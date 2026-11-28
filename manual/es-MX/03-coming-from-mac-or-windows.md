# Si vienes de Mac o Windows

Si has pasado años en macOS o Windows, tus dedos saben cien cosas que tu cerebro olvidó que aprendió alguna vez. Este capítulo es la capa de traducción: a dónde van esos instintos en Omarchy. Las funciones en sí se tratan a fondo en otras partes: esto es solo el mapa.

### Super es el centro de todo

Toda la memoria muscular que construiste alrededor de Cmd o la tecla de Windows se transfiere a una tecla: Super. Esa es la tecla de Windows en un teclado de PC, y es el ancla de casi todos los atajos de teclado en Omarchy.

Tu reflejo de Spotlight o Raycast o el menú Inicio se convierte en `Super + Space`. Eso abre el menú de Omarchy, que abre aplicaciones, cambia ajustes, instala software, captura la pantalla: prácticamente todo. Empieza a escribir para filtrar. `Super + Alt + Space` muestra todas las aplicaciones en una sola cuadrícula, como lo hace Launchpad. Consulta [navegación](04-navigation.md).

### Sin iconos en el escritorio, y el dock no estorba

No hay iconos para acomodar en el escritorio, y el dock se oculta una vez que un espacio de trabajo tiene una ventana, hasta que empujas el puntero hasta su borde de la pantalla, el inferior a menos que lo muevas (consulta [navegación](04-navigation.md)). Las aplicaciones se abren con un atajo de teclado (`Super + Return` para la terminal, `Super + Shift + Return` para el navegador y `Super + K` para una lista de todo lo que está asignado) o desde el menú. La única pieza persistente de la interfaz es [la barra superior](05-the-top-bar.md), que cubre lo que antes hacían por ti la barra de menús, la bandeja del sistema y el Centro de notificaciones, y casi todos los widgets que tiene hacen algo con clic izquierdo, derecho y central.

### Las ventanas se acomodan solas

El cambio de mentalidad más grande: no arrastras ventanas ni las acoplas a mitades de la pantalla. Abres una ventana y ocupa toda la pantalla. Abres una segunda y se dividen la pantalla. Nunca tienes que pescar una ventana debajo de otra, porque las ventanas no se enciman.

Cuando de verdad necesitas una ventana flotante, `Super + T` saca la activa del mosaico (y la regresa). Pero primero dale una oportunidad real al mosaico: es el corazón de todo esto. [Navegación](04-navigation.md) te guía paso a paso.

Los espacios de trabajo te resultarán familiares: son los Spaces de macOS o los escritorios virtuales de Windows, excepto que sí los vas a usar, porque `Super + 1/2/3/4` salta directo a uno y `Super + Shift + 1/2/3/4` envía ahí la ventana activa. Sin retraso de animación, solo saltos instantáneos. Esto significa que quizá ni siquiera necesites varios monitores, si estabas acostumbrado a eso antes.

### Copiar y pegar simplemente funcionan

En Mac tenías Cmd + C en todas partes. En Windows tenías Ctrl + C en todas partes, excepto en la terminal, donde mata tu programa. Omarchy te da `Super + C`, `Super + X` y `Super + V`, y funcionan en todas partes, incluida la terminal. No tienes que aprender un reflejo distinto para la shell.

Gente de Windows: su historial del portapapeles con Win + V vive en `Super + Ctrl + V`, y guarda imágenes además de texto. Consulta [portapapeles unificado e historial](08-unified-clipboard-history.md).

### La tabla de traducción

| Lo que buscas | En Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / menú Inicio | `Super + Space` — el menú de Omarchy |
| AirDrop | LocalSend, con `Super + Ctrl + S` — consulta [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` o `Print Screen` — consulta [capturas de pantalla y grabación](12-screenshots-recording.md) |
| Centro de notificaciones | Historial de notificaciones en `Super + Shift + Alt + ,` |
| Time Machine (para el sistema) | [Instantáneas del sistema](47-system-snapshots.md) automáticas en cada actualización |
| App Store / descargar un instalador | _Install_ en el menú, o `omarchy pkg add` — consulta [otros paquetes](29-other-packages.md) |
| Configuración del sistema / Panel de control | _Setup_ en el menú, que edita archivos de configuración en texto plano — consulta [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, en `Super + Shift + F` — consulta [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome en `Super + Shift + Return`; elige otro en _Setup > Defaults > Browser_ — consulta [navegadores](23-browsers.md) |
| Preview / Photos | Omaview para imágenes, video y música, Document Viewer para PDFs — consulta [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, en `Super + Shift + N`; elige otro en _Setup > Defaults > Editor_ |

### Algunas cosas sí son diferentes

Muchos ajustes viven en archivos de texto que editas, no en paneles donde haces clic. Suena primitivo hasta que te das cuenta de que significa que cada ajuste se puede ver, copiar a tu siguiente máquina y poner bajo control de versiones. El menú _Setup_ te deja directo en el archivo correcto y reinicia lo que haya que reiniciar cuando terminas.

Las actualizaciones llegan con un solo comando: _Update > Omarchy_, que actualiza Omarchy mismo y cada paquete del sistema, tomando una instantánea antes. Sin actualizadores por aplicación molestándote en momentos aleatorios. Consulta [actualizaciones](30-updates.md).

El software viene de un gestor de paquetes, no de instaladores descargados.

Y cuando cierras una ventana, la aplicación sí se cierra. No hay limbo de macOS donde el programa sigue corriendo sin ventanas. `Super + W` — o `Super + Q`, si esa es la memoria muscular con la que llegaste — significa que se fue.

### En hardware Mac

Omarchy corre bien en Macs Intel, y en Macs M1, M2 y M3 con Omarchy for Apple Silicon. Consulta [compatibilidad con Mac](44-mac-support.md). Y el teclado se porta bien contigo: Omarchy no reasigna nada, y Linux trata la tecla Command como Super, así que Super queda justo donde siempre estuvo Cmd. Tu pulgar no va a notar la mudanza.

### Dale dos semanas

Los instintos se transfieren más rápido de lo que crees. Lee por encima el capítulo de [atajos de teclado](07-hotkeys.md) una vez, y cada vez que te quedes en blanco con una asignación, presiona `Super + K`: te muestra todas. Ese es el único atajo que en realidad tienes que memorizar.
