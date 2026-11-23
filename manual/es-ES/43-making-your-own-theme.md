# Crea tu propio tema

Puedes añadir tus propios temas a `~/.config/omarchy/themes`. Solo copia uno de los existentes como base (busca en `/usr/share/omarchy/themes`) y luego ajústalo a tu gusto. Mientras tu tema esté dentro de esa carpeta, se incluirá en el menú de selección de temas.

El archivo principal que tienes que ajustar es `colors.toml`. Ese define el conjunto de colores que luego se usa para generar la configuración del terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, las aplicaciones Qt, la retroiluminación del teclado, el método de entrada, el selector para compartir pantalla, los iconos de las aplicaciones, varias herramientas de IA (Claude, Pi, Hermes, T3 Code, Herdr) y todo el shell de Omarchy (barra superior, menú, notificaciones, OSD y pantalla de bloqueo).

También puedes crear un tema nuevo con Aether, la aplicación incluida, que ofrece una interfaz gráfica agradable para jugar con los colores y buscar fondos. Solo iníciala desde la rejilla de apps con `Super + Alt + Space`.

### Qué puede contener un tema instalado

Un tema que escribas tú mismo en `~/.config/omarchy/themes` puede contener lo que quieras: es tu máquina y tu archivo, y Omarchy lo aplica todo.

Un tema que instales desde el repo de otra persona con `omarchy theme install` conserva todo lo relacionado con el color y pierde el puñado de archivos que ejecutarían código en tu máquina: cualquier archivo `.lua`, las configuraciones de terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) y `vscode.json`. El `hyprland.lua` de un tema es Lua que tu compositor ejecuta al iniciar sesión, una configuración de terminal indica qué programa lanza tu terminal, y `vscode.json` indica una extensión de VSCode que se debe instalar. Instalar el tema de alguien debería cambiar cómo se ve tu escritorio, nunca qué ejecuta.

Todo lo demás sigue funcionando exactamente como lo escribió el autor del tema: `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, los fondos y las vistas previas se conservan. Solo lo que se descartó se regenera a partir de `colors.toml` en tu máquina.

Omarchy distingue los dos casos por si el tema tiene dentro su propio repo de git, que es lo que deja `omarchy theme install` al clonar. Así que un tema que escribiste sigue siendo tuyo, y uno que bajaste de internet se limita a los colores.

### Modo claro

Si estás creando un tema en modo claro, establece `mode = "light"` al inicio de tu `colors.toml`. Entonces se combinará automáticamente con el modo claro en todas las aplicaciones. (La forma antigua de dejar un archivo vacío llamado `light.mode` en la raíz de tu tema también sigue funcionando.)

### Imagen de desbloqueo

Los temas que incluyan imágenes `unlock.png` y `preview-unlock.png` aparecerán en _Apariencia > Desbloquear_. Tu `unlock.png` debería ser, a ser posible, un png transparente. Y puedes crear la imagen de vista previa usando `omarchy plymouth preview`.

### Aplicar temas a apps que Omarchy no cubre

Si usas una app que no está en esa lista, puedes enseñar a Omarchy a aplicarle un tema con una plantilla. Deja un archivo en `~/.config/omarchy/themed/` cuyo nombre sea el de la configuración que genera, con la extensión `.tpl`, y escribe la configuración con `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` hasta `{{ color15 }}`, y el resto de la paleta como marcadores. Cada vez que cambies de tema, el archivo se regenera con los colores de ese tema.

Hay un `alacritty.toml.tpl.sample` totalmente comentado en esa carpeta para que lo copies: enumera todas las variables que puedes usar, además de los modificadores `_strip` y `_rgb` para las apps que quieren sus colores sin el `#` o como RGB decimal. Tus plantillas tienen prioridad sobre las propias de Omarchy, así que también puedes usar esto para sobrescribir cómo se aplica el tema a una app integrada.

### Distribuir tu tema

Si quieres distribuir tu tema para que otros puedan usarlo, tienes que ponerlo en un servidor git público, como GitHub. Luego la gente puede instalarlo con _Instalar > Estilo > Tema_, en el menú de Omarchy, indicando esa URL. Se recomienda que sigas la convención de nombres de `omarchy-[themename]-theme`, ya que el tema se mostrará correctamente como solo `[themename]` en el menú de selección de temas después de la instalación.

Ese `[themename]` restante se convierte en el nombre del directorio del tema, así que tiene que ser uno que Omarchy pueda aceptar con seguridad: debe empezar con una letra, un dígito o un guion bajo, y el resto puede contener letras, dígitos, `.`, `_`, `+` y `-`. Las mayúsculas se convierten en minúsculas automáticamente, pero cualquier otra cosa —un espacio, una comilla, un carácter no inglés— se rechaza en el momento de la instalación en lugar de convertirse en un nombre de directorio. Así que `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` y `omarchy-c++-theme` se instalan sin problemas.

Recuerda que una vez instalado desde un repo, cualquier `.lua`, configuración de terminal o `vscode.json` que incluya se descarta, así que no construyas el tema en torno a esos archivos.

Puedes hacer que tu tema se añada a [la página de temas extra](https://omarchy.org/themes/) enviando una pull request al [repo omarchy-site](https://github.com/omacom-io/omarchy-site).
