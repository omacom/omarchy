# Instalaciones desatendidas

La ISO de Omarchy puede instalarse a sí misma sin nadie en el teclado. Si el instalador encuentra una segunda unidad etiquetada como `cidata` que lleva sus archivos de configuración, los copia, se salta por completo el asistente de configuración y se reinicia por sí solo en el sistema terminado. Sin compilación especial de la ISO, sin entrada extra en el menú de arranque: sin tal unidad conectada, nada cambia y obtienes el asistente normal.

Esto hace que Omarchy sea genial como imagen base para entornos de desarrollo desechables: crea una MV en Proxmox o con Packer, arráncala, aléjate y entra por SSH. `cidata` es la etiqueta `NoCloud` de cloud-init, así que todas las herramientas de virtualización comunes ya saben cómo adjuntar una unidad así.

## Los archivos de configuración

Los archivos son exactamente lo que escribe el propio asistente del instalador, así que la forma más fácil de obtener un conjunto inicial es correr una instalación interactiva (en una MV, por ejemplo) y copiar lo que escribió en `/root`:

| Archivo | Requerido | Propósito |
|------|----------|---------|
| `user_configuration.json` | Sí | Disco, nombre del equipo, zona horaria, teclado |
| `user_credentials.json` | Sí | Nombre de usuario y hash de contraseña |
| `user_full_name.txt` | No | Nombre completo para Git |
| `user_email_address.txt` | No | Correo electrónico para Git |
| `user_encrypt_installation.txt` | No | `true` cuando la configuración lleva un bloque `disk_encryption` |
| `authorized_keys` | No | Llaves públicas SSH, una por línea |
| `tailscale_authkey` | No | Llave de autenticación de Tailscale para unirte a tu tailnet en el primer arranque |

Genera el hash de contraseña para `user_credentials.json` con `openssl passwd -6 "yourpassword"`.

También puedes dejar un archivo vacío llamado `defer-provisioning` en lugar de `user_credentials.json`. Eso ejecuta la misma [instalación para preparar para otro dueño](02-getting-started.md) que puedes activar de forma interactiva: la computadora se instala sin datos personales, y quien la arranque primero elige su teclado y crea su usuario. Ese es el modo para los equipos de generación de imágenes, donde la unidad no debería llevar las credenciales de nadie.

## Acceso por SSH

Cuando `authorized_keys` está presente, la instalación establece las llaves como el `~/.ssh/authorized_keys` del usuario, activa `sshd` y abre el firewall para él. (Una instalación básica de Omarchy trae openssh con el servicio desactivado y el puerto cerrado, así que una computadora desatendida de otro modo sería inalcanzable.) La instalación solo agrega tus llaves: no afloja ninguno de los demás ajustes de autenticación del daemon SSH.

Cuando `tailscale_authkey` está presente, en cambio la computadora se une a tu tailnet en el primer arranque: Tailscale se instala desde los paquetes incluidos en la ISO, el firewall permite la interfaz de la tailnet y un trabajo en segundo plano ejecuta el ingreso en cuanto la computadora tiene red, reintentando hasta lograrlo. Usa una llave reutilizable y preautorizada para que una imagen de unidad pueda servir a muchas computadoras.

## Crear la unidad cidata

Cualquier sistema de archivos con la etiqueta correcta sirve. Una ISO pequeña es la forma fácil:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Luego adjúntala a la MV junto a la ISO de Omarchy. He aquí un ejemplo completo de Proxmox:

```bash
qm create 101 --name my-omarchy \
  --bios ovmf --machine q35 --cpu host --cores 4 --memory 8192 \
  --ostype l26 --scsihw virtio-scsi-single \
  --efidisk0 local-lvm:0,efitype=4m,pre-enrolled-keys=0 \
  --scsi0 local-lvm:40,discard=on,iothread=1 \
  --net0 virtio,bridge=vmbr0 --vga virtio --serial0 socket \
  --ide2 local:iso/omarchy.iso,media=cdrom \
  --ide3 local:iso/cidata.iso,media=cdrom \
  --boot order='scsi0;ide2'

qm start 101
```

El orden de arranque pone el disco primero a propósito: el disco vacío pasa a la ISO en el primer arranque, y el sistema instalado arranca desde el disco para siempre.

## Dos advertencias

Las instalaciones desatendidas cifradas no son totalmente desatendidas: alguien todavía tiene que escribir la frase de contraseña de LUKS en el primer arranque. Y el bloque `disk_encryption` en `user_configuration.json` lleva esa frase en texto sin cifrar, así que trata una unidad cidata creada desde una instalación cifrada como el secreto que es.
