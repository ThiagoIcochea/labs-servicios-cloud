#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Funciones comunes para todos los laboratorios.
# Cada up.sh / down.sh hace:  source "$(dirname "$0")/../../lib/comun.sh"
# y recibe del lanzador (./lab) las variables ALUMNO y LAB_ID.
# ---------------------------------------------------------------------------
set -Eeuo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$RAIZ/config/curso.env"

: "${ALUMNO:?Falta ALUMNO. Usa: ./lab <alumno> <lab> [up|down]}"
: "${LAB_ID:?Falta LAB_ID. Usa: ./lab <alumno> <lab> [up|down]}"

# --- Datos del alumno -------------------------------------------------------
_linea="$(grep -E "^${ALUMNO};" "$RAIZ/config/alumnos.csv" || true)"
if [[ -z "$_linea" ]]; then
  echo "ERROR: el alumno '$ALUMNO' no está en config/alumnos.csv" >&2
  exit 1
fi
IFS=';' read -r ALUMNO_SLUG P NOMBRE CODIGO CORREO <<<"$_linea"
CODIGO="${CODIGO:-sin código}"
MARCA="${NOMBRE} · ${CODIGO}"   # marca personal que aparece en todas las evidencias
CORREO="${CORREO:-$(gcloud config get-value account 2>/dev/null || true)}"
export ALUMNO_SLUG P NOMBRE CODIGO CORREO MARCA

# --- Proyecto y ubicación -----------------------------------------------------
PROJECT_ID="${PROJECT_ID:-$(gcloud config get-value project 2>/dev/null || true)}"
PROJECT_ID="${PROJECT_ID:-$PROJECT_ID_DEFECTO}"
REGION="${REGION:-$REGION_DEFECTO}"
ZONA="${ZONA:-$ZONA_DEFECTO}"
REGION2="${REGION2:-$REGION2_DEFECTO}"
ZONA2="${ZONA2:-$ZONA2_DEFECTO}"
export PROJECT_ID REGION ZONA REGION2 ZONA2
export CLOUDSDK_CORE_PROJECT="$PROJECT_ID"
export CLOUDSDK_COMPUTE_REGION="$REGION"
export CLOUDSDK_COMPUTE_ZONE="$ZONA"
export CLOUDSDK_CORE_DISABLE_PROMPTS=1

# Identificador corto del lab sin guiones (i1-l1 -> i1l1)
LAB_CORTO="$(echo "$LAB_ID" | cut -d- -f1-2 | tr -d '-')"
# Etiquetas que llevan TODOS los recursos (sirven para filtrar y limpiar)
ETIQUETAS="alumno=${P},seccion=${SECCION},curso=servicios-cloud,lab=${LAB_CORTO}"
# Carpeta de trabajo temporal del alumno para este lab
TRABAJO="${HOME}/labs-trabajo/${P}/${LAB_ID}"
mkdir -p "$TRABAJO"
export LAB_CORTO ETIQUETAS TRABAJO

ahora() { TZ=America/Lima date '+%Y-%m-%d %H:%M:%S (hora de Lima)'; }

# --- Salida en pantalla -------------------------------------------------------
C_AZ='\033[1;36m'; C_VE='\033[1;32m'; C_AM='\033[1;33m'; C_RO='\033[1;31m'; C_NO='\033[0m'

banner() {
  local titulo="$1" linea="════════════════════════════════════════════════════════════════════════"
  echo -e "${C_AZ}╔${linea}"
  echo "║  $titulo"
  echo "╠${linea}"
  echo "║  Alumno   : $NOMBRE"
  echo "║  Código   : $CODIGO"
  echo "║  Curso    : $CURSO - Sección $SECCION ($UNIVERSIDAD)"
  echo "║  Docente  : $DOCENTE"
  echo "║  Proyecto : $PROJECT_ID    Lab: $LAB_ID"
  echo "║  Fecha    : $(ahora)"
  echo -e "╚${linea}${C_NO}"
}

