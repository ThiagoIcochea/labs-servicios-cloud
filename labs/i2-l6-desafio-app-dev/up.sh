#!/usr/bin/env bash
# Insignia 2 - Lab de desafío: Set Up an App Dev Environment on Google Cloud
source "$(dirname "$0")/../../lib/comun.sh"
banner "Insignia 2 · DESAFÍO · Set Up an App Dev Environment"
habilitar_apis cloudfunctions.googleapis.com cloudbuild.googleapis.com artifactregistry.googleapis.com \
  run.googleapis.com eventarc.googleapis.com pubsub.googleapis.com storage.googleapis.com logging.googleapis.com
BUCKET="${PROJECT_ID}-${P}-i2l6-imagenes"
TOPICO="${P}-i2l6-miniaturas"; SUB="${P}-i2l6-verificacion"
FN="${P}-i2l6-miniaturas-fn"
EX_ID="${P}-ex-ingeniero"; EX="${EX_ID}@${PROJECT_ID}.iam.gserviceaccount.com"
NUM_PROY="$(gcloud projects describe "$PROJECT_ID" --format='value(projectNumber)')"
SA_COMPUTE="${NUM_PROY}-compute@developer.gserviceaccount.com"

paso "Tarea 1) Bucket para las imágenes: gs://$BUCKET"
existe gcloud storage buckets describe "gs://$BUCKET" || \
  cmd gcloud storage buckets create "gs://$BUCKET" --location "$REGION" --uniform-bucket-level-access
cmd gcloud storage buckets update "gs://$BUCKET" --update-labels "$ETIQUETAS"

paso "Tarea 2) Tópico Pub/Sub $TOPICO (y una suscripción para verificar)"
existe gcloud pubsub topics describe "$TOPICO" || cmd gcloud pubsub topics create "$TOPICO" --labels "$ETIQUETAS"
existe gcloud pubsub subscriptions describe "$SUB" || cmd gcloud pubsub subscriptions create "$SUB" --topic "$TOPICO"

paso "Permisos que necesitan los disparadores de eventos de Cloud Storage"
SA_GCS="$(gcloud storage service-agent --project "$PROJECT_ID")"
# La cuenta de servicio de Cloud Storage puede tardar unos minutos en existir en un proyecto nuevo
for intento in $(seq 1 12); do
  if gcloud projects add-iam-policy-binding "$PROJECT_ID" --member "serviceAccount:$SA_GCS" \
      --role roles/pubsub.publisher --condition=None --format=none 2>/dev/null; then
    ok "roles/pubsub.publisher otorgado a $SA_GCS"; break
  fi
  aviso "La cuenta de servicio de Cloud Storage aún se está creando (intento $intento/12). Reintento en 15 s…"
  gcloud storage ls "gs://$BUCKET" >/dev/null 2>&1 || true
  sleep 15
done
for R in roles/eventarc.eventReceiver roles/run.invoker roles/artifactregistry.reader; do
  gcloud projects add-iam-policy-binding "$PROJECT_ID" --member "serviceAccount:$SA_COMPUTE" --role "$R" --condition=None --format=none
done

paso "Tarea 3) Cloud Function $FN que crea miniaturas y publica en $TOPICO (tarda ~3 min)"
cat > "$TRABAJO/env.yaml" <<YAML
TOPICO: "projects/$PROJECT_ID/topics/$TOPICO"
NOMBRE: "$MARCA"
YAML
cmd gcloud functions deploy "$FN" --gen2 --region "$REGION" --runtime python312 \
  --source "$(dirname "$0")/funcion" --entry-point crear_miniatura \
  --trigger-event-filters "type=google.cloud.storage.object.v1.finalized" \
  --trigger-event-filters "bucket=$BUCKET" --env-vars-file "$TRABAJO/env.yaml" \
  --memory 512Mi --max-instances 2 --update-labels "$ETIQUETAS" --retry || {
  aviso "El primer despliegue a veces falla porque los permisos de Eventarc aún se propagan. Reintentando en 60 s…"
  sleep 60
  gcloud functions deploy "$FN" --gen2 --region "$REGION" --runtime python312 \
    --source "$(dirname "$0")/funcion" --entry-point crear_miniatura \
    --trigger-event-filters "type=google.cloud.storage.object.v1.finalized" \
    --trigger-event-filters "bucket=$BUCKET" --env-vars-file "$TRABAJO/env.yaml" \
    --memory 512Mi --max-instances 2 --update-labels "$ETIQUETAS"
}

paso "Tarea 4) Subiendo una imagen de prueba con el nombre del alumno"
if command -v convert >/dev/null; then
  convert -size 640x400 gradient:'#34a853'-'#1a73e8' -fill white -gravity center -pointsize 36 \
    -annotate +0-40 "$NOMBRE" -pointsize 26 -annotate +0+10 "Código $CODIGO" -pointsize 22 -annotate +0+55 "Sección $SECCION - Desafío Insignia 2" "$TRABAJO/foto-${P}.png"
else
  python3 -m pip install --user -q pillow
  python3 - "$TRABAJO/foto-${P}.png" "$MARCA" <<'PY'
import sys
from PIL import Image, ImageDraw
img = Image.new("RGB", (640, 400), (26, 115, 232)); ImageDraw.Draw(img).text((40, 190), sys.argv[2], fill="white"); img.save(sys.argv[1])
PY
fi
cmd gcloud storage cp "$TRABAJO/foto-${P}.png" "gs://$BUCKET/foto-${P}.png"

paso "Esperando la miniatura generada por la función…"
for i in $(seq 1 30); do
  LISTA="$(gcloud storage ls "gs://$BUCKET" || true)"
  if grep -q miniatura <<<"$LISTA"; then echo "$LISTA"; ok "¡Miniatura creada!"; break; fi
  sleep 10
done
paso "Mensaje publicado en Pub/Sub por la función"
gcloud pubsub subscriptions pull "$SUB" --auto-ack --limit 5 --format='value(message.data.decode(base64).decode(utf-8))' || true

paso "Tarea 5) Quitar el acceso del ingeniero anterior ($EX)"
existe gcloud iam service-accounts describe "$EX" || \
  gcloud iam service-accounts create "$EX_ID" --display-name "Ingeniero anterior (lab de $NOMBRE)"
gcloud projects add-iam-policy-binding "$PROJECT_ID" --member "serviceAccount:$EX" --role roles/viewer --condition=None --format=none
echo "Antes:"; gcloud projects get-iam-policy "$PROJECT_ID" --flatten='bindings[].members' --filter="bindings.members:$EX" --format='table(bindings.role,bindings.members)'
cmd gcloud projects remove-iam-policy-binding "$PROJECT_ID" --member "serviceAccount:$EX" --role roles/viewer --condition=None --format=none
echo "Después (vacío = sin acceso):"; gcloud projects get-iam-policy "$PROJECT_ID" --flatten='bindings[].members' --filter="bindings.members:$EX" --format='table(bindings.role,bindings.members)'

paso "Logs de la función"
gcloud functions logs read "$FN" --gen2 --region "$REGION" --limit 8 || true
ok "Miniatura pública solo para el proyecto: gs://$BUCKET/foto-${P}64x64_miniatura.png"
fin_lab
