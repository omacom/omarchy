# Spilling

Omarchy er ikke bare til _pRoDuKtIvItEt_, det er også til for å ha det gøy, og hva er morsommere enn spilling? Omarchy leveres med en hel samling spillmuligheter — Steam og RetroArch for innebygd og retro spilling, Battle.net, Lutris og Heroic for butikker utenfor Steam, Moonlight for PC-strømming, Xbox Cloud Gaming + NVIDIA GeForce NOW for skyen, pluss den eviggrønne Minecraft.

Takket være Valves utrolige arbeid med [proton-kompatibilitetslaget](https://en.wikipedia.org/wiki/Proton_(software)) finnes det nå titusenvis av spillbare moderne spill på Linux. Å, og visste du at [Steam Deck](https://store.steampowered.com/steamdeck/) faktisk kjører Arch!

Alle spillinstallasjoner finnes under _Install > Gaming_ i Omarchy-menyen (`Super + Space`). Hvis du noen gang vil angre en, bruker du _Remove > Gaming_. Minecraft, NVIDIA GeForce NOW, Battle.net, Lutris og Heroic tilbys kun på x86-maskiner.

## Steam

Installer [Steam](https://store.steampowered.com/) ved å velge _Install > Gaming > Steam_ fra Omarchy-menyen (`Super + Space`).

Etter at du har installert det, kan du starte Steam med `Super + Space`.

Merk at Steam kan bruke 10-20 sekunder på å starte, og det kommer ikke til å gi noen visuell tilbakemelding på at det lastes inn.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Installer [RetroArch](https://www.retroarch.com/) ved å velge _Install > Gaming > RetroArch_ fra Omarchy-menyen (`Super + Space`). Det leveres med hele settet av libretro-kjerner, så alle de klassiske systemene er dekket.

RetroArch er ferdig konfigurert med den vakre CRT Royale-shaderen for det perfekte retro-utseendet.

For å komme i gang:

1. Legg BIOS-filene dine i `~/Games/bios` og ROM-ene dine i `~/Games/roms`.
2. Start RetroArch med `Super + Space` og skriv `retro`.
3. Skann `~/Games/roms`-mappen, så er du klar til å spille.

Du kan også gi et favorittspill sin egen oppføring i appstarteren med _Install > Gaming > RetroArch Game Launcher_, som lar deg velge en kjerne og en ROM, og hoppe rett inn i spillet fra `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Installer Xbox Cloud Gaming-webappen ved å velge _Install > Gaming > Xbox Cloud Gaming_ fra Omarchy-menyen (`Super + Space`). Det er «bare» en webapp for tjenesten, men den starter raskt og kjører flott i 1080p.

Hvis du allerede har Xbox Game Pass, er dette en solid måte å spille Fortnite og andre titler du ikke kan kjøre innebygd på Linux på.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Installer skyspilltjenesten [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) ved å velge _Install > Gaming > NVIDIA GeForce NOW_ fra Omarchy-menyen (`Super + Space`). Nok en flott måte å spille titler som ikke er tilgjengelige innebygd på Linux på.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Installer Minecraft ved å velge _Install > Gaming > Minecraft_ fra Omarchy-menyen (`Super + Space`).

Som med Steam, merk at det kan ta en stund etter at du logger inn eller starter opp før neste skjerm vises, og du får ingen tilbakemelding mens du venter.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox-kontrollere

Installer støtte for Bluetooth Xbox-kontrollere ved å velge _Install > Gaming > Xbox Controllers_ fra Omarchy-menyen (`Super + Space`). Par kontrollerne via Bluetooth (`Super + Ctrl + B`), så fungerer de i alle spillene dine. Du trenger ikke dette hvis du bare kobler kontrolleren til med en USB-C-kabel.

## Moonlight (Spillstrømming fra en PC)

Installer [Moonlight-klienten](https://github.com/moonlight-stream/moonlight-qt) ved å velge _Install > Gaming > Moonlight_ fra Omarchy-menyen (`Super + Space`), så kan du strømme spill fra en Windows-PC som kjører [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Hvis både Omarchy-maskinen din og den eksterne gaming-PC-en er kablet, er opplevelsen umulig å skille fra å spille lokalt. Skru oppløsningen opp til opprinnelig, sett oppdateringen til 120Hz, og maks ut bitraten — dette er den beste måten å spille konkurranseskytespill som Fortnite på Linux på.

Du kan også gjøre en Omarchy-maskin til vert ved å kjøre `omarchy install service sunshine`, som installerer Sunshine og åpner Moonlight-strømmeportene for LAN-et ditt og Tailscale.

## Battle.net

Installer [Battle.net](https://eu.shop.battle.net/en-us) ved å velge _Install > Gaming > Battle.net_ fra Omarchy-menyen (`Super + Space`). Dette gir deg titler som Diablo, Starcraft og World of Warcraft som en frittstående installasjon som kjører under GE-Proton — ingen Steam, Lutris eller Heroic nødvendig.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows-spill)

Installer [Lutris](https://lutris.net/) ved å velge _Install > Gaming > Lutris_ fra Omarchy-menyen (`Super + Space`). Lutris er måten å spille Windows-spill fra butikker som EA og Ubisoft Connect som ikke har sin egen installasjon ovenfor på.

Installasjonen er litt vaklete og ser ut som ingenting skjer i perioder — bare vær tålmodig, den jobber i bakgrunnen.

## Heroic Launcher (Epic Games)

Installer [Heroic Launcher](https://heroicgameslauncher.com/) ved å velge _Install > Gaming > Heroic (Epic Games)_ fra Omarchy-menyen (`Super + Space`). Heroic lar deg kjøre Epic Games-titler, som OddSparks, som ikke er avhengige av anti-cheat — pluss spill fra GOG og Amazon Prime Gaming. Dessverre betyr det ingen Fortnite og ingen Rocket League — før Tim Sweeney kommer til Linux, er dette så nært du kommer.

Som med Lutris kan det føles tregt og vaklete mens spill installeres. Gi det tid.
