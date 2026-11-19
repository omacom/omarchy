# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) es una alternativa encantadora a algo como la aplicación GitHub Desktop, y se ejecuta dentro de la terminal.

Puedes ejecutarlo directamente, yendo a cualquier directorio gestionado por git y ejecutando `lazygit`. O puedes ejecutarlo dentro de Neovim, donde puede iniciarse con `Space G G`.

Saltas entre los distintos paneles usando `Tab`. En el panel Files, seleccionas archivos para staging usando `Space`, y luego puedes crear un nuevo commit usando `c`. Puedes ver todos los comandos disponibles usando `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) es un hermoso gestor de recursos que muestra el uso de memoria, CPU, disco y red. También enumera todos los procesos activos y te permite gestionarlos.

Omarchy lo llama Activity Monitor, y lo inicias desde el lanzador de aplicaciones o presionando `Super + Shift + T`. Se abre como una ventana flotante, que puedes poner en mosaico con `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) es un gestor de espacios de trabajo de terminal que te da espacios de trabajo, pestañas y paneles, y los mantiene todos en ejecución en una sesión persistente de la que puedes desconectarte y a la que puedes volver más tarde.

Lo inicias (o te vuelves a conectar a tu sesión existente) desde el lanzador de aplicaciones o con `Super + Ctrl + Return`. Omarchy incluye una configuración de Herdr que refleja su configuración de Tmux, así que aquí la tecla prefijo también es `Ctrl + Space`. Puedes consultar todos los atajos de teclado con `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) muestra información del sistema, como la versión del kernel, el tiempo de actividad, el tema, la CPU, la memoria y más. Es el sucesor de la popular herramienta neofetch.

Omarchy lo ha empaquetado como _Sistema > Acerca de_ en el menú de Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) es un reproductor de música de terminal retro inspirado en Winamp 2.x, completo con estaciones de radio integradas para ritmos lo-fi. Inícialo con `Super + Shift + Alt + M`, o desde el menú de Omarchy en _Aplicaciones_. Presiona `?` para ver la lista completa de atajos de teclado.

## ¿Y qué pasa con el Wi-Fi y el Bluetooth?

No encontrarás TUIs para Wi-Fi y Bluetooth: esos trabajos le corresponden a la shell de Omarchy. Haz clic en el icono de Wi-Fi en la barra superior (o presiona `Super + Ctrl + N`) para ver las redes y conectarte, y haz clic en el icono de Bluetooth (o presiona `Super + Ctrl + B`) para emparejar y conectar dispositivos. Consulta [redes](35-networking.md) para conocer la historia completa.

## Agrega los tuyos

Cualquier programa de terminal puede recibir todo el trato de una aplicación. Ve a _Instalar > TUI_ en el menú de Omarchy (`Super + Space`), dale un nombre, un comando de lanzamiento, un estilo de ventana y un icono, y aparecerá en el lanzador de aplicaciones como cualquier otra aplicación. Puedes eliminarlo de nuevo en _Eliminar > TUI_.
