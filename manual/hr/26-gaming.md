# Gaming

Omarchy nije samo za _pRoDUkTiVNOST_, već i za zabavu, a što je zabavnije od gaminga? Omarchy dolazi s cijelim paketom opcija za gaming — Steam i RetroArch za nativnu i retro igru, Battle.net, Lutris i Heroic za trgovine izvan Steama, Moonlight za streaming s PC-a, Xbox Cloud Gaming + NVIDIA GeForce NOW za oblak, plus vječni Minecraft.

Zahvaljujući nevjerojatnom radu Valvea na [sloju kompatibilnosti proton](https://en.wikipedia.org/wiki/Proton_(software)), sada postoje deseci tisuća igrivih modernih igara na Linuxu. Oh, a jeste li znali da [Steam Deck](https://store.steampowered.com/steamdeck/) zapravo pokreće Arch!

Svi instalateri za gaming nalaze se pod _Instaliraj > Gaming_ u izborniku Omarchy (`Super + Space`). Ako ikada poželiš poništiti jedan, koristi _Ukloni > Gaming_.

## Steam

Instaliraj [Steam](https://store.steampowered.com/) odabirom _Instaliraj > Gaming > Steam_ iz izbornika Omarchy (`Super + Space`).

Nakon što ga instaliraš, moći ćeš pokrenuti Steam sa `Super + Space`.

Imaj na umu da Steam može trebati 10-20 sekundi za pokretanje i neće pružiti nikakvu vizualnu povratnu informaciju da se učitava.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Instaliraj [RetroArch](https://www.retroarch.com/) odabirom _Instaliraj > Gaming > RetroArch_ iz izbornika Omarchy (`Super + Space`). Dolazi s punim skupom libretro jezgri, pa su svi klasični sustavi pokriveni.

RetroArch je u potpunosti unaprijed konfiguriran s prekrasnim shaderom CRT Royale za savršen retro izgled.

Za početak:

1. Ispusti svoje BIOS datoteke u `~/Games/bios`, a ROM-ove u `~/Games/roms`.
2. Pokreni RetroArch sa `Super + Space` i upisivanjem `retro`.
3. Skeniraj direktorij `~/Games/roms` i spreman si za igru.

Također omiljenoj igri možeš dati vlastiti unos u pokretaču aplikacija s _Instaliraj > Gaming > RetroArch Game Launcher_, što ti omogućuje odabir jezgre i ROM-a i skok izravno u igru iz `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Instaliraj web-aplikaciju Xbox Cloud Gaming odabirom _Instaliraj > Gaming > Xbox Cloud Gaming_ iz izbornika Omarchy (`Super + Space`). To je "samo" web-aplikacija za uslugu, ali brzo se pokreće i odlično radi na 1080p.

Ako već imaš Xbox Game Pass, ovo je čvrst način za igranje Fortnitea i drugih naslova koje ne možeš pokrenuti nativno na Linuxu.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Instaliraj uslugu za gaming u oblaku [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) odabirom _Instaliraj > Gaming > NVIDIA GeForce NOW_ iz izbornika Omarchy (`Super + Space`). Još jedan sjajan način za igranje naslova koji nisu dostupni nativno na Linuxu.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Instaliraj Minecraft odabirom _Instaliraj > Gaming > Minecraft_ iz izbornika Omarchy (`Super + Space`).

Kao i Steam, imaj na umu da može proći neko vrijeme nakon prijave ili pokretanja prije nego što se pojavi sljedeći zaslon i nećeš dobiti nikakvu povratnu informaciju dok čekaš.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox kontroleri

Instaliraj podršku za Bluetooth Xbox kontrolere odabirom _Instaliraj > Gaming > Xbox Controllers_ iz izbornika Omarchy (`Super + Space`). Upari kontrolere putem Bluetootha (`Super + Ctrl + B`) i radit će u svim tvojim igrama. Ovo ti ne treba ako kontroler samo žično spajaš USB-C kabelom.

## Moonlight (streaming igre s PC-a)

[Moonlight klijent](https://github.com/moonlight-stream/moonlight-qt) dolazi predinstaliran s Omarchyjem, pa možeš odmah streamati igre s Windows PC-a koji pokreće [Sunshine](https://app.lizardbyte.dev/Sunshine/). Pokreni Moonlight putem `Super + Space`.

Ako su i tvoje Omarchy računalo i udaljeno gaming računalo žično spojeni, iskustvo se ne razlikuje od igranja lokalno. Podigni razlučivost na nativnu, postavi osvježavanje na 120Hz i maksimiziraj bitrate — ovo je najbolji način za igranje kompetitivnih pucačina poput Fortnitea na Linuxu.

Omarchy računalo također možeš pretvoriti u hosta pokretanjem `omarchy install service sunshine`, što instalira Sunshine i otvara Moonlight streaming portove za tvoj LAN i Tailscale.

## Battle.net

Instaliraj [Battle.net](https://eu.shop.battle.net/en-us) odabirom _Instaliraj > Gaming > Battle.net_ iz izbornika Omarchy (`Super + Space`). To ti daje naslove poput Diablo, Starcraft i World of Warcraft kao samostalna instalacija koja radi pod GE-Protonom — nije potreban Steam, Lutris ni Heroic.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows igre)

Instaliraj [Lutris](https://lutris.net/) odabirom _Instaliraj > Gaming > Lutris_ iz izbornika Omarchy (`Super + Space`). Lutris je način za igranje Windows igara iz trgovina poput EA i Ubisoft Connect koje gore nemaju vlastiti instalater.

Instalacija je pomalo traljava i povremeno izgleda kao da se ništa ne događa — samo budi strpljiv, radi u pozadini.

## Heroic Launcher (Epic Games)

Instaliraj [Heroic Launcher](https://heroicgameslauncher.com/) odabirom _Instaliraj > Gaming > Heroic (Epic Games)_ iz izbornika Omarchy (`Super + Space`). Heroic ti omogućuje pokretanje naslova Epic Games, poput OddSparks, koji se ne oslanjaju na anti-cheat — plus igre s GOG-a i Amazon Prime Gaminga. Nažalost, to znači da nema Fortnitea i nema Rocket Leaguea — dok Tim Sweeney ne dođe na Linux, ovo je najbliže što se može.

Kao i Lutris, može se činiti sporim i traljavim tijekom instalacije igara. Daj mu vremena.
