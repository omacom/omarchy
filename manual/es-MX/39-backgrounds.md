# Fondos

Cada tema incluye su propio conjunto de fondos, y puedes añadir extras tuyos en `~/.config/omarchy/backgrounds/[theme]`. Si quieres añadir una imagen de fondo extra, digamos, al tema nord, solo pon el archivo en `~/.config/omarchy/backgrounds/nord`.

La forma más fácil de hacerlo es ir a _Instalar > Estilo > Fondo_ en el Menú de Omarchy. Eso abrirá la carpeta donde se guardan los fondos de ese tema. Presiona `Super + Shift + F` para abrir otro gestor de archivos, encuentra tu fondo y cópialo ahí. Ahora quedará incluido entre las opciones de fondos entre las que puedes elegir con `Super + Ctrl + W`.

Los fondos también pueden ser videos, no solo imágenes fijas. Deja un archivo `mp4`, `m4v`, `mov`, `webm`, `mkv` o `avi` en la misma carpeta y aparecerá junto a las imágenes. Los videos los reproduce el motor de fondos de pantalla OWE. Decodifica el video una sola vez para todos los monitores y reproduce su sonido por la salida de audio predeterminada, y detiene la reproducción cuando nada puede verlo. Un fondo en video sigue consumiendo mucha más energía que uno fijo.

Los temas pueden incluir una intro corta para un fondo fijo. Para `backgrounds/road.webp`, el video correspondiente está en `backgrounds/intros/road.mp4`. Se reproduce automáticamente al arrancar, al cambiar a un tema con ese fondo seleccionado y al elegir ese fondo, y después vuelve a la imagen fija. Los videos de intro no aparecen en el selector de fondos y nunca se reproducen en bucle.

Desactivar _Apariencia > Animaciones_ también desactiva las intros de fondo. Omarchy hace esto por defecto en una máquina virtual. El comando `omarchy theme bg intro toggle` permite activar o desactivar las intros por separado. Actualizar un tema no reproduce ninguna intro.

Una imagen fija también puede tener un bucle, una versión discreta de la misma imagen que se sigue moviendo, en `backgrounds/loops/road.mp4`. Se reproduce en lugar de la imagen fija, después de su intro si tiene una, y se detiene cuando se desactivan las animaciones. Con batería, se muestra la imagen fija en su lugar, y el bucle vuelve en cuanto conectas el equipo. Los bucles no aparecen en el selector de fondos.

Puedes encontrar una colección enorme de fondos geniales y seleccionados en [dharmx/walls](https://github.com/dharmx/walls).

La pantalla de bloqueo muestra un fotograma fijo de un fondo en video, igual que muestra un fotograma fijo de un GIF animado.
