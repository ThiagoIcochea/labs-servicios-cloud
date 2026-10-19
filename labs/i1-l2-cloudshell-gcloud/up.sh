#!/usr/bin/env bash
# Insignia 1 - Lab 2: Cómo comenzar a utilizar Cloud Shell y gcloud
source "$(dirname "$0")/../../lib/comun.sh"
banner "Insignia 1 · Lab 2 · Cloud Shell y gcloud"
habilitar_apis compute.googleapis.com
VM="${P}-i1l2-gcelab2"

paso "1) Cuenta activa y configuración de gcloud"
cmd gcloud auth list
cmd gcloud config list

paso "2) Configurando región y zona por defecto"
cmd gcloud config set compute/region "$REGION"
cmd gcloud config set compute/zone "$ZONA"
cmd gcloud config get-value compute/region
cmd gcloud config get-value compute/zone

paso "3) Información del proyecto (metadatos comunes y zona por defecto)"
gcloud compute project-info describe --project "$PROJECT_ID" \
  --format='yaml(name,commonInstanceMetadata.items,defaultServiceAccount)'

paso "4) Variables de entorno como en el lab"
export PROJECT_ID ZONE="$ZONA" REGION
echo "PROJECT_ID=$PROJECT_ID  ZONE=$ZONE  REGION=$REGION  ALUMNO=$NOMBRE"

paso "5) Creando la VM $VM con gcloud"
existe gcloud compute instances describe "$VM" --zone "$ZONA" || \
  cmd gcloud compute instances create "$VM" --zone "$ZONA" --machine-type e2-micro \
    --image-family debian-12 --image-project debian-cloud --boot-disk-size 10GB \
    --labels "$ETIQUETAS" --metadata alumno="$NOMBRE",seccion="$SECCION"

paso "6) Listando y filtrando instancias"
cmd gcloud compute instances list --filter="name=('$VM')"
cmd gcloud compute instances list --filter="labels.alumno=$P" --format='table(name,zone.basename(),status,labels.lab)'
cmd gcloud compute firewall-rules list --filter="network~default" --format='table(name,network.basename(),direction,sourceRanges.list(),allowed[].map().firewall_rule().list())'

paso "7) Conectándose por SSH a la VM y ejecutando comandos dentro de ella"
sleep 20
gcloud compute ssh "$VM" --zone "$ZONA" --quiet --strict-host-key-checking=no --command "
  echo '------------------------------------------------------------'
  echo 'Hola desde la VM' \$(hostname) 'en' \$(curl -s -H Metadata-Flavor:Google http://metadata.google.internal/computeMetadata/v1/instance/zone | awk -F/ '{print \$NF}')
  echo 'Alumno (metadato de la VM):' \$(curl -s -H Metadata-Flavor:Google http://metadata.google.internal/computeMetadata/v1/instance/attributes/alumno)
  echo 'Sección:' \$(curl -s -H Metadata-Flavor:Google http://metadata.google.internal/computeMetadata/v1/instance/attributes/seccion)
  uname -a; uptime
  echo '------------------------------------------------------------'
"

paso "8) Archivo de evidencia en el directorio home de Cloud Shell"
texto_evidencia "$HOME/evidencia-${LAB_CORTO}-${P}.txt" "Insignia 1 · Lab 2 · Cloud Shell y gcloud"
cmd cat "$HOME/evidencia-${LAB_CORTO}-${P}.txt"

paso "9) Lectura de logs de la VM con gcloud logging"
gcloud logging read "resource.type=gce_instance AND protoPayload.resourceName:\"$VM\"" \
  --limit 3 --format='table(timestamp,protoPayload.methodName,protoPayload.authenticationInfo.principalEmail)' || true
fin_lab
