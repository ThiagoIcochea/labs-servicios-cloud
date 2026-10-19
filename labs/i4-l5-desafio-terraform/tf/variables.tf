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
variable "codigo" { type = string }
variable "seccion" { type = string }
variable "etapa" {
  description = "1 = importar VMs + bucket; 3 = cambiar tipo y agregar 3ra VM; 4 = quitar 3ra VM, VPC y firewall"
  type        = number
  default     = 1
}
