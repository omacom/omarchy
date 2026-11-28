# Actualizaciones

Omarchy y tus paquetes se mantienen actualizados mediante _Actualizar > Omarchy_ en el menú de Omarchy (`Super + Space`).

Omarchy en sí se instala como paquetes normales de pacman desde el [Repositorio de paquetes de Omarchy](https://github.com/omacom-io/omarchy-pkgs), así que una actualización instala [la versión más reciente de Omarchy](https://github.com/omacom/omarchy/releases), ejecuta cualquier migración pendiente para sincronizar tu sistema con la versión más reciente y actualiza todos los paquetes del sistema desde el [mirror de Arch de Omarchy](https://github.com/omacom-io/omarchy-mirror) y [AUR](https://aur.archlinux.org/) (si has instalado algún paquete de AUR).

Cuando haya nuevas versiones, aparecerá un icono de una flecha circular a la derecha de tu reloj. Haz clic en él y el proceso de actualización comenzará.

![update-available](images/update-available.webp)

### Cuatro canales

Omarchy se actualiza a través de cuatro canales: stable, RC, edge y dev. Las instalaciones nuevas empiezan en el canal stable, que sigue las [versiones oficiales](https://github.com/omacom/omarchy/releases/), así como el [mirror estable de Arch de Omarchy](https://github.com/omacom-io/omarchy-mirror), que va un mes por detrás del más reciente, para que podamos detectar cualquier incompatibilidad nueva que requiera cambios de configuración antes de que cause problemas a la gente.

Pero si quieres ayudar a detectar esos posibles problemas, puedes usar el canal edge. Eso mantendrá tus paquetes de Omarchy siguiendo las compilaciones de desarrollo más recientes y te permitirá actualizar a los paquetes más recientes de Arch en cuanto estén disponibles. Solo deberías hacer esto si tienes experiencia con Linux y sabes cómo recuperar un sistema que tiene problemas.

Antes de cada nueva versión mayor, haremos la validación final usando el canal RC. Si te interesa ayudar con los últimos retoques, pásate por #omarchy-release-candidates en Discord.

Por último, está el canal dev, que vincula Omarchy directamente a una copia del código fuente obtenida con git en `~/omarchy`, combinada con los paquetes edge. Solo deberías usar este canal si eres un usuario experimentado de Linux, trabajas directamente en Omarchy y estás dispuesto a tolerar que las cosas se rompan.

Puedes cambiar de canal usando _Actualizar > Canal_ desde el menú de Omarchy (o `omarchy channel set <stable|rc|edge|dev>` en el terminal, con `omarchy channel current` para ver en cuál estás).

### Cambiar de kernel

Omarchy arranca con su propio kernel `linux-omarchy`, pero puedes mantener otros instalados junto a él, como el kernel `linux` estándar de Arch o una compilación experimental que estés probando. Cuando haya más de uno, _Actualizar > Kernel_ en el menú de Omarchy los enumera con una marca junto al que arranca por defecto. Elige otro e introduce tu contraseña. El equipo arrancará con el kernel elegido la próxima vez que reinicies. Los demás kernels permanecen en el menú de arranque, así que todavía puedes elegir uno manualmente si el nuevo predeterminado te da problemas. En el terminal, usa `omarchy kernel` para ver el predeterminado actual, `omarchy kernel list` para ver qué está instalado y `omarchy kernel set <kernel>` para cambiar.

### Actualizaciones de firmware

Tus paquetes no son lo único que se queda obsoleto. Muchos portátiles y periféricos distribuyen firmware para BIOS, SSD y docks a través del Linux Vendor Firmware Service, y _Actualizar > Firmware_ en el menú de Omarchy descargará e instalará lo que tu hardware tenga pendiente. La primera vez que lo ejecutes instalará `fwupd`. Mucho firmware solo se puede escribir durante un reinicio, así que no te sorprendas si te pide uno.

Cuando necesites cambiar un ajuste en el propio BIOS, mantén pulsada `Alt` en el menú del sistema (`Super + Escape`) y _Reiniciar_ se convertirá en _Reiniciar en el BIOS_, que reinicia directamente en la configuración del firmware sin tener que pulsar la tecla correcta al arrancar. Desde la terminal, usa `omarchy system firmware`.

### Advertencia sobre actualizar directamente con pacman/yay

Si ya conoces Arch, podrías tener la tentación de ejecutar simplemente `pacman -Syu` o `yay -Syu` por tu cuenta, pero si lo haces, te saltarás la instantánea, las migraciones y las actualizaciones de configuración que Omarchy ejecuta junto con los paquetes nuevos. Por eso Omarchy en realidad detendrá una actualización directa del sistema y te indicará que uses `omarchy update` en su lugar. (Si de verdad sabes lo que estás haciendo, la protección te dirá cómo omitirla para una sola transacción).

### Revertir actualizaciones problemáticas

Si alguna vez tienes un problema después de actualizar, puedes revertir tu sistema a la instantánea tomada antes de la actualización. Solo reinicia y elige en el menú de arranque la instantánea de antes de que empezaras la actualización.

![bootloader](images/bootloader.webp)

Si de algún modo tus archivos de configuración se dañaron, también puedes realizar una reinstalación de Omarchy usando `omarchy reinstall` en la terminal. Esto reinstalará todos los paquetes predeterminados de Omarchy, te pondrá en stable (edge en Apple Silicon) y degradará cualquier paquete que sea demasiado nuevo, y restablecerá todos los archivos de configuración. ¡Ten en cuenta que al hacer esto se sobrescribirán todos los cambios que hayas hecho en tu configuración respecto a los valores predeterminados de Omarchy!
