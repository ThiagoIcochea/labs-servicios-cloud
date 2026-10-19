01-cloudshell-inicio.png|Cloud Shell · inicio del lab y creación de los servidores web ticochea-www1..3 (sin IP externa)|18/10/2026 23:12:47
02-cloudshell-balanceador-red.png|Cloud Shell · IP regional, health check, target pool ticochea-www-pool y regla de reenvío|18/10/2026 23:13:59
03-cloudshell-balanceador-http.png|Cloud Shell · firewall para health checks, IP global, backend service y URL map del balanceador HTTP|18/10/2026 23:15:48
04-cloudshell-pruebas.png|Cloud Shell · las respuestas alternan entre www1/www2/www3 y entre las VMs del MIG|18/10/2026 23:20:33
05-consola-instancias.png|Consola · 5 VMs: 3 servidores www y 2 VMs del grupo administrado|18/10/2026 23:15:02
06-consola-grupo-instancias.png|Consola · grupo administrado ticochea-lb-backend-group (2 instancias en buen estado)|18/10/2026 23:15:22
07-consola-balanceadores.png|Consola · Balanceo de cargas: ticochea-web-map-http (HTTP) y ticochea-www-pool (red)|18/10/2026 23:18:44
08-consola-backend-saludable.png|Consola · backend del balanceador HTTP: 2 de 2 instancias en buen estado|18/10/2026 23:19:35
09-navegador-red-www2.png|Navegador · balanceador de red responde desde ticochea-www2|18/10/2026 23:17:26
10-navegador-red-www3.png|Navegador · nueva petición al balanceador de red responde desde ticochea-www3|18/10/2026 23:17:26
11-navegador-http-mig.png|Navegador · balanceador HTTP (136.82.37.235) responde desde una VM del MIG|18/10/2026 23:20:15
12-cloudshell-limpieza.png|Cloud Shell · ./lab down elimina balanceadores, MIG, plantilla, VMs, IPs y firewall; verificación vacía|18/10/2026 23:27:32
13-consola-sin-balanceadores.png|Consola · Balanceo de cargas sin recursos después de la limpieza|18/10/2026 23:27:32
