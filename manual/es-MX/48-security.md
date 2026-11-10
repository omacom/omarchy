# Seguridad

Omarchy se toma la seguridad extremadamente en serio. Esto está pensado para ser un sistema operativo que puedas usar para hacer _Trabajo Real_ en el _Mundo Real_. Donde perder una laptop no puede convertirse en una emergencia de seguridad. Así que esto es lo que hacemos:

1. *El cifrado completo del disco está activado por defecto*: Este es el paso más importante para asegurar la protección física de tus datos. Si tu computadora se pierde o te la roban, los datos están completamente cifrados usando el estándar LUKS (Linux Unified Key Setup). El instalador te permite desactivarlo para máquinas desechables (consulta [Primeros pasos](02-getting-started.md)); una instalación sin cifrado no tiene nada de esta protección, y cualquiera que tenga el disco en sus manos puede leerlo.
2. *El firewall está activado por defecto*: Todo el tráfico entrante está bloqueado por defecto, con unas pocas excepciones: el puerto 53317 para [LocalSend](https://localsend.org/); las consultas DNS al resolver propio de la computadora en la dirección del puente de Docker (172.17.0.1), aceptadas desde los rangos de direcciones privadas que Docker asigna a sus contenedores; y el DNS multicast (puerto 5353), que permite que las impresoras y otros dispositivos de tu red se encuentren entre sí y también anuncia ahí el nombre de tu computadora. Además de eso, el firewall mantiene los permisos estándar de UFW para ping, obtener una dirección de tu router (DHCP) y el descubrimiento UPnP. Incluso ssh está desactivado hasta que lo activas mediante _Configuración > Seguridad > SSHD_, lo que abre el puerto 22 (con límite de velocidad contra ataques de fuerza bruta) como parte de la configuración. Incluso restringimos el acceso a Docker usando la configuración de [ufw-docker](https://github.com/chaifeng/ufw-docker) para evitar que tus contenedores queden expuestos accidentalmente al mundo.
3. *Arch siempre tiene las actualizaciones más recientes*: Arch, la distro base sobre la que está construido Omarchy, es una distribución rolling. Esto significa que cualquier vulnerabilidad de seguridad que se descubra y se corrija en cualquier paquete está disponible rápidamente para instalarse usando `omarchy-update`. De esa manera, siempre estás ejecutando las versiones más recientes y seguras de todo.
4. *Omarchy mantiene sus propios paquetes y mirror*: Por defecto, Omarchy solo depende de paquetes de los repositorios core/extra/multilib propios de Arch y de su propio Omarchy Package Repository. Puedes instalar software directamente desde AUR, pero la instalación base no lo hace: solo unas pocas instalaciones opcionales, como los navegadores de terceros, obtienen paquetes desde AUR.
5. *Cloudflare nos protege contra DDoS*: La infraestructura de distribución de Omarchy —las ISO, los paquetes de Omarchy, el mirror de Arch— está protegida detrás del formidable escudo contra DDoS de Cloudflare y alojada en su CDN. Esto proporciona una disponibilidad excelente.

## Cambiar tus contraseñas

Tienes dos contraseñas en una instalación cifrada: la que desbloquea el disco al arrancar y la que usas para iniciar sesión y para `sudo`. La configuración hace que ambas sean la misma. Ambas se pueden cambiar en _Actualizar > Contraseña_ en el menú de Omarchy: _Cifrado del disco_ para la primera, _Usuario_ para la segunda. Cambiar la contraseña del disco primero te pide la actual, así que tenla a la mano. Si un cambio se interrumpe, ejecuta _Cifrado del disco_ de nuevo: te pide la contraseña que desbloquea el disco ahora y completa el cambio.

## Entregar una máquina que ya usaste

Si vas a entregar tu máquina a otra persona, no tienes que reinstalarla. Ejecuta _Configuración > Restablecer computadora_ en el menú de Omarchy, escribe `reset` para confirmar y reinicia. Eso borra todas las cuentas de usuario y todo lo que hay en `/home`, elimina todos los paquetes y cambios del sistema que hiciste desde la instalación y borra la identidad de la máquina: conexiones de red, claves del host y todo. Lo que vuelve a arrancar es el asistente de configuración del primer arranque, listo para que su nuevo dueño ingrese su propio nombre, contraseña y contraseña de cifrado.

Funciona restaurando la instantánea base que toma el instalador, por lo que solo está disponible en máquinas instaladas desde la ISO de Omarchy. Y en un disco sin cifrado, un restablecimiento es una eliminación, no un borrado seguro, así que si los datos eran sensibles, haz una instalación limpia en su lugar.

## Sudo sin contraseña

A veces quieres que `sudo` deje de pedir la contraseña, con mayor frecuencia cuando un agente de IA está haciendo un largo tramo de trabajo del sistema por ti. _Configuración > Seguridad > Sudo sin contraseña_ te pregunta cuánto tiempo permitir el acceso: **15 minutos**, **1 hora**, **1 día** o **Permanentemente**. Aparece un ícono de advertencia rojo junto a los otros indicadores de la barra de menú mientras el acceso está activo. Haz clic en él o ejecuta el comando de nuevo para desactivar el acceso. También puedes pasar tu propio número de minutos (de 1 a 1440) con `omarchy-sudo-passwordless 30`, o usar `omarchy-sudo-passwordless permanent`.

El acceso con tiempo limitado expira automáticamente, incluso inmediatamente después de reanudar desde una suspensión que cruzó la fecha límite. Reiniciar la computadora lo termina antes de tiempo. El acceso permanente sobrevive a los reinicios y permanece activado hasta que lo desactivas.

Actualizar o eliminar el paquete de configuración de Omarchy termina cualquier concesión temporal antes de que cambie su soporte de expiración. Si el comando reporta un error de autorización o de limpieza, resuélvelo antes de intentar habilitar otra concesión; un error no significa que el acceso sin contraseña esté inactivo.

Tenlo bien claro: mientras está activado, cualquier cosa que se ejecute como tu usuario puede hacer cualquier cosa como root sin que se le pida permiso. Esa es justamente la idea, y también es justamente el riesgo.

## Claves de firma

La clave pública para todas las firmas de las ISO y el paquete del repositorio de Omarchy es `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verificar en openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). El paquete `omarchy/omarchy-keyring` también la contiene y se usará para desplegar cualquier actualización potencial sin problemas.

Puedes encontrar la firma de cualquier versión de la ISO agregando `.sig` a su URL, como `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
