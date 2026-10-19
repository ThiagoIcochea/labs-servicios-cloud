resource "google_compute_instance" "vm" {
  for_each                  = toset(var.instancias)
  name                      = "${var.prefijo}-tf-instance-${each.key}"
  zone                      = var.zona
  machine_type              = var.tipo_maquina
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network    = var.red
    subnetwork = var.subred == "" ? null : var.subred
  }

  labels = { alumno = var.prefijo, seccion = var.seccion, curso = "servicios-cloud", lab = "i4l5" }

  metadata = {
    alumno = var.nombre
  }

  lifecycle {
    # Las VMs importadas tienen detalles del disco que no se gestionan aquí
    ignore_changes = [boot_disk, metadata["ssh-keys"]]
  }
}
