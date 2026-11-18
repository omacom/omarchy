# Herramientas de desarrollo

## Editores alternativos

Omarchy viene con [Neovim](https://neovim.io/) por defecto, pero si quieres algo un poco más convencional y familiar, puedes abrir el Menú de Omarchy (`Super + Space`) y ver las opciones en _Instalar > Editor_. Ahí tenemos VSCode, Cursor, Zed, Sublime Text, Helix, Vim y Emacs. Si no encuentras lo que buscas, échale un vistazo a _Instalar > Paquete_ y revisa si no está en un paquete de Arch (y si no, prueba _Instalar > AUR_ para buscar en AUR).

El editor original `vi` también está disponible desde el inicio. Ejecuta `vi filename` para editar un archivo en la terminal.

Hay temas a juego disponibles para `VSCode`, `Cursor`, `VSCodium` y `Helix`.

Puedes establecer el editor predeterminado para todo el sistema en `Setup > Defaults > Editor`.

## Entorno

Omarchy permite configurar un montón de entornos de desarrollo a través de la sección _Instalar > Desarrollo_ del Menú de Omarchy (`Super + Space`). Encontrarás, por supuesto, _Ruby on Rails_, pero también los tres principales runtimes para JavaScript (Node.js, Bun, Deno), así como frameworks populares de PHP como Laravel y Symfony. Ah, y también hay Go, Rust, Python, Java, Elixir (con Phoenix), .NET, OCaml, Zig, Clojure y Scala. ¡Es una selección muy amplia!

La mayoría de estos entornos se gestionan con [Mise](https://mise.jdx.dev/). Es una herramienta que te permite instalar y ejecutar múltiples versiones de un lenguaje de programación en la misma computadora. Es como rbenv o rvm para Ruby o virtualenv para Python, pero funciona para un montón de entornos distintos.

Para instalar, digamos, Ruby, ejecutarías `mise use -g ruby`, lo que instalará Ruby y lo establecerá como predeterminado global. O, si tu proyecto tiene un archivo .ruby-version, simplemente puedes ejecutar `mise i` en la raíz de ese proyecto.

## Herramientas CLI preinstaladas

Omarchy pone a tu disposición herramientas como `gh`, `uv` y la mayoría de los [agentes de codificación](17-ai.md) mediante la [instalación diferida de mise](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). La primera vez que ejecutas una, mise la instala. En ejecuciones posteriores se reutiliza la versión instalada; no se busca una actualización en cada inicio.

También puedes revisar los valores predeterminados o instalarlas por adelantado:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Ejecuta `omarchy update` para actualizar las herramientas instaladas junto con el resto de Omarchy. El alias `mup` actualiza solo las herramientas gestionadas por mise. Para agregar otra herramienta a tu propia configuración, usa `mise use -g <tool>`.

La configuración de Python también instala `uv` mediante mise. Al eliminar el entorno de desarrollo de Python, `uv` sigue disponible como herramienta independiente.

### Usar tu propia instalación

Los comandos de mise van antes de `~/.local/bin` en `PATH`, así que una herramienta que instalaste por tu cuenta, por ejemplo con el instalador propio de Claude Code o de Cursor, seguirá ejecutando la copia de mise. Las aplicaciones lanzadas desde el escritorio también encuentran los comandos de mise antes que los paquetes del sistema, así que una aplicación que ejecuta `gh` obtiene la copia de mise incluso si instalaste `github-cli` con pacman, y mise instala esa copia la primera vez. Para usar la tuya, desactiva la copia de mise en `~/.config/mise/config.toml`. Por ejemplo, si instalaste Cursor CLI por tu cuenta:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

Si ya tienes una tabla `[settings]`, agrega la entrada ahí; extiende una lista `disable_tools` existente en lugar de reemplazarla. Asegúrate de que tu instalación esté en `PATH`. Usa el nombre de la herramienta de mise, que puede diferir de su comando: `oh-my-pi` proporciona `omp`, por ejemplo. El lanzador del agente predeterminado también prefiere un Cursor o Muse instalado por el usuario en `~/.local/bin`.

### Eliminar y restaurar los valores predeterminados

_Eliminar preinstalados_ hace que mise omita las declaraciones de herramientas de Omarchy para tu usuario, al agregarlas a `ignored_config_paths` en `~/.config/mise/miserc.toml`. _Restaurar preinstalados_ elimina esa línea de nuevo. Las herramientas que declares por tu cuenta, en tu propia configuración o en el `mise.toml` de un proyecto, seguirán funcionando en cualquier caso. Si eliges un agente predeterminado o configuras Python después de eliminar los preinstalados, esa herramienta se agregará a tu propia configuración. Ambas opciones aplican solo a tu usuario; los demás usuarios de la computadora conservan su propia elección.

## Docker

[Docker](https://www.docker.com/) casi no necesita presentación. Te permite ejecutar contenedores aislados, y Omarchy instala todo lo necesario para que funcione bien, incluido el propio Docker y [Docker Compose](https://docs.docker.com/compose/).

Por defecto, tu usuario *no* está en el grupo `docker`. Ese grupo es, en la práctica, root sin contraseña —cualquier cosa en él puede ejecutar `docker run -v /:/host` y tomar el control de la computadora—, así que un solo script o dependencia maliciosa que se ejecute como tú estaría, de otro modo, a un comando de obtener root. Por eso, en la línea de comandos ejecutas Docker con `sudo` (`sudo docker ps`, `sudo docker compose up`), y las herramientas gráficas que se comunican con el daemon —la VM de Windows— piden autorización cuando la necesitan. Si quieres recuperar la comodidad de una configuración sin grupo y entiendes el compromiso, actívala desde **Configuración > Seguridad > Docker sin sudo** (o ejecuta `omarchy-setup-security-sudoless-docker`), lo que te agregará al grupo `docker` después de una advertencia; entonces el simple `docker` y el alias `d` volverán a funcionar sin `sudo`.

Puedes configurar las bases de datos comunes para desarrollo local en Docker usando _Instalar > Desarrollo > Docker DB_ en el menú de Omarchy.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) está disponible como `gh` para trabajar con repositorios, issues y pull requests desde la terminal. Ejecuta `gh auth login` para instalarlo en el primer uso y autenticarte, luego `gh repo clone org/repo` para clonar un repositorio. Ejecuta `gh --help` para explorar sus comandos.

Para una interfaz de terminal para pull requests, ejecuta `ghui`; mise también lo instala en el primer uso. [Lazygit](https://github.com/jesseduffield/lazygit) viene preinstalado para trabajar con el propio Git.
