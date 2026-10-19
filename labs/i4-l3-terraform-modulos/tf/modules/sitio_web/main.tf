resource "google_storage_bucket" "sitio" {
  name                        = "${var.project_id}-${var.prefijo}-i4l3-web"
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true
  labels                      = { alumno = var.prefijo, seccion = var.seccion, curso = "servicios-cloud", lab = "i4l3" }

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

resource "google_storage_bucket_iam_member" "publico" {
  bucket = google_storage_bucket.sitio.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_storage_bucket_object" "index" {
  name          = "index.html"
  bucket        = google_storage_bucket.sitio.name
  content_type  = "text/html; charset=utf-8"
  cache_control = "no-store"
  content       = <<-HTML
    <!doctype html><html lang="es"><head><meta charset="utf-8"><title>Módulo Terraform - ${var.nombre}</title></head>
    <body style="font-family:Arial;background:#f3e8fd;padding:40px">
    <h1 style="color:#7627bb">Sitio creado con un módulo propio de Terraform</h1>
    <p><b>Alumno:</b> ${var.nombre}<br><b>Código:</b> ${var.codigo}<br><b>Curso:</b> Servicios Cloud - Sección ${var.seccion}<br>
    <b>Módulo:</b> ./modules/sitio_web · Insignia 4 Lab 3</p></body></html>
  HTML
}

resource "google_storage_bucket_object" "no_encontrado" {
  name         = "404.html"
  bucket       = google_storage_bucket.sitio.name
  content_type = "text/html; charset=utf-8"
  content      = "<h1>404 - Página no encontrada (sitio de ${var.nombre})</h1>"
}
