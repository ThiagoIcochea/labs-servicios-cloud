#!/usr/bin/env bash
# Insignia 3 - Lab 4: Monitoreo en la nube (Qwik Start) - variante con logs y métrica basada en logs
# Mismo objetivo que i2-l3 (Ops Agent + monitoreo), pero ahora con Apache, sus logs,
# una MÉTRICA BASADA EN LOGS y un dashboard distinto para que la evidencia no se repita.
source "$(dirname "$0")/../../lib/comun.sh"
banner "Insignia 3 · Lab 4 · Monitoreo: Ops Agent, logs de Apache y métricas"
habilitar_apis compute.googleapis.com monitoring.googleapis.com logging.googleapis.com
VM="${P}-i3l4-apache"; TAG="${P}-i3l4-http"
METRICA="${P}_i3l4_visitas"
NOMBRE_DASH="Dashboard ${P} i3l4 - Apache de ${NOMBRE}"

paso "1) VM con Apache + Ops Agent configurado para recolectar logs y métricas de Apache"
cat > "$TRABAJO/startup.sh" <<EOS
#!/bin/bash
apt-get update -y && apt-get install -y apache2
cat > /var/www/html/index.html <<HTML
<!doctype html><html lang="es"><head><meta charset="utf-8"><title>Apache monitoreado</title></head>
<body style="font-family:Arial;background:#e6f4ea;padding:40px"><h1 style="color:#188038">Apache monitoreado con Ops Agent</h1>
<p><b>Alumno:</b> ${NOMBRE}<br><b>Curso:</b> ${CURSO} - Sección ${SECCION}<br><b>Docente:</b> ${DOCENTE}<br>
<b>Lab:</b> Insignia 3 · Lab 4<br><b>Servidor:</b> \$(hostname)</p></body></html>
HTML
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
bash add-google-cloud-ops-agent-repo.sh --also-install
cat > /etc/google-cloud-ops-agent/config.yaml <<YAML
metrics:
  receivers:
    apache:
      type: apache
  service:
    pipelines:
      apache:
        receivers: [apache]
logging:
  receivers:
    apache_access:
      type: apache_access
    apache_error:
      type: apache_error
  service:
    pipelines:
      apache:
        receivers: [apache_access, apache_error]
YAML
systemctl restart google-cloud-ops-agent
EOS
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

paso "2) Métrica basada en logs: $METRICA (cuenta visitas con el user-agent del alumno)"
FILTRO="resource.type=\"gce_instance\" AND resource.labels.instance_id=\"$ID_VM\" AND log_id(\"apache_access\") AND jsonPayload.userAgent:\"Evidencia-$P\""
if ! existe gcloud logging metrics describe "$METRICA"; then
  cmd gcloud logging metrics create "$METRICA" --description "Visitas al Apache de $NOMBRE (lab i3-l4)" --log-filter "$FILTRO"
fi

paso "3) Generando 3 minutos de tráfico con el user-agent 'Evidencia-$P'"
sleep 60
for i in $(seq 1 180); do curl -s -o /dev/null -A "Evidencia-$P ($NOMBRE)" "http://$IP/?visita=$i"; sleep 1; done

paso "4) Leyendo los logs de acceso de Apache recolectados por el Ops Agent"
sleep 30
gcloud logging read "$FILTRO" --limit 5 --freshness 15m \
  --format='table(timestamp,jsonPayload.method,jsonPayload.requestUrl:label=URL,jsonPayload.status:label=ESTADO,jsonPayload.userAgent:label=USER_AGENT)' || true

paso "5) Dashboard: $NOMBRE_DASH"
cat > "$TRABAJO/dashboard.json" <<JSON
{
  "displayName": "$NOMBRE_DASH",
  "mosaicLayout": {"columns": 12, "tiles": [
    {"width": 12, "height": 2, "widget": {"title": "Alumno", "text": {"content": "**$NOMBRE** · $CURSO · Sección $SECCION · Insignia 3 Lab 4 · VM $VM", "format": "MARKDOWN"}}},
    {"yPos": 2, "width": 6, "height": 4, "widget": {"title": "Visitas (métrica basada en logs $METRICA)", "xyChart": {"dataSets": [{"timeSeriesQuery": {"timeSeriesFilter": {
      "filter": "metric.type=\"logging.googleapis.com/user/$METRICA\" resource.type=\"gce_instance\"",
      "aggregation": {"alignmentPeriod": "60s", "perSeriesAligner": "ALIGN_RATE", "crossSeriesReducer": "REDUCE_SUM"}}}, "plotType": "STACKED_BAR"}]}}},
    {"xPos": 6, "yPos": 2, "width": 6, "height": 4, "widget": {"title": "Peticiones Apache (Ops Agent)", "xyChart": {"dataSets": [{"timeSeriesQuery": {"timeSeriesFilter": {
      "filter": "metric.type=\"workload.googleapis.com/apache.requests\" resource.type=\"gce_instance\" resource.label.\"instance_id\"=\"$ID_VM\"",
      "aggregation": {"alignmentPeriod": "60s", "perSeriesAligner": "ALIGN_RATE", "crossSeriesReducer": "REDUCE_SUM"}}}, "plotType": "LINE"}]}}},
    {"yPos": 6, "width": 12, "height": 4, "widget": {"title": "Logs de acceso de Apache", "logsPanel": {"filter": "log_id(\"apache_access\") resource.labels.instance_id=\"$ID_VM\"", "resourceNames": ["projects/$PROJECT_ID"]}}}
  ]}
}
JSON
if [[ -z "$(gcloud monitoring dashboards list --filter="displayName=\"$NOMBRE_DASH\"" --format='value(name)')" ]]; then
  cmd gcloud monitoring dashboards create --config-from-file "$TRABAJO/dashboard.json"
fi
cmd gcloud logging metrics describe "$METRICA"
ok "Abre Monitoring → Paneles → '$NOMBRE_DASH'"
fin_lab
