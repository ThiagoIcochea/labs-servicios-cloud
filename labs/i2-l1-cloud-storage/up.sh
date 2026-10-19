#!/usr/bin/env bash
# Insignia 2 - Lab 1: Cloud Storage: Qwik Start - CLI/SDK
source "$(dirname "$0")/../../lib/comun.sh"
banner "Insignia 2 · Lab 1 · Cloud Storage (CLI/SDK)"
habilitar_apis storage.googleapis.com
BUCKET="gs://${PROJECT_ID}-${P}-i2l1"

paso "1) Creando el bucket $BUCKET (control de acceso detallado para poder publicar objetos)"
existe gcloud storage buckets describe "$BUCKET" || \
  cmd gcloud storage buckets create "$BUCKET" --location US --no-uniform-bucket-level-access
cmd gcloud storage buckets update "$BUCKET" --update-labels "$ETIQUETAS"

paso "2) Generando los objetos de evidencia personalizados"
texto_evidencia "$TRABAJO/evidencia.txt" "Insignia 2 · Lab 1 · Cloud Storage"
cat > "$TRABAJO/index.html" <<HTML
<!doctype html><html lang="es"><head><meta charset="utf-8"><title>Cloud Storage - ${NOMBRE}</title></head>
<body style="font-family:Arial;background:#fef7e0;padding:40px">
<h1 style="color:#e37400">Objeto público en Cloud Storage</h1>
<p><b>Alumno:</b> ${NOMBRE}<br><b>Curso:</b> ${CURSO} - Sección ${SECCION}<br>
<b>Docente:</b> ${DOCENTE}<br><b>Bucket:</b> ${BUCKET}<br><b>Fecha:</b> $(ahora)</p></body></html>
HTML
# Imagen con el nombre del alumno (ImageMagick viene en Cloud Shell; si no, se usa SVG)
if command -v convert >/dev/null; then
  convert -size 900x300 xc:'#1a73e8' -fill white -gravity center -pointsize 34 \
    -annotate +0-40 "$NOMBRE" -pointsize 24 -annotate +0+30 "$CURSO - Sección $SECCION" \
    -pointsize 18 -annotate +0+80 "Insignia 2 · Lab 1 · $(ahora)" "$TRABAJO/credencial.png"
  IMG="credencial.png"
else
  cat > "$TRABAJO/credencial.svg" <<SVG
<svg xmlns="http://www.w3.org/2000/svg" width="900" height="300"><rect width="900" height="300" fill="#1a73e8"/>
<text x="450" y="130" font-size="34" fill="#fff" text-anchor="middle" font-family="Arial">${NOMBRE}</text>
<text x="450" y="190" font-size="24" fill="#fff" text-anchor="middle" font-family="Arial">${CURSO} - Sección ${SECCION}</text></svg>
SVG
  IMG="credencial.svg"
fi

paso "3) Subiendo objetos al bucket"
cmd gcloud storage cp "$TRABAJO/evidencia.txt" "$TRABAJO/index.html" "$TRABAJO/$IMG" "$BUCKET/"

paso "4) Descargando el objeto de vuelta (como en el lab)"
cmd gcloud storage cp "$BUCKET/evidencia.txt" "$TRABAJO/descargado.txt"
cat "$TRABAJO/descargado.txt"

paso "5) Copiando a carpetas y subcarpetas"
cmd gcloud storage cp "$BUCKET/$IMG" "$BUCKET/carpeta-${P}/imagenes/$IMG"
cmd gcloud storage cp "$BUCKET/evidencia.txt" "$BUCKET/carpeta-${P}/documentos/evidencia.txt"

paso "6) Listando el contenido del bucket y los detalles de un objeto"
cmd gcloud storage ls -r "$BUCKET"
cmd gcloud storage ls -l "$BUCKET/$IMG"

paso "7) Haciendo públicos la página y la imagen (allUsers con rol READER)"
cmd gcloud storage objects update "$BUCKET/index.html" --add-acl-grant=entity=allUsers,role=READER
cmd gcloud storage objects update "$BUCKET/$IMG" --add-acl-grant=entity=allUsers,role=READER
URL="https://storage.googleapis.com/${BUCKET#gs://}/index.html"
esperar_http "$URL" "$NOMBRE" 6
ok "Página pública:  $URL"
ok "Imagen pública:  https://storage.googleapis.com/${BUCKET#gs://}/$IMG"
fin_lab
