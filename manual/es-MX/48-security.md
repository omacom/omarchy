# Seguridad

Omarchy se toma la seguridad sumamente en serio. Esto pretende ser un sistema operativo que puedas usar para hacer _Trabajo Real_ en el _Mundo Real_. Donde perder una laptop no pueda llevar a una emergencia de seguridad. Así que esto es lo que hacemos:

1. *El cifrado completo de disco es obligatorio*: Este es el paso más importante para asegurar la protección física de tus datos. Si tu computadora se pierde o te la roban, los datos están totalmente cifrados usando LUKS estándar (Configuración Unificada de Clave de Linux).
2. *El firewall está activado por defecto*: Todo el tráfico entrante está bloqueado por defecto excepto el puerto 53317 para [LocalSend](https://localsend.org/). Incluso ssh está desactivado hasta que lo activas mediante _Configurar > Seguridad > SSHD_, que abre el puerto 22 (con límite de velocidad contra ataques de fuerza bruta) como parte de la configuración. Incluso restringimos el acceso de Docker usando la configuración [ufw-docker](https://github.com/chaifeng/ufw-docker) para evitar que tus contenedores se expongan al mundo por accidente.
3. *Arch siempre tiene las últimas actualizaciones*: Arch, la distribución subyacente sobre la que está construido Omarchy, es una distribución de lanzamiento continuo. Esto significa que cualquier vulnerabilidad de seguridad que se descubra y se parchee en cualquier paquete está disponible rápidamente para instalar usando `omarchy-update`. De esa manera siempre estás ejecutando las versiones más recientes y seguras de todo.
4. *Omarchy mantiene sus propios paquetes y espejo*: Omarchy solo depende por defecto de paquetes de los repositorios core/extra/multilib de Arch y de su propio Repositorio de Paquetes Omarchy. Puedes instalar software directamente desde AUR, pero la instalación base no lo hace: solo unas pocas instalaciones opcionales, como los navegadores de terceros, jalan del AUR.
5. *Cloudflare nos protege de los DDoS*: Toda la infraestructura de distribución de Omarchy —las ISO, los paquetes de Omarchy, el espejo de Arch— está protegida detrás del formidable escudo anti-DDoS de Cloudflare y alojada en su CDN. Esto proporciona una disponibilidad excelente.

## Cambiar tus contraseñas

Tienes dos contraseñas en una instalación cifrada: la que desbloquea la unidad al arrancar y la que usas para iniciar sesión y para `sudo`. La configuración hace que sean la misma. Ambas pueden cambiarse en _Actualizar > Contraseña_ en el menú de Omarchy — _Cifrado de unidad_ para la primera, _Usuario_ para la segunda. Cambiar la contraseña de la unidad pregunta primero por la actual, así que tenla a la mano. Si un cambio se interrumpe, ejecuta _Cifrado de unidad_ de nuevo: pregunta por la contraseña que desbloquea la unidad ahora y termina el cambio.

## Entregar una computadora que ya usaste

Si vas a entregarle tu computadora a alguien más, no tienes que reinstalarla. Ejecuta _Configurar > Restablecer computadora_ en el menú de Omarchy, escribe `reset` para confirmar y reinicia. Eso borra cada cuenta de usuario y todo lo que hay en `/home`, descarta todos los paquetes y cambios del sistema que hiciste desde la instalación y borra la identidad de la computadora: conexiones de red, llaves de host y todo. Lo que vuelve a aparecer es el asistente de configuración del primer arranque, listo para que su nuevo dueño ingrese su propio nombre, contraseña y contraseña de cifrado.

Funciona restaurando la instantánea base que toma el instalador, así que solo está disponible en computadoras instaladas desde la ISO de Omarchy. Y en una unidad sin cifrado, un restablecimiento es una eliminación en lugar de un borrado seguro, así que si los datos eran confidenciales, haz una instalación limpia en su lugar.

## Sudo sin contraseña

A veces quieres que `sudo` deje de preguntar, más a menudo cuando un agente de IA está haciendo un tramo largo de trabajo en el sistema por ti. _Configurar > Seguridad > Sudo sin contraseña_ pregunta por cuánto tiempo permitir el acceso: **15 minutos**, **1 hora**, **1 día** o **Permanentemente**. Un ícono de advertencia rojo aparece junto a los demás indicadores de la barra de menú mientras el acceso está activo. Haz clic en él o ejecuta el comando de nuevo para desactivar el acceso. También puedes pasar tu propio número de minutos (de 1 a 1440) con `omarchy-sudo-passwordless 30`, o usar `omarchy-sudo-passwordless permanent`.

El acceso temporal caduca automáticamente, incluso inmediatamente después de regresar de una suspensión que cruzó la fecha límite. Reiniciar la computadora lo termina antes. El acceso permanente sobrevive a los reinicios y se mantiene activado hasta que lo desactives.

Actualizar o quitar el paquete de ajustes de Omarchy termina cualquier concesión temporal antes de que cambie su soporte de caducidad. Si el comando reporta un error de autorización o de limpieza, resuélvelo antes de intentar activar otra concesión; un error no significa que el acceso sin contraseña esté inactivo.

Ten clara esta parte: mientras está activado, cualquier cosa que se ejecute como tu usuario puede hacer cualquier cosa como root sin que se le pregunte. Ese es todo el punto, y también es todo el riesgo.

## Llaves de firma

La llave pública para todas las firmas de ISO y paquetes del repositorio de Omarchy es `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifica en openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). El paquete `omarchy/omarchy-keyring` también la contiene y se usará para implementar cualquier actualización potencial sin problemas.

Puedes encontrar la firma de cualquier lanzamiento ISO agregando .sig a la URL. Como https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
