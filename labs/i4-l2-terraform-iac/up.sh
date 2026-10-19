#!/usr/bin/env bash
# Insignia 4 - Lab 2: Infraestructura como código con Terraform
source "$(dirname "$0")/../../lib/comun.sh"
source "$RAIZ/lib/terraform.sh"
banner "Insignia 4 · Lab 2 · Infraestructura como código con Terraform"
habilitar_apis compute.googleapis.com storage.googleapis.com
preparar_tf "$(dirname "$0")/tf"
tf init -input=false

paso "ETAPA 1 · CONSTRUIR: red, IP estática, bucket y VM (dependencias implícitas y explícitas)"
tf apply -input=false -auto-approve -var etapa=1
tf output

paso "Gráfico de dependencias (terraform graph)"
tf graph | grep -E -- '->' | grep -v 'provider' | sed 's/\[root\] //g' | head -20 || true

paso "ETAPA 2 · CAMBIAR en el lugar: se agrega la etiqueta de red '${P}-dev' y cambia un metadato"
tf plan -input=false -var etapa=2 | grep -E 'update in-place|~ |Plan:' || true
tf apply -input=false -auto-approve -var etapa=2

paso "ETAPA 3 · CAMBIO DESTRUCTIVO: la imagen pasa de Debian 12 a Ubuntu 22.04 (forces replacement)"
tf plan -input=false -var etapa=3 | grep -E 'forces replacement|must be replaced|Plan:' || true
tf apply -input=false -auto-approve -var etapa=3

paso "Estado final"
tf state list
tf output
resumen_recursos
aviso "La etapa DESTRUIR se hace con:  ./lab $ALUMNO $LAB_ID down   (terraform destroy)"
fin_lab
