# Igranje iger

Omarchy ni samo za _pRoDUkTiVnOsT_, tudi za zabavo je, in kaj je bolj zabavno od igranja iger? Omarchy prinaša cel nabor možnosti za igranje iger — Steam in RetroArch za izvorno in retro igranje, Battle.net, Lutris in Heroic za trgovine, ki niso Steam, Moonlight za pretakanje z PC-ja, Xbox Cloud Gaming + NVIDIA GeForce NOW za oblak, poleg tega pa še vedno zeleni Minecraft.

Zahvaljujoč neverjetnemu delu podjetja Valve na [združljivostni plasti Proton](https://en.wikipedia.org/wiki/Proton_(software)) je zdaj na Linuxu mogoče igrati več deset tisoč sodobnih iger. Aha, in ali ste vedeli, da [Steam Deck](https://store.steampowered.com/steamdeck/) v resnici poganja Arch!

Vsi namestitveni programi za igre so pod _Namesti > Igranje iger_ v meniju Omarchy (`Super + Space`). Če želite katerega od njih kdaj razveljaviti, uporabite _Odstrani > Igranje iger_. Minecraft, NVIDIA GeForce NOW, Battle.net, Lutris in Heroic so na voljo samo na računalnikih x86.

## Steam

Namestite [Steam](https://store.steampowered.com/) tako, da v meniju Omarchy (`Super + Space`) izberete _Namesti > Igranje iger > Steam_.

Ko ga namestite, boste Steam lahko zagnali s `Super + Space`.

Upoštevajte, da lahko zagon Steama traja 10-20 sekund in da ne bo nobenega vizualnega odziva, da se nalaga.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Namestite [RetroArch](https://www.retroarch.com/) tako, da v meniju Omarchy (`Super + Space`) izberete _Namesti > Igranje iger > RetroArch_. Priložen je celoten nabor jeder libretro, tako da so pokriti vsi klasični sistemi.

RetroArch je v celoti vnaprej konfiguriran s čudovitim senčilnikom CRT Royale za popoln retro videz.

Za začetek:

1. Datoteke BIOS odložite v `~/Games/bios`, ROM-e pa v `~/Games/roms`.
2. Zaženite RetroArch s `Super + Space` in vtipkajte `retro`.
3. Preglejte imenik `~/Games/roms` in pripravljeni ste na igranje.

Najljubši igri lahko daste tudi lasten vnos v zaganjalniku aplikacij z _Namesti > Igranje iger > Zaganjalnik iger RetroArch_, ki vam omogoča, da izberete jedro in ROM ter skočite naravnost v igro iz `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Spletno aplikacijo Xbox Cloud Gaming namestite tako, da v meniju Omarchy (`Super + Space`) izberete _Namesti > Igranje iger > Xbox Cloud Gaming_. Je »samo« spletna aplikacija za to storitev, vendar se hitro zažene in odlično deluje pri 1080p.

Če že imate Xbox Game Pass, je to zanesljiv način za igranje Fortnitea in drugih naslovov, ki jih na Linuxu ne morete poganjati izvorno.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Storitev za igranje iger v oblaku [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) namestite tako, da v meniju Omarchy (`Super + Space`) izberete _Namesti > Igranje iger > NVIDIA GeForce NOW_. Še en odličen način za igranje naslovov, ki na Linuxu niso na voljo izvorno.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Minecraft namestite tako, da v meniju Omarchy (`Super + Space`) izberete _Namesti > Igranje iger > Minecraft_.

Tako kot pri Steamu upoštevajte, da lahko po prijavi ali zagonu traja nekaj časa, preden se prikaže naslednji zaslon, in da med čakanjem ne boste dobili nobenega odziva.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Krmilniki Xbox

Podporo za krmilnike Xbox Bluetooth namestite tako, da v meniju Omarchy (`Super + Space`) izberete _Namesti > Igranje iger > Krmilniki Xbox_. Krmilnike seznanite prek Bluetootha (`Super + Ctrl + B`) in delovali bodo v vseh vaših igrah. Tega ne potrebujete, če krmilnik preprosto povežete s kablom USB-C.

## Moonlight (pretakanje iger z PC-ja)

[Odjemalca Moonlight](https://github.com/moonlight-stream/moonlight-qt) namestite tako, da v meniju Omarchy (`Super + Space`) izberete _Namesti > Igranje iger > Moonlight_, in lahko pretakate igre z računalnika Windows, na katerem teče [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Če sta tako vaš računalnik z Omarchy kot oddaljeni igralni PC povezana z žico, se izkušnja ne razlikuje od lokalnega igranja. Ločljivost dvignite na izvorno, osveževanje nastavite na 120Hz in bitno hitrost na največ — to je najboljši način za igranje tekmovalnih streljačin, kot je Fortnite, na Linuxu.

Računalnik z Omarchy lahko spremenite tudi v gostitelja, tako da zaženete `omarchy install service sunshine`, kar namesti Sunshine in odpre vrata za pretakanje Moonlight za vaš LAN in Tailscale.

## Battle.net

[Battle.net](https://eu.shop.battle.net/en-us) namestite tako, da v meniju Omarchy (`Super + Space`) izberete _Namesti > Igranje iger > Battle.net_. To vam prinaša naslove, kot so Diablo, Starcraft in World of Warcraft, kot samostojno namestitev, ki teče pod GE-Proton — brez potrebe po Steamu, Lutrisu ali Heroicu.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (igre za Windows)

[Lutris](https://lutris.net/) namestite tako, da v meniju Omarchy (`Super + Space`) izberete _Namesti > Igranje iger > Lutris_. Lutris je način za igranje iger za Windows iz trgovin, kot sta EA in Ubisoft Connect, ki nimata lastnega namestitvenega programa zgoraj.

Namestitev je nekoliko nerodna in včasih je videti, kot da se nič ne dogaja — le potrpežljivo počakajte, deluje v ozadju.

## Heroic Launcher (Epic Games)

[Heroic Launcher](https://heroicgameslauncher.com/) namestite tako, da v meniju Omarchy (`Super + Space`) izberete _Namesti > Igranje iger > Heroic (Epic Games)_. Heroic vam omogoča poganjanje naslovov Epic Games, kot je OddSparks, ki se ne zanašajo na anticheat — poleg iger iz GOG in Amazon Prime Gaming. Žal to pomeni brez Fortnitea in brez Rocket League — dokler Tim Sweeney ne pride na Linux, se temu ne da priti bližje.

Tako kot Lutris se lahko tudi ta med nameščanjem iger zdi počasen in neroden. Dajte mu čas.
