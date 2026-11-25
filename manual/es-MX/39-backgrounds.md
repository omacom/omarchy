# Fondos

Cada tema incluye su propio conjunto de fondos, y puedes agregar extras tuyos en `~/.config/omarchy/backgrounds/[theme]`. Si quieres agregar una imagen de fondo extra a, digamos, el tema nord, solo tienes que poner el archivo en `~/.config/omarchy/backgrounds/nord`.

La forma más fácil de hacerlo es ir a _Instalar > Estilo > Fondo_ en el menú de Omarchy. Eso abrirá la carpeta donde se guardan los fondos de ese tema. Presiona `Super + Shift + F` para abrir otro gestor de archivos, busca tu fondo y cópialo. Ahora estará incluido entre las opciones de fondos que puedes elegir con `Super + Ctrl + W`.

Un tema sin fondos propios recibe uno generado a partir de sus colores: el logo de Omarchy en el color de acento del tema sobre su color de fondo. Agrega el tuyo para reemplazarlo.

Los fondos también pueden ser videos, no solo imágenes fijas. Suelta un archivo `mp4`, `m4v`, `mov`, `webm`, `mkv` o `avi` en la misma carpeta y aparecerá junto a las imágenes. Los videos los reproduce el motor de fondos de pantalla OWE. Decodifica el video una sola vez para todos los monitores, reproduce su sonido por la salida de audio predeterminada y detiene la reproducción cuando nada puede verlo. Un fondo en video sigue consumiendo mucha más energía que uno fijo.

Los temas pueden incluir una intro corta para un fondo fijo. Para `backgrounds/road.webp`, el video correspondiente está en `backgrounds/intros/road.mp4`. Se reproduce automáticamente al arrancar, al cambiar a un tema con ese fondo seleccionado y al elegir ese fondo, y luego regresa a la imagen fija. Los videos de intro no aparecen en el selector de fondos y nunca se reproducen en bucle.

Elegir _Apariencia > Animaciones desactivadas_ también desactiva las intros de fondo. Omarchy hace esto por defecto en una máquina virtual. El comando `omarchy theme bg intro toggle` puede activar o desactivar las intros por separado. Actualizar un tema no reproduce una intro.

Una imagen fija también puede tener un bucle, una versión tranquila de la misma imagen que se mantiene en movimiento, en `backgrounds/loops/road.mp4`. Se reproduce en lugar de la imagen fija, después de su intro si tiene una, y se detiene cuando desactivas las animaciones. Con batería se muestra la imagen fija, y el bucle regresa en cuanto conectas el equipo. Los bucles no aparecen en el selector de fondos.

Puedes encontrar una colección enorme de fondos geniales y bien seleccionados en [dharmx/walls](https://github.com/dharmx/walls).

La pantalla de bloqueo muestra un fotograma fijo de un fondo en video, igual que muestra un fotograma fijo de un GIF animado.
