# Neovim

[Neovim](https://neovim.io/) es una implementación moderna [del editor vi](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) creado por Bill Joy allá por 1976. Es un editor modal donde el modo de inserción y el modo de comandos están separados, y se convierte en una especie de superpoder en cuanto aprendes aunque sea una parte del enorme repertorio de comandos de teclado. ¡Aunque la curva de aprendizaje es considerable!

Si eres totalmente nuevo en la edición estilo vim, te recomiendo ver [la serie Vim As Your Editor de ThePrimeagen](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) en YouTube. Eso te enseñará lo básico. Solo ten en cuenta que, a diferencia de otros editores más convencionales, que se parecen más entre sí, te llevará más tiempo alcanzar un dominio básico de vim. Pero cuando lo logras, la recompensa también es mayor.

Ahora bien, Neovim se puede configurar hasta el infinito. Si de verdad quieres volverte loco, puedes crear tu propia configuración de Neovim desde cero. Hay un curso excelente de [Typecraft sobre cómo configurar Neovim desde cero](https://www.youtube.com/watch?v=zHTeCSVAFNY). Y [ThePrimeagen también tiene uno](https://www.youtube.com/watch?v=w7i4amO_zaE).

Pero Omarchy incluye una configuración completa de Neovim — el paquete `omarchy-nvim` — ajustada con cariño para sacar lo mejor que puede dar de sí desde el primer momento. ¡Sin que tengas que escribir ni una sola línea de configuración! Está construida sobre [LazyVim](https://www.lazyvim.org/), una distribución de plugins y configuraciones de Neovim. Es increíble.

## Conceptos básicos de LazyVim

Como ya mencioné, no voy a enseñarte vim en esta introducción breve, pero sí puedo mostrarte algunos conceptos básicos de LazyVim y cómo moverte por ahí.

Primero, Neovim tiene el concepto de tecla líder (leader key). Es básicamente la puerta de entrada a todos los comandos. LazyVim la ha fijado en `Space`. Así que solo púlsala, espera un segundo y verás un montón de opciones con su explicación al lado, así:

Aquí tienes algunos comandos básicos que uso todo el tiempo:

- `Space Space` - Busca cualquier archivo en el directorio actual con búsqueda difusa.
- `Space S G` - Busca en todos los archivos usando grep con vista previa.
- `Space E` - Muestra u oculta el árbol de archivos.
- `Ctrl + W W` - Salta del árbol de archivos al editor y de vuelta.
- `Shift + H` - Pasa a la pestaña de la izquierda (vim las llama buffers).
- `Shift + L` - Pasa a la pestaña de la derecha.
- `Space B D` - Cierra una pestaña.
- `Space B O` - Cierra todas las demás pestañas excepto la actual.
- `Space G G` - Abre LazyGit en un panel flotante desde el directorio actual.
- `Space U W` - Activa o desactiva el ajuste de línea suave.

Mientras estás en el árbol de archivos (`Space E` para mostrarlo, `Ctrl + W W` para saltar hasta ahí), puedes añadir un archivo nuevo con `a` o un directorio nuevo con `A`. Pulsa `?` estando en el árbol para ver todos los comandos.

Si quieres aprender el lenguaje básico de vim, he escrito sobre [la sintaxis de tres partes](https://world.hey.com/dhh/wonderful-vi-a1d034d3) y cómo hacer esas combinaciones de teclas tan espectaculares.

Puedes ver todos los comandos posibles en [la página de atajos de LazyVim](https://www.lazyvim.org/keymaps).

## Iniciar Neovim

`Super + Shift + N` abre tu editor predeterminado, que es Plain en las instalaciones nuevas; elige Neovim en _Configurar > Predeterminados > Editor_ para que en su lugar abra Neovim. Pero normalmente es más fácil usarlo desde el terminal navegando al directorio en el que quieres trabajar y escribiendo `n`. La `n` es el alias de `nvim`, que por defecto abrirá el directorio actual. Puedes abrir un solo archivo con `n myfile.txt`.

## Usar Neovim para ediciones con sudo

Si necesitas editar archivos que solo puedes cambiar como superusuario, ejecuta `sudoedit /etc/sudoers.d/00-sudo-only-file`. Abre tu editor predeterminado, así que configura Neovim en _Configurar > Predeterminados > Editor_ si lo quieres ahí con todos tus plugins.
