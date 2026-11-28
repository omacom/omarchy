# Si vienes de Mac o Windows

Si llevas años en macOS o Windows, tus dedos saben cien cosas que tu cerebro ya olvidó que aprendió. Este capítulo es la capa de traducción: a dónde van esos instintos en Omarchy. Las funciones en sí se cubren a fondo en otras partes: esto es solo el mapa.

### Super es el centro de todo

Toda la memoria muscular que construiste alrededor de Cmd o de la tecla de Windows se transfiere a una sola tecla: Super. Es la tecla de Windows en un teclado de PC, y es el ancla de casi todos los atajos de teclado en Omarchy.

Tu reflejo de Spotlight, Raycast o el menú Inicio se convierte en `Super + Space`. Eso abre el menú de Omarchy, que lanza aplicaciones, cambia ajustes, instala software, captura la pantalla: prácticamente todo. Empieza a escribir para filtrar. `Super + Alt + Space` muestra todas las aplicaciones en una sola rejilla, como lo hace Launchpad. Consulta [navegación](04-navigation.md).

### El escritorio no tiene iconos y el dock solo aparece en espacios flotantes

No hay iconos que ordenar en el escritorio, y no hay dock en un espacio de trabajo en mosaico — el dock solo aparece en un espacio de trabajo flotante (consulta [navegación](04-navigation.md)). Las aplicaciones se inician con un atajo de teclado (`Super + Return` para el terminal, `Super + Shift + Return` para el navegador y `Super + K` para una lista de todo lo que está asignado) o desde el menú. La única pieza persistente de la interfaz es [la barra superior](05-the-top-bar.md), que cubre lo que antes hacían por ti la barra de menús, la bandeja del sistema y el centro de notificaciones — y casi todos los componentes que tiene hacen algo con clic izquierdo, derecho y central.

### Las ventanas se colocan solas

El mayor cambio de mentalidad: no arrastras ventanas ni las ajustas a mitades de la pantalla. Abres una ventana y ocupa toda la pantalla. Abres una segunda y se dividen la pantalla. Nunca tienes que sacar una ventana de debajo de otra, porque las ventanas no se solapan.

Cuando de verdad necesitas una ventana flotante, `Super + T` saca la ventana activa del mosaico (y la devuelve). Pero primero dale una oportunidad real al mosaico: es el corazón de todo esto. [Navegación](04-navigation.md) te guía paso a paso.

Los espacios de trabajo te resultarán familiares: son los Spaces de macOS o los escritorios virtuales de Windows, excepto que estos sí los vas a usar, porque `Super + 1/2/3/4` salta directo a uno y `Super + Shift + 1/2/3/4` envía ahí la ventana activa. Sin retraso de animación, solo saltos instantáneos. Esto significa que, si antes estabas acostumbrado a eso, quizá ni siquiera necesites varios monitores.

### Copiar y pegar simplemente funciona

En Mac tenías Cmd + C en todas partes. En Windows tenías Ctrl + C en todas partes, excepto en la terminal, donde mata tu programa. Omarchy te da `Super + C`, `Super + X` y `Super + V`, y funcionan en todas partes, incluida la terminal. No tienes que aprender un reflejo aparte para el shell.

Para quienes vienen de Windows: el historial del portapapeles de Win + V está en `Super + Ctrl + V`, y guarda imágenes además de texto. Consulta [portapapeles unificado e historial](08-unified-clipboard-history.md).

### La tabla de traducción

| Buscas | En Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / menú Inicio | `Super + Space` — el menú de Omarchy |
| AirDrop | LocalSend, mediante `Super + Ctrl + S` — consulta [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` o `Print Screen` — consulta [capturas de pantalla y grabación](12-screenshots-recording.md) |
| Centro de notificaciones | Historial de notificaciones en `Super + Shift + Alt + ,` |
| Time Machine (para el sistema) | [Instantáneas automáticas del sistema](47-system-snapshots.md) en cada actualización |
| App Store / descargar un instalador | _Instalar_ en el menú, o `omarchy pkg add` — consulta [otros paquetes](29-other-packages.md) |
| Configuración del sistema / Panel de control | _Configurar_ en el menú, que edita archivos de configuración en texto plano — consulta [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, en `Super + Shift + F` — consulta [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome en `Super + Shift + Return`; elige otro en _Configurar > Predeterminados > Navegador_ — consulta [navegadores](23-browsers.md) |
| Preview / Photos | Omaview para imágenes, vídeo y música, Document Viewer para PDFs — consulta [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, en `Super + Shift + N`; elige otro en _Configurar > Predeterminados > Editor_ |

### Algunas cosas sí son diferentes de verdad

Muchos ajustes viven en archivos de texto que editas, no en paneles por los que haces clic. Suena primitivo hasta que te das cuenta de que significa que cada ajuste se puede ver, copiar a tu siguiente máquina y poner bajo control de versiones. El menú _Configuración_ te lleva directo al archivo correcto y reinicia lo que haya que reiniciar cuando terminas.

Las actualizaciones llegan con un solo comando — _Actualizar > Omarchy_ — que actualiza Omarchy mismo y todos los paquetes del sistema, y antes crea una instantánea. Nada de actualizadores por aplicación molestándote al azar. Consulta [actualizaciones](30-updates.md).

El software viene de un gestor de paquetes, no de instaladores descargados.

Y cuando cierras una ventana, la aplicación sí se cierra. No hay limbo como el de macOS, donde el programa sigue corriendo sin ventanas. `Super + W` — o `Super + Q`, si esa es la memoria muscular con la que llegaste — significa que se fue.

### En hardware Mac

Omarchy funciona bien en Mac con Intel, y en Mac con M1, M2 y M3 con Omarchy para Apple Silicon. Consulta [compatibilidad con Mac](44-mac-support.md). Y el teclado te trata bien: Omarchy no remapea nada, y Linux interpreta la tecla Command como Super, así que Super queda justo donde siempre estuvo Cmd. Tu pulgar ni siquiera notará el cambio.

### Dale dos semanas

Los instintos se transfieren más rápido de lo que crees. Hojea una vez el capítulo de [atajos de teclado](07-hotkeys.md), y cuando te quedes en blanco con una combinación, pulsa `Super + K`: te muestra todas. Ese es el único atajo que de verdad tienes que memorizar.
