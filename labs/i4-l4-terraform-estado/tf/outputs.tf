output "alumno" { value = "${var.nombre} - Sección ${var.seccion}" }
output "bucket_estado" { value = google_storage_bucket.estado.name }
