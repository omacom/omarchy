# Máquina virtual de Windows

Omarchy ofrece una forma fácil de ejecutar Windows mediante una VM de Docker en máquinas x86_64. Puedes instalarla usando _Instalar > Windows_ desde el menú de Omarchy (`Super + Space`).

Tu ordenador necesita virtualización KVM para esto, algo que la mayoría de los equipos tiene, pero que a veces está desactivado en la BIOS, y el instalador te dirá si ese es el caso. También necesitarás espacio en disco: lo que le des a Windows, más unos 10GB para la imagen misma.

El instalador pregunta cuánta RAM, cuántos núcleos de CPU y cuánto disco asignar (64GB o más es el mínimo sensato), y luego un nombre de usuario y contraseña de Windows. Déjalos en blanco y tendrás `docker` / `admin`. La descarga tarda un rato —10-15 minutos es normal— y puedes seguir el progreso en el navegador en `http://127.0.0.1:8006`. El navegador pide el mismo nombre de usuario y contraseña antes de abrir la consola.

 ![windows-vm](images/windows-vm.webp)

## Usarla

Una vez instalada, lanza _Windows_ desde el lanzador de aplicaciones. Eso inicia la máquina virtual si aún no está en ejecución y te conecta por RDP, a pantalla completa. Dale 15-30 segundos en un arranque en frío.

La sesión RDP lleva sonido, tu micrófono y un portapapeles compartido, así que copiar texto entre Linux y Windows simplemente funciona. La resolución sigue a tu ventana, y Omarchy respeta tu escalado de pantalla, así que no es un desastre borroso en una pantalla HiDPI.

Cuando cierras la ventana RDP, la máquina virtual se apaga automáticamente. Si prefieres dejarla en ejecución —pongamos que tienes algo funcionando ahí dentro—, lánzala con `omarchy windows vm launch --keep-alive` en su lugar.

El resto de los controles están en el mismo comando:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Compartir archivos

El directorio `~/Windows` en tu directorio personal se comparte automáticamente con la máquina virtual. Pon ahí los archivos a los que quieras dar acceso a Windows. La máquina virtual no tiene acceso a ninguna otra parte de tu sistema de archivos, así que estás a salvo de cualquier cosa desagradable del lado de Windows. Su propio disco virtual está disponible en `~/.windows`.

Esas rutas de siempre del directorio personal siguen en sus propios sistemas de archivos. También pueden ser enlaces simbólicos a directorios que te pertenezcan, lo cual es útil cuando el disco virtual vive en una unidad más grande. El instalador mide el espacio libre en el sistema de archivos que realmente contiene `~/.windows`, no necesariamente el sistema de archivos que contiene tu directorio personal.

Mantén las rutas del disco y de la carpeta compartida como directorios separados que no se solapen. La desinstalación vacía deliberadamente el directorio del disco pero conserva el directorio compartido. Inmediatamente antes de la eliminación, Omarchy realiza una comprobación de contención acotada y se niega a quitar nada si esa comprobación no termina a tiempo o no puede demostrar que los dos árboles están separados.

Antes de que arranque la máquina virtual, Omarchy abre y fija esos dos directorios y después monta mediante bind los inodos exactos en anclas privadas por usuario bajo `/var/lib/omarchy/windows/mounts`. Docker solo ve esas anclas protegidas por root. Esto conserva las ubicaciones personalizadas del disco a la vez que impide que otro proceso que se ejecute como tú intercambie una ruta ya comprobada antes de que el contenedor privilegiado la consuma. Los directorios existentes del disco y compartido se ajustan a modo `0700` durante la migración para que otras cuentas locales no puedan explorar su contenido.

Los puertos de la máquina virtual están vinculados solo a localhost, así que nada en tu red puede llegar al ordenador Windows. La consola web también requiere el nombre de usuario y la contraseña de Windows configurados, lo que impide que otra cuenta local gestione la máquina virtual mediante el puerto 8006.

## Límites y licencias

No hay paso directo de GPU con esta configuración, así que no es adecuada para videojuegos ni edición de vídeo. Es una gran forma de ejecutar Microsoft Office o lo que sea que absolutamente debas tener.

La versión instalada es Windows 11 Pro, sin activar. Necesitarás tu propia clave de licencia para usar las funciones restringidas.

Si este ordenador vino con Windows, la clave OEM sigue en el firmware incluso después de instalar Omarchy. Imprímela con `omarchy windows key`. Esa clave está vinculada a este ordenador: activará Windows reinstalado en este hardware, pero por lo general no activará la máquina virtual.

Puedes cambiar la asignación de recursos después ejecutando `omarchy windows vm install` en un terminal, lo que reescribe la configuración de la VM a partir de tus respuestas. El archivo compose en sí ahora vive en `/var/lib/omarchy/windows/docker-compose.yml` y es propiedad de root — eso es deliberado, para que un proceso ejecutándose como tú no pueda reescribirlo y hacer que el arranque privilegiado monte todo tu disco dentro del contenedor. Si necesitas editarlo a mano (por ejemplo para montar un dispositivo USB), edítalo con `sudo` y consulta todas las opciones en [el proyecto Dockur Windows](https://github.com/dockur/windows).

Para deshacerte de todo, usa _Quitar > Windows_ desde el menú de Omarchy. Eso elimina el disco de la VM en `~/.windows` y todo lo instalado dentro de Windows, así que primero copia fuera de la VM cualquier cosa que necesites. Tu carpeta compartida `~/Windows` se queda intacta.
