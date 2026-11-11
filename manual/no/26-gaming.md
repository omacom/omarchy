# Gaming

Omarchy er ikke bare for _pRoDUcTiVItY_, det er også for å ha det gøy, og hva er morsommere enn gaming? Omarchy leveres med en hel pakke med gamingvalg — Steam og RetroArch for nativ spilling og retrospilling, Battle.net, Lutris og Heroic for butikker utenfor Steam, Moonlight for PC-strømming, Xbox Cloud Gaming + NVIDIA GeForce NOW for skyen, pluss eviggrønne Minecraft.

Takket være Valves utrolige arbeid med [kompatibilitetslaget Proton](https://en.wikipedia.org/wiki/Proton_(software)) finnes det nå titusenvis av moderne spill som kan spilles på Linux. Å, og visste du at [Steam Deck](https://store.steampowered.com/steamdeck/) faktisk kjører Arch!

Alle installasjonsprogrammer for gaming ligger under _Installer > Gaming_ i Omarchy-menyen (`Super + Space`). Hvis du noen gang vil angre en av dem, bruker du _Fjern > Gaming_.

## Steam

Installer [Steam](https://store.steampowered.com/) ved å velge _Installer > Gaming > Steam_ fra Omarchy-menyen (`Super + Space`).

Etter at du har installert det, kan du starte Steam med `Super + Space`.

Merk at Steam kan bruke 10-20 sekunder på å starte, og at den ikke kommer til å gi noen visuell tilbakemelding på at den laster inn.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Installer [RetroArch](https://www.retroarch.com/) ved å velge _Installer > Gaming > RetroArch_ fra Omarchy-menyen (`Super + Space`). Den leveres med det komplette settet av libretro-kjerner, så alle de klassiske systemene er dekket.

RetroArch er ferdig konfigurert med den vakre CRT Royale-shaderen for det perfekte retroutseendet.

Slik kommer du i gang:

1. Legg BIOS-filene dine i `~/Games/bios` og ROM-ene dine i `~/Games/roms`.
2. Start RetroArch med `Super + Space` og skriv `retro`.
3. Skann `~/Games/roms`-mappen, så er du klar til å spille.

Du kan også gi et favorittspill en egen oppføring i appstarteren med _Installer > Gaming > RetroArch Game Launcher_, der du kan velge en kjerne og en ROM, og hoppe rett inn i spillet fra `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Installer nettappen Xbox Cloud Gaming ved å velge _Installer > Gaming > Xbox Cloud Gaming_ fra Omarchy-menyen (`Super + Space`). Den er «bare» en nettapp for tjenesten, men den starter raskt og kjører flott i 1080p.

Hvis du allerede har Xbox Game Pass, er dette en solid måte å spille Fortnite og andre titler på som du ikke kan kjøre nativt på Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Installer skyspilltjenesten [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) ved å velge _Installer > Gaming > NVIDIA GeForce NOW_ fra Omarchy-menyen (`Super + Space`). En annen flott måte å spille titler på som ikke er tilgjengelige nativt på Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Installer Minecraft ved å velge _Installer > Gaming > Minecraft_ fra Omarchy-menyen (`Super + Space`).

Som med Steam bør du merke deg at det kan ta en stund etter innlogging eller oppstart før neste skjerm vises, og at du ikke får noen tilbakemelding mens du venter.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox Controllers

Installer støtte for Bluetooth Xbox-kontrollere ved å velge _Installer > Gaming > Xbox Controllers_ fra Omarchy-menyen (`Super + Space`). Koble til kontrollerne via Bluetooth (`Super + Ctrl + B`), så fungerer de i alle spillene dine. Du trenger ikke dette hvis du bare kobler kontrolleren til med en USB-C-kabel.

## Moonlight (Spillstrømming fra en PC)

Installer [Moonlight-klienten](https://github.com/moonlight-stream/moonlight-qt) ved å velge _Installer > Gaming > Moonlight_ fra Omarchy-menyen (`Super + Space`), så kan du strømme spill fra en Windows-PC som kjører [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Hvis både Omarchy-maskinen din og den eksterne gaming-PC-en er kablet, er opplevelsen umulig å skille fra å spille lokalt. Skru oppløsningen opp til nativ, sett oppdateringsfrekvensen til 120Hz, og maks bitraten — dette er den beste måten å spille konkurransepregede skytespill som Fortnite på Linux.

Du kan også gjøre en Omarchy-maskin om til verten ved å kjøre `omarchy install service sunshine`, som installerer Sunshine og åpner Moonlight-strømmeportene for LAN-et og Tailscale ditt.

## Battle.net

Installer [Battle.net](https://eu.shop.battle.net/en-us) ved å velge _Installer > Gaming > Battle.net_ fra Omarchy-menyen (`Super + Space`). Dette gir deg titler som Diablo, Starcraft og World of Warcraft som en frittstående installasjon som kjører under GE-Proton — ingen Steam, Lutris eller Heroic nødvendig.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows-spill)

Installer [Lutris](https://lutris.net/) ved å velge _Installer > Gaming > Lutris_ fra Omarchy-menyen (`Super + Space`). Lutris er måten å spille Windows-spill fra butikker som EA og Ubisoft Connect på, som ikke har sitt eget installasjonsprogram ovenfor.

Installasjonen er litt klønete og ser ut som om ingenting skjer til tider — bare vær tålmodig, den jobber i bakgrunnen.

## Heroic Launcher (Epic Games)

Installer [Heroic Launcher](https://heroicgameslauncher.com/) ved å velge _Installer > Gaming > Heroic (Epic Games)_ fra Omarchy-menyen (`Super + Space`). Heroic lar deg kjøre Epic Games-titler, som OddSparks, som ikke er avhengige av anti-cheat — pluss spill fra GOG og Amazon Prime Gaming. Dessverre betyr det ingen Fortnite og ingen Rocket League — før Tim Sweeney kommer til Linux, er dette så nært du kommer.

Som med Lutris kan det føles tregt og klønete mens spill installeres. Gi det tid.
