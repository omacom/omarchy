# VM de Windows

Omarchy ofrece una forma fácil de ejecutar Windows mediante una VM de Docker en máquinas x86_64. Puedes instalarla usando _Instalar > Windows_ desde el menú de Omarchy (`Super + Space`).

Tu máquina necesita virtualización KVM para esto, y la mayoría la tiene — pero a veces está desactivada en el BIOS, y el instalador te avisará si ese es el caso. También vas a querer espacio en disco: lo que le des a Windows, más unos 10GB para la imagen en sí.

El instalador te pregunta cuánta RAM, cuántos núcleos de CPU y cuánto disco quieres asignar (64GB o más es el mínimo sensato), y luego un nombre de usuario y una contraseña de Windows. Deja esos campos en blanco y obtienes `docker` / `admin`. La descarga tarda un rato — 10-15 minutos es normal — y puedes seguir el progreso en el navegador en `http://127.0.0.1:8006`. El navegador te pide el mismo nombre de usuario y contraseña antes de abrir la consola.

 ![windows-vm](images/windows-vm.webp)

## Cómo usarla

Una vez instalada, ejecuta _Windows_ desde el lanzador de aplicaciones. Eso inicia la VM si aún no está en ejecución y te conecta por RDP, en pantalla completa. Dale 15-30 segundos en un arranque en frío.

La sesión de RDP transmite sonido, tu micrófono y un portapapeles compartido, así que copiar texto entre Linux y Windows simplemente funciona. La resolución se adapta a tu ventana, y Omarchy pasa la escala de tu pantalla, así que no queda como un desastre borroso en una pantalla HiDPI.

Cuando cierras la ventana de RDP, la VM se apaga automáticamente. Si prefieres dejarla en ejecución — digamos que tienes algo trabajando ahí dentro — ejecútala mejor con `omarchy windows vm launch --keep-alive`.

El resto de los controles están en el mismo comando:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Compartir archivos

El directorio `~/Windows` en tu directorio home se comparte automáticamente con la VM. Pon ahí los archivos si quieres que Windows pueda acceder a ellos. La VM no tiene acceso a ninguna otra parte de tu sistema de archivos, así que estás a salvo de cualquier cosa desagradable del lado de Windows. Su propio disco virtual está disponible en `~/.windows`.

Esas rutas home conocidas se quedan en sus propios sistemas de archivos. También pueden ser symlinks a directorios de tu propiedad, lo cual es útil cuando el disco virtual vive en una unidad más grande. El instalador mide el espacio libre en el sistema de archivos que realmente contiene `~/.windows`, no necesariamente el sistema de archivos que contiene tu directorio home.

Mantén el disco y las rutas compartidas como directorios separados y que no se traslapen. La eliminación vacía deliberadamente el directorio del disco, pero conserva el directorio compartido. Inmediatamente antes de la eliminación, Omarchy realiza una comprobación de contención acotada y se niega a eliminar cualquier cosa si esa comprobación agota el tiempo de espera o no puede probar que los dos árboles están separados.

Antes de que la VM inicie, Omarchy abre y fija esos dos directorios, y luego hace bind-mount de los inodos exactos de los directorios sobre anclajes privados por usuario debajo de `/var/lib/omarchy/windows/mounts`. Docker solo ve esos anclajes protegidos por root. Esto conserva las ubicaciones personalizadas del disco mientras evita que otro proceso ejecutándose como tú intercambie una ruta ya comprobada antes de que el contenedor privilegiado la consuma. Los directorios existentes del disco y compartidos se ajustan al modo `0700` durante la migración para que otras cuentas locales no puedan explorar su contenido.

Los puertos de la VM están ligados solo a localhost, así que nada en tu red puede llegar a la máquina de Windows. La consola web también requiere el nombre de usuario y la contraseña de Windows configurados, lo que impide que otra cuenta local controle la VM mediante el puerto 8006.

## Límites y licencias

No hay GPU passthrough con esta configuración, así que no es adecuada para gaming ni para edición de video. Es una gran forma de ejecutar Microsoft Office o lo que sea que absolutamente necesites tener.

La versión instalada es Windows 11 Pro, sin activar. Vas a necesitar tu propia clave de licencia para usar las funciones restringidas.

Si esta computadora venía con Windows de fábrica, la clave OEM sigue en el firmware incluso después de instalar Omarchy. Imprímela con `omarchy windows key`. Esa clave está ligada a esta máquina — activará Windows reinstalado en este hardware, pero por lo general no activará la VM.

Puedes cambiar la asignación de recursos después ejecutando `omarchy windows vm install` en una terminal, lo que reescribe la configuración de la VM a partir de tus respuestas. El archivo compose en sí ahora vive en `/var/lib/omarchy/windows/docker-compose.yml` y es propiedad de root — eso es deliberado, para que un proceso ejecutándose como tú no pueda reescribirlo y hacer que el arranque privilegiado monte todo tu disco dentro del contenedor. Si necesitas editarlo a mano (por ejemplo para montar un dispositivo USB), edítalo con `sudo` y consulta todas las opciones en [el proyecto Dockur Windows](https://github.com/dockur/windows).

Para deshacerte de todo, usa _Eliminar > Windows_ desde el menú de Omarchy. Eso elimina el disco de la VM en `~/.windows` y todo lo instalado dentro de Windows, así que primero copia fuera de la VM cualquier cosa que necesites. Tu carpeta compartida `~/Windows` se queda intacta.
