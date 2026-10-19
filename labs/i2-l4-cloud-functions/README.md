# Insignia 2 · Lab 4 — Cloud Functions (línea de comandos)

**Equivale a:** *Cloud Functions: Qwik Start - Command Line* (opción 2 del Lab 4).

## Qué hace
1. Despliega la función HTTP `<prefijo>-i2l4-hola` (Python 3.12, 2.ª generación) desde [`funcion/main.py`](funcion/main.py).
2. La función responde un JSON con **tu nombre, curso, sección y docente** (variables de entorno).
3. La prueba con `curl` y `gcloud functions call`.
4. Lee los logs de la función, donde aparece “Invocación del lab i2-l4 de <tu nombre>”.

## Ejecutar
```bash
./lab <alumno> i2-l4 up      # ~3 min
./lab <alumno> i2-l4 down
```

## Evidencias que debes capturar
- [ ] **Cloud Run functions** con tu función en verde.
- [ ] La respuesta JSON en el navegador o en Cloud Shell.
- [ ] La pestaña **Registros** de la función con tu nombre.

## Costo
Dentro del nivel gratuito (2 M invocaciones/mes) ≈ **US$ 0.00**.
