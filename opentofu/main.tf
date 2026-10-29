##############################################
# web — Debian 13
##############################################

# Clon ligero sobre la imagen base: solo almacena los cambios
resource "libvirt_volume" "p1-web-disk" {
  name             = "p1-web.qcow2"
  pool             = var.libvirt_pool_name
  base_volume_name = var.base_image_debian
  base_volume_pool = var.libvirt_pool_name
  format           = "qcow2"
}

resource "libvirt_cloudinit_disk" "p1-web-cloudinit" {
  name = "p1-web-cloudinit.iso"
  pool = var.libvirt_pool_name
  user_data = templatefile("${path.module}/cloud-init/user-data.yaml", {
    hostname = "web"
    usuario  = "debian"
    clave    = trimspace(file(pathexpand(var.ssh_public_key)))
  })
  network_config = file("${path.module}/cloud-init/network-config-web.yaml")
}

resource "libvirt_domain" "p1-web" {
  name   = "p1-web"
  memory = var.memory_web
  vcpu   = 2

  # Red 1: NAT con DHCP (acceso desde el anfitrión)
  network_interface {
    network_id     = libvirt_network.p1-red-nat.id
    wait_for_lease = true
  }

  # Red 2: datos (IP estática 10.10.10.10)
  network_interface {
    network_id = libvirt_network.p1-red-datos.id
  }

  disk { volume_id = libvirt_volume.p1-web-disk.id }
  cloudinit = libvirt_cloudinit_disk.p1-web-cloudinit.id

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}

##############################################
# bd — Ubuntu 26.04
##############################################

resource "libvirt_volume" "p1-bd-disk" {
  name             = "p1-bd.qcow2"
  pool             = var.libvirt_pool_name
  base_volume_name = var.base_image_ubuntu
  base_volume_pool = var.libvirt_pool_name
  format           = "qcow2"
}

resource "libvirt_cloudinit_disk" "p1-bd-cloudinit" {
  name = "p1-bd-cloudinit.iso"
  pool = var.libvirt_pool_name
  user_data = templatefile("${path.module}/cloud-init/user-data.yaml", {
    hostname = "bd"
    usuario  = "ubuntu"
    clave    = trimspace(file(pathexpand(var.ssh_public_key)))
  })
  network_config = file("${path.module}/cloud-init/network-config-bd.yaml")
}

resource "libvirt_domain" "p1-bd" {
  name   = "p1-bd"
  memory = var.memory_bd
  vcpu   = 2

  # Red 1: NAT con DHCP (salida a internet para instalar paquetes)
  network_interface {
    network_id     = libvirt_network.p1-red-nat.id
    wait_for_lease = true
  }

  # Red 2: datos (IP estática 10.10.10.20)
  network_interface {
    network_id = libvirt_network.p1-red-datos.id
  }

  disk { volume_id = libvirt_volume.p1-bd-disk.id }
  cloudinit = libvirt_cloudinit_disk.p1-bd-cloudinit.id

  # Ubuntu no termina de arrancar sin consola serie
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}
