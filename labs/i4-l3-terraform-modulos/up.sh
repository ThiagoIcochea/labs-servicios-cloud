#!/usr/bin/env bash
# Insignia 4 - Lab 3: Interactuar con los módulos de Terraform
source "$(dirname "$0")/../../lib/comun.sh"
source "$RAIZ/lib/terraform.sh"
banner "Insignia 4 · Lab 3 · Módulos de Terraform"
habilitar_apis compute.googleapis.com storage.googleapis.com
preparar_tf "$(dirname "$0")/tf"

paso "Estructura del proyecto Terraform (módulo raíz + módulo propio)"
(cd "$TF_DIR" && find . -name '*.tf' | sort)

paso "1) terraform init: descarga el módulo público terraform-google-modules/network"
tf init -input=false
paso "2) Plan y apply"
tf plan -input=false | grep -E '^  # |Plan:' || true
tf apply -input=false -auto-approve
paso "3) Salidas de los módulos"
tf output
tf state list
URL="$(terraform -chdir="$TF_DIR" output -raw sitio_web_url)"
esperar_http "$URL" "$NOMBRE" 6
ok "Sitio web del módulo: $URL"
fin_lab
