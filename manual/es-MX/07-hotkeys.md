# Atajos de teclado

Puedes ver todas las combinaciones de teclas principales con `Super + K` (las combinaciones de Tmux con `Super + Alt + K` y las combinaciones de Herdr con `Super + Ctrl + K`).

## Cómo están organizados los atajos

Cada atajo está en un plano, definido por sus modificadores, y cada plano tiene una función. Eso evita que los atajos se confundan entre sí, y significa que normalmente puedes adivinar dónde está cada cosa.

| Plano | Qué vive ahí | Ejemplos |
| --- | --- | --- |
| `Super + key` | El sistema: ventanas, espacios de trabajo, diseños y menús principales | `Super + Space` menú de Omarchy, `Super + W` cerrar ventana, `Super + F` pantalla completa |
| `Super + Shift + key` | Aplicaciones | `Super + Shift + B` navegador, `Super + Shift + E` correo, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Paneles y menús del sistema | `Super + Ctrl + A` audio, `Super + Ctrl + N` red, `Super + Ctrl + C` menú de captura |
| `Super + Ctrl + Alt + key` | Acciones rápidas y avisos | `Super + Ctrl + Alt + T` mostrar la hora, `Super + Ctrl + Alt + B` batería, `Super + Ctrl + Alt + C` captura de pantalla |

Agregar `Alt` a un atajo te da una variante de la misma cosa, nunca algo sin relación:

- `Super + Shift + B` abre el navegador; `Super + Shift + Alt + B` abre una ventana privada
- `Super + Shift + E` abre el correo; `Super + Shift + Alt + E` inicia uno nuevo
- `Super + F` pasa a pantalla completa; `Super + Alt + F` pasa a ancho completo
- `Super + Ctrl + C` abre el menú de captura; `Super + Ctrl + Alt + C` se salta el menú y toma una captura de pantalla

Al agregar un atajo:

1. Elige el plano según lo que hace, luego elige la tecla.
2. No muevas un atajo existente para hacer espacio. Encuentra una tecla libre en el plano correcto.
3. Usa `Alt` solo para una variante del atajo sin él.

Algunos atajos rompen estas reglas porque son convenientes. `Shift` con una flecha o `Tab` mueve o invierte en lugar de abrir una aplicación, y `Print`, las teclas multimedia, `Alt + Tab` y `Ctrl + Alt + Del` funcionan como en cualquier otro lugar. Son excepciones, no patrones para copiar.

Si un valor predeterminado no te conviene (por ejemplo, quieres `Super + Shift + S` para capturas de pantalla como en Windows), vuelve a asignarlo en `~/.config/hypr/bindings.lua`.

## Navegación

