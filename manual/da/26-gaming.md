# Gaming

Omarchy er ikke kun til _pRoDUcTiVItY_, det er også til at have det sjovt, og hvad er sjovere end gaming? Omarchy leveres med en hel række gaming-muligheder — Steam og RetroArch til native og retro spil, Battle.net, Lutris og Heroic til butikker uden for Steam, Moonlight til PC-streaming, Xbox Cloud Gaming + NVIDIA GeForce NOW til cloud, plus den eviggrønne Minecraft.

Takket være Valves utrolige arbejde med [proton-kompatibilitetslaget](https://en.wikipedia.org/wiki/Proton_(software)) findes der nu titusindvis af spilbare moderne spil på Linux. Åh, og vidste du, at [Steam Deck](https://store.steampowered.com/steamdeck/) faktisk kører Arch!

Alle gaming-installationsprogrammer findes under _Install > Gaming_ i Omarchy-menuen (`Super + Space`). Hvis du nogensinde vil fortryde en af dem, så brug _Remove > Gaming_. Minecraft, NVIDIA GeForce NOW, Battle.net, Lutris og Heroic tilbydes kun på x86-maskiner.

## Steam

Installer [Steam](https://store.steampowered.com/) ved at vælge _Install > Gaming > Steam_ fra Omarchy-menuen (`Super + Space`).

Når du har installeret det, kan du starte Steam med `Super + Space`.

Bemærk, at Steam kan tage 10-20 sekunder om at starte, og den giver ingen visuel feedback på, at den indlæser.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Installer [RetroArch](https://www.retroarch.com/) ved at vælge _Install > Gaming > RetroArch_ fra Omarchy-menuen (`Super + Space`). Den leveres med det fulde sæt af libretro-kerner, så alle de klassiske systemer er dækket.

RetroArch er fuldt forudkonfigureret med den smukke CRT Royale-shader for det perfekte retro-look.

Sådan kommer du i gang:

1. Læg dine BIOS-filer i `~/Games/bios` og dine ROMs i `~/Games/roms`.
2. Start RetroArch med `Super + Space` og skriv `retro`.
3. Scan mappen `~/Games/roms`, og så er du klar til at spille.

Du kan også give et yndlingsspil sin egen post i app-starteren med _Install > Gaming > RetroArch Game Launcher_, som lader dig vælge en kerne og en ROM og hoppe direkte ind i spillet fra `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Installer Xbox Cloud Gaming-webappen ved at vælge _Install > Gaming > Xbox Cloud Gaming_ fra Omarchy-menuen (`Super + Space`). Det er "bare" en webapp til tjenesten, men den starter hurtigt og kører fremragende i 1080p.

Hvis du allerede har Xbox Game Pass, er dette en solid måde at spille Fortnite og andre titler på, som du ikke kan køre nativt på Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Installer cloud-gaming-tjenesten [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) ved at vælge _Install > Gaming > NVIDIA GeForce NOW_ fra Omarchy-menuen (`Super + Space`). Endnu en fremragende måde at spille titler på, der ikke er tilgængelige nativt på Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Installer Minecraft ved at vælge _Install > Gaming > Minecraft_ fra Omarchy-menuen (`Super + Space`).

Ligesom med Steam skal du bemærke, at det kan tage et stykke tid, efter du har logget ind eller startet op, før den næste skærm vises, og du får ingen feedback, mens du venter.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox-controllere

Installer understøttelse af Bluetooth Xbox-controllere ved at vælge _Install > Gaming > Xbox Controllers_ fra Omarchy-menuen (`Super + Space`). Par controllerne via Bluetooth (`Super + Ctrl + B`), og så virker de i alle dine spil. Du har ikke brug for dette, hvis du blot tilslutter din controller direkte med et USB-C-kabel.

## Moonlight (Gamestreaming fra en PC)

Installer [Moonlight-klienten](https://github.com/moonlight-stream/moonlight-qt) ved at vælge _Install > Gaming > Moonlight_ fra Omarchy-menuen (`Super + Space`), og så kan du streame spil fra en Windows-PC, der kører [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Hvis både din Omarchy-maskine og den eksterne gaming-PC er forbundet med kabel, kan oplevelsen ikke skelnes fra at spille lokalt. Skru opløsningen op til native, sæt opdateringshastigheden til 120Hz, og maksimér bitraten — dette er den bedste måde at spille konkurrencemæssige skydespil som Fortnite på Linux.

Du kan også gøre en Omarchy-maskine til vært ved at køre `omarchy install service sunshine`, som installerer Sunshine og åbner Moonlight-streamingportene for dit LAN og Tailscale.

## Battle.net

Installer [Battle.net](https://eu.shop.battle.net/en-us) ved at vælge _Install > Gaming > Battle.net_ fra Omarchy-menuen (`Super + Space`). Dette giver dig titler som Diablo, Starcraft og World of Warcraft som en selvstændig installation, der kører under GE-Proton — ingen Steam, Lutris eller Heroic nødvendig.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows-spil)

Installer [Lutris](https://lutris.net/) ved at vælge _Install > Gaming > Lutris_ fra Omarchy-menuen (`Super + Space`). Lutris er måden at spille Windows-spil fra butikker som EA og Ubisoft Connect, der ikke har deres eget installationsprogram ovenfor.

Installationen er lidt kluntet og ser til tider ud, som om der ikke sker noget — vær bare tålmodig, den arbejder i baggrunden.

## Heroic Launcher (Epic Games)

Installer [Heroic Launcher](https://heroicgameslauncher.com/) ved at vælge _Install > Gaming > Heroic (Epic Games)_ fra Omarchy-menuen (`Super + Space`). Heroic lader dig køre Epic Games-titler som OddSparks, der ikke er afhængige af anti-cheat — plus spil fra GOG og Amazon Prime Gaming. Desværre betyder det ingen Fortnite og ingen Rocket League — indtil Tim Sweeney kommer til Linux, er dette det tætteste, du kommer.

Ligesom Lutris kan den føles langsom og kluntet, mens den installerer spil. Giv den tid.
