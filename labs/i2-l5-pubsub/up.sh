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

paso "5) Leyendo el resto de mensajes con --limit (se repite hasta vaciar la suscripción)"
for intento in 1 2 3 4; do
  sleep 3
  salida="$(gcloud pubsub subscriptions pull "$S1" --auto-ack --limit 10 \
    --format='value(message.data.decode(base64).decode(utf-8),message.attributes.alumno,message.publishTime)' || true)"
  [[ -z "$salida" ]] && break
  echo -e "${C_AZ}\$ gcloud pubsub subscriptions pull $S1 --auto-ack --limit 10   (lectura $intento)${C_NO}"
  printf '%s\n' "$salida" | awk -F'\t' '{printf "  MENSAJE: %-50s ALUMNO: %-10s PUBLICADO: %s\n", $1, $2, $3}'
done
ok "Suscripción vacía: todos los mensajes de ${NOMBRE} fueron leídos"
fin_lab
