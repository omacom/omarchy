# Capturas de pantalla y grabación

Todo lo que puedes capturar de la pantalla cuelga de la tecla Print Screen. Una tecla por sí sola toma una foto, y los modificadores toman una grabación, un color o el texto dentro de una región. Si tu teclado no tiene tecla Print Screen, `Super + Ctrl + Alt + C` toma la misma captura de pantalla, y `Super + Ctrl + C` abre todo el conjunto como un menú.

| Hotkey | Función |
| ------ | -------- |
| `Print Screen` | Captura de pantalla |
| `Super + Ctrl + Alt + C` | Captura de pantalla |
| `Alt + Print Screen` | Grabación de pantalla (o detener la que está en curso) |
| `Super + Print Screen` | Selector de color |
| `Super + Ctrl + Print Screen` | Extraer texto de una región |
| `Super + Ctrl + C` | Menú de captura |
| `Super + Ctrl + .` | Transcodificar una imagen o un video |

## Capturas de pantalla

Presiona `Print Screen` (o `Super + Ctrl + Alt + C`) y Omasnap captura el monitor enfocado antes de que aparezca su superposición, para que nada se mueva debajo de ti mientras apuntas. Arrastra una región libre, haz clic en una ventana para capturarla o haz clic en un espacio abierto para capturar todo el monitor. Presiona `S` antes de dibujar para capturar una región con desplazamiento. ¿Cambiaste de opinión? Presiona la misma tecla otra vez para cerrar Omasnap.

Después de seleccionar un área, Omasnap guarda la captura, la copia al portapapeles y muestra una vista previa durante 10 segundos. Usa el botón de fijar de la vista previa o `Ctrl + P` para mantenerla en pantalla, o elige Edit para anotarla.

El editor de anotaciones puede dibujar flechas, líneas, formas, resaltados, marcadores numerados, texto y tachaduras seguras; recortar o cortar parte de la imagen; aplicar OCR a su texto; y agregar un fondo. En el editor, presiona `Enter` para copiar y guardar el PNG terminado, `Ctrl + C` para copiarlo sin guardarlo, o `Ctrl + S` para guardarlo sin copiarlo.

Las capturas guardadas van a `~/Pictures/Screenshots` de forma predeterminada, con un nombre como `screenshot-2026-08-13_14-22-05-firefox.png`. Configura `OMASNAP_SCREENSHOT_DIR` para usar otro directorio — consulta [las preguntas frecuentes](46-faq.md) para saber dónde poner las variables de entorno de la sesión. Omasnap crea el directorio cuando guarda la primera captura. Configura `[output] autosave = false` en `~/.config/omasnap/omasnap.conf` para desactivar el guardado automático.

Desde la terminal, `omarchy screenshot` abre la misma superposición, y puedes elegir su modo inicial: `omarchy capture screenshot region`, `windows`, `fullscreen` o `scroll`. Un segundo argumento de `copy` o `save` omite la vista previa y envía la captura directo a ese destino. Para editar antes de la salida, usa `omarchy screenshot --editor=overlay` para un editor de pantalla completa o `omarchy screenshot --editor=window` para una ventana separada.

### Controlar el selector con el teclado

Mientras la selección está activa, no tienes que usar el mouse para nada:

| Tecla | Función |
| --- | -------- |
| `S` | Activar o desactivar el modo de región con desplazamiento |
| `Super + Arrow keys` | Moverse entre ventanas en el modo Window |
| `Return` | Capturar la ventana resaltada |
| `Ctrl + A` | Capturar todo el monitor enfocado |
| `R` | Restaurar la última región dibujada en esta sesión |
| `Esc` | Cerrar Omasnap |

Estos atajos solo existen mientras Omasnap está abierto, así que no pueden chocar con nada de tu propia configuración.

## Grabación de pantalla

`Alt + Print Screen` abre _Trigger > Capture > Screenrecord_, que pregunta qué quieres en la banda sonora: sin audio, audio del escritorio, escritorio más micrófono, o escritorio más micrófono más webcam. Esa última opción solo aparece si de verdad tienes una cámara conectada. Elige una y el selector de grabación de Omarchy te deja arrastrar una región o hacer clic en una ventana o monitor.

