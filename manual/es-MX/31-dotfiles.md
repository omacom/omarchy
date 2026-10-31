# Dotfiles

Omarchy se configura principalmente a través de los llamados dotfiles que viven en `~/.config`. Esos se consideran tus archivos para tus cambios. Los archivos que viven en `/usr/share/omarchy` pertenecen a Omarchy mismo, y no deberías estar metiendo mano en ellos. Si necesitas cambiar algo en `/usr/share/omarchy`, deberías sobrescribir el valor en `~/.config` en su lugar.

Las configuraciones clave se pueden editar directamente desde el menú de Omarchy (`Super + Space`), como _Setup > Keybindings_, _Setup > Input_ y _Setup > Config > [file]_. Cuando lo haces de esta manera, cualquier proceso que necesite reiniciarse después de editar la configuración lo hará automáticamente al salir del editor (Neovim por defecto — `:wq`, ¡recuérdalo! — pero puedes cambiarlo vía _Setup > Defaults > Editor_).

Aquí tienes una lista de los archivos clave en `~/.config` y lo que controlan:

| Archivo | Propósito |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | La configuración principal de Hyprland. Carga los valores por defecto de Omarchy además de tus archivos de sobrescritura de abajo. [Más información sobre las configuraciones de Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Tus propios atajos de teclado y sobrescrituras de los valores por defecto. |
| `~/.config/hypr/monitors.lua` | Ajustes de monitor que el panel de monitores no cubre, como la rotación, modos extra o mantener un monitor apagado. |
| `~/.config/hypr/input.lua` | Controla la distribución de tu teclado, el mouse y los ajustes del trackpad. |
| `~/.config/hypr/looknfeel.lua` | Controla los espacios, bordes, animaciones y el resto de la apariencia. |
| `~/.config/hypr/autostart.lua` | Controla los procesos extra que se inician con la sesión. |
| `~/.config/omarchy/shell.json` | Controla el shell de Omarchy: la posición de la barra, el diseño y los widgets, además de los tiempos del protector de pantalla, el bloqueo y la inactividad. |
| `~/.config/foot/foot.ini` | Controla tu terminal (foot es el predeterminado). |
| `~/.XCompose` | Define tus emojis de acceso rápido y el autocompletado de nombre/correo electrónico. Asegúrate de ejecutar `omarchy-restart-xcompose` después de hacer cambios. |

Si terminas haciendo muchos cambios para ajustar tu propia configuración, es buena idea respaldar todos estos dotfiles. [Stow es una excelente manera de hacerlo](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Iniciar tus propias aplicaciones con la sesión

Si quieres que algo se ejecute cada vez que inicias sesión — un daemon de sincronización, una aplicación de chat, tu propio script — ponlo en `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Eso inicia el comando como parte de la sesión, así que se limpia correctamente cuando vuelves a cerrar sesión.

### Ejecutar scripts en eventos del sistema

Omarchy dispara hooks en un puñado de momentos, y puedes colgar tus propios scripts de ellos. Viven en `~/.config/omarchy/hooks/<event>.d/`, un directorio por evento, y cada archivo ejecutable que haya ahí se ejecuta cuando ocurre el evento:

| Evento | Cuándo se ejecuta |
| ----- | ------------ |
| `post-boot` | Justo después de que se inició el escritorio |
| `post-update` | Cerca del final de `omarchy update`, después de los paquetes, las migraciones y los reinicios de servicios, antes de que se actualicen las herramientas de mise |
| `pre-refresh-pacman` | Después de que `omarchy refresh pacman` vuelve a sincronizar la configuración de paquetes, antes de que actualice los paquetes; un cambio de canal lo ejecuta durante ese mismo paso de actualización |
| `theme-set` | Después de un cambio de tema (nombre del tema en `$1`) |
| `font-set` | Después de un cambio de fuente (nombre de la fuente en `$1`) |
| `battery-low` | Cuando la batería está baja (porcentaje en `$1`) |

El hook `pre-refresh-pacman` es donde pertenecen los repositorios personalizados o las líneas `IgnorePkg`, ya que se ejecuta antes de la transacción de paquetes. Ambos hooks relacionados con la actualización se ejecutan como tu usuario después de que Omarchy borra su autorización de sudo en caché, así que un hook que use `sudo` necesita su propia autorización y puede pedirte tu contraseña.

Cada uno de esos directorios ya contiene un archivo `.sample` que muestra la forma de un hook — quita el `.sample` del nombre para ponerlo a trabajar. Para instalar un script que escribiste en otro lugar, usa `omarchy hook install post-boot ~/my-hook`, que lo copia ahí y lo hace ejecutable.

### Agregar tus propias entradas al menú

El menú de Omarchy (`Super + Space`) se puede extender con tus propias filas editando `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Las entradas se identifican con un id con puntos, y el id es lo que las coloca en el árbol, así que `personal` aparece en el menú raíz y `personal.notes` aparece dentro de él:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Reutiliza un id existente y sobrescribirás esa fila en lugar de agregar una nueva. El archivo viene con todos los campos disponibles documentados como comentarios.

### Agregar tus propios exports, funciones y alias de shell

Omarchy viene con un montón de alias ergonómicos y funciones útiles, pero es muy común querer agregar los tuyos. Deberías agregar tanto alias como funciones y exports en `~/.bashrc`. Este archivo no se sobrescribirá con las actualizaciones. Si quieres cambiar cualquiera de los valores por defecto de Omarchy, también puedes agregarlos aquí de forma segura.

### Cambiar los archivos internos de Omarchy

Mira, esta es tu computadora. Puedes hacer lo que quieras con ella, pero te aconsejaría no hacer cambios directamente en los archivos de `/usr/share/omarchy`. Pertenecen al paquete pacman de Omarchy, así que tus cambios simplemente se sobrescribirán en la próxima actualización. Te conviene más simplemente sobrescribir cualquier valor por defecto que no te guste en la carpeta `~/.config/*` en su lugar.

Puedes cambiar prácticamente todo de esa manera, como los atajos de teclado por defecto. Solo edita `~/.config/hypr/bindings.lua` para, por ejemplo, reemplazar [Obsidian](https://obsidian.md/) con [Joplin](https://joplinapp.org/) (instálalo con `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` elimina el atajo existente antes de agregar su reemplazo. Acepta los mismos argumentos que `o.bind`, incluidos los helpers de lanzamiento y las opciones de atajo. Usa `o.bind` para agregar un atajo, o `hl.unbind` para eliminar uno sin reemplazarlo.

Si insistes en meterle mano a los archivos internos de Omarchy, cámbiate al canal dev vía _Update > Channel > Dev_. Eso vincula Omarchy a un checkout de git del código fuente en `~/omarchy`, que puedes cambiar a tu antojo. ¡Aquí nadie te va a decir qué hacer!

### Restablecer cualquier cambio

Si terminas haciendo un desastre con las configuraciones, siempre puedes revertirlas a los valores por defecto vía _Update > Config_ en el menú de Omarchy. O ejecutando `omarchy reinstall configs` para restablecer todo.
