# Primeros pasos

Omarchy se instala usando una ISO. Puedes elegir entre una instalación de disco completo, que se apodera de todo el disco, o una instalación en espacio libre, que coloca Omarchy en el espacio no asignado de un disco — así es como haces arranque dual junto a Windows u otro sistema operativo (consulta [instalación con arranque dual](50-dual-boot-install.md) — ten en cuenta que primero tendrás que desactivar BitLocker en Windows). De cualquier manera, la instalación usa cifrado completo de forma predeterminada, y la opción de disco completo borrará el disco seleccionado, ¡así que asegúrate de hacer una copia de seguridad antes de usar uno que ya tengas!

[Descarga la ISO de Omarchy](https://omarchy.org/) primero, ponla en una memoria USB (usa [balenaEtcher](https://etcher.balena.io/) en Mac/Windows o [caligula](https://github.com/ifd3f/caligula) en Linux) y arranca desde la memoria.

_Debes desactivar Secure Boot y/o TPM en el BIOS. Tienes que desactivarlos para poder instalar Omarchy. Son esquemas de seguridad de Microsoft pensados para Windows y para distribuciones de Linux afiliadas a Microsoft._

Luego responde las preguntas de configuración y confírmalas así:

 ![install-config](images/install-config.webp)

Luego selecciona un disco para tu instalación, relájate y mira el espectáculo de la instalación. Puede terminar en menos de un minuto en las máquinas modernas más rápidas, pero no debería tardar más de 5 minutos ni siquiera en una computadora más vieja.

 ![install-done](images/install-done.webp)

¡Ya estás listo para usar Omarchy!

### ¡Usa un teclado con cable o de 2.4ghz!

El cifrado completo de disco no te permitirá ingresar la contraseña desde un teclado Bluetooth al arrancar. Igual que no puedes usar un teclado Bluetooth para entrar al BIOS en una PC. Necesitarás un teclado que use un dongle de 2.4ghz o un cable (¡que de todos modos es mucho mejor para la latencia!). ¡A mí en lo personal me encanta el [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instalar para otro dueño

Si estás preparando una máquina para alguien más — un familiar, un empleado nuevo, un comprador — no deberías estar respondiendo las preguntas personales en su nombre. Presiona `Ctrl + C` en la primerísima pantalla del instalador (la de selección de teclado) y Omarchy te ofrecerá preparar la máquina para otro dueño. El sistema se instala de inmediato, pero toda la configuración personal — distribución de teclado, nombre de usuario, contraseña — se pospone hasta que la máquina arranca por primera vez. El disco sigue cifrado de forma predeterminada, y la contraseña que el nuevo dueño elija en ese primer arranque se convierte también en la contraseña de cifrado. (Una máquina que ya hayas estado usando también se puede entregar sin reinstalar — consulta [restablecer la computadora](48-security.md).)

### Instalaciones desatendidas

La ISO también puede instalarse completamente por sí sola — sin teclado, sin asistente — cuando se le entrega su configuración en un segundo disco. Esa es la manera de tratar a Omarchy como una imagen base para VMs y máquinas de una flota. Consulta [instalaciones desatendidas](51-unattended-installs.md).

### Instalaciones sin cifrado

Omarchy se instala con cifrado de forma predeterminada. Es la opción segura y responsable para cualquier computadora que pueda perderse o ser robada. ¡No quieres que cualquiera que tenga acceso a tu hardware pueda obtener tus datos!

Pero en circunstancias especiales, como instalaciones remotas de Omarchy en computadoras protegidas o instalaciones desechables sin datos sensibles, quizá quieras instalar sin cifrado. Puedes presionar `Ctrl + C` en la confirmación de formateo del disco para cambiar a una instalación sin cifrado.

### Idioma

Omarchy habla 50 idiomas — el mismo conjunto que omarchy.org — y el inglés es el predeterminado. Para cambiarlo, abre el menú de Omarchy y ve a _Configuración > Idioma_, o ejecuta `omarchy language <code>` en una terminal (`omarchy language list` muestra los códigos). El menú, el escritorio y las notificaciones propias de Omarchy cambian de idioma de inmediato, y cada aplicación que abras después también. Las apps que ya estaban abiertas cambian una vez que las reinicias.

### Ayuda si te atoras

Si te atoras, normalmente puedes encontrar a alguien dispuesto a ayudar en el canal _#omarchy-help_ en [el Discord de la comunidad](https://omarchy.org/discord).
