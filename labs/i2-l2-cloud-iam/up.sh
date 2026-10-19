#!/usr/bin/env bash
# Insignia 2 - Lab 2: Cloud IAM: Qwik Start
# El lab original usa 2 usuarios. Aquí el "Usuario 2" es una cuenta de servicio
# del alumno, y las pruebas se hacen suplantándola (--impersonate-service-account).
source "$(dirname "$0")/../../lib/comun.sh"
banner "Insignia 2 · Lab 2 · Cloud IAM: conceder y revocar permisos"
habilitar_apis iam.googleapis.com iamcredentials.googleapis.com storage.googleapis.com
YO="$(gcloud config get-value account)"
SA_ID="${P}-usuario2"
SA="${SA_ID}@${PROJECT_ID}.iam.gserviceaccount.com"
BUCKET="gs://${PROJECT_ID}-${P}-i2l2"

como_usuario2() { gcloud storage ls "$BUCKET" --impersonate-service-account="$SA" 2>&1 | grep -v WARNING || true; }
puede_ver() { local out; out="$(como_usuario2)"; echo "$out" > "$TRABAJO/ultimo.txt"; grep -q sample.txt <<<"$out"; }

paso "1) Usuario 1 = $YO (propietario). Creando el Usuario 2: $SA"
existe gcloud iam service-accounts describe "$SA" || \
  cmd gcloud iam service-accounts create "$SA_ID" --display-name "Usuario 2 de $NOMBRE (lab IAM)"
cmd gcloud iam service-accounts add-iam-policy-binding "$SA" \
  --member "user:$YO" --role roles/iam.serviceAccountTokenCreator --format=none

paso "2) Usuario 1 crea un bucket y sube un archivo"
existe gcloud storage buckets describe "$BUCKET" || cmd gcloud storage buckets create "$BUCKET" --location US
texto_evidencia "$TRABAJO/sample.txt" "Insignia 2 · Lab 2 · Cloud IAM (archivo de prueba)"
cmd gcloud storage cp "$TRABAJO/sample.txt" "$BUCKET/sample.txt"

paso "3) Concediendo al Usuario 2 el rol Visor (roles/viewer) del proyecto"
cmd gcloud projects add-iam-policy-binding "$PROJECT_ID" --member "serviceAccount:$SA" \
  --role roles/viewer --condition=None --format=none
gcloud projects get-iam-policy "$PROJECT_ID" --flatten='bindings[].members' \
  --filter="bindings.members:$SA" --format='table(bindings.role,bindings.members)'

paso "4) Usuario 2 intenta listar el bucket (debe PODER, espera propagación de IAM)"
for i in $(seq 1 12); do
  if puede_ver; then cat "$TRABAJO/ultimo.txt"; ok "Usuario 2 SÍ puede ver el bucket con roles/viewer"; break; fi
  sleep 10
done

paso "5) Quitando el rol Visor al Usuario 2"
cmd gcloud projects remove-iam-policy-binding "$PROJECT_ID" --member "serviceAccount:$SA" \
  --role roles/viewer --condition=None --format=none

paso "6) Usuario 2 vuelve a intentarlo (ahora debe ser RECHAZADO con 403)"
for i in $(seq 1 18); do
  if ! puede_ver; then tail -3 "$TRABAJO/ultimo.txt"; ok "Acceso revocado: el Usuario 2 ya NO puede listar el bucket"; break; fi
  sleep 10
done

paso "7) Concediendo solo Storage Object Viewer al Usuario 2 (principio de mínimo privilegio)"
cmd gcloud projects add-iam-policy-binding "$PROJECT_ID" --member "serviceAccount:$SA" \
  --role roles/storage.objectViewer --condition=None --format=none
for i in $(seq 1 12); do
  if puede_ver; then cat "$TRABAJO/ultimo.txt"; ok "Usuario 2 puede leer objetos con roles/storage.objectViewer"; break; fi
  sleep 10
done
paso "Contenido leído por el Usuario 2:"
gcloud storage cat "$BUCKET/sample.txt" --impersonate-service-account="$SA" 2>/dev/null || true

paso "8) Política IAM final para el Usuario 2"
gcloud projects get-iam-policy "$PROJECT_ID" --flatten='bindings[].members' \
  --filter="bindings.members:$SA" --format='table(bindings.role,bindings.members)'
fin_lab
