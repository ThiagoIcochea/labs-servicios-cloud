#!/usr/bin/env bash
# Insignia 3 - Lab 1: IAM en la nube (Qwik Start) - variante con rol personalizado
# Mismo objetivo que i2-l2 (conceder y revocar acceso), pero con un ROL PERSONALIZADO
# para que la evidencia sea distinta.
source "$(dirname "$0")/../../lib/comun.sh"
banner "Insignia 3 · Lab 1 · IAM: roles predefinidos y personalizados"
habilitar_apis iam.googleapis.com iamcredentials.googleapis.com storage.googleapis.com compute.googleapis.com
YO="$(gcloud config get-value account)"
ROL="${P}_i3l1_auditor"
SA_ID="${P}-i3l1-auditor"; SA="${SA_ID}@${PROJECT_ID}.iam.gserviceaccount.com"
BUCKET="gs://${PROJECT_ID}-${P}-i3l1"

paso "1) Explorando roles predefinidos: qué incluye roles/storage.objectViewer"
gcloud iam roles describe roles/storage.objectViewer --format='yaml(title,includedPermissions)'

paso "2) Creando el ROL PERSONALIZADO $ROL (solo lectura de buckets y VMs)"
ESTADO="$(gcloud iam roles describe "$ROL" --project "$PROJECT_ID" --format='value(deleted)' 2>/dev/null || echo NOEXISTE)"
if [[ "$ESTADO" == "NOEXISTE" ]]; then
  cmd gcloud iam roles create "$ROL" --project "$PROJECT_ID" \
    --title "Auditor de $NOMBRE" --description "Rol personalizado del lab i3-l1 - $CURSO sección $SECCION" \
    --permissions storage.buckets.list,storage.objects.list,storage.objects.get,compute.instances.list,compute.zones.list \
    --stage GA
else
  [[ "$ESTADO" == "True" ]] && cmd gcloud iam roles undelete "$ROL" --project "$PROJECT_ID"
  cmd gcloud iam roles update "$ROL" --project "$PROJECT_ID" --title "Auditor de $NOMBRE" \
    --permissions storage.buckets.list,storage.objects.list,storage.objects.get,compute.instances.list,compute.zones.list
fi
gcloud iam roles describe "$ROL" --project "$PROJECT_ID" --format='yaml(name,title,description,includedPermissions,stage)'

paso "3) Cuenta de servicio que usará el rol: $SA"
existe gcloud iam service-accounts describe "$SA" || \
  cmd gcloud iam service-accounts create "$SA_ID" --display-name "Auditor del lab i3-l1 de $NOMBRE"
gcloud iam service-accounts add-iam-policy-binding "$SA" --member "user:$YO" \
  --role roles/iam.serviceAccountTokenCreator --format=none

paso "4) Bucket con un archivo para auditar"
existe gcloud storage buckets describe "$BUCKET" || cmd gcloud storage buckets create "$BUCKET" --location US
texto_evidencia "$TRABAJO/informe.txt" "Insignia 3 · Lab 1 · Informe leído por el auditor"
cmd gcloud storage cp "$TRABAJO/informe.txt" "$BUCKET/informe.txt"

prueba() {
  local out; out="$(gcloud storage cat "$BUCKET/informe.txt" --impersonate-service-account="$SA" 2>&1 || true)"
  echo "$out" > "$TRABAJO/prueba.txt"; grep -q "$NOMBRE" <<<"$out"
}

paso "5) Asignando el rol personalizado al auditor"
cmd gcloud projects add-iam-policy-binding "$PROJECT_ID" --member "serviceAccount:$SA" \
  --role "projects/$PROJECT_ID/roles/$ROL" --condition=None --format=none
for i in $(seq 1 12); do if prueba; then cat "$TRABAJO/prueba.txt"; ok "El auditor PUEDE leer con el rol personalizado"; break; fi; sleep 10; done
paso "El auditor también puede listar VMs (permiso compute.instances.list):"
gcloud compute instances list --impersonate-service-account="$SA" --format='table(name,zone.basename(),status)' 2>&1 | grep -v WARNING || true

paso "6) Revocando el rol personalizado"
cmd gcloud projects remove-iam-policy-binding "$PROJECT_ID" --member "serviceAccount:$SA" \
  --role "projects/$PROJECT_ID/roles/$ROL" --condition=None --format=none
for i in $(seq 1 18); do if ! prueba; then tail -2 "$TRABAJO/prueba.txt"; ok "Acceso revocado (403)"; break; fi; sleep 10; done

paso "7) Roles personalizados del proyecto"
gcloud iam roles list --project "$PROJECT_ID" --format='table(name.basename(),title,stage)'
fin_lab
