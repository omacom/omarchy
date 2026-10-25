# Fondos

Cada tema incluye su propio conjunto de fondos, y puedes agregar los tuyos en `~/.config/omarchy/backgrounds/[theme]`. Si quieres agregar una imagen de fondo adicional a, por ejemplo, el tema nord, solo coloca el archivo en `~/.config/omarchy/backgrounds/nord`.

La forma más fácil de hacerlo es ir a _Install > Style > Background_ en el Omarchy Menu. Eso abrirá la carpeta donde se guardan los fondos de ese tema. Presiona `Super + Shift + F` para abrir otro administrador de archivos, busca tu fondo y cópialo. Ahora aparecerá entre las opciones de fondos que puedes elegir con `Super + Ctrl + W`.

Los fondos también pueden ser videos, no solo imágenes fijas. Coloca un archivo `mp4`, `m4v`, `mov`, `webm`, `mkv` o `avi` en la misma carpeta y aparecerá junto a las imágenes. Los videos los reproduce el motor de fondos de pantalla OWE. Decodifica el video una sola vez para todos los monitores y reproduce su sonido a través de la salida de audio predeterminada, y detiene la reproducción cuando nada puede verlo. Un fondo de pantalla en video sigue consumiendo mucha más energía que uno fijo.

Los temas pueden incluir una intro corta para un fondo fijo. Para `backgrounds/road.webp`, el video correspondiente está en `backgrounds/intros/road.mp4`. Se reproduce automáticamente al arrancar y al cambiar a un tema con ese fondo seleccionado, y luego regresa a la imagen fija. Los videos de intro no aparecen en el selector de fondos y nunca se reproducen en bucle.

Desactivar _Appearance > Animations_ también desactiva las intros de fondo. Omarchy hace esto de forma predeterminada en una máquina virtual. El comando `omarchy theme bg intro toggle` puede activar o desactivar las intros por separado. Actualizar un tema o elegir otro fondo dentro del mismo tema no reproduce ninguna intro.

Puedes encontrar una colección enorme de fondos geniales y seleccionados en https://github.com/dharmx/walls.

La pantalla de bloqueo muestra un fotograma fijo de un fondo en video, de la misma forma en que muestra un fotograma fijo de un GIF animado.
