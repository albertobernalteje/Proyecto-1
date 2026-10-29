# Pool de almacenamiento donde están las imágenes base y se crean los clones
variable "libvirt_pool_name" {
  type        = string
  description = "Nombre del pool de almacenamiento libvirt."
  default     = "default"
}

# Imágenes base (qcow2) ya disponibles en el pool: se usan como backing store
variable "base_image_debian" {
  type        = string
  description = "Imagen base Debian 13 para el servidor web."
  default     = "debian13-base.qcow2"
}

variable "base_image_ubuntu" {
  type        = string
  description = "Imagen base Ubuntu 26.04 para el servidor de base de datos."
  default     = "ubuntu2604-base.qcow2"
}

variable "memory_web" {
  type        = number
  description = "Memoria RAM (MB) del servidor web."
  default     = 1024
}

variable "memory_bd" {
  type        = number
  description = "Memoria RAM (MB) del servidor de base de datos."
  default     = 1024
}

# Clave pública que cloud-init mete en las máquinas para que entre Ansible
variable "ssh_public_key" {
  type        = string
  description = "Ruta a la clave pública SSH del equipo."
  default     = "~/.ssh/id_ed25519.pub"
}
