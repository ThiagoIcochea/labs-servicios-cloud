# Guía de Google Cloud para el grupo

## 1. Proyectos

| Proyecto | ID | Uso |
|---|---|---|
| Servicios Cloud 45104 Labs | `sc-45104-labs` | Los 21 labs de cada integrante |
| Makip Te Crea Plataforma Cloud | `sc-45104-makip` | Proyecto grupal Makip Te Crea (repo `crm-cloud-makip`) |

Ambos están vinculados a la misma cuenta de facturación con la **prueba gratuita** (≈ US$ 300). Separarlos permite ver el gasto de cada uno en **Facturación → Informes** y borrar los labs sin tocar Makip.

## 2. Agregar a un integrante (lo hace el dueño del proyecto)
**Consola:** IAM y administración → IAM → **Otorgar acceso** → correo de Google → rol **Editor** → Guardar.

**Cloud Shell:**
```bash
for P in sc-45104-labs sc-45104-makip; do
  gcloud projects add-iam-policy-binding $P --member=user:CORREO@gmail.com --role=roles/editor --condition=None
done
```
- Nunca dar *Propietario* ni roles de la cuenta de facturación.
- Con *Editor* el integrante crea recursos, pero **no ve** la tarjeta ni la cuenta de facturación.
- Todo lo que se crea en el proyecto se descuenta del crédito del dueño: por eso cada lab se borra al terminar.

## 3. Replicar en un proyecto propio (opcional)
Si un integrante prefiere usar **su propia prueba gratuita**:
1. Activa la prueba en <https://console.cloud.google.com/freetrial>.
2. Crea un proyecto y ejecuta en Cloud Shell:
   ```bash
   git clone https://github.com/ThiagoIcochea/labs-servicios-cloud.git && cd labs-servicios-cloud
   export PROJECT_ID=<tu-proyecto>
   gcloud config set project $PROJECT_ID
   bash scripts/preparar-proyecto.sh $PROJECT_ID
   ./lab <alumno> i1-l1 up
   ```
Todos los scripts usan la variable `PROJECT_ID`, así que funcionan igual en cualquier proyecto.

## 4. Cómo tomar buenas evidencias
- Que se vea **la cuenta** (avatar arriba a la derecha) y **el proyecto** en la barra superior.
- En Cloud Shell, que se vea el **recuadro del alumno** que imprime cada lab (nombre, curso, sección, fecha).
- Captura el **resultado final** (página con tu nombre, recurso en verde, `Apply complete!`, etc.).
- Guarda en `alumnos/<alumno>/evidencias/<lab>/` con nombres como `01-cloudshell.png`, `02-consola.png`, `video.gif`.

## 5. Control de costos
- **Facturación → Presupuestos y alertas**: presupuesto recomendado de US$ 50 con alertas al 50 %, 90 % y 100 %.
- Revisión rápida de que no quede nada encendido:
  ```bash
  gcloud compute instances list
  gcloud container clusters list
  gcloud sql instances list
  gcloud compute forwarding-rules list
  ```
