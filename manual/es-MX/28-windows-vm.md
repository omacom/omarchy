# Máquina virtual de Windows

Omarchy ofrece una forma fácil de ejecutar Windows mediante una máquina virtual de Docker. Puedes instalarla usando _Instalar > Windows_ desde el menú de Omarchy (`Super + Space`).

Tu computadora necesita virtualización KVM para esto, algo que la mayoría tiene, pero a veces está desactivada en la BIOS, y el instalador te dirá si ese es el caso. También vas a querer espacio en disco: lo que le des a Windows, más unos 10GB para la imagen misma.

El instalador pregunta cuánta RAM, cuántos núcleos de CPU y cuánto disco entregar (64GB o más es el mínimo sensato), y luego un nombre de usuario y contraseña de Windows. Déjalos en blanco y obtendrás `docker` / `admin`. La descarga tarda un rato —10-15 minutos es normal— y puedes seguir el progreso en el navegador en `http://127.0.0.1:8006`. El navegador pide el mismo nombre de usuario y contraseña antes de abrir la consola.

 ![windows-vm](images/windows-vm.webp)

## Usarla

Una vez instalada, lanza _Windows_ desde el lanzador de aplicaciones. Eso inicia la máquina virtual si aún no está en ejecución y te conecta por RDP, a pantalla completa. Dale 15-30 segundos en un arranque en frío.

La sesión RDP lleva sonido, tu micrófono y un portapapeles compartido, así que copiar texto entre Linux y Windows simplemente funciona. La resolución sigue a tu ventana, y Omarchy pasa tu escalado de pantalla, así que no es un desastre borroso en una pantalla HiDPI.

Cuando cierras la ventana RDP, la máquina virtual se apaga automáticamente. Si prefieres dejarla en ejecución —digamos que tienes algo trabajando ahí dentro—, lánzala con `omarchy windows vm launch --keep-alive` en su lugar.

El resto de los controles están en el mismo comando:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Compartir archivos

El directorio `~/Windows` en tu directorio personal se comparte automáticamente con la máquina virtual. Pon archivos ahí si quieres que sean accesibles para Windows. La máquina virtual no tiene acceso a ninguna otra parte de tu sistema de archivos, así que estás a salvo de cualquier cosa desagradable del lado de Windows. Su propio disco virtual está disponible en `~/.windows`.

Esas rutas personales familiares se quedan en sus propios sistemas de archivos. También pueden ser enlaces simbólicos a directorios que te pertenezcan, lo cual es útil cuando el disco virtual vive en una unidad más grande. El instalador mide el espacio libre en el sistema de archivos que realmente contiene `~/.windows`, no necesariamente el sistema de archivos que contiene tu directorio personal.

Mantén las rutas del disco y de compartición como directorios separados y que no se traslapen. La eliminación vacía deliberadamente el directorio del disco pero conserva el directorio compartido. Inmediatamente antes de la eliminación, Omarchy realiza una comprobación de contención acotada y se niega a quitar nada si esa comprobación agota el tiempo o no puede probar que los dos árboles están separados.

Antes de que la máquina virtual inicie, Omarchy abre y fija esos dos directorios, y luego monta con bind los inodos exactos de los directorios sobre anclas privadas por usuario bajo `/var/lib/omarchy/windows/mounts`. Docker solo ve esas anclas protegidas por root. Esto conserva las ubicaciones personalizadas del disco a la vez que impide que otro proceso que se ejecute como tú intercambie una ruta ya comprobada antes de que el contenedor privilegiado la consuma. Los directorios existentes del disco y compartido se ajustan a modo `0700` durante la migración para que otras cuentas locales no puedan explorar su contenido.

Los puertos de la máquina virtual están vinculados solo a localhost, así que nada en tu red puede llegar a la computadora Windows. La consola web también requiere el nombre de usuario y la contraseña de Windows configurados, lo que impide que otra cuenta local maneje la máquina virtual mediante el puerto 8006.

## Límites y licencias

No hay paso directo de GPU con esta configuración, así que no es adecuada para videojuegos ni edición de video. Es una gran forma de ejecutar Microsoft Office o lo que sea que absolutamente debas tener.

La versión instalada es Windows 11 Pro, sin activar. Necesitarás tu propia clave de licencia para usar las funciones restringidas.

Si esta computadora vino con Windows, la clave OEM sigue en el firmware incluso después de instalar Omarchy. Imprímela con `omarchy windows key`. Esa clave está vinculada a esta computadora: activará Windows reinstalado en este hardware, pero por lo general no activará la máquina virtual.

Puedes cambiar la asignación de recursos después volviendo a ejecutar `omarchy-windows-vm install`, lo cual reescribe la configuración de la máquina virtual a partir de tus respuestas. El archivo compose mismo ahora vive en `/var/lib/omarchy/windows/docker-compose.yml` y pertenece a root: eso es deliberado, para que un proceso que se ejecute como tú no pueda reescribirlo y hacer que el arranque privilegiado monte todo tu disco en el contenedor. Si necesitas editarlo a mano (por ejemplo para montar un dispositivo USB), edítalo con `sudo` y consulta todas las opciones en [el proyecto Dockur Windows](https://github.com/dockur/windows).

Para deshacerte de todo, usa _Quitar > Windows_ desde el menú de Omarchy. Eso borra el disco de la máquina virtual y todos sus datos, así que asegúrate de que todo lo que te importe haya salido de `~/Windows` primero.
