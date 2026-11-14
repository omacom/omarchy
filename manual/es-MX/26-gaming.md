# Juegos

Omarchy no es solo para la _pRoDUcTiViDaD_, también es para divertirse, ¿y qué es más divertido que jugar? Omarchy incluye toda una suite de opciones para jugar — Steam y RetroArch para juego nativo y retro, Battle.net, Lutris y Heroic para tiendas que no son Steam, Moonlight para streaming desde una PC, Xbox Cloud Gaming + NVIDIA GeForce NOW para la nube, además del eterno Minecraft.

Gracias al increíble trabajo de Valve en [la capa de compatibilidad Proton](https://en.wikipedia.org/wiki/Proton_(software)), ahora hay decenas de miles de juegos modernos jugables en Linux. Ah, ¿y sabías que la [Steam Deck](https://store.steampowered.com/steamdeck/) en realidad corre Arch?

Todos los instaladores de juegos están en _Install > Gaming_ en el menú de Omarchy (`Super + Space`). Si alguna vez quieres deshacer uno, usa _Remove > Gaming_.

## Steam

Instala [Steam](https://store.steampowered.com/) seleccionando _Install > Gaming > Steam_ en el menú de Omarchy (`Super + Space`).

Después de instalarlo, podrás iniciar Steam con `Super + Space`.

Ten en cuenta que Steam puede tardar de 10 a 20 segundos en iniciar y no va a darte ninguna indicación visual de que está cargando.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Instala [RetroArch](https://www.retroarch.com/) seleccionando _Install > Gaming > RetroArch_ en el menú de Omarchy (`Super + Space`). Viene con el conjunto completo de núcleos libretro, así que todos los sistemas clásicos están cubiertos.

RetroArch viene totalmente preconfigurado con el hermoso shader CRT Royale para ese look retro perfecto.

Para empezar:

1. Deja tus archivos BIOS en `~/Games/bios` y tus ROMs en `~/Games/roms`.
2. Inicia RetroArch con `Super + Space` y escribiendo `retro`.
3. Escanea el directorio `~/Games/roms` y ya estás listo para jugar.

También puedes darle a un juego favorito su propia entrada en el lanzador de aplicaciones con _Install > Gaming > RetroArch Game Launcher_, que te permite elegir un núcleo y una ROM, y saltar directo al juego desde `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Instala la web app de Xbox Cloud Gaming seleccionando _Install > Gaming > Xbox Cloud Gaming_ en el menú de Omarchy (`Super + Space`). Es "solo" una web app para el servicio, pero inicia rápido y funciona de maravilla a 1080p.

Si ya tienes Xbox Game Pass, esta es una forma sólida de jugar Fortnite y otros títulos que no puedes correr de forma nativa en Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Instala el servicio de juego en la nube [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) seleccionando _Install > Gaming > NVIDIA GeForce NOW_ en el menú de Omarchy (`Super + Space`). Otra excelente forma de jugar títulos que no están disponibles de forma nativa en Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Instala Minecraft seleccionando _Install > Gaming > Minecraft_ en el menú de Omarchy (`Super + Space`).

Al igual que Steam, ten en cuenta que puede tardar un buen rato después de iniciar sesión o de abrirlo para que aparezca la siguiente pantalla, y no vas a recibir ninguna indicación mientras esperas.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Controles de Xbox

Instala el soporte para controles Bluetooth de Xbox seleccionando _Install > Gaming > Xbox Controllers_ en el menú de Omarchy (`Super + Space`). Empareja los controles vía Bluetooth (`Super + Ctrl + B`) y funcionarán en todos tus juegos. No necesitas esto si solo vas a conectar tu control con cable usando un cable USB-C.

## Moonlight (streaming de juegos desde una PC)

Instala el [cliente Moonlight](https://github.com/moonlight-stream/moonlight-qt) seleccionando _Install > Gaming > Moonlight_ en el menú de Omarchy (`Super + Space`), y podrás transmitir juegos desde una PC con Windows que corra [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Si tanto tu máquina con Omarchy como la PC remota para jugar están conectadas por cable, la experiencia es indistinguible de jugar localmente. Sube la resolución a la nativa, configura la frecuencia de actualización a 120Hz y pon el bitrate al máximo — esta es la mejor forma de jugar shooters competitivos como Fortnite en Linux.

También puedes convertir una máquina con Omarchy en el host ejecutando `omarchy install service sunshine`, que instala Sunshine y abre los puertos de streaming de Moonlight para tu LAN y Tailscale.

## Battle.net

Instala [Battle.net](https://eu.shop.battle.net/en-us) seleccionando _Install > Gaming > Battle.net_ en el menú de Omarchy (`Super + Space`). Esto te da títulos como Diablo, Starcraft y World of Warcraft como una instalación independiente que corre bajo GE-Proton — no necesitas Steam, Lutris ni Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (juegos de Windows)

Instala [Lutris](https://lutris.net/) seleccionando _Install > Gaming > Lutris_ en el menú de Omarchy (`Super + Space`). Lutris es la forma de jugar juegos de Windows de tiendas como EA y Ubisoft Connect que no tienen su propio instalador arriba.

La instalación es medio torpe y a veces parece que no está pasando nada — solo ten paciencia, está trabajando en segundo plano.

## Heroic Launcher (Epic Games)

Instala el [Heroic Launcher](https://heroicgameslauncher.com/) seleccionando _Install > Gaming > Heroic (Epic Games)_ en el menú de Omarchy (`Super + Space`). Heroic te permite correr títulos de Epic Games, como OddSparks, que no dependen del anti-cheat — además de juegos de GOG y Amazon Prime Gaming. Lamentablemente, eso significa que no hay Fortnite ni Rocket League — hasta que Tim Sweeney llegue a Linux, esto es lo más cerca que vas a estar.

Al igual que Lutris, puede sentirse lento y torpe mientras instala juegos. Dale tiempo.
