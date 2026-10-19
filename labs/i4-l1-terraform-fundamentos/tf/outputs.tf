output "alumno" { value = "${var.nombre} (${var.codigo}) - Sección ${var.seccion}" }
output "vm_nombre" { value = google_compute_instance.vm_terraform.name }
output "vm_ip_externa" { value = google_compute_instance.vm_terraform.network_interface[0].access_config[0].nat_ip }
