# Insignia 4 · Lab 1 — Fundamentos de Terraform

**Equivale a:** *Terraform Fundamentals*.

## Qué hace
1. Muestra la versión de Terraform de Cloud Shell.
2. Copia la configuración de [`tf/`](tf) a tu carpeta de trabajo y genera `terraform.tfvars` con **tu nombre, prefijo y sección**.
3. Ejecuta `init`, `fmt`, `validate`, `plan` y `apply`.
4. Crea la VM `<prefijo>-i4l1-terraform` con etiquetas y metadatos del alumno.
5. Muestra `state list`, `show` y los `output` (incluye `alumno = "<tu nombre> - Sección 45104"`).

## Ejecutar
```bash
./lab <alumno> i4-l1 up
./lab <alumno> i4-l1 down     # terraform destroy
```

## Evidencias que debes capturar
- [ ] Salida de `terraform plan` (1 to add) y `apply` (Apply complete!).
- [ ] `terraform output` con tu nombre.
- [ ] La VM en **Compute Engine** con sus etiquetas.
- [ ] `terraform destroy` (Destroy complete!).

## Costo
1 × e2-micro ~10 min ≈ **US$ 0.01**.
