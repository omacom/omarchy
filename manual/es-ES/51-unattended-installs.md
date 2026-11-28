# Instalaciones desatendidas

La ISO de Omarchy puede instalarse sola, sin nadie frente al teclado. Si el instalador encuentra una segunda unidad etiquetada como `cidata` con sus archivos de configuración, los copia, se salta por completo el asistente de configuración y reinicia por su cuenta en el sistema ya terminado. No necesitas una ISO especial ni una entrada extra en el menú de arranque: si no hay una unidad así conectada, nada cambia y obtienes el asistente normal.

Esto hace que Omarchy sea ideal como imagen base para entornos de desarrollo desechables: crea una VM en Proxmox o con Packer, arráncala, aléjate y entra por SSH. `cidata` es la etiqueta `NoCloud` de cloud-init, así que todas las herramientas comunes de virtualización ya saben cómo adjuntar una unidad así.

## Los archivos de configuración

Los archivos son exactamente los que escribe el propio asistente del instalador, así que la forma más fácil de obtener un conjunto inicial es hacer una instalación interactiva (en una VM, por ejemplo) y copiar lo que escribió en `/root`:

| Archivo | Obligatorio | Propósito |
|------|----------|---------|
| `user_configuration.json` | Sí | Disco, nombre del equipo, zona horaria, teclado |
| `user_credentials.json` | Sí | Nombre de usuario, hash de la contraseña y, si la instalación está cifrada, la frase de contraseña de LUKS |
| `user_encrypt_installation.txt` | No | `true` cuando la configuración incluye un bloque `disk_encryption` |
| `authorized_keys` | No | Claves públicas de SSH, una por línea |
| `tailscale_authkey` | No | Clave de autenticación de Tailscale para unirte a tu tailnet en el primer arranque |

Genera el hash de la contraseña para `user_credentials.json` con `openssl passwd -6 "yourpassword"`.

El nombre y el correo para los commits de git no forman parte de la instalación. Configúralos en cuanto la máquina esté en marcha, por SSH por ejemplo, con `omarchy setup git --name "Jane Doe" --email jane@example.com`.

También puedes poner un archivo vacío llamado `defer-provisioning` en lugar de `user_credentials.json`. Eso ejecuta la misma [instalación de preparación para otro propietario](02-getting-started.md) que puedes activar de forma interactiva: la máquina se instala sin datos personales, y quien la arranque primero elige su teclado y crea su usuario. Ese es el modo para los equipos que preparan imágenes, donde la unidad no debe llevar las credenciales de nadie.

## Acceso por SSH

Cuando `authorized_keys` está presente, la instalación coloca las claves en el `~/.ssh/authorized_keys` del usuario, habilita `sshd` y abre el firewall para ello. (Una instalación estándar de Omarchy incluye openssh con el servicio deshabilitado y el puerto cerrado, así que una máquina desatendida sería inalcanzable de otro modo). La instalación solo añade tus claves: no relaja ninguna otra configuración de autenticación del demonio de SSH.

Cuando `tailscale_authkey` está presente, la máquina se une a tu tailnet en el primer arranque: Tailscale se instala desde los paquetes incluidos en la ISO, el firewall permite la interfaz de la tailnet y una tarea en segundo plano hace la unión en cuanto la máquina tiene red y lo reintenta hasta conseguirlo. Usa una clave reutilizable y preautorizada para que una sola imagen de unidad sirva para muchas máquinas.

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

El orden de arranque pone el disco primero a propósito: el disco vacío cede el turno a la ISO en el primer arranque, y a partir de ahí el sistema instalado arranca siempre desde el disco.

## Dos advertencias

Las instalaciones desatendidas cifradas requieren que alguien introduzca la frase de contraseña de LUKS en el primer arranque. archinstall lee esa frase del campo `encryption_password` en el nivel superior de `user_credentials.json`. El bloque `disk_encryption` de `user_configuration.json` no se usa para leerla. Protege como un secreto cualquier unidad cidata creada a partir de una instalación cifrada.
