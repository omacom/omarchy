# Instalación con arranque dual

Puedes instalar Omarchy en una sola partición junto a Windows u otras instalaciones.

Este método de instalación sigue incluyendo cifrado LUKS para la partición de forma predeterminada, así que en la práctica no se diferencia de una instalación en todo el disco y solo requiere que haya espacio libre en él.

## Hacer espacio en Windows

Para instalarlo junto a Windows, escribe `disk management` en el menú Inicio y selecciona la opción **Crear y formatear particiones del disco duro**.

 ![dual-boot-1](images/dual-boot-1.webp)

Encuentra la partición adecuada, haz clic derecho y elige **Reducir volumen**.

![dual-boot-2](images/dual-boot-2.webp)

 Introduce cuánto quieres reducir el volumen. Ten en cuenta que ese será el tamaño de tu futura instalación de Omarchy, incluida la partición de arranque.

 ![dual-boot-3](images/dual-boot-3.webp)

Cuando termines, deberías ver algo como esto; en este ejemplo, Omarchy se instalará en la sección de 50 GB.

 ![dual-boot-4](images/dual-boot-4.webp)

## Instalar Omarchy

El proceso de instalación de Omarchy es básicamente el de siempre. Después de seleccionar tu disco, verás la opción **Instalación en espacio libre**. Selecciona esa opción para evitar borrar todo el disco.

 ![dual-boot-5](images/dual-boot-5.webp)

Confirma que todo se ve bien y espera a que la instalación termine como de costumbre. Aquí también puedes elegir instalar sin cifrado (no recomendado), igual que en una instalación en todo el disco.
 ![dual-boot-6](images/dual-boot-6.webp)

## Añadir otras instalaciones al gestor de arranque

Cuando termines de instalar Omarchy, notarás que ahora el gestor de arranque predeterminado es Limine. Con esto, también puedes añadir a Limine opciones para tus otras instalaciones, como Windows.

Para añadir otros sistemas operativos, ejecuta `limine-scan` y sigue las indicaciones para añadir las entradas que quieras a tu configuración de Limine. El menú de arranque permanece oculto de forma predeterminada e inicia Omarchy después de un segundo. Para elegir Windows u otra entrada, pulsa cualquier tecla en cuanto inicie Limine; cuando aparezca el menú, usa las teclas de dirección para seleccionar una entrada y pulsa Enter. Si Omarchy inicia antes de que pulses una tecla, reinicia e inténtalo de nuevo.

## Bitlocker

Este método de instalación no es compatible con BitLocker, porque este cifra todo el disco y no solo la partición. Si te aparece un error que indica que Bitlocker está activado, arranca en Windows, ve a **Configuración -> Privacidad y seguridad -> Cifrado del dispositivo** y desactiva BitLocker. Puede tardar un tiempo en descifrar el disco.

 ![dual-boot-7](images/dual-boot-7.webp)

## Reinstalar Windows

Si este ordenador venía con Windows, su clave de producto está almacenada en el firmware. Ejecuta `omarchy windows key` para mostrarla y poder activar Windows de nuevo si alguna vez lo reinstalas en esta máquina.
