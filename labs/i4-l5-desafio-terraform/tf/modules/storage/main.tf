# Tarea 3: bucket para el backend remoto
resource "google_storage_bucket" "backend" {
  name                        = "${var.project_id}-${var.prefijo}-i4l5-backend"
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true
  labels                      = { alumno = var.prefijo, seccion = var.seccion, curso = "servicios-cloud", lab = "i4l5" }
}
