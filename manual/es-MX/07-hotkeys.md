# Atajos de teclado

Puedes ver todos los atajos de teclado principales con `Super + K` (atajos de Tmux con `Super + Alt + K` y atajos de Herdr con `Super + Ctrl + K`).

## Cómo están organizados los atajos

Cada atajo vive en un plano, definido por sus modificadores, y cada plano tiene una sola función. Eso evita que los atajos se mezclen, y significa que por lo general puedes adivinar dónde está cada cosa.

| Plano | Qué vive ahí | Ejemplos |
| --- | --- | --- |
| `Super + key` | El sistema: ventanas, espacios de trabajo, diseños y menús principales | `Super + Space` menú de Omarchy, `Super + W` cerrar ventana, `Super + F` pantalla completa |
| `Super + Shift + key` | Aplicaciones | `Super + Shift + B` navegador, `Super + Shift + E` correo, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Paneles y menús del sistema | `Super + Ctrl + A` audio, `Super + Ctrl + N` red, `Super + Ctrl + C` menú de captura |
| `Super + Ctrl + Alt + key` | Acciones rápidas y avisos | `Super + Ctrl + Alt + T` mostrar la hora, `Super + Ctrl + Alt + B` batería, `Super + Ctrl + Alt + C` captura de pantalla |

Agregar `Alt` a un atajo te da una variante de lo mismo, nunca algo sin relación:

- `Super + Shift + B` abre el navegador; `Super + Shift + Alt + B` abre una ventana privada
- `Super + Shift + E` abre el correo; `Super + Shift + Alt + E` inicia uno nuevo
- `Super + F` pasa a pantalla completa; `Super + Alt + F` pasa a ancho completo
- `Super + Ctrl + C` abre el menú de captura; `Super + Ctrl + Alt + C` se salta el menú y toma una captura de pantalla

Al agregar un atajo:

1. Elige el plano según lo que hace, luego elige la tecla.
2. No muevas un atajo existente para hacer espacio. Encuentra una tecla libre en el plano correcto.
3. Usa `Alt` solo para una variante del atajo sin `Alt`.

Unos cuantos atajos rompen estas reglas porque son prácticos. `Shift` con una flecha o `Tab` mueve o invierte en lugar de abrir una aplicación, y `Print`, las teclas multimedia, `Alt + Tab` y `Ctrl + Alt + Del` funcionan como en cualquier otro lado. Son excepciones, no patrones para copiar.

Si un atajo predeterminado no te conviene (digamos que quieres `Super + Shift + S` para capturas de pantalla como en Windows), reasígnalo en `~/.config/hypr/bindings.lua`.

## Navegación

