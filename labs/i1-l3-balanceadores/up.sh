#!/usr/bin/env bash
# Insignia 1 - Lab 3: Configura balanceadores de carga de red y HTTP
source "$(dirname "$0")/../../lib/comun.sh"
banner "Insignia 1 · Lab 3 · Balanceadores de carga de red y HTTP"
habilitar_apis compute.googleapis.com
NUM_WWW="${NUM_WWW:-3}"   # VMs detrás del balanceador de red
TAM_MIG="${TAM_MIG:-2}"   # VMs del grupo administrado detrás del balanceador HTTP

# ---------------- Parte A: balanceador de carga de RED (L4) ----------------
paso "A1) Creando $NUM_WWW servidores web ${P}-www1..${P}-www${NUM_WWW}"
for i in $(seq 1 "$NUM_WWW"); do
  startup_nginx "Balanceador de RED · Servidor www$i" "Detrás del target pool ${P}-www-pool (balanceo de capa 4)" > "$TRABAJO/www$i.sh"
  existe gcloud compute instances describe "${P}-www$i" --zone "$ZONA" || \
    cmd gcloud compute instances create "${P}-www$i" --zone "$ZONA" --machine-type e2-micro \
      --image-family debian-12 --image-project debian-cloud --boot-disk-size 10GB \
      --tags "${P}-network-lb-tag" --labels "$ETIQUETAS" \
      --metadata-from-file startup-script="$TRABAJO/www$i.sh" --async
done
sleep 30

paso "A2) Firewall para HTTP hacia los servidores web"
existe gcloud compute firewall-rules describe "${P}-www-firewall-network-lb" || \
  cmd gcloud compute firewall-rules create "${P}-www-firewall-network-lb" --network default \
    --target-tags "${P}-network-lb-tag" --allow tcp:80 --source-ranges 0.0.0.0/0

paso "A3) IP externa estática, health check, target pool y regla de reenvío"
existe gcloud compute addresses describe "${P}-network-lb-ip-1" --region "$REGION" || \
  cmd gcloud compute addresses create "${P}-network-lb-ip-1" --region "$REGION"
existe gcloud compute http-health-checks describe "${P}-basic-check" || \
  cmd gcloud compute http-health-checks create "${P}-basic-check"
existe gcloud compute target-pools describe "${P}-www-pool" --region "$REGION" || \
  cmd gcloud compute target-pools create "${P}-www-pool" --region "$REGION" --http-health-check "${P}-basic-check"
INSTANCIAS="$(seq -s, -f "${P}-www%g" 1 "$NUM_WWW")"
cmd gcloud compute target-pools add-instances "${P}-www-pool" --instances "$INSTANCIAS" --instances-zone "$ZONA" || true
existe gcloud compute forwarding-rules describe "${P}-www-rule" --region "$REGION" || \
  cmd gcloud compute forwarding-rules create "${P}-www-rule" --region "$REGION" --ports 80 \
    --address "${P}-network-lb-ip-1" --target-pool "${P}-www-pool"
IP_RED="$(gcloud compute forwarding-rules describe "${P}-www-rule" --region "$REGION" --format='value(IPAddress)')"

# ---------------- Parte B: balanceador de carga HTTP (L7) -------------------
paso "B1) Plantilla de instancias y grupo administrado (MIG) de $TAM_MIG VMs"
startup_nginx "Balanceador HTTP · Backend del MIG" "Grupo administrado ${P}-lb-backend-group detrás de ${P}-web-map-http (capa 7)" > "$TRABAJO/backend.sh"
existe gcloud compute instance-templates describe "${P}-lb-backend-template" || \
  cmd gcloud compute instance-templates create "${P}-lb-backend-template" \
    --network default --tags "${P}-allow-health-check" --machine-type e2-micro \
    --image-family debian-12 --image-project debian-cloud --boot-disk-size 10GB \
    --labels "$ETIQUETAS" --metadata-from-file startup-script="$TRABAJO/backend.sh"
existe gcloud compute instance-groups managed describe "${P}-lb-backend-group" --zone "$ZONA" || \
  cmd gcloud compute instance-groups managed create "${P}-lb-backend-group" \
    --template "${P}-lb-backend-template" --size "$TAM_MIG" --zone "$ZONA"
cmd gcloud compute instance-groups managed set-named-ports "${P}-lb-backend-group" --named-ports http:80 --zone "$ZONA"

paso "B2) Firewall para los health checks de Google (130.211.0.0/22 y 35.191.0.0/16)"
existe gcloud compute firewall-rules describe "${P}-fw-allow-health-check" || \
  cmd gcloud compute firewall-rules create "${P}-fw-allow-health-check" --network default \
    --action allow --direction ingress --source-ranges 130.211.0.0/22,35.191.0.0/16 \
    --target-tags "${P}-allow-health-check" --rules tcp:80

paso "B3) IP global, health check, servicio de backend, URL map, proxy y regla de reenvío"
existe gcloud compute addresses describe "${P}-lb-ipv4-1" --global || \
  cmd gcloud compute addresses create "${P}-lb-ipv4-1" --ip-version IPV4 --global
existe gcloud compute health-checks describe "${P}-http-basic-check" || \
  cmd gcloud compute health-checks create http "${P}-http-basic-check" --port 80
existe gcloud compute backend-services describe "${P}-web-backend-service" --global || \
  cmd gcloud compute backend-services create "${P}-web-backend-service" --protocol HTTP \
    --port-name http --health-checks "${P}-http-basic-check" --global
cmd gcloud compute backend-services add-backend "${P}-web-backend-service" \
  --instance-group "${P}-lb-backend-group" --instance-group-zone "$ZONA" --global || true
existe gcloud compute url-maps describe "${P}-web-map-http" || \
  cmd gcloud compute url-maps create "${P}-web-map-http" --default-service "${P}-web-backend-service"
existe gcloud compute target-http-proxies describe "${P}-http-lb-proxy" || \
  cmd gcloud compute target-http-proxies create "${P}-http-lb-proxy" --url-map "${P}-web-map-http"
existe gcloud compute forwarding-rules describe "${P}-http-content-rule" --global || \
  cmd gcloud compute forwarding-rules create "${P}-http-content-rule" --address "${P}-lb-ipv4-1" \
    --global --target-http-proxy "${P}-http-lb-proxy" --ports 80
IP_HTTP="$(gcloud compute addresses describe "${P}-lb-ipv4-1" --global --format='value(address)')"

resumen_recursos
esperar_http "http://$IP_RED" "$NOMBRE" 30
paso "Probando el balanceador de RED ($IP_RED): las respuestas deben alternar entre servidores"
for i in $(seq 1 6); do curl -s -m 5 "http://$IP_RED" | grep -o 'Servidor www[0-9]*' | head -1 || true; done

esperar_http "http://$IP_HTTP" "$NOMBRE" 60
paso "Probando el balanceador HTTP ($IP_HTTP): respuestas de las VMs del MIG"
for i in $(seq 1 6); do curl -s -m 5 "http://$IP_HTTP" | sed -e 's/<[^>]*>/ /g' | grep -o 'Servidor *[^ ]* *([^)]*)' | head -1 || true; done
echo
ok "Balanceador de red : http://$IP_RED"
ok "Balanceador HTTP   : http://$IP_HTTP"
fin_lab
