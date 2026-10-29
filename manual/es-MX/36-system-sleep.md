# Suspensión del sistema

Omarchy activa la suspensión y la hibernación de forma predeterminada, pero si tienes problemas con cualquiera de las dos en tu máquina, puedes desactivarlas.

En las máquinas NVIDIA GB10, como la DGX Spark y la ASUS Ascent GX10, la suspensión y la hibernación están desactivadas, igual que en el DGX OS de NVIDIA, porque todavía no se ha demostrado que el reposo funcione en ese hardware. El interruptor de suspensión y la configuración de hibernación no aplican ahí. Para volver a activar el reposo, elimina `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` con `sudo rm`; entonces la suspensión vuelve al menú y la hibernación puede configurarse como en otras máquinas. Ejecutar `sudo omarchy apply hardware --install-user "$USER"` vuelve a colocar el archivo.

### Perfiles de energía

En una laptop, Omarchy recuerda tu perfil de energía por separado para cuando está conectada y cuando funciona con batería, y cambia entre los dos al conectarla y desconectarla. De fábrica, eso significa rendimiento con AC y equilibrado con batería.

Puedes ver lo que ofrece tu máquina con `omarchy powerprofiles list`, y establecer el que quieras para el estado en el que estás actualmente con `omarchy powerprofiles set autodetect power-saver`. Para establecer el otro estado sin desconectar nada, nómbralo directamente: `omarchy powerprofiles set battery power-saver`. Lo que elijas es lo que tendrás la próxima vez que estés en ese estado.

### Alternar la suspensión

Alternas la suspensión ejecutando `omarchy toggle suspend` desde la terminal. Eso solo muestra/oculta la opción en _Sistema_ (o `Super + Esc`), y así puedes ver si funciona de manera consistente en tu sistema. Si no, puedes ocultarla de nuevo con el mismo comando.

### Alternar la hibernación

Configuras la hibernación ejecutando `omarchy hibernation setup` desde la terminal. La hibernación crea un subvolumen /swap en tu unidad de arranque del tamaño de tu asignación de RAM física, así que asegúrate de tener mucho espacio libre de sobra. En una máquina de 32GB, siempre necesitarás más de 32GB libres para este volumen. La hibernación también requiere el gestor de arranque predeterminado Limine.

Una vez configurada, verás la opción de hibernar en _Sistema_ (o `Super + Esc`), y así puedes ver si funciona de manera consistente en tu sistema. Si no, puedes eliminarla de nuevo ejecutando `omarchy hibernation remove`.
