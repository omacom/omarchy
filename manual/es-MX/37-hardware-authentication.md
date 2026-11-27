# Autenticación por hardware

### Autenticación por huella dactilar

Muchas laptops traen un sensor de huella dactilar para autenticarte. Puedes usarlo con Omarchy ejecutando _Setup > Security > Fingerprint_ en el menú de Omarchy (`Super + Space`).

Eso abre una huella dactilar a pantalla completa que se va llenando conforme tocas el sensor. Por detrás, Omarchy instalará el paquete de huella dactilar, registrará tu huella, la verificará y quedarás listo para usar tu huella para desbloquear desde la pantalla de bloqueo (que puedes activar con `Super + Ctrl + L`), entrar en modo sudo y autorizar avisos del sistema.

Una vez que la pantalla de bloqueo apaga la pantalla, el sensor entra en reposo para ahorrar energía, así que despierta la pantalla con cualquier tecla o con el touchpad antes de tocarlo.

Cuando la tapa de tu laptop está cerrada, el aviso de huella dactilar se omite automáticamente, así que vas directo al aviso de contraseña en lugar de esperar un sensor al que no puedes llegar. Si en otro caso necesitas trabajar con un teclado externo que no tiene sensor, simplemente presiona `CTRL + C` cuando se te pida tu huella dactilar durante `sudo`.

Puedes eliminar la autenticación por huella dactilar en _Remove > Security > Fingerprint_ en el menú de Omarchy.

### Autenticación Fido2

Si usas un dispositivo Fido2, puedes configurarlo para la autenticación de `sudo` usando _Setup > Security > Fido2_ en el menú de Omarchy (`Super + Space`). Sin embargo, cubre `sudo` y los avisos de autorización del sistema, no el desbloqueo de tu computadora.

Puedes eliminar la autenticación fido2 en _Remove > Security > Fido2_ en el menú de Omarchy.
