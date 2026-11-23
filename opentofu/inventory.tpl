# Fichero generado por OpenTofu (inventario.tf): no lo edites a mano

# web hace de router/NAT y de balanceador de carga (HAProxy)
[balanceador]
web ansible_host=${ip_web} ansible_user=debian

# Los dos servidores web con Apache y la aplicación, detrás del balanceador
# web2 solo está en la red de datos: se llega a ella saltando por web
# (ProxyCommand con ssh -W equivale a ProxyJump, pero admite opciones para el salto)
[servidores_web]
web ansible_host=${ip_web} ansible_user=debian
web2 ansible_host=${ip_web2} ansible_user=debian ansible_ssh_common_args='-o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -W %h:%p -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null debian@${ip_web}"'

# bd solo está en la red de datos: mismo salto por web
[servidores_bd]
bd ansible_host=${ip_bd} ansible_user=ubuntu ansible_ssh_common_args='-o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -W %h:%p -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null debian@${ip_web}"'

# backup también está solo en la red de datos: mismo salto por web
[servidores_backup]
backup ansible_host=${ip_backup} ansible_user=debian ansible_ssh_common_args='-o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -W %h:%p -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null debian@${ip_web}"'
