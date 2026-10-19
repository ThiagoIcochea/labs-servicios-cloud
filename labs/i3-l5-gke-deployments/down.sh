#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/comun.sh"
banner "Limpieza · Insignia 3 · Lab 5"
CL="${P}-i3l5-gke"
if gcloud container clusters describe "$CL" --zone "$ZONA" >/dev/null 2>&1; then
  gcloud container clusters get-credentials "$CL" --zone "$ZONA"
  # Borrar primero los Services LoadBalancer para que no queden balanceadores huérfanos
  kubectl delete svc web web-bg --ignore-not-found --wait=true || true
  sleep 30
fi
borrar gcloud container clusters delete "$CL" --zone "$ZONA"
fin_limpieza
