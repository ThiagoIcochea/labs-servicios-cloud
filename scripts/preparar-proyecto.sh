#!/usr/bin/env bash
# Habilita de una sola vez todas las APIs que usan los 21 labs.
# Uso: bash scripts/preparar-proyecto.sh [PROJECT_ID]
set -euo pipefail
PROJECT_ID="${1:-$(gcloud config get-value project 2>/dev/null)}"
echo "Habilitando APIs en el proyecto: $PROJECT_ID (tarda 1-3 minutos)…"
gcloud services enable --project "$PROJECT_ID" \
  compute.googleapis.com storage.googleapis.com iam.googleapis.com \
  iamcredentials.googleapis.com cloudresourcemanager.googleapis.com \
  monitoring.googleapis.com logging.googleapis.com \
  cloudfunctions.googleapis.com cloudbuild.googleapis.com \
  artifactregistry.googleapis.com run.googleapis.com eventarc.googleapis.com \
  pubsub.googleapis.com bigquery.googleapis.com sqladmin.googleapis.com \
  container.googleapis.com
gcloud config set project "$PROJECT_ID" >/dev/null
gcloud config set compute/region us-central1 >/dev/null
gcloud config set compute/zone us-central1-a >/dev/null
echo
echo "Cuota de CPUs en us-central1 (la prueba gratuita limita los vCPU encendidos a la vez):"
gcloud compute regions describe us-central1 --flatten=quotas \
  --filter="quotas.metric=(CPUS,IN_USE_ADDRESSES,STATIC_ADDRESSES,SSD_TOTAL_GB)" \
  --format="table(quotas.metric,quotas.usage,quotas.limit)"
echo "Listo. Proyecto preparado."
