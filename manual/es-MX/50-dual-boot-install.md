# Instalación con arranque dual

Puedes instalar Omarchy en una sola partición junto a Windows u otras instalaciones.

Este método de instalación sigue incluyendo cifrado LUKS para la partición de forma predeterminada, así que en la práctica no es diferente a usar todo el disco y simplemente requiere que haya espacio libre disponible en el disco.

## Hacer espacio en Windows

Para instalarlo junto a Windows, escribe `disk management` en el menú Inicio y selecciona la opción **Crear y formatear particiones del disco duro**.

 ![dual-boot-1](images/dual-boot-1.webp)

Encuentra la partición adecuada, haz clic derecho y elige **Reducir volumen**.

![dual-boot-2](images/dual-boot-2.webp)

 Escribe la cantidad que quieres reducir del volumen. Ten en cuenta que ese será el tamaño de tu futura instalación de Omarchy, incluida la partición de arranque.

 ![dual-boot-3](images/dual-boot-3.webp)

Cuando termines, deberías ver algo como esto, donde la sección de 50GB es donde instalaremos Omarchy en este ejemplo.

 ![dual-boot-4](images/dual-boot-4.webp)

## Instalar Omarchy

El proceso de instalación de Omarchy es en la práctica el mismo de siempre. Después de seleccionar tu disco, se te dará la opción **Instalación en espacio libre**. Selecciona esa opción para evitar borrar todo el disco.

 ![dual-boot-5](images/dual-boot-5.webp)

Confirma que todo se ve bien y espera a que la instalación termine como de costumbre. Aquí también puedes elegir instalar sin cifrado (no recomendado), igual que en una instalación en todo el disco.
 ![dual-boot-6](images/dual-boot-6.webp)

## Agregar otras instalaciones al gestor de arranque

Cuando termines de instalar Omarchy, notarás que ahora el gestor de arranque predeterminado es Limine. Con esto, también puedes agregar a Limine opciones para tus otras instalaciones, como Windows.

Para agregar otros sistemas operativos, ejecuta `limine-scan` y sigue las indicaciones para agregar las entradas que quieras a tu configuración de Limine. El menú de arranque permanece oculto de forma predeterminada e inicia Omarchy después de un segundo. Para elegir Windows u otra entrada, presiona cualquier tecla en cuanto inicie Limine; cuando aparezca el menú, usa las teclas de flecha para seleccionar una entrada y presiona Enter. Si Omarchy inicia antes de que presiones una tecla, reinicia e inténtalo de nuevo. Si activaste _Setup > Direct Boot_, el firmware omite Limine por completo, así que elige Limine desde el menú de arranque de tu BIOS o ejecuta _Setup > Direct Boot_ de nuevo para eliminar la entrada.

## Bitlocker

Es importante tener en cuenta que este método de instalación no es compatible con Bitlocker, ya que cifra todo el disco, no solo la partición. Si te aparece un error que indica que Bitlocker está activado, arranca en Windows, ve a **Configuración -> Privacidad y seguridad -> Cifrado del dispositivo** y desactiva Bitlocker. Puede tardar un tiempo en descifrar el disco.

 ![dual-boot-7](images/dual-boot-7.webp)
