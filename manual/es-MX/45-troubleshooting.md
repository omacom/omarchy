# Resolución de problemas

### ¡Rompí mi sistema con una actualización!

Primero intenta [revertir tu sistema](47-system-snapshots.md) a la versión anterior a tu actualización reciente. Si eso no funciona, usa `omarchy-debug` para compartir tu problema en #omarchy-help en Discord. Y si todo eso falla, puedes reinstalar las configuraciones y los paquetes predeterminados usando `omarchy-reinstall`.

### ¿Por qué algunas apps se ven tan grandes en mi pantalla?

Omarchy asume una pantalla de alta resolución 2x, así que establece `GDK_SCALE` en 2 hasta que elijas una escala en el panel del monitor. Si estás en una pantalla 1x y las apps GTK o X11 se ven enormes, elige 1x para ella en el panel del monitor, o agrega `hl.env("GDK_SCALE", "1")` a `~/.config/hypr/monitors.lua` (y después reinicia cualquier app que se vea enorme). Consulta [el manual sobre monitores](33-monitors.md).

Para Spotify, puedes usar `Ctrl + Minus` para reducir la interfaz (y `Ctrl + Plus` para agrandarla).

### ¿Por qué dejaron de funcionar todos mis atajos con la tecla Super?

En algunas laptops ASUS ROG y TUF, `Fn + Super` es una combinación fácil de pasar por alto que activa un bloqueo de la tecla Windows a nivel firmware (pensado para jugar, para que no salgas de un juego por accidente). Nada en pantalla te dice que pasó. Mientras el bloqueo está activo, Super no emite absolutamente nada, así que todos los atajos de Omarchy que usan Super simplemente dejan de funcionar, y parece que Hyprland se rompió.

Presiona `Fn + Super` una vez antes de meterte a revisar `~/.config/hypr/`, y si eso no hace que Super vuelva, presiónala otra vez para no dejar el bloqueo activado. Esto no es el bloqueo de Fn, que solo cambia lo que hace la fila de teclas F.

### Mi Wi-Fi, Bluetooth, audio o trackpad simplemente dejó de funcionar

Antes de reiniciar, intenta reiniciar por separado el subsistema que está fallando. _Actualizar > Hardware_ en el menú de Omarchy tiene Wi-Fi, Bluetooth, Audio y Trackpad, y recargar uno de esos resuelve la mayoría de las situaciones de "funcionaba hace cinco minutos": unos audífonos Bluetooth que no se vuelven a conectar, un trackpad que dejó de responder después de una suspensión, sonido que desapareció cuando desconectaste un monitor.

### ¿Por qué no suenan mis bocinas externas?

Probablemente porque no están configuradas como la salida principal. Haz clic en el ícono de la bocina en el lado derecho de la barra y se abrirá la ventana emergente de volumen, donde puedes elegir el dispositivo de salida (y también mezclar el volumen por app).

### Las bocinas de mi laptop suenan raro

En algunas laptops, Omarchy aplica automáticamente un ajuste de bocinas que corrige la respuesta de frecuencia de las bocinas integradas. `omarchy audio tuning status` te dice si hay uno activo en tu máquina, y `omarchy audio tuning off` lo desactiva si prefieres escuchar las bocinas sin corrección.

### ¿Por qué no puedo iniciar sesión ni usar sudo con mi contraseña?

Probablemente la escribiste mal demasiadas veces y te bloquearon. Si esto pasa en la pantalla de bloqueo, puedes presionar `CTRL + ALT + F2` para iniciar un nuevo TTY donde puedes iniciar sesión como root, y luego ejecutar `faillock --reset --user [your-username]`. Eso restablecerá el bloqueo y listo.

### Mi contraseña es aceptada, pero regreso a la pantalla de inicio de sesión

Un archivo del entorno de la sesión dañado puede impedir que el escritorio inicie, incluso cuando tu contraseña es correcta. Vale la pena revisar esto especialmente después de editar `~/.config/uwsm/env.d/`.

Presiona `Ctrl + Alt + F2`, inicia sesión con tu nombre de usuario y contraseña normales, e inspecciona el journal de usuario del arranque actual:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Busca un error que nombre uno de tus archivos de entorno, como `bad substitution`, justo antes de un mensaje que indica que no se encontró la marca de salida del entorno. Mueve ese archivo fuera de `env.d` antes de intentar iniciar sesión de nuevo. Por ejemplo, si el error nombra `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM omite un archivo con un error de sintaxis, pero un error fatal que solo aparece mientras el archivo se ejecuta, como `bad substitution`, aún puede impedir que el escritorio inicie. Una reversión a una instantánea del sistema no repara estos archivos, porque `/home` no se revierte.

Una vez que puedas iniciar sesión, arregla la copia guardada antes de volver a moverla a su lugar. `sh -n` detecta errores de sintaxis sin ejecutar el archivo, pero no puede detectar todos los errores que ocurren cuando se carga con source. Mantén abierta una terminal que funcione mientras pruebas los cambios.

### ¿Por qué no aparecen las solicitudes de autorización de 1Password para 1Password SSH Agent / CLI?

Esto puede pasar por 2 razones:

Para que aparezca la solicitud de aprobación completa, Ajustes > Avanzado > Usar aceleración por hardware debe estar activado. _Nota: Esto requiere un reinicio para empezar a funcionar._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

O si no has abierto 1Password desde que arrancó la computadora, la solicitud no aparecerá.
