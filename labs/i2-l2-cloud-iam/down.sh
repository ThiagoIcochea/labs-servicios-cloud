#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/comun.sh"
banner "Limpieza · Insignia 2 · Lab 2"
SA="${P}-usuario2@${PROJECT_ID}.iam.gserviceaccount.com"
for R in roles/viewer roles/storage.objectViewer; do
  gcloud projects remove-iam-policy-binding "$PROJECT_ID" --member "serviceAccount:$SA" --role "$R" --condition=None --format=none 2>/dev/null || true
done
borrar gcloud storage rm -r "gs://${PROJECT_ID}-${P}-i2l2"
borrar gcloud iam service-accounts delete "$SA"
fin_limpieza
