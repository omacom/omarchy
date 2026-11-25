# Herramientas de desarrollo

## Editores alternativos

Omarchy incluye Plain como el editor predeterminado en las instalaciones nuevas y [Neovim](https://neovim.io/) preinstalado, pero si quieres algo un poco más convencional y familiar, puedes abrir el menú de Omarchy (`Super + Space`) y ver las opciones en _Instalar > Editor_. Allí tenemos VSCode, Cursor, Zed, Sublime Text, Helix, Vim y Emacs. Si no encuentras lo que buscas, revisa _Instalar > Paquete_ y mira si no está en un paquete de Arch (y si no, prueba _Instalar > AUR_ para consultar el AUR).

El editor original `vi` también viene incluido de serie. Ejecuta `vi filename` para editar un archivo en la terminal.

Hay temas a juego disponibles para `VSCode`, `Cursor`, `VSCodium` y `Helix`.

Puedes establecer el editor predeterminado para todo el sistema en `Configurar > Predeterminados > Editor`.

## Entorno

Desde la sección _Instalar > Desarrollo_ del Menú de Omarchy puedes montar un buen número de entornos de desarrollo (`Super + Space`). Encontrarás, por supuesto, _Ruby on Rails_, pero también los tres entornos de ejecución principales para JavaScript (Node.js, Bun, Deno), así como frameworks populares de PHP como Laravel y Symfony. Ah, y también hay Go, Rust, Python, Java, Elixir (con Phoenix), .NET, OCaml, Zig, Clojure y Scala. ¡Es una selección muy amplia!

La mayoría de estos entornos se gestionan con [Mise](https://mise.jdx.dev/). Con ella puedes instalar y ejecutar varias versiones de un lenguaje de programación en el mismo ordenador. Es como rbenv o rvm para Ruby o virtualenv para Python, pero funciona para un montón de entornos distintos.

Para instalar, por ejemplo, Ruby, ejecuta `mise use -g ruby`, que instalará Ruby y lo dejará como predeterminado global. O, si tu proyecto tiene un archivo .ruby-version, simplemente puedes ejecutar `mise i` en la raíz de ese proyecto.

## Herramientas CLI preinstaladas

`uv`, Node.js y `playwright-cli` (para que los agentes controlen el navegador con el Chrome instalado) vienen instalados como paquetes. `omarchy update` los mantiene al día con el resto del sistema. Puedes instalar [Hunk](https://github.com/modem-dev/hunk) y las CLI de GitHub, Basecamp, Cloudflare y HEY desde _Instalar > CLI_. Los [agentes de programación](17-ai.md) están en _Instalar > IA > CLI_.

mise solo gestiona los entornos de ejecución que configuras desde _Instalar > Desarrollo_. Omarchy no instala nada por su cuenta a través de mise. Ejecuta `omarchy update` para actualizarlos con el resto de Omarchy. El alias `mup` actualiza únicamente las herramientas gestionadas por mise. Para añadir otra herramienta a tu propia configuración, ejecuta `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) casi no necesita presentación. Sirve para ejecutar contenedores aislados, y Omarchy instala todo lo necesario para que funcione bien, incluido el propio Docker y [Docker Compose](https://docs.docker.com/compose/).

Por defecto, tu usuario *no* está en el grupo `docker`. Ese grupo es, en la práctica, root sin contraseña —cualquier cosa en él puede ejecutar `docker run -v /:/host` y tomar el control del ordenador—, así que un solo script o dependencia maliciosa que se ejecute como tú estaría a un comando de ser root. Por eso, en la línea de comandos ejecutas Docker con `sudo` (`sudo docker ps`, `sudo docker compose up`), y las herramientas gráficas que se comunican con el daemon —la VM de Windows— piden autorización cuando la necesitan. Si quieres recuperar la comodidad de una configuración sin grupo y entiendes el compromiso, actívala desde **Configuración > Seguridad > Docker sin sudo** (o ejecuta `omarchy-setup-security-sudoless-docker`), lo que te añadirá al grupo `docker` después de una advertencia; entonces el simple `docker` y el alias `d` volverán a funcionar sin `sudo`.

Las bases de datos habituales para desarrollo local en Docker se configuran desde _Instalar > Desarrollo > Docker DB_, en el menú de Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) es el comando `gh` para trabajar con repositorios, incidencias y pull requests desde la terminal. _Configurar > Git_ la instala si eliges iniciar sesión en GitHub. También puedes instalarla directamente desde _Instalar > CLI > GitHub_. Después, ejecuta `gh repo clone org/repo` para clonar un repositorio o `gh --help` para consultar los comandos disponibles.

[Lazygit](https://github.com/jesseduffield/lazygit) viene preinstalado para trabajar con Git.
