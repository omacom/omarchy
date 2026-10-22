# Instantáneas del sistema

Creamos instantáneas automáticamente en cada actualización de Omarchy, pero si quieres crear las tuyas, puedes usar `omarchy-snapshot create`.

Para arrancar y restaurar una instantánea, la seleccionas desde el cargador de arranque Limine. (Si actualmente arrancas directo a la pantalla de descifrado de Omarchy, primero tendrás que seleccionar Limine como opción de arranque desde el BIOS).

Desde esa pantalla, elige la instantánea en la que quieres arrancar según la fecha y la versión. La versión de Omarchy al momento de la instantánea se puede ver en la esquina inferior izquierda.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Al llegar adentro, aparecerá una notificación avisándote que estás en una instantánea arrancable y, si haces clic en ella, empezará el proceso de restauración. Como alternativa, puedes usar `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Esto restaurará tu sistema de archivos raíz, pero no tu `/home`. Así que sirve para revertir una actualización del sistema rota, pero no para recuperar archivos personales perdidos.

Esto también significa que tu directorio `~/.config` se conserva tal cual. Así que si estás regresando a una versión anterior de una biblioteca o aplicación que guarda archivos de configuración en un formato nuevo, tendrás que resolverlo manualmente.

_Nota: Esta función solo está disponible en instalaciones que usan el cargador de arranque Limine, que ha sido el predeterminado desde Omarchy 2.0. No está disponible si estás en GRUB o systemd-boot._

### Saltarse el menú de arranque

Si nunca tocas el menú de arranque y solo quieres que la computadora vaya directo a la pantalla de descifrado, ejecuta _Configurar > Arranque directo_ en el menú de Omarchy. Eso agrega una entrada EFI que apunta directamente a Omarchy, para que el firmware lo arranque sin detenerse en Limine.

La desventaja es la mencionada al principio: con el arranque directo activado, llegar a una instantánea significa primero elegir Limine desde el menú de arranque de tu BIOS. Ejecuta _Configurar > Arranque directo_ de nuevo para quitar la entrada y volver a arrancar a través de Limine. Algunos firmware no se llevan bien con entradas EFI personalizadas, así que la configuración se niega a ejecutarse en firmware de American Megatrends y Apple.
