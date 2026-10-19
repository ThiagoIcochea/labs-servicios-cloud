# Insignia 2 · Lab 2 — Cloud IAM: conceder y revocar permisos

**Equivale a:** *Cloud IAM: Qwik Start*.

El lab original inicia sesión con **2 usuarios**. Para que cada integrante lo haga solo, aquí el **Usuario 2** es una cuenta de servicio `<prefijo>-usuario2`, y las pruebas se ejecutan **suplantándola** (`--impersonate-service-account`). El efecto de conceder/quitar roles es exactamente el mismo.

## Qué hace
1. Crea el Usuario 2 y permite que tú lo suplantes.
2. Usuario 1 (tú) crea un bucket y sube `sample.txt` con tus datos.
3. Concede **Visor** al Usuario 2 → puede listar el bucket.
4. Quita **Visor** → recibe **403 / acceso denegado**.
5. Concede solo **Storage Object Viewer** → vuelve a leer el archivo (mínimo privilegio).

## Ejecutar
```bash
./lab <alumno> i2-l2 up      # ~3-5 min (la propagación de IAM tarda)
./lab <alumno> i2-l2 down
```

## Evidencias que debes capturar
- [ ] **IAM y administración → IAM** mostrando la cuenta `<prefijo>-usuario2` con el rol asignado.
- [ ] En Cloud Shell: acceso permitido → denegado (403) → permitido otra vez.
- [ ] **Cuentas de servicio** mostrando la cuenta con el nombre visible “Usuario 2 de <tu nombre>”.

## Costo
Gratis.
