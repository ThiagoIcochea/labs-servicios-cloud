#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/comun.sh"
banner "Limpieza · Insignia 1 · Desafío"
borrar gcloud compute forwarding-rules delete "${P}-desafio-fr" --global
borrar gcloud compute target-http-proxies delete "${P}-desafio-proxy"
borrar gcloud compute url-maps delete "${P}-desafio-lb"
borrar gcloud compute backend-services delete "${P}-desafio-backend" --global
borrar gcloud compute health-checks delete "${P}-desafio-hc"
borrar gcloud compute instance-groups managed delete "${P}-desafio-mig" --zone "$ZONA"
borrar gcloud compute instance-templates delete "${P}-desafio-template"
borrar gcloud compute instances delete "${P}-jumphost" --zone "$ZONA"
borrar gcloud compute firewall-rules delete "${P}-permit-tcp-rule-80"
fin_limpieza
