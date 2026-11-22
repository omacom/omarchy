# Neovim

[Neovim](https://neovim.io/) es una implementación moderna de [el editor vi](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) creado por Bill Joy allá por 1976. Es un editor modal donde el modo de inserción y el modo de comandos están separados, y es una especie de superpoder una vez que aprendes aunque sea solo una parte del increíblemente profundo conjunto de comandos con teclas. ¡Pero también tiene una curva de aprendizaje considerable!

Si eres totalmente nuevo en la edición estilo vim, te recomiendo que veas [la serie Vim As Your Editor de ThePrimeagen](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) en YouTube. Eso te enseñará lo básico. Solo ten en cuenta que, a diferencia de los editores convencionales más parecidos entre sí, te va a llevar más tiempo adquirir un dominio básico de vim. Pero una vez que lo logres, la recompensa también es mayor.

Ahora bien, Neovim es básicamente infinitamente configurable. Si de verdad quieres volverte loco, puedes crear tu propia configuración de Neovim desde cero. Hay un curso excelente de [Typecraft sobre cómo configurar Neovim desde cero](https://www.youtube.com/watch?v=zHTeCSVAFNY). Y [ThePrimeagen también tiene uno](https://www.youtube.com/watch?v=w7i4amO_zaE).

Pero Omarchy incluye una configuración completa de Neovim — el paquete `omarchy-nvim` — que ha sido ajustada con mucho cariño para mostrar lo mejor de lo que es posible desde el primer momento. ¡Sin que tengas que escribir una sola línea de configuración! Está construida sobre [LazyVim](https://www.lazyvim.org/), una distribución de plugins y configuraciones de Neovim. Es increíble.

## Conceptos básicos de LazyVim

Como ya mencioné, no voy a enseñarte vim en esta breve introducción, pero sí puedo mostrarte algunos conceptos básicos de LazyVim y cómo moverte.

Primero, Neovim tiene la idea de la tecla líder. Esa es básicamente la puerta de entrada a todos los comandos. LazyVim la ha configurado como `Space`. Así que solo presiónala, espera un segundo y verás un montón de opciones explicadas en línea así:

Aquí tienes algunos comandos básicos que uso todo el tiempo:

- `Space Space` - Busca cualquier archivo en el directorio actual con búsqueda difusa.
- `Space S G` - Busca en todos los archivos usando grep con una vista previa.
- `Space E` - Muestra u oculta el árbol de archivos.
- `Ctrl + W W` - Salta del árbol de archivos al editor y de vuelta.
- `Shift + H` - Muévete a la izquierda entre las pestañas abiertas (vim las llama buffers).
- `Shift + L` - Muévete a la derecha entre las pestañas abiertas.
- `Space B D` - Cierra una pestaña.
- `Space B O` - Cierra todas las demás pestañas excepto la actual.
- `Space G G` - Abre LazyGit en un panel flotante desde el directorio actual.
- `Space U W` - Activa o desactiva el ajuste de línea suave.

Mientras estás en el árbol de archivos (`Space E` para mostrarlo, `Ctrl + W W` para saltar ahí), puedes agregar un archivo nuevo con `a` o un directorio nuevo con `A`. Presiona `?` mientras estás en el árbol para ver todos los comandos.

Si quieres aprender el lenguaje básico de vim, he escrito sobre [la sintaxis de tres partes](https://world.hey.com/dhh/wonderful-vi-a1d034d3) ¡y cómo lograr esos movimientos en combo tan impresionantes!

Puedes ver todos los comandos posibles en [la página de atajos de teclado de LazyVim](https://www.lazyvim.org/keymaps).

## Cómo iniciar Neovim

`Super + Shift + N` abre tu editor predeterminado, que es Plain en las instalaciones nuevas; elige Neovim en _Configuración > Valores predeterminados > Editor_ para que en su lugar abra Neovim. Pero normalmente es más fácil usarlo desde la terminal navegando al directorio en el que quieres trabajar y escribiendo `n`. La `n` es el alias de `nvim`, que por defecto abrirá el directorio actual. Puedes abrir un solo archivo con `n myfile.txt`.

## Uso de Neovim para ediciones con sudo

Si necesitas editar archivos que solo puedes cambiar como superusuario, ejecuta `sudoedit /etc/sudoers.d/00-sudo-only-file`. Abre tu editor predeterminado, así que configura Neovim en _Configuración > Valores predeterminados > Editor_ si lo quieres ahí con todos tus plugins.
