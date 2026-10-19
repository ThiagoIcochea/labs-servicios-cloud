#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/comun.sh"
banner "Limpieza · Insignia 1 · Lab 1"
borrar gcloud compute instances delete "${P}-i1l1-web" "${P}-i1l1-gcelab2" --zone "$ZONA"
borrar gcloud compute firewall-rules delete "${P}-i1l1-http"
fin_limpieza