| Atajo                  | Función              |
| ----------------------- | --------------------- |
| `Super + Space`           | Menú de Omarchy (aplicaciones y todo lo demás)    |
| `Super + Alt + Space` | Cuadrícula de aplicaciones |
| `Super + Escape` | Menú del sistema (suspender, reiniciar, etc.)  |
| `Super + Ctrl + L` | Bloquear la computadora |
| `Super + W` or `Super + Q` | Cerrar ventana             |
| `Ctrl + Alt + Del` | Cerrar todas las ventanas |
| `Super + K` | Mostrar todos los atajos |
| `Super + Alt + K` | Mostrar atajos de tmux |
| `Super + Ctrl + K` | Mostrar atajos de herdr |
| `Super + M` | Minimizar ventana al dock |
| `Super + T`               | Alternar la ventana entre mosaico y flotante             |
| `Super + J` | Alternar la posición de la ventana (horizontal/vertical) |
| `Super + O`               | Alternar que la ventana emergente se vuelva fija y flotante |
| `Super + L`               | Recorrer los diseños dwindle, scrolling y flotante |
| `Super + Alt + L`         | Recorrer los diseños en orden inverso |
| `Super + P`               | Alternar el estilo de ventana pseudo (natural vs. estirado) |
| `Super + F`                 | Pasar a pantalla completa              |
| `Super + Alt + F`                 | Pasar a ancho completo              |
| `Super + Ctrl + F`                 | Pasar a pantalla completa dentro de la ventana              |
| `Super + 1…9/0`         | Ir a un espacio de trabajo específico (0 es 10) en el monitor enfocado |
| `Super + Tab` | Ir al siguiente espacio de trabajo en el monitor enfocado |
| `Super + Shift + Tab` | Ir al espacio de trabajo anterior en el monitor enfocado |
| `Super + Ctrl + Tab` | Ir al espacio de trabajo anterior en el monitor enfocado |
| `Super + Shift + 1…9/0` | Mover la ventana a un espacio de trabajo en el monitor enfocado |
| `Super + Shift + Alt + 1…9/0` | Mover la ventana a un espacio de trabajo en el monitor enfocado sin seguirla |
| `Super + S` | Alternar el scratchpad completo |
| `Super + Alt + S` | Mover la ventana al scratchpad completo |
| `Super + Grave` | Alternar la consola Quake |
| `Super + Shift + Grave` | Mover la ventana a la consola Quake |
| `Super + Shift + Ctrl + Arrows` | Mover la ventana al monitor en esa dirección |
| `Super + Shift + Alt + Arrows` | Mover el espacio de trabajo al monitor en esa dirección |
| `Super + Arrow`  | Mover el foco a la ventana en la dirección de la flecha, cruzando al monitor de ese lado en el borde de la pantalla |
| `Super + Shift + Arrow`  | Intercambiar la ventana con otra en la dirección de la flecha, incluida una en el monitor de ese lado |
| `Super + Minus` | Expandir la ventana a la izquierda |
| `Super + Equal` | Reducir la ventana a la izquierda |
| `Super + Shift + Minus` | Reducir la ventana hacia arriba |
| `Super + Shift + Equal` | Expandir la ventana hacia abajo |
| `Super + Alt + Minus/Equal` | El mismo cambio de tamaño en pasos más pequeños |
| `Super + Ctrl + Minus/Equal` | El mismo cambio de tamaño en pasos más grandes |
| `Super + Alt + Home` | Guardar el ancho de la ventana |
| `Super + Home` | Restaurar el ancho de la ventana guardado |
| `Super + Left Mouse` | Arrastrar la ventana |
| `Super + Right Mouse` | Cambiar el tamaño de la ventana |
| `Super + Scroll Wheel` | Recorrer los espacios de trabajo en el monitor enfocado |
| `Super + G`               | Alternar la agrupación de ventanas      |
| `Super + Alt + G`               | Sacar la ventana de la agrupación      |
| `Super + Alt + Tab`               | Recorrer las ventanas de la agrupación      |
| `Super + Alt + Shift + Tab`               | Recorrer hacia atrás las ventanas de la agrupación      |
| `Super + Alt + Scroll Wheel` | Recorrer las ventanas de la agrupación |
| `Super + Alt + 1/2/3/4/5`               | Ir a una ventana específica de la agrupación      |
| `Super + Alt + Arrow`  | Mover la ventana a la agrupación en la dirección de la flecha, incluida una en el monitor de ese lado |
| `Super + Ctrl + Left/Right`  | Moverse entre ventanas dentro de un grupo en mosaico |
| `Super + Ctrl + Z` | Acercar la pantalla (repetir para acercar más) |
| `Super + Ctrl + Alt + Z` | Alejar la pantalla por completo |
| `Super + /` | Avanzar entre las opciones de escala del monitor |
| `Super + Alt + /` | Retroceder entre las opciones de escala del monitor |
| `Alt + Tab` | Avanzar entre las ventanas del espacio de trabajo activo |
| `Alt + Shift + Tab` | Retroceder entre las ventanas del espacio de trabajo activo |
| `Ctrl + Alt + Tab`| Avanzar el foco entre monitores |
| `Ctrl + Alt + Shift + Tab`| Retroceder el foco entre monitores |
| `Super + I` | Cambiar el idioma de entrada (con más de un diseño o método de entrada) |
| `Super + Shift + I` | Volver al idioma de entrada anterior |

