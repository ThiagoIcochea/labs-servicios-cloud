#!/usr/bin/env bash
# Insignia 2 - Lab 5: Google Cloud Pub/Sub: Qwik Start - Línea de comandos
source "$(dirname "$0")/../../lib/comun.sh"
banner "Insignia 2 · Lab 5 · Pub/Sub (línea de comandos)"
habilitar_apis pubsub.googleapis.com
T1="${P}-i2l5-topico"; T2="${P}-i2l5-temporal"; S1="${P}-i2l5-suscripcion"

paso "1) Creando tópicos (y uno temporal para practicar borrado)"
existe gcloud pubsub topics describe "$T1" || cmd gcloud pubsub topics create "$T1" --labels "$ETIQUETAS"
existe gcloud pubsub topics describe "$T2" || cmd gcloud pubsub topics create "$T2" --labels "$ETIQUETAS"
cmd gcloud pubsub topics list --filter="name~$P" --format='table(name.basename(),labels.alumno)'
cmd gcloud pubsub topics delete "$T2"
cmd gcloud pubsub topics list --filter="name~$P" --format='table(name.basename(),labels.alumno)'

paso "2) Creando la suscripción pull $S1"
existe gcloud pubsub subscriptions describe "$S1" || \
  cmd gcloud pubsub subscriptions create "$S1" --topic "$T1" --labels "$ETIQUETAS" --ack-deadline 20
cmd gcloud pubsub topics list-subscriptions "$T1"

paso "3) Publicando mensajes con los datos del alumno"
cmd gcloud pubsub topics publish "$T1" --message "Hola, soy $NOMBRE" --attribute "alumno=$P,seccion=$SECCION"
cmd gcloud pubsub topics publish "$T1" --message "Código de estudiante: $CODIGO" --attribute "alumno=$P"
cmd gcloud pubsub topics publish "$T1" --message "Curso $CURSO - Sección $SECCION" --attribute "alumno=$P"
cmd gcloud pubsub topics publish "$T1" --message "Docente: $DOCENTE" --attribute "alumno=$P"
cmd gcloud pubsub topics publish "$T1" --message "Mensaje enviado el $(ahora)" --attribute "alumno=$P"

paso "4) Leyendo un solo mensaje (pull sin --limit)"
cmd gcloud pubsub subscriptions pull "$S1" --auto-ack

paso "5) Leyendo el resto de mensajes con --limit"
sleep 3
cmd gcloud pubsub subscriptions pull "$S1" --auto-ack --limit 10 \
  --format='table(message.data.decode(base64):label=MENSAJE,message.attributes.alumno:label=ALUMNO,message.publishTime:label=PUBLICADO)'
fin_lab
