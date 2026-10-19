#!/usr/bin/env bash
# Insignia 3 - Lab 5: Managing Deployments Using Kubernetes Engine
# Escalado, rolling update, rollback, canary y blue-green con NGINX + ConfigMaps personalizados.
source "$(dirname "$0")/../../lib/comun.sh"
banner "Insignia 3 · Lab 5 · Gestión de despliegues en GKE"
habilitar_apis container.googleapis.com
CL="${P}-i3l5-gke"; IP=""; IPBG=""
command -v kubectl >/dev/null || { aviso "Falta kubectl"; exit 1; }

paso "1) Clúster GKE zonal $CL (2 nodos e2-medium). Tarda ~5-6 min"
existe gcloud container clusters describe "$CL" --zone "$ZONA" || \
  cmd gcloud container clusters create "$CL" --zone "$ZONA" --num-nodes 2 --machine-type e2-medium \
    --disk-size 30 --disk-type pd-standard --release-channel regular --labels "$ETIQUETAS"
cmd gcloud container clusters get-credentials "$CL" --zone "$ZONA"
kubectl get nodes -o wide

pagina() { # $1 = versión, $2 = color, $3 = descripción
cat <<HTML
<!doctype html><html lang="es"><head><meta charset="utf-8"><title>$1</title></head>
<body style="font-family:Arial;background:$2;color:#fff;padding:40px">
<h1>Versión $1 · $3</h1>
<p><b>Alumno:</b> $NOMBRE<br><b>Código:</b> $CODIGO<br><b>Curso:</b> $CURSO - Sección $SECCION<br><b>Docente:</b> $DOCENTE<br>
<b>Clúster:</b> $CL · Insignia 3 Lab 5</p></body></html>
HTML
}
paso "2) ConfigMaps con las páginas de cada versión (v1 azul, v2 verde, canary naranja)"
kubectl create configmap web-v1 --from-literal=index.html="$(pagina 1.0.0 '#1a73e8' 'estable')" --dry-run=client -o yaml | kubectl apply -f -
kubectl create configmap web-v2 --from-literal=index.html="$(pagina 2.0.0 '#188038' 'nueva versión')" --dry-run=client -o yaml | kubectl apply -f -
kubectl create configmap web-canary --from-literal=index.html="$(pagina 2.0.0-canary '#e37400' 'canary')" --dry-run=client -o yaml | kubectl apply -f -

despliegue() { # nombre track version configmap replicas
cat <<YAML
apiVersion: apps/v1
kind: Deployment
metadata: {name: $1, labels: {app: web, alumno: $P}}
spec:
  replicas: $5
  selector: {matchLabels: {app: web, track: $2}}
  strategy: {type: RollingUpdate, rollingUpdate: {maxSurge: 1, maxUnavailable: 0}}
  template:
    metadata: {labels: {app: web, track: $2, version: "$3"}, annotations: {kubernetes.io/change-cause: "version $3 ($4) - $P"}}
    spec:
      containers:
      - name: nginx
        image: nginx:1.27-alpine
        ports: [{containerPort: 80}]
        resources: {requests: {cpu: 50m, memory: 32Mi}}
        readinessProbe: {httpGet: {path: /, port: 80}, periodSeconds: 3}
        volumeMounts: [{name: html, mountPath: /usr/share/nginx/html}]
      volumes: [{name: html, configMap: {name: $4}}]
YAML
}
servicio() { # nombre selector-extra
cat <<YAML
apiVersion: v1
kind: Service
metadata: {name: $1, labels: {alumno: $P}}
spec:
  type: LoadBalancer
  selector: {app: web$2}
  ports: [{port: 80, targetPort: 80}]
YAML
}

paso "3) Deployment 'web' (3 réplicas, v1) y Service LoadBalancer 'web'"
despliegue web stable 1.0.0 web-v1 3 | kubectl apply -f -
servicio web "" | kubectl apply -f -
kubectl rollout status deployment/web --timeout=180s
echo "Esperando IP externa del Service…"
for i in $(seq 1 40); do IP="$(kubectl get svc web -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)"; [[ -n "$IP" ]] && break; sleep 10; done
kubectl get deploy,pods,svc -o wide
esperar_http "http://$IP" "$NOMBRE" 20
version() { curl -s -m 5 "http://$IP" | grep -o 'Versión [^<]*' || true; }

paso "4) ESCALADO: 3 → 5 → 3 réplicas"
cmd kubectl scale deployment web --replicas 5
kubectl rollout status deployment/web --timeout=120s; kubectl get pods -l app=web
cmd kubectl scale deployment web --replicas 3
kubectl rollout status deployment/web --timeout=120s

paso "5) ROLLING UPDATE a v2 (sin cortar el servicio)"
despliegue web stable 2.0.0 web-v2 3 | kubectl apply -f -
kubectl rollout status deployment/web --timeout=180s
for i in 1 2 3; do version; done
cmd kubectl rollout history deployment/web

paso "6) ROLLBACK a v1"
cmd kubectl rollout undo deployment/web
kubectl rollout status deployment/web --timeout=180s
for i in 1 2 3; do version; done

paso "7) CANARY: 1 réplica 2.0.0-canary recibe ~25 % del tráfico del mismo Service"
despliegue web-canary canary 2.0.0-canary web-canary 1 | kubectl apply -f -
kubectl rollout status deployment/web-canary --timeout=120s
kubectl get pods -L track,version
echo "Distribución de 20 peticiones:"
for i in $(seq 1 20); do version; done | sort | uniq -c
kubectl delete deployment web-canary

paso "8) BLUE-GREEN: Service 'web-bg' apunta a blue (v1) y luego se cambia a green (v2)"
despliegue web-blue blue 1.0.0 web-v1 2 | kubectl apply -f -
despliegue web-green green 2.0.0 web-v2 2 | kubectl apply -f -
kubectl rollout status deployment/web-blue --timeout=120s; kubectl rollout status deployment/web-green --timeout=120s
servicio web-bg ", track: blue" | kubectl apply -f -
for i in $(seq 1 40); do IPBG="$(kubectl get svc web-bg -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)"; [[ -n "$IPBG" ]] && break; sleep 10; done
esperar_http "http://$IPBG" "1.0.0" 20
echo "Antes del cambio:"; curl -s "http://$IPBG" | grep -o 'Versión [^<]*' || true
cmd kubectl patch service web-bg -p '{"spec":{"selector":{"app":"web","track":"green"}}}'
sleep 10
echo "Después del cambio:"; for i in 1 2 3; do curl -s "http://$IPBG" | grep -o 'Versión [^<]*' || true; done

paso "Estado final del clúster"
kubectl get deploy,svc -L alumno
ok "Service web    : http://$IP"
ok "Service web-bg : http://$IPBG"
fin_lab
