#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/comun.sh"
banner "Limpieza · Insignia 3 · Desafío"
CL="${P}-i3l6-gke"; VPC="${P}-desafio-vpc"
for n in $(gcloud monitoring uptime list-configs --filter="displayName~\"${P} i3l6\"" --format='value(name)'); do borrar gcloud monitoring uptime delete "$n"; done
if gcloud container clusters describe "$CL" --zone "$ZONA" >/dev/null 2>&1; then
  gcloud container clusters get-credentials "$CL" --zone "$ZONA"
  kubectl -n produccion delete svc app-desafio --ignore-not-found --wait=true || true
  sleep 30
fi
borrar gcloud container clusters delete "$CL" --zone "$ZONA"
for S in "${P}-i3l6-dev" "${P}-i3l6-ex"; do
  gcloud projects remove-iam-policy-binding "$PROJECT_ID" --member "serviceAccount:${S}@${PROJECT_ID}.iam.gserviceaccount.com" --role roles/container.developer --condition=None --format=none 2>/dev/null || true
  borrar gcloud iam service-accounts delete "${S}@${PROJECT_ID}.iam.gserviceaccount.com"
done
for N in ssh internal; do borrar gcloud compute firewall-rules delete "${VPC}-allow-$N"; done
# Reglas de firewall que GKE crea automáticamente en la VPC
for r in $(gcloud compute firewall-rules list --filter="network~$VPC" --format='value(name)'); do borrar gcloud compute firewall-rules delete "$r"; done
borrar gcloud compute networks subnets delete "${P}-desafio-prod" "${P}-desafio-dev" --region "$REGION"
borrar gcloud compute networks delete "$VPC"
fin_limpieza
