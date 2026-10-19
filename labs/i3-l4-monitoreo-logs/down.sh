#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/comun.sh"
banner "Limpieza · Insignia 3 · Lab 4"
for n in $(gcloud monitoring dashboards list --filter="displayName~\"${P} ${LAB_CORTO}\"" --format='value(name)'); do borrar gcloud monitoring dashboards delete "$n"; done
borrar gcloud logging metrics delete "${P}_i3l4_visitas"
borrar gcloud compute instances delete "${P}-i3l4-apache" --zone "$ZONA"
borrar gcloud compute firewall-rules delete "${P}-i3l4-http"
fin_limpieza