La grabación corre sobre gpu-screen-recorder, que codifica en la GPU a 60fps y recurre a la CPU si no le queda de otra. El resultado es un MP4 en `~/Videos`, con un nombre como `screenrecording-2026-08-13_14-22-05.mp4`. Configura `OMARCHY_SCREENRECORD_DIR` para cambiar eso — pero ten en cuenta que, a diferencia del directorio de capturas de pantalla, este ya tiene que existir, o la grabación se niega a empezar.

Mientras grabas, aparece un pequeño indicador en la barra. Haz clic en él para detener. También puedes detener con `Alt + Print Screen` otra vez, o con la entrada _Stop Screenrecording_ bajo _Trigger > Capture > Screenrecord_, que solo aparece mientras algo se está grabando de verdad.

Al detener, hace un poco de limpieza antes de entregarte el archivo: se recorta el primer cuadro, y si hay audio se normaliza a -14 LUFS con el chasquido de captura de PipeWire del mero inicio silenciado. Luego aparece una notificación con una miniatura de la grabación. Haz clic en ella para reproducir el archivo en mpv.

### La superposición de la webcam

Cuando grabas con una webcam, la cámara aparece como una ventana vertical fijada y recortada en la esquina inferior derecha de lo que estés grabando. Si está encima de algo que necesitas, cambia su tamaño al vuelo:

| Hotkey | Función |
| ------ | -------- |
| `Super + Alt + [` | Hacer más chica la superposición de la webcam |
| `Super + Alt + ]` | Hacer más grande la superposición de la webcam |

Hay tres tamaños — chico, mediano y grande — y los atajos avanzan entre ellos. El mediano es el predeterminado. Son proporcionales a la grabación, así que la cámara ocupa la misma parte del cuadro grabes un monitor de 1080p o uno de 6K. Y si grabaste una región en lugar de una pantalla completa, la superposición se ancla a la esquina de esa región en lugar de a la del monitor, para que se quede dentro de la toma.

También puedes llamarla directo con `omarchy-capture-webcam-resize small`, o `reset` para volver al tamaño mediano.

## Texto, códigos QR y colores

`Super + Ctrl + Print Screen` selecciona una región y aplica OCR a su contenido para llevarlo al portapapeles. Eso está cubierto como se debe en [Extracción de texto y dictado](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ hace el mismo truco para códigos QR. Selecciona la región con el código y el valor decodificado va al portapapeles. Solo busca códigos QR — el contenido denso de la pantalla tiene la maña de dar falsos positivos como código de barras en caso contrario. Vale la pena saberlo: el valor decodificado va al portapapeles y a ningún otro lado. No se imprime, no está en la notificación, y está marcado como sensible para que no se quede en el [historial del portapapeles](08-unified-clipboard-history.md). Los códigos QR suelen llevar secretos — la URI `otpauth://` detrás de un código de configuración de 2FA, por ejemplo — y no quieres eso en un registro. Pegar sigue funcionando sin problema.

`Super + Print Screen` (o _Trigger > Capture > Color_) convierte el cursor en un cuentagotas. Haz clic en cualquier cosa en pantalla y el color va al portapapeles. Presiona el atajo otra vez para salir sin elegir.

## Transcodificar antes de compartir

Una grabación de pantalla en 4K o un HEIC sin procesar de tu teléfono suele ser demasiado grande para nomás enviarlo. `Super + Ctrl + .` (o _Trigger > Transcode_) arregla eso. Te ofrece un selector de archivos con búsqueda difusa sobre `~/Pictures` y `~/Videos`, y luego pregunta por un formato y un tamaño.

Las imágenes van a jpg o png en alto, medio o bajo, que limitan el ancho a 3160, 2160 y 1080 píxeles. Los videos van a mp4 o a un gif animado en 4k, 1080p o 720p. El archivo convertido se escribe junto al original con la resolución en el nombre — `demo-1080p.mp4` — y la ruta se copia al portapapeles como una URI de archivo, para que puedas pegarla directo en una app que acepte archivos soltados.

También funciona desde la terminal, si ya sabes lo que quieres: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. También está `omarchy transcode ascii`, que convierte una imagen en arte ASCII — ese es más que nada para [la marca](41-branding.md).

## Enviarlo a algún lado

Ya que tienes el archivo, `Super + Ctrl + S` abre el menú Share y lo envía a otro dispositivo en tu red vía LocalSend. Consulta [GUIs](22-guis.md) para eso.
