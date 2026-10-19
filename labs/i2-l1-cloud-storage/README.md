# Insignia 2 · Lab 1 — Cloud Storage (CLI/SDK)

**Equivale a:** *Cloud Storage: Qwik Start - CLI/SDK* (opción 2 del Lab 1 de *Set Up an App Dev Environment on Google Cloud*).

## Qué hace
1. Crea el bucket `gs://<proyecto>-<prefijo>-i2l1` con etiquetas del alumno.
2. Genera 3 objetos con tus datos: `evidencia.txt`, `index.html` y una **imagen con tu nombre** (`credencial.png`).
3. Los sube, descarga uno, los copia a `carpeta-<prefijo>/imagenes` y `carpeta-<prefijo>/documentos`.
4. Lista el bucket y muestra los metadatos de un objeto.
5. Hace **públicos** la página y la imagen y verifica la URL pública.

## Ejecutar
```bash
./lab <alumno> i2-l1 up
./lab <alumno> i2-l1 down
```

## Evidencias que debes capturar
- [ ] **Cloud Storage → Buckets → tu bucket** mostrando carpetas y objetos.
- [ ] El objeto con la columna *Acceso público* = “Público en Internet”.
- [ ] La URL pública abierta en el navegador (página e imagen con tu nombre).

## Costo aproximado
Unos KB de almacenamiento ≈ **US$ 0.00**.
