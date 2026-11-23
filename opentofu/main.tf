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
# web2 — Debian 13 (segundo servidor web, detrás del balanceador de web)
##############################################

resource "libvirt_volume" "p1-web2-disk" {
  name             = "p1-web2.qcow2"
  pool             = var.libvirt_pool_name
  base_volume_name = var.base_image_debian
  base_volume_pool = var.libvirt_pool_name
  format           = "qcow2"
}

resource "libvirt_cloudinit_disk" "p1-web2-cloudinit" {
  name = "p1-web2-cloudinit.iso"
  pool = var.libvirt_pool_name
  user_data = templatefile("${path.module}/cloud-init/user-data.yaml", {
    hostname = "web2"
    usuario  = "debian"
    clave    = trimspace(file(pathexpand(var.ssh_public_key)))
  })
  network_config = file("${path.module}/cloud-init/network-config-web2.yaml")
}

resource "libvirt_domain" "p1-web2" {
  name   = "p1-web2"
  memory = var.memory_web2
  vcpu   = 1

  # Solo red de datos (IP estática 10.10.10.11): le llegan las peticiones
  # desde el balanceador de web y sale a internet a través de web
  network_interface {
    network_id = libvirt_network.p1-red-datos.id
  }

  disk { volume_id = libvirt_volume.p1-web2-disk.id }
  cloudinit = libvirt_cloudinit_disk.p1-web2-cloudinit.id

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

  # Solo red de datos (IP estática 10.10.10.20): sale a internet a través de web
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

##############################################
# backup — Debian 13 (copias de seguridad de la base de datos)
##############################################

resource "libvirt_volume" "p1-backup-disk" {
  name             = "p1-backup.qcow2"
  pool             = var.libvirt_pool_name
  base_volume_name = var.base_image_debian
  base_volume_pool = var.libvirt_pool_name
  format           = "qcow2"
}

resource "libvirt_cloudinit_disk" "p1-backup-cloudinit" {
  name = "p1-backup-cloudinit.iso"
  pool = var.libvirt_pool_name
  user_data = templatefile("${path.module}/cloud-init/user-data.yaml", {
    hostname = "backup"
    usuario  = "debian"
    clave    = trimspace(file(pathexpand(var.ssh_public_key)))
  })
  network_config = file("${path.module}/cloud-init/network-config-backup.yaml")
}

resource "libvirt_domain" "p1-backup" {
  name   = "p1-backup"
  memory = var.memory_backup
  vcpu   = 1

  # Solo red de datos (IP estática 10.10.10.30): sale a internet a través de web
  network_interface {
    network_id = libvirt_network.p1-red-datos.id
  }

  disk { volume_id = libvirt_volume.p1-backup-disk.id }
  cloudinit = libvirt_cloudinit_disk.p1-backup-cloudinit.id

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}
