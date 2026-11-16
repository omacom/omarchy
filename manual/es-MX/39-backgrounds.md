# Fondos

Cada tema viene con su propio conjunto de fondos, y puedes agregar extras tuyos en `~/.config/omarchy/backgrounds/[theme]`. Si quieres agregar una imagen de fondo extra a, digamos, el tema nord, solo pon el archivo en `~/.config/omarchy/backgrounds/nord`.

Puedes hacerlo más fácilmente yendo a _Install > Style > Background_ en el Omarchy Menu. Eso abrirá la carpeta donde se guardan los fondos de ese tema. Presiona `Super + Shift + F` para abrir otro administrador de archivos, busca tu fondo y cópialo. Ahora estará incluido entre las opciones de fondos que puedes elegir con `Super + Ctrl + W`.

Los fondos pueden ser videos además de imágenes fijas. Suelta un archivo `mp4`, `m4v`, `mov`, `webm`, `mkv` o `avi` en la misma carpeta y aparecerá junto a las imágenes. Los videos los reproduce el motor de fondos de pantalla OWE. Decodifica el video una sola vez para todos los monitores y reproduce su sonido por la salida de audio predeterminada, y detiene la reproducción cuando nada puede verlo. Un fondo en video sigue consumiendo mucha más energía que uno fijo.

Los temas pueden incluir una intro corta para un fondo fijo. Para `backgrounds/road.webp`, el video correspondiente está en `backgrounds/intros/road.mp4`. Se reproduce automáticamente al arrancar, al cambiar a un tema con ese fondo seleccionado y al elegir ese fondo, y luego regresa a la imagen fija. Los videos de intro no aparecen en el selector de fondos y nunca se reproducen en bucle.

Desactivar _Appearance > Animations_ también desactiva las intros de fondo. Omarchy hace esto por defecto en una máquina virtual. El comando `omarchy theme bg intro toggle` puede activar o desactivar las intros por separado. Actualizar un tema no reproduce una intro.

Puedes encontrar una colección enorme de fondos geniales curados en [dharmx/walls](https://github.com/dharmx/walls).

La pantalla de bloqueo muestra un cuadro fijo de un fondo en video, de la misma forma en que muestra un cuadro fijo de un GIF animado.
