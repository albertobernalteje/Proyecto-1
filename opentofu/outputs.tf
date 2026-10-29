# ip_nat por DHCP; ip_datos estática (cloud-init/network-config-*.yaml)
output "web" {
  value = {
    nombre   = libvirt_domain.p1-web.name
    ip_nat   = try(libvirt_domain.p1-web.network_interface[0].addresses[0], "No disponible")
    ip_datos = "10.10.10.10"
  }
}

output "bd" {
  value = {
    nombre   = libvirt_domain.p1-bd.name
    ip_nat   = try(libvirt_domain.p1-bd.network_interface[0].addresses[0], "No disponible")
    ip_datos = "10.10.10.20"
  }
}
