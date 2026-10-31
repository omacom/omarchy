# Solución de problemas

### ¡Rompí mi sistema con una actualización!

Primero intenta [revertir tu sistema](47-system-snapshots.md) a la versión anterior a tu actualización reciente. Si eso no funciona, usa `omarchy-debug` para compartir tu problema en #omarchy-help en Discord. Y si todo eso falla, puedes reinstalar las configuraciones y los paquetes predeterminados usando `omarchy-reinstall`.

### ¿Por qué algunas aplicaciones se ven tan grandes en mi pantalla?

Omarchy asume que tienes una pantalla de alta resolución 2x, así que establece `GDK_SCALE` en 2 hasta que elijas una escala en el panel del monitor. Si estás en una pantalla 1x y las aplicaciones GTK o X11 se ven demasiado grandes, elige 1x para ella en el panel del monitor, o agrega `hl.env("GDK_SCALE", "1")` a `~/.config/hypr/monitors.lua` (y luego reinicia cualquier aplicación que se vea demasiado grande). Consulta [el manual sobre monitores](33-monitors.md).

Para Spotify, puedes usar `Ctrl + Minus` para reducir la interfaz (y `Ctrl + Plus` para agrandarla).

### ¿Por qué dejaron de funcionar todos mis atajos con la tecla Super?

En algunas laptops ASUS ROG y TUF, `Fn + Super` es una combinación fácil de pasar por alto que activa o desactiva un bloqueo de la tecla Windows a nivel de firmware (pensado para jugar, para que no salgas de un juego por accidente). Nada en la pantalla te avisa que sucedió. Mientras el bloqueo está activo, Super no emite absolutamente nada, así que todos los atajos de Omarchy que usan Super simplemente dejan de funcionar, y parece que Hyprland se rompió.

Presiona `Fn + Super` una vez antes de ponerte a revisar `~/.config/hypr/`, y si eso no hace que Super vuelva, presiónala de nuevo para que no dejes el bloqueo activado. Esto no es el bloqueo Fn, que solo cambia lo que hace la fila de teclas F.

### Mi Wi-Fi, Bluetooth, audio o trackpad simplemente dejó de funcionar

Antes de reiniciar, intenta reiniciar por separado el subsistema que está dando problemas. _Update > Hardware_ en el menú de Omarchy tiene Wi-Fi, Bluetooth, Audio y Trackpad, y recargar uno de esos resuelve la mayoría de las situaciones de «funcionaba hace cinco minutos»: unos audífonos Bluetooth que no se quieren volver a conectar, un trackpad que dejó de responder después de una suspensión, o el sonido que desapareció cuando desconectaste un monitor.

### ¿Por qué no suenan mis bocinas externas?

Probablemente porque no están configuradas como la salida principal. Haz clic en el ícono de bocina en el lado derecho de la barra y se abrirá la ventana emergente de volumen, donde puedes elegir el dispositivo de salida (y también ajustar el volumen por aplicación).

### Las bocinas de mi laptop se escuchan raras

En algunas laptops, Omarchy aplica automáticamente un ajuste de bocinas que corrige la respuesta de frecuencia de las bocinas integradas. `omarchy audio tuning status` te dice si hay uno activo en tu equipo, y `omarchy audio tuning off` lo desactiva si prefieres escuchar las bocinas sin ningún ajuste.

### ¿Por qué no puedo iniciar sesión ni usar sudo con mi contraseña?

Probablemente la escribiste mal demasiadas veces y te bloquearon el acceso. Si esto te está pasando en la pantalla de bloqueo, puedes presionar `CTRL + ALT + F2` para abrir una nueva TTY donde puedes iniciar sesión como root, y luego ejecutar `faillock --reset --user [your-username]`. Eso restablecerá el bloqueo y ya podrás entrar.

### ¿Por qué no aparecen las solicitudes de autorización de 1Password para 1Password SSH Agent / CLI?

Esto puede suceder por 2 motivos:

Para que aparezca la solicitud de aprobación completa, Settings > Advanced > Use Hardware Acceleration debe estar activado. _Nota: Esto requiere un reinicio para empezar a funcionar._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

O si no has abierto 1Password desde que encendiste el equipo, la solicitud no aparecerá.
