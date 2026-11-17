# Jocs

Omarchy no és només per a la _pRoDUcTiViTaT_, també és per divertir-se, i què hi ha de més divertit que jugar? Omarchy inclou tot un conjunt d'opcions de joc — Steam i RetroArch per jugar a jocs nadius i retro, Battle.net, Lutris i Heroic per a botigues alienes a Steam, Moonlight per a la transmissió des del PC, Xbox Cloud Gaming + NVIDIA GeForce NOW per al núvol, a més de l'etern Minecraft.

Gràcies a la increïble feina de Valve amb [la capa de compatibilitat Proton](https://en.wikipedia.org/wiki/Proton_(software)), ara hi ha desenes de milers de jocs moderns jugables a Linux. Ah, i sabies que la [Steam Deck](https://store.steampowered.com/steamdeck/) en realitat funciona amb Arch!

Tots els instal·ladors de jocs es troben a _Instal·la > Jocs_ al menú d'Omarchy (`Super + Space`). Si mai en vols desfer un, fes servir _Elimina > Jocs_.

## Steam

Instal·la [Steam](https://store.steampowered.com/) seleccionant _Instal·la > Jocs > Steam_ al menú d'Omarchy (`Super + Space`).

Un cop l'hagis instal·lat, podràs iniciar Steam amb `Super + Space`.

Tingues en compte que Steam pot trigar 10-20 segons a iniciar-se, i no et donarà cap indicació visual que s'està carregant.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Instal·la [RetroArch](https://www.retroarch.com/) seleccionant _Instal·la > Jocs > RetroArch_ al menú d'Omarchy (`Super + Space`). Ve amb el conjunt complet de nuclis libretro, de manera que tots els sistemes clàssics hi són coberts.

RetroArch ve totalment preconfigurat amb el preciós shader CRT Royale per a aquell aspecte retro perfecte.

Per començar:

1. Deixa els fitxers de BIOS a `~/Games/bios` i les ROM a `~/Games/roms`.
2. Inicia RetroArch amb `Super + Space` i escrivint `retro`.
3. Escaneja el directori `~/Games/roms` i ja estaràs a punt per jugar.

També pots donar a un joc preferit la seva pròpia entrada al llançador d'aplicacions amb _Instal·la > Jocs > RetroArch Game Launcher_, que et permet triar un nucli i una ROM, i saltar directament al joc des de `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Instal·la l'aplicació web Xbox Cloud Gaming seleccionant _Instal·la > Jocs > Xbox Cloud Gaming_ al menú d'Omarchy (`Super + Space`). És "només" una aplicació web per al servei, però s'inicia ràpidament i funciona molt bé a 1080p.

Si ja tens Xbox Game Pass, aquesta és una manera sòlida de jugar a Fortnite i a altres títols que no pots executar nativament a Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Instal·la el servei de joc al núvol [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) seleccionant _Instal·la > Jocs > NVIDIA GeForce NOW_ al menú d'Omarchy (`Super + Space`). Una altra manera fantàstica de jugar a títols que no estan disponibles nativament a Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Instal·la Minecraft seleccionant _Instal·la > Jocs > Minecraft_ al menú d'Omarchy (`Super + Space`).

Com amb Steam, tingues en compte que pot trigar una estona després d'iniciar sessió o d'arrencar perquè aparegui la pantalla següent, i no rebràs cap indicació mentre esperes.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Controladors d'Xbox

Instal·la el suport per a controladors Xbox per Bluetooth seleccionant _Instal·la > Jocs > Controladors d'Xbox_ al menú d'Omarchy (`Super + Space`). Aparella els controladors via Bluetooth (`Super + Ctrl + B`) i funcionaran en tots els teus jocs. No necessites això si simplement connectes el controlador amb un cable USB-C.

## Moonlight (transmissió de jocs des d'un PC)

Instal·la el [client Moonlight](https://github.com/moonlight-stream/moonlight-qt) seleccionant _Instal·la > Jocs > Moonlight_ al menú d'Omarchy (`Super + Space`), i podràs transmetre jocs des d'un PC amb Windows que executi [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Si tant la teva màquina Omarchy com el PC de joc remot estan connectats per cable, l'experiència és indistingible de jugar localment. Augmenta la resolució fins a la nativa, ajusta la freqüència d'actualització a 120Hz i posa la taxa de bits al màxim — aquesta és la millor manera de jugar a shooters competitius com Fortnite a Linux.

També pots convertir una màquina Omarchy en l'amfitrió executant `omarchy install service sunshine`, que instal·la Sunshine i obre els ports de transmissió de Moonlight per a la teva LAN i Tailscale.

## Battle.net

Instal·la [Battle.net](https://eu.shop.battle.net/en-us) seleccionant _Instal·la > Jocs > Battle.net_ al menú d'Omarchy (`Super + Space`). Això et dona títols com Diablo, Starcraft i World of Warcraft com una instal·lació independent que funciona sota GE-Proton — sense necessitat de Steam, Lutris ni Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (jocs de Windows)

Instal·la [Lutris](https://lutris.net/) seleccionant _Instal·la > Jocs > Lutris_ al menú d'Omarchy (`Super + Space`). Lutris és la manera de jugar a jocs de Windows de botigues com EA i Ubisoft Connect que no tenen el seu propi instal·lador més amunt.

La instal·lació és una mica precària i sembla que de vegades no passa res — tingues paciència, està treballant en segon pla.

## Heroic Launcher (Epic Games)

Instal·la el [Heroic Launcher](https://heroicgameslauncher.com/) seleccionant _Instal·la > Jocs > Heroic (Epic Games)_ al menú d'Omarchy (`Super + Space`). Heroic et permet executar títols d'Epic Games, com OddSparks, que no depenen de mecanismes antitrampes — a més de jocs de GOG i Amazon Prime Gaming. Malauradament, això significa que no hi ha Fortnite ni Rocket League — fins que Tim Sweeney no vingui a Linux, això és el més a prop que hi pots ser.

Com Lutris, pot semblar lent i precari mentre instal·la jocs. Dona-li temps.
