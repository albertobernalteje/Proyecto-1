# Proyecto 1: Infraestructura como código

Escenario con OpenTofu y configuración con Ansible para desplegar
la aplicación [guestbook_php](https://github.com/josedom24/guestbook_php)
(libro de visitas en PHP con MariaDB).

## Escenario

| Máquina | Sistema      | Red NAT (`p1-red-nat`)  | Red de datos (`p1-red-datos`) |
|---------|--------------|-------------------------|-------------------------------|
| `web`   | Debian 13    | DHCP (192.168.140.0/24) | 10.10.10.10                   |
| `bd`    | Ubuntu 26.04 | DHCP (192.168.140.0/24) | 10.10.10.20                   |

- `p1-red-nat`: red NAT con DHCP. Desde el anfitrión se accede al servidor web
  y las máquinas tienen salida a internet.
- `p1-red-datos`: red muy aislada (sin IP en el anfitrión) con direcciones
  estáticas, por la que `web` se conecta a MariaDB.

## Estructura

- `opentofu/`: definición del escenario (redes, máquinas, cloud-init) y
  generación del inventario de Ansible (`ansible/hosts`).
- `ansible/`: configuración con tres roles:
  - `commons`: actualiza el sistema e instala paquetes comunes.
  - `bd`: MariaDB escuchando solo en la red de datos, base de datos, usuario
    que solo puede conectarse desde `web` y tablas de la aplicación.
  - `web`: Apache con PHP, virtual host `www.albertobernal.org` y la aplicación.
- Las variables están en `ansible/group_vars/`.

## Requisitos

- libvirt, OpenTofu y Ansible (con las colecciones `community.mysql` y
  `community.general`).
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

Para destruir el escenario: `tofu destroy` en `opentofu/`.
