# Si vienes de Mac o Windows

Si pasaste años en macOS o Windows, tus dedos saben cien cosas que tu cerebro olvidó que alguna vez aprendió. Este capítulo es la capa de traducción: a dónde van esos instintos en Omarchy. Las funciones en sí se tratan a fondo en otras partes — esto es solo el mapa.

### Super es el centro de todo

Toda la memoria muscular que construiste alrededor de Cmd o la tecla Windows se transfiere a una sola tecla: Super. Es la tecla Windows en un teclado de PC, y es el ancla de casi todos los atajos de teclado en Omarchy.

Tu reflejo de Spotlight, Raycast o el menú Inicio se convierte en `Super + Space`. Eso abre el menú de Omarchy, que abre apps, cambia ajustes, instala software, captura la pantalla — prácticamente todo. Empieza a escribir para filtrar. `Super + Alt + Space` muestra todas las apps en una sola cuadrícula, como lo hace Launchpad. Consulta [navegación](04-navigation.md).

### Sin iconos en el escritorio, y el dock solo aparece cuando flotas

Sin iconos que acomodar en el escritorio, y sin dock en un espacio de trabajo en mosaico — el dock solo aparece en un espacio de trabajo flotante (consulta [navegación](04-navigation.md)). Las apps se abren desde un atajo de teclado (`Super + Return` para la terminal, `Super + Shift + Return` para el navegador y `Super + K` para una lista de todo lo que está asignado) o desde el menú. La única pieza persistente de la interfaz es [la barra superior](05-the-top-bar.md), que cubre lo que antes hacían por ti la barra de menús, la bandeja del sistema y Notification Center — y casi todos los widgets que tiene hacen algo con clic izquierdo, derecho y central.

### Las ventanas se acomodan solas

El cambio de mentalidad más grande: no arrastras ventanas ni las ajustas a mitades de la pantalla. Abres una ventana y ocupa toda la pantalla. Abres una segunda y se dividen la pantalla. Nunca tienes que pescar una ventana debajo de otra, porque las ventanas no se enciman.

Cuando de verdad necesitas una ventana flotante, `Super + T` saca la ventana activa del mosaico (y la regresa). Pero primero dale una oportunidad real al mosaico — es el corazón de todo esto. [Navegación](04-navigation.md) te guía paso a paso.

Los espacios de trabajo te van a resultar familiares: son los Spaces de macOS o los escritorios virtuales de Windows, excepto que ahora sí los vas a usar, porque `Super + 1/2/3/4` salta directo a uno y `Super + Shift + 1/2/3/4` manda ahí la ventana activa. Sin retraso de animación, solo saltos instantáneos. Esto significa que quizá ni siquiera necesites varios monitores, si antes estabas acostumbrado a eso.

### Copiar y pegar simplemente funcionan

En la Mac tenías Cmd + C en todas partes. En Windows tenías Ctrl + C en todas partes — excepto en la terminal, donde mata tu programa. Omarchy te da `Super + C`, `Super + X` y `Super + V`, y funcionan en todas partes, incluida la terminal. No tienes que aprender un reflejo aparte para la shell.

Gente de Windows: su historial del portapapeles de Win + V vive en `Super + Ctrl + V`, y guarda imágenes además de texto. Consulta [portapapeles unificado e historial](08-unified-clipboard-history.md).

### La tabla de traducción

| Buscas | En Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — el menú de Omarchy |
| AirDrop | LocalSend, mediante `Super + Ctrl + S` — consulta [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` o `Print Screen` — consulta [capturas de pantalla y grabación](12-screenshots-recording.md) |
| Notification Center | Historial de notificaciones en `Super + Shift + Alt + ,` |
| Time Machine (para el sistema) | [instantáneas del sistema](47-system-snapshots.md) automáticas en cada actualización |
| App Store / descargar un instalador | _Install_ en el menú, o `omarchy pkg add` — consulta [otros paquetes](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ en el menú, que edita archivos de configuración en texto plano — consulta [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, en `Super + Shift + F` — consulta [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome en `Super + Shift + Return`; elige otro en _Setup > Defaults > Browser_ — consulta [navegadores](23-browsers.md) |
| Preview / Photos | Omaview para imágenes, video y música, Document Viewer para archivos PDF — consulta [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, en `Super + Shift + N`; elige otro en _Setup > Defaults > Editor_ |

### Algunas cosas sí son diferentes de verdad

Muchos ajustes viven en archivos de texto que editas, no en paneles por los que vas haciendo clic. Eso suena primitivo hasta que te das cuenta de que significa que cada ajuste se puede ver, copiar a tu siguiente computadora y meter en control de versiones. El menú _Setup_ te deja directo en el archivo correcto y reinicia lo que haya que reiniciar cuando terminas.

Las actualizaciones llegan por un solo comando — _Update > Omarchy_ — que actualiza el propio Omarchy y todos los paquetes del sistema, y antes crea una instantánea. Nada de actualizadores por app molestándote en momentos al azar. Consulta [actualizaciones](30-updates.md).

El software viene de un gestor de paquetes, no de instaladores descargados.

Y cuando cierras una ventana, la app sí se cierra de verdad. No existe ese limbo de macOS en el que el programa sigue corriendo sin ventanas. `Super + W` — o `Super + Q`, si esa es la memoria muscular con la que llegaste — significa que desapareció.

### En hardware Mac

Omarchy funciona bien en Mac con Intel — consulta [soporte para Mac](44-mac-support.md). Y el teclado se porta bien contigo: Omarchy no reasigna nada, y Linux trata la tecla Command como Super, así que Super queda justo donde siempre estuvo Cmd. Tu pulgar ni va a notar el cambio.

### Dale dos semanas

Los instintos se transfieren más rápido de lo que crees. Hojea una vez el capítulo de [atajos de teclado](07-hotkeys.md), y cada vez que te quedes en blanco con una asignación, presiona `Super + K` — te muestra todas. Ese es el único atajo que de verdad tienes que memorizar.
