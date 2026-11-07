# Primeros pasos

Omarchy se instala usando una ISO. Puedes elegir entre una instalación en todo el disco, que se apodera de toda la unidad, o una instalación en espacio libre, que pone Omarchy en el espacio sin asignar de una unidad — así haces arranque dual junto a Windows u otro sistema operativo (consulta [instalación en arranque dual](50-dual-boot-install.md) — ten en cuenta que primero tendrás que desactivar BitLocker en Windows). De cualquier forma, la instalación usa cifrado completo de forma predeterminada, y la opción de todo el disco borrará la unidad seleccionada, ¡así que asegúrate de hacer una copia de seguridad antes de usar una existente!

Primero [descarga la ISO de Omarchy](https://omarchy.org/), ponla en una memoria USB (usa [Rufus](https://rufus.ie/) en Windows, [balenaEtcher](https://etcher.balena.io/) en Mac, o [caligula](https://github.com/ifd3f/caligula) en Linux), y arranca desde la memoria.

_Debes desactivar Secure Boot y/o TPM en el BIOS. Tienes que desactivarlos para poder instalar Omarchy. Son esquemas de seguridad de Microsoft pensados para Windows y distribuciones de Linux afiliadas a Microsoft._

Luego responde las preguntas de configuración, y confírmalas así:

 ![install-config](images/install-config.webp)

Luego selecciona una unidad para tu instalación, y relájate a ver el espectáculo de la instalación. Puede terminar en menos de un minuto en las máquinas modernas más rápidas, pero no debería tardar más de 5 minutos ni en una computadora más vieja.

 ![install-done](images/install-done.webp)

¡Ahora estás listo para Omarchy!

### ¡Usa un teclado con cable o de 2.4ghz!

El cifrado completo del disco no te permitirá ingresar la contraseña desde un teclado Bluetooth al arrancar. Igual que no puedes usar un teclado Bluetooth para entrar al BIOS en una PC. Necesitarás un teclado que use un dongle de 2.4ghz o un cable (¡que además es mucho mejor para la latencia!). ¡A mí personalmente me encanta el [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instalar para otro propietario

Si estás configurando una máquina para alguien más — un familiar, un empleado nuevo, un comprador — no deberías responder las preguntas personales en su lugar. Presiona `Ctrl + C` en la primera pantalla del instalador (la de selección de teclado), y Omarchy te ofrecerá preparar la máquina para otro propietario. El sistema se instala de inmediato, pero toda la configuración personal — distribución del teclado, nombre de usuario, contraseña — se pospone hasta que la máquina arranca por primera vez. La unidad sigue cifrada de forma predeterminada, y la contraseña que el nuevo propietario elija en ese primer arranque también se convierte en la contraseña de cifrado. (Una máquina que ya has estado usando también puede entregarse sin reinstalar — consulta [restablecer la computadora](48-security.md).)

### Instalaciones desatendidas

La ISO también puede instalarse completamente sola — sin teclado, sin asistente — cuando se le entrega su configuración en una segunda unidad. Esa es la manera de tratar a Omarchy como una imagen base para VMs y máquinas de flota. Consulta [instalaciones desatendidas](51-unattended-installs.md).

### Instalaciones sin cifrado

Omarchy se instala con cifrado de forma predeterminada. Es la opción segura y responsable para cualquier computadora que pueda perderse o ser robada. ¡No quieres que cualquiera con acceso a tu hardware pueda obtener tus datos!

Pero en circunstancias especiales, como instalaciones remotas de Omarchy en computadoras protegidas o instalaciones desechables sin datos sensibles, quizá quieras instalar sin cifrado. Puedes presionar `Ctrl + C` en la confirmación de formateo del disco para cambiar a una instalación sin cifrado.

### Idioma

Omarchy habla 50 idiomas — el mismo conjunto que omarchy.org — y el inglés es el predeterminado. Para cambiarlo, abre el menú de Omarchy y ve a _Configuración > Idioma_, o ejecuta `omarchy language <code>` en una terminal (`omarchy language list` muestra los códigos). El menú, el escritorio y las notificaciones propias de Omarchy cambian de idioma de inmediato, y cada aplicación que abras después también. Las apps que ya estaban abiertas cambian cuando las reinicias.

### Ayuda si te atoras

Si te atoras, normalmente puedes encontrar a alguien dispuesto a ayudar en el canal _#omarchy-help_ en [el Discord de la comunidad](https://omarchy.org/discord).
