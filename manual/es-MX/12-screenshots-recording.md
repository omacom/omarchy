# Capturas de pantalla y grabación

Todo lo que puedes tomar de la pantalla cuelga de la tecla Print Screen. Una tecla sola toma una foto, y los modificadores toman una grabación, un color o el texto dentro de una región. Si tu teclado de plano no tiene tecla Print Screen, `Super + Ctrl + C` abre el mismo conjunto como menú.

| Atajo | Función |
| ------ | -------- |
| `Print Screen` | Captura de pantalla |
| `Alt + Print Screen` | Grabar pantalla (o detener la que está en curso) |
| `Super + Print Screen` | Selector de color |
| `Super + Ctrl + Print Screen` | Extraer texto de una región |
| `Super + Ctrl + C` | Menú de captura |
| `Super + Ctrl + .` | Transcodificar una imagen o un video |

## Capturas de pantalla

Presiona `Print Screen` y Omasnap captura el monitor enfocado antes de que aparezca su capa superpuesta, para que nada se mueva debajo de ti mientras apuntas. Arrastra una región libre, haz clic en una ventana para capturarla o haz clic en un espacio abierto para capturar todo el monitor. Presiona `S` antes de dibujar para capturar una región con desplazamiento. ¿Cambiaste de opinión? Presiona `Print Screen` otra vez para cerrar Omasnap.

Después de seleccionar un área, Omasnap guarda la captura, la copia al portapapeles y muestra una vista previa durante 10 segundos. Usa el botón de fijar de la vista previa o `Ctrl + P` para mantenerla en pantalla, o elige Editar para anotarla.

El editor de anotaciones puede dibujar flechas, líneas, figuras, resaltados, marcadores numerados, texto y censuras seguras; recortar o eliminar parte de la imagen; aplicar OCR a su texto; y agregarle un fondo. En el editor, presiona `Enter` para copiar y guardar el PNG terminado, `Ctrl + C` para copiarlo sin guardarlo, o `Ctrl + S` para guardarlo sin copiarlo.

Las capturas guardadas caen en `~/Pictures/Screenshots` por defecto, con un nombre como `screenshot-2026-08-13_14-22-05-firefox.png`. Configura `OMASNAP_SCREENSHOT_DIR` para usar otro directorio — consulta [las preguntas frecuentes](46-faq.md) para saber dónde poner las variables de entorno de sesión. Omasnap crea el directorio cuando guarda la primera captura. Pon `[output] autosave = false` en `~/.config/omasnap/omasnap.conf` para desactivar el guardado automático.

Desde la terminal, `omarchy screenshot` abre la misma capa superpuesta, y puedes elegir su modo inicial: `omarchy capture screenshot region`, `windows`, `fullscreen` o `scroll`. Un segundo argumento de `copy` o `save` se salta la vista previa y manda la captura directo a ese destino. Para editar antes de generar la salida, usa `omarchy screenshot --editor=overlay` para un editor en pantalla completa o `omarchy screenshot --editor=window` para una ventana separada.

### Manejar el selector desde el teclado

Mientras la selección está activa, no tienes que usar el ratón para nada:

| Tecla | Función |
| --- | -------- |
| `S` | Activar/desactivar el modo de región con desplazamiento |
| `Super + Arrow keys` | Moverse entre ventanas en el modo Ventana |
| `Return` | Capturar la ventana resaltada |
| `Ctrl + A` | Capturar todo el monitor enfocado |
| `R` | Restaurar la última región dibujada en esta sesión |
| `Esc` | Cerrar Omasnap |

Estas asignaciones solo existen mientras Omasnap está abierto, así que no pueden chocar con nada de tu propia configuración.

## Grabación de pantalla

`Alt + Print Screen` abre _Activar > Capturar > Grabar pantalla_, que pregunta qué quieres en la pista de audio: sin audio, audio del escritorio, escritorio más micrófono, o escritorio más micrófono más webcam. Esta última solo aparece si de verdad tienes una cámara conectada. Elige una y el selector de grabación de Omarchy te deja arrastrar una región o hacer clic en una ventana o monitor.

