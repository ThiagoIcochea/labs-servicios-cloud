# Insignia 3 · Lab 4 — Monitoreo: Ops Agent, logs y métricas

**Equivale a:** *Cloud Monitoring: Qwik Start* (Lab 4 de *Develop your Google Cloud Network*).

Este lab se repite en la Insignia 2 (Lab 3). Para que la evidencia **no sea la misma**, aquí se trabaja con **logs**:

## Qué hace
1. Crea la VM `<prefijo>-i3l4-apache` con **Apache** y el **Ops Agent** configurado para recolectar métricas y logs de Apache.
2. Crea la **métrica basada en logs** `<prefijo>_i3l4_visitas` que cuenta las visitas con el user-agent `Evidencia-<prefijo>`.
3. Genera 3 minutos de tráfico y lee los **logs de acceso** con `gcloud logging read`.
4. Crea un **dashboard** con tu nombre, la métrica basada en logs, las peticiones de Apache y un panel de logs.

## Ejecutar
```bash
./lab <alumno> i3-l4 up      # ~7 min
./lab <alumno> i3-l4 down
```

## Evidencias que debes capturar
- [ ] **Explorador de registros** filtrando `apache_access` con el user-agent `Evidencia-<prefijo>`.
- [ ] **Métricas basadas en registros** con tu métrica.
- [ ] Tu **dashboard** con los 3 paneles.

## Costo aproximado
e2-small ~15 min ≈ **US$ 0.01**.
