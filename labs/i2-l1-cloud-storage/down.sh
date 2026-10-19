#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/comun.sh"
banner "Limpieza · Insignia 2 · Lab 1"
borrar gcloud storage rm -r "gs://${PROJECT_ID}-${P}-i2l1"
fin_limpieza
