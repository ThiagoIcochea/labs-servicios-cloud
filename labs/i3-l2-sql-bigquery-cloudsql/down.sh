#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/comun.sh"
banner "Limpieza · Insignia 3 · Lab 2"
borrar gcloud sql instances delete "${P}-i3l2-mysql"
bq rm -r -f -d "$PROJECT_ID:${P}_i3l2_bicis" || true
borrar gcloud storage rm -r "gs://${PROJECT_ID}-${P}-i3l2"
rm -f "$TRABAJO/.clave-root"
fin_limpieza
