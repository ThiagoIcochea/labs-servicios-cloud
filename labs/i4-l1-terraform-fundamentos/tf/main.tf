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

resource "google_compute_instance" "vm_terraform" {
  name         = "${var.prefijo}-i4l1-terraform"
  machine_type = "e2-micro"
  tags         = ["${var.prefijo}-i4l1"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 10
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  labels = {
    alumno  = var.prefijo
    seccion = var.seccion
    curso   = "servicios-cloud"
    lab     = "i4l1"
  }

  metadata = {
    alumno  = var.nombre
    codigo  = var.codigo
    seccion = var.seccion
  }
}
