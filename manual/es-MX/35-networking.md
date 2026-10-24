# Redes

La red en Omarchy la maneja NetworkManager, y la controlas desde el ícono de red en la [barra superior](05-the-top-bar.md) o con `Super + Ctrl + W`.

Ese panel busca redes Wi-Fi, muestra la intensidad de la señal y se conecta. Ethernet no necesita absolutamente nada: lo conectas y funciona. Si prefieres quedarte en la terminal, `nmtui` te da los mismos controles, y también hay un grupo de comandos `omarchy network`.

## Compartir tu Wi-Fi

En lugar de dictar una contraseña larguísima, ejecuta _Configurar > Red > Código QR_ mientras estás conectado al Wi-Fi. Eso pone en pantalla un código QR que la cámara de cualquier teléfono puede escanear para unirse. Es una de esas cosas que vas a usar más de lo que esperas una vez que sabes que está ahí.

Si en realidad necesitas la contraseña misma, `omarchy network password <interface>` la imprime.

## DNS

Omarchy utiliza el DNS que tu red entrega por DHCP. Puedes cambiarlo para toda la computadora en _Configurar > Red > DNS_, donde Cloudflare y Google están a un clic de distancia. Elige _Personalizado_ para escribir tus propios servidores.

Desde la terminal, `omarchy dns` imprime el proveedor actual y `omarchy dns Cloudflare` establece uno.

## Fijar la banda del Wi-Fi

Si tu rúter pone 2.4 GHz, 5 GHz y 6 GHz en el mismo nombre de red, tu laptop a veces se va a aferrar a la más lenta. `omarchy network band` muestra en qué banda estás, y `omarchy network band 5` la fija. Usa `auto` para dejar que elija de nuevo.

Esto fija la banda en lugar de un punto de acceso específico, así que sigues moviéndote entre puntos de acceso con normalidad.

## ¿Qué tan rápida es?

_Activar > Prueba de velocidad > Prueba de velocidad de red_ mide tu velocidad real de subida y bajada con un par de indicadores. Desde la terminal es `omarchy network speedtest down` o `up`. (En ese mismo menú hay una prueba de velocidad de disco al lado, por si estás midiendo el otro cuello de botella.)

## El firewall

El firewall está activado por defecto y bloquea todo el tráfico entrante, con una excepción: el puerto 53317, para que [LocalSend](22-guis.md) funcione desde el inicio.

SSH está desactivado hasta que lo activas con _Configurar > Seguridad > SSHD_, que inicia el daemon, abre el puerto 22 con límite de velocidad contra ataques de fuerza bruta y autoriza una llave. Docker también está restringido, para que los contenedores no puedan exponerse al mundo por accidente. Consulta [seguridad](48-security.md) para conocer la historia completa.

## Tailscale

[Tailscale](https://tailscale.com/) es una VPN en malla que hace que llegar a todas tus computadoras y servidores por internet sea sencillo y seguro. Instálalo con _Instalar > Servicio > Tailscale_.

Eso te da un panel de Tailscale en la barra, que conecta y desconecta la tailnet, cambia de cuenta y elige un nodo de salida: tus propias computadoras y las regiones de Mullvad aparecen en la lista. También navega por tus computadoras, y ahí es donde vive Taildrop: selecciona una computadora y presiona `s` para enviarle archivos, o `c`, `n` y `d` para copiar su IP, su nombre o su nombre DNS completo. El equivalente en la terminal es `omarchy tailscale send <machine> [file...]`, y los archivos que te envíen llegan automáticamente a `~/Downloads`. La notificación que anuncia una llegada espera hasta que haces clic para abrirla o la descartas, así que un archivo que llegó mientras no estabas frente a la computadora sigue ahí para responderlo cuando regresas.

Al instalarlo también se agrega una app web para la consola de administración de Tailscale.

## Cuando deja de funcionar

Antes de reiniciar, intenta reiniciar por separado la parte que está fallando. _Actualizar > Hardware_ tiene Wi-Fi, Bluetooth, Audio y Panel táctil, y recargar uno de esos resuelve la mayoría de las situaciones de «funcionaba hace cinco minutos». Consulta [solución de problemas](45-troubleshooting.md).
