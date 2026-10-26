# Jocs

Omarchy no és només per a la _pRoDUcTiVItAt_, també és per divertir-se, i què hi ha més divertit que jugar? Omarchy ve amb tot un conjunt d'opcions per jugar — Steam i RetroArch per al joc natiu i retro, Battle.net, Lutris i Heroic per a botigues fora de Steam, Moonlight per a la transmissió des de PC, Xbox Cloud Gaming + NVIDIA GeForce NOW per al núvol, a més del perenne Minecraft.

Gràcies a la feina increïble de Valve en [la capa de compatibilitat Proton](https://en.wikipedia.org/wiki/Proton_(software)), ara hi ha desenes de milers de jocs moderns jugables a Linux. Ah, i sabies que la [Steam Deck](https://store.steampowered.com/steamdeck/) en realitat executa Arch!

Tots els instal·ladors de jocs viuen a _Instal·la > Jocs_ al menú d'Omarchy (`Super + Space`). Si mai en vols desfer un, fes servir _Elimina > Jocs_.

## Steam

Instal·la [Steam](https://store.steampowered.com/) seleccionant _Instal·la > Jocs > Steam_ des del menú d'Omarchy (`Super + Space`).

Un cop l'hagis instal·lat, podràs llançar Steam amb `Super + Space`.

Tingues en compte que Steam pot trigar 10-20 segons a engegar-se, i no et donarà cap indici visual que s'està carregant.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Instal·la [RetroArch](https://www.retroarch.com/) seleccionant _Instal·la > Jocs > RetroArch_ des del menú d'Omarchy (`Super + Space`). Ve amb tot el conjunt de nuclis libretro, de manera que tots els sistemes clàssics hi són coberts.

RetroArch ve totalment preconfigurat amb el bonic shader CRT Royale per a aquell aspecte retro perfecte.

Per començar:

1. Deixa els fitxers de BIOS a `~/Games/bios` i les ROM a `~/Games/roms`.
2. Llança RetroArch amb `Super + Space` i escrivint `retro`.
3. Escaneja el directori `~/Games/roms` i ja estàs a punt per jugar.

També pots donar a un joc preferit la seva pròpia entrada al llançador d'aplicacions amb _Instal·la > Jocs > RetroArch Game Launcher_, que et permet triar un nucli i una ROM i saltar directament al joc des de `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Instal·la l'aplicació web de Xbox Cloud Gaming seleccionant _Instal·la > Jocs > Xbox Cloud Gaming_ des del menú d'Omarchy (`Super + Space`). És «només» una aplicació web per al servei, però s'engega ràpid i funciona de meravella a 1080p.

Si ja tens Xbox Game Pass, aquesta és una manera sòlida de jugar a Fortnite i a altres títols que no pots executar de manera nativa a Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Instal·la el servei de jocs al núvol [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) seleccionant _Instal·la > Jocs > NVIDIA GeForce NOW_ des del menú d'Omarchy (`Super + Space`). Una altra manera fantàstica de jugar a títols que no estan disponibles de manera nativa a Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Instal·la Minecraft seleccionant _Instal·la > Jocs > Minecraft_ des del menú d'Omarchy (`Super + Space`).

Com amb Steam, tingues en compte que pot trigar una estona després d'iniciar sessió o d'engegar-se fins que aparegui la pantalla següent, i no rebràs cap indici mentre esperes.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Comandaments de Xbox

Instal·la el suport per als comandaments de Xbox per Bluetooth seleccionant _Instal·la > Jocs > Xbox Controllers_ des del menú d'Omarchy (`Super + Space`). Aparella els comandaments per Bluetooth (`Super + Ctrl + B`) i funcionaran en tots els teus jocs. No ho necessites si simplement connectes el comandament amb un cable USB-C.

## Moonlight (transmissió de jocs des d'un PC)

El [client Moonlight](https://github.com/moonlight-stream/moonlight-qt) ve preinstal·lat amb Omarchy, de manera que pots transmetre jocs des d'un PC amb Windows que executi [Sunshine](https://app.lizardbyte.dev/Sunshine/) immediatament. Llança Moonlight amb `Super + Space`.

Si tant la teva màquina Omarchy com el PC de jocs remot estan connectats per cable, l'experiència és indistingible de jugar en local. Apuja la resolució a la nativa, posa la freqüència d'actualització a 120Hz i puja la taxa de bits al màxim: aquesta és la millor manera de jugar a jocs de trets competitius com Fortnite a Linux.

També pots convertir una màquina Omarchy en l'amfitrió executant `omarchy install service sunshine`, que instal·la Sunshine i obre els ports de transmissió de Moonlight per a la teva LAN i Tailscale.

## Battle.net

Instal·la [Battle.net](https://eu.shop.battle.net/en-us) seleccionant _Instal·la > Jocs > Battle.net_ des del menú d'Omarchy (`Super + Space`). Això et dona títols com Diablo, Starcraft i World of Warcraft com a instal·lació autònoma que s'executa sota GE-Proton — sense necessitar Steam, Lutris ni Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (jocs de Windows)

Instal·la [Lutris](https://lutris.net/) seleccionant _Instal·la > Jocs > Lutris_ des del menú d'Omarchy (`Super + Space`). Lutris és la manera de jugar a jocs de Windows de botigues com EA i Ubisoft Connect que no tenen el seu propi instal·lador a dalt.

La instal·lació és una mica matussera i de vegades sembla que no estigui passant res: tingues paciència, està treballant en segon pla.

## Heroic Launcher (Epic Games)

Instal·la el [Heroic Launcher](https://heroicgameslauncher.com/) seleccionant _Instal·la > Jocs > Heroic (Epic Games)_ des del menú d'Omarchy (`Super + Space`). Heroic et permet executar títols d'Epic Games, com OddSparks, que no depenen d'antitrucs — a més de jocs de GOG i Amazon Prime Gaming. Malauradament, això vol dir que no hi ha Fortnite ni Rocket League — fins que Tim Sweeney vingui a Linux, això és el més a prop que s'hi pot arribar.

Com Lutris, pot semblar lent i matusser mentre instal·la jocs. Dona-li temps.
