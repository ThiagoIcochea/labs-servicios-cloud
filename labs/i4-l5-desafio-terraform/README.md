# Insignia 4 · Desafío — Build Infrastructure with Terraform

**Equivale a:** *Build Infrastructure with Terraform on Google Cloud: Challenge Lab*.

## Escenario
Tu equipo creó 2 VMs a mano y ahora quiere gestionarlas con Terraform, usando módulos y un estado remoto.

| Tarea | Qué se hace |
|---|---|
| 0 | Se crean a mano `<prefijo>-tf-instance-1` y `-2` con `gcloud` |
| 1-2 | Estructura con módulos [`instances`](tf/modules/instances) y [`storage`](tf/modules/storage); **import** de las 2 VMs (bloques `import`) |
| 3 | Bucket `<proyecto>-<prefijo>-i4l5-backend` creado por el módulo storage |
| 4 | **Backend remoto** `gcs` y migración del estado |
| 5 | Cambiar tipo de máquina a **e2-small** y agregar `<prefijo>-tf-instance-3` |
| 6 | Retirar la instancia 3; crear la VPC `<prefijo>-tf-vpc` (módulo público) con 2 subredes y mover las VMs |
| 7 | Firewall `<prefijo>-tf-firewall` (TCP 80) |

## Ejecutar
```bash
./lab <alumno> i4-l5 up      # ~10 min
./lab <alumno> i4-l5 down
```

## Evidencias que debes capturar
- [ ] `2 to import` en el plan de la etapa 1.
- [ ] El estado remoto en el bucket.
- [ ] Las VMs en e2-small dentro de `<prefijo>-tf-vpc`.
- [ ] La regla `<prefijo>-tf-firewall`.

## Costo
3 VMs pequeñas ~15 min ≈ **US$ 0.02**.
