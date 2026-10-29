# Genera el inventario de Ansible (ansible/hosts) con las IP del escenario
resource "local_file" "inventario" {
  filename        = "${path.module}/../ansible/hosts"
  file_permission = "0644"
  content = templatefile("${path.module}/inventory.tpl", {
    # Ansible entra por la red NAT (IP por DHCP)
    ip_web = libvirt_domain.p1-web.network_interface[0].addresses[0]
    ip_bd  = libvirt_domain.p1-bd.network_interface[0].addresses[0]
  })
}
