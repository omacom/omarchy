# Suspensión del sistema

Omarchy activa por defecto la suspensión y la hibernación, pero si tienes problemas con alguna de las dos en tu computadora, puedes desactivarlas.

### Perfiles de energía

En una laptop, Omarchy recuerda tu perfil de energía por separado para cuando está conectada a la corriente y cuando funciona con batería, y cambia entre los dos al conectarla y desconectarla. Desde el inicio eso significa rendimiento con corriente alterna y equilibrado con batería.

Puedes ver qué ofrece tu computadora con `omarchy powerprofiles list`, y establecer el que quieres para el estado en el que estás en ese momento con `omarchy powerprofiles set autodetect power-saver`. Para establecer el otro estado sin desconectar nada, nómbralo directamente: `omarchy powerprofiles set battery power-saver`. Lo que elijas es lo que obtendrás la próxima vez que estés en ese estado.

### Alternar la suspensión

Alternas la suspensión ejecutando `omarchy toggle suspend` desde la terminal. Eso solo muestra u oculta la opción en _Sistema_ (o `Super + Esc`), y luego puedes ver si funciona de manera constante en tu sistema. Si no, puedes ocultarla de nuevo con el mismo comando.

### Alternar la hibernación

Configuras la hibernación ejecutando `omarchy hibernation setup` desde la terminal. La hibernación crea un subvolumen /swap en tu unidad de arranque con el tamaño de tu asignación de RAM física, así que asegúrate de tener espacio de sobra. En una computadora de 32 GB, siempre necesitarás más de 32 GB libres para este volumen. La hibernación también requiere el cargador de arranque Limine por defecto.

Una vez configurada, verás la opción de hibernar en _Sistema_ (o `Super + Esc`), y luego puedes ver si funciona de manera constante en tu sistema. Si no, puedes quitarla de nuevo ejecutando `omarchy hibernation remove`.
