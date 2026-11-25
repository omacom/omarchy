# Fondos

Cada tema viene con su propio conjunto de fondos, y puedes añadir extras tuyos en `~/.config/omarchy/backgrounds/[theme]`. Si quieres añadir una imagen de fondo extra a, digamos, el tema nord, solo pon el archivo en `~/.config/omarchy/backgrounds/nord`.

La forma más fácil es ir a _Instalar > Estilo > Fondo_ en el menú de Omarchy. Eso abrirá la carpeta donde se guardan los fondos de ese tema. Pulsa `Super + Shift + F` para abrir otro administrador de archivos, busca tu fondo y cópialo. Ahora estará incluido entre las opciones de fondos que puedes elegir con `Super + Ctrl + W`.

Si un tema no incluye fondos propios, Omarchy genera uno con los colores del tema. Muestra el logotipo de Omarchy en el color de acento sobre el color de fondo. Añade un fondo propio para sustituirlo.

Los fondos pueden ser vídeos además de imágenes fijas. Suelta un archivo `mp4`, `m4v`, `mov`, `webm`, `mkv` o `avi` en la misma carpeta y aparecerá junto a las imágenes. Los vídeos los reproduce el motor de fondos de pantalla OWE. Decodifica el vídeo una sola vez para todos los monitores y reproduce su sonido por la salida de audio predeterminada, y detiene la reproducción cuando ninguna pantalla lo muestra. Un fondo en vídeo sigue consumiendo mucha más energía que uno fijo.

Los temas pueden incluir una intro corta para un fondo fijo. Para `backgrounds/road.webp`, el vídeo correspondiente está en `backgrounds/intros/road.mp4`. Se reproduce automáticamente al arrancar, al cambiar a un tema con ese fondo seleccionado y al elegir ese fondo, y luego vuelve a la imagen fija. Los vídeos de intro no aparecen en el selector de fondos y nunca se reproducen en bucle.

Elegir _Apariencia > Desactivar animaciones_ también desactiva las introducciones de fondo. Omarchy hace esto por defecto en una máquina virtual. El comando `omarchy theme bg intro toggle` puede activar o desactivar las introducciones por separado. Actualizar un tema no reproduce una introducción.

Una imagen fija también puede tener un bucle, una versión tranquila de la misma imagen que se mantiene en movimiento, en `backgrounds/loops/road.mp4`. Se reproduce en lugar de la imagen fija, después de su introducción si tiene una, y se detiene cuando se desactivan las animaciones. Con batería, se muestra la imagen fija, y el bucle vuelve en cuanto conectas el equipo. Los bucles no aparecen en el selector de fondos.

Puedes encontrar una colección enorme de fondos geniales curados en [dharmx/walls](https://github.com/dharmx/walls).

La pantalla de bloqueo muestra un cuadro fijo de un fondo en vídeo, igual que muestra un cuadro fijo de un GIF animado.
