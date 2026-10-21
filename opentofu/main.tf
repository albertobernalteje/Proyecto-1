terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.7.0"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

# ----------------------------------------------------------------------
# REDES
# ----------------------------------------------------------------------

# 1. Red NAT con DHCP
resource "libvirt_network" "red_nat" {
  name      = "red_nat_proyecto"
  mode      = "nat"
  domain    = "proyecto.local"
  addresses = ["192.168.122.0/24"]
  dhcp {
    enabled = true
  }
}

# 2. Red de datos aislada
resource "libvirt_network" "red_datos" {
  name      = "red_datos_proyecto"
  mode      = "none"
  addresses = ["10.0.0.0/24"]
  dhcp {
    enabled = false
  }
}

# ----------------------------------------------------------------------
# DISCOS
# ----------------------------------------------------------------------
resource "libvirt_volume" "disco_base" {
  name   = "debian13-base.qcow2"
  source = var.base_image_path
}

resource "libvirt_volume" "disco_web" {
  name           = "disco_web.qcow2"
  base_volume_id = libvirt_volume.disco_base.id
  capacity       = 10737418240
}

resource "libvirt_volume" "disco_bd" {
  name           = "disco_bd.qcow2"
  base_volume_id = libvirt_volume.disco_base.id
  capacity       = 10737418240
}

# ----------------------------------------------------------------------
# MÁQUINAS VIRTUALES
# ----------------------------------------------------------------------

# Servidor WEB
resource "libvirt_domain" "web" {
  name   = "web"
  memory = var.memory_web
  vcpu   = 2

  disk {
    volume_id = libvirt_volume.disco_web.id
  }

  # Interfaz 1: Red NAT
  network_interface {
    network_id     = libvirt_network.red_nat.id
    wait_for_lease = true
  }

  # Interfaz 2: Red de datos aislada
  network_interface {
    network_id = libvirt_network.red_datos.id
    addresses  = ["10.0.0.10"]
  }

  graphics {
    type        = "spice"
    listen_type = "address"
  }
}

# Servidor BD
resource "libvirt_domain" "bd" {
  name   = "bd"
  memory = var.memory_bd
  vcpu   = 2

  disk {
    volume_id = libvirt_volume.disco_bd.id
  }

  # Interfaz 1: Red NAT
  network_interface {
    network_id     = libvirt_network.red_nat.id
    wait_for_lease = true
  }

  # Interfaz 2: Red de datos aislada
  network_interface {
    network_id = libvirt_network.red_datos.id
    addresses  = ["10.0.0.20"]
  }

  graphics {
    type        = "spice"
    listen_type = "address"
  }
}

# ----------------------------------------------------------------------
# GENERACIÓN AUTOMÁTICA DEL INVENTARIO DE ANSIBLE
# ----------------------------------------------------------------------
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    ip_web = libvirt_domain.web.network_interface[0].addresses[0]
    ip_bd  = libvirt_domain.bd.network_interface[0].addresses[0]
  })
  filename = "${path.module}/../ansible/hosts"
}
