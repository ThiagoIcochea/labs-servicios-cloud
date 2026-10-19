# Insignia 1 · Lab 3 — Balanceadores de carga de red y HTTP

**Equivale a:** *Set Up Network and HTTP Load Balancers*.

## Qué hace
**Parte A – Balanceador de red (capa 4)**
- 3 VMs `<prefijo>-www1..3` con NGINX; cada una dice *“Servidor wwwN”* y tu nombre.
- IP estática regional, *health check* HTTP, *target pool* `<prefijo>-www-pool` y regla de reenvío.

**Parte B – Balanceador HTTP (capa 7)**
- Plantilla de instancias, grupo administrado (MIG) `<prefijo>-lb-backend-group`, regla de firewall para los *health checks* de Google.
- IP global, servicio de backend, *URL map*, proxy HTTP y regla de reenvío global.

Al final hace varios `curl` para demostrar que las respuestas se reparten entre servidores.

Variables opcionales (por la cuota de la prueba gratuita): `NUM_WWW=2 TAM_MIG=1 ./lab <alumno> i1-l3 up`.

## Ejecutar
```bash
./lab <alumno> i1-l3 up      # ~6-8 min (el balanceador HTTP tarda en propagarse)
./lab <alumno> i1-l3 down
```

## Evidencias que debes capturar
- [ ] Salida de los `curl` alternando entre `www1`, `www2`, `www3`.
- [ ] **Servicios de red → Balanceo de cargas** con tus dos balanceadores.
- [ ] Detalle del balanceador HTTP con los backends en verde (*healthy*).
- [ ] La página del balanceador HTTP en el navegador con tu nombre.

## Costo aproximado
5 VMs e2-micro + 2 reglas de reenvío ~20 min ≈ **US$ 0.05**.
