#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/comun.sh"
source "$RAIZ/lib/terraform.sh"
banner "Limpieza · Insignia 4 · Lab 1 (terraform destroy)"
if [[ -d "$TF_DIR" ]]; then tf destroy -auto-approve -input=false; else
  borrar gcloud compute instances delete "${P}-i4l1-terraform" --zone "$ZONA"; fi
fin_limpieza
