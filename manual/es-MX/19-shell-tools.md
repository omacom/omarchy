# Herramientas de shell

Además de las herramientas estándar de Linux, Omarchy también viene con un montón de herramientas de shell mejoradas. Estas son las principales.

## fzf

[fzf](https://junegunn.github.io/fzf/) te da búsqueda difusa de archivos mediante el alias `ff`. Ve a cualquier directorio, escribe `ff` y podrás buscar de forma difusa cualquier archivo en ese árbol, mientras ves una vista previa de los archivos que vas acotando en el lado derecho.

Puedes usar `Ctrl + R` para usar fzf y buscar de forma difusa en tu historial de comandos.

Esta herramienta también la usa Neovim cuando escribes `Space Space`.

El manual completo se puede consultar con `man fzf`.

## Zoxide

[Zoxide](https://github.com/ajeetdsouza/zoxide) es un reemplazo de cd. Recuerda los directorios en los que has estado, para que puedas saltar a ellos más fácilmente la próxima vez. Digamos que haces `cd ~/.config/omarchy` una vez. La próxima vez, puedes simplemente hacer `cd omarchy` (o incluso solo `cd oma`), y Zoxide te llevará directo ahí.

El manual completo se puede consultar con `man zoxide`.

## ripgrep

[ripgrep](https://github.com/BurntSushi/ripgrep) busca el contenido de los archivos usando `rg <pattern> <path>`, como `rg Controller app/` para encontrar todas las menciones de `Controller` en el directorio app.

Esta herramienta también la usa Neovim cuando escribes `Space S G`.

El manual completo se puede consultar con `man rg`.

## eza

[eza](https://eza.rocks/) es un reemplazo de ls. Te da listados de directorios con más información, color e íconos. De forma predeterminada, eza tiene el alias ls. También puedes usar `lt` para obtener un listado de dos niveles de anidamiento. `lsa` te da un listado que incluye archivos ocultos. Y `lta` un listado anidado con archivos ocultos.

El manual completo se puede consultar con `man eza`.

## fd

[fd](https://github.com/sharkdp/fd) es un reemplazo más fácil de usar para `find`. Usa `fd person.rb` para encontrar un archivo llamado `person.rb` dentro del árbol actual. `fd person.rb /` buscará en todo el sistema de archivos. `fd person.rb / -H` busca en todo el sistema de archivos, incluidos los directorios ocultos.

El manual completo se puede consultar con `man fd`.

## bat

[bat](https://github.com/sharkdp/bat) es `cat` con resaltado de sintaxis, números de línea y paginación. Ejecuta `bat somefile.rb` y verás por qué es difícil volver atrás. También trabaja en silencio para ti en otros lugares: es lo que colorea tus páginas de manual y lo que renderiza las vistas previas en `ff`.

El manual completo se puede consultar con `man bat`.

## tldr

[tldr](https://tldr.sh/) es el antídoto contra las páginas de manual que empiezan con tres pantallas de historia antes de mostrarte un solo ejemplo. `tldr tar` te da el puñado de invocaciones que en realidad querías.

## yt-dlp

[yt-dlp](https://github.com/yt-dlp/yt-dlp) descarga video de YouTube y cientos de otros sitios. `yt-dlp <url>` obtiene la mejor calidad disponible en el directorio actual.

El manual completo se puede consultar con `man yt-dlp`.

## try

[try](https://github.com/tobi/try) facilita gestionar experimentos de programación con directorios con fecha. Todos los experimentos viven en `~/Work/tries` y puedes acceder a ellos con `try`.

Omarchy no agrega el directorio `bin/` de un proyecto a `PATH` automáticamente. Ejecuta las herramientas locales de confianza de un proyecto con una ruta relativa explícita, como `bin/rails` o `./bin/dev`.
