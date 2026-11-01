# Videojuegos

Omarchy no es solo para la _pRoDUcTiViDaD_, también es para divertirse, ¿y qué es más divertido que jugar? Omarchy viene con todo un conjunto de opciones para jugar: Steam y RetroArch para juego nativo y retro, Battle.net, Lutris y Heroic para tiendas que no son Steam, Moonlight para streaming desde PC, Xbox Cloud Gaming + NVIDIA GeForce NOW para la nube, además del siempre vigente Minecraft.

Gracias al increíble trabajo de Valve en [la capa de compatibilidad Proton](https://en.wikipedia.org/wiki/Proton_(software)), ahora hay decenas de miles de juegos modernos jugables en Linux. Ah, ¿y sabías que la [Steam Deck](https://store.steampowered.com/steamdeck/) en realidad ejecuta Arch?

Todos los instaladores de videojuegos viven en _Instalar > Videojuegos_ en el menú de Omarchy (`Super + Space`). Si alguna vez quieres deshacer uno, usa _Quitar > Videojuegos_.

## Steam

Instala [Steam](https://store.steampowered.com/) seleccionando _Instalar > Videojuegos > Steam_ desde el menú de Omarchy (`Super + Space`).

Después de instalarlo, podrás lanzar Steam con `Super + Space`.

Ten en cuenta que Steam puede tardar 10-20 segundos en iniciar, y no va a dar ninguna señal visual de que está cargando.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Instala [RetroArch](https://www.retroarch.com/) seleccionando _Instalar > Videojuegos > RetroArch_ desde el menú de Omarchy (`Super + Space`). Viene con el conjunto completo de núcleos libretro, así que todos los sistemas clásicos están cubiertos.

RetroArch viene totalmente preconfigurado con el hermoso shader CRT Royale para ese aspecto retro perfecto.

Para empezar:

1. Pon tus archivos BIOS en `~/Games/bios` y tus ROM en `~/Games/roms`.
2. Lanza RetroArch con `Super + Space` y escribiendo `retro`.
3. Escanea el directorio `~/Games/roms` y estarás listo para jugar.

También puedes darle a un juego favorito su propia entrada en el lanzador de aplicaciones con _Instalar > Videojuegos > RetroArch Game Launcher_, lo cual te permite elegir un núcleo y una ROM, y saltar directo al juego desde `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Instala la aplicación web de Xbox Cloud Gaming seleccionando _Instalar > Videojuegos > Xbox Cloud Gaming_ desde el menú de Omarchy (`Super + Space`). Es «solo» una aplicación web para el servicio, pero inicia rápido y funciona genial a 1080p.

Si ya tienes Xbox Game Pass, esta es una forma sólida de jugar Fortnite y otros títulos que no puedes ejecutar de forma nativa en Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Instala el servicio de videojuegos en la nube [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) seleccionando _Instalar > Videojuegos > NVIDIA GeForce NOW_ desde el menú de Omarchy (`Super + Space`). Otra gran forma de jugar títulos que no están disponibles de forma nativa en Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Instala Minecraft seleccionando _Instalar > Videojuegos > Minecraft_ desde el menú de Omarchy (`Super + Space`).

Como con Steam, ten en cuenta que puede tardar un rato después de iniciar sesión o arrancar para que aparezca la siguiente pantalla, y no vas a recibir ninguna señal mientras esperas.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Controles de Xbox

Instala el soporte para controles Bluetooth de Xbox seleccionando _Instalar > Videojuegos > Xbox Controllers_ desde el menú de Omarchy (`Super + Space`). Empareja los controles vía Bluetooth (`Super + Ctrl + B`) y funcionarán en todos tus juegos. No necesitas esto si simplemente conectas tu control con un cable USB-C.

## Moonlight (streaming de juegos desde una PC)

El [cliente Moonlight](https://github.com/moonlight-stream/moonlight-qt) viene preinstalado con Omarchy, así que puedes transmitir juegos desde una PC con Windows que ejecute [Sunshine](https://app.lizardbyte.dev/Sunshine/) de inmediato. Lanza Moonlight con `Super + Space`.

Si tanto tu computadora con Omarchy como la PC de juegos remota están conectadas por cable, la experiencia es indistinguible de jugar localmente. Sube la resolución a la nativa, pon la frecuencia de actualización a 120Hz y maximiza la tasa de bits: esta es la mejor forma de jugar shooters competitivos como Fortnite en Linux.

También puedes convertir una computadora con Omarchy en el host ejecutando `omarchy install service sunshine`, lo cual instala Sunshine y abre los puertos de streaming de Moonlight para tu LAN y Tailscale.

## Battle.net

Instala [Battle.net](https://eu.shop.battle.net/en-us) seleccionando _Instalar > Videojuegos > Battle.net_ desde el menú de Omarchy (`Super + Space`). Esto te da títulos como Diablo, Starcraft y World of Warcraft como una instalación independiente que se ejecuta bajo GE-Proton: no se necesita Steam, Lutris ni Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (juegos de Windows)

Instala [Lutris](https://lutris.net/) seleccionando _Instalar > Videojuegos > Lutris_ desde el menú de Omarchy (`Super + Space`). Lutris es la forma de jugar juegos de Windows de tiendas como EA y Ubisoft Connect que no tienen su propio instalador arriba.

La instalación es un poco tosca y a veces parece que no pasa nada: solo ten paciencia, está trabajando en segundo plano.

## Heroic Launcher (Epic Games)

Instala el [Heroic Launcher](https://heroicgameslauncher.com/) seleccionando _Instalar > Videojuegos > Heroic (Epic Games)_ desde el menú de Omarchy (`Super + Space`). Heroic te permite ejecutar títulos de Epic Games, como OddSparks, que no dependen de anti-cheat, además de juegos de GOG y Amazon Prime Gaming. Por desgracia, eso significa que no hay Fortnite ni Rocket League: hasta que Tim Sweeney llegue a Linux, esto es lo más cerca que se puede estar.

Como Lutris, puede sentirse lento y tosco al instalar juegos. Dale tiempo.
