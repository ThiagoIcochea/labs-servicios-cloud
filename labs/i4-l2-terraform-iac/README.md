# Insignia 4 · Lab 2 — Infraestructura como código con Terraform

**Equivale a:** *Infrastructure as Code with Terraform*.

## Qué hace (las 3 fases del lab: construir, cambiar y destruir)
| Etapa | Qué pasa |
|---|---|
| 1 · Construir | Crea la red `<prefijo>-i4l2-red`, una **IP estática** (dependencia implícita), un **bucket** (dependencia explícita con `depends_on`), la VM y un objeto con tu nombre |
| 2 · Cambiar | Agrega la etiqueta de red `<prefijo>-dev` → `update in-place` |
| 3 · Cambio destructivo | Cambia la imagen a Ubuntu → `forces replacement` (destruye y recrea la VM) |
| Destruir | `./lab <alumno> i4-l2 down` → `terraform destroy` |

También muestra el **grafo de dependencias** (`terraform graph`).

## Ejecutar
```bash
./lab <alumno> i4-l2 up
./lab <alumno> i4-l2 down
```

## Evidencias que debes capturar
- [ ] `Plan:` de cada etapa (add / change / replace).
- [ ] El grafo de dependencias.
- [ ] La VM con IP estática y el bucket con `evidencia-<prefijo>.txt`.
- [ ] `Destroy complete!`.

## Costo
e2-micro + IP estática ~10 min ≈ **US$ 0.01**.
