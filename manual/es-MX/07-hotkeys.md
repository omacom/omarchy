# Atajos de teclado

Puedes ver todos los atajos principales del teclado con `Super + K` (atajos de Tmux con `Super + Alt + K` y atajos de Herdr con `Super + Ctrl + K`).

## Cómo están organizados los atajos

Cada atajo está en un plano, definido por sus modificadores, y cada plano tiene una sola función. Eso evita que los atajos se mezclen entre sí y significa que normalmente puedes adivinar dónde está cada cosa.

| Plano | Qué va ahí | Ejemplos |
| --- | --- | --- |
| `Super + key` | El sistema: ventanas, espacios de trabajo, distribuciones y menús principales | `Super + Space` menú de Omarchy, `Super + W` cerrar ventana, `Super + F` pantalla completa |
| `Super + Shift + key` | Aplicaciones | `Super + Shift + B` navegador, `Super + Shift + E` correo electrónico, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Paneles y menús del sistema | `Super + Ctrl + A` audio, `Super + Ctrl + N` red, `Super + Ctrl + C` menú de captura |
| `Super + Ctrl + Alt + key` | Acciones rápidas y avisos | `Super + Ctrl + Alt + T` mostrar la hora, `Super + Ctrl + Alt + B` batería, `Super + Ctrl + Alt + C` captura de pantalla |

Agregar `Alt` a un atajo te da una variante de lo mismo, nunca algo sin relación:

- `Super + Shift + B` abre el navegador; `Super + Shift + Alt + B` abre una ventana privada
- `Super + Shift + E` abre el correo electrónico; `Super + Shift + Alt + E` empieza uno nuevo
- `Super + F` activa la pantalla completa; `Super + Alt + F` activa el ancho completo
- `Super + Ctrl + C` abre el menú de captura; `Super + Ctrl + Alt + C` se salta el menú y toma una captura de pantalla

Al agregar un atajo:

1. Elige el plano según lo que hace, luego elige la tecla.
2. No muevas un atajo existente para hacer espacio. Busca una tecla libre en el plano correcto.
3. Usa `Alt` solo para una variante del atajo sin `Alt`.

Unos cuantos atajos rompen estas reglas porque son convenientes. `Shift` con una flecha o `Tab` mueve o invierte en lugar de abrir una aplicación, y `Print`, las teclas multimedia, `Alt + Tab` y `Ctrl + Alt + Del` funcionan como en cualquier otro lugar. Son excepciones, no patrones para copiar.

Si un atajo predeterminado no te conviene (digamos que quieres `Super + Shift + S` para capturas de pantalla como en Windows), cámbialo en `~/.config/hypr/bindings.lua`.

