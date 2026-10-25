# Seguridad

Omarchy se toma la seguridad extremadamente en serio. Esto está pensado para ser un sistema operativo que puedas usar para hacer _Trabajo Real_ en el _Mundo Real_. Donde perder una laptop no puede convertirse en una emergencia de seguridad. Así que esto es lo que hacemos:

1. *El cifrado completo del disco es obligatorio*: Este es el paso más importante para asegurar la protección física de tus datos. Si tu computadora se pierde o te la roban, los datos están completamente cifrados usando LUKS (Linux Unified Key Setup) estándar.
2. *El firewall está activado por defecto*: Todo el tráfico entrante está bloqueado por defecto, excepto el puerto 53317 para [LocalSend](https://localsend.org/). Incluso ssh está desactivado hasta que lo activas mediante _Setup > Security > SSHD_, lo que abre el puerto 22 (con límite de velocidad contra ataques de fuerza bruta) como parte de la configuración. Incluso restringimos el acceso a Docker usando la configuración de [ufw-docker](https://github.com/chaifeng/ufw-docker) para evitar que tus contenedores queden expuestos accidentalmente al mundo.
3. *Arch siempre tiene las actualizaciones más recientes*: Arch, la distribución subyacente sobre la que está construido Omarchy, es una distribución rolling. Esto significa que cualquier vulnerabilidad de seguridad que se descubra y se corrija en cualquier paquete estará disponible rápidamente para su instalación usando `omarchy-update`. De esa manera, siempre estarás ejecutando las versiones más recientes y seguras de todo.
4. *Omarchy mantiene sus propios paquetes y mirror*: Por defecto, Omarchy solo depende de paquetes de los repositorios core/extra/multilib del propio Arch y de su propio Omarchy Package Repository. Puedes instalar software directamente desde AUR, pero la instalación base no lo hace: solo unas pocas instalaciones opcionales, como los navegadores de terceros, obtienen paquetes desde AUR.
5. *Cloudflare nos protege contra DDoS*: La infraestructura de distribución de Omarchy —las ISO, los paquetes de Omarchy y el mirror de Arch— está protegida detrás del formidable escudo contra DDoS de Cloudflare y alojada en su CDN. Esto proporciona una disponibilidad excelente.

## Cambiar tus contraseñas

Tienes dos contraseñas en una instalación cifrada: la que desbloquea la unidad al arrancar y la que usas para iniciar sesión y para `sudo`. La configuración hace que sean la misma. Ambas se pueden cambiar en _Update > Password_ en el menú de Omarchy: _Drive Encryption_ para la primera y _User_ para la segunda. Cambiar la contraseña de la unidad te pide primero la actual, así que tenla a la mano. Si un cambio se interrumpe, ejecuta _Drive Encryption_ de nuevo: te pedirá la contraseña que desbloquea la unidad ahora y terminará el cambio.

## Entregar una máquina que ya usaste

Si vas a entregar tu máquina a otra persona, no tienes que reinstalarla. Ejecuta _Setup > Reset Computer_ en el menú de Omarchy, escribe `reset` para confirmar y reinicia. Eso borra todas las cuentas de usuario y todo lo que hay en `/home`, descarta todos los paquetes y cambios del sistema que hayas hecho desde la instalación y elimina la identidad de la máquina: conexiones de red, claves de host y todo. Lo que vuelve a arrancar es el asistente de configuración del primer inicio, listo para que su nuevo dueño ingrese su propio nombre, contraseña y contraseña de cifrado.

Funciona restaurando la instantánea base que toma el instalador, por lo que solo está disponible en máquinas instaladas desde la ISO de Omarchy. Y en una unidad sin cifrado, un restablecimiento es una eliminación, no un borrado seguro, así que si los datos eran sensibles, haz una instalación limpia en su lugar.

## sudo sin contraseña

A veces quieres que `sudo` deje de pedirte la contraseña, sobre todo cuando un agente de IA está haciendo por ti un tramo largo de trabajo del sistema. _Setup > Security > Passwordless Sudo_ te pregunta durante cuánto tiempo quieres permitir el acceso: **15 minutes**, **1 Hour**, **1 Day** o **Permanently**. Aparece un icono rojo de advertencia junto a los demás indicadores de la barra de menús mientras el acceso está activo. Haz clic en él o ejecuta el comando de nuevo para desactivar el acceso. También puedes indicar tu propio número de minutos (de 1 a 1440) con `omarchy-sudo-passwordless 30`, o usar `omarchy-sudo-passwordless permanent`.

El acceso por tiempo limitado vence automáticamente, incluso inmediatamente después de reanudar desde una suspensión que haya cruzado la fecha límite. Reiniciar la computadora lo termina antes de tiempo. El acceso permanente sobrevive a los reinicios y permanece activado hasta que lo desactivas.

Actualizar o eliminar el paquete de configuración de Omarchy termina cualquier concesión temporal antes de que cambie su compatibilidad con la expiración. Si el comando reporta un error de autorización o de limpieza, resuélvelo antes de intentar activar otra concesión; un error no significa que el acceso sin contraseña esté inactivo.

Tenlo muy claro: mientras está activado, cualquier cosa que se ejecute como tu usuario puede hacer cualquier cosa como root sin que se le pregunte. Ese es todo el punto, y también es todo el riesgo.

## Claves de firma

La clave pública para todas las firmas de las ISO y los paquetes del repositorio de Omarchy es `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verificar en openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). El paquete `omarchy/omarchy-keyring` también la contiene y se utilizará para desplegar sin problemas cualquier posible actualización.

Puedes encontrar la firma de cualquier lanzamiento de ISO agregando .sig a la URL. Por ejemplo, https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
