# Instalación en arranque dual

Puedes instalar Omarchy en una sola partición junto a Windows u otras instalaciones.

Este método de instalación también trae cifrado LUKS para la partición por defecto, así que en la práctica no hay diferencia con respecto a la unidad completa y simplemente requiere espacio libre disponible en el disco.

## Hacer espacio en Windows

Para instalar junto a Windows, escribe `disk management` en el menú de inicio y selecciona la opción **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Encuentra la partición adecuada, haz clic derecho y elige **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Ingresa la cantidad en que quieres reducir el volumen. Ten en cuenta que este será el tamaño de tu futura instalación de Omarchy, incluida la partición de arranque.

 ![dual-boot-3](images/dual-boot-3.webp)

Cuando termines, deberías ver algo como esto, donde la sección de 50 GB es donde instalaremos Omarchy en este ejemplo.

 ![dual-boot-4](images/dual-boot-4.webp)

## Instalar Omarchy

El proceso de instalación de Omarchy es en la práctica igual al normal. Después de seleccionar tu disco, se te dará la opción **Free space install**. Selecciona esa opción para evitar borrar el disco completo.

 ![dual-boot-5](images/dual-boot-5.webp)

Confirma que todo se vea bien y espera a que termine la instalación como siempre. Aquí también es donde podrías elegir instalar sin cifrado (no recomendado), igual que en una instalación de unidad completa.
 ![dual-boot-6](images/dual-boot-6.webp)

## Agregar otras instalaciones al cargador de arranque

Al terminar tu instalación de Omarchy, notarás que el cargador de arranque Limine es ahora el predeterminado. Con esto, también puedes agregar opciones a Limine para tus otras instalaciones, como Windows.

Para hacerlo, ejecuta `limine-scan` y sigue las instrucciones para agregar lo que quieras a tu configuración de limine. Entonces, al arrancar, verás tus opciones normales de Omarchy, además del Administrador de arranque de Windows y otros.

## Bitlocker

Es importante tener en cuenta que este método de instalación no es compatible con Bitlocker, ya que cifra toda la unidad, no solo la partición. Si te encuentras con un error que indica que Bitlocker está activado, arranca en Windows, entra a **Settings -> Privacy & Security -> Device encryption** y desactiva Bitlocker. Descifrar la unidad puede tardar un rato.

 ![dual-boot-7](images/dual-boot-7.webp)
