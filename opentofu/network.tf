# Red NAT con DHCP: acceso desde el anfitrión y salida a internet
resource "libvirt_network" "p1-red-nat" {
  name      = "p1-red-nat"
  mode      = "nat"
  domain    = "proyecto.local"
  addresses = ["192.168.140.0/24"]
  dhcp { enabled = true }
  dns { enabled = true }
  autostart = true
}

# Red de datos muy aislada (sin IP en el anfitrión): solo web y bd,
# con direcciones estáticas en 10.10.10.0/24 (cloud-init/network-config-*.yaml)
resource "libvirt_network" "p1-red-datos" {
  name      = "p1-red-datos"
  mode      = "none"
  autostart = true
}
