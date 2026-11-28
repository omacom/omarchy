# Redes

Las redes en Omarchy las gestiona NetworkManager, y las controlas desde el icono de red en la [barra superior](05-the-top-bar.md) o con `Super + Ctrl + N`.

Ese panel busca redes Wi-Fi, muestra la intensidad de la señal y se conecta. Ethernet no necesita absolutamente nada: conéctalo y funciona. Si prefieres quedarte en la terminal, `nmtui` te da los mismos controles, y también hay un grupo de comandos `omarchy network`.

## Compartir tu Wi-Fi

En lugar de dictar una contraseña larga en voz alta, ejecuta _Configurar > Red > Código QR_ mientras estés conectado a Wi-Fi. Eso muestra un código QR en pantalla que cualquier cámara de móvil puede escanear para unirse. Es una de esas cosas que usarás más de lo que esperas en cuanto sepas que está ahí.

Si de verdad necesitas la contraseña, `omarchy network password <interface>` la imprime.

## DNS

Omarchy usa el DNS que te proporcione tu red por DHCP. Puedes cambiarlo para toda la máquina en _Configurar > Red > DNS_, donde Cloudflare y Google están a un clic de distancia. Elige _Personalizado_ para escribir tus propios servidores.

Desde la terminal, `omarchy dns` imprime el proveedor actual y `omarchy dns Cloudflare` fija uno.

## Fijar la banda de Wi-Fi

Si tu router pone 2.4GHz, 5GHz y 6GHz con el mismo nombre de red, tu portátil a veces se aferrará a la lenta. `omarchy network band` muestra en qué banda estás, y `omarchy network band 5` la fija. Usa `auto` para que vuelva a elegir por sí misma.

Esto fija la banda en lugar de un punto de acceso específico, así que puedes seguir pasando de un punto de acceso a otro con normalidad.

## ¿Cómo de rápida es?

_Activar > Prueba de velocidad > Prueba de velocidad de red_ mide tu velocidad real de subida y bajada con un par de indicadores. Desde la terminal es `omarchy network speedtest down` o `up`. Mide contra el propio servicio de Omarchy y cuenta solo sus transferencias de prueba. Otras descargas pueden competir por el ancho de banda, pero no se suman al resultado de la prueba de velocidad. (Hay una prueba de velocidad de disco junto a ella en ese menú, por si quieres medir el otro cuello de botella).

## El firewall

El firewall está activado por defecto y bloquea todo el tráfico entrante, con una excepción: el puerto 53317, para que [LocalSend](22-guis.md) funcione desde el primer momento.

SSH está desactivado hasta que lo actives con _Configurar > Seguridad > SSHD_, lo que inicia el daemon, abre el puerto 22 con límite de velocidad contra ataques de fuerza bruta y autoriza una clave. Docker también está restringido, para que los contenedores no puedan exponerse accidentalmente al mundo. Consulta [seguridad](48-security.md) para conocer la historia completa.

## Tailscale

[Tailscale](https://tailscale.com/) es una VPN en malla que permite llegar a todos tus ordenadores y servidores por internet de forma sencilla y segura. Instálala con _Instalar > Servicio > Tailscale_.

Eso te da un panel de Tailscale en la barra, que conecta y desconecta la tailnet, cambia de cuenta y elige un nodo de salida: tanto tus propias máquinas como las regiones de Mullvad aparecen en la lista. También explora tus máquinas, y ahí es donde vive Taildrop: selecciona una máquina y pulsa `s` para enviarle archivos, o `c`, `n` y `d` para copiar su IP, su nombre o su nombre DNS completo. El equivalente en la terminal es `omarchy tailscale send <machine> [file...]`, y los archivos que te envíen llegan a `~/Downloads` automáticamente. La notificación que anuncia una llegada se queda hasta que hagas clic para abrirla o la descartes, así que un archivo que llegue mientras no estás en la máquina seguirá ahí para que respondas cuando regreses.

Al instalarla también se añade una aplicación web para la consola de administración de Tailscale.

## Cuando deja de funcionar

Antes de reiniciar, prueba a reiniciar solo la pieza que falla. _Actualizar > Hardware_ incluye Wi-Fi, Bluetooth, Audio y Trackpad, y recargar uno de esos resuelve la mayoría de las situaciones de "funcionaba hace cinco minutos". Consulta [solución de problemas](45-troubleshooting.md).
