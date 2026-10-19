variable "project_id" { type = string }
variable "region" {
  type    = string
  default = "us-central1"
}
variable "zona" {
  type    = string
  default = "us-central1-a"
}
variable "prefijo" { type = string }
variable "nombre" { type = string }
variable "seccion" { type = string }
variable "etapa" {
  description = "1 = crear, 2 = cambio en el lugar (tags/metadatos), 3 = cambio destructivo (imagen)"
  type        = number
  default     = 1
}
