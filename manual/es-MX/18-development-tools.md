# Herramientas de desarrollo

## Editores alternativos

Omarchy incluye Plain como el editor predeterminado en las instalaciones nuevas y [Neovim](https://neovim.io/) preinstalado, pero si quieres algo un poco más convencional y familiar, puedes abrir el Omarchy Menu (`Super + Space`) y ver las opciones en _Install > Editor_. Ahí tenemos VSCode, Cursor, Zed, Sublime Text, Helix, Vim y Emacs. Si no encuentras lo que buscas, échale un ojo a _Install > Package_ y ve si no está en un paquete de Arch (y si no, prueba _Install > AUR_ para buscar en el AUR).

El editor `vi` original también está disponible desde el inicio. Ejecuta `vi filename` para editar un archivo en la terminal.

Se ofrece coincidencia de temas para `VSCode`, `Cursor`, `VSCodium` y `Helix`.

Puedes establecer el editor predeterminado para todo el sistema en `Setup > Defaults > Editor`.

## Entorno

Omarchy permite configurar un montón de entornos de desarrollo desde la sección _Install > Development_ del Omarchy Menu (`Super + Space`). Por supuesto, encontrarás _Ruby on Rails_, pero también los tres principales runtimes de JavaScript (Node.js, Bun, Deno), así como frameworks populares de PHP como Laravel y Symfony. Ah, y también están Go, Rust, Python, Java, Elixir (con Phoenix), .NET, OCaml, Zig, Clojure y Scala. ¡Es una selección muy amplia!

La mayoría de estos entornos los gestiona [Mise](https://mise.jdx.dev/). Es una herramienta que te permite instalar y ejecutar varias versiones de un lenguaje de programación en la misma máquina. Es como rbenv o rvm para Ruby o virtualenv para Python, pero funciona para un montón de entornos distintos.

Para instalar, digamos, Ruby, ejecutarías `mise use -g ruby`, que instalará Ruby y también lo establecerá como el predeterminado global. O, si tu proyecto tiene un archivo .ruby-version, puedes simplemente ejecutar `mise i` en la raíz de ese proyecto.

## Herramientas CLI preinstaladas

`uv`, Node.js y `playwright-cli` (para que los agentes controlen un navegador usando el Chrome instalado) vienen instalados como paquetes, y `omarchy update` los mantiene actualizados junto con el resto del sistema. [Hunk](https://github.com/modem-dev/hunk) y las CLI de GitHub, Basecamp, Cloudflare y HEY están a una selección de distancia en _Install > CLI_, y los [agentes de programación](17-ai.md) en _Install > AI > CLI_.

Mise solo gestiona los runtimes que configuras desde _Install > Development_; Omarchy no instala nada a través de él por su cuenta. Ejecuta `omarchy update` para actualizarlos junto con el resto de Omarchy; el alias `mup` actualiza solo las herramientas gestionadas por mise. Para agregar otra herramienta a tu propia configuración, usa `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) casi no necesita presentación. Te permite ejecutar contenedores aislados, y Omarchy instala todo lo necesario para que funcione bien, incluido el propio Docker y [Docker Compose](https://docs.docker.com/compose/).

Por defecto, tu usuario *no* está en el grupo `docker`. Ese grupo es, en la práctica, root sin contraseña — cualquier cosa que esté en él puede ejecutar `docker run -v /:/host` y apoderarse de la máquina —, así que un solo script o dependencia maliciosa que se ejecute como tú estaría, de otro modo, a un solo comando de ser root. Así que en la línea de comandos ejecutas Docker con `sudo` (`sudo docker ps`, `sudo docker compose up`), y las herramientas gráficas que se comunican con el daemon — la Windows VM — piden autorización cuando la necesitan. Si quieres recuperar la comodidad de no usar `sudo` y entiendes el compromiso, actívalo desde **Setup > Security > Sudoless Docker** (o ejecuta `omarchy-setup-security-sudoless-docker`), que te agrega al grupo `docker` después de una advertencia; entonces `docker` a secas y el alias `d` vuelven a funcionar sin `sudo`.

Puedes configurar las bases de datos comunes para desarrollo local en Docker usando _Install > Development > Docker DB_ en el menú de Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) es `gh`, para trabajar con repositorios, issues y pull requests desde la terminal. _Setup > Git_ lo instala cuando eliges iniciar sesión en GitHub ahí, o instálalo por separado desde _Install > CLI > GitHub_. Luego `gh repo clone org/repo` clona un repositorio; ejecuta `gh --help` para explorar sus comandos.

[Lazygit](https://github.com/jesseduffield/lazygit) está preinstalado para trabajar con el propio Git.
