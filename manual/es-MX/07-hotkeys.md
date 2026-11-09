# Atajos de teclado

Puedes ver todas las combinaciones principales de teclas con `Super + K` (las combinaciones de Tmux con `Super + Alt + K` y las combinaciones de Herdr con `Super + Ctrl + K`).

## Cómo están organizados los atajos de teclado

Cada atajo está en un plano, definido por sus modificadores, y cada plano tiene una función. Eso es lo que evita que los atajos se confundan entre sí, y significa que normalmente puedes adivinar dónde está cada cosa.

| Plano | Qué vive ahí | Ejemplos |
| --- | --- | --- |
| `Super + key` | El sistema: ventanas, espacios de trabajo, diseños y menús principales | `Super + Space` menú de Omarchy, `Super + W` cerrar ventana, `Super + F` pantalla completa |
| `Super + Shift + key` | Aplicaciones | `Super + Shift + B` navegador, `Super + Shift + E` correo electrónico, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Paneles y menús del sistema | `Super + Ctrl + A` audio, `Super + Ctrl + N` red, `Super + Ctrl + C` menú de captura |
| `Super + Ctrl + Alt + key` | Acciones rápidas y avisos | `Super + Ctrl + Alt + T` mostrar la hora, `Super + Ctrl + Alt + B` batería, `Super + Ctrl + Alt + C` captura de pantalla |

Agregar `Alt` a un atajo te da una variante de lo mismo, nunca algo sin relación:

- `Super + Shift + B` abre el navegador; `Super + Shift + Alt + B` abre una ventana privada
- `Super + Shift + E` abre el correo electrónico; `Super + Shift + Alt + E` empieza uno nuevo
- `Super + F` pasa a pantalla completa; `Super + Alt + F` pasa a ancho completo
- `Super + Ctrl + C` abre el menú de captura; `Super + Ctrl + Alt + C` se salta el menú y toma una captura de pantalla

Al agregar un atajo:

1. Elige el plano según lo que hace y luego elige la tecla.
2. No muevas un atajo existente para hacer espacio. Encuentra una tecla libre en el plano correcto.
3. Usa `Alt` solo para una variante del atajo sin `Alt`.

Algunos atajos rompen estas reglas porque son convenientes. `Shift` con una flecha o `Tab` mueve o invierte en lugar de abrir una aplicación, y `Print`, las teclas multimedia, `Alt + Tab` y `Ctrl + Alt + Del` funcionan como en cualquier otro lugar. Son excepciones, no patrones para copiar.

Si un atajo predeterminado no te conviene (digamos que quieres `Super + Shift + S` para capturas de pantalla como en Windows), vuelve a asignarlo en `~/.config/hypr/bindings.lua`.

## Navegación