## Navegación

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + Space`           | Menú de Omarchy (aplicaciones y todo lo demás)    |
| `Super + Alt + Space` | Cuadrícula de aplicaciones |
| `Super + Escape` | Menú del sistema (suspender, reiniciar, etc.)  |
| `Super + Ctrl + L` | Bloquear la computadora |
| `Super + W` or `Super + Q` | Cerrar ventana             |
| `Ctrl + Alt + Del` | Cerrar todas las ventanas |
| `Super + T`               | Alternar la ventana entre mosaico/flotante             |
| `Super + J` | Alternar la posición de la ventana (horizontal/vertical) |
| `Super + O`               | Alternar la ventana emergente a fija y flotante |
| `Super + L`               | Recorrer las distribuciones dwindle, scrolling y flotante |
| `Super + Alt + L`         | Recorrer las distribuciones en sentido inverso |
| `Super + P`               | Alternar el estilo de ventana pseudo (natural vs. estirado) |
| `Super + F`                 | Activar pantalla completa              |
| `Super + Alt + F`                 | Activar ancho completo              |
| `Super + Ctrl + F`                 | Activar pantalla completa dentro de la ventana              |
| `Super + 1/2/3/4`         | Ir a un espacio de trabajo específico en el monitor enfocado |
| `Super + Tab` | Ir al siguiente espacio de trabajo en el monitor enfocado |
| `Super + Shift + Tab` | Ir al espacio de trabajo anterior en el monitor enfocado |
| `Super + Ctrl + Tab` | Ir al último espacio de trabajo usado en el monitor enfocado |
| `Super + Shift + 1/2/3/4` | Mover la ventana a un espacio de trabajo en el monitor enfocado |
| `Super + Shift + Alt + 1/2/3/4` | Mover la ventana a un espacio de trabajo en el monitor enfocado sin seguirla |
| `Super + S` | Alternar el scratchpad completo |
| `Super + Alt + S` | Mover la ventana al scratchpad completo |
| `Super + Grave` | Alternar la consola Quake |
| `Super + Shift + Grave` | Mover la ventana a la consola Quake |
| `Super + Shift + Ctrl + Arrows` | Mover la ventana al monitor en esa dirección |
| `Super + Shift + Alt + Arrows` | Mover el espacio de trabajo al monitor en esa dirección |
| `Super + Arrow`  | Mover el foco a la ventana en la dirección de la flecha, cruzando al monitor de ese lado al llegar al borde de la pantalla |
| `Super + Shift + Arrow`  | Intercambiar la ventana con otra en la dirección de la flecha, incluida una en el monitor de ese lado |
| `Super + Minus` | Expandir la ventana hacia la izquierda |
| `Super + Equal` | Encoger la ventana hacia la izquierda |
| `Super + Shift + Minus` | Encoger la ventana hacia arriba |
| `Super + Shift + Equal` | Expandir la ventana hacia abajo |
| `Super + Alt + Minus/Equal` | El mismo cambio de tamaño en pasos más pequeños |
| `Super + Ctrl + Minus/Equal` | El mismo cambio de tamaño en pasos más grandes |
| `Super + Alt + Home` | Guardar el ancho de la ventana |
| `Super + Home` | Restaurar el ancho guardado de la ventana |
| `Super + Left Mouse` | Arrastrar la ventana |
| `Super + Right Mouse` | Cambiar el tamaño de la ventana |
| `Super + Scroll Wheel` | Desplazarse por los espacios de trabajo en el monitor enfocado |
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
| `Super + /` | Avanzar por las opciones de escala del monitor |
| `Super + Alt + /` | Retroceder por las opciones de escala del monitor |
| `Alt + Tab` | Recorrer hacia adelante las ventanas del espacio de trabajo activo |
| `Alt + Shift + Tab` | Recorrer hacia atrás las ventanas del espacio de trabajo activo |
| `Ctrl + Alt + Tab`| Recorrer el foco hacia adelante por los monitores |
| `Ctrl + Alt + Shift + Tab`| Recorrer el foco hacia atrás por los monitores |

Los atajos de cambio de tamaño usan las teclas físicas `code:20` y `code:21` (XKB `<AE11>` y `<AE12>`), sin importar los caracteres impresos en el teclado. En teclados de EE. UU. estas teclas son `-` y `=`; en teclados japoneses (JIS) son `-` y `^`; en teclados en español son `'` y `¡`. En JIS, `Super + ^` es `Super + Equal`, mientras que `Super + Shift + -` (que escribe `=`) es `Super + Shift + Minus`.

## Controles del sistema

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Panel de audio    |
| `Super + Ctrl + B`           | Panel de Bluetooth    |
| `Super + Ctrl + N`           | Panel de Wi-Fi/red    |
| `Super + Ctrl + D`           | Panel de pantalla    |
| `Super + Ctrl + P`           | Panel de energía    |
| `Super + Ctrl + X`           | Panel de agentes    |
| `Super + Ctrl + Alt + D`           | Panel de calendario    |
| `Super + Ctrl + Alt + E`           | Panel de relojes mundiales    |
| `Super + Ctrl + 1-9`           | Alternar el panel de la barra por posición    |
| `Super + Ctrl + S` | Menú para compartir (mediante LocalSend) |
| `Super + Ctrl + C` | Controles de captura (captura de pantalla/grabación/selector) |
| `Super + Ctrl + O` | Menú de interruptores |
| `Super + Ctrl + H` | Menú de hardware |
| `Super + Ctrl + E` | Selector de emojis |
| `Super + Ctrl + .` | Transcodificar multimedia |
| `Super + Shift + Ctrl + A` | Elegir un agente de IA |

