# ip_nat por DHCP; ip_datos estática (cloud-init/network-config-*.yaml)
output "web" {
  value = {
    nombre   = libvirt_domain.p1-web.name
    ip_nat   = try(libvirt_domain.p1-web.network_interface[0].addresses[0], "No disponible")
    ip_datos = "10.10.10.10"
  }
}

# bd ya no está en la red NAT: sale a internet a través de web
output "bd" {
  value = {
    nombre   = libvirt_domain.p1-bd.name
    ip_datos = "10.10.10.20"
    gateway  = "10.10.10.10"
  }
}

# backup solo está en la red de datos, como bd
output "backup" {
  value = {
    nombre   = libvirt_domain.p1-backup.name
    ip_datos = "10.10.10.30"
    gateway  = "10.10.10.10"
  }
}
