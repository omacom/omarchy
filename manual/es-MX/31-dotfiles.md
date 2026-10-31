# Dotfiles

Omarchy se configura principalmente mediante los llamados dotfiles que viven en `~/.config`. Esos se consideran tus archivos para tus cambios. Los archivos que viven en `/usr/share/omarchy` pertenecen a Omarchy mismo, y no deberías andar metiendo mano en ellos. Si necesitas cambiar algo en `/usr/share/omarchy`, deberías sobrescribir el valor en `~/.config` en su lugar.

Las configuraciones clave se pueden editar directamente desde el menú de Omarchy (`Super + Space`), como _Configurar > Monitores_, _Configurar > Atajos de teclado_, _Configurar > Entrada_ y _Configurar > Config > [archivo]_. Cuando lo haces de esta forma, cualquier proceso que necesite reiniciarse después de editar la configuración lo hará automáticamente después de que salgas del editor (Neovim por defecto —`:wq`, ¡recuerda!—, pero puedes cambiar eso mediante _Setup > Defaults > Editor_).

Esta es una lista de los archivos clave en `~/.config` y lo que controlan:

|| File                  | Purpose              |
|| ----------------------- | --------------------- |
|| `~/.config/hypr/hyprland.lua` | La configuración principal de Hyprland. Carga los valores predeterminados de Omarchy más tus archivos de sobrescritura de abajo. [Más información sobre las configuraciones de Hyprland](https://wiki.hypr.land/Configuring/).  |
|| `~/.config/hypr/bindings.lua` | Tus propios atajos de teclado y sobrescrituras de los predeterminados. |
|| `~/.config/hypr/monitors.lua` | Controla tus monitores, resolución y posición. |
|| `~/.config/hypr/input.lua` | Controla tu distribución de teclado, mouse y ajustes del panel táctil. |
|| `~/.config/hypr/looknfeel.lua` | Controla los espacios, bordes, animaciones y el resto de la apariencia. |
|| `~/.config/hypr/autostart.lua` | Controla los procesos extra que se inician con la sesión. |
|| `~/.config/omarchy/shell.json` | Controla el shell de Omarchy: posición de la barra, distribución y widgets, además de los tiempos del protector de pantalla, el bloqueo y la inactividad. |
|| `~/.config/foot/foot.ini` | Controla tu terminal (foot es la predeterminada). |
|| `~/.XCompose` | Define tus emojis de acceso rápido y el autocompletado de nombre/correo. Asegúrate de ejecutar `omarchy-restart-xcompose` después de hacer cambios. |

Si terminas haciendo muchos cambios para ajustar tu propia configuración, es buena idea respaldar todos estos dotfiles. [Stow es una gran forma de hacerlo](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Iniciar tus propias aplicaciones con la sesión

Si quieres que algo se ejecute cada vez que inicias sesión —un demonio de sincronización, una aplicación de chat, tu propio script—, ponlo en `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Eso inicia el comando como parte de la sesión, así que se limpia adecuadamente cuando cierras sesión de nuevo.

### Ejecutar scripts en eventos del sistema

Omarchy dispara hooks en un puñado de momentos, y puedes colgar tus propios scripts de ellos. Viven en `~/.config/omarchy/hooks/<event>.d/`, un directorio por evento, y cada archivo ejecutable ahí dentro se ejecuta cuando ocurre el evento:

|| Event | When it runs |
|| ----- | ------------ |
|| `post-boot` | Justo después de que el escritorio ha iniciado |
|| `post-update` | Cerca del final de `omarchy update`, después de los paquetes, las migraciones y los reinicios de servicios, antes de que se actualicen las herramientas de mise |
|| `pre-refresh-pacman` | Después de que `omarchy refresh pacman` resincroniza la configuración de paquetes, antes de que actualice los paquetes; un cambio de canal lo ejecuta durante ese mismo paso de actualización |
|| `theme-set` | Después de un cambio de tema (nombre del tema en `$1`) |
|| `font-set` | Después de un cambio de fuente (nombre de la fuente en `$1`) |
|| `battery-low` | Cuando la batería está baja (porcentaje en `$1`) |

El hook `pre-refresh-pacman` es donde pertenecen los repositorios personalizados o las líneas `IgnorePkg`, ya que se ejecuta antes de la transacción de paquetes. Ambos hooks relacionados con actualizaciones se ejecutan como tu usuario después de que Omarchy borra su autorización sudo en caché, así que un hook que use `sudo` necesita su propia autorización y puede pedirte tu contraseña.

Cada uno de esos directorios ya contiene un archivo `.sample` que muestra la forma de un hook: quita el `.sample` del nombre para ponerlo a trabajar. Para instalar un script que hayas escrito en otro lugar, usa `omarchy hook install post-boot ~/my-hook`, lo cual lo copia y lo hace ejecutable.

### Agregar tus propias entradas de menú

El menú de Omarchy (`Super + Space`) se puede ampliar con tus propias filas editando `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Las entradas se identifican por un id con puntos, y el id es lo que las coloca en el árbol, así que `personal` aparece en el menú raíz y `personal.notes` aparece dentro de él:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Reutiliza un id existente y sobrescribirás esa fila en lugar de agregar una nueva. El archivo viene con todos los campos disponibles documentados como comentarios.

### Agregar tus propias exportaciones, funciones y alias de shell

Omarchy viene con un montón de alias ergonómicos y funciones útiles, pero es muy común querer agregar los tuyos. Deberías agregar alias, funciones y exportaciones en `~/.bashrc`. Este archivo no se sobrescribirá en las actualizaciones. Si quieres cambiar alguno de los valores predeterminados de Omarchy, también puedes agregarlos aquí de forma segura.

### Cambiar archivos internos de Omarchy

Mira, esta es tu computadora. Puedes hacer lo que quieras con ella, pero te aconsejo no hacer cambios directamente en los archivos de `/usr/share/omarchy`. Pertenecen al paquete pacman de Omarchy, así que tus cambios simplemente se sobrescribirán en la próxima actualización. Te conviene más simplemente sobrescribir cualquier valor predeterminado que no te guste en la carpeta `~/.config/*` en su lugar.

Puedes cambiar casi todo de esa forma, como los atajos de teclado predeterminados. Solo edita `~/.config/hypr/bindings.lua` para, digamos, reemplazar [Obsidian](https://obsidian.md/) con [Joplin](https://joplinapp.org/) (instálalo con `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` quita el atajo existente antes de agregar su reemplazo. Toma los mismos argumentos que `o.bind`, incluidos los ayudantes de lanzamiento y las opciones de atajo. Usa `o.bind` para agregar un atajo, o `hl.unbind` para quitar uno sin reemplazarlo.

Si insistes en meter mano en los archivos internos de Omarchy, cambia al canal dev mediante _Actualizar > Canal > Dev_. Eso vincula Omarchy a una copia git del código fuente en `~/omarchy`, que eres libre de cambiar a tu antojo. ¡Aquí no hay nadie que te diga qué hacer!

### Restablecer cualquier cambio

Si terminas haciendo un desastre con las configuraciones, siempre puedes revertirlas a los valores predeterminados mediante _Actualizar > Config_ en el menú de Omarchy. O ejecutando `omarchy reinstall configs` para restablecer todo.