En un touchpad, los deslizamientos con tres y cuatro dedos cambian de espacio de trabajo, mueven ventanas y abren el menú y la consola Quake; consulta [teclado, mouse y trackpad](34-keyboard-mouse-trackpad.md) para ver los gestos.

Los atajos de cambio de tamaño usan las teclas físicas `code:20` y `code:21` (XKB `<AE11>` y `<AE12>`), sin importar los caracteres impresos en el teclado. En los teclados de EE. UU. estas teclas son `-` y `=`; en los teclados japoneses (JIS) son `-` y `^`; en los teclados en español son `'` y `¡`. En JIS, `Super + ^` es `Super + Equal`, mientras que `Super + Shift + -` (que escribe `=`) es `Super + Shift + Minus`.

## Controles del sistema

| Atajo                  | Función              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Panel de audio    |
| `Super + Ctrl + B`           | Panel de Bluetooth    |
| `Super + Ctrl + N`           | Panel de Wi-Fi/red    |
| `Super + Ctrl + D`           | Panel de pantalla    |
| `Super + Ctrl + P`           | Panel de energía    |
| `Super + Ctrl + X`           | Panel de agentes    |
| `Super + Ctrl + Alt + D`           | Panel de calendario    |
| `Super + Ctrl + Alt + E`           | Panel de reloj mundial    |
| `Super + Ctrl + 1-9`           | Alternar el panel de la barra por posición    |
| `Super + Ctrl + S` | Menú para compartir (vía LocalSend) |
| `Super + Ctrl + C` | Controles de captura (captura de pantalla/grabación/selector) |
| `Super + Ctrl + O` | Alternar el menú |
| `Super + Ctrl + H` | Menú de hardware |
| `Super + Ctrl + E` | Selector de emojis |
| `Super + Ctrl + .` | Transcodificar medios |
| `Super + Shift + Ctrl + A` | Elegir un agente de IA |
| `Power` key | Menú del sistema |
| `Super + Shift + Copilot` key | Menú de Omarchy |

## Ajustes

| Atajo                  | Función              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Brillo máximo de la pantalla |
| `Shift + Brightness Down` | Brillo mínimo de la pantalla |
| `Alt + Brightness Up/Down` | Cambios precisos del brillo de 1% |
| `Alt + Volume Up/Down` | Cambios precisos del volumen de 1% |
| `Keyboard Brightness Up/Down` | Retroiluminación del teclado más brillante/más tenue |
| `Keyboard Backlight` | Recorrer los niveles de retroiluminación del teclado |
| `Ctrl + Brightness Up/Down` | Retroiluminación del teclado más brillante/más tenue, en teclados sin teclas propias para ello |
| `Mic Mute` | Silenciar el micrófono |
| `Shift + Mute` | Cambiar la salida de audio |
| `Touchpad Toggle` | Encender o apagar el touchpad |
| `Display` key | Recorrer el diseño del espacio de trabajo |
| `Alt + Play` | Siguiente pista |
| `Alt + Shift + Play` | Pista anterior |

## Abrir aplicaciones

