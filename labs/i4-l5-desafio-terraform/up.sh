#!/usr/bin/env bash
# Insignia 4 - Lab de desafío: Build Infrastructure with Terraform on Google Cloud
source "$(dirname "$0")/../../lib/comun.sh"
source "$RAIZ/lib/terraform.sh"
banner "Insignia 4 · DESAFÍO · Build Infrastructure with Terraform"
habilitar_apis compute.googleapis.com storage.googleapis.com
preparar_tf "$(dirname "$0")/tf"
rm -f "$TF_DIR/backend.tf"

paso "Tarea 0) Infraestructura existente creada A MANO (fuera de Terraform)"
for i in 1 2; do
  existe gcloud compute instances describe "${P}-tf-instance-$i" --zone "$ZONA" || \
    cmd gcloud compute instances create "${P}-tf-instance-$i" --zone "$ZONA" --machine-type e2-micro \
      --image-family debian-12 --image-project debian-cloud --boot-disk-size 10GB \
      --labels "alumno=${P},seccion=${SECCION},curso=servicios-cloud,lab=i4l5" --metadata alumno="$NOMBRE"
done
(cd "$TF_DIR" && find . -name '*.tf' | sort)

paso "Tareas 1-3) Módulos instances y storage + IMPORTAR las 2 VMs + crear el bucket del backend"
tf init -input=false
tf plan -input=false -var etapa=1 | grep -E 'will be imported|will be created|Plan:' || true
tf apply -input=false -auto-approve -var etapa=1
BUCKET="$(terraform -chdir="$TF_DIR" output -raw bucket)"

paso "Tarea 4) Backend remoto en gs://$BUCKET"
cat > "$TF_DIR/backend.tf" <<TF
terraform {
  backend "gcs" {
    bucket = "$BUCKET"
    prefix = "terraform/state"
  }
}
TF
tf init -input=false -migrate-state -force-copy
cmd gcloud storage ls -r "gs://$BUCKET"

paso "Tarea 5) Modificar: tipo de máquina e2-micro → e2-small y agregar ${P}-tf-instance-3"
tf apply -input=false -auto-approve -var etapa=3
tf output instancias

paso "Tarea 6) Retirar ${P}-tf-instance-3 (como un taint/destroy), crear la VPC ${P}-tf-vpc y mover las VMs a sus subredes"
tf apply -input=false -auto-approve -var etapa=4

paso "Tarea 7) Firewall ${P}-tf-firewall creado. Estado final:"
tf state list
tf output
gcloud compute instances list --filter="labels.alumno=$P AND labels.lab=i4l5" \
  --format='table(name,machineType.basename(),networkInterfaces[0].network.basename():label=RED,networkInterfaces[0].subnetwork.basename():label=SUBRED,status)'
gcloud compute firewall-rules list --filter="name=${P}-tf-firewall" --format='table(name,network.basename(),sourceRanges.list(),allowed[].map().firewall_rule().list())'
fin_lab
