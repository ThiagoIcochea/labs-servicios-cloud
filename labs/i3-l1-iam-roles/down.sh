#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/comun.sh"
banner "Limpieza · Insignia 3 · Lab 1"
SA="${P}-i3l1-auditor@${PROJECT_ID}.iam.gserviceaccount.com"
gcloud projects remove-iam-policy-binding "$PROJECT_ID" --member "serviceAccount:$SA" \
  --role "projects/$PROJECT_ID/roles/${P}_i3l1_auditor" --condition=None --format=none 2>/dev/null || true
borrar gcloud storage rm -r "gs://${PROJECT_ID}-${P}-i3l1"
borrar gcloud iam service-accounts delete "$SA"
borrar gcloud iam roles delete "${P}_i3l1_auditor" --project "$PROJECT_ID"
fin_limpieza
