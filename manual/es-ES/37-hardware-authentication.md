# Autenticación por hardware

### Autenticación con huella dactilar

Muchos portátiles vienen con un sensor de huella dactilar para autenticarte. Para usarlo con Omarchy, ejecuta _Configurar > Seguridad > Huella dactilar_ en el menú de Omarchy (`Super + Space`).

Eso instalará el paquete de huella dactilar, registrará tu huella, la verificará y te dejará listo para usarla al desbloquear desde la pantalla de bloqueo (que puedes activar con `Super + Ctrl + L`), entrar en modo sudo y autorizar solicitudes del sistema.

Una vez que la pantalla de bloqueo apaga la pantalla, el sensor entra en reposo para ahorrar energía, así que despierta la pantalla con cualquier tecla o con el touchpad antes de tocarlo.

Cuando la tapa de tu portátil está cerrada, la solicitud de huella dactilar se omite automáticamente, así que vas directo a la solicitud de contraseña en lugar de esperar a un sensor que no puedes alcanzar. Si aun así necesitas trabajar con un teclado externo que no tiene sensor, solo pulsa `CTRL + C` cuando se te pida tu huella dactilar durante `sudo`.

Puedes eliminar la autenticación con huella dactilar en _Quitar > Seguridad > Huella dactilar_ en el menú de Omarchy.

### Autenticación con FIDO2

Si usas un dispositivo FIDO2, puedes configurarlo para la autenticación de `sudo` usando _Configurar > Seguridad > Fido2_ en el menú de Omarchy (`Super + Space`). Eso sí, cubre `sudo` y las solicitudes de autorización del sistema, no el desbloqueo de tu ordenador.

Puedes eliminar la autenticación con FIDO2 en _Quitar > Seguridad > Fido2_ en el menú de Omarchy.
