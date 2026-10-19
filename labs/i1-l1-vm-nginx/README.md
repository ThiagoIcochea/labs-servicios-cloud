# Insignia 1 · Lab 1 — Creando una máquina virtual

**Equivale a:** *Creating a Virtual Machine* (opción 1 del Lab 1 de la insignia *Implement Load Balancing on Compute Engine*).

## Qué hace
1. Crea la regla de firewall `<prefijo>-i1l1-http` (TCP 80) para la etiqueta de red del lab.
2. Crea la VM `<prefijo>-i1l1-web` (e2-micro, Debian 12) e instala **NGINX** con un *startup-script* que publica una página con **tu nombre completo, curso, sección y docente**.
3. Crea una segunda VM `<prefijo>-i1l1-gcelab2` solo con `gcloud` (parte 2 del lab original).
4. Espera a que la página responda y muestra la IP externa.

## Ejecutar
```bash
./lab <alumno> i1-l1 up      # crear
./lab <alumno> i1-l1 down    # borrar todo
```

## Evidencias que debes capturar
- [ ] Cloud Shell con el recuadro de datos del alumno y la creación de las VMs.
- [ ] **Compute Engine → Instancias de VM** mostrando tus 2 VMs con tu prefijo.
- [ ] La página `http://<IP_EXTERNA>` en el navegador con tu nombre.
- [ ] Detalle de la VM (pestaña *Detalles*): tipo de máquina, zona y etiquetas `alumno` / `seccion`.

## Costo aproximado
2 × e2-micro durante ~15 min ≈ **US$ 0.01**. Bórralo al terminar.
