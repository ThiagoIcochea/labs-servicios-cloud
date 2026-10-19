output "alumno" { value = "${var.nombre} - Sección ${var.seccion}" }
output "etapa" { value = var.etapa }
output "instancias" { value = module.instances.resumen }
output "bucket" { value = module.storage.bucket }