| Atajo | Función |
| ----------------------- | --------------------- |
| `Super + Space` | Menú de Omarchy (aplicaciones y todo lo demás) |
| `Super + Alt + Space` | Cuadrícula de aplicaciones |
| `Super + Escape` | Menú del sistema (suspender, reiniciar, etc.) |
| `Super + Ctrl + L` | Bloquear computadora |
| `Super + W` or `Super + Q` | Cerrar ventana |
| `Ctrl + Alt + Del` | Cerrar todas las ventanas |
| `Super + T` | Alternar ventana entre mosaico/flotante |
| `Super + J` | Alternar posición de la ventana (horizontal/vertical) |
| `Super + O` | Alternar ventana emergente a fija y flotante |
| `Super + L` | Recorrer los diseños dwindle, scrolling y flotante |
| `Super + Alt + L` | Recorrer los diseños en sentido inverso |
| `Super + P` | Alternar estilo de ventana pseudo (natural vs. estirado) |
| `Super + F` | Pasar a pantalla completa |
| `Super + Alt + F` | Pasar a ancho completo |
| `Super + Ctrl + F` | Pasar a pantalla completa dentro de la ventana |
| `Super + 1/2/3/4` | Ir a un espacio de trabajo específico en el monitor enfocado |
| `Super + Tab` | Ir al siguiente espacio de trabajo en el monitor enfocado |
| `Super + Shift + Tab` | Ir al espacio de trabajo anterior en el monitor enfocado |
| `Super + Ctrl + Tab` | Ir al espacio de trabajo previo en el monitor enfocado |
| `Super + Shift + 1/2/3/4` | Mover ventana al espacio de trabajo en el monitor enfocado |
| `Super + Shift + Alt + 1/2/3/4` | Mover ventana al espacio de trabajo en el monitor enfocado sin seguirla |
| `Super + S` | Alternar scratchpad completo |
| `Super + Alt + S` | Mover ventana al scratchpad completo |
| `Super + Grave` | Alternar consola Quake |
| `Super + Shift + Grave` | Mover ventana a la consola Quake |
| `Super + Shift + Ctrl + Arrows` | Mover ventana al monitor en esa dirección |
| `Super + Shift + Alt + Arrows` | Mover espacio de trabajo al monitor en esa dirección |
| `Super + Arrow` | Mover el foco a la ventana en la dirección de la flecha, cruzando al monitor de ese lado en el borde de la pantalla |
| `Super + Shift + Arrow` | Intercambiar ventana con otra en la dirección de la flecha, incluida una en el monitor de ese lado |
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
| `Super + Scroll Wheel` | Desplazarse por los espacios de trabajo en el monitor enfocado |
| `Super + G` | Alternar agrupación de ventanas |
| `Super + Alt + G` | Sacar ventana de la agrupación |
| `Super + Alt + Tab` | Recorrer las ventanas de la agrupación |
| `Super + Alt + Shift + Tab` | Recorrer hacia atrás las ventanas de la agrupación |
| `Super + Alt + Scroll Wheel` | Recorrer las ventanas de la agrupación |
| `Super + Alt + 1/2/3/4/5` | Ir a una ventana específica de la agrupación |
| `Super + Alt + Arrow` | Mover ventana a la agrupación en la dirección de la flecha, incluida una en el monitor de ese lado |
| `Super + Ctrl + Left/Right` | Moverse entre ventanas dentro de un grupo en mosaico |
| `Super + Ctrl + Z` | Acercar la pantalla (repetir para acercar más) |
| `Super + Ctrl + Alt + Z` | Alejar la pantalla por completo |
| `Super + /` | Avanzar por las opciones de escala del monitor |
| `Super + Alt + /` | Retroceder por las opciones de escala del monitor |
| `Alt + Tab` | Recorrer hacia adelante las ventanas del espacio de trabajo activo |
| `Alt + Shift + Tab` | Recorrer hacia atrás las ventanas del espacio de trabajo activo |
| `Ctrl + Alt + Tab` | Recorrer el foco hacia adelante por los monitores |
| `Ctrl + Alt + Shift + Tab` | Recorrer el foco hacia atrás por los monitores |

Los atajos de redimensionamiento usan las teclas físicas `code:20` y `code:21` (XKB `<AE11>` y `<AE12>`), sin importar los caracteres impresos en el teclado. En teclados de EE. UU. estas teclas son `-` y `=`; en teclados japoneses (JIS) son `-` y `^`; en teclados en español son `'` y `¡`. En JIS, `Super + ^` es `Super + Equal`, mientras que `Super + Shift + -` (que escribe `=`) es `Super + Shift + Minus`.

## Controles del sistema

| Atajo | Función |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Panel de audio |
| `Super + Ctrl + B` | Panel de Bluetooth |
| `Super + Ctrl + N` | Panel de Wi-Fi/red |
| `Super + Ctrl + D` | Panel de pantalla |
| `Super + Ctrl + P` | Panel de energía |
| `Super + Ctrl + Alt + D` | Panel de calendario |
| `Super + Ctrl + Alt + E` | Panel de reloj mundial |
| `Super + Ctrl + 1-9` | Alternar panel de la barra por posición |
| `Super + Ctrl + S` | Menú para compartir (vía LocalSend) |
| `Super + Ctrl + C` | Controles de captura (captura de pantalla/grabación/selector) |
| `Super + Ctrl + O` | Alternar menú |
| `Super + Ctrl + H` | Menú de hardware |
| `Super + Ctrl + E` | Selector de emojis |
| `Super + Ctrl + .` | Transcodificar multimedia |
| `Super + Shift + Ctrl + A` | Elegir un agente de IA |

## Ajustes