| Atajo                  | Función              |
| ----------------------- | --------------------- |
| `Super + Space`           | Menú de Omarchy (aplicaciones y todo lo demás)    |
| `Super + Alt + Space` | Cuadrícula de aplicaciones |
| `Super + Escape` | Menú del sistema (suspender, reiniciar, etc.)  |
| `Super + Ctrl + L` | Bloquear la computadora |
| `Super + W` o `Super + Q` | Cerrar ventana             |
| `Ctrl + Alt + Del` | Cerrar todas las ventanas |
| `Super + K` | Mostrar todos los atajos |
| `Super + Alt + K` | Mostrar atajos de tmux |
| `Super + Ctrl + K` | Mostrar atajos de herdr |
| `Super + M` | Minimizar ventana al dock |
| `Super + T`               | Alternar ventana entre mosaico/flotante             |
| `Super + J` | Alternar posición de la ventana (horizontal/vertical) |
| `Super + O`               | Alternar que la ventana emergente pase a sticky'n'floating |
| `Super + L`               | Recorrer los diseños dwindle, scrolling y floating |
| `Super + Alt + L`         | Recorrer los diseños en sentido inverso |
| `Super + P`               | Alternar estilo pseudo de ventana (natural vs. estirado) |
| `Super + F`                 | Pasar a pantalla completa              |
| `Super + Alt + F`                 | Pasar a ancho completo              |
| `Super + Ctrl + F`                 | Pasar a pantalla completa dentro de la ventana              |
| `Super + 1…9/0`         | Ir al espacio de trabajo específico (0 es 10) en el monitor enfocado |
| `Super + Tab` | Ir al siguiente espacio de trabajo en el monitor enfocado |
| `Super + Shift + Tab` | Ir al espacio de trabajo anterior en el monitor enfocado |
| `Super + Ctrl + Tab` | Ir al espacio de trabajo previo en el monitor enfocado |
| `Super + Shift + 1…9/0` | Mover ventana al espacio de trabajo en el monitor enfocado |
| `Super + Shift + Alt + 1…9/0` | Mover ventana al espacio de trabajo en el monitor enfocado sin seguirla |
| `Super + S` | Alternar scratchpad completo |
| `Super + Alt + S` | Mover ventana al scratchpad completo |
| `Super + the key above Tab` (acento grave en distribuciones de EE. UU.) | Alternar consola Quake |
| `Super + Shift + the key above Tab` (acento grave en distribuciones de EE. UU.) | Mover ventana a la consola Quake |
| `Super + Shift + Ctrl + Arrows` | Mover ventana al monitor en esa dirección |
| `Super + Shift + Alt + Arrows` | Mover espacio de trabajo al monitor en esa dirección |
| `Super + Arrow`  | Mover el foco a la ventana en la dirección de la flecha, cruzando al monitor de ese lado en el borde de la pantalla |
| `Super + Shift + Arrow`  | Intercambiar ventana con otra en la dirección de la flecha, incluida una en el monitor de ese lado |
| `Super + Minus` | Expandir ventana a la izquierda |
| `Super + Equal` | Reducir ventana a la izquierda |
| `Super + Shift + Minus` | Reducir ventana hacia arriba |
| `Super + Shift + Equal` | Expandir ventana hacia abajo |
| `Super + Alt + Minus/Equal` | El mismo redimensionamiento en pasos más pequeños |
| `Super + Ctrl + Minus/Equal` | El mismo redimensionamiento en pasos más grandes |
| `Super + Alt + Home` | Guardar ancho de la ventana |
| `Super + Home` | Restaurar ancho de ventana guardado |
| `Super + Left Mouse` | Arrastrar ventana |
| `Super + Right Mouse` | Redimensionar ventana |
| `Super + Scroll Wheel` | Recorrer espacios de trabajo en el monitor enfocado |
| `Super + G`               | Alternar agrupación de ventanas      |
| `Super + Alt + G`               | Sacar ventana de la agrupación      |
| `Super + Alt + Tab`               | Recorrer ventanas en la agrupación      |
| `Super + Alt + Shift + Tab`               | Recorrer hacia atrás las ventanas en la agrupación      |
| `Super + Alt + Scroll Wheel` | Recorrer ventanas en la agrupación |
| `Super + Alt + 1/2/3/4/5`               | Ir a ventana específica en la agrupación      |
| `Super + Alt + Arrow`  | Mover ventana a la agrupación en la dirección de la flecha, incluida una en el monitor de ese lado |
| `Super + Ctrl + Left/Right`  | Moverse entre ventanas dentro de un grupo en mosaico |
| `Super + Ctrl + Z` | Acercar la pantalla (repetir para acercar más) |
| `Super + Ctrl + Alt + Z` | Alejar la pantalla por completo |
| `Super + /` | Avanzar por las opciones de escala del monitor |
| `Super + Alt + /` | Retroceder por las opciones de escala del monitor |
| `Alt + Tab` | Recorrer hacia adelante las ventanas en el espacio de trabajo activo |
| `Alt + Shift + Tab` | Recorrer hacia atrás las ventanas en el espacio de trabajo activo |
| `Ctrl + Alt + Tab`| Recorrer hacia adelante el foco entre monitores |
| `Ctrl + Alt + Shift + Tab`| Recorrer hacia atrás el foco entre monitores |
| `Super + I` | Cambiar idioma de entrada (con más de una distribución o método de entrada) |
| `Super + Shift + I` | Cambiar idioma de entrada de vuelta |

En un touchpad, los deslizamientos con tres y cuatro dedos cambian espacios de trabajo, mueven ventanas y abren el menú y la consola Quake; consulta [teclado, mouse y trackpad](34-keyboard-mouse-trackpad.md) para ver los gestos.

El redimensionamiento usa las dos teclas a la derecha del 0, imprima lo que imprima tu teclado en ellas: `-` y `=` en teclados de EE. UU., `+` y `´` en danés y sueco, `+` y `\` en noruego, `ß` y `´` en alemán, `'` y `¡` en español, y `-` y `^` en japonés (JIS). `Super + K` las muestra tal como las imprime tu teclado. En JIS, `Super + ^` es `Super + Equal`, mientras que `Super + Shift + -` (que escribe `=`) es `Super + Shift + Minus`. La escala del monitor y el administrador de contraseñas usan `/`; en distribuciones que escriben `/` solo con Shift, como la mayoría de las europeas, usan en su lugar la tecla a la izquierda de Shift derecho (`-` en danés y alemán).

## Controles del sistema

