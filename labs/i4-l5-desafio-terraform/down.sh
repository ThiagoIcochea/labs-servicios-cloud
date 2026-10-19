#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/comun.sh"
source "$RAIZ/lib/terraform.sh"
banner "Limpieza · Insignia 4 · Desafío Terraform"
if [[ -d "$TF_DIR" ]]; then
  if [[ -f "$TF_DIR/backend.tf" ]]; then rm -f "$TF_DIR/backend.tf"; tf init -input=false -migrate-state -force-copy || true; fi
  tf destroy -auto-approve -input=false -var etapa=4 || true
fi
for i in 1 2 3; do borrar gcloud compute instances delete "${P}-tf-instance-$i" --zone "$ZONA"; done
borrar gcloud compute firewall-rules delete "${P}-tf-firewall"
borrar gcloud compute networks subnets delete "${P}-subnet-01" "${P}-subnet-02" --region "$REGION"
borrar gcloud compute networks delete "${P}-tf-vpc"
borrar gcloud storage rm -r "gs://${PROJECT_ID}-${P}-i4l5-backend"
fin_limpieza