| Atajo                  | Función              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Terminal Tmux |
| `Super + Ctrl + Return` | Herdr (administrador de agentes) |
| `Super + Shift + Return` or `Super + Shift + B`  | Navegador    |
| `Super + Shift + Alt + B`           | Navegador (privado/incógnito)    |
| `Super + Shift + F`           | Administrador de archivos    |
| `Super + Shift + Alt + F`           | Administrador de archivos en el cwd de la terminal    |
| `Super + Shift + M`           | Música (Spotify)    |
| `Super + Shift + Alt + M`           | Música (cliamp)    |
| `Super + Shift + /`           | Administrador de contraseñas (1password)    |
| `Super + Shift + Q` or `Calculator` key  | Calculadora (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, una vez instalado)    |
| `Super + Shift + T`           | Actividad (btop)    |
| `Super + Shift + N`           | Editor (Plain, o el predeterminado que hayas elegido)  |
| `Super + Shift + C`           | Calendario ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | Correo ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Correo nuevo ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | IA (ChatGPT)  |
| `Super + Shift + Alt + A`           | IA (Grok)  |
| `Super + Shift + G`           | Mensajería (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Mensajería (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Mensajería (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Escritura (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X (nueva publicación) |
| `Super + Shift + Y`           | YouTube |

Cambia/agrega asignaciones en `~/.config/hypr/bindings.lua`.

## Portapapeles universal

| Atajo                  | Función              |
| ----------------------- | --------------------- |
| `Super + A`           | Seleccionar todo en aplicaciones que admiten `Ctrl + A`    |
| `Super + C`           | Copiar    |
| `Super + X`           | Cortar (no en la terminal)    |
| `Super + V`           | Pegar    |
| `Super + Ctrl + V`           | Administrador del portapapeles    |

Normalmente en Linux necesitas `Ctrl + Shift + C/V` para copiar y pegar en la terminal y `Ctrl + C/V` para hacerlo en cualquier otro lugar. Estos atajos unificados del portapapeles de Omarchy funcionan en todas partes.

## Captura

| Atajo              | Función                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Captura de pantalla                      |
| `Super + Ctrl + Alt + C`            | Captura de pantalla (la misma captura, para teclados sin tecla Print Screen) |
| `Super + Ctrl + C` | Menú de captura |
| `Alt + Print Screen`            | Grabación de pantalla                     |
| `Super + Shift + Ctrl + Alt + C` | Grabación de pantalla sin audio, sin pasar por el menú (presiona de nuevo para detener) |
| `Super + Print Screen` | Selector de color |
| `Super + Ctrl + Print Screen` | Extracción de texto al portapapeles |
| `Super + Alt + [` | Hacer más pequeña la superposición de la webcam durante la grabación |
| `Super + Alt + ]` | Hacer más grande la superposición de la webcam durante la grabación |
| `Alt + Shift + L` | Copiar la URL actual de la webapp o del navegador |
| `Alt + Shift + D` | Descargar el video de la página actual a `~/Videos` |
| `Alt + Space` | Iniciar/detener el dictado (requiere _Setup > Defaults > Dictation_) |
| `Right Alt` | Mantener presionado para dictar (requiere _Setup > Defaults > Dictation_) |

Con las grabaciones de pantalla, el atajo primero pregunta qué audio quieres y luego empieza a grabar. Presiónalo de nuevo para detener. Consulta [capturas de pantalla y grabación](12-screenshots-recording.md) para ver los detalles.

Todas las opciones de captura también están disponibles en _Trigger > Capture_ en el menú de Omarchy (`Super + Space`).

## Notificaciones

| Atajo                  | Función              |
| ----------------------- | --------------------- |
| `Super + ,` | Actuar sobre la notificación más reciente: abrirla o presionar su único botón, elegir entre sus opciones o descartarla cuando no tenga ninguna  |
| `Super + Shift + ,` | Descartar todas las notificaciones |
| `Super + Ctrl + ,` | Controlar las notificaciones con el teclado  |
| `Super + Alt + ,` | Descartar la notificación más reciente  |
| `Super + Shift + Alt + ,` | Abrir el historial de notificaciones  |
| `Super + Ctrl + Alt + ,` | Alternar el silenciamiento de notificaciones  |

## Estilo

| Atajo                  | Función              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Elegir un tema nuevo (también `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Elegir el fondo del tema (también `Super + Ctrl + Space`) |
| `Super + Backspace` | Alternar la transparencia en una ventana |
| `Super + Ctrl + Backspace` | Alternar el aspecto cuadrado de una sola ventana |

Las imágenes de fondo adicionales están en `~/.config/omarchy/backgrounds/<theme name>`. También disponible vía _Install > Style > Background_ en el menú de Omarchy.

Todas las opciones de estilo también están disponibles en _Appearance_ en el menú de Omarchy (`Super + Space`).

## Activar y desactivar

| Atajo                  | Función              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Alternar el bloqueo por inactividad |
| `Super + Ctrl + Delete` | Alternar la pantalla de la laptop encendida/apagada |
| `Super + Ctrl + Alt + Delete` | Alternar la duplicación de la pantalla de la laptop |
| `Super + Shift + Space` | Alternar la barra superior  |
| `Shift + Mute` | Cambiar a la siguiente salida de audio |
| `Shift + Play` | Cambiar a la siguiente fuente multimedia |
| `Super + Shift + Backspace` | Alternar los espacios entre ventanas |
| `Super + Ctrl + Alt + F` | Alternar el escritorio a pantalla completa (barra superior + espacios entre ventanas) |

## Recordatorios

| Atajo                  | Función              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Establecer un recordatorio  |
| `Super + Ctrl + Alt + R` | Ver todos los recordatorios  |
| `Super + Ctrl + Shift + R` | Borrar todos los recordatorios  |

## Avisos

| Atajo                  | Función              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Mostrar la hora como notificación  |
| `Super + Ctrl + Alt + B` | Mostrar la batería como notificación  |
| `Super + Ctrl + Alt + W` | Alternar el clima como notificación  |

## Tmux

La tecla de prefijo es `Ctrl + Space` (`Ctrl + B` también funciona). Puedes cambiar estas asignaciones en `~/.config/tmux/tmux.conf`.

### Paneles

| Atajo                  | Función              |
| ----------------------- | --------------------- |
| `Prefix + v` | Dividir el panel al lado (vertical) |
| `Prefix + h` | Dividir el panel abajo (horizontal) |
| `Prefix + x` | Cerrar el panel |
| `Prefix + z` | Alternar el zoom del panel (pantalla completa) |
| `Alt + Enter` | Dividir el panel abajo (sin prefijo) |
| `Alt + Shift + Enter` | Dividir el panel al lado (sin prefijo) |
| `Alt + Escape` | Cerrar el panel (sin prefijo) |
| `Ctrl + Alt + Arrows` | Moverse entre paneles |
| `Ctrl + Alt + Shift + Arrows` | Cambiar el tamaño de los paneles |

### Ventanas

| Atajo                  | Función              |
| ----------------------- | --------------------- |
| `Prefix + c` | Ventana nueva |
| `Prefix + k` | Cerrar ventana |
| `Prefix + r` | Renombrar ventana |
| `Alt + 1-9` | Ir a una ventana específica |
| `Alt + Arrow Left/Right` | Moverse entre ventanas |
| `Alt + Shift + Arrow Left/Right` | Mover la ventana a la izquierda/derecha |

### Sesiones

| Atajo                  | Función              |
| ----------------------- | --------------------- |
| `Prefix + C` | Sesión nueva |
| `Prefix + K` | Cerrar sesión |
| `Prefix + R` | Renombrar sesión |
| `Prefix + N` | Sesión siguiente |
| `Prefix + P` | Sesión anterior |
| `Alt + Arrow Up/Down` | Moverse entre sesiones |
| `Prefix + s` | Enumerar sesiones |
| `Prefix + d` | Desconectarse de la sesión |

### Modo de copia (estilo vi)

| Atajo                  | Función              |
| ----------------------- | --------------------- |
| `Prefix + [` | Entrar al modo de copia |
| `v` | Iniciar la selección (en modo de copia) |
| `y` | Copiar la selección (en modo de copia) |

### General

| Atajo                  | Función              |
| ----------------------- | --------------------- |
| `Prefix + q` | Recargar la configuración |
| `Prefix + ?` | Mostrar los atajos de Tmux |
| `Prefix + :` | Prompt de comandos |

### Funciones de diseño de Tmux

Estas funciones deben ejecutarse dentro de una sesión de Tmux.

| Comando | Función |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Crear un diseño de desarrollo con editor, IA y terminal |
| `tdlm <ai> [<second_ai>]` | Crear un diseño de desarrollo por subdirectorio |
| `tsl <count> <command>` | Crear un diseño swarm con varios paneles |

## Terminal Ghostty

La terminal Ghostty se instala usando _Install > Terminal_ vía el menú de Omarchy.

| Atajo                  | Función              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nueva división abajo |
| `Ctrl + Shift + O` | Nueva división al lado |
| `Ctrl + Alt + Arrows` | Moverse entre divisiones |
| `Super + Ctrl + Shift + Arrows` | Cambiar el tamaño de la división en 10 líneas |
| `Super + Ctrl + Shift + Alt + Arrows` | Cambiar el tamaño de la división en 100 líneas |
| `Ctrl + Shift + T` | Nueva pestaña  |
| `Ctrl + Shift + Arrows` | Moverse entre pestañas |
| `Alt + Numbers` | Ir a una pestaña específica |
| `Shift + Pg Up/Down` | Desplazar el historial |
| `Ctrl + Left mouse` | Abrir el enlace en el navegador |

## Administrador de archivos

| Atajo              | Función                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Ir a la ruta                     |
| `Space`               | Vista previa del archivo (las flechas navegan) |
| `Alt + Up`       | Subir a la carpeta principal        |

## Neovim (con lazyvim)

### Navegación

| Atajo                   | Función                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Mostrar las opciones de comandos            |
| `Space Space`              | Abrir un archivo mediante búsqueda difusa      |
| `Space E`                  | Alternar la barra lateral                  |
| `Space G G`                | Mostrar los controles de git               |
| `Space S G`                | Buscar el contenido del archivo             |
| `Ctrl + W W`               | Saltar entre la barra lateral y el editor |
| `Ctrl + Left/right arrow`  | Cambiar el tamaño de la barra lateral          |
| `Shift + H`                      | Ir a la pestaña de archivo de la izquierda             |
| `Shift + L`                      | Ir a la pestaña de archivo de la derecha            |
| `Space B D`                | Cerrar la pestaña de archivo                  |

### Mientras estás en la barra lateral

| Atajo                   | Función                        |
| ------------------------ | ------------------------------- |
| `A`                        | Agregar un archivo nuevo en el directorio principal      |
| `Shift + A`                | Agregar un subdirectorio nuevo en el directorio principal    |
| `D`                        | Eliminar el archivo/directorio resaltado     |
| `M`                        | Mover el archivo/directorio resaltado       |
| `R`                        | Renombrar el archivo/directorio resaltado     |
| `?`                        | Mostrar la ayuda de todos los comandos      |

[Consulta todos los atajos de Neovim configurados por LazyVim](https://www.lazyvim.org/keymaps).

## Emojis rápidos

Puedes usar `Super + Ctrl + E` para mostrar un selector de emojis completo que pondrá la selección en el portapapeles, o puedes usar estas opciones de acceso rápido.

| Atajo       | EM | Pista       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | sonrisa      |
| `Shift + CapsLock M C` | 😂 | llanto        |
| `Shift + CapsLock M L` | 😍 | amor       |
| `Shift + CapsLock M V` | ✌️ | victoria    |
| `Shift + CapsLock M H` | ❤️ | corazón      |
| `Shift + CapsLock M Y` | 👍 | sí        |
| `Shift + CapsLock M N` | 👎 | no         |
| `Shift + CapsLock M F` | 🖕 | fuck       |
| `Shift + CapsLock M W` | 🤞 | deseo       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | beso       |
| `Shift + CapsLock M E` | 🙄 | ojos en blanco    |
| `Shift + CapsLock M I` | 😉 | guiño       |
| `Shift + CapsLock M P` | 🙏 | rezar |
| `Shift + CapsLock M D` | 🤤 | babear      |
| `Shift + CapsLock M M` | 💰 | dinero      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | brindis      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | saludo |
| `Shift + CapsLock M A` |💪 | brazo |
| `Shift + CapsLock M B` |🤯 | explotando |

## Completados rápidos

| Atajo       | Completado       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (raya)   |
| `Shift + CapsLock Space N` | Tu nombre (como lo ingresaste durante la configuración)  |
| `Shift + CapsLock Space E` | Tu correo electrónico (como lo ingresaste durante la configuración)  |

Puedes agregar más por tu cuenta editando `~/.XCompose`, luego ejecutando `omarchy restart xcompose` en la terminal para que se apliquen los cambios.
