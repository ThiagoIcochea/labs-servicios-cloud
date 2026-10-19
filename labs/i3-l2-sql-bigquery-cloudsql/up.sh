#!/usr/bin/env bash
# Insignia 3 - Lab 2: Introducción a SQL para BigQuery y Cloud SQL
source "$(dirname "$0")/../../lib/comun.sh"
banner "Insignia 3 · Lab 2 · SQL para BigQuery y Cloud SQL"
habilitar_apis bigquery.googleapis.com sqladmin.googleapis.com storage.googleapis.com
DS="${P}_i3l2_bicis"
BUCKET="gs://${PROJECT_ID}-${P}-i3l2"
INST="${P}-i3l2-mysql"
CLAVE_FILE="$TRABAJO/.clave-root"
[[ -f "$CLAVE_FILE" ]] || openssl rand -base64 18 | tr -d '/+=' > "$CLAVE_FILE"
CLAVE="$(cat "$CLAVE_FILE")"

paso "0) Creando la instancia de Cloud SQL $INST en segundo plano (tarda ~8 min)"
if ! existe gcloud sql instances describe "$INST"; then
  # La contraseña de root se genera al azar y NO se muestra en pantalla (queda en $CLAVE_FILE)
  echo -e "${C_AZ}\$ gcloud beta sql instances create $INST --database-version MYSQL_8_0 --edition enterprise --tier db-f1-micro --region $REGION --storage-size 10 --storage-type HDD --root-password ******** --labels $ETIQUETAS --no-backup --async${C_NO}"
  gcloud beta sql instances create "$INST" --database-version MYSQL_8_0 --edition enterprise \
    --tier db-f1-micro --region "$REGION" --storage-size 10 --storage-type HDD \
    --root-password "$CLAVE" --labels "$ETIQUETAS" --no-backup --async
fi

# ----------------------------- Parte 1: BigQuery ---------------------------
paso "1) Consulta básica: SELECT ... LIMIT sobre london_bicycles.cycle_hire"
cmd bq query --use_legacy_sql=false --max_rows=5 \
  "SELECT end_station_name, duration, '$NOMBRE' AS alumno, '$CODIGO' AS codigo FROM \`bigquery-public-data.london_bicycles.cycle_hire\` LIMIT 5"

paso "2) GROUP BY + COUNT + ORDER BY: estaciones de inicio más usadas"
cmd bq query --use_legacy_sql=false --max_rows=10 \
  "SELECT start_station_name, COUNT(*) AS num_viajes, '$P' AS alumno FROM \`bigquery-public-data.london_bicycles.cycle_hire\` GROUP BY start_station_name ORDER BY num_viajes DESC LIMIT 10"

paso "3) Dataset propio $DS y tablas de resultados"
existe bq show "$PROJECT_ID:$DS" || cmd bq --location US mk -d --label "alumno:$P" --label "seccion:$SECCION" \
  --description "Dataset del lab i3-l2 de $MARCA - $CURSO sección $SECCION" "$PROJECT_ID:$DS"
cmd bq query --use_legacy_sql=false --replace --destination_table "$PROJECT_ID:$DS.inicio_estaciones" \
  "SELECT start_station_name, COUNT(*) AS num FROM \`bigquery-public-data.london_bicycles.cycle_hire\` GROUP BY start_station_name ORDER BY num DESC"
cmd bq query --use_legacy_sql=false --replace --destination_table "$PROJECT_ID:$DS.fin_estaciones" \
  "SELECT end_station_name, COUNT(*) AS num FROM \`bigquery-public-data.london_bicycles.cycle_hire\` GROUP BY end_station_name ORDER BY num DESC"
cmd bq ls "$PROJECT_ID:$DS"

paso "4) Exportando las tablas a CSV en $BUCKET"
existe gcloud storage buckets describe "$BUCKET" || cmd gcloud storage buckets create "$BUCKET" --location "$REGION"
cmd bq extract --print_header=false "$PROJECT_ID:$DS.inicio_estaciones" "$BUCKET/inicio_estaciones.csv"
cmd bq extract --print_header=false "$PROJECT_ID:$DS.fin_estaciones" "$BUCKET/fin_estaciones.csv"
cmd gcloud storage ls -l "$BUCKET"

# ----------------------------- Parte 2: Cloud SQL ---------------------------
paso "5) Esperando a que la instancia Cloud SQL esté lista"
for i in $(seq 1 60); do
  EST="$(gcloud sql instances describe "$INST" --format='value(state)' 2>/dev/null || true)"
  [[ "$EST" == "RUNNABLE" ]] && break
  echo "  estado: ${EST:-CREANDO} ($i/60)"; sleep 15
done
gcloud sql instances describe "$INST" --format='table(name,databaseVersion,settings.tier,region,state,ipAddresses[0].ipAddress)'

paso "6) Base de datos 'bike' y tablas (vía cliente mysql desde Cloud Shell)"
MI_IP="$(curl -s https://api.ipify.org)"
cmd gcloud sql instances patch "$INST" --authorized-networks "$MI_IP/32" --quiet
IP_SQL="$(gcloud sql instances describe "$INST" --format='value(ipAddresses[0].ipAddress)')"
export MYSQL_PWD="$CLAVE"
mysql -h "$IP_SQL" -u root <<SQL
CREATE DATABASE IF NOT EXISTS bike;
USE bike;
CREATE TABLE IF NOT EXISTS london1 (start_station_name VARCHAR(255), num INT);
CREATE TABLE IF NOT EXISTS london2 (end_station_name VARCHAR(255), num INT);
TRUNCATE london1; TRUNCATE london2;
DROP TABLE IF EXISTS evidencia;
CREATE TABLE evidencia (alumno VARCHAR(120), codigo VARCHAR(12), curso VARCHAR(60), seccion VARCHAR(10), docente VARCHAR(80), fecha DATETIME);
DELETE FROM evidencia;
INSERT INTO evidencia VALUES ('$NOMBRE', '$CODIGO', '$CURSO', '$SECCION', '$DOCENTE', NOW());
SQL
ok "Base de datos y tablas creadas"

paso "7) Importando los CSV a Cloud SQL (gcloud sql import csv)"
SA_SQL="$(gcloud sql instances describe "$INST" --format='value(serviceAccountEmailAddress)')"
cmd gcloud storage buckets add-iam-policy-binding "$BUCKET" --member "serviceAccount:$SA_SQL" --role roles/storage.objectViewer --format=none
cmd gcloud sql import csv "$INST" "$BUCKET/inicio_estaciones.csv" --database bike --table london1 --quiet
cmd gcloud sql import csv "$INST" "$BUCKET/fin_estaciones.csv" --database bike --table london2 --quiet

paso "8) Consultas en Cloud SQL"
mysql -h "$IP_SQL" -u root -t bike <<SQL
SELECT * FROM evidencia;
SELECT COUNT(*) AS filas_london1 FROM london1;
SELECT start_station_name, num FROM london1 ORDER BY num DESC LIMIT 5;
DELETE FROM london1 WHERE num = 0;
SELECT start_station_name AS top_estacion, num FROM london1 UNION SELECT end_station_name, num FROM london2 ORDER BY num DESC LIMIT 5;
SQL
unset MYSQL_PWD
fin_lab
