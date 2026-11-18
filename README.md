# Proyecto 1: Infraestructura como código

Escenario con OpenTofu y configuración con Ansible para desplegar
la aplicación [guestbook_php](https://github.com/josedom24/guestbook_php)
(libro de visitas en PHP con MariaDB).

## Escenario

| Máquina | Sistema      | Red NAT (`p1-red-nat`)  | Red de datos (`p1-red-datos`) |
|---------|--------------|-------------------------|-------------------------------|
| `web`   | Debian 13    | DHCP (192.168.140.0/24) | 10.10.10.10                   |
| `bd`    | Ubuntu 26.04 | —                       | 10.10.10.20 (gw 10.10.10.10)  |
| `backup`| Debian 13    | —                       | 10.10.10.30 (gw 10.10.10.10)  |

- `p1-red-nat`: red NAT con DHCP. Desde el anfitrión se accede al servidor web,
  que tiene salida a internet.
- `p1-red-datos`: red muy aislada (sin IP en el anfitrión) con direcciones
  estáticas, por la que `web` se conecta a MariaDB.
- `web` hace de router/NAT: `bd` solo está en la red de datos y sale a internet
  a través de él (reenvío de paquetes y masquerade con iptables). Ansible llega
  a `bd` saltando por `web` (SSH con `ProxyCommand`).
- `backup` también está solo en la red de datos y sale a internet por `web`.
  Hace cada día una copia de la base de datos de `bd` por la red de datos.

## Estructura

- `opentofu/`: definición del escenario (redes, máquinas, cloud-init) y
  generación del inventario de Ansible (`ansible/hosts`).
- `ansible/`: configuración con cinco roles:
  - `router`: en `web`, activa el reenvío de paquetes y el NAT de la red de
    datos con iptables (reglas guardadas con iptables-persistent). Se ejecuta
    primero porque `bd` lo necesita para salir a internet.
  - `commons`: actualiza el sistema e instala paquetes comunes.
  - `bd`: MariaDB escuchando solo en la red de datos, base de datos, usuario
    que solo puede conectarse desde `web`, usuario de copias que solo puede
    conectarse desde `backup` y tablas de la aplicación.
  - `web`: Apache con PHP, virtual host `www.albertobernal.org` y la aplicación.
  - `backup`: en `backup`, script `copia-bd` (`mariadb-dump` comprimido con
    gzip, guardando solo las últimas copias) que lanza cada día un timer de
    systemd, y script `restaurar-bd` para recuperar una copia.
- Las variables están en `ansible/group_vars/`.

## Requisitos

- libvirt, OpenTofu y Ansible (con las colecciones `community.mysql`,
  `community.general` y `ansible.posix`).
- Imágenes base `debian13-base.qcow2` y `ubuntu2604-base.qcow2` en el pool
  `default` (se pueden cambiar con las variables `base_image_debian` y
  `base_image_ubuntu`).
- Una clave SSH en `~/.ssh/id_ed25519.pub` (variable `ssh_public_key`).

## Despliegue

```bash
cd opentofu
tofu init
tofu apply

cd ../ansible
ansible-playbook site.yaml
```

Para acceder a la aplicación por su nombre, se añade en el `/etc/hosts` del
anfitrión la IP NAT de `web` (sale en `tofu output`):

```
192.168.140.X  www.albertobernal.org
```

Copias de seguridad (en `backup`, entrando con `ssh -J debian@<IP_WEB> debian@10.10.10.30`):

```bash
systemctl list-timers copia-bd.timer   # próxima copia
sudo systemctl start copia-bd.service  # hacer una copia ahora
sudo ls -l /var/backups/guestbook      # copias guardadas
sudo restaurar-bd                      # restaurar la más reciente (o: sudo restaurar-bd <fichero>)
```

Para destruir el escenario: `tofu destroy` en `opentofu/`.
