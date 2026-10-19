#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/comun.sh"
banner "Limpieza · Insignia 2 · Lab 5"
borrar gcloud pubsub subscriptions delete "${P}-i2l5-suscripcion"
borrar gcloud pubsub topics delete "${P}-i2l5-topico"
borrar gcloud pubsub topics delete "${P}-i2l5-temporal"
fin_limpieza
