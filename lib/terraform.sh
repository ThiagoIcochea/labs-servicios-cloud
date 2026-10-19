#!/usr/bin/env bash
# Funciones para los labs de Terraform (se carga después de comun.sh)
TF_DIR="$TRABAJO/tf"
preparar_tf() { # copia la plantilla del lab a la carpeta de trabajo del alumno
  mkdir -p "$TF_DIR"
  cp -r "$1"/. "$TF_DIR"/
  cat > "$TF_DIR/terraform.tfvars" <<EOF2
project_id = "$PROJECT_ID"
region     = "$REGION"
zona       = "$ZONA"
prefijo    = "$P"
nombre     = "$NOMBRE"
codigo     = "$CODIGO"
seccion    = "$SECCION"
EOF2
  echo "Carpeta de Terraform: $TF_DIR"
}
tf() { echo -e "\033[1;36m\$ terraform $*\033[0m"; terraform -chdir="$TF_DIR" "$@"; }
