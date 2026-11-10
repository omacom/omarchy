# Igranje iger

Omarchy ni samo za _pRoDUcTiVItY_, ampak tudi za zabavo, in kaj je bolj zabavno od igranja iger? Omarchy ima cel nabor možnosti za igranje — Steam in RetroArch za izvorno in retro igranje, Battle.net, Lutris in Heroic za trgovine zunaj Steama, Moonlight za pretakanje z osebnega računalnika, Xbox Cloud Gaming + NVIDIA GeForce NOW za igranje v oblaku, poleg tega pa še večni Minecraft.

Zahvaljujoč neverjetnemu delu podjetja Valve na [združljivostni plasti Proton](https://en.wikipedia.org/wiki/Proton_(software)) je zdaj na Linuxu mogoče igrati več deset tisoč sodobnih iger. Aja, ali ste vedeli, da [Steam Deck](https://store.steampowered.com/steamdeck/) dejansko poganja Arch!

Vsi namestitveni programi za igre so v meniju Omarchy pod _Install > Gaming_ (`Super + Space`). Če želite katerega od njih kdaj odstraniti, uporabite _Remove > Gaming_.

## Steam

Namestite [Steam](https://store.steampowered.com/) tako, da v meniju Omarchy (`Super + Space`) izberete _Install > Gaming > Steam_.

Po namestitvi boste lahko Steam zagnali s `Super + Space`.

Upoštevajte, da zagon Steama lahko traja 10-20 sekund in da med nalaganjem ne bo nobenega vizualnega odziva.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Namestite [RetroArch](https://www.retroarch.com/) tako, da v meniju Omarchy (`Super + Space`) izberete _Install > Gaming > RetroArch_. Prihaja s celotnim naborom jeder libretro, tako da so pokriti vsi klasični sistemi.

RetroArch je v celoti vnaprej nastavljen s čudovitim senčilnikom CRT Royale za popoln retro videz.

Za začetek:

1. Datoteke BIOS odložite v `~/Games/bios`, ROM-e pa v `~/Games/roms`.
2. Zaženite RetroArch s `Super + Space` in vtipkajte `retro`.
3. Preglejte imenik `~/Games/roms` in pripravljeni ste na igranje.

Priljubljeni igri lahko dodate tudi lasten vnos v zaganjalnik aplikacij z _Install > Gaming > RetroArch Game Launcher_, ki vam omogoča, da izberete jedro in ROM ter skočite naravnost v igro iz `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Namestite spletno aplikacijo Xbox Cloud Gaming tako, da v meniju Omarchy (`Super + Space`) izberete _Install > Gaming > Xbox Cloud Gaming_. Je »samo« spletna aplikacija za storitev, vendar se hitro zažene in odlično deluje pri 1080p.

Če že imate Xbox Game Pass, je to dober način za igranje Fortnite in drugih naslovov, ki jih na Linuxu ne morete poganjati izvorno.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Namestite storitev za igranje v oblaku [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) tako, da v meniju Omarchy (`Super + Space`) izberete _Install > Gaming > NVIDIA GeForce NOW_. Še en odličen način za igranje naslovov, ki na Linuxu niso na voljo izvorno.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Namestite Minecraft tako, da v meniju Omarchy (`Super + Space`) izberete _Install > Gaming > Minecraft_.

Podobno kot pri Steamu upoštevajte, da lahko po prijavi ali zagonu traja nekaj časa, preden se prikaže naslednji zaslon, in da med čakanjem ne boste dobili nobenega odziva.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Krmilniki Xbox

Namestite podporo za krmilnike Xbox Bluetooth tako, da v meniju Omarchy (`Super + Space`) izberete _Install > Gaming > Xbox Controllers_. Krmilnike seznanite prek Bluetooth (`Super + Ctrl + B`) in delovali bodo v vseh vaših igrah. Tega ne potrebujete, če krmilnik preprosto povežete s kablom USB-C.

## Moonlight (pretakanje iger z osebnega računalnika)

Namestite [odjemalec Moonlight](https://github.com/moonlight-stream/moonlight-qt) tako, da v meniju Omarchy (`Super + Space`) izberete _Install > Gaming > Moonlight_, in lahko pretakate igre iz osebnega računalnika z Windows, na katerem teče [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Če sta tako vaš računalnik z Omarchy kot oddaljeni igralni računalnik povezana z žico, je izkušnja nerazločljiva od lokalnega igranja. Ločljivost nastavite na izvorno, osveževanje na 120Hz in bitno hitrost na največ — to je najboljši način za igranje tekmovalnih streljačin, kot je Fortnite, na Linuxu.

Računalnik z Omarchy lahko spremenite tudi v gostitelja tako, da zaženete `omarchy install service sunshine`, kar namesti Sunshine in odpre vrata za pretakanje Moonlight za vaše omrežje LAN in Tailscale.

## Battle.net

Namestite [Battle.net](https://eu.shop.battle.net/en-us) tako, da v meniju Omarchy (`Super + Space`) izberete _Install > Gaming > Battle.net_. To vam omogoča naslove, kot so Diablo, Starcraft in World of Warcraft, kot samostojno namestitev, ki teče pod GE-Proton — brez potrebe po Steamu, Lutrisu ali Heroicu.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (igre za Windows)

Namestite [Lutris](https://lutris.net/) tako, da v meniju Omarchy (`Super + Space`) izberete _Install > Gaming > Lutris_. Lutris je način za igranje iger za Windows iz trgovin, kot sta EA in Ubisoft Connect, ki zgoraj nimata lastnega namestitvenega programa.

Namestitev je nekoliko okorna in včasih je videti, kot da se nič ne dogaja — bodite potrpežljivi, deluje v ozadju.

## Heroic Launcher (Epic Games)

Namestite [Heroic Launcher](https://heroicgameslauncher.com/) tako, da v meniju Omarchy (`Super + Space`) izberete _Install > Gaming > Heroic (Epic Games)_. Heroic vam omogoča poganjanje naslovov Epic Games, kot je OddSparks, ki se ne zanašajo na zaščito pred goljufanjem — poleg tega pa še igre iz GOG in Amazon Prime Gaming. Žal to pomeni brez Fortnite in brez Rocket League — dokler Tim Sweeney ne pride na Linux, je to najbližje, kar lahko dobite.

Podobno kot Lutris je lahko med nameščanjem iger počasen in okoren. Dajte mu čas.
