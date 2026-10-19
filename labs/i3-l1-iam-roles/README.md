# Insignia 3 · Lab 1 — IAM en la nube (roles predefinidos y personalizados)

**Equivale a:** *Cloud IAM: Qwik Start* (Lab 1 de *Develop your Google Cloud Network*).

Este lab es el mismo de la Insignia 2 (Lab 2). Para que la evidencia **no se repita**, aquí se hace la variante con un **rol personalizado**:

## Qué hace
1. Muestra los permisos del rol predefinido `roles/storage.objectViewer`.
2. Crea el **rol personalizado** `<prefijo>_i3l1_auditor` con título “Auditor de <tu nombre>” y 5 permisos de solo lectura.
3. Crea la cuenta `<prefijo>-i3l1-auditor`, le asigna el rol y comprueba que **puede** leer un informe con tus datos y listar VMs.
4. Revoca el rol y comprueba que ahora recibe **403**.

## Ejecutar
```bash
./lab <alumno> i3-l1 up
./lab <alumno> i3-l1 down    # el rol queda “eliminado” 7 días; si vuelves a correr el lab, se recupera solo
```

## Evidencias que debes capturar
- [ ] **IAM y administración → Funciones (Roles)** con tu rol personalizado “Auditor de <tu nombre>”.
- [ ] Detalle del rol con sus permisos.
- [ ] En Cloud Shell: lectura permitida → revocada (403).

## Costo
Gratis.
