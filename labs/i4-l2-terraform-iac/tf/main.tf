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
  etiquetas = { alumno = var.prefijo, seccion = var.seccion, curso = "servicios-cloud", lab = "i4l2" }
  imagen    = var.etapa >= 3 ? "ubuntu-os-cloud/ubuntu-2204-lts" : "debian-cloud/debian-12"
  tags      = var.etapa >= 2 ? ["${var.prefijo}-web", "${var.prefijo}-dev"] : ["${var.prefijo}-web"]
}

# Red VPC propia
resource "google_compute_network" "red" {
  name                    = "${var.prefijo}-i4l2-red"
  auto_create_subnetworks = true
  description             = "Red del lab i4-l2 de ${var.nombre}"
}

# IP estática (dependencia IMPLÍCITA: la VM la referencia)
resource "google_compute_address" "ip_estatica" {
  name   = "${var.prefijo}-i4l2-ip"
  region = var.region
  labels = local.etiquetas
}

# Bucket (dependencia EXPLÍCITA: la VM declara depends_on)
resource "google_storage_bucket" "datos" {
  name                        = "${var.project_id}-${var.prefijo}-i4l2"
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true
  labels                      = local.etiquetas
}

resource "google_compute_instance" "vm" {
  name                      = "${var.prefijo}-i4l2-instancia"
  machine_type              = "e2-micro"
  tags                      = local.tags
  allow_stopping_for_update = true
  labels                    = local.etiquetas

  boot_disk {
    initialize_params {
      image = local.imagen
      size  = 10
    }
  }

  network_interface {
    network = google_compute_network.red.self_link
    access_config {
      nat_ip = google_compute_address.ip_estatica.address
    }
  }

  metadata = {
    alumno = var.nombre
    etapa  = tostring(var.etapa)
  }

  depends_on = [google_storage_bucket.datos]
}

resource "google_storage_bucket_object" "evidencia" {
  name    = "evidencia-${var.prefijo}.txt"
  bucket  = google_storage_bucket.datos.name
  content = "Alumno: ${var.nombre}\nCódigo: ${var.codigo}\nCurso: Servicios Cloud - Sección ${var.seccion}\nVM: ${google_compute_instance.vm.name}\nEtapa: ${var.etapa}\n"
}
