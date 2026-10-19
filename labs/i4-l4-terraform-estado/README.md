# Insignia 4 · Lab 4 — Administración del estado de Terraform

**Equivale a:** *Managing Terraform State*.

## Qué hace
1. **Estado local:** crea el bucket `<proyecto>-<prefijo>-i4l4-tfstate` (con versionado) y muestra `terraform.tfstate`.
2. **Estado remoto:** agrega un backend `gcs` y **migra** el estado al bucket (`init -migrate-state`).
3. **Refresh:** cambia una etiqueta del bucket fuera de Terraform y lo detecta con `apply -refresh-only`.
4. **Importación:** crea la VM `<prefijo>-i4l4-importada` con `gcloud` y la pone bajo control de Terraform con un bloque `import` y `plan -generate-config-out` (Terraform genera el código solo).
5. Muestra el estado remoto guardado en el bucket.

## Ejecutar
```bash
./lab <alumno> i4-l4 up
./lab <alumno> i4-l4 down    # devuelve el estado a local, hace destroy y borra el bucket
```

## Evidencias que debes capturar
- [ ] `Successfully configured the backend "gcs"` y el archivo `default.tfstate` en el bucket.
- [ ] `Import complete` / `1 imported` y el archivo `generado.tf`.
- [ ] El bucket en **Cloud Storage** con la carpeta `terraform/estado/<prefijo>`.

## Costo
e2-micro ~10 min ≈ **US$ 0.01**.
