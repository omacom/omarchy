# Herramientas de desarrollo

## Editores alternativos

Omarchy incluye Plain como editor predeterminado en las instalaciones nuevas y [Neovim](https://neovim.io/) preinstalado, pero si quieres algo un poco más convencional y familiar, puedes abrir el Menú de Omarchy (`Super + Space`) y ver las opciones en _Instalar > Editor_. Ahí están VSCode, Cursor, Zed, Sublime Text, Helix, Vim y Emacs. Si no encuentras lo que buscas, echa un vistazo a _Instalar > Paquete_ y revisa si no está en un paquete de Arch (y si no, prueba _Instalar > AUR_ para buscar en el AUR).

El editor `vi` original también está disponible de fábrica. Ejecuta `vi filename` para editar un archivo en la terminal.

La coincidencia de temas se ofrece para `VSCode`, `Cursor`, `VSCodium` y `Helix`.

Puedes establecer el editor predeterminado para todo el sistema en `Setup > Defaults > Editor`.

## Entorno

Omarchy permite configurar un montón de entornos de desarrollo mediante la sección _Instalar > Desarrollo_ del Menú de Omarchy (`Super + Space`). Por supuesto que encontrarás _Ruby on Rails_, pero también los tres principales entornos de ejecución para JavaScript (Node.js, Bun, Deno), así como frameworks populares de PHP como Laravel y Symfony. Ah, y también hay Go, Rust, Python, Java, Elixir (con Phoenix), .NET, OCaml, Zig, Clojure y Scala. ¡Es una selección muy amplia!

La mayoría de estos entornos se gestionan con [Mise](https://mise.jdx.dev/). Es una herramienta que te permite instalar y ejecutar varias versiones de un lenguaje de programación en la misma máquina. Es como rbenv o rvm para Ruby o virtualenv para Python, pero funciona para un montón de entornos diferentes.

Para instalar, digamos, Ruby, ejecutarías `mise use -g ruby`, lo que instalará Ruby y lo establecerá como predeterminado global. O, si tu proyecto tiene un archivo .ruby-version, solo tienes que ejecutar `mise i` en la raíz de ese proyecto.

## Herramientas CLI preinstaladas

`uv`, Node.js y `playwright-cli` (para que los agentes controlen un navegador usando el Chrome instalado) vienen instalados como paquetes, y `omarchy update` los mantiene actualizados junto con el resto del sistema. `ghui`, [Hunk](https://github.com/modem-dev/hunk) y las CLI de Basecamp, Cloudflare y HEY están a una selección de distancia en _Instalar > CLI_, y los [agentes de programación](17-ai.md) en _Instalar > AI > CLI_.

mise solo gestiona los entornos de ejecución que configuras desde _Instalar > Desarrollo_; Omarchy no instala nada a través de él por su cuenta. Ejecuta `omarchy update` para actualizarlos junto con el resto de Omarchy; el alias `mup` actualiza solo las herramientas gestionadas por mise. Para agregar otra herramienta a tu propia configuración, usa `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) casi no necesita presentación. Te permite ejecutar contenedores aislados, y Omarchy instala todo lo necesario para que funcione bien, incluido el propio Docker y [Docker Compose](https://docs.docker.com/compose/).

Por defecto, tu usuario *no* está en el grupo `docker`. Ese grupo equivale en la práctica a root sin contraseña —cualquier cosa en él puede ejecutar `docker run -v /:/host` y apoderarse de la máquina—, así que un solo script o dependencia maliciosa que se ejecute como tú estaría, de otro modo, a un comando de distancia de ser root. Por eso, en la línea de comandos ejecutas Docker con `sudo` (`sudo docker ps`, `sudo docker compose up`), y las herramientas gráficas que se comunican con el daemon —la VM de Windows— piden autorización cuando la necesitan. Si quieres recuperar la comodidad de una configuración sin grupo y entiendes lo que implica a cambio, actívala desde **Configuración > Seguridad > Docker sin sudo** (o ejecuta `omarchy-setup-security-sudoless-docker`), lo que te agrega al grupo `docker` después de una advertencia; entonces `docker` a secas y el alias `d` vuelven a funcionar sin `sudo`.

Puedes configurar las bases de datos comunes para desarrollo local en Docker usando _Instalar > Desarrollo > Docker DB_ en el menú de Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) es `gh`, para trabajar con repositorios, issues y pull requests desde la terminal. _Configuración > Git_ lo instala cuando eliges iniciar sesión en GitHub ahí, y luego `gh repo clone org/repo` clona un repositorio. Ejecuta `gh --help` para explorar sus comandos.

_Instalar > CLI > GitHub_ instala GitHub CLI, `gh`, junto con `ghui`, una interfaz de terminal para pull requests. [Lazygit](https://github.com/jesseduffield/lazygit) viene preinstalado para trabajar con el propio Git.
