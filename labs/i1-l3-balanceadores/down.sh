#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/comun.sh"
banner "Limpieza · Insignia 1 · Lab 3"
borrar gcloud compute forwarding-rules delete "${P}-http-content-rule" --global
borrar gcloud compute target-http-proxies delete "${P}-http-lb-proxy"
borrar gcloud compute url-maps delete "${P}-web-map-http"
borrar gcloud compute backend-services delete "${P}-web-backend-service" --global
borrar gcloud compute health-checks delete "${P}-http-basic-check"
borrar gcloud compute addresses delete "${P}-lb-ipv4-1" --global
borrar gcloud compute instance-groups managed delete "${P}-lb-backend-group" --zone "$ZONA"
borrar gcloud compute instance-templates delete "${P}-lb-backend-template"
borrar gcloud compute forwarding-rules delete "${P}-www-rule" --region "$REGION"
borrar gcloud compute target-pools delete "${P}-www-pool" --region "$REGION"
borrar gcloud compute http-health-checks delete "${P}-basic-check"
borrar gcloud compute addresses delete "${P}-network-lb-ip-1" --region "$REGION"
borrar gcloud compute instances delete "${P}-www1" "${P}-www2" "${P}-www3" --zone "$ZONA"
borrar gcloud compute firewall-rules delete "${P}-www-firewall-network-lb"
borrar gcloud compute firewall-rules delete "${P}-fw-allow-health-check"
fin_limpieza
