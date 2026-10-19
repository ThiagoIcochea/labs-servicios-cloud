# Insignia 3 · Lab 5 — Gestión de despliegues en Kubernetes Engine

**Equivale a:** *Managing Deployments Using Kubernetes Engine*.

## Qué hace
1. Crea el clúster GKE `<prefijo>-i3l5-gke` (zonal, 2 nodos e2-medium).
2. Crea 3 **ConfigMaps** con páginas HTML (v1 azul, v2 verde, canary naranja) que muestran **tu nombre, curso y sección**.
3. Despliega `web` (NGINX, 3 réplicas) con un **Service LoadBalancer**.
4. **Escalado** 3 → 5 → 3.
5. **Rolling update** a v2, `rollout history` y **rollback** a v1.
6. **Canary**: 1 réplica canary junto a las 3 estables; muestra la distribución de 20 peticiones.
7. **Blue-green**: Service `web-bg` apuntando a *blue* y luego a *green* con `kubectl patch`.

## Ejecutar
```bash
./lab <alumno> i3-l5 up      # ~12 min
./lab <alumno> i3-l5 down    # borra Services y luego el clúster
```

## Evidencias que debes capturar
- [ ] **Kubernetes Engine → Clústeres** con tu clúster.
- [ ] **Cargas de trabajo** con `web`, `web-blue`, `web-green`.
- [ ] La página en el navegador (v1 azul / v2 verde) con tu nombre.
- [ ] En Cloud Shell: `rollout history`, distribución canary y el cambio blue → green.

## Costo aproximado
2 nodos e2-medium + 2 LoadBalancer ~20 min ≈ **US$ 0.05** (la tarifa de gestión del clúster zonal la cubre el crédito gratuito de GKE).
