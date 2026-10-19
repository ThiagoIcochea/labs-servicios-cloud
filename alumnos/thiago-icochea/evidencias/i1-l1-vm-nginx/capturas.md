01-cloudshell-inicio.png|Cloud Shell · inicio del lab: datos del alumno y regla de firewall ticochea-i1l1-http|18/10/2026 22:47:55
02-cloudshell-vms-creadas.png|Cloud Shell · VMs ticochea-i1l1-web y ticochea-i1l1-gcelab2 creadas con gcloud (filtro alumno=ticochea)|18/10/2026 22:48:36
03-cloudshell-resultado.png|Cloud Shell · NGINX responde desde ticochea-i1l1-web con nombre, curso y sección|18/10/2026 22:49:20
04-consola-instancias.png|Consola · Compute Engine > Instancias de VM (prefijo ticochea)|18/10/2026 22:50:50
05-consola-detalle-vm.png|Consola · Detalle de la VM ticochea-i1l1-web: información básica|18/10/2026 22:51:22
06-consola-etiquetas.png|Consola · Etiquetas de la VM: alumno=ticochea, seccion=45104, curso=servicios-cloud, lab=i1l1|18/10/2026 22:53:11
07-consola-codigo-equivalente.png|Consola · Código equivalente (JSON) de la VM|18/10/2026 22:51:57
08-consola-observabilidad.png|Consola · Pestaña Observabilidad: uso de CPU de la VM|18/10/2026 22:54:13
09-consola-firewall.png|Consola · Regla de firewall ticochea-i1l1-http (tcp:80) en la red default|18/10/2026 22:54:41
10-navegador-pagina-nginx.png|Navegador · http://34.30.230.138 — página servida por NGINX con nombre, código, curso y docente|18/10/2026 22:50:50
11-cloudshell-limpieza.png|Cloud Shell · ./lab down borra las 2 VMs y la regla de firewall|18/10/2026 22:55:33
12-consola-sin-recursos.png|Consola · Instancias de VM vacía después de la limpieza|18/10/2026 22:57:37
