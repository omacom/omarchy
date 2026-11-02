# Igranje iger

Omarchy ni samo za _pRoDuKtIvNoSt_, namenjen je tudi zabavi, in kaj je bolj zabavnega od igranja iger? Omarchy dobavlja celoten nabor možnosti za igranje — Steam in RetroArch za izvorno in retro igranje, Battle.net, Lutris in Heroic za trgovine zunaj Steama, Moonlight za pretočno predvajanje na PC, Xbox Cloud Gaming + NVIDIA GeForce NOW za oblak ter vedno zeleni Minecraft.

Zahvaljujoč neverjetnemu delu podjetja Valve na [združljivostni plasti proton](https://en.wikipedia.org/wiki/Proton_(software)) je zdaj v Linuxu na deset tisoče sodobnih iger, ki jih je mogoče igrati. Oh, ali ste vedeli, da [Steam Deck](https://store.steampowered.com/steamdeck/) dejansko poganja Arch!

Vsi namestitveni programi za igre živijo pod _Namesti > Igranje_ v meniju Omarchy (`Super + Space`). Če boste kdaj želeli kaj razveljaviti, uporabite _Odstrani > Igranje_.

## Steam

Namestite [Steam](https://store.steampowered.com/), tako da v meniju Omarchy (`Super + Space`) izberete _Namesti > Igranje > Steam_.

Ko ga namestite, boste Steam lahko zagnali s `Super + Space`.

Upoštevajte, da zagon Steama lahko traja 10-20 sekund in ne bo podal nobene vizualne povratne informacije, da se nalaga.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Namestite [RetroArch](https://www.retroarch.com/), tako da v meniju Omarchy (`Super + Space`) izberete _Namesti > Igranje > RetroArch_. Prinaša celoten nabor jeder libretro, tako da so pokriti vsi klasični sistemi.

RetroArch je v celoti vnaprej konfiguriran z lepim senčilom CRT Royale za popoln retro videz.

Za začetek:

1. Datoteke BIOS odložite v `~/Games/bios`, ROM-e pa v `~/Games/roms`.
2. Zaženite RetroArch s `Super + Space` in vpisom `retro`.
3. Preglejte mapo `~/Games/roms` in pripravljeni ste na igranje.

Priljubljeni igri lahko date tudi lasten vnos v zaganjalniku aplikacij z _Namesti > Igranje > RetroArch Game Launcher_, ki omogoča izbiro jedra in ROM-a ter skok naravnost v igro iz `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Namestite spletno aplikacijo Xbox Cloud Gaming, tako da v meniju Omarchy (`Super + Space`) izberete _Namesti > Igranje > Xbox Cloud Gaming_. Gre »samo« za spletno aplikacijo za storitev, vendar se hitro zažene in odlično teče pri 1080p.

Če že imate Xbox Game Pass, je to soliden način za igranje Fortnite in drugih naslovov, ki jih v Linuxu ne morete izvajati izvorno.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Namestite storitev za igranje v oblaku [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/), tako da v meniju Omarchy (`Super + Space`) izberete _Namesti > Igranje > NVIDIA GeForce NOW_. Še en odličen način za igranje naslovov, ki v Linuxu niso izvorno na voljo.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Namestite Minecraft, tako da v meniju Omarchy (`Super + Space`) izberete _Namesti > Igranje > Minecraft_.

Tako kot pri Steamu upoštevajte, da lahko po prijavi ali zagonu mine nekaj časa, preden se prikaže naslednji zaslon, med čakanjem pa ne boste prejeli povratnih informacij.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Krmilniki Xbox

Namestite podporo za krmilnike Xbox prek Bluetootha, tako da v meniju Omarchy (`Super + Space`) izberete _Namesti > Igranje > Xbox Controllers_. Krmilnike združite prek Bluetootha (`Super + Ctrl + B`) in delovali bodo v vseh vaših igrah. Tega ne potrebujete, če krmilnik preprosto povežete s kablom USB-C.

## Moonlight (pretočno predvajanje iger iz PC-ja)

[Odjemalec Moonlight](https://github.com/moonlight-stream/moonlight-qt) je prednameščen z Omarchyjem, tako da lahko takoj pretočno predvajate igre iz PC-ja Windows, ki poganja [Sunshine](https://app.lizardbyte.dev/Sunshine/). Moonlight zaženete prek `Super + Space`.

Če sta vaš računalnik Omarchy in oddaljeni igralni PC povezana s kablom, je izkušnja neločljiva od lokalnega igranja. Ločljivost dvignite na izvorno, osveževanje nastavite na 120 Hz in bitno hitrost potisnite na maksimum — to je najboljši način za igranje tekmovalnih streljank, kot je Fortnite, v Linuxu.

Računalnik Omarchy lahko spremenite tudi v gostitelja, če zaženete `omarchy install service sunshine`, kar namesti Sunshine in odpre vrata za pretočno predvajanje Moonlight za vaše LAN in Tailscale.

## Battle.net

Namestite [Battle.net](https://eu.shop.battle.net/en-us), tako da v meniju Omarchy (`Super + Space`) izberete _Namesti > Igranje > Battle.net_. To vam prinese naslove, kot so Diablo, Starcraft in World of Warcraft, kot samostojno namestitev, ki teče pod GE-Proton — brez Steama, Lutrisa ali Heroica.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (igre Windows)

Namestite [Lutris](https://lutris.net/), tako da v meniju Omarchy (`Super + Space`) izberete _Namesti > Igranje > Lutris_. Lutris je način za igranje iger Windows iz trgovin, kot sta EA in Ubisoft Connect, ki nimata lastnega namestitvenega programa zgoraj.

Namestitev je nekoliko okorna in včasih izgleda, kot da se nič ne dogaja — samo bodite potrpežljivi, v ozadju dela.

## Heroic Launcher (Epic Games)

Namestite [Heroic Launcher](https://heroicgameslauncher.com/), tako da v meniju Omarchy (`Super + Space`) izberete _Namesti > Igranje > Heroic (Epic Games)_. Heroic omogoča izvajanje naslovov Epic Games, kot je OddSparks, ki ne slonijo na zaščiti pred goljufanjem — ter iger iz GOG in Amazon Prime Gaming. Žal to pomeni brez Fortnite in brez Rocket League — dokler Tim Sweeney ne pride v Linux, je to najbližje, kar gre.

Tako kot pri Lutrisu se lahko med nameščanjem iger zdi počasen in okoren. Dajte mu čas.
