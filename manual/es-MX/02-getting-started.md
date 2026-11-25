# Primeros pasos

Omarchy se instala usando una ISO. Puedes elegir entre una instalación en todo el disco, que se apodera de toda la unidad, o una instalación en el espacio libre, que pone a Omarchy en el espacio sin asignar de una unidad — así es como haces arranque dual junto a Windows u otro sistema operativo (consulta [instalación con arranque dual](50-dual-boot-install.md) — ten en cuenta que primero tendrás que desactivar BitLocker en Windows). De cualquier forma, la instalación usa cifrado completo de forma predeterminada, y la opción de todo el disco borrará la unidad seleccionada, ¡así que asegúrate de hacer una copia de seguridad antes de usar una existente!

En una Mac con Apple Silicon, en cambio, instalas desde macOS, sin ISO ni memoria USB. Consulta [Omarchy para Apple Silicon](44-mac-support.md#omarchy-for-apple-silicon).

Primero [descarga la ISO de Omarchy](https://omarchy.org/), ponla en una memoria USB (usa [Rufus](https://rufus.ie/) en Windows, [balenaEtcher](https://etcher.balena.io/) en Mac, o [caligula](https://github.com/ifd3f/caligula) en Linux), y arranca desde la memoria.

_Debes desactivar Secure Boot y/o TPM en el BIOS. Tienes que desactivarlos para poder instalar Omarchy. Son esquemas de seguridad de Microsoft pensados para Windows y distribuciones de Linux afiliadas a Microsoft._

Luego responde las preguntas de configuración y confírmalas así:

 ![install-config](images/install-config.webp)

Luego selecciona una unidad para tu instalación, siéntate y mira el espectáculo de la instalación. Puede terminar en menos de un minuto en las máquinas modernas más rápidas, pero no debería tardar más de 5 minutos ni siquiera en una computadora más vieja.

 ![install-done](images/install-done.webp)

¡Ahora ya estás listo para Omarchy!

### ¡Usa un teclado con cable o de 2.4ghz!

El cifrado completo del disco no te permitirá ingresar la contraseña desde un teclado Bluetooth al arrancar. Igual que no puedes usar un teclado Bluetooth para entrar al BIOS en una PC. Necesitarás un teclado que use un dongle de 2.4ghz o un cable (¡que además es mucho mejor para la latencia!). ¡A mí en lo personal me encanta el [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instalación para otro propietario

Si estás configurando una máquina para alguien más — un familiar, un empleado nuevo, un comprador — no deberías responder las preguntas personales en su lugar. Presiona `Ctrl + C` en la primera pantalla del instalador (la selección de teclado), y Omarchy ofrecerá preparar la máquina para otro propietario. El sistema se instala de inmediato, pero toda la configuración personal — distribución del teclado, nombre de usuario, contraseña — se pospone hasta que la máquina arranca por primera vez. La unidad sigue cifrada de forma predeterminada, y la contraseña que el nuevo propietario elija en ese primer arranque también se convierte en la contraseña de cifrado. (Una máquina que ya has estado usando también se puede entregar sin reinstalar — consulta [restablecer la computadora](48-security.md).)

### Instalaciones desatendidas

La ISO también puede instalarse completamente sola — sin teclado, sin asistente — cuando se le entrega su configuración en una segunda unidad. Esa es la forma de tratar a Omarchy como una imagen base para VM y máquinas de una flota. Consulta [instalaciones desatendidas](51-unattended-installs.md).

### Instalaciones sin cifrado

Omarchy se instala con cifrado de forma predeterminada. Es la opción segura y responsable para cualquier computadora que pueda perderse o ser robada. ¡No quieres que cualquiera con acceso a tu hardware pueda obtener tus datos!

Pero en circunstancias especiales, como instalaciones remotas de Omarchy en computadoras protegidas o para instalaciones desechables sin datos sensibles, quizá quieras instalar sin cifrado. Puedes presionar `Ctrl + C` en la confirmación de formateo del disco para cambiar a una instalación sin cifrado.

### Idioma

Omarchy habla 50 idiomas — el mismo conjunto que omarchy.org — y el inglés es el predeterminado. Para cambiarlo, abre el menú de Omarchy y ve a _Setup > Region > Language_, o ejecuta `omarchy language <code>` en una terminal (`omarchy language list` muestra los códigos). El menú, el escritorio y las notificaciones propias de Omarchy cambian de idioma de inmediato, y también lo hace cada aplicación que abras después. Las aplicaciones que ya estaban abiertas cambian una vez que las reinicias.

Para mantener el idioma pero escribir las fechas, las horas, los números, el dinero, las unidades y los tamaños de papel como lo hace otra región (inglés con fechas europeas y un reloj de 24 horas, por ejemplo), elige una región en _Setup > Region > Formats_, donde cada opción muestra un ejemplo, o ejecuta `omarchy region formats <code>` (`omarchy region formats list` muestra los códigos). _Same as language_ vuelve a los formatos propios del idioma. Al igual que un cambio de idioma, llega a las aplicaciones que abras después.

### Ayuda si te atascas

Si te atascas, normalmente puedes encontrar a alguien dispuesto a ayudar en el canal _#omarchy-help_ en [el Discord de la comunidad](https://omarchy.org/discord).
