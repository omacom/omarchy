# Solución de problemas

### ¡Rompí mi sistema con una actualización!

Primero intenta [restaurar tu sistema](47-system-snapshots.md) a la versión anterior a tu actualización reciente. Si eso no funciona, usa `omarchy-debug` para compartir tu problema en #omarchy-help en Discord. Y si todo eso falla, puedes reinstalar las configuraciones y los paquetes por defecto usando `omarchy-reinstall`.

### ¿Por qué algunas apps se ven tan grandes en mi pantalla?

Omarchy supone una pantalla de alta resolución 2x, lo que requiere establecer `GDK_SCALE` en 2 en `~/.config/hypr/monitors.lua`. Pero si estás en una pantalla 1x, puedes cambiar `local omarchy_gdk_scale = 2` a 1 (y luego reiniciar cualquier app que se vea sobredimensionada). Consulta [el manual sobre monitores](33-monitors.md).

En Spotify, puedes usar `Ctrl + Minus` para reducir la interfaz (y `Ctrl + Plus` para agrandarla).

### Mi Wi-Fi, Bluetooth, audio o panel táctil simplemente dejó de funcionar

Antes de reiniciar, intenta reiniciar por separado el subsistema que está fallando. _Actualizar > Hardware_ en el menú de Omarchy tiene Wi-Fi, Bluetooth, Audio y Panel táctil, y recargar uno de esos resuelve la mayoría de las situaciones de «funcionaba hace cinco minutos»: unos audífonos Bluetooth que no se vuelven a conectar, un panel táctil que dejó de responder después de una suspensión, un sonido que desapareció cuando desconectaste un monitor.

### ¿Por qué no suenan mis bocinas externas?

Probablemente porque no están establecidas como salida principal. Haz clic en el ícono de la bocina en el lado derecho de la barra y se abrirá la ventana emergente de volumen, donde puedes elegir el dispositivo de salida (y también mezclar los volúmenes por app).

### Las bocinas de mi laptop suenan raro

En algunas laptops, Omarchy aplica automáticamente un ajuste de bocinas que corrige la respuesta de frecuencia de las bocinas integradas. `omarchy audio tuning status` te dice si hay uno activo en tu computadora, y `omarchy audio tuning off` lo desactiva si prefieres escuchar las bocinas sin procesar.

### ¿Por qué no puedo iniciar sesión ni usar sudo con mi contraseña?

Probablemente la escribiste mal demasiadas veces y te bloquearon. Si esto está pasando en la pantalla de bloqueo, puedes presionar `CTRL + ALT + F2` para iniciar un nuevo TTY donde puedes iniciar sesión como root y luego ejecutar `faillock --reset --user [your-username]`. Eso restablecerá el bloqueo y quedarás listo.

### ¿Por qué no aparecen las solicitudes de autorización de 1Password para el Agente SSH / CLI de 1Password?

Esto puede pasar por 2 razones:

Para que aparezca la solicitud de aprobación completa, debe estar activada la opción Settings > Advanced > Use Hardware Acceleration. _Nota: Esto requiere reiniciar para empezar a funcionar._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

O bien, si no has abierto 1Password desde que arrancaste, la solicitud no aparecerá.
