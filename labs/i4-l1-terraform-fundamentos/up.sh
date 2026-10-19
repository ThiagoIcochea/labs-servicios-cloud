#!/usr/bin/env bash
# Insignia 4 - Lab 1: Fundamentos de Terraform
source "$(dirname "$0")/../../lib/comun.sh"
source "$RAIZ/lib/terraform.sh"
banner "Insignia 4 · Lab 1 · Fundamentos de Terraform"
habilitar_apis compute.googleapis.com

paso "1) Versión de Terraform (se instala sola en ~/.local/bin si Cloud Shell no la trae)"
terraform version

paso "2) Archivos de configuración (main.tf, variables.tf, outputs.tf y terraform.tfvars con tus datos)"
preparar_tf "$(dirname "$0")/tf"
cat "$TF_DIR/terraform.tfvars"

paso "3) terraform init  (descarga el proveedor de Google)"
tf init -input=false

paso "4) terraform fmt y validate"
tf fmt
tf validate

paso "5) terraform plan"
tf plan -input=false -out plan.tfplan

paso "6) terraform apply"
tf apply -input=false plan.tfplan

paso "7) terraform show y outputs"
tf state list
tf show -no-color | head -40 || true
tf output
resumen_recursos
fin_lab
