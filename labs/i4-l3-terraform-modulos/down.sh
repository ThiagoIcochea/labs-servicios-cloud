#!/usr/bin/env bash
source "$(dirname "$0")/../../lib/comun.sh"
source "$RAIZ/lib/terraform.sh"
banner "Limpieza · Insignia 4 · Lab 3 (terraform destroy)"
[[ -d "$TF_DIR" ]] && tf destroy -auto-approve -input=false
fin_limpieza
