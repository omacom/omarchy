# Instantáneas del sistema

Creamos instantáneas automáticamente en cada actualización de Omarchy, pero si quieres crear una propia, puedes usar `omarchy-snapshot create`.

La forma de arrancar y restaurar una instantánea depende del cargador de arranque con el que arranca tu equipo. Las instalaciones UEFI nuevas usan systemd-boot; las instalaciones anteriores y los equipos con BIOS usan Limine. `omarchy-boot-backend` te indica cuál tienes.

## Con systemd-boot

Selecciona _System > Snapshots_ en el menú de Omarchy y elige la instantánea que quieres arrancar. El equipo se reinicia en ella una sola vez. O mantén presionada Space mientras el equipo arranca para ver el menú de arranque, donde todas las instantáneas aparecen ordenadas de la más reciente a la más antigua, con su versión de Omarchy y su fecha.

Una instantánea arranca con una capa temporal encima, así que puedes usarla como siempre, pero cualquier cambio que hagas desaparecerá en el siguiente reinicio. Para conservarla, conviértela en tu sistema: haz clic en la notificación que aparece al iniciar sesión, selecciona _System > Snapshots > Restore This Snapshot_ o ejecuta `omarchy-snapshot restore`. La restauración se realiza mientras el equipo se reinicia. El sistema tal como estaba antes se queda en el menú de arranque como _Before restore_, y `omarchy-snapshot restore backup` lo vuelve a poner.

Desde la terminal:

- `omarchy-snapshot list` enumera las instantáneas que puedes arrancar;
- `omarchy-snapshot boot 12` se reinicia en la instantánea 12 una sola vez;
- `omarchy-snapshot restore 12` convierte la instantánea 12 en el sistema en el siguiente reinicio, y `omarchy-snapshot restore --cancel` te permite cambiar de opinión antes de ese reinicio.

## Con Limine

Para arrancar y restaurar una instantánea, la seleccionas desde el cargador de arranque Limine. El menú de arranque permanece oculto de forma predeterminada, así que presiona cualquier tecla en cuanto arranque Limine para mostrarlo.

Desde esa pantalla, elige la instantánea que quieres arrancar según la fecha y la versión. La versión de Omarchy en el momento de la instantánea se puede ver en la esquina inferior izquierda.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Cuando entres, aparecerá una notificación que te avisará de que estás en una instantánea arrancable y, si haces clic en ella, iniciará el proceso de restauración. Como alternativa, puedes utilizar `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

## Qué cubre una restauración

Una restauración recupera tu sistema de archivos raíz, pero no tu `/home`. Así que sirve para revertir una actualización del sistema que falló, pero no para recuperar archivos personales perdidos.

Esto también significa que tu directorio `~/.config` se mantiene tal cual. Así que si vuelves a una versión anterior de una biblioteca o aplicación que guarda archivos de configuración en un formato nuevo, tendrás que resolverlo manualmente.

Lo mismo ocurre con el propio registro de Omarchy sobre qué migraciones ya se ejecutaron: vive en tu directorio personal, así que sobrevive a la restauración. Las migraciones que se ejecutaron después de que se tomó la instantánea se quedan marcadas como hechas, aunque los cambios que hicieron en el sistema de archivos raíz se hayan revertido, y la siguiente `omarchy update` no las volverá a ejecutar. Así que si vuelves a actualizar después de una restauración y todavía falta algo que una actualización anterior había configurado, esa es la razón probable.
