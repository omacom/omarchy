# Avisos

Las notificaciones aparecen en la esquina superior derecha de la pantalla en foco. También puedes acceder rápidamente a la fecha y la hora, el estado de la batería y el clima actual usando los avisos por atajo de teclado.

## Notificaciones

Las notificaciones de la misma app o sitio se apilan en un mazo, para que un canal de Slack muy activo no saque de la pantalla tu error de compilación. Pasa el cursor sobre un mazo para desplegarlo; nada nuevo se desliza bajo tu puntero mientras estás leyendo. Haz clic en una tarjeta para saltar a su origen, haz clic derecho, clic central o pulsa la ✕ para descartarla.

Las tarjetas ofrecen lo que traen: _Copiar código_ para los códigos de verificación (que se mantienen fuera del [historial del portapapeles](08-unified-clipboard-history.md) y se borran después de un minuto), además de los botones que proporcione la app. Los enlaces en el texto de una notificación se abren al hacer clic en ellos.

Para usarlas sin el mouse, presiona `Super + Ctrl + ,`. La notificación más reciente queda seleccionada y sus botones numerados: presiona un número para usar uno, `Enter` para hacer clic en la notificación, `↑` y `↓` para moverte entre notificaciones, `Delete` para descartar una y `Esc` para devolver el teclado. También se libera por sí sola después de unos segundos sin actividad.

Silenciar las notificaciones las retiene, excepto las confirmaciones propias de Omarchy, las alertas de emergencia y los códigos de verificación, que pediste hace un momento. Vuelve a poner las últimas en pantalla, retenidas o no, con `Super + Shift + Alt + ,`. El historial se conserva durante un día.

## Avisos por atajo de teclado

### Fecha y hora

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Clima

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

La ubicación se detecta a partir de tu dirección IP, que por lo general es lo bastante cercana, pero no siempre. Puedes precisarla con `omarchy weather location --set Malibu`, o ser exacto al respecto agregando coordenadas: `omarchy weather location --set Malibu 34.0259,-118.7798`. Ejecuta `omarchy weather location` por sí solo para ver dónde cree que estás, y `--clear` para volver a la detección automática.

### Batería

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
