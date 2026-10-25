# Instalaciones desatendidas

La ISO de Omarchy puede instalarse sola, sin nadie frente al teclado. Si el instalador encuentra una segunda unidad etiquetada como `cidata` con sus archivos de configuración, los copia, se salta por completo el asistente de configuración y reinicia por su cuenta en el sistema ya terminado. No necesitas una ISO especial ni una entrada extra en el menú de arranque: si no hay una unidad así conectada, nada cambia y obtienes el asistente normal.

Esto hace que Omarchy sea ideal como imagen base para entornos de desarrollo desechables: crea una VM en Proxmox o con Packer, arráncala, aléjate y entra por SSH. `cidata` es la etiqueta `NoCloud` de cloud-init, así que todas las herramientas comunes de virtualización ya saben cómo adjuntar una unidad así.

## Los archivos de configuración

Los archivos son exactamente los que escribe el propio asistente del instalador, así que la forma más fácil de obtener un conjunto inicial es hacer una instalación interactiva (en una VM, por ejemplo) y copiar lo que escribió en `/root`:

| Archivo | Obligatorio | Propósito |
|------|----------|---------|
| `user_configuration.json` | Sí | Disco, nombre del equipo, zona horaria, teclado |
| `user_credentials.json` | Sí | Nombre de usuario y hash de la contraseña |
| `user_encrypt_installation.txt` | No | `true` cuando la configuración incluye un bloque `disk_encryption` |
| `authorized_keys` | No | Claves públicas de SSH, una por línea |
| `tailscale_authkey` | No | Clave de autenticación de Tailscale para unirte a tu tailnet en el primer arranque |

Genera el hash de la contraseña para `user_credentials.json` con `openssl passwd -6 "yourpassword"`.

El nombre y el correo para los commits de git no forman parte de la instalación. Configúralos una vez que la máquina esté en marcha, por SSH por ejemplo, con `omarchy setup git --name "Jane Doe" --email jane@example.com`.

También puedes poner un archivo vacío llamado `defer-provisioning` en lugar de `user_credentials.json`. Eso ejecuta la misma [instalación de preparación para otro propietario](02-getting-started.md) que puedes activar de forma interactiva: la máquina se instala sin datos personales, y quien la arranque primero elige su teclado y crea su usuario. Ese es el modo para los equipos de creación de imágenes, donde la unidad no debe llevar las credenciales de nadie.

## Acceso por SSH

Cuando `authorized_keys` está presente, la instalación configura las claves como el `~/.ssh/authorized_keys` del usuario, habilita `sshd` y abre el firewall para ello. (Una instalación estándar de Omarchy incluye openssh con el servicio deshabilitado y el puerto cerrado, así que una máquina desatendida sería inalcanzable de otro modo). La instalación solo agrega tus claves: no relaja ninguna otra configuración de autenticación del demonio de SSH.

Cuando `tailscale_authkey` está presente, la máquina se une a tu tailnet en el primer arranque: Tailscale se instala desde los paquetes incluidos en la ISO, el firewall permite la interfaz de la tailnet y un trabajo en segundo plano realiza la unión en cuanto la máquina tiene red, reintentándolo hasta que lo logra. Usa una clave reutilizable y preautorizada para que una sola imagen de unidad sirva para muchas máquinas.

## Cómo crear la unidad cidata

Cualquier sistema de archivos con la etiqueta correcta funciona. Una ISO diminuta es la forma fácil:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Luego adjúntala a la VM junto con la ISO de Omarchy. Aquí tienes un ejemplo completo de Proxmox:

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

El orden de arranque pone el disco primero a propósito: el disco vacío pasa de largo a la ISO en el primer arranque, y el sistema instalado arranca desde el disco para siempre después.

## Dos advertencias

Las instalaciones desatendidas cifradas no son totalmente desatendidas: alguien todavía tiene que escribir la frase de contraseña de LUKS en el primer arranque. Y el bloque `disk_encryption` en `user_configuration.json` lleva esa frase de contraseña en texto plano, así que trata una unidad cidata creada a partir de una instalación cifrada como el secreto que es.
