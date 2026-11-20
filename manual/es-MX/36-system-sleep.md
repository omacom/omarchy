# Suspensión del sistema

Omarchy habilita la suspensión y la hibernación por defecto, pero si tienes problemas con cualquiera de las dos en tu equipo, puedes desactivarlas.

En equipos NVIDIA GB10, como la DGX Spark y la ASUS Ascent GX10, la suspensión y la hibernación están desactivadas, igual que en DGX OS de NVIDIA, porque aún no se ha demostrado que la suspensión funcione en ese hardware. Lo mismo aplica para la ASUS Zenbook A16 (UX3607OA), donde la suspensión aún no pone el chip completamente en reposo y puede quedarse colgada durante la noche. Ahí no aplican ni la opción para activar o desactivar la suspensión ni la configuración de la hibernación. Para volver a activar la suspensión, elimina `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` con `sudo rm`; la suspensión volverá al menú y la hibernación podrá configurarse como en otros equipos. Ejecutar `sudo omarchy apply hardware --install-user "$USER"` restaura el archivo.

### Perfiles de energía

En una laptop, Omarchy recuerda tu perfil de energía por separado para cuando está conectada y para cuando funciona con batería, y cambia entre los dos al conectar y desconectar. De fábrica, eso significa rendimiento con corriente alterna y equilibrado con batería.

Puedes ver qué ofrece tu equipo con `omarchy powerprofiles list`, y establecer el que quieres para el estado en el que estás actualmente con `omarchy powerprofiles set autodetect power-saver`. Para establecer el otro estado sin desconectar nada, nómbralo directamente: `omarchy powerprofiles set battery power-saver`. Lo que elijas es lo que recuperarás la próxima vez que estés en ese estado.

### Activar o desactivar la suspensión

Activas o desactivas la suspensión ejecutando `omarchy toggle suspend` desde la terminal. Eso solo muestra u oculta la opción en _Sistema_ (o `Super + Esc`), y luego puedes ver si funciona de forma consistente en tu sistema. Si no, puedes ocultarla de nuevo con el mismo comando.

### Activar o desactivar la hibernación

Configuras la hibernación ejecutando `omarchy hibernation setup` desde la terminal. La hibernación crea un subvolumen /swap en tu unidad de arranque del tamaño de tu asignación de RAM física, así que asegúrate de tener mucho espacio libre de sobra. En un equipo de 32GB, siempre necesitarás 32GB+ libres para este volumen. La hibernación también requiere el cargador de arranque predeterminado Limine.

Una vez configurada, verás la opción de hibernar en _Sistema_ (o `Super + Esc`), y luego puedes ver si funciona de forma consistente en tu sistema. Si no, puedes quitarla de nuevo ejecutando `omarchy hibernation remove`.
