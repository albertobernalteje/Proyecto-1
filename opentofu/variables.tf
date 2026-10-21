variable "memory_web" {
  description = "Memoria RAM para el servidor web"
  type        = number
  default     = 2048
}

variable "memory_bd" {
  description = "Memoria RAM para el servidor de base de datos"
  type        = number
  default     = 2048
}

variable "base_image_path" {
  description = "Ruta a la imagen base de Debian 13 en el sistema"
  type        = string
  default     = "/var/lib/libvirt/images/debian13-base.qcow2"
}
