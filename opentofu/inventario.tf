# Genera el inventario de Ansible (ansible/hosts) con las IP del escenario
resource "local_file" "inventario" {
  filename        = "${path.module}/../ansible/hosts"
  file_permission = "0644"
  content = templatefile("${path.module}/inventory.tpl", {
    # Ansible entra en web por la red NAT (IP por DHCP)...
    ip_web = libvirt_domain.p1-web.network_interface[0].addresses[0]
    # ...y en bd por la red de datos, saltando por web
    ip_bd = "10.10.10.20"
  })
}
