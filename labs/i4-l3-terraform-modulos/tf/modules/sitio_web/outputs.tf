output "bucket" { value = google_storage_bucket.sitio.name }
output "url" { value = "https://storage.googleapis.com/${google_storage_bucket.sitio.name}/index.html" }
