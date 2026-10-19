#!/usr/bin/env bash
# Insignia 3 - Lab de desafío: Develop your Google Cloud Network
source "$(dirname "$0")/../../lib/comun.sh"
banner "Insignia 3 · DESAFÍO · Develop your Google Cloud Network"
habilitar_apis compute.googleapis.com container.googleapis.com monitoring.googleapis.com iam.googleapis.com
VPC="${P}-desafio-vpc"; SUB_PROD="${P}-desafio-prod"; SUB_DEV="${P}-desafio-dev"
CL="${P}-i3l6-gke"; DEV_ID="${P}-i3l6-dev"; DEV="${DEV_ID}@${PROJECT_ID}.iam.gserviceaccount.com"
EXI_ID="${P}-i3l6-ex"; EXI="${EXI_ID}@${PROJECT_ID}.iam.gserviceaccount.com"
NOMBRE_UPTIME="Uptime ${P} i3l6 - ${NOMBRE}"; IP=""

paso "Tarea 1) VPC personalizada $VPC con subredes de producción y desarrollo"
existe gcloud compute networks describe "$VPC" || cmd gcloud compute networks create "$VPC" --subnet-mode custom
existe gcloud compute networks subnets describe "$SUB_PROD" --region "$REGION" || \
  cmd gcloud compute networks subnets create "$SUB_PROD" --network "$VPC" --region "$REGION" --range 10.10.0.0/24 \
    --secondary-range "pods=10.20.0.0/16,servicios=10.30.0.0/20" --enable-private-ip-google-access
existe gcloud compute networks subnets describe "$SUB_DEV" --region "$REGION" || \
  cmd gcloud compute networks subnets create "$SUB_DEV" --network "$VPC" --region "$REGION" --range 10.11.0.0/24
for R in "ssh:tcp:22:0.0.0.0/0" "internal:tcp:0-65535,udp:0-65535,icmp:10.0.0.0/8"; do
  N="${R%%:*}"; RESTO="${R#*:}"; REGLAS="${RESTO%:*}"; ORIGEN="${RESTO##*:}"
  existe gcloud compute firewall-rules describe "${VPC}-allow-$N" || \
    cmd gcloud compute firewall-rules create "${VPC}-allow-$N" --network "$VPC" --allow "$REGLAS" --source-ranges "$ORIGEN"
done

paso "Tarea 2) Clúster GKE $CL dentro de la subred de producción (VPC-native). Tarda ~5-6 min"
existe gcloud container clusters describe "$CL" --zone "$ZONA" || \
  cmd gcloud container clusters create "$CL" --zone "$ZONA" --num-nodes 1 --machine-type e2-medium \
    --disk-size 30 --disk-type pd-standard --network "$VPC" --subnetwork "$SUB_PROD" --enable-ip-alias \
    --cluster-secondary-range-name pods --services-secondary-range-name servicios \
    --release-channel regular --labels "$ETIQUETAS"
cmd gcloud container clusters get-credentials "$CL" --zone "$ZONA"

paso "Tarea 3) Desplegando la aplicación en el namespace 'produccion'"
kubectl create namespace produccion --dry-run=client -o yaml | kubectl apply -f -
kubectl -n produccion create configmap pagina --from-literal=index.html="<!doctype html><html lang='es'><head><meta charset='utf-8'></head><body style='font-family:Arial;padding:40px;background:#fce8e6'><h1 style='color:#c5221f'>DESAFÍO · Develop your Google Cloud Network</h1><p><b>Alumno:</b> $NOMBRE<br><b>Código:</b> $CODIGO<br><b>Curso:</b> $CURSO - Sección $SECCION<br><b>Docente:</b> $DOCENTE<br><b>Red:</b> $VPC / $SUB_PROD · Clúster $CL</p></body></html>" --dry-run=client -o yaml | kubectl apply -f -
cat <<YAML | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata: {name: app-desafio, namespace: produccion, labels: {alumno: $P}}
spec:
  replicas: 2
  selector: {matchLabels: {app: app-desafio}}
  template:
    metadata: {labels: {app: app-desafio}}
    spec:
      containers:
      - name: web
        image: nginx:1.27-alpine
        ports: [{containerPort: 80}]
        resources: {requests: {cpu: 50m, memory: 32Mi}}
        volumeMounts: [{name: html, mountPath: /usr/share/nginx/html}]
      volumes: [{name: html, configMap: {name: pagina}}]
---
apiVersion: v1
kind: Service
metadata: {name: app-desafio, namespace: produccion}
spec: {type: LoadBalancer, selector: {app: app-desafio}, ports: [{port: 80, targetPort: 80}]}
YAML
kubectl -n produccion rollout status deployment/app-desafio --timeout=180s
for i in $(seq 1 40); do IP="$(kubectl -n produccion get svc app-desafio -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)"; [[ -n "$IP" ]] && break; sleep 10; done
kubectl -n produccion get deploy,pods,svc -o wide
esperar_http "http://$IP" "$NOMBRE" 20

paso "Tarea 4) IAM: dar acceso de desarrollador al nuevo integrante y quitárselo al anterior"
existe gcloud iam service-accounts describe "$DEV" || cmd gcloud iam service-accounts create "$DEV_ID" --display-name "Nuevo desarrollador (desafío de $NOMBRE)"
existe gcloud iam service-accounts describe "$EXI" || cmd gcloud iam service-accounts create "$EXI_ID" --display-name "Integrante anterior (desafío de $NOMBRE)"
gcloud projects add-iam-policy-binding "$PROJECT_ID" --member "serviceAccount:$EXI" --role roles/container.developer --condition=None --format=none
cmd gcloud projects add-iam-policy-binding "$PROJECT_ID" --member "serviceAccount:$DEV" --role roles/container.developer --condition=None --format=none
cmd gcloud projects remove-iam-policy-binding "$PROJECT_ID" --member "serviceAccount:$EXI" --role roles/container.developer --condition=None --format=none
gcloud projects get-iam-policy "$PROJECT_ID" --flatten='bindings[].members' --filter="bindings.members~${P}-i3l6" --format='table(bindings.role,bindings.members)'

paso "Tarea 5) Monitoreo: uptime check hacia la aplicación"
if [[ -z "$(gcloud monitoring uptime list-configs --filter="displayName=\"$NOMBRE_UPTIME\"" --format='value(name)')" ]]; then
  cmd gcloud monitoring uptime create "$NOMBRE_UPTIME" --resource-type uptime-url \
    --resource-labels "host=$IP,project_id=$PROJECT_ID" --protocol http --path / --period 1 --timeout 10
fi
gcloud monitoring uptime list-configs --filter="displayName~\"$P i3l6\"" --format='table(displayName,monitoredResource.labels.host)'
ok "Aplicación del desafío: http://$IP"
fin_lab
