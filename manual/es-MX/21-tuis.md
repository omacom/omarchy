# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) es una alternativa encantadora a algo como la aplicación GitHub Desktop, y se ejecuta dentro de la terminal.

Puedes ejecutarlo directamente, yendo a cualquier directorio gestionado por git y ejecutando `lazygit`. O puedes ejecutarlo dentro de Neovim, donde se puede iniciar con `Space G G`.

Saltas entre los diferentes paneles usando `Tab`. En el panel de archivos, seleccionas archivos para prepararlos usando `Space`, y luego puedes crear un nuevo commit usando `c`. Puedes ver todos los comandos disponibles usando `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) es un hermoso gestor de recursos que muestra el uso de memoria, CPU, disco y red. También enumera todos los procesos activos y te permite gestionarlos.

Omarchy lo llama Monitor de actividad, y lo inicias desde el lanzador de aplicaciones o presionando `Super + Shift + T`. Se abre como una ventana flotante, que puedes poner en mosaico con `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) es un gestor de espacios de trabajo para la terminal que te ofrece espacios de trabajo, pestañas y paneles, y los mantiene todos en ejecución en una sesión persistente de la que puedes desconectarte y a la que puedes volver más tarde.

Lo inicias (o te vuelves a conectar a tu sesión existente) con `Super + Ctrl + Return`. Omarchy incluye una configuración de Herdr que refleja su configuración de Tmux, así que la tecla de prefijo aquí también es `Ctrl + Space`. Puedes explorar todos los atajos de teclado con `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) muestra información del sistema, como la versión del kernel, el tiempo de actividad, el tema, la CPU, la memoria y más. Es el sucesor de la popular herramienta neofetch.

Omarchy lo ha incluido como _Acerca de_ en el menú de Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) es un reproductor de música retro para la terminal, inspirado en Winamp 2.x, con estaciones de radio integradas de ritmos lo-fi. Inícialo con `Super + Shift + Alt + M`, o desde el menú de Omarchy en _Aplicaciones_. Presiona `?` para ver la lista completa de atajos de teclado.

## ¿Qué pasa con Wi-Fi y Bluetooth?

No encontrarás TUIs para Wi-Fi y Bluetooth: esos trabajos le corresponden al shell de Omarchy. Haz clic en el icono de Wi-Fi en la barra superior (o presiona `Super + Ctrl + N`) para ver las redes y conectarte, y haz clic en el icono de Bluetooth (o presiona `Super + Ctrl + B`) para emparejar y conectar dispositivos. Consulta [redes](35-networking.md) para conocer la historia completa.

## Agregar los tuyos

Cualquier programa de terminal puede recibir el tratamiento completo de aplicación. Ve a _Instalar > TUI_ en el menú de Omarchy (`Super + Space`), dale un nombre, un comando de inicio, un estilo de ventana y un icono, y aparecerá en el lanzador de aplicaciones como cualquier otra aplicación. Puedes eliminarlo de nuevo en _Eliminar > TUI_.
