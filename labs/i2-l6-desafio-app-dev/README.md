# Insignia 2 · Desafío — Set Up an App Dev Environment on Google Cloud

**Equivale a:** *Set Up an App Dev Environment on Google Cloud: Challenge Lab*.

## Escenario
Tu equipo necesita que, cada vez que alguien suba una foto, se genere automáticamente una **miniatura** y se avise por **Pub/Sub**. Además, debes **retirar el acceso** de un ingeniero que ya no está en el equipo.

| Tarea | Recurso |
|---|---|
| 1 | Bucket `gs://<proyecto>-<prefijo>-i2l6-imagenes` |
| 2 | Tópico `<prefijo>-i2l6-miniaturas` |
| 3 | Cloud Function `<prefijo>-i2l6-miniaturas-fn` (Python, disparada al subir un objeto) — [código](funcion/main.py) |
| 4 | Sube `foto-<prefijo>.png` con **tu nombre** → la función crea `foto-<prefijo>64x64_miniatura.png` (también con tu nombre) y publica un mensaje |
| 5 | Quita el rol Visor a la cuenta `<prefijo>-ex-ingeniero` |

## Ejecutar
```bash
./lab <alumno> i2-l6 up      # ~5 min
./lab <alumno> i2-l6 down
```

## Evidencias que debes capturar
- [ ] El bucket con la foto original y la miniatura.
- [ ] El mensaje JSON leído de Pub/Sub (con tu nombre).
- [ ] **Cloud Run functions → tu función → Activadores** (evento `object.v1.finalized`).
- [ ] IAM antes/después de quitar al ingeniero anterior.

## Costo
Dentro del nivel gratuito ≈ **US$ 0.00 – 0.01**.
