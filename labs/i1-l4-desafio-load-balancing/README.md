# Insignia 1 · Desafío — Implement Load Balancing on Compute Engine

**Equivale a:** *Implement Load Balancing on Compute Engine: Challenge Lab*.

## Escenario
Eres el ingeniero de la nube del equipo y debes publicar un sitio web con alta disponibilidad, usando nombres con tu prefijo:

| Tarea | Recurso |
|---|---|
| 1 | VM de salto `<prefijo>-jumphost` |
| 2 | Plantilla `<prefijo>-desafio-template` (NGINX con tu nombre) |
| 3 | MIG `<prefijo>-desafio-mig` con **autoescalado** (mín 2, máx 3, CPU 60 %) |
| 4 | Firewall `<prefijo>-permit-tcp-rule-80` |
| 5 | Balanceador HTTP: *health check*, *backend*, *URL map* `<prefijo>-desafio-lb`, proxy y regla global |
| 6 | Prueba desde el jumphost hacia las IPs internas y desde Internet hacia el balanceador |

## Ejecutar
```bash
./lab <alumno> i1-l4 up
./lab <alumno> i1-l4 down
```

## Evidencias que debes capturar
- [ ] Salida de la tarea 6 (jumphost → backends) con tu nombre.
- [ ] **Grupos de instancias** mostrando el autoescalado configurado.
- [ ] **Balanceo de cargas** con el backend en verde.
- [ ] La página del balanceador en el navegador.

## Costo aproximado
3 VMs e2-micro + 1 regla de reenvío ~20 min ≈ **US$ 0.04**.
