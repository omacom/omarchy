# Suspensión del sistema

Omarchy activa la suspensión de forma predeterminada, y la hibernación una vez que está configurada, pero si tienes problemas con alguna de las dos en tu máquina, puedes desactivarlas.

En máquinas NVIDIA GB10, como la DGX Spark y la ASUS Ascent GX10, la suspensión y la hibernación están desactivadas, igual que en DGX OS de NVIDIA, porque aún no se ha demostrado que la suspensión funcione en ese hardware. Ahí no aplican la opción para activar/desactivar la suspensión ni la configuración de la hibernación. Para volver a activar la suspensión, elimina `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` con `sudo rm`; la suspensión volverá al menú y la hibernación podrá configurarse como en otras máquinas. Ejecutar `sudo omarchy apply hardware --install-user "$USER"` vuelve a colocar el archivo.

### Perfiles de energía

En una laptop, Omarchy recuerda tu perfil de energía por separado para cuando está conectada y para cuando funciona con batería, y alterna entre ambos al conectarla y desconectarla. De fábrica, eso significa rendimiento conectada y equilibrado con batería.

Puedes ver qué ofrece tu máquina con `omarchy powerprofiles list`, y establecer el que quieras para el estado en el que estás actualmente con `omarchy powerprofiles set autodetect power-saver`. Para establecer el otro estado sin desconectar nada, nómbralo directamente: `omarchy powerprofiles set battery power-saver`. Lo que elijas será lo que obtendrás la próxima vez que estés en ese estado.

### Activar/desactivar la suspensión

Activas o desactivas la suspensión ejecutando `omarchy toggle suspend` desde la terminal. Eso solo muestra/oculta la opción en _Sistema_ (o `Super + Esc`), y así puedes ver si funciona de forma consistente en tu sistema. Si no, puedes ocultarla de nuevo con el mismo comando.

### Activar/desactivar la hibernación

Configuras la hibernación ejecutando `omarchy hibernation setup` desde la terminal (no está disponible en Macs con Apple Silicon). La hibernación crea un subvolumen /swap en tu unidad de arranque del tamaño de tu asignación de RAM física, así que asegúrate de tener mucho espacio de sobra. En una máquina de 32GB, siempre necesitarás más de 32GB libres para este volumen. La hibernación también requiere el gestor de arranque predeterminado Limine.

Una vez configurada, verás la opción de hibernar en _Sistema_ (o `Super + Esc`), y así puedes ver si funciona de forma consistente en tu sistema. Si no, puedes quitarla de nuevo ejecutando `omarchy hibernation remove`.
