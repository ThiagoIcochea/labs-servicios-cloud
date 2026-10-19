#!/usr/bin/env bash
# Insignia 2 - Lab 3: Cloud Monitoring: Qwik Start
source "$(dirname "$0")/../../lib/comun.sh"
banner "Insignia 2 · Lab 3 · Cloud Monitoring"
habilitar_apis compute.googleapis.com monitoring.googleapis.com logging.googleapis.com
VM="${P}-i2l3-lamp"; TAG="${P}-i2l3-http"
NOMBRE_UPTIME="Uptime ${P} i2l3 - ${NOMBRE}"
NOMBRE_ALERTA="Alerta trafico ${P} i2l3 - ${NOMBRE}"
NOMBRE_CANAL="Correo ${P} i2l3 - ${NOMBRE}"
NOMBRE_DASH="Dashboard ${P} i2l3 - ${NOMBRE} (Seccion ${SECCION})"

paso "1) VM con Apache y el Agente de operaciones (Ops Agent)"
startup_nginx "Insignia 2 · Lab 3 · Cloud Monitoring" "VM monitoreada con Ops Agent, uptime check, alerta y dashboard" > "$TRABAJO/startup.sh"
cat >> "$TRABAJO/startup.sh" <<'AGENTE'
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
bash add-google-cloud-ops-agent-repo.sh --also-install
AGENTE
existe gcloud compute firewall-rules describe "$TAG" || \
  cmd gcloud compute firewall-rules create "$TAG" --network default --allow tcp:80 --target-tags "$TAG" --source-ranges 0.0.0.0/0
existe gcloud compute instances describe "$VM" --zone "$ZONA" || \
  cmd gcloud compute instances create "$VM" --zone "$ZONA" --machine-type e2-small \
    --image-family debian-12 --image-project debian-cloud --boot-disk-size 10GB \
    --tags "$TAG" --labels "$ETIQUETAS" --scopes cloud-platform \
    --metadata-from-file startup-script="$TRABAJO/startup.sh"
IP="$(ip_externa_vm "$VM")"
ID_VM="$(gcloud compute instances describe "$VM" --zone "$ZONA" --format='value(id)')"
esperar_http "http://$IP" "$NOMBRE" 40

paso "2) Verificando que el Ops Agent esté corriendo dentro de la VM"
sleep 30
gcloud compute ssh "$VM" --zone "$ZONA" --quiet --strict-host-key-checking=no \
  --command "sudo systemctl is-active google-cloud-ops-agent && sudo systemctl status google-cloud-ops-agent --no-pager | head -5" || true

paso "3) Uptime check: $NOMBRE_UPTIME"
if [[ -z "$(gcloud monitoring uptime list-configs --filter="displayName=\"$NOMBRE_UPTIME\"" --format='value(name)')" ]]; then
  cmd gcloud monitoring uptime create "$NOMBRE_UPTIME" --resource-type uptime-url \
    --resource-labels "host=$IP,project_id=$PROJECT_ID" --protocol http --path / --period 1 --timeout 10
fi

paso "4) Canal de notificación por correo ($CORREO)"
CANAL="$(gcloud beta monitoring channels list --filter="displayName=\"$NOMBRE_CANAL\"" --format='value(name)' | head -1 || true)"
if [[ -z "$CANAL" ]]; then
  CANAL="$(gcloud beta monitoring channels create --display-name "$NOMBRE_CANAL" --type email \
    --channel-labels "email_address=$CORREO" --format='value(name)')"
fi
echo "Canal: $CANAL"