paso()  { echo -e "\n${C_AM}▶ $*${C_NO}"; }
ok()    { echo -e "${C_VE}✔ $*${C_NO}"; }
aviso() { echo -e "${C_RO}⚠ $*${C_NO}"; }
cmd()   { echo -e "${C_AZ}\$ $*${C_NO}"; "$@"; }

trap 'aviso "Error en la línea $LINENO. Revisa el mensaje de arriba; puedes volver a ejecutar el lab (es idempotente) o limpiarlo con: ./lab $ALUMNO $LAB_ID down"' ERR

# --- APIs -----------------------------------------------------------------
habilitar_apis() {
  paso "Habilitando APIs necesarias: $*"
  gcloud services enable "$@" --project "$PROJECT_ID"
}

# --- Utilidades para recursos ------------------------------------------------
existe() { "$@" >/dev/null 2>&1; }

borrar() { # ejecuta un borrado sin fallar si el recurso no existe
  echo -e "${C_AZ}\$ $*${C_NO}"
  "$@" --quiet 2>&1 | grep -v -E 'was not found|not found|NOT_FOUND|Could not fetch resource|^ - |^$' || true
}

ip_externa_vm() { # $1 = nombre, $2 = zona (opcional)
  gcloud compute instances describe "$1" --zone "${2:-$ZONA}" \
    --format='get(networkInterfaces[0].accessConfigs[0].natIP)'
}

esperar_http() { # $1 = URL, $2 = texto esperado, $3 = intentos (10 s c/u)
  local url="$1" texto="$2" intentos="${3:-40}" i
  paso "Esperando que $url responda con \"$texto\" (puede tardar unos minutos)…"
  for ((i = 1; i <= intentos; i++)); do
    local cuerpo; cuerpo="$(curl -s -m 5 "$url" || true)"
    if grep -q "$texto" <<<"$cuerpo"; then
      ok "Responde correctamente ($url)"
      return 0
    fi
    sleep 10
  done
  aviso "No respondió a tiempo. Vuelve a probar en un minuto con: curl $url"
  return 0
}

