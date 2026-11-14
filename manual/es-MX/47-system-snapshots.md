# Instantáneas del sistema

Creamos instantáneas automáticamente en cada actualización de Omarchy, pero si quieres crear la tuya, puedes usar `omarchy-snapshot create`.

Para arrancar y restaurar una instantánea, la seleccionas en el cargador de arranque Limine. (Si actualmente arrancas directamente en la pantalla de descifrado de Omarchy, primero tendrás que seleccionar Limine como opción de arranque desde el BIOS).

Desde esa pantalla, elige la instantánea en la que quieres arrancar según la fecha y la versión. La versión de Omarchy al momento de la instantánea se puede ver en la esquina inferior izquierda.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Cuando llegues adentro, aparecerá una notificación que te avisará que estás en una instantánea arrancable y, si haces clic en ella, iniciará el proceso de restauración. Como alternativa, puedes utilizar `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Esto restaurará tu sistema de archivos raíz, pero no tu `/home`. Así que sirve para revertir una actualización del sistema que salió mal, pero no para recuperar archivos personales perdidos.

Esto también significa que tu directorio `~/.config` se mantiene tal cual. Así que si regresas a una versión anterior de una biblioteca o aplicación que guarda archivos de configuración en un formato nuevo, tendrás que resolverlo manualmente.

Lo mismo pasa con el propio registro de Omarchy de qué migraciones ya se ejecutaron: vive en tu directorio home, así que sobrevive a la restauración. Las migraciones que se ejecutaron después de que se tomó la instantánea se quedan marcadas como hechas, aunque los cambios que hicieron en el sistema de archivos raíz se hayan revertido, y la próxima vez que ejecutes `omarchy update` no las volverá a ejecutar. Así que si actualizas de nuevo después de una restauración y todavía falta algo que una actualización anterior había configurado, esa es la razón más probable.

_Nota: Esta función solo está disponible en instalaciones que usan el cargador de arranque Limine, que ha sido el predeterminado desde Omarchy 2.0. No está disponible si usas GRUB o systemd-boot._

### Omitir el menú de arranque

Si nunca tocas el menú de arranque y solo quieres que la máquina vaya directo a la pantalla de descifrado, ejecuta _Setup > Direct Boot_ en el menú de Omarchy. Eso agrega una entrada EFI que apunta directamente a Omarchy, así que el firmware lo arranca sin detenerse en Limine.

El compromiso es el que se mencionó al principio: con el arranque directo activado, para llegar a una instantánea tienes que elegir primero Limine desde el menú de arranque de tu BIOS. Ejecuta _Setup > Direct Boot_ de nuevo para quitar la entrada y volver a arrancar a través de Limine. Algunos firmwares no se llevan bien con las entradas EFI personalizadas, así que la configuración se niega a ejecutarse en firmware de American Megatrends y Apple.
