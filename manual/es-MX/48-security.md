# Seguridad

Omarchy se toma la seguridad extremadamente en serio. Esto está pensado como un sistema operativo que puedas usar para hacer _Trabajo Real_ en el _Mundo Real_. Donde perder una laptop no pueda convertirse en una emergencia de seguridad. Así que esto es lo que hacemos:

1. *El cifrado de disco completo está activado por defecto*: Este es el paso más importante para asegurar la protección física de tus datos. Si pierdes tu computadora o te la roban, los datos están completamente cifrados usando LUKS estándar (Linux Unified Key Setup). El instalador te permite desactivarlo para máquinas desechables (consulta [Primeros pasos](02-getting-started.md)); una instalación sin cifrado no tiene nada de esta protección, y cualquiera que tenga el disco puede leerlo.
2. *El firewall está activado por defecto*: Todo el tráfico entrante está bloqueado por defecto, con unas cuantas excepciones: el puerto 53317 para [LocalSend](https://localsend.org/); las consultas DNS al propio resolvedor de la computadora en la dirección del puente de Docker (172.17.0.1), aceptadas desde los rangos de direcciones privadas que Docker da a sus contenedores; y DNS multicast (puerto 5353), que permite que las impresoras y otros dispositivos de tu red se encuentren entre sí y también anuncia el nombre de tu computadora ahí. Además de eso, el firewall mantiene los permisos estándar de UFW para ping, obtener una dirección de tu router (DHCP) y descubrimiento UPnP. Incluso ssh está desactivado hasta que lo actives mediante _Setup > Security > SSHD_, que autoriza tu clave SSH, desactiva los inicios de sesión con contraseña y solo entonces abre el puerto 22 (con límite de velocidad contra fuerza bruta). Incluso restringimos el acceso a Docker usando la configuración [ufw-docker](https://github.com/chaifeng/ufw-docker) para evitar que tus contenedores queden expuestos accidentalmente al mundo.
3. *Arch siempre tiene las actualizaciones más recientes*: Arch, la distribución base sobre la que está construido Omarchy, es una distribución rolling. Esto significa que cualquier vulnerabilidad de seguridad que se descubra y se parchee en cualquier paquete está disponible rápidamente para instalar usando `omarchy-update`. De esa manera, siempre estás usando las versiones más recientes y seguras de todo.
4. *Omarchy mantiene sus propios paquetes y mirror*: Por defecto, Omarchy solo depende de paquetes de los propios repositorios core/extra/multilib de Arch (los de Arch Linux ARM en máquinas ARM, además de Asahi ALARM en Apple Silicon) y de su propio Omarchy Package Repository. Puedes instalar software directamente desde AUR, pero la instalación base no lo hace: solo unas cuantas instalaciones opcionales, como los navegadores de terceros, obtienen paquetes desde AUR.
5. *Cloudflare nos protege contra DDoS*: La infraestructura de distribución de Omarchy — las ISO, los paquetes de Omarchy, el mirror de Arch — está protegida detrás del formidable escudo contra DDoS de Cloudflare y alojada en su CDN. Esto proporciona una disponibilidad excelente.

## Cambiar tus contraseñas

En una instalación cifrada tienes dos contraseñas: la que desbloquea el disco al arrancar y la que usas para iniciar sesión y con `sudo`. La configuración inicial hace que sean la misma. _Update > Password_ en el menú de Omarchy cambia ambas a la vez, para que sigan siendo la misma: pide la contraseña actual del disco, luego la nueva, cambia la del disco y después establece tu contraseña de inicio de sesión para que coincida. Sin cifrado de disco, cambia solo tu contraseña de inicio de sesión. Si un cambio se interrumpe, ejecuta _Update > Password_ otra vez: pide la contraseña que desbloquea el disco ahora, termina el cambio y establece tu contraseña de inicio de sesión con esa. Para cambiar la contraseña de otro disco cifrado, ejecuta `omarchy-drive-password` en una terminal.

## Entregar una máquina que ya usaste

Si vas a entregar tu máquina a alguien más, no tienes que reinstalarla. Ejecuta _Remove > Factory Reset_ en el menú de Omarchy, escribe `reset` para confirmar, ingresa tu contraseña de cifrado del disco si te la pide y reinicia. Eso borra todas las cuentas de usuario y todo lo que hay en `/home`, desecha todos los paquetes y cambios del sistema que hiciste desde la instalación y limpia la identidad de la máquina: conexiones de red, claves de host y todo. Lo que vuelve a arrancar es el asistente de configuración del primer inicio, listo para que su nuevo dueño ingrese su propio nombre, contraseña y contraseña de cifrado.

Funciona restaurando la instantánea base que toma el instalador, así que solo está disponible en máquinas instaladas desde la ISO de Omarchy. Y en un disco sin cifrado, un restablecimiento es un borrado en lugar de un borrado seguro, así que si los datos eran sensibles, haz una instalación nueva en su lugar.

## sudo sin contraseña

A veces quieres que `sudo` deje de pedirla, con mayor frecuencia cuando un agente de AI está haciendo un tramo largo de trabajo del sistema por ti. _Setup > Security > Passwordless Sudo_ pregunta cuánto tiempo permitir el acceso: **15 minutos**, **1 hora**, **1 día** o **Permanentemente**. Aparece un icono rojo de advertencia junto a los demás indicadores de la barra de menús mientras el acceso está activo. Haz clic en él o ejecuta el comando otra vez para desactivar el acceso. También puedes pasar tu propio número de minutos (de 1 a 1440) con `omarchy-sudo-passwordless 30`, o usar `omarchy-sudo-passwordless permanent`.

El acceso con tiempo limitado caduca automáticamente, incluso inmediatamente después de reanudar desde una suspensión que cruzó la fecha límite. Reiniciar la computadora lo termina antes. El acceso permanente sobrevive a los reinicios y permanece activado hasta que lo desactives.

Actualizar o eliminar el paquete de configuración de Omarchy termina cualquier concesión temporal antes de que cambie su soporte de caducidad. Si el comando reporta un error de autorización o de limpieza, resuélvelo antes de intentar activar otra concesión; un error no significa que el acceso sin contraseña esté inactivo.

Ten esto muy claro: mientras está activado, cualquier cosa que se ejecute como tu usuario puede hacer cualquier cosa como root sin que le pregunte. Ese es todo el punto, y también es todo el riesgo.

## Claves de firma

La clave pública para todas las firmas de las ISO y el paquete del repositorio de Omarchy es `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifícala en openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). El paquete `omarchy/omarchy-keyring` también la contiene y se usará para distribuir cualquier actualización potencial sin problemas.

Puedes encontrar la firma de cualquier versión de la ISO agregando `.sig` a su URL, como `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
