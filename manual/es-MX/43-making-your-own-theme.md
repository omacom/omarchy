# Crea tu propio tema

Puedes añadir tus propios temas a `~/.config/omarchy/themes`. Solo copia uno de los existentes como base (busca en `/usr/share/omarchy/themes`) y luego ajústalo a tu gusto. Mientras tu tema esté dentro de esa carpeta, se incluirá en el menú de selección de temas.

El archivo principal que tienes que ajustar es `colors.toml`. Ese define el conjunto de colores que luego se usa para generar las configuraciones de la terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian y todo el shell de Omarchy (barra superior, menú, notificaciones, OSD y pantalla de bloqueo).

También puedes usar la aplicación incluida Aether para crear un nuevo tema usando una encantadora interfaz GUI para jugar con los colores y buscar fondos. Solo iníciala desde la cuadrícula de apps con `Super + Alt + Space`.

### Qué puede contener un tema instalado

Un tema que escribas tú mismo en `~/.config/omarchy/themes` puede contener lo que quieras: es tu máquina y tu archivo, y Omarchy aplica todo.

Un tema que instales desde el repo de otra persona con `omarchy theme install` conserva todo lo que es color y pierde el puñado de archivos que ejecutarían código en tu máquina: cualquier archivo `.lua`, las configuraciones de terminal (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) y `vscode.json`. El `hyprland.lua` de un tema es Lua que tu compositor ejecuta al iniciar sesión, una configuración de terminal nombra el programa que inicia tu terminal, y `vscode.json` nombra una extensión de VSCode que se debe instalar. Instalar el tema de alguien debería cambiar cómo se ve tu escritorio, nunca qué ejecuta.

Todo lo demás sigue funcionando exactamente como lo escribió el autor del tema: `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, los fondos y las vistas previas se conservan. Solo lo que se descartó se regenera a partir de `colors.toml` en tu máquina.

Omarchy distingue ambos casos según si el tema tiene su propio repo de git dentro de él, que es lo que `omarchy theme install` deja cuando clona. Así que un tema que escribiste sigue siendo tuyo, y uno que bajaste de internet se limita a los colores.

### Modo claro

Si estás creando un tema en modo claro, establece `mode = "light"` al inicio de tu `colors.toml`. Entonces se emparejará automáticamente con el modo claro para todas las apps. (La forma antigua de dejar un archivo vacío llamado `light.mode` en la raíz de tu tema también sigue funcionando.)

### Colores de iconos

Si quieres que los iconos del gestor de archivos combinen en color con tu tema, añade un archivo llamado `icons.theme` con el nombre del conjunto de iconos que quieres usar. Por defecto, las opciones son: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Imagen de desbloqueo

Los temas que incluyan imágenes `unlock.png` y `preview-unlock.png` aparecerán en _Apariencia > Desbloqueo_. Tu `unlock.png` debería ser preferiblemente un png transparente. Y puedes crear la imagen de vista previa usando `omarchy plymouth preview`.

### Aplicar temas a apps que Omarchy no cubre

Si usas una app que no está en esa lista, puedes enseñarle a Omarchy a aplicarle un tema tú mismo con una plantilla. Deja un archivo en `~/.config/omarchy/themed/` con el nombre de la configuración que genera más una extensión `.tpl`, y escribe la configuración con `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` hasta `{{ color15 }}`, y el resto de la paleta como marcadores. Cada vez que cambies de tema, el archivo se regenera con los colores de ese tema.

Hay un `alacritty.toml.tpl.sample` totalmente comentado en esa carpeta para que lo copies: enumera todas las variables que puedes usar, además de los modificadores `_strip` y `_rgb` para las apps que quieren sus colores sin el `#` o como RGB decimal. Tus plantillas tienen prioridad sobre las propias de Omarchy, así que también puedes usar esto para sobrescribir cómo se aplica el tema a una app integrada.

### Distribuir tu tema

Si quieres distribuir tu tema para que otros puedan usarlo, tienes que ponerlo en un servidor git público, como GitHub. Luego la gente puede instalarlo usando _Instalar > Estilo > Tema_ en el menú de Omarchy usando esa URL. Se recomienda que sigas la convención de nombres de `omarchy-[themename]-theme`, ya que el tema se mostrará correctamente como solo `[themename]` en el menú de selección de temas después de la instalación.

Ese `[themename]` restante se convierte en el nombre del directorio del tema, así que tiene que ser uno que Omarchy pueda manejar con seguridad: debe empezar con una letra, un dígito o un guion bajo, y el resto puede contener letras, dígitos, `.`, `_`, `+` y `-`. Las mayúsculas se convierten a minúsculas por ti, pero cualquier otra cosa —un espacio, una comilla, un carácter no inglés— se rechaza al momento de la instalación en lugar de convertirse en un nombre de directorio. Así que `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` y `omarchy-c++-theme` se instalan sin problemas.

Recuerda que una vez instalado desde un repo, cualquier `.lua`, configuración de terminal o `vscode.json` que incluya se descarta, así que no construyas el tema en torno a esos archivos.

Puedes hacer que tu tema se añada a [la página de temas extra](https://omarchy.org/themes/) enviando una pull request al [repo omarchy-site](https://github.com/omacom-io/omarchy-site).
