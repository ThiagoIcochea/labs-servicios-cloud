#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/comun.sh"
banner "Limpieza · Insignia 2 · Desafío"
borrar gcloud functions delete "${P}-i2l6-miniaturas-fn" --gen2 --region "$REGION"
borrar gcloud pubsub subscriptions delete "${P}-i2l6-verificacion"
borrar gcloud pubsub topics delete "${P}-i2l6-miniaturas"
borrar gcloud storage rm -r "gs://${PROJECT_ID}-${P}-i2l6-imagenes"
borrar gcloud iam service-accounts delete "${P}-ex-ingeniero@${PROJECT_ID}.iam.gserviceaccount.com"
fin_limpieza
