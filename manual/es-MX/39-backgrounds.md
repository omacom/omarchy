# Fondos

Cada tema incluye su propio conjunto de fondos, y puedes agregar extras tuyos en `~/.config/omarchy/backgrounds/[theme]`. Si quieres agregar una imagen de fondo extra, por ejemplo, al tema nord, solo coloca el archivo en `~/.config/omarchy/backgrounds/nord`.

Puedes hacer esto más fácilmente desde _Install > Style > Background_ en el Menú de Omarchy. Eso abrirá la carpeta donde se guardan los fondos de ese tema. Presiona `Super + Shift + F` para abrir otro administrador de archivos, encuentra tu fondo y cópialo. Ahora estará incluido entre las opciones de fondos que puedes seleccionar con `Super + Ctrl + W`.

Los fondos también pueden ser videos, no solo imágenes fijas. Coloca un archivo `mp4`, `m4v`, `mov`, `webm`, `mkv` o `avi` en la misma carpeta y aparecerá junto a las imágenes. Los videos los reproduce el motor de fondos de pantalla OWE. Decodifica el video una vez para todos los monitores y reproduce su sonido por la salida de audio predeterminada, y detiene la reproducción cuando nada puede verlo. Aun así, un fondo de pantalla en video consume mucha más energía que uno fijo.

Los temas pueden incluir una introducción corta para un fondo fijo. Para `backgrounds/road.webp`, el video correspondiente está en `backgrounds/intros/road.mp4`. Se reproduce automáticamente al arrancar, al cambiar a un tema con ese fondo seleccionado y al elegir ese fondo, y luego regresa a la imagen fija. Los videos de introducción no aparecen en el selector de fondos y nunca se repiten en bucle.

Desactivar _Appearance > Animations_ también desactiva las introducciones de fondo. Omarchy hace esto por defecto en una máquina virtual. El comando `omarchy theme bg intro toggle` puede activar o desactivar las introducciones por separado. Actualizar un tema no reproduce una introducción.

Una imagen fija también puede tener un bucle, una versión tranquila de la misma imagen que se mantiene en movimiento, en `backgrounds/loops/road.mp4`. Se reproduce en lugar de la imagen fija, después de su introducción si tiene una, y se detiene cuando se desactivan las animaciones. Los bucles no aparecen en el selector de fondos y, como cualquier fondo en video, consumen más energía que una imagen fija.

Puedes encontrar una colección enorme de fondos geniales y seleccionados en [dharmx/walls](https://github.com/dharmx/walls).

La pantalla de bloqueo muestra un fotograma fijo de un fondo en video, de la misma forma en que muestra un fotograma fijo de un GIF animado.
