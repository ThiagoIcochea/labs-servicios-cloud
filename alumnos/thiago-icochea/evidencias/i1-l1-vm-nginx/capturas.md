01-cloudshell-inicio.png|Cloud Shell · inicio del lab con los datos del alumno y la regla de firewall creada
02-cloudshell-vms-creadas.png|Cloud Shell · VMs ticochea-i1l1-web y ticochea-i1l1-gcelab2 creadas con gcloud y filtradas por etiqueta alumno=ticochea
03-cloudshell-resultado.png|Cloud Shell · NGINX responde con el nombre del alumno desde la VM ticochea-i1l1-web
04-consola-instancias.png|Consola · Compute Engine > Instancias de VM con las 2 VMs del alumno (prefijo ticochea)
05-consola-detalle-vm.png|Consola · Detalle de la VM ticochea-i1l1-web: información básica
06-consola-etiquetas.png|Consola · Etiquetas de la VM: alumno=ticochea, seccion=45104, curso=servicios-cloud, lab=i1l1
07-consola-codigo-equivalente.png|Consola · Código equivalente (JSON) de la VM creada
08-consola-observabilidad.png|Consola · Pestaña Observabilidad: uso de CPU de la VM
09-consola-firewall.png|Consola · Regla de firewall ticochea-i1l1-http (tcp:80) aplicada a la etiqueta de red del lab
10-navegador-pagina-nginx.png|Navegador · http://34.30.230.138 — página NGINX personalizada con nombre y código del alumno
