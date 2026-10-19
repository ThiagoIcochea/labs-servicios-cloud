terraform {
  required_providers {
    google = { source = "hashicorp/google", version = "~> 6.0" }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zona
}

locals {
  tipo_maquina = var.etapa >= 3 ? "e2-small" : "e2-micro"
  # instancia 3 solo existe en la etapa 3 (se agrega y luego se retira)
  instancias = var.etapa == 3 ? ["1", "2", "3"] : ["1", "2"]
}

# Tarea 2: importar las VMs creadas fuera de Terraform
import {
  for_each = toset(["1", "2"])
  to       = module.instances.google_compute_instance.vm[each.key]
  id       = "projects/${var.project_id}/zones/${var.zona}/instances/${var.prefijo}-tf-instance-${each.key}"
}

module "instances" {
  source       = "./modules/instances"
  prefijo      = var.prefijo
  nombre       = var.nombre
  seccion      = var.seccion
  zona         = var.zona
  tipo_maquina = local.tipo_maquina
  instancias   = local.instancias
  # Tarea 6: en la etapa 4 las VMs pasan a las subredes de la VPC del módulo
  red    = var.etapa >= 4 ? module.vpc[0].network_name : "default"
  subred = var.etapa >= 4 ? module.vpc[0].subnets_names[0] : ""
}

module "storage" {
  source     = "./modules/storage"
  project_id = var.project_id
  prefijo    = var.prefijo
  seccion    = var.seccion
}

# Tarea 5: VPC con el módulo público, 2 subredes
module "vpc" {
  count        = var.etapa >= 4 ? 1 : 0
  source       = "terraform-google-modules/network/google"
  version      = "~> 10.0"
  project_id   = var.project_id
  network_name = "${var.prefijo}-tf-vpc"
  routing_mode = "GLOBAL"
  subnets = [
    { subnet_name = "${var.prefijo}-subnet-01", subnet_ip = "10.10.10.0/24", subnet_region = var.region },
    { subnet_name = "${var.prefijo}-subnet-02", subnet_ip = "10.10.20.0/24", subnet_region = var.region },
  ]
}

# Tarea 7: firewall que permite HTTP en la VPC
resource "google_compute_firewall" "tf_firewall" {
  count         = var.etapa >= 4 ? 1 : 0
  name          = "${var.prefijo}-tf-firewall"
  network       = module.vpc[0].network_self_link
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  description = "Firewall del desafío Terraform de ${var.nombre}"
}
