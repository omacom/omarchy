# TUI

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) es una alternativa encantadora a algo como la aplicación GitHub Desktop, y se ejecuta dentro de la terminal.

Puedes ejecutarlo directamente, yendo a cualquier directorio gestionado por git y ejecutando `lazygit`. O puedes ejecutarlo dentro de Neovim, donde se puede iniciar con `Space G G`.

Saltas entre los distintos paneles usando `Tab`. En el panel Files, seleccionas archivos para el área de preparación usando `Space`, y luego puedes crear un nuevo commit usando `c`. Puedes ver todos los comandos disponibles usando `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) es un hermoso gestor de recursos que muestra el uso de memoria, CPU, disco y red. También lista todos los procesos activos y te permite gestionarlos.

Omarchy lo llama Activity, y lo inicias presionando `Super + Ctrl + T`. Se abre como una ventana flotante, que puedes poner en mosaico con `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) es un gestor de espacios de trabajo de terminal que te da espacios de trabajo, pestañas y paneles, y los mantiene todos ejecutándose en una sesión persistente de la que puedes desconectarte y volver después.

Lo inicias (o te reconectas a tu sesión existente) con `Super + Ctrl + Return`. Omarchy incluye una configuración de Herdr que refleja su configuración de Tmux, así que la tecla prefijo aquí también es `Ctrl + Space`. Puedes explorar todos los atajos de teclado con `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) muestra información del sistema, como la versión del kernel, el tiempo de actividad, el tema, la CPU, la memoria y más. Es un sucesor de la popular herramienta neofetch.

Omarchy lo ha empaquetado como _Acerca de_ en el menú de Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) es un reproductor de música retro para terminal inspirado en Winamp 2.x, completo con estaciones de radio integradas de ritmos lo-fi. Lánzalo con `Super + Shift + Alt + M`, o desde el menú de Omarchy en _Aplicaciones_. Presiona `?` para ver la lista completa de atajos de teclado.

## ¿Y el Wi-Fi y el Bluetooth?

No encontrarás TUI para Wi-Fi y Bluetooth: esos trabajos le corresponden al shell de Omarchy. Haz clic en el ícono de Wi-Fi en la barra superior (o presiona `Super + Ctrl + W`) para ver las redes y conectarte, y haz clic en el ícono de Bluetooth (o presiona `Super + Ctrl + B`) para emparejar y conectar dispositivos. Consulta [redes](35-networking.md) para conocer la historia completa.

## Agregar las tuyas

Cualquier programa de terminal puede recibir el tratamiento completo de aplicación. Ve a _Instalar > TUI_ en el menú de Omarchy (`Super + Space`), dale un nombre, un comando de lanzamiento, un estilo de ventana y un ícono, y aparecerá en el lanzador de aplicaciones como cualquier otra aplicación. Puedes quitarla de nuevo en _Quitar > TUI_.
