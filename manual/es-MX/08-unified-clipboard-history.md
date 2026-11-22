# Portapapeles unificado e historial

Normalmente en Linux, necesitas `Ctrl + Shift + C/V` para copiar y pegar en la terminal y `Ctrl + C/V` para hacerlo en cualquier otro lugar. ¡Es difícil acostumbrarse a eso para cualquiera que no haya nacido y crecido en Linux! También lo es el cambio de super a ctrl, si vienes de Mac.

Omarchy resuelve ambos problemas con atajos unificados para el portapapeles que funcionan (casi) en todas partes. Son:

| Atajo | Comando |
| ------- | ----------- |
| Super + A | Seleccionar todo |
| Super + C | Copiar |
| Super + X | Cortar |
| Super + V | Pegar |
| Super + Ctrl + V | Historial del portapapeles |

_Ten en cuenta que la mayoría de los agent harnesses usarán `Ctrl + V` para pegar imágenes, pero `Super + V` para pegar texto._

Usa `Super + A` y luego `Super + C` para copiar todo lo que haya en un campo de texto con el foco u otra app que admita `Ctrl + A`. En una terminal, `Ctrl + A` lleva al inicio de la línea de comandos en lugar de seleccionar su texto.

### Historial del portapapeles

El historial del portapapeles lo proporciona el shell de Omarchy y funciona tanto para texto como para imágenes. Lo activas con `Super + Ctrl + V` y seleccionas la entrada con Return, lo que la pega directamente en la app en la que estabas. Usa `Shift + Return` para solo copiarla al portapapeles, `Alt + Return` para abrirla, `Delete` para quitarla del historial y `Shift + Delete` para borrar todo el historial.

 ![clipboard-history](images/clipboard-history.webp)

También puedes buscar en el historial con solo empezar a escribir:

 ![clipboard-history-search](images/clipboard-history-search.webp)
