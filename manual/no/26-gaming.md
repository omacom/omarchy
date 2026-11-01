# Spilling

Omarchy er ikke bare for _pRoDUcTiVItY_, det er også for å ha det gøy, og hva er morsommere enn spilling? Omarchy leveres med en hel suite av spillvalg — Steam og RetroArch for nativ og retro spilling, Battle.net, Lutris og Heroic for butikker utenfor Steam, Moonlight for PC-strømming, Xbox Cloud Gaming + NVIDIA GeForce NOW for skyen, pluss evigunge Minecraft.

Takket være Valves utrolige arbeid med [proton-kompatibilitetslaget](https://en.wikipedia.org/wiki/Proton_(software)) finnes det nå titusenvis av spillbare moderne spill på Linux. Og visste du at [Steam Deck](https://store.steampowered.com/steamdeck/) faktisk kjører Arch!

Alle spillinstallasjonsprogrammer bor under _Installer > Spilling_ i Omarchy-menyen (`Super + Space`). Hvis du noen gang vil angre ett, bruk _Fjern > Spilling_.

## Steam

Installer [Steam](https://store.steampowered.com/) ved å velge _Installer > Spilling > Steam_ fra Omarchy-menyen (`Super + Space`).

Etter at du har installert den, kan du starte Steam med `Super + Space`.

Merk at Steam kan ta 10–20 sekunder på å starte, og den gir ingen visuell tilbakemelding om at den laster.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Installer [RetroArch](https://www.retroarch.com/) ved å velge _Installer > Spilling > RetroArch_ fra Omarchy-menyen (`Super + Space`). Den kommer med hele settet av libretro-kjerner, så alle de klassiske systemene dekkes.

RetroArch er fullt forhåndskonfigurert med den vakre CRT Royale-shaderen for det perfekte retro-utseendet.

For å komme i gang:

1. Slipp BIOS-filene dine i `~/Games/bios` og ROM-ene dine i `~/Games/roms`.
2. Start RetroArch med `Super + Space` og skriv `retro`.
3. Skann `~/Games/roms`-mappen, så er du klar til å spille.

Du kan også gi et favorittspill sin egen oppføring i appstarteren med _Installer > Spilling > RetroArch Game Launcher_, der du kan velge en kjerne og en ROM og hoppe rett inn i spillet fra `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Installer Xbox Cloud Gaming-webappen ved å velge _Installer > Spilling > Xbox Cloud Gaming_ fra Omarchy-menyen (`Super + Space`). Den er «bare» en webapp for tjenesten, men den er rask å starte og kjører flott i 1080p.

Hvis du allerede har Xbox Game Pass, er dette en solid måte å spille Fortnite og andre titler du ikke kan kjøre nativt på Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Installer skyspilltjenesten [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) ved å velge _Installer > Spilling > NVIDIA GeForce NOW_ fra Omarchy-menyen (`Super + Space`). Nok en flott måte å spille titler som ikke er tilgjengelige nativt på Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Installer Minecraft ved å velge _Installer > Spilling > Minecraft_ fra Omarchy-menyen (`Super + Space`).

Som med Steam, merk at det kan ta en stund etter innlogging eller oppstart før neste skjerm vises, og du får ingen tilbakemelding mens du venter.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox-kontrollere

Installer støtte for Bluetooth Xbox-kontrollere ved å velge _Installer > Spilling > Xbox-kontrollere_ fra Omarchy-menyen (`Super + Space`). Par kontrollerne via Bluetooth (`Super + Ctrl + B`), så fungerer de i alle spillene dine. Du trenger ikke dette hvis du bare kopler kontrolleren med en USB-C-kabel.

## Moonlight (Spillstrømming fra en PC)

[Moonlight-klienten](https://github.com/moonlight-stream/moonlight-qt) kommer forhåndsinstallert med Omarchy, så du kan strømme spill fra en Windows-PC som kjører [Sunshine](https://app.lizardbyte.dev/Sunshine/) med en gang. Start Moonlight via `Super + Space`.

Hvis både Omarchy-maskinen din og den eksterne spill-PC-en er kablet, kan opplevelsen ikke skilles fra å spille lokalt. Skru oppløsningen opp til nativ, sett oppdateringsfrekvensen til 120Hz og maks ut bitraten — dette er den beste måten å spille konkurranseskytespill som Fortnite på Linux.

Du kan også gjøre en Omarchy-maskin til vert ved å kjøre `omarchy install service sunshine`, som installerer Sunshine og åpner Moonlight-strømmeportene for LAN-et ditt og Tailscale.

## Battle.net

Installer [Battle.net](https://eu.shop.battle.net/en-us) ved å velge _Installer > Spilling > Battle.net_ fra Omarchy-menyen (`Super + Space`). Dette gir deg titler som Diablo, Starcraft og World of Warcraft som en frittstående installasjon som kjører under GE-Proton — ingen Steam, Lutris eller Heroic trengs.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows-spill)

Installer [Lutris](https://lutris.net/) ved å velge _Installer > Spilling > Lutris_ fra Omarchy-menyen (`Super + Space`). Lutris er måten å spille Windows-spill fra butikker som EA og Ubisoft Connect som ikke har eget installasjonsprogram ovenfor.

Installasjonen er litt klønete og ser ut som ingenting skjer til tider — bare vær tålmodig, den jobber i bakgrunnen.

## Heroic Launcher (Epic Games)

Installer [Heroic Launcher](https://heroicgameslauncher.com/) ved å velge _Installer > Spilling > Heroic (Epic Games)_ fra Omarchy-menyen (`Super + Space`). Heroic lar deg kjøre Epic Games-titler, som OddSparks, som ikke er avhengige av juksevern — pluss spill fra GOG og Amazon Prime Gaming. Dessverre betyr det ingen Fortnite og ingen Rocket League — inntil Tim Sweeney kommer til Linux, er dette så nært det blir.

Som Lutris kan den føles treg og klønete mens den installerer spill. Gi den tid.
