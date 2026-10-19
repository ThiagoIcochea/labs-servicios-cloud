# Insignia 4 · Lab 3 — Módulos de Terraform

**Equivale a:** *Interact with Terraform Modules*.

## Qué hace
1. Usa un **módulo público** del Terraform Registry (`terraform-google-modules/network/google`) para crear la VPC `<prefijo>-i4l3-red` con 2 subredes.
2. Usa un **módulo propio** [`modules/sitio_web`](tf/modules/sitio_web) que crea un bucket con **sitio web estático** público, cuya página muestra tu nombre y sección.
3. Muestra la estructura de carpetas, el plan, los `output` de cada módulo y prueba la URL del sitio.

## Ejecutar
```bash
./lab <alumno> i4-l3 up
./lab <alumno> i4-l3 down
```

## Evidencias que debes capturar
- [ ] `terraform init` descargando el módulo `network`.
- [ ] `terraform output` (red, subredes, URL).
- [ ] La red en **Redes de VPC** y el sitio web abierto en el navegador.

## Costo
Gratis (red sin VMs + unos KB en Storage).