| Atajo                  | Función              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Panel de audio    |
| `Super + Ctrl + B`           | Panel de Bluetooth    |
| `Super + Ctrl + N`           | Panel de wifi/red    |
| `Super + Ctrl + D`           | Panel de pantalla    |
| `Super + Ctrl + P`           | Panel de energía    |
| `Super + Ctrl + X`           | Panel de agentes    |
| `Super + Ctrl + Alt + X`           | Panel de modelos locales    |
| `Super + Ctrl + Alt + D`           | Panel de calendario    |
| `Super + Ctrl + Alt + E`           | Panel de reloj mundial    |
| `Super + Ctrl + 1-9`           | Alternar panel de la barra por posición    |
| `Super + Ctrl + S` | Menú para compartir (vía LocalSend) |
| `Super + Ctrl + C` | Controles de captura (captura de pantalla/-grabación/selector) |
| `Super + Ctrl + O` | Alternar menú |
| `Super + Ctrl + H` | Menú de hardware |
| `Super + Ctrl + E` | Selector de emojis |
| `Super + Ctrl + .` | Transcodificar multimedia |
| `Super + Shift + Ctrl + A` | Iniciar tu agente predeterminado |
| tecla `Power` | Menú del sistema |
| tecla `Super + Shift + Copilot` | Menú de Omarchy |

## Ajustes

| Atajo                  | Función              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Brillo máximo de pantalla |
| `Shift + Brightness Down` | Brillo mínimo de pantalla |
| `Alt + Brightness Up/Down` | Cambios precisos de brillo del 1% |
| `Alt + Volume Up/Down` | Cambios precisos de volumen del 1% |
| `Keyboard Brightness Up/Down` | Aumentar/disminuir brillo de la retroiluminación del teclado |
| `Keyboard Backlight` | Recorrer los niveles de retroiluminación del teclado |
| `Ctrl + Brightness Up/Down` | Aumentar/disminuir brillo de la retroiluminación del teclado, en teclados sin teclas propias para ello |
| `Mic Mute` | Silenciar el micrófono |
| `Shift + Mute` | Cambiar salida de audio |
| `Touchpad Toggle` | Activar o desactivar el touchpad |
| tecla `Display` | Recorrer el diseño del espacio de trabajo |
| `Alt + Play` | Siguiente pista |
| `Alt + Shift + Play` | Pista anterior |

## Abrir aplicaciones

