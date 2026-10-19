#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/comun.sh"
source "$RAIZ/lib/terraform.sh"
banner "Limpieza · Insignia 4 · Lab 4"
if [[ -d "$TF_DIR" ]]; then
  # El estado vive en el bucket que vamos a borrar: primero lo devolvemos a local
  if [[ -f "$TF_DIR/backend.tf" ]]; then
    rm -f "$TF_DIR/backend.tf"
    tf init -input=false -migrate-state -force-copy || true
  fi
  rm -f "$TF_DIR/importada.tf"
  tf destroy -auto-approve -input=false || true
fi
borrar gcloud compute instances delete "${P}-i4l4-importada" --zone "$ZONA"
borrar gcloud storage rm -r "gs://${PROJECT_ID}-${P}-i4l4-tfstate"
fin_limpieza
