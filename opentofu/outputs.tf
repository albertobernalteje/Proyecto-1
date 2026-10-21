output "ip_web_nat" {
  value       = libvirt_domain.web.network_interface[0].addresses[0]
  description = "IP del servidor web en la red NAT"
}

output "ip_bd_nat" {
  value       = libvirt_domain.bd.network_interface[0].addresses[0]
  description = "IP del servidor de BD en la red NAT"
}
