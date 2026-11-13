# Crear tu propio tema

Puedes agregar tus propios temas a `~/.config/omarchy/themes`. Solo copia uno de los existentes como base (busca en `/usr/share/omarchy/themes`) y luego ajústalo a tu gusto. Mientras tu tema esté dentro de esa carpeta, se incluirá en el menú de selección de temas.

El archivo principal que tienes que ajustar es `colors.toml`. Ese define el conjunto de colores que luego se usa para generar las configuraciones de la terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian y todo el shell de Omarchy (barra superior, menú, notificaciones, OSD y pantalla de bloqueo).

También puedes usar la aplicación Aether incluida para crear un tema nuevo con una encantadora interfaz GUI para jugar con los colores y buscar fondos. Solo iníciala desde la cuadrícula de aplicaciones con `Super + Alt + Space`.

### Qué puede contener un tema instalado

Un tema que escribes tú mismo en `~/.config/omarchy/themes` puede contener lo que quieras: es tu máquina y tu archivo, y Omarchy aplica todo.

Un tema que instalas desde el repositorio de otra persona con `omarchy theme install` conserva todo lo que es color y pierde el puñado de archivos que ejecutarían código en tu máquina: cualquier archivo `.lua`, las configuraciones de terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) y `vscode.json`. El `hyprland.lua` de un tema es Lua que tu compositor ejecuta al iniciar sesión, una configuración de terminal nombra el programa que inicia tu terminal y `vscode.json` nombra una extensión de VSCode para instalar. Instalar el tema de alguien debería cambiar cómo se ve tu escritorio, nunca qué ejecuta.

Todo lo demás sigue funcionando exactamente como lo escribió el autor del tema: `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, los fondos y las vistas previas se conservan todos. Solo lo que se descartó se regenera a partir de `colors.toml` en tu máquina.

Omarchy distingue entre ambos según si el tema tiene su propio repositorio git dentro, que es lo que `omarchy theme install` deja atrás cuando clona. Así, un tema que escribiste sigue siendo tuyo, y uno que bajaste de internet se queda en colores.

### Modo claro

Si estás creando un tema en modo claro, establece `mode = "light"` en la parte superior de tu `colors.toml`. Luego se emparejará automáticamente con el modo claro en todas las aplicaciones. (La forma antigua de dejar un archivo vacío llamado `light.mode` en la raíz de tu tema también sigue funcionando).

### Imagen de desbloqueo

Los temas que incluyan imágenes `unlock.png` y `preview-unlock.png` aparecerán en _Apariencia > Desbloqueo_. Tu `unlock.png` debería ser preferiblemente un png transparente. Y puedes crear la imagen de vista previa usando `omarchy plymouth preview`.

### Aplicar temas a aplicaciones que Omarchy no cubre

Si usas una aplicación que no está en esa lista, puedes enseñarle a Omarchy a aplicarle un tema tú mismo con una plantilla. Deja un archivo en `~/.config/omarchy/themed/` con el nombre de la configuración que genera más la extensión `.tpl`, y escribe la configuración con `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` hasta `{{ color15 }}`, y el resto de la paleta como marcadores de posición. Cada vez que cambies de tema, el archivo se regenera con los colores de ese tema.

Hay un `alacritty.toml.tpl.sample` totalmente comentado en esa carpeta para que lo copies: enumera todas las variables que puedes usar, además de los modificadores `_strip` y `_rgb` para aplicaciones que quieren sus colores sin el `#` o como RGB decimal. Tus plantillas tienen prioridad sobre las propias de Omarchy, así que también puedes usar esto para anular cómo se aplica el tema a una aplicación integrada.

### Distribuir tu tema

Si quieres distribuir tu tema para que otros puedan usarlo, tienes que ponerlo en un servidor git público, como GitHub. Luego la gente podrá instalarlo usando _Instalar > Estilo > Tema_ en el menú de Omarchy usando esa URL. Se recomienda que sigas la convención de nombres `omarchy-[themename]-theme`, ya que el tema se mostrará correctamente solo como `[themename]` en el menú de selección de temas después de la instalación.

Ese `[themename]` restante se convierte en el nombre del directorio del tema, así que tiene que ser uno que Omarchy pueda manejar de forma segura: debe empezar con una letra, un dígito o un guion bajo, y el resto puede contener letras, dígitos, `.`, `_`, `+` y `-`. Las mayúsculas se convierten a minúsculas por ti, pero cualquier otra cosa —un espacio, una comilla, un carácter que no sea del inglés— se rechaza al momento de la instalación en lugar de convertirse en un nombre de directorio. Así que `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` y `omarchy-c++-theme` se instalan sin problema.

Recuerda que una vez que se instala desde un repositorio, cualquier `.lua`, configuración de terminal o `vscode.json` que incluya se descarta, así que no construyas el tema en torno a eso.

Puedes hacer que tu tema se agregue a [la página de temas extra](https://omarchy.org/themes/) enviando un pull request a [el repositorio omarchy-site](https://github.com/omacom-io/omarchy-site).
