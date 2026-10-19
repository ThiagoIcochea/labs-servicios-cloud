output "alumno" { value = "${var.nombre} (${var.codigo}) - Sección ${var.seccion}" }
output "bucket_estado" { value = google_storage_bucket.estado.name }