## Ajustes

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Brillo máximo de la pantalla |
| `Shift + Brightness Down` | Brillo mínimo de la pantalla |
| `Alt + Brightness Up/Down` | Cambios precisos de brillo del 1% |
| `Alt + Volume Up/Down` | Cambios precisos de volumen del 1% |
| `Keyboard Brightness Up/Down` | Retroiluminación del teclado más brillante/más tenue |
| `Keyboard Backlight` | Recorrer los niveles de retroiluminación del teclado |
| `Alt + Play` | Siguiente pista |
| `Alt + Shift + Play` | Pista anterior |

## Abrir aplicaciones

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Terminal con Tmux |
| `Super + Ctrl + Return` | Herdr (gestor de agentes) |
| `Super + Shift + Return`           | Navegador    |
| `Super + Shift + Alt + B`           | Navegador (privado/incógnito)    |
| `Super + Shift + F`           | Gestor de archivos    |
| `Super + Shift + Alt + F`           | Gestor de archivos en el cwd de la terminal    |
| `Super + Shift + M`           | Música (Spotify)    |
| `Super + Shift + Alt + M`           | Música (cliamp)    |
| `Super + Shift + /`           | Gestor de contraseñas (1password)    |
| `Super + Shift + Q`           | Calculadora (Omacalc)    |
| `Super + Shift + T`           | Actividad (btop)    |
| `Super + Shift + N`           | Editor (Neovim)  |
| `Super + Shift + C`           | Calendario ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | Correo electrónico ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Nuevo correo electrónico ([HEY](https://hey.com/))  |
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
| `Super + Shift + Alt + X`           | X Compose |
| `Super + Shift + Y`           | YouTube |

Cambia o agrega atajos en `~/.config/hypr/bindings.lua`.

## Portapapeles universal

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + A`           | Seleccionar todo en aplicaciones que admiten `Ctrl + A`    |
| `Super + C`           | Copiar    |
| `Super + X`           | Cortar (no en la terminal)    |
| `Super + V`           | Pegar    |
| `Super + Ctrl + V`           | Gestor del portapapeles    |

Normalmente en Linux necesitas `Ctrl + Shift + C/V` para copiar y pegar en la terminal y `Ctrl + C/V` para hacerlo en cualquier otro lugar. Estos atajos unificados del portapapeles de Omarchy funcionan en todas partes.

## Captura

| Hotkey              | Function                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Captura de pantalla                      |
| `Super + Ctrl + Alt + C`            | Captura de pantalla (la misma captura, para teclados sin tecla Print Screen) |
| `Super + Ctrl + C` | Menú de captura |
| `Alt + Print Screen`            | Grabación de pantalla                     |
| `Super + Shift + Ctrl + Alt + C` | Grabación de pantalla sin audio, sin pasar por el menú (presiona de nuevo para detenerla) |
| `Super + Print Screen` | Selector de color |
| `Super + Ctrl + Print Screen` | Extracción de texto al portapapeles |
| `Super + Alt + [` | Hacer más pequeña la superposición de la cámara web mientras grabas |
| `Super + Alt + ]` | Hacer más grande la superposición de la cámara web mientras grabas |
| `Alt + Shift + L` | Copiar la URL actual de la aplicación web o del navegador |
| `Alt + Shift + D` | Descargar el video de la página actual a `~/Videos` |
| `Alt + Space` | Iniciar/detener el dictado (requiere _Configuración > Predeterminados > Dictado_) |
| `Right Alt` | Mantén presionada para dictar (requiere _Configuración > Predeterminados > Dictado_) |

Con las grabaciones de pantalla, el atajo primero pregunta qué audio quieres y luego empieza a grabar. Presiónalo de nuevo para detenerla. Consulta [capturas de pantalla y grabación](12-screenshots-recording.md) para ver los detalles.

Todas las opciones de captura también están disponibles en _Activador > Captura_ del menú de Omarchy (`Super + Space`).

## Notificaciones

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + ,` | Actuar sobre la notificación más reciente: abrirla o presionar su único botón, elegir entre sus opciones o descartarla cuando no tenga ninguna  |
| `Super + Shift + ,` | Descartar todas las notificaciones |
| `Super + Ctrl + ,` | Controlar las notificaciones con el teclado  |
| `Super + Alt + ,` | Descartar la notificación más reciente  |
| `Super + Shift + Alt + ,` | Abrir el historial de notificaciones  |
| `Super + Ctrl + Alt + ,` | Alternar el silencio de las notificaciones  |

## Estilo

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Elegir un tema nuevo (también `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Elegir el fondo del tema (también `Super + Ctrl + Space`) |
| `Super + Backspace` | Alternar la transparencia de una ventana |
| `Super + Ctrl + Backspace` | Alternar el aspecto cuadrado de una sola ventana |

Las imágenes de fondo adicionales están en `~/.config/omarchy/backgrounds/<theme name>`. También están disponibles en _Instalar > Estilo > Fondo_ del menú de Omarchy.

Todas las opciones de estilo también están disponibles en _Estilo_ del menú de Omarchy (`Super + Space`).

## Interruptores

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Alternar el bloqueo por inactividad |
| `Super + Ctrl + Delete` | Encender/apagar la pantalla de la laptop |
| `Super + Ctrl + Alt + Delete` | Alternar la duplicación de la pantalla de la laptop |
| `Super + Shift + Space` | Alternar la barra superior  |
| `Shift + Mute` | Cambiar a la siguiente salida de audio |
| `Shift + Play` | Cambiar a la siguiente fuente multimedia |
| `Super + Shift + Backspace` | Alternar los espacios entre ventanas |
| `Super + Ctrl + Alt + F` | Alternar el escritorio a pantalla completa (barra superior + espacios entre ventanas) |

## Recordatorios

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Crear un recordatorio  |
| `Super + Ctrl + Alt + R` | Ver todos los recordatorios  |
| `Super + Ctrl + Shift + R` | Borrar todos los recordatorios  |

## Avisos

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Mostrar la hora como notificación  |
| `Super + Ctrl + Alt + B` | Mostrar la batería como notificación  |
| `Super + Ctrl + Alt + W` | Alternar el clima como notificación  |

## Tmux

La tecla de prefijo es `Ctrl + Space` (`Ctrl + B` también funciona). Puedes cambiar estos atajos en `~/.config/tmux/tmux.conf`.

### Paneles

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Prefix + v` | Dividir el panel al lado (vertical) |
| `Prefix + h` | Dividir el panel abajo (horizontal) |
| `Prefix + x` | Eliminar el panel |
| `Prefix + z` | Alternar el zoom del panel (pantalla completa) |
| `Alt + Enter` | Dividir el panel abajo (sin prefijo) |
| `Alt + Shift + Enter` | Dividir el panel al lado (sin prefijo) |
| `Alt + Escape` | Eliminar el panel (sin prefijo) |
| `Ctrl + Alt + Arrows` | Moverse entre paneles |
| `Ctrl + Alt + Shift + Arrows` | Cambiar el tamaño de los paneles |

### Ventanas

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Prefix + c` | Nueva ventana |
| `Prefix + k` | Eliminar ventana |
| `Prefix + r` | Cambiar el nombre de la ventana |
| `Alt + 1-9` | Ir a una ventana específica |
| `Alt + Arrow Left/Right` | Moverse entre ventanas |
| `Alt + Shift + Arrow Left/Right` | Mover la ventana a la izquierda/derecha |

### Sesiones

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Prefix + C` | Nueva sesión |
| `Prefix + K` | Eliminar sesión |
| `Prefix + R` | Cambiar el nombre de la sesión |
| `Prefix + N` | Siguiente sesión |
| `Prefix + P` | Sesión anterior |
| `Alt + Arrow Up/Down` | Moverse entre sesiones |
| `Prefix + s` | Listar sesiones |
| `Prefix + d` | Desconectarse de la sesión |

### Modo de copia (estilo vi)

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Prefix + [` | Entrar al modo de copia |
| `v` | Iniciar la selección (en modo de copia) |
| `y` | Copiar la selección (en modo de copia) |

### General

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Prefix + q` | Recargar la configuración |
| `Prefix + ?` | Mostrar los atajos de Tmux |
| `Prefix + :` | Línea de comandos |

### Funciones de distribución de Tmux

Estas funciones deben ejecutarse dentro de una sesión de Tmux.

| Command | Function |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Crear una distribución de desarrollo con editor, IA y terminal |
| `tdlm <ai> [<second_ai>]` | Crear una distribución de desarrollo por subdirectorio |
| `tsl <count> <command>` | Crear una distribución en enjambre con varios paneles |

## Terminal Ghostty

La terminal Ghostty se instala con _Instalar > Terminal_ desde el menú de Omarchy.

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nueva división abajo |
| `Ctrl + Shift + O` | Nueva división al lado |
| `Ctrl + Alt + Arrows` | Moverse entre divisiones |
| `Super + Ctrl + Shift + Arrows` | Cambiar el tamaño de la división en 10 líneas |
| `Super + Ctrl + Shift + Alt + Arrows` | Cambiar el tamaño de la división en 100 líneas |
| `Ctrl + Shift + T` | Nueva pestaña  |
| `Ctrl + Shift + Arrows` | Moverse entre pestañas |
| `Alt + Numbers` | Ir a una pestaña específica |
| `Shift + Pg Up/Down` | Desplazarse por el historial |
| `Ctrl + Left mouse` | Abrir el enlace en el navegador |

## Gestor de archivos

| Hotkey              | Function                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Ir a la ruta                     |
| `Space`               | Vista previa del archivo (las flechas navegan) |
| `Alt + Up`       | Ir a la carpeta padre        |

## Neovim (w/ lazyvim)

### Navegación

| Hotkey                   | Function                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Mostrar las opciones de comandos            |
| `Space Space`              | Abrir un archivo mediante búsqueda difusa      |
| `Space E`                  | Alternar la barra lateral                  |
| `Space G G`                | Mostrar los controles de git               |
| `Space S G`                | Buscar en el contenido de los archivos             |
| `Ctrl + W W`               | Saltar entre la barra lateral y el editor |
| `Ctrl + Left/right arrow`  | Cambiar el tamaño de la barra lateral          |
| `Shift + H`                      | Ir a la pestaña de archivo de la izquierda             |
| `Shift + L`                      | Ir a la pestaña de archivo de la derecha            |
| `Space B D`                | Cerrar la pestaña de archivo                  |

### Mientras estás en la barra lateral

| Hotkey                   | Function                        |
| ------------------------ | ------------------------------- |
| `A`                        | Agregar un archivo nuevo en el directorio padre      |
| `Shift + A`                | Agregar un subdirectorio nuevo en el directorio padre    |
| `D`                        | Eliminar el archivo/directorio resaltado     |
| `M`                        | Mover el archivo/directorio resaltado       |
| `R`                        | Cambiar el nombre del archivo/directorio resaltado     |
| `?`                        | Mostrar la ayuda de todos los comandos      |

[Consulta todos los atajos de Neovim configurados por LazyVim](https://www.lazyvim.org/keymaps).

## Emojis rápidos

Puedes usar `Super + Ctrl + E` para mostrar un selector de emojis completo que pondrá la selección en el portapapeles, o puedes usar estas opciones de acceso rápido.

| Hotkey       | EM | Clue       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | sonrisa      |
| `Shift + CapsLock M C` | 😂 | llorar        |
| `Shift + CapsLock M L` | 😍 | amor       |
| `Shift + CapsLock M V` | ✌️ | victoria    |
| `Shift + CapsLock M H` | ❤️ | corazón      |
| `Shift + CapsLock M Y` | 👍 | sí        |
| `Shift + CapsLock M N` | 👎 | no         |
| `Shift + CapsLock M F` | 🖕 | chingar       |
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
| `Shift + CapsLock M B` |🤯 | cabeza explotando |

## Completados rápidos

| Hotkey       | Completion       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (raya)   |
| `Shift + CapsLock Space N` | Tu nombre (como lo ingresaste durante la configuración)  |
| `Shift + CapsLock Space E` | Tu correo electrónico (como lo ingresaste durante la configuración)  |

Puedes agregar más por tu cuenta editando `~/.XCompose` y luego ejecutando `omarchy-restart-xcompose` en la terminal para que se apliquen los cambios.
