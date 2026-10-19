# Insignia 1 · Lab 2 — Cloud Shell y gcloud

**Equivale a:** *Getting Started with Cloud Shell and gcloud*.

## Qué hace
1. Muestra la cuenta activa (`gcloud auth list`) y la configuración (`gcloud config list`).
2. Configura región y zona por defecto, y consulta los metadatos del proyecto.
3. Crea la VM `<prefijo>-i1l2-gcelab2` con metadatos `alumno` y `seccion`.
4. Lista y filtra instancias y reglas de firewall con `--filter` y `--format`.
5. Entra por **SSH** a la VM y lee tu nombre desde el servidor de metadatos.
6. Crea un archivo de evidencia en tu home de Cloud Shell y consulta los logs de auditoría.

## Ejecutar
```bash
./lab <alumno> i1-l2 up
./lab <alumno> i1-l2 down
```

## Evidencias que debes capturar
- [ ] `gcloud auth list` y `gcloud config list` con tu cuenta.
- [ ] La salida del SSH donde la VM imprime **tu nombre** desde los metadatos.
- [ ] `cat` del archivo de evidencia.
- [ ] **Compute Engine → Instancias de VM** con la VM y sus metadatos `alumno` y `seccion`.

## Costo aproximado
1 × e2-micro ~10 min ≈ **US$ 0.01**.
