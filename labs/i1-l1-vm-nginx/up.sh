#!/usr/bin/env bash
# Insignia 1 - Lab 1: Creando una máquina virtual (consola + gcloud) con NGINX
source "$(dirname "$0")/../../lib/comun.sh"
banner "Insignia 1 · Lab 1 · Creando una máquina virtual"
habilitar_apis compute.googleapis.com

VM1="${P}-i1l1-web"       # VM con NGINX y página personalizada
VM2="${P}-i1l1-gcelab2"   # VM creada solo con gcloud (segunda parte del lab)
TAG="${P}-i1l1-http"

paso "1) Regla de firewall que permite HTTP (puerto 80) hacia la etiqueta $TAG"
existe gcloud compute firewall-rules describe "$TAG" || \
  cmd gcloud compute firewall-rules create "$TAG" --network default \
    --allow tcp:80 --target-tags "$TAG" --source-ranges 0.0.0.0/0 \
    --description "Lab i1-l1 de $NOMBRE"

paso "2) Creando la VM $VM1 (e2-micro, Debian 12) con NGINX y la página de $NOMBRE"
startup_nginx "Insignia 1 · Lab 1 · Máquina virtual con NGINX" \
  "VM creada con gcloud desde Cloud Shell; NGINX instalado con startup-script" > "$TRABAJO/startup.sh"
existe gcloud compute instances describe "$VM1" --zone "$ZONA" || \
  cmd gcloud compute instances create "$VM1" --zone "$ZONA" --machine-type e2-micro \
    --image-family debian-12 --image-project debian-cloud --boot-disk-size 10GB \
    --tags "$TAG" --labels "$ETIQUETAS" \
    --metadata-from-file startup-script="$TRABAJO/startup.sh"

paso "3) Creando la segunda VM $VM2 solo con gcloud (como en la parte 2 del lab)"
existe gcloud compute instances describe "$VM2" --zone "$ZONA" || \
  cmd gcloud compute instances create "$VM2" --zone "$ZONA" --machine-type e2-micro \
    --image-family debian-12 --image-project debian-cloud --boot-disk-size 10GB \
    --labels "$ETIQUETAS"

resumen_recursos
IP="$(ip_externa_vm "$VM1")"
esperar_http "http://$IP" "$NOMBRE" 40
paso "Contenido servido por NGINX:"
curl -s "http://$IP" | sed -e 's/<[^>]*>/ /g' | tr -s ' ' | grep -E 'Alumno|Curso|Servidor' || true
echo
ok "Abre en el navegador:  http://$IP"
fin_lab