| Atajo                  | Función              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Terminal de Tmux |
| `Super + Ctrl + Return` | Herdr (administrador de agentes) |
| `Super + Shift + Return` o `Super + Shift + B`  | Navegador    |
| `Super + Shift + Alt + B`           | Navegador (privado/incógnito)    |
| `Super + Shift + F`           | Administrador de archivos    |
| `Super + Shift + Alt + F`           | Administrador de archivos en el cwd de la terminal    |
| `Super + Shift + M`           | Música (Spotify)    |
| `Super + Shift + Alt + M`           | Música (cliamp)    |
| `Super + Shift + /`           | Administrador de contraseñas (1password)    |
| `Super + Shift + Q` o tecla `Calculator`  | Calculadora (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, una vez instalado)    |
| `Super + Shift + T`           | Actividad (btop)    |
| `Super + Shift + N`           | Editor (Plain, o el predeterminado que elijas)  |
| `Super + Shift + C`           | Calendario ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | Correo ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Correo nuevo ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | Tu agente predeterminado, o ChatGPT hasta que elijas uno |
| `Super + Shift + Alt + A`           | IA (Grok)  |
| `Super + Shift + G`           | Mensajería (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Mensajería (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Mensajería (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Escritura (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X (publicación nueva) |
| `Super + Shift + Y`           | YouTube |

Cambia/agrega atajos en `~/.config/hypr/bindings.lua`.

## Portapapeles universal

| Atajo                  | Función              |
| ----------------------- | --------------------- |
| `Super + A`           | Seleccionar todo en aplicaciones que admiten `Ctrl + A`    |
| `Super + C`           | Copiar    |
| `Super + X`           | Cortar (no en la terminal)    |
| `Super + V`           | Pegar    |
| `Super + Ctrl + V`           | Administrador del portapapeles    |

Por lo general en Linux necesitas `Ctrl + Shift + C/V` para copiar y pegar en la terminal y `Ctrl + C/V` para hacerlo en cualquier otro lado. Estos atajos unificados de portapapeles de Omarchy funcionan en todas partes.

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
| `Super + Alt + [` | Hacer más pequeña la superposición de la webcam mientras grabas |
| `Super + Alt + ]` | Hacer más grande la superposición de la webcam mientras grabas |
| `Alt + Shift + L` | Copiar la URL actual desde la webapp o el navegador |
| `Alt + Shift + D` | Descargar el video de la página actual a `~/Videos` |
| `Alt + Space` | Iniciar/detener dictado (requiere _Setup > Defaults > Dictation_) |
| `Right Alt` | Mantener presionado para dictar (requiere _Setup > Defaults > Dictation_) |

Con las grabaciones de pantalla, el atajo primero pregunta qué audio quieres y luego empieza a grabar. Presiónalo de nuevo para detener. Consulta [capturas de pantalla y grabación](12-screenshots-recording.md) para ver los detalles.

Todas las opciones de captura también están disponibles en _Trigger > Capture_ en el menú de Omarchy (`Super + Space`).

## Notificaciones

| Atajo                  | Función              |
| ----------------------- | --------------------- |
| `Super + ,` | Actuar sobre la notificación más reciente: abrirla o presionar su único botón, elegir entre sus opciones o descartarla cuando no tiene ninguna  |
| `Super + Shift + ,` | Descartar todas las notificaciones |
| `Super + Ctrl + ,` | Controlar notificaciones con el teclado  |
| `Super + Alt + ,` | Descartar la notificación más reciente  |
| `Super + Shift + Alt + ,` | Abrir historial de notificaciones  |
| `Super + Ctrl + Alt + ,` | Alternar silencio de notificaciones  |

## Estilo

| Atajo                  | Función              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Elegir un tema nuevo (también `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Elegir fondo del tema (también `Super + Ctrl + Space`) |
| `Super + Backspace` | Alternar transparencia en una ventana |
| `Super + Ctrl + Backspace` | Alternar proporción cuadrada de una sola ventana |

Las imágenes de fondo adicionales viven en `~/.config/omarchy/backgrounds/<theme name>`. También están disponibles vía _Install > Style > Background_ en el menú de Omarchy.

Todas las opciones de estilo también están disponibles en _Appearance_ en el menú de Omarchy (`Super + Space`).

## Alternar

| Atajo                  | Función              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Alternar bloqueo por inactividad |
| `Super + Ctrl + Delete` | Alternar encendido/apagado de la pantalla de la laptop |
| `Super + Ctrl + Alt + Delete` | Alternar duplicación de la pantalla de la laptop |
| `Super + Shift + Space` | Alternar la barra superior  |
| `Shift + Mute` | Cambiar a la siguiente salida de audio |
| `Shift + Play` | Cambiar a la siguiente fuente multimedia |
| `Super + Shift + Backspace` | Alternar espacios entre ventanas |
| `Super + Ctrl + Alt + F` | Alternar escritorio en pantalla completa (barra superior + espacios entre ventanas) |

## Recordatorios

| Atajo                  | Función              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Crear un recordatorio  |
| `Super + Ctrl + Alt + R` | Ver todos los recordatorios  |
| `Super + Ctrl + Shift + R` | Borrar todos los recordatorios  |

## Avisos

| Atajo                  | Función              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Mostrar la hora como notificación  |
| `Super + Ctrl + Alt + B` | Mostrar la batería como notificación  |
| `Super + Ctrl + Alt + W` | Alternar el clima como notificación  |

## Tmux

La tecla prefijo es `Ctrl + Space` (`Ctrl + B` también funciona). Puedes cambiar estos atajos en `~/.config/tmux/tmux.conf`.

### Paneles

| Atajo                  | Función              |
| ----------------------- | --------------------- |
| `Prefix + v` | Dividir panel al lado (vertical) |
| `Prefix + h` | Dividir panel abajo (horizontal) |
| `Prefix + x` | Eliminar panel |
| `Prefix + z` | Alternar zoom del panel (pantalla completa) |
| `Alt + Enter` | Dividir panel abajo (sin prefijo) |
| `Alt + Shift + Enter` | Dividir panel al lado (sin prefijo) |
| `Alt + Escape` | Eliminar panel (sin prefijo) |
| `Ctrl + Alt + Arrows` | Moverse entre paneles |
| `Ctrl + Alt + Shift + Arrows` | Redimensionar paneles |

### Ventanas

| Atajo                  | Función              |
| ----------------------- | --------------------- |
| `Prefix + c` | Ventana nueva |
| `Prefix + k` | Eliminar ventana |
| `Prefix + r` | Renombrar ventana |
| `Alt + 1-9` | Ir a ventana específica |
| `Alt + Arrow Left/Right` | Moverse entre ventanas |
| `Alt + Shift + Arrow Left/Right` | Mover ventana a la izquierda/derecha |

### Sesiones

| Atajo                  | Función              |
| ----------------------- | --------------------- |
| `Prefix + C` | Sesión nueva |
| `Prefix + K` | Eliminar sesión |
| `Prefix + R` | Renombrar sesión |
| `Prefix + N` | Siguiente sesión |
| `Prefix + P` | Sesión anterior |
| `Alt + Arrow Up/Down` | Moverse entre sesiones |
| `Prefix + s` | Listar sesiones |
| `Prefix + d` | Desconectarse de la sesión |

### Modo de copia (estilo vi)

| Atajo                  | Función              |
| ----------------------- | --------------------- |
| `Prefix + [` | Entrar al modo de copia |
| `v` | Iniciar selección (en modo de copia) |
| `y` | Copiar selección (en modo de copia) |

### General

| Atajo                  | Función              |
| ----------------------- | --------------------- |
| `Prefix + q` | Recargar configuración |
| `Prefix + ?` | Mostrar atajos de Tmux |
| `Prefix + :` | Prompt de comandos |

### Funciones de diseño de Tmux

Estas funciones deben ejecutarse dentro de una sesión de Tmux.

| Comando | Función |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Crear diseño de desarrollo con editor, IA y terminal |
| `tdlm <ai> [<second_ai>]` | Crear diseño de desarrollo por subdirectorio |
| `tsl <count> <command>` | Crear diseño en enjambre de varios paneles |

## Terminal Ghostty

La terminal Ghostty se instala usando _Install > Terminal_ vía el menú de Omarchy.

| Atajo                  | Función              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nueva división abajo |
| `Ctrl + Shift + O` | Nueva división al lado |
| `Ctrl + Alt + Arrows` | Moverse entre divisiones |
| `Super + Ctrl + Shift + Arrows` | Redimensionar división en 10 líneas |
| `Super + Ctrl + Shift + Alt + Arrows` | Redimensionar división en 100 líneas |
| `Ctrl + Shift + T` | Pestaña nueva  |
| `Ctrl + Shift + Arrows` | Moverse entre pestañas |
| `Alt + Numbers` | Ir a pestaña específica |
| `Shift + Pg Up/Down` | Recorrer el historial |
| `Ctrl + Left mouse` | Abrir enlace en el navegador |

## Administrador de archivos

| Atajo              | Función                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Ir a ruta                     |
| `Space`               | Vista previa del archivo (las flechas navegan) |
| `Alt + Up`       | Subir a la carpeta principal        |

## Neovim (con lazyvim)

### Navegación

| Atajo                   | Función                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Mostrar opciones de comandos            |
| `Space Space`              | Abrir archivo vía búsqueda difusa      |
| `Space E`                  | Alternar barra lateral                  |
| `Space G G`                | Mostrar controles de git               |
| `Space S G`                | Buscar contenido del archivo             |
| `Ctrl + W W`               | Saltar entre barra lateral y editor |
| `Ctrl + Left/right arrow`  | Cambiar tamaño de la barra lateral          |
| `Shift + H`                      | Ir a pestaña de archivo de la izquierda             |
| `Shift + L`                      | Ir a pestaña de archivo de la derecha            |
| `Space B D`                | Cerrar pestaña de archivo                  |

### Mientras estás en la barra lateral

| Atajo                   | Función                        |
| ------------------------ | ------------------------------- |
| `A`                        | Agregar archivo nuevo en directorio principal      |
| `Shift + A`                | Agregar subdirectorio nuevo en directorio principal    |
| `D`                        | Eliminar archivo/directorio resaltado     |
| `M`                        | Mover archivo/directorio resaltado       |
| `R`                        | Renombrar archivo/directorio resaltado     |
| `?`                        | Mostrar ayuda para todos los comandos      |

[Consulta todos los atajos de Neovim configurados por LazyVim](https://www.lazyvim.org/keymaps).

## Emojis rápidos

Puedes usar `Super + Ctrl + E` para mostrar un selector de emojis completo que pondrá la selección en el portapapeles, o puedes usar estas opciones de acceso rápido.

| Atajo       | EM | Pista       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | sonrisa      |
| `Shift + CapsLock M C` | 😂 | llorar        |
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
| `Shift + CapsLock Space N` | Tu nombre (como lo ingresaste en la configuración)  |
| `Shift + CapsLock Space E` | Tu correo (como lo ingresaste en la configuración)  |

Puedes agregar más por tu cuenta editando `~/.XCompose`, luego ejecutando `omarchy restart xcompose` en la terminal para que se apliquen los cambios.
