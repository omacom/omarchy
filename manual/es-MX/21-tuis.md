# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) es una alternativa encantadora a algo como la aplicación GitHub Desktop, y se ejecuta dentro de la terminal.

Puedes ejecutarlo directamente: ve a cualquier directorio administrado por git y ejecuta `lazygit`. O puedes ejecutarlo dentro de Neovim, donde puede iniciarse con `Space G G`.

Te mueves entre los diferentes paneles usando `Tab`. En el panel Files, seleccionas archivos para prepararlos usando `Space`, y luego puedes crear un commit nuevo usando `c`. Puedes ver todos los comandos disponibles usando `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) es un hermoso administrador de recursos que muestra el uso de memoria, CPU, disco y red. También enumera todos los procesos activos y te permite administrarlos.

Omarchy lo llama Activity Monitor, y lo inicias desde el lanzador de aplicaciones o presionando `Super + Shift + T`. Se abre como una ventana flotante, que puedes acoplar con `Super + T`.

## Herdr

[Herdr](https://herdr.dev) es un administrador de espacios de trabajo para la terminal que te ofrece espacios de trabajo, pestañas y paneles, y los mantiene a todos en ejecución en una sesión persistente de la que puedes desconectarte y a la que puedes volver más tarde.

Lo inicias (o te vuelves a conectar a tu sesión existente) desde el lanzador de aplicaciones o con `Super + Ctrl + Return`. Omarchy incluye una configuración de Herdr que refleja su configuración de Tmux, así que la tecla prefijo también es `Ctrl + Space` aquí. Puedes consultar todos los atajos de teclado con `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) muestra información del sistema, como la versión del kernel, el tiempo de actividad, el tema, la CPU, la memoria y más. Es un sucesor de la popular herramienta neofetch.

Omarchy lo ha integrado como _Sistema > Acerca de_ en el menú de Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) es un reproductor de música retro para la terminal inspirado en Winamp 2.x, completo con estaciones de radio integradas de ritmos lo-fi. Inícialo con `Super + Shift + Alt + M`, o desde el menú de Omarchy en _Aplicaciones_. Presiona `?` para ver la lista completa de atajos de teclado.

## ¿Y qué hay de Wi-Fi y Bluetooth?

No encontrarás TUIs para Wi-Fi y Bluetooth: esas tareas le corresponden a la shell de Omarchy. Haz clic en el ícono de Wi-Fi en la barra superior (o presiona `Super + Ctrl + N`) para ver las redes y conectarte, y haz clic en el ícono de Bluetooth (o presiona `Super + Ctrl + B`) para enlazar y conectar dispositivos. Consulta [redes](35-networking.md) para conocer la historia completa.

## Agrega las tuyas

Cualquier programa de terminal puede recibir el tratamiento completo de aplicación. Ve a _Instalar > TUI_ en el menú de Omarchy (`Super + Space`), dale un nombre, un comando de lanzamiento, un estilo de ventana y un ícono, y aparecerá en el lanzador de aplicaciones como cualquier otra aplicación. Puedes eliminarla de nuevo en _Eliminar > TUI_.
