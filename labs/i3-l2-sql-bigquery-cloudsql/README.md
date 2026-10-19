# Insignia 3 · Lab 2 — SQL para BigQuery y Cloud SQL

**Equivale a:** *Introduction to SQL for BigQuery and Cloud SQL*.

## Qué hace
**Parte 1 – BigQuery** (dataset público `london_bicycles`)
- `SELECT … LIMIT`, `GROUP BY`, `COUNT`, `ORDER BY` — cada consulta incluye una columna con **tu nombre o prefijo**.
- Crea el dataset `<prefijo>_i3l2_bicis` (con tu nombre en la descripción) y guarda 2 tablas de resultados.
- Las exporta como CSV a `gs://<proyecto>-<prefijo>-i3l2`.

**Parte 2 – Cloud SQL (MySQL 8, db-f1-micro)**
- Crea la instancia `<prefijo>-i3l2-mysql`, la base `bike` y las tablas `london1`, `london2` y **`evidencia`** (con tu nombre, curso, sección y docente).
- Importa los CSV con `gcloud sql import csv` y ejecuta `SELECT`, `DELETE` y `UNION`.

## Ejecutar
```bash
./lab <alumno> i3-l2 up      # ~10 min (la instancia SQL tarda en crearse)
./lab <alumno> i3-l2 down
```

## Evidencias que debes capturar
- [ ] **BigQuery Studio** con tu dataset, las tablas y una consulta con la columna `alumno`.
- [ ] **SQL → tu instancia** (estado verde).
- [ ] En Cloud Shell la tabla `evidencia` y el `UNION` final.

## Costo aproximado
Consultas BigQuery dentro del 1 TB gratis; Cloud SQL db-f1-micro ~20 min ≈ **US$ 0.01**.