| Atajo | Función |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Brillo máximo de pantalla |
| `Shift + Brightness Down` | Brillo mínimo de pantalla |
| `Alt + Brightness Up/Down` | Cambios precisos de brillo del 1% |
| `Alt + Volume Up/Down` | Cambios precisos de volumen del 1% |
| `Keyboard Brightness Up/Down` | Retroiluminación del teclado más brillante/más tenue |
| `Keyboard Backlight` | Recorrer los niveles de retroiluminación del teclado |
| `Alt + Play` | Pista siguiente |
| `Alt + Shift + Play` | Pista anterior |

## Abrir aplicaciones

| Atajo | Función |
| ----------------------- | --------------------- |
| `Super + Return` | Terminal |
| `Super + Alt + Return` | Terminal de Tmux |
| `Super + Ctrl + Return` | Herdr (administrador de agentes) |
| `Super + Shift + Return` | Navegador |
| `Super + Shift + Alt + B` | Navegador (privado/incógnito) |
| `Super + Shift + F` | Administrador de archivos |
| `Super + Shift + Alt + F` | Administrador de archivos en el cwd de la terminal |
| `Super + Shift + M` | Música (Spotify) |
| `Super + Shift + Alt + M` | Música (cliamp) |
| `Super + Shift + /` | Administrador de contraseñas (1password) |
| `Super + Shift + Q` | Calculadora (Omacalc) |
| `Super + Shift + T` | Actividad (btop) |
| `Super + Shift + N` | Editor (Neovim) |
| `Super + Shift + C` | Calendario ([HEY](https://hey.com/)) |
| `Super + Shift + E` | Correo electrónico ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Correo electrónico nuevo ([HEY](https://hey.com/)) |
| `Super + Shift + A` | IA (ChatGPT) |
| `Super + Shift + Alt + A` | IA (Grok) |
| `Super + Shift + G` | Mensajería (Signal) |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | Mensajería (WhatsApp) |
| `Super + Shift + Ctrl + G` | Mensajería (Google) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | Escritura (Omawrite) |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X Compose |
| `Super + Shift + Y` | YouTube |

Cambia/agrega combinaciones en `~/.config/hypr/bindings.lua`.

## Portapapeles universal

| Atajo | Función |
| ----------------------- | --------------------- |
| `Super + A` | Seleccionar todo en aplicaciones que admiten `Ctrl + A` |
| `Super + C` | Copiar |
| `Super + X` | Cortar (no en la terminal) |
| `Super + V` | Pegar |
| `Super + Ctrl + V` | Administrador del portapapeles |

Normalmente en Linux, necesitas `Ctrl + Shift + C/V` para copiar y pegar en la terminal y `Ctrl + C/V` para hacerlo en cualquier otro lugar. Estos atajos unificados del portapapeles de Omarchy funcionan en todas partes.

## Captura

| Atajo | Función |
| ------------------- | ------------------------------ |
| `Print Screen` | Captura de pantalla |
| `Super + Ctrl + Alt + C` | Captura de pantalla (la misma captura, para teclados sin tecla Print Screen) |
| `Super + Ctrl + C` | Menú de captura |
| `Alt + Print Screen` | Grabación de pantalla |
| `Super + Print Screen` | Selector de color |
| `Super + Ctrl + Print Screen` | Extracción de texto al portapapeles |
| `Super + Alt + [` | Hacer más pequeña la superposición de la webcam mientras grabas |
| `Super + Alt + ]` | Hacer más grande la superposición de la webcam mientras grabas |
| `Alt + Shift + L` | Copiar la URL actual desde la webapp o Chromium |
| `Alt + Shift + D` | Descargar el video de la página actual a `~/Videos` |
| `Alt + Space` | Iniciar/detener el dictado (requiere _Configuración > Valores predeterminados > Dictado_) |
| `Right Alt` | Mantener presionada para dictar (requiere _Configuración > Valores predeterminados > Dictado_) |

Con las grabaciones de pantalla, el atajo primero pregunta qué audio quieres y luego empieza a grabar. Presiónalo de nuevo para detener. Consulta [capturas de pantalla y grabación](12-screenshots-recording.md) para ver los detalles.

Todas las opciones de captura también están disponibles en _Activar > Captura_ en el menú de Omarchy (`Super + Space`).

## Notificaciones

| Atajo | Función |
| ----------------------- | --------------------- |
| `Super + ,` | Actuar sobre la última notificación: abrirla o presionar su único botón, elegir entre sus opciones o descartarla cuando no tenga ninguna |
| `Super + Shift + ,` | Descartar todas las notificaciones |
| `Super + Ctrl + ,` | Controlar las notificaciones con el teclado |
| `Super + Alt + ,` | Descartar la última notificación |
| `Super + Shift + Alt + ,` | Abrir el historial de notificaciones |
| `Super + Ctrl + Alt + ,` | Alternar el silencio de notificaciones |

## Estilo

| Atajo | Función |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Elegir un tema nuevo (también `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Elegir el fondo del tema (también `Super + Ctrl + Space`) |
| `Super + Backspace` | Alternar la transparencia en una ventana |
| `Super + Ctrl + Backspace` | Alternar la relación de aspecto cuadrada de una sola ventana |

Las imágenes de fondo adicionales están en `~/.config/omarchy/backgrounds/<theme name>`. También están disponibles en _Instalar > Estilo > Fondo_ en el menú de Omarchy.

Todas las opciones de estilo también están disponibles en _Estilo_ en el menú de Omarchy (`Super + Space`).

## Activar/desactivar

| Atajo | Función |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Alternar el bloqueo por inactividad |
| `Super + Ctrl + Delete` | Encender/apagar la pantalla de la laptop |
| `Super + Ctrl + Alt + Delete` | Alternar la duplicación de la pantalla de la laptop |
| `Super + Shift + Space` | Alternar la barra superior |
| `Shift + Mute` | Cambiar a la siguiente salida de audio |
| `Shift + Play` | Cambiar a la siguiente fuente multimedia |
| `Super + Shift + Backspace` | Alternar los espacios entre ventanas |
| `Super + Ctrl + Alt + F` | Alternar el escritorio a pantalla completa (barra superior + espacios entre ventanas) |

## Recordatorios

| Atajo | Función |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Crear un recordatorio |
| `Super + Ctrl + Alt + R` | Ver todos los recordatorios |
| `Super + Ctrl + Shift + R` | Borrar todos los recordatorios |

## Avisos

| Atajo | Función |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Mostrar la hora como notificación |
| `Super + Ctrl + Alt + B` | Mostrar la batería como notificación |
| `Super + Ctrl + Alt + W` | Alternar el clima como notificación |

## Tmux

La tecla de prefijo es `Ctrl + Space` (`Ctrl + B` también funciona). Puedes cambiar estas combinaciones en `~/.config/tmux/tmux.conf`.

### Paneles

| Atajo | Función |
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

| Atajo | Función |
| ----------------------- | --------------------- |
| `Prefix + c` | Nueva ventana |
| `Prefix + k` | Eliminar ventana |
| `Prefix + r` | Renombrar ventana |
| `Alt + 1-9` | Ir a una ventana específica |
| `Alt + Arrow Left/Right` | Moverse entre ventanas |
| `Alt + Shift + Arrow Left/Right` | Mover ventana a la izquierda/derecha |

### Sesiones

| Atajo | Función |
| ----------------------- | --------------------- |
| `Prefix + C` | Nueva sesión |
| `Prefix + K` | Eliminar sesión |
| `Prefix + R` | Renombrar sesión |
| `Prefix + N` | Sesión siguiente |
| `Prefix + P` | Sesión anterior |
| `Alt + Arrow Up/Down` | Moverse entre sesiones |
| `Prefix + s` | Listar sesiones |
| `Prefix + d` | Desconectarse de la sesión |

### Modo de copia (estilo vi)

| Atajo | Función |
| ----------------------- | --------------------- |
| `Prefix + [` | Entrar al modo de copia |
| `v` | Iniciar selección (en modo de copia) |
| `y` | Copiar selección (en modo de copia) |

### General

| Atajo | Función |
| ----------------------- | --------------------- |
| `Prefix + q` | Recargar configuración |
| `Prefix + ?` | Mostrar combinaciones de teclas de Tmux |
| `Prefix + :` | Indicador de comandos |

### Funciones de diseño de Tmux

Estas funciones deben ejecutarse dentro de una sesión de Tmux.

| Comando | Función |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Crear diseño de desarrollo con editor, IA y terminal |
| `tdlm <ai> [<second_ai>]` | Crear diseño de desarrollo por subdirectorio |
| `tsl <count> <command>` | Crear diseño de enjambre con varios paneles |

## Terminal Ghostty

La terminal Ghostty se instala con _Instalar > Terminal_ en el menú de Omarchy.

| Atajo | Función |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nueva división abajo |
| `Ctrl + Shift + O` | Nueva división al lado |
| `Ctrl + Alt + Arrows` | Moverse entre divisiones |
| `Super + Ctrl + Shift + Arrows` | Redimensionar división en 10 líneas |
| `Super + Ctrl + Shift + Alt + Arrows` | Redimensionar división en 100 líneas |
| `Ctrl + Shift + T` | Nueva pestaña |
| `Ctrl + Shift + Arrows` | Moverse entre pestañas |
| `Alt + Numbers` | Ir a una pestaña específica |
| `Shift + Pg Up/Down` | Desplazarse por el historial |
| `Ctrl + Left mouse` | Abrir enlace en el navegador |

## Administrador de archivos

| Atajo | Función |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Ir a la ruta |
| `Space` | Vista previa del archivo (las flechas navegan) |
| `Alt + Up` | Subir a la carpeta superior |

## Neovim (con lazyvim)

### Navegación

| Atajo | Función |
| ------------------------ | ------------------------------- |
| `Space` | Mostrar opciones de comandos |
| `Space Space` | Abrir archivo mediante búsqueda difusa |
| `Space E` | Alternar barra lateral |
| `Space G G` | Mostrar controles de git |
| `Space S G` | Buscar contenido del archivo |
| `Ctrl + W W` | Saltar entre la barra lateral y el editor |
| `Ctrl + Left/right arrow` | Cambiar el tamaño de la barra lateral |
| `Shift + H` | Ir a la pestaña de archivo de la izquierda |
| `Shift + L` | Ir a la pestaña de archivo de la derecha |
| `Space B D` | Cerrar pestaña de archivo |

### Mientras estás en la barra lateral

| Atajo | Función |
| ------------------------ | ------------------------------- |
| `A` | Agregar un archivo nuevo en el directorio superior |
| `Shift + A` | Agregar un subdirectorio nuevo en el directorio superior |
| `D` | Eliminar archivo/directorio resaltado |
| `M` | Mover archivo/directorio resaltado |
| `R` | Renombrar archivo/directorio resaltado |
| `?` | Mostrar ayuda para todos los comandos |

[Consulta todos los atajos de teclado de Neovim configurados por LazyVim](https://www.lazyvim.org/keymaps).

## Emojis rápidos

Puedes usar `Super + Ctrl + E` para mostrar un selector completo de emojis que pondrá la selección en el portapapeles, o puedes usar estas opciones de acceso rápido.

| Atajo | EM | Pista |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | sonrisa |
| `Shift + CapsLock M C` | 😂 | llorar |
| `Shift + CapsLock M L` | 😍 | amor |
| `Shift + CapsLock M V` | ✌️ | victoria |
| `Shift + CapsLock M H` | ❤️ | corazón |
| `Shift + CapsLock M Y` | 👍 | sí |
| `Shift + CapsLock M N` | 👎 | no |
| `Shift + CapsLock M F` | 🖕 | chingar |
| `Shift + CapsLock M W` | 🤞 | deseo |
| `Shift + CapsLock M R` | 🤘 | rock |
| `Shift + CapsLock M K` | 😘 | beso |
| `Shift + CapsLock M E` | 🙄 | ojos en blanco |
| `Shift + CapsLock M I` | 😉 | guiño |
| `Shift + CapsLock M P` | 🙏 | rezar |
| `Shift + CapsLock M D` | 🤤 | babear |
| `Shift + CapsLock M M` | 💰 | dinero |
| `Shift + CapsLock M X` | 🎉 | celebrar |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | brindis |
| `Shift + CapsLock M O` | 👌 | ok |
| `Shift + CapsLock M G` | 👋 | saludo |
| `Shift + CapsLock M A` | 💪 | brazo |
| `Shift + CapsLock M B` | 🤯 | explosión |

## Autocompletados rápidos

| Atajo | Completado |
| ------------ | ---------- |
| `Shift + CapsLock Space Space` | — (raya) |
| `Shift + CapsLock Space N` | Tu nombre (tal como lo ingresaste en la configuración) |
| `Shift + CapsLock Space E` | Tu correo electrónico (tal como lo ingresaste en la configuración) |

Puedes agregar más por tu cuenta editando `~/.XCompose` y luego ejecutando `omarchy-restart-xcompose` en la terminal para que se apliquen los cambios.
