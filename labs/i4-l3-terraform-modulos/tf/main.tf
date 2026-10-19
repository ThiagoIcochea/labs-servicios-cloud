terraform {
  required_providers {
    google = { source = "hashicorp/google", version = "~> 6.0" }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# 1) Módulo PÚBLICO del Terraform Registry: red VPC con 2 subredes
module "red" {
  source  = "terraform-google-modules/network/google"
  version = "~> 10.0"

  project_id   = var.project_id
  network_name = "${var.prefijo}-i4l3-red"
  routing_mode = "GLOBAL"
  description  = "Red creada con un módulo público - ${var.nombre}"

  subnets = [
    { subnet_name = "${var.prefijo}-subred-01", subnet_ip = "10.10.10.0/24", subnet_region = var.region },
    { subnet_name = "${var.prefijo}-subred-02", subnet_ip = "10.10.20.0/24", subnet_region = var.region, subnet_private_access = "true" },
  ]
}

# 2) Módulo PROPIO (local): sitio web estático en Cloud Storage con los datos del alumno
module "sitio_web" {
  source     = "./modules/sitio_web"
  project_id = var.project_id
  prefijo    = var.prefijo
  nombre     = var.nombre
  seccion    = var.seccion
}
