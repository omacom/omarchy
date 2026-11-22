# Avisos

Las notificaciones aparecen en la esquina superior derecha de la pantalla enfocada. También puedes consultar rápidamente la fecha y la hora, el estado de la batería y el clima actual con los avisos por atajo de teclado.

## Notificaciones

Las notificaciones de la misma aplicación o sitio se apilan en un mazo, para que un canal parlanchín de Slack no saque de la pantalla el error de tu compilación. Pasa el cursor sobre un mazo para desplegarlo; nada nuevo se desliza bajo tu puntero mientras lees. Haz clic en una tarjeta para ir a su origen; haz clic derecho, clic central o pulsa la ✕ para descartarla.

Las tarjetas ofrecen lo que traen: _Copiar código_ para los códigos de verificación (que se mantienen fuera del [historial del portapapeles](08-unified-clipboard-history.md) y se borran después de un minuto), además de los botones que proporcione la aplicación. Los enlaces en el texto de una notificación se abren al hacer clic en ellos.

`Super + ,` descarta la notificación más reciente, o abre aquello a lo que apunta cuando ofrece esa opción, `Super + Alt + ,` descarta solo la última, `Super + Shift + ,` las descarta todas, y `Super + Shift + Alt + ,` abre el historial. Para usarlas sin el mouse, presiona `Super + Ctrl + ,`. La notificación más reciente queda seleccionada y sus botones numerados: presiona un número para usar uno, `Enter` para hacer clic en la notificación, `↑` y `↓` para moverte entre notificaciones, `Delete` para descartar una, y `Esc` para devolver el teclado. También se suelta por sí sola tras unos segundos sin actividad.

Silenciar las notificaciones las retiene, excepto las confirmaciones propias de Omarchy, las alertas de emergencia y los códigos de verificación, que pediste hace un momento. Vuelve a mostrar las últimas en pantalla, retenidas o no, con `Super + Shift + Alt + ,`. El historial se conserva durante un día.

## Avisos por atajo de teclado

### Fecha y hora

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Clima

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

La ubicación se detecta a partir de tu dirección IP, que suele ser lo bastante aproximada, pero no siempre. Puedes fijarla con `omarchy weather location --set Malibu`, o ser exacto agregando coordenadas: `omarchy weather location --set Malibu 34.0259,-118.7798`. Ejecuta `omarchy weather location` por sí solo para ver dónde cree que estás, y `--clear` para volver a la detección automática.

### Batería

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
