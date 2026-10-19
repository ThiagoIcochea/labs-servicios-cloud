#!/usr/bin/env bash
# Insignia 1 - Lab de desafío: Implement Load Balancing on Compute Engine
source "$(dirname "$0")/../../lib/comun.sh"
banner "Insignia 1 · DESAFÍO · Implement Load Balancing on Compute Engine"
habilitar_apis compute.googleapis.com
JUMP="${P}-jumphost"
PLANT="${P}-desafio-template"; MIG="${P}-desafio-mig"; TAG="${P}-desafio-web"
MIN="${MIN_MIG:-2}"; MAX="${MAX_MIG:-3}"

paso "Tarea 1) VM de salto (jumphost) para administrar el entorno"
existe gcloud compute instances describe "$JUMP" --zone "$ZONA" || \
  cmd gcloud compute instances create "$JUMP" --zone "$ZONA" --machine-type e2-micro \
    --image-family debian-12 --image-project debian-cloud --boot-disk-size 10GB --labels "$ETIQUETAS"

paso "Tarea 2) Plantilla de instancias con NGINX personalizado"
startup_nginx "DESAFÍO · Insignia Implement Load Balancing on Compute Engine" \
  "Backend del MIG autoescalable ${MIG} (mín ${MIN}, máx ${MAX}) detrás del balanceador HTTP ${P}-desafio-lb" > "$TRABAJO/web.sh"
existe gcloud compute instance-templates describe "$PLANT" || \
  cmd gcloud compute instance-templates create "$PLANT" --network default --tags "$TAG" \
    --machine-type e2-micro --image-family debian-12 --image-project debian-cloud \
    --boot-disk-size 10GB --labels "$ETIQUETAS" --metadata-from-file startup-script="$TRABAJO/web.sh"

paso "Tarea 3) Grupo de instancias administrado con autoescalado"
existe gcloud compute instance-groups managed describe "$MIG" --zone "$ZONA" || \
  cmd gcloud compute instance-groups managed create "$MIG" --template "$PLANT" --size "$MIN" --zone "$ZONA"
cmd gcloud compute instance-groups managed set-named-ports "$MIG" --named-ports http:80 --zone "$ZONA"
cmd gcloud compute instance-groups managed set-autoscaling "$MIG" --zone "$ZONA" \
  --min-num-replicas "$MIN" --max-num-replicas "$MAX" --target-cpu-utilization 0.6 --cool-down-period 60

paso "Tarea 4) Regla de firewall permit-tcp-rule (puerto 80) para tráfico y health checks"
existe gcloud compute firewall-rules describe "${P}-permit-tcp-rule-80" || \
  cmd gcloud compute firewall-rules create "${P}-permit-tcp-rule-80" --network default --allow tcp:80 \
    --source-ranges 0.0.0.0/0 --target-tags "$TAG"

paso "Tarea 5) Health check, backend, URL map, proxy y regla de reenvío global"
existe gcloud compute health-checks describe "${P}-desafio-hc" || \
  cmd gcloud compute health-checks create http "${P}-desafio-hc" --port 80
existe gcloud compute backend-services describe "${P}-desafio-backend" --global || \
  cmd gcloud compute backend-services create "${P}-desafio-backend" --protocol HTTP --port-name http \
    --health-checks "${P}-desafio-hc" --global
cmd gcloud compute backend-services add-backend "${P}-desafio-backend" --instance-group "$MIG" \
  --instance-group-zone "$ZONA" --global || true
existe gcloud compute url-maps describe "${P}-desafio-lb" || \
  cmd gcloud compute url-maps create "${P}-desafio-lb" --default-service "${P}-desafio-backend"
existe gcloud compute target-http-proxies describe "${P}-desafio-proxy" || \
  cmd gcloud compute target-http-proxies create "${P}-desafio-proxy" --url-map "${P}-desafio-lb"
existe gcloud compute forwarding-rules describe "${P}-desafio-fr" --global || \
  cmd gcloud compute forwarding-rules create "${P}-desafio-fr" --global --target-http-proxy "${P}-desafio-proxy" --ports 80
IP="$(gcloud compute forwarding-rules describe "${P}-desafio-fr" --global --format='value(IPAddress)')"

resumen_recursos
paso "Tarea 6) Desde el jumphost, probando los backends por IP interna"
sleep 30
for ipi in $(gcloud compute instances list --filter="name~^${MIG}" --format='value(networkInterfaces[0].networkIP)'); do
  gcloud compute ssh "$JUMP" --zone "$ZONA" --quiet --strict-host-key-checking=no \
    --command "echo -n 'Backend $ipi -> '; curl -s -m 5 http://$ipi | grep -o 'Alumno</td><td>[^<]*' | sed 's/<[^>]*>/ /g'" || true
done
esperar_http "http://$IP" "$NOMBRE" 60
paso "Respuestas del balanceador HTTP"
for i in $(seq 1 6); do curl -s -m 5 "http://$IP" | sed -e 's/<[^>]*>/ /g' | grep -o 'Servidor *[^ ]* *([^)]*)' | head -1 || true; done
ok "Balanceador del desafío: http://$IP"
fin_lab
