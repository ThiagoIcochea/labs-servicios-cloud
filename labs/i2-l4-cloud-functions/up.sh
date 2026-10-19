#!/usr/bin/env bash
# Insignia 2 - Lab 4: Cloud Functions: Qwik Start - Línea de comandos
source "$(dirname "$0")/../../lib/comun.sh"
banner "Insignia 2 · Lab 4 · Cloud Functions (línea de comandos)"
habilitar_apis cloudfunctions.googleapis.com cloudbuild.googleapis.com artifactregistry.googleapis.com \
  run.googleapis.com logging.googleapis.com
FN="${P}-i2l4-hola"

paso "1) Variables de entorno de la función con los datos del alumno"
cat > "$TRABAJO/env.yaml" <<YAML
NOMBRE: "$NOMBRE"
CODIGO: "$CODIGO"
CURSO: "$CURSO"
SECCION: "$SECCION"
DOCENTE: "$DOCENTE"
YAML
cat "$TRABAJO/env.yaml"

paso "2) Desplegando la función HTTP $FN (Python 3.12, 2.ª generación). Tarda ~2-3 min"
cmd gcloud functions deploy "$FN" --gen2 --region "$REGION" --runtime python312 \
  --source "$(dirname "$0")/funcion" --entry-point hola --trigger-http --allow-unauthenticated \
  --env-vars-file "$TRABAJO/env.yaml" --memory 256Mi --max-instances 2 \
  --update-labels "$ETIQUETAS"

paso "3) Describiendo la función"
gcloud functions describe "$FN" --gen2 --region "$REGION" \
  --format='yaml(name,state,buildConfig.runtime,serviceConfig.uri,serviceConfig.environmentVariables,labels)'
URL="$(gcloud functions describe "$FN" --gen2 --region "$REGION" --format='value(serviceConfig.uri)')"

paso "4) Probando la función con curl y con gcloud functions call"
cmd curl -s "$URL?nombre=$(echo "$NOMBRE" | cut -d' ' -f1)"; echo
cmd gcloud functions call "$FN" --gen2 --region "$REGION"

paso "5) Leyendo los logs de la función"
sleep 15
gcloud functions logs read "$FN" --gen2 --region "$REGION" --limit 10 || true
ok "URL de la función: $URL"
fin_lab
