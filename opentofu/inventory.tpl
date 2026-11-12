# Fichero generado por OpenTofu (inventario.tf): no lo edites a mano
[servidores_web]
web ansible_host=${ip_web} ansible_user=debian

# bd solo está en la red de datos: se llega a ella saltando por web
# (ProxyCommand con ssh -W equivale a ProxyJump, pero admite opciones para el salto)
[servidores_bd]
bd ansible_host=${ip_bd} ansible_user=ubuntu ansible_ssh_common_args='-o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -W %h:%p -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null debian@${ip_web}"'
