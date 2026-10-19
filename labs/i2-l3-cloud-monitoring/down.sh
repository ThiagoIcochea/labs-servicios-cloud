#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/comun.sh"
banner "Limpieza · Insignia 2 · Lab 3"
for n in $(gcloud alpha monitoring policies list --filter="displayName~\"${P} ${LAB_CORTO}\"" --format='value(name)'); do borrar gcloud alpha monitoring policies delete "$n"; done
for n in $(gcloud monitoring uptime list-configs --filter="displayName~\"${P} ${LAB_CORTO}\"" --format='value(name)'); do borrar gcloud monitoring uptime delete "$n"; done
for n in $(gcloud monitoring dashboards list --filter="displayName~\"${P} ${LAB_CORTO}\"" --format='value(name)'); do borrar gcloud monitoring dashboards delete "$n"; done
for n in $(gcloud beta monitoring channels list --filter="displayName~\"${P} ${LAB_CORTO}\"" --format='value(name)'); do borrar gcloud beta monitoring channels delete "$n" --force; done
borrar gcloud compute instances delete "${P}-${LAB_CORTO}-lamp" --zone "$ZONA"
borrar gcloud compute firewall-rules delete "${P}-${LAB_CORTO}-http"
fin_limpieza
