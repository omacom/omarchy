# Redes

Las redes en Omarchy están a cargo de NetworkManager, y las controlas desde el ícono de red en la [barra superior](05-the-top-bar.md) o con `Super + Ctrl + N`.

Ese panel busca redes Wi-Fi, muestra la intensidad de la señal y se conecta. Ethernet no necesita nada en absoluto: conéctalo y funciona. Si prefieres quedarte en la terminal, `nmtui` te da los mismos controles, y también hay un grupo de comandos `omarchy network`.

## Compartir tu Wi-Fi

En lugar de dictar una contraseña larga en voz alta, ejecuta _Setup > Network > QR Code_ mientras estés conectado a Wi-Fi. Eso muestra un código QR en pantalla que cualquier cámara de teléfono puede escanear para unirse. Es una de esas cosas que usarás más de lo que esperas una vez que sabes que está ahí.

Si de plano necesitas la contraseña en sí, `omarchy network password <interface>` la imprime.

## DNS

Omarchy usa el DNS que tu red le entregue por DHCP. Puedes cambiarlo para toda la máquina en _Setup > Network > DNS_, donde Cloudflare y Google están a un clic de distancia. Elige _Custom_ para ingresar tus propios servidores.

Desde la terminal, `omarchy dns` imprime el proveedor actual y `omarchy dns Cloudflare` establece uno.

## Fijar la banda de Wi-Fi

Si tu router pone 2.4GHz, 5GHz y 6GHz con el mismo nombre de red, tu laptop a veces se aferrará a la lenta. `omarchy network band` muestra en qué banda estás, y `omarchy network band 5` la fija. Usa `auto` para que vuelva a elegir por sí sola.

Esto fija la banda y no un punto de acceso específico, así que sigues moviéndote entre APs con normalidad.

## ¿Qué tan rápida es?

_Trigger > Speed Test > Network Speed Test_ mide tu velocidad real de subida y bajada con un par de indicadores. Desde la terminal es `omarchy network speedtest down` o `up`. (Junto a esa opción en ese menú hay una prueba de velocidad de disco, por si quieres medir el otro cuello de botella.)

## El firewall

El firewall está activado por defecto y bloquea todo el tráfico entrante, con una excepción: el puerto 53317, para que [LocalSend](22-guis.md) funcione desde el primer momento.

SSH está desactivado hasta que lo actives con _Setup > Security > SSHD_, que inicia el daemon, abre el puerto 22 con limitación de velocidad contra ataques de fuerza bruta y autoriza una clave. Docker también está restringido, para que los contenedores no puedan exponerse accidentalmente al mundo. Consulta [seguridad](48-security.md) para conocer la historia completa.

## Tailscale

[Tailscale](https://tailscale.com/) es una VPN en malla que hace que acceder a todas tus computadoras y servidores por internet sea simple y seguro. Instálala con _Install > Service > Tailscale_.

Eso te da un panel de Tailscale en la barra, que conecta y desconecta la tailnet, cambia de cuentas y elige un nodo de salida: tanto tus propias máquinas como las regiones de Mullvad aparecen en la lista. También te permite explorar tus máquinas, y ahí es donde vive Taildrop: selecciona una máquina y presiona `s` para enviarle archivos, o `c`, `n` y `d` para copiar su IP, su nombre o su nombre DNS completo. El equivalente en la terminal es `omarchy tailscale send <machine> [file...]`, y los archivos que te envíen llegan automáticamente a `~/Downloads`. La notificación que anuncia una llegada espera hasta que hagas clic para abrirla o la descartes, así que un archivo que llegue mientras no estás frente a la máquina seguirá ahí para que respondas cuando vuelvas.

Instalarla también agrega una aplicación web para la consola de administración de Tailscale.

## Cuando deja de funcionar

Antes de reiniciar, prueba reiniciar solo la pieza que está fallando. _Update > Hardware_ tiene Wi-Fi, Bluetooth, Audio y Trackpad, y recargar una de esas opciones resuelve la mayoría de las situaciones de "funcionaba hace cinco minutos". Consulta [solución de problemas](45-troubleshooting.md).
