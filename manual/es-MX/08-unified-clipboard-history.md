# Portapapeles e historial unificados

Normalmente en Linux necesitas `Ctrl + Shift + C/V` para copiar y pegar en la terminal y `Ctrl + C/V` para hacerlo en cualquier otro lado. ¡Eso es difícil de acostumbrarse para cualquiera que no haya nacido y crecido en Linux! Lo mismo pasa con el cambio de super a ctrl, si vienes de Mac.

Omarchy resuelve ambos problemas con atajos de portapapeles unificados que funcionan (casi) en todas partes. Son estos:

| Atajo | Comando |
| ------- | ----------- |
| Super + C | Copiar |
| Super + X | Cortar |
| Super + V | Pegar |
| Super + Ctrl + V | Historial del portapapeles |

_Ten en cuenta que la mayoría de los arneses de agentes usarán `Ctrl + V` para pegar imágenes, pero `Super + V` para pegar texto._

### Historial del portapapeles

El historial del portapapeles lo proporciona el shell de Omarchy y funciona tanto para texto como para imágenes. Lo activas con `Super + Ctrl + V`, seleccionas tu entrada con Enter, y eso quedará en el portapapeles listo para pegarse con `Super + V`.

 ![clipboard-history](images/clipboard-history.webp)

También puedes buscar en el historial simplemente empezando a escribir:

 ![clipboard-history-search](images/clipboard-history-search.webp)
