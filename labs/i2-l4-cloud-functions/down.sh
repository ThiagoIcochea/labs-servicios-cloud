#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/comun.sh"
banner "Limpieza · Insignia 2 · Lab 4"
borrar gcloud functions delete "${P}-i2l4-hola" --gen2 --region "$REGION"
fin_limpieza
