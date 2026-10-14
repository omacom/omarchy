# Herramientas de desarrollo

## Editores alternativos

Omarchy viene con [Neovim](https://neovim.io/) de forma predeterminada, pero si prefieres algo más común y familiar, puedes abrir el menú de Omarchy (`Super + Space`) y ver las opciones en _Instalar > Editor_. Ahí tenemos VSCode, Cursor, Zed, Sublime Text, Helix, Vim y Emacs. Si no encuentras lo que buscas, revisa _Instalar > Paquete_ y ve si no está en un paquete de Arch (y si no, prueba _Instalar > AUR_ para buscar en el AUR).

El editor original `vi` también está disponible desde el principio. Ejecuta `vi filename` para editar un archivo en la terminal.

Se ofrece coincidencia de tema para `VSCode`, `Cursor`, `VSCodium` y `Helix`.

Puedes definir el editor predeterminado de todo el sistema en `Setup > Defaults > Editor`.

## Entorno

Omarchy permite configurar un montón de entornos de desarrollo desde la sección _Instalar > Desarrollo_ del menú de Omarchy (`Super + Space`). Por supuesto encontrarás _Ruby on Rails_, pero también los tres principales runtimes de JavaScript (Node.js, Bun, Deno), así como frameworks populares de PHP como Laravel y Symfony. Ah, y también hay Go, Rust, Python, Java, Elixir (con Phoenix), .NET, OCaml, Zig, Clojure y Scala. ¡Es una selección muy amplia!

La mayoría de estos entornos los gestiona [Mise](https://mise.jdx.dev/). Es una herramienta que te permite instalar y ejecutar varias versiones de un lenguaje de programación en la misma computadora. Es como rbenv o rvm para Ruby o virtualenv para Python, pero funciona para un montón de entornos distintos.

Para instalar, digamos, Ruby, ejecutarías `mise use -g ruby`, lo cual instala Ruby y lo deja como predeterminado global. O bien, si tu proyecto tiene un archivo .ruby-version, puedes simplemente ejecutar `mise i` en la raíz de ese proyecto.

## Docker

[Docker](https://www.docker.com/) prácticamente no necesita presentación. Te permite ejecutar contenedores aislados, y Omarchy instala todo lo necesario para que funcione bien, incluido Docker mismo y [Docker Compose](https://docs.docker.com/compose/).

De forma predeterminada tu usuario *no* está en el grupo `docker`. Ese grupo equivale en la práctica a root sin contraseña —cualquiera que esté en él puede ejecutar `docker run -v /:/host` y tomar el control de la computadora—, así que un solo script o dependencia maliciosa ejecutándose como tú estaría, de otro modo, a un comando de ser root. Por eso en la línea de comandos ejecutas Docker con `sudo` (`sudo docker ps`, `sudo docker compose up`), y las herramientas gráficas que hablan con el demonio —la máquina virtual de Windows— piden autorización cuando la necesitan. Si quieres recuperar la comodidad de una configuración sin grupo y entiendes el compromiso, actívala desde **Setup > Security > Sudoless Docker** (o ejecuta `omarchy-setup-security-sudoless-docker`), lo cual te agrega al grupo `docker` después de una advertencia; entonces `docker` a secas y el alias `d` vuelven a funcionar sin `sudo`.

Puedes configurar las bases de datos comunes para desarrollo local en Docker usando _Instalar > Desarrollo > Docker DB_ en el menú de Omarchy.

## GitHub CLI

[La CLI de GitHub](https://cli.github.com/) te permite autenticarte con tu cuenta de GitHub y clonar repositorios privados con ella. Está conectada como uno de los stubs de carga diferida de mise, así que la primera vez que ejecutas `gh`, se instala sola. Para autenticarte, ejecuta `gh auth login`. Después puedes clonar repositorios privados con `gh repo clone org/repo`.

También puedes hacer un montón de otras operaciones de GitHub con este comando. Solo ejecuta `gh` para ver todo lo que es posible.

También hay un stub de instalación diferida para `ghui` para gestionar tus pull requests en una TUI. Y [lazygit](https://github.com/jesseduffield/lazygit) viene preinstalado, por si también quieres manejar git desde una TUI.
