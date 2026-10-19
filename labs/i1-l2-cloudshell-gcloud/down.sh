#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/comun.sh"
banner "Limpieza · Insignia 1 · Lab 2"
borrar gcloud compute instances delete "${P}-i1l2-gcelab2" --zone "$ZONA"
rm -f "$HOME/evidencia-${LAB_CORTO}-${P}.txt"
fin_limpieza
