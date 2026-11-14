# Portapapeles e historial unificados

En Linux, normalmente necesitas `Ctrl + Shift + C/V` para copiar y pegar en la terminal y `Ctrl + C/V` para hacerlo en cualquier otro lugar. ¡Es difícil acostumbrarse a eso para cualquiera que no haya nacido y crecido en Linux! Lo mismo pasa con el cambio de Super a Ctrl si vienes de Mac.

Omarchy resuelve ambos problemas con atajos de portapapeles unificados que funcionan (casi) en todas partes. Son:

| Atajo | Acción |
| ------- | ----------- |
| Super + A | Seleccionar todo |
| Super + C | Copiar |
| Super + X | Cortar |
| Super + V | Pegar |
| Super + Ctrl + V | Historial del portapapeles |

_Ten en cuenta que la mayoría de los entornos de agentes usan `Ctrl + V` para pegar imágenes, pero `Super + V` para pegar texto._

Usa `Super + A` y luego `Super + C` para copiar todo lo que haya en un campo de texto enfocado u otra app compatible con `Ctrl + A`. En una terminal, `Ctrl + A` lleva al inicio de la línea de comandos en lugar de seleccionar su texto.

### Historial del portapapeles

El historial del portapapeles lo proporciona el shell de Omarchy y funciona tanto para texto como para imágenes. Lo activas con `Super + Ctrl + V`, seleccionas tu entrada con Intro y eso se colocará en el portapapeles, listo para pegarse con `Super + V`.

 ![clipboard-history](images/clipboard-history.webp)

También puedes buscar en el historial con solo empezar a escribir:

 ![clipboard-history-search](images/clipboard-history-search.webp)
