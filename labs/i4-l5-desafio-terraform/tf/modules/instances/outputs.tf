output "resumen" {
  value = { for k, v in google_compute_instance.vm : v.name => "${v.machine_type} · ${v.network_interface[0].network}" }
}