paso "5) Política de alerta: tráfico de red de la VM > 500 bytes/s durante 1 minuto"
cat > "$TRABAJO/alerta.json" <<JSON
{
  "displayName": "$NOMBRE_ALERTA",
  "documentation": {"content": "Alerta creada por $MARCA - $CURSO, sección $SECCION. Lab i2-l3.", "mimeType": "text/markdown"},
  "combiner": "OR",
  "conditions": [{
    "displayName": "Trafico de red de $VM",
    "conditionThreshold": {
      "filter": "resource.type = \"gce_instance\" AND resource.labels.instance_id = \"$ID_VM\" AND metric.type = \"agent.googleapis.com/interface/traffic\"",
      "aggregations": [{"alignmentPeriod": "60s", "perSeriesAligner": "ALIGN_RATE"}],
      "comparison": "COMPARISON_GT", "thresholdValue": 500, "duration": "60s",
      "trigger": {"count": 1}
    }
  }],
  "notificationChannels": ["$CANAL"],
  "userLabels": {"alumno": "$P", "seccion": "$SECCION", "lab": "$LAB_CORTO"}
}
JSON
if [[ -z "$(gcloud alpha monitoring policies list --filter="displayName=\"$NOMBRE_ALERTA\"" --format='value(name)')" ]]; then
  cmd gcloud alpha monitoring policies create --policy-from-file "$TRABAJO/alerta.json"
fi

paso "6) Dashboard del alumno: $NOMBRE_DASH"
cat > "$TRABAJO/dashboard.json" <<JSON
{
  "displayName": "$NOMBRE_DASH",
  "mosaicLayout": {"columns": 12, "tiles": [
    {"width": 12, "height": 2, "widget": {"title": "Datos del alumno", "text": {"content": "**$NOMBRE** · Código $CODIGO · $CURSO · Sección $SECCION · Docente: $DOCENTE · VM: $VM", "format": "MARKDOWN"}}},
    {"yPos": 2, "width": 6, "height": 4, "widget": {"title": "CPU de $VM (Ops Agent)", "xyChart": {"dataSets": [{"timeSeriesQuery": {"timeSeriesFilter": {
      "filter": "metric.type=\"agent.googleapis.com/cpu/utilization\" resource.type=\"gce_instance\" resource.label.\"instance_id\"=\"$ID_VM\"",
      "aggregation": {"alignmentPeriod": "60s", "perSeriesAligner": "ALIGN_MEAN", "crossSeriesReducer": "REDUCE_MEAN"}}}, "plotType": "LINE"}]}}},
    {"xPos": 6, "yPos": 2, "width": 6, "height": 4, "widget": {"title": "Tráfico de red de $VM", "xyChart": {"dataSets": [{"timeSeriesQuery": {"timeSeriesFilter": {
      "filter": "metric.type=\"agent.googleapis.com/interface/traffic\" resource.type=\"gce_instance\" resource.label.\"instance_id\"=\"$ID_VM\"",
      "aggregation": {"alignmentPeriod": "60s", "perSeriesAligner": "ALIGN_RATE", "crossSeriesReducer": "REDUCE_SUM"}}}, "plotType": "LINE"}]}}}
  ]}
}
JSON
if [[ -z "$(gcloud monitoring dashboards list --filter="displayName=\"$NOMBRE_DASH\"" --format='value(name)')" ]]; then
  cmd gcloud monitoring dashboards create --config-from-file "$TRABAJO/dashboard.json"
fi

paso "7) Generando tráfico para que la alerta se dispare (2 minutos)"
for i in $(seq 1 120); do curl -s -o /dev/null "http://$IP/?alumno=${P}&i=$i"; curl -s -o /dev/null "http://$IP/"; sleep 1; done
ok "Tráfico generado. En unos minutos llegará el correo de alerta a $CORREO"

paso "Recursos de monitoreo creados"
gcloud monitoring uptime list-configs --filter="displayName~\"$P\"" --format='table(displayName,monitoredResource.labels.host,period)' || true
gcloud alpha monitoring policies list --filter="displayName~\"$P\"" --format='table(displayName,enabled)' || true
gcloud monitoring dashboards list --filter="displayName~\"$P\"" --format='table(displayName)' || true
fin_lab
