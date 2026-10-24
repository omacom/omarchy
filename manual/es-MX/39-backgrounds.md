# Fondos

Cada tema trae su propio conjunto de fondos, y puedes agregar extras tuyos en `~/.config/omarchy/backgrounds/[theme]`. Si quieres agregar una imagen de fondo extra, digamos, al tema nord, solo pones el archivo en `~/.config/omarchy/backgrounds/nord`.

La manera más fácil de hacerlo es entrar a _Instalar > Estilo > Fondo_ en el menú de Omarchy. Eso abrirá la carpeta donde están guardados los fondos de ese tema. Presiona `Super + Shift + F` para abrir otro administrador de archivos, encuentra tu fondo y cópialo. Ahora estará incluido en las opciones de fondos entre las que puedes elegir con `Super + Ctrl + Space`.

Los fondos pueden ser videos además de imágenes fijas. Deja un archivo `mp4`, `m4v`, `mov`, `webm`, `mkv` o `avi` en la misma carpeta y aparecerá junto a las imágenes. Los videos los reproduce el motor de fondo de pantalla OWE. Decodifica el video una sola vez para todos los monitores y reproduce su sonido por la salida de audio por defecto, y detiene la reproducción cada vez que nada puede verlo. La pantalla de bloqueo dibuja la misma decodificación, en silencio, mediante OWE. Un fondo de pantalla en video sigue costando mucha más energía que uno fijo.

Los temas pueden incluir una introducción breve para un fondo fijo. Para `backgrounds/road.webp`, el video correspondiente vive en `backgrounds/intros/road.mp4`. Se reproduce automáticamente al arrancar y al cambiar a un tema con ese fondo seleccionado, y luego regresa a la imagen fija. Los videos de introducción no aparecen en el selector de fondos y nunca se repiten en bucle.

Desactivar _Activar > Apariencia > Animaciones_ también desactiva las introducciones de fondo. Omarchy hace esto por defecto en una máquina virtual. El comando `omarchy theme bg intro toggle` puede alternar las introducciones por separado. Actualizar un tema o elegir otro fondo dentro del mismo tema no reproduce una introducción.

Puedes encontrar una enorme colección de fondos geniales y curados en https://github.com/dharmx/walls.

Los fondos en video conservan una imagen fija en caché en la pantalla de bloqueo mientras la reproducción está en pausa o no está disponible. Los GIF animados se reproducen en el escritorio y muestran un cuadro fijo en la pantalla de bloqueo.