La grabación corre sobre gpu-screen-recorder, que codifica en la GPU a 60 fps y recurre a la CPU si hace falta. El resultado es un MP4 en `~/Videos`, con nombre `screenrecording-2026-08-13_14-22-05.mp4`. Configura `OMARCHY_SCREENRECORD_DIR` para cambiarlo — pero ojo: a diferencia del directorio de capturas, este ya tiene que existir, o la grabación se niega a empezar.

Mientras grabas, aparece un indicador pequeño en la barra. Haz clic en él para detener. También puedes detener con `Alt + Print Screen` otra vez, o con la entrada _Detener grabación_ en _Activar > Capturar > Grabar pantalla_, que solo aparece mientras algo de verdad se está grabando.

Al detener hace un poco de limpieza antes de entregarte el archivo: se recorta el primer fotograma y, si hay audio, se normaliza a -14 LUFS con el chasquido de captura de PipeWire del mero inicio silenciado. Luego aparece una notificación con una miniatura de la grabación. Haz clic para reproducir el archivo en mpv.

### La capa de la webcam

Cuando grabas con una webcam, la cámara aparece como una ventana de retrato fijada y recortada en la esquina inferior derecha de lo que estés grabando. Si está encima de algo que necesitas, redimensiónala al vuelo:

| Atajo | Función |
| ------ | -------- |
| `Super + Alt + [` | Hacer más chica la capa de la webcam |
| `Super + Alt + ]` | Hacer más grande la capa de la webcam |

Hay tres tamaños — chico, mediano y grande — y los atajos pasan de uno a otro. Mediano es el predeterminado. Son proporcionales a la grabación, así que la cámara ocupa la misma porción del encuadre ya sea que grabes un monitor 1080p o uno 6K. Y si grabaste una región en lugar de una pantalla completa, la capa se ancla a la esquina de esa región en lugar de a la del monitor, para que se quede dentro de la toma.

También puedes llamarlo directamente con `omarchy-capture-webcam-resize small`, o `reset` para volver a mediano.

## Texto, códigos QR y colores

`Super + Ctrl + Print Screen` selecciona una región y le aplica OCR hacia el portapapeles. Eso se trata como se debe en [Extracción de texto y dictado](11-text-extraction-dictation.md).

_Activar > Capturar > Código QR_ hace el mismo truco para códigos QR. Selecciona la región con el código y el valor decodificado va al portapapeles. Solo busca códigos QR — el contenido denso de pantalla tiende a dar falsos positivos como código de barras en caso contrario. Vale la pena saberlo: el valor decodificado va al portapapeles y a ningún otro lado. No se imprime, no va en la notificación y está marcado como sensible para que no se quede en el [historial del portapapeles](08-unified-clipboard-history.md). Los códigos QR suelen cargar secretos — el URI `otpauth://` detrás de un código de configuración de 2FA, por ejemplo — y no quieres eso en un registro. Pegar sigue funcionando bien.

`Super + Print Screen` (o _Activar > Capturar > Color_) convierte el cursor en un gotero. Haz clic en cualquier cosa en pantalla y el color cae en el portapapeles. Presiona el atajo otra vez para salir sin elegir.

## Transcodificar antes de compartir

Una grabación de pantalla en 4K o un HEIC crudo de tu teléfono a menudo es demasiado grande para solo enviarlo. `Super + Ctrl + .` (o _Activar > Transcodificar_) arregla eso. Te ofrece un selector de archivos con búsqueda difusa sobre `~/Pictures` y `~/Videos`, y luego pide un formato y un tamaño.

Las imágenes pasan a jpg o png en alto, medio o bajo, lo que limita el ancho a 3160, 2160 y 1080 píxeles. Los videos pasan a mp4 o a un gif animado en 4k, 1080p o 720p. El archivo convertido se escribe junto al original con la resolución en el nombre — `demo-1080p.mp4` — y la ruta se copia al portapapeles como un URI de archivo, para que puedas pegarlo directo en una app que acepte archivos soltados.

También funciona desde la terminal, si ya sabes lo que quieres: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. También está `omarchy transcode ascii`, que convierte una imagen en arte ASCII — ese es sobre todo para [branding](41-branding.md).

## Enviarlo a algún lado

Ya que tienes el archivo, `Super + Ctrl + S` abre el menú Compartir y lo manda a otro dispositivo de tu red vía LocalSend. Consulta [GUIs](22-guis.md) para eso.
