# Fondos

Cada tema incluye su propio conjunto de fondos, y puedes agregar los tuyos en `~/.config/omarchy/backgrounds/[theme]`. Si quieres agregar una imagen de fondo extra a, digamos, el tema nord, solo coloca el archivo en `~/.config/omarchy/backgrounds/nord`.

La forma más fácil de hacerlo es ir a _Instalar > Estilo > Fondo_ en el menú de Omarchy. Eso abrirá la carpeta donde se guardan los fondos de ese tema. Presiona `Super + Shift + F` para abrir otro administrador de archivos, busca tu fondo y cópialo ahí. Ahora estará incluido entre las opciones de fondos que puedes elegir con `Super + Ctrl + W`.

Los fondos también pueden ser videos, no solo imágenes fijas. Coloca un archivo `mp4`, `m4v`, `mov`, `webm`, `mkv` o `avi` en la misma carpeta y aparecerá junto a las imágenes. Los videos los reproduce el motor de fondos de pantalla OWE. Decodifica el video una sola vez para todos los monitores, reproduce su sonido por la salida de audio predeterminada y detiene la reproducción cuando deja de estar visible. Un fondo en video sigue consumiendo mucha más energía que uno fijo.

Los temas pueden incluir una breve introducción para un fondo fijo. Para `backgrounds/road.webp`, el video correspondiente está en `backgrounds/intros/road.mp4`. Se reproduce automáticamente al arrancar y al cambiar a un tema con ese fondo seleccionado, y luego vuelve a la imagen fija. Los videos de introducción no aparecen en el selector de fondos y nunca se repiten en bucle.

Desactivar _Apariencia > Animaciones_ también desactiva las introducciones de fondo. Omarchy hace esto por defecto en una máquina virtual. El comando `omarchy theme bg intro toggle` puede activar o desactivar las introducciones por separado. Volver a aplicar un tema o elegir otro fondo dentro del mismo tema no reproduce una introducción.

Puedes encontrar una enorme colección de fondos geniales y seleccionados en [dharmx/walls](https://github.com/dharmx/walls).

La pantalla de bloqueo muestra un fotograma fijo de un fondo en video, igual que muestra un fotograma fijo de un GIF animado.
