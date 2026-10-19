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

# Bucket que guardará el estado REMOTO de Terraform
resource "google_storage_bucket" "estado" {
  name                        = "${var.project_id}-${var.prefijo}-i4l4-tfstate"
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true
  versioning { enabled = true }
  labels = { alumno = var.prefijo, seccion = var.seccion, curso = "servicios-cloud", lab = "i4l4" }
}
