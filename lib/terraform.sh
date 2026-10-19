#!/usr/bin/env bash
# Funciones para los labs de Terraform (se carga después de comun.sh)
TF_DIR="$TRABAJO/tf"
TF_VERSION="${TF_VERSION:-1.9.8}"
# Cloud Shell ya no trae Terraform preinstalado: si falta, se descarga el binario oficial
# de HashiCorp en ~/.local/bin (queda guardado en el $HOME de Cloud Shell para los demás labs).
asegurar_terraform() {
  export PATH="$HOME/.local/bin:$PATH"
  if ! terraform version 2>/dev/null | grep -q "^Terraform v"; then  # Cloud Shell trae un "terraform" que solo muestra instrucciones
    echo "Instalando Terraform $TF_VERSION en ~/.local/bin…"
    mkdir -p "$HOME/.local/bin"
    local zip; zip="$(mktemp -d)/tf.zip"
    curl -fsSL -o "$zip" "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip"
    unzip -o -q "$zip" -d "$HOME/.local/bin"
    chmod +x "$HOME/.local/bin/terraform"
  fi
}
asegurar_terraform
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
