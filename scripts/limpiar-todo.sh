#!/usr/bin/env bash
# Limpieza de emergencia: busca y borra TODO lo que tenga el prefijo/etiqueta
# de un alumno (o de todos). Úsalo si un lab quedó a medias.
# Uso: bash scripts/limpiar-todo.sh <prefijo|todos>      ej.: ticochea
set -uo pipefail
OBJ="${1:?Indica el prefijo del alumno (ej. ticochea) o 'todos'}"
PROJECT_ID="$(gcloud config get-value project 2>/dev/null)"
if [[ "$OBJ" == "todos" ]]; then FILTRO_ETQ="labels.curso=servicios-cloud"; PATRON=".*"
else FILTRO_ETQ="labels.alumno=$OBJ"; PATRON="^$OBJ"; fi
echo "Proyecto: $PROJECT_ID   Objetivo: $OBJ"
q() { "$@" --quiet 2>/dev/null || true; }

echo "== Clústeres GKE"
gcloud container clusters list --format='value(name,location)' | grep -E "$PATRON" | while read -r n l; do q gcloud container clusters delete "$n" --location "$l" --async; done
echo "== Cloud SQL"
gcloud sql instances list --format='value(name)' | grep -E "$PATRON" | while read -r n; do q gcloud sql instances delete "$n"; done
echo "== Cloud Functions"
gcloud functions list --format='value(name,region)' 2>/dev/null | grep -E "${PATRON#^}" | while read -r n r; do q gcloud functions delete "${n##*/}" --region "${r:-us-central1}" --gen2; done
echo "== Balanceadores (reglas, proxies, url maps, backends)"
gcloud compute forwarding-rules list --format='value(name,region.basename())' | grep -E "$PATRON" | while read -r n r; do if [[ -n "$r" ]]; then q gcloud compute forwarding-rules delete "$n" --region "$r"; else q gcloud compute forwarding-rules delete "$n" --global; fi; done
gcloud compute target-http-proxies list --format='value(name)' | grep -E "$PATRON" | while read -r n; do q gcloud compute target-http-proxies delete "$n" --global; done
gcloud compute url-maps list --format='value(name)' | grep -E "$PATRON" | while read -r n; do q gcloud compute url-maps delete "$n" --global; done
gcloud compute backend-services list --format='value(name)' | grep -E "$PATRON" | while read -r n; do q gcloud compute backend-services delete "$n" --global; done
gcloud compute target-pools list --format='value(name,region.basename())' | grep -E "$PATRON" | while read -r n r; do q gcloud compute target-pools delete "$n" --region "$r"; done
echo "== Grupos de instancias y plantillas"
gcloud compute instance-groups managed list --format='value(name,zone.basename(),region.basename())' | grep -E "$PATRON" | while read -r n z r; do if [[ -n "$z" ]]; then q gcloud compute instance-groups managed delete "$n" --zone "$z"; else q gcloud compute instance-groups managed delete "$n" --region "$r"; fi; done
echo "== VMs"
gcloud compute instances list --filter="$FILTRO_ETQ" --format='value(name,zone.basename())' | while read -r n z; do q gcloud compute instances delete "$n" --zone "$z"; done
gcloud compute instances list --format='value(name,zone.basename())' | grep -E "$PATRON" | while read -r n z; do q gcloud compute instances delete "$n" --zone "$z"; done
gcloud compute instance-templates list --format='value(name)' | grep -E "$PATRON" | while read -r n; do q gcloud compute instance-templates delete "$n"; done
gcloud compute health-checks list --format='value(name)' | grep -E "$PATRON" | while read -r n; do q gcloud compute health-checks delete "$n"; done
gcloud compute http-health-checks list --format='value(name)' 2>/dev/null | grep -E "$PATRON" | while read -r n; do q gcloud compute http-health-checks delete "$n"; done
echo "== IPs estáticas"
gcloud compute addresses list --format='value(name,region.basename())' | grep -E "$PATRON" | while read -r n r; do if [[ -n "$r" ]]; then q gcloud compute addresses delete "$n" --region "$r"; else q gcloud compute addresses delete "$n" --global; fi; done
echo "== Firewall, subredes y redes"
gcloud compute firewall-rules list --format='value(name)' | grep -E "$PATRON" | while read -r n; do q gcloud compute firewall-rules delete "$n"; done
gcloud compute networks subnets list --format='value(name,region.basename())' | grep -E "$PATRON" | while read -r n r; do q gcloud compute networks subnets delete "$n" --region "$r"; done
gcloud compute networks list --format='value(name)' | grep -E "$PATRON" | while read -r n; do q gcloud compute networks delete "$n"; done
echo "== Buckets"
gcloud storage buckets list --format='value(name)' | grep -E "${PROJECT_ID}-${OBJ/todos/}" | while read -r n; do q gcloud storage rm -r "gs://$n"; done
echo "== Pub/Sub"
gcloud pubsub subscriptions list --format='value(name.basename())' | grep -E "$PATRON" | while read -r n; do q gcloud pubsub subscriptions delete "$n"; done
gcloud pubsub topics list --format='value(name.basename())' | grep -E "$PATRON" | while read -r n; do q gcloud pubsub topics delete "$n"; done
echo "== BigQuery"
bq ls --format=csv 2>/dev/null | tail -n +2 | cut -d, -f1 | grep -E "$PATRON" | while read -r n; do bq rm -r -f -d "$PROJECT_ID:$n" || true; done
echo "== Cuentas de servicio"
gcloud iam service-accounts list --format='value(email)' | grep -E "$PATRON" | while read -r n; do q gcloud iam service-accounts delete "$n"; done
echo "Limpieza terminada. Revisa en la consola: Compute Engine, Kubernetes, SQL y Storage."
