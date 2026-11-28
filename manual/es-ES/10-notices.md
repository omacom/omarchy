# Avisos

Las notificaciones aparecen en la esquina superior derecha de la pantalla activa. También puedes acceder rápidamente a la fecha y la hora, el estado de la batería y el tiempo actual usando los avisos por atajo de teclado.

## Notificaciones

Las notificaciones de la misma app o sitio se apilan, para que un canal de Slack muy activo no saque de la pantalla tu error de compilación. Pasa el ratón por encima de una pila para desplegarla; nada nuevo se desliza debajo del cursor mientras lees. Haz clic en una tarjeta para saltar a su origen, haz clic derecho, clic central o pulsa la ✕ para descartarla.

Las tarjetas ofrecen lo que trae cada notificación: _Copiar código_ para los códigos de verificación (que se mantienen fuera del [historial del portapapeles](08-unified-clipboard-history.md) y se borran después de un minuto), además de los botones que proporcione la app. Los enlaces en el texto de una notificación se abren al hacer clic en ellos.

`Super + ,` descarta la notificación más reciente, o abre aquello a lo que apunta cuando ofrece esa opción, `Super + Alt + ,` descarta solo la última, `Super + Shift + ,` las descarta todas, y `Super + Shift + Alt + ,` abre el historial. Para usarlas sin el ratón, pulsa `Super + Ctrl + ,`. La notificación más reciente queda seleccionada y sus botones numerados: pulsa un número para usar uno, `Enter` para hacer clic en la notificación, `↑` y `↓` para moverte entre notificaciones, `Delete` para descartar una, y `Esc` para devolver el teclado. También se suelta por sí sola tras unos segundos sin actividad.

Silenciar las notificaciones las retiene, excepto las confirmaciones propias de Omarchy, las alertas de emergencia y los códigos de verificación, que pediste hace un momento. Vuelve a poner las últimas en pantalla, retenidas o no, con `Super + Shift + Alt + ,`. El historial se conserva durante un día.

## Avisos por atajo de teclado

### Fecha y hora

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Tiempo

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

La ubicación se detecta a partir de tu dirección IP, que por lo general es lo bastante cercana, pero no siempre. Puedes precisarla con `omarchy weather location --set Malibu`, o afinarla del todo añadiendo coordenadas: `omarchy weather location --set Malibu 34.0259,-118.7798`. Ejecuta `omarchy weather location` por sí solo para ver dónde cree que estás, y `--clear` para volver a la detección automática.

### Batería

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
