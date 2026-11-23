# Suspensión del sistema

Omarchy activa la suspensión por defecto, y la hibernación una vez que está configurada, pero si tienes problemas con cualquiera de las dos en tu máquina, puedes desactivarlas.

En las máquinas NVIDIA GB10, como la DGX Spark y la ASUS Ascent GX10, la suspensión y la hibernación están desactivadas, igual que en el DGX OS de NVIDIA, porque todavía no se ha demostrado que el reposo funcione en ese hardware. Lo mismo ocurre con el ASUS Zenbook A16 (UX3607OA), donde la suspensión todavía no duerme del todo el chip y el equipo puede quedarse colgado toda la noche. El interruptor de suspensión y la configuración de hibernación no están disponibles ahí. Para volver a activar el reposo, elimina `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` con `sudo rm`; tras eso, la suspensión vuelve al menú y la hibernación se puede configurar como en otras máquinas. Ejecutar `sudo omarchy apply hardware --install-user "$USER"` vuelve a colocar el archivo.

### Perfiles de energía

En un portátil, Omarchy recuerda tu perfil de energía por separado para cuando está enchufado y cuando funciona con batería, y cambia entre los dos al enchufarlo y desenchufarlo. De fábrica, eso significa rendimiento con AC y equilibrado con batería.

Puedes ver lo que ofrece tu máquina con `omarchy powerprofiles list`, y establecer el que quieras para el estado en el que estás actualmente con `omarchy powerprofiles set autodetect power-saver`. Para establecer el otro estado sin desenchufar nada, nómbralo directamente: `omarchy powerprofiles set battery power-saver`. Lo que elijas es lo que tendrás la próxima vez que estés en ese estado.

### Alternar la suspensión

Para alternar la suspensión, ejecuta `omarchy toggle suspend` desde la terminal. Eso solo muestra/oculta la opción en _Sistema_ (o `Super + Esc`), y así puedes ver si funciona de manera consistente en tu sistema. Si no, puedes ocultarla de nuevo con el mismo comando.

### Alternar la hibernación

Configuras la hibernación ejecutando `omarchy hibernation setup` desde el terminal (no está disponible en Mac con Apple Silicon). La hibernación crea un subvolumen /swap en tu unidad de arranque del tamaño de tu asignación de RAM física, así que asegúrate de tener bastante espacio libre de sobra. En una máquina de 32GB, siempre necesitarás más de 32GB libres para este volumen. La hibernación también requiere el gestor de arranque predeterminado Limine.

Una vez configurada, verás la opción de hibernar en _Sistema_ (o `Super + Esc`), y así puedes ver si funciona de manera consistente en tu sistema. Si no, puedes eliminarla de nuevo ejecutando `omarchy hibernation remove`.
