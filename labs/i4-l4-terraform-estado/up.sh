#!/usr/bin/env bash
# Insignia 4 - Lab 4: Administración del estado de Terraform
source "$(dirname "$0")/../../lib/comun.sh"
source "$RAIZ/lib/terraform.sh"
banner "Insignia 4 · Lab 4 · Estado de Terraform (local, remoto e importación)"
habilitar_apis compute.googleapis.com storage.googleapis.com
VM_EXT="${P}-i4l4-importada"
preparar_tf "$(dirname "$0")/tf"
rm -f "$TF_DIR/backend.tf" "$TF_DIR/importada.tf" "$TF_DIR/generado.tf"

paso "1) ESTADO LOCAL: crear el bucket del estado con backend local"
tf init -input=false
tf apply -input=false -auto-approve
ls -l "$TF_DIR"/terraform.tfstate
BUCKET="$(terraform -chdir="$TF_DIR" output -raw bucket_estado)"

paso "2) ESTADO REMOTO: agregar backend 'gcs' y migrar el estado al bucket $BUCKET"
cat > "$TF_DIR/backend.tf" <<TF
terraform {
  backend "gcs" {
    bucket = "$BUCKET"
    prefix = "terraform/estado/${P}"
  }
}
TF
cat "$TF_DIR/backend.tf"
tf init -input=false -migrate-state -force-copy
cmd gcloud storage ls -r "gs://$BUCKET"
tf state list

paso "3) Cambio fuera de Terraform y terraform refresh (el estado detecta la nueva etiqueta)"
cmd gcloud storage buckets update "gs://$BUCKET" --update-labels "modificado=fuera-de-terraform"
tf apply -refresh-only -input=false -auto-approve | grep -E 'modificado|Apply complete|No changes' || true

paso "4) IMPORTAR infraestructura existente: VM creada con gcloud → bajo control de Terraform"
existe gcloud compute instances describe "$VM_EXT" --zone "$ZONA" || \
  cmd gcloud compute instances create "$VM_EXT" --zone "$ZONA" --machine-type e2-micro \
    --image-family debian-12 --image-project debian-cloud --boot-disk-size 10GB --labels "$ETIQUETAS"
cat > "$TF_DIR/importada.tf" <<TF
import {
  to = google_compute_instance.importada
  id = "projects/$PROJECT_ID/zones/$ZONA/instances/$VM_EXT"
}
TF
cat "$TF_DIR/importada.tf"
paso "terraform plan -generate-config-out: Terraform escribe el código de la VM importada"
tf plan -input=false -generate-config-out=generado.tf | tail -5 || true
head -30 "$TF_DIR/generado.tf" || true
if ! tf apply -input=false -auto-approve; then
  aviso "El código generado tuvo conflictos; se usa una definición escrita a mano para importar la VM"
  cat > "$TF_DIR/generado.tf" <<TF
resource "google_compute_instance" "importada" {
  name         = "$VM_EXT"
  zone         = "$ZONA"
  machine_type = "e2-micro"
  boot_disk {
    initialize_params { image = "debian-cloud/debian-12" }
  }
  network_interface {
    network = "default"
    access_config {}
  }
  lifecycle { ignore_changes = all }
}
TF
  tf apply -input=false -auto-approve
fi
tf state list
tf state show google_compute_instance.importada | grep -E 'name|machine_type|zone|labels' | head -12 || true

paso "5) Estado guardado en el bucket (versión remota)"
gcloud storage cat "gs://$BUCKET/terraform/estado/${P}/default.tfstate" | grep -E '"(terraform_version|serial|type|name)"' | head -12 || true
fin_lab
