# Laboratorios de Servicios Cloud — Sección 45104 (UTP)

Laboratorios del **Google Cloud Engineering Certificate** replicados en un proyecto propio de Google Cloud, **con los datos de cada integrante** y con **limpieza automática** para no gastar créditos.

| | |
|---|---|
| **Universidad** | Universidad Tecnológica del Perú (UTP) |
| **Curso** | Servicios Cloud — Sección **45104** |
| **Docente** | Eleodoro Orbegoso Carrera |
| **Programa** | Google Cloud Engineering Certificate · 4 insignias de habilidad · **21 labs** |
| **Proyecto GCP** | `sc-45104-labs` (labs) · `sc-45104-makip` (proyecto Makip Te Crea, aparte) |

## Integrantes

| Integrante | Carpeta | Prefijo de recursos |
|---|---|---|
| Thiago Paolo Icochea Rodriguez (U22330428) | [alumnos/thiago-icochea](alumnos/thiago-icochea) | `ticochea` |
| Carlos Enrique Giussepe Gonzales Aguilar | [alumnos/carlos-gonzales](alumnos/carlos-gonzales) | `cgonzales` |
| Eddyson Cesar Huamani Pereira | [alumnos/eddyson-huamani](alumnos/eddyson-huamani) | `ehuamani` |
| Emmanuel Misael Torres Centeno | [alumnos/emmanuel-torres](alumnos/emmanuel-torres) | `etorres` |
| Huber Eduardo Remuzgo Tovar | [alumnos/huber-remuzgo](alumnos/huber-remuzgo) | `hremuzgo` |
| Karen Meylin Quispe Saavedra | [alumnos/karen-quispe](alumnos/karen-quispe) | `kquispe` |

Cada integrante trabaja **solo con sus recursos**: todo lo que crea lleva su prefijo en el nombre y las etiquetas `alumno=<prefijo>`, `seccion=45104`, `lab=<lab>`. Las páginas web, archivos, mensajes, dashboards y salidas de cada lab muestran su **nombre completo, curso y sección**.

## Los 21 laboratorios

| Insignia | Lab | Carpeta |
|---|---|---|
| **1 · Implement Load Balancing on Compute Engine** | Lab 1 · Creando una máquina virtual | [i1-l1-vm-nginx](labs/i1-l1-vm-nginx) |
| | Lab 2 · Cloud Shell y gcloud | [i1-l2-cloudshell-gcloud](labs/i1-l2-cloudshell-gcloud) |
| | Lab 3 · Balanceadores de carga de red y HTTP | [i1-l3-balanceadores](labs/i1-l3-balanceadores) |
| | Desafío | [i1-l4-desafio-load-balancing](labs/i1-l4-desafio-load-balancing) |
| **2 · Set Up an App Dev Environment on Google Cloud** | Lab 1 · Cloud Storage (CLI) | [i2-l1-cloud-storage](labs/i2-l1-cloud-storage) |
| | Lab 2 · Cloud IAM | [i2-l2-cloud-iam](labs/i2-l2-cloud-iam) |
| | Lab 3 · Cloud Monitoring | [i2-l3-cloud-monitoring](labs/i2-l3-cloud-monitoring) |
| | Lab 4 · Cloud Functions (CLI) | [i2-l4-cloud-functions](labs/i2-l4-cloud-functions) |
| | Lab 5 · Pub/Sub (CLI) | [i2-l5-pubsub](labs/i2-l5-pubsub) |
| | Desafío | [i2-l6-desafio-app-dev](labs/i2-l6-desafio-app-dev) |
| **3 · Develop your Google Cloud Network** | Lab 1 · IAM (roles personalizados) | [i3-l1-iam-roles](labs/i3-l1-iam-roles) |
| | Lab 2 · SQL para BigQuery y Cloud SQL | [i3-l2-sql-bigquery-cloudsql](labs/i3-l2-sql-bigquery-cloudsql) |
| | Lab 3 · Redes VPC múltiples | [i3-l3-multiples-vpc](labs/i3-l3-multiples-vpc) |
| | Lab 4 · Monitoreo con logs | [i3-l4-monitoreo-logs](labs/i3-l4-monitoreo-logs) |
| | Lab 5 · Despliegues en GKE | [i3-l5-gke-deployments](labs/i3-l5-gke-deployments) |
| | Desafío | [i3-l6-desafio-network](labs/i3-l6-desafio-network) |
| **4 · Build Infrastructure with Terraform on Google Cloud** | Lab 1 · Fundamentos de Terraform | [i4-l1-terraform-fundamentos](labs/i4-l1-terraform-fundamentos) |
| | Lab 2 · Infraestructura como código | [i4-l2-terraform-iac](labs/i4-l2-terraform-iac) |
| | Lab 3 · Módulos de Terraform | [i4-l3-terraform-modulos](labs/i4-l3-terraform-modulos) |
| | Lab 4 · Estado de Terraform | [i4-l4-terraform-estado](labs/i4-l4-terraform-estado) |
| | Desafío | [i4-l5-desafio-terraform](labs/i4-l5-desafio-terraform) |

