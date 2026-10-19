# Insignia 3 · Desafío — Develop your Google Cloud Network

**Equivale a:** *Develop your Google Cloud Network: Challenge Lab*.

## Escenario
Debes preparar la red y la plataforma de contenedores para el equipo de desarrollo:

| Tarea | Recurso |
|---|---|
| 1 | VPC `<prefijo>-desafio-vpc` con subredes `prod` (con rangos secundarios para GKE) y `dev`, firewall SSH e interno |
| 2 | Clúster GKE `<prefijo>-i3l6-gke` *VPC-native* dentro de la subred de producción |
| 3 | App NGINX en el namespace `produccion` con tu nombre, expuesta con un Service LoadBalancer |
| 4 | IAM: rol `container.developer` al nuevo desarrollador y retiro del integrante anterior |
| 5 | Uptime check de Cloud Monitoring hacia la app |

## Ejecutar
```bash
./lab <alumno> i3-l6 up      # ~10 min
./lab <alumno> i3-l6 down
```

## Evidencias que debes capturar
- [ ] **Redes de VPC** con tu VPC y sus subredes (rangos secundarios).
- [ ] **Kubernetes Engine → Cargas de trabajo** en el namespace `produccion`.
- [ ] La app en el navegador con tu nombre.
- [ ] **IAM** con el nuevo desarrollador y el uptime check en verde.

## Costo aproximado
1 nodo e2-medium + LoadBalancer ~20 min ≈ **US$ 0.03**.
