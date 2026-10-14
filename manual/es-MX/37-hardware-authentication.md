# Autenticación por hardware

### Autenticación con huella dactilar

Muchas laptops vienen con un sensor de huella dactilar para autenticarte. Puedes usarlo con Omarchy ejecutando _Configuración > Seguridad > Huella dactilar_ en el menú de Omarchy (`Super + Space`).

Eso instalará el paquete de huella dactilar, registrará tu huella, la verificará y quedarás listo para usar tu huella dactilar para desbloquear desde la pantalla de bloqueo (que puedes activar con `Super + Ctrl + L`), entrar en modo sudo y autorizar solicitudes del sistema.

Una vez que la pantalla de bloqueo apaga la pantalla, el sensor reposa para ahorrar energía, así que despierta la pantalla con cualquier tecla o con el touchpad antes de tocarlo.

Cuando la tapa de tu laptop está cerrada, la solicitud de huella dactilar se omite automáticamente, así que vas directo a la solicitud de contraseña en lugar de esperar a un sensor que no puedes alcanzar. Si en otro caso necesitas trabajar con un teclado externo que no tiene sensor, solo presiona `CTRL + C` cuando se te pida tu huella dactilar durante `sudo`.

Puedes eliminar la autenticación con huella dactilar en _Eliminar > Seguridad > Huella dactilar_ en el menú de Omarchy.

### Autenticación con Fido2

Si usas un dispositivo Fido2, puedes configurarlo para la autenticación de `sudo` usando _Configuración > Seguridad > Fido2_ en el menú de Omarchy (`Super + Space`). Sin embargo, cubre `sudo` y las solicitudes de autorización del sistema, no el desbloqueo de tu computadora.

Puedes eliminar la autenticación con fido2 en _Eliminar > Seguridad > Fido2_ en el menú de Omarchy.
