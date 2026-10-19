# Insignia 2 · Lab 3 — Cloud Monitoring

**Equivale a:** *Cloud Monitoring: Qwik Start*.

## Qué hace
1. Crea la VM `<prefijo>-i2l3-lamp` con servidor web e instala el **Ops Agent** (métricas y logs).
2. Crea un **uptime check** HTTP hacia la IP de la VM.
3. Crea un **canal de notificación por correo** con tu correo y una **política de alerta** (tráfico > 500 B/s por 1 min).
4. Crea un **dashboard** con un panel de texto que muestra tu nombre, más gráficos de CPU y red.
5. Genera tráfico durante 2 minutos para que la alerta se dispare.

## Ejecutar
```bash
./lab <alumno> i2-l3 up      # ~6 min
./lab <alumno> i2-l3 down
```

## Evidencias que debes capturar
- [ ] **Monitoring → Paneles** con tu dashboard (nombre y sección visibles).
- [ ] **Monitoring → Verificaciones de tiempo de actividad** con tu uptime check en verde.
- [ ] **Monitoring → Alertas** mostrando la política y el incidente abierto.
- [ ] El correo de alerta recibido (opcional).

## Costo aproximado
e2-small ~15 min + métricas del agente ≈ **US$ 0.02**.
