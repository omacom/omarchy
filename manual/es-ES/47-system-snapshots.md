# Instantáneas del sistema

Creamos instantáneas automáticamente en cada actualización de Omarchy, pero si quieres crear la tuya, puedes usar `omarchy-snapshot create`.

Para arrancar y restaurar una instantánea, la seleccionas desde el cargador de arranque Limine. El menú de arranque permanece oculto por defecto, así que pulsa cualquier tecla en cuanto inicie Limine para mostrarlo.

Desde esa pantalla, elige la instantánea en la que quieres arrancar según la fecha y la versión. La versión de Omarchy que tenía la instantánea aparece en la esquina inferior izquierda.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Cuando entres, aparecerá una notificación que te avisará de que estás en una instantánea arrancable; si haces clic en ella, se iniciará el proceso de restauración. Como alternativa, puedes usar `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Esto restaurará tu sistema de archivos raíz, pero no tu `/home`. Sirve para revertir una actualización del sistema que salió mal, pero no para recuperar archivos personales perdidos.

Esto también significa que tu directorio `~/.config` se mantiene tal cual, así que si vuelves a una versión anterior de una biblioteca o aplicación que guarda archivos de configuración en un formato nuevo, tendrás que resolverlo manualmente.

Lo mismo pasa con el registro que lleva Omarchy de qué migraciones ya se ejecutaron: vive en tu directorio home, así que sobrevive a la restauración. Las migraciones que se ejecutaron después de que se tomó la instantánea se quedan marcadas como hechas, aunque los cambios que hicieron en el sistema de archivos raíz se hayan revertido, y la próxima vez que ejecutes `omarchy update` no las volverá a ejecutar. Si actualizas de nuevo después de una restauración y todavía falta algo que una actualización anterior había configurado, esa es la razón más probable.

_Nota: Esta función solo está disponible en instalaciones que usan el cargador de arranque Limine, que ha sido el predeterminado desde Omarchy 2.0. No está disponible si usas GRUB o systemd-boot._
