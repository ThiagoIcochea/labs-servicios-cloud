output "alumno" { value = "${var.nombre} (${var.codigo}) - Sección ${var.seccion}" }
output "ip_estatica" { value = google_compute_address.ip_estatica.address }
output "imagen_actual" { value = local.imagen }
output "tags_actuales" { value = local.tags }
output "bucket" { value = google_storage_bucket.datos.url }