# --- Página HTML con los datos del alumno (evidencia) -------------------------------------
# Genera un startup-script que instala NGINX y publica una página con los datos
# del alumno. $1 = título del lab, $2 = detalle (opcional)
startup_nginx() {
  local titulo="$1" detalle="${2:-}"
  cat <<EOF
#!/bin/bash
apt-get update -y
apt-get install -y nginx
HOST=\$(hostname)
ZONA_VM=\$(curl -s -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/zone | awk -F/ '{print \$NF}')
IP_INT=\$(hostname -I | awk '{print \$1}')
cat > /var/www/html/index.html <<HTML
<!doctype html><html lang="es"><head><meta charset="utf-8"><title>${titulo}</title>
<style>body{font-family:Arial,sans-serif;background:#f1f5fb;margin:0;padding:40px}
.card{max-width:760px;margin:auto;background:#fff;border-radius:14px;padding:32px;
box-shadow:0 6px 24px rgba(0,0,0,.08);border-top:8px solid #1a73e8}
h1{color:#1a73e8;margin-top:0}td{padding:6px 12px}td:first-child{font-weight:bold;color:#555}</style></head>
<body><div class="card"><h1>${titulo}</h1>
<table>
<tr><td>Alumno</td><td>${NOMBRE}</td></tr>
<tr><td>Código</td><td>${CODIGO}</td></tr>
<tr><td>Curso</td><td>${CURSO} - Sección ${SECCION}</td></tr>
<tr><td>Docente</td><td>${DOCENTE}</td></tr>
<tr><td>Programa</td><td>${PROGRAMA}</td></tr>
<tr><td>Proyecto</td><td>${PROJECT_ID}</td></tr>
<tr><td>Servidor</td><td>\$HOST (\$ZONA_VM) - IP interna \$IP_INT</td></tr>
<tr><td>Detalle</td><td>${detalle}</td></tr>
<tr><td>Generado</td><td>$(ahora)</td></tr>
<tr><td>Hora del equipo</td><td id='reloj' style='font-weight:bold;color:#1a73e8'></td></tr>
</table><script>function r(){var d=new Date();document.getElementById('reloj').textContent=d.toLocaleDateString('es-PE')+' '+d.toLocaleTimeString('es-PE')}r();setInterval(r,1000)</script><p style='margin-top:24px;color:#888;font-size:13px'>${MARCA} · ${CURSO} ${SECCION}</p></div></body></html>
HTML
systemctl restart nginx
EOF
}

# Igual que startup_nginx pero SIN instalar paquetes: sirve la página con python3
# (Debian 12 ya lo trae). Sirve para VMs SIN IP externa: la prueba gratuita solo
# permite 4 IPs externas en uso por región.
startup_python() {
  startup_nginx "$@" | sed -e '/^apt-get/d' -e 's#/var/www/html#/opt/web#g' \
    -e 's#^cat > /opt/web/index.html#mkdir -p /opt/web \&\& cat > /opt/web/index.html#' \
    -e '/^systemctl restart nginx/d'
  cat <<'UNIDAD'
cat > /etc/systemd/system/web-lab.service <<UNIT
[Unit]
Description=Pagina del lab
After=network-online.target
[Service]
WorkingDirectory=/opt/web
ExecStart=/usr/bin/python3 -m http.server 80
Restart=always
[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable --now web-lab.service
UNIDAD
}

# Escribe un archivo de texto de evidencia con los datos del alumno
texto_evidencia() { # $1 = archivo, $2 = título
  cat >"$1" <<EOF
==============================================================
 ${2}
--------------------------------------------------------------
 Alumno   : ${NOMBRE}
 Código   : ${CODIGO}
 Curso    : ${CURSO} - Sección ${SECCION}
 Docente  : ${DOCENTE}
 Proyecto : ${PROJECT_ID}
 Lab      : ${LAB_ID}
 Fecha    : $(ahora)
==============================================================
EOF
}

resumen_recursos() {
  paso "Recursos de Compute Engine con la etiqueta alumno=${P} y lab=${LAB_CORTO}"
  gcloud compute instances list --filter="labels.alumno=${P} AND labels.lab=${LAB_CORTO}" \
    --format='table(name,zone.basename(),machineType.basename(),status,networkInterfaces[0].accessConfigs[0].natIP:label=IP_EXTERNA,labels.alumno)' || true
}

fin_lab() {
  echo
  ok "Lab ${LAB_ID} terminado para ${NOMBRE} - $(ahora)"
  echo -e "${C_AM}Toma tus capturas y luego limpia con:  ./lab ${ALUMNO} ${LAB_ID} down${C_NO}"
}

fin_limpieza() {
  paso "Verificación: recursos que aún tienen el prefijo ${P} y el lab ${LAB_CORTO}"
  echo "VMs:";          gcloud compute instances list --filter="labels.alumno=${P} AND labels.lab=${LAB_CORTO}" --format='value(name)' 2>/dev/null | sed 's/^/  - /' || true
  echo "Firewall:";     gcloud compute firewall-rules list --filter="name~^${P}-${LAB_CORTO}" --format='value(name)' 2>/dev/null | sed 's/^/  - /' || true
  echo "Buckets:";      gcloud storage buckets list --format='value(name)' 2>/dev/null | grep -E -- "-${P}-${LAB_CORTO}" | sed 's/^/  - /' || true
  echo "(si las listas están vacías, no queda nada del lab)"
  echo
  ok "Limpieza de ${LAB_ID} completada para ${NOMBRE} - $(ahora). No quedan recursos de este lab cobrando."
}