> Los labs de IAM y Monitoring aparecen en las insignias 2 y 3. Para que la evidencia no se repita, en la insignia 3 se hacen **variantes**: rol personalizado (i3-l1) y logs + métrica basada en logs (i3-l4).

## Cómo correrlo (paso a paso)

### 1. Antes de empezar (una sola vez)
- Pide al dueño del proyecto que te agregue como **Editor** de `sc-45104-labs` con tu correo de Google (ver [docs/guia-google-cloud.md](docs/guia-google-cloud.md)).
- Entra a <https://console.cloud.google.com> con ese correo y selecciona el proyecto **Servicios Cloud 45104 Labs**.

### 2. Abrir Cloud Shell y clonar el repositorio
Abre **Cloud Shell** (ícono `>_` arriba a la derecha) y ejecuta:
```bash
git clone https://github.com/ThiagoIcochea/labs-servicios-cloud.git
cd labs-servicios-cloud
gcloud config set project sc-45104-labs
bash scripts/preparar-proyecto.sh        # habilita las APIs (solo la primera vez)
```

### 3. Ver tu nombre de alumno y la lista de labs
```bash
./lab alumnos      # tu "alumno" es el slug: thiago-icochea, karen-quispe, …
./lab lista
```

### 4. Ejecutar un lab, tomar evidencias y BORRAR
```bash
./lab <alumno> i1-l1 info    # leer qué hace el lab y qué capturas tomar
./lab <alumno> i1-l1 up      # crear todo (con tu nombre, código y sección)
#   … toma tus capturas en Cloud Shell y en la consola …
./lab <alumno> i1-l1 down    # borrar TODO lo del lab
```
Ejemplo real: `./lab karen-quispe i2-l5 up`

Todo lo que sale en la terminal se guarda en `alumnos/<alumno>/evidencias/<lab>/salida-up-<fecha>.log`.

### 5. Subir tus evidencias
Guarda tus capturas y videos en `alumnos/<alumno>/evidencias/<lab>/` y súbelos con un Pull Request (o pásaselos al responsable del repo).

### Si algo quedó a medias
```bash
./lab <alumno> <lab> down                 # se puede repetir sin problema
bash scripts/limpiar-todo.sh <prefijo>    # borra TODO lo que tenga tu prefijo
```

## Reglas para no gastar créditos
1. **Siempre** ejecuta `down` al terminar cada lab.
2. La prueba gratuita permite **8 vCPU encendidas a la vez** en el proyecto: los labs con varias VMs o GKE (`i1-l3`, `i1-l4`, `i3-l3`, `i3-l5`, `i3-l6`) se hacen **de a uno por turno**.
3. Los labs ligeros (Storage, IAM, Pub/Sub, Functions, BigQuery, Terraform) los pueden hacer varios a la vez.
4. Costo total estimado de los 21 labs por integrante: **menos de US$ 1** si se borra al terminar.

## Estructura del repositorio
```
├── lab                      # lanzador: ./lab <alumno> <lab> up|down|info
├── config/
│   ├── alumnos.csv          # integrantes, prefijos y correos
│   └── curso.env            # curso, sección, docente, proyecto y región
├── lib/
│   ├── comun.sh             # funciones comunes (banner, etiquetas, páginas con los datos del alumno…)
│   └── terraform.sh         # utilidades para los labs de Terraform
├── labs/<lab>/              # up.sh, down.sh, README.md (+ código de funciones o Terraform)
├── alumnos/<alumno>/        # README con el avance y evidencias/ por lab
├── scripts/                 # preparar-proyecto.sh, limpiar-todo.sh
└── docs/                    # guía de Google Cloud y documento de evidencias
```
