# Gaming

Omarchy er ikke kun til _pRoDUcTiVItY_, det er også til at have det sjovt, og hvad er sjovere end gaming? Omarchy leveres med en hel suite af gamingmuligheder — Steam og RetroArch til native og retro-spil, Battle.net, Lutris og Heroic til ikke-Steam-butikker, Moonlight til PC-streaming, Xbox Cloud Gaming + NVIDIA GeForce NOW til cloud plus den evigtgrønne Minecraft.

Takket være Valves utrolige arbejde på [proton-kompatibilitetslaget](https://en.wikipedia.org/wiki/Proton_(software)) er der nu titusindvis af spilbare moderne spil på Linux. Åh, og vidste du, at [Steam Deck](https://store.steampowered.com/steamdeck/) faktisk kører Arch!

Alle gaminginstallationsprogrammer lever under _Installer > Gaming_ i Omarchy-menuen (`Super + Space`). Hvis du nogensinde vil fortryde et, skal du bruge _Fjern > Gaming_.

## Steam

Installér [Steam](https://store.steampowered.com/) ved at vælge _Installer > Gaming > Steam_ fra Omarchy-menuen (`Super + Space`).

Når du har installeret det, vil du kunne starte Steam med `Super + Space`.

Bemærk, at Steam kan tage 10-20 sekunder om at starte op, og det giver ingen visuel feedback om, at det indlæses.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Installér [RetroArch](https://www.retroarch.com/) ved at vælge _Installer > Gaming > RetroArch_ fra Omarchy-menuen (`Super + Space`). Det leveres med det fulde sæt libretro-kerner, så alle de klassiske systemer er dækket.

RetroArch er fuldt forudkonfigureret med den smukke CRT Royale-shader for det perfekte retro-look.

For at komme i gang:

1. Smid dine BIOS-filer ind i `~/Games/bios` og dine ROM'er ind i `~/Games/roms`.
2. Start RetroArch med `Super + Space` og skriv `retro`.
3. Scan mappen `~/Games/roms`, og du er klar til at spille.

Du kan også give et favoritspil sin egen post i app-starteren med _Installer > Gaming > RetroArch Game Launcher_, som lader dig vælge en kerne og en ROM og hoppe direkte ind i spillet fra `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Installér Xbox Cloud Gaming-webappen ved at vælge _Installer > Gaming > Xbox Cloud Gaming_ fra Omarchy-menuen (`Super + Space`). Det er "bare" en webapp til tjenesten, men den er hurtig at starte og kører fantastisk ved 1080p.

Hvis du allerede har Xbox Game Pass, er dette en solid måde at spille Fortnite og andre titler, du ikke kan køre nativt på Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Installér cloud-gamingtjenesten [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) ved at vælge _Installer > Gaming > NVIDIA GeForce NOW_ fra Omarchy-menuen (`Super + Space`). Endnu en fantastisk måde at spille titler, der ikke er tilgængelige nativt på Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Installér Minecraft ved at vælge _Installer > Gaming > Minecraft_ fra Omarchy-menuen (`Super + Space`).

Ligesom Steam skal du bemærke, at det kan tage et stykke tid efter login eller opstart, før den næste skærm vises, og du får ingen feedback, mens du venter.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox-controllere

Installér support til Bluetooth Xbox-controllere ved at vælge _Installer > Gaming > Xbox Controllers_ fra Omarchy-menuen (`Super + Space`). Par controllerne via Bluetooth (`Super + Ctrl + B`), og de vil virke i alle dine spil. Du har ikke brug for dette, hvis du bare forbinder din controller med et USB-C-kabel.

## Moonlight (Spilstreaming fra en PC)

[Moonlight-klienten](https://github.com/moonlight-stream/moonlight-qt) leveres forudinstalleret med Omarchy, så du kan streame spil fra en Windows-PC, der kører [Sunshine](https://app.lizardbyte.dev/Sunshine/), med det samme. Start Moonlight via `Super + Space`.

Hvis både din Omarchy-maskine og fjern-gaming-PC'en er kablet, er oplevelsen umulig at skelne fra at spille lokalt. Skru opløsningen op til native, sæt opdateringen til 120Hz, og maks. bitraten — dette er den bedste måde at spille konkurrencedygtige skydespil som Fortnite på Linux.

Du kan også forvandle en Omarchy-maskine til værten ved at køre `omarchy install service sunshine`, som installerer Sunshine og åbner Moonlight-streamingportene til dit LAN og Tailscale.

## Battle.net

Installér [Battle.net](https://eu.shop.battle.net/en-us) ved at vælge _Installer > Gaming > Battle.net_ fra Omarchy-menuen (`Super + Space`). Dette giver dig titler som Diablo, Starcraft og World of Warcraft som en selvstændig installation, der kører under GE-Proton — ingen Steam, Lutris eller Heroic nødvendig.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows-spil)

Installér [Lutris](https://lutris.net/) ved at vælge _Installer > Gaming > Lutris_ fra Omarchy-menuen (`Super + Space`). Lutris er måden at spille Windows-spil fra butikker som EA og Ubisoft Connect, der ikke har deres eget installationsprogram ovenfor.

Installationen er lidt kluntet og ser ud som om, der ingenting sker til tider — vær bare tålmodig, den arbejder i baggrunden.

## Heroic Launcher (Epic Games)

Installér [Heroic Launcher](https://heroicgameslauncher.com/) ved at vælge _Installer > Gaming > Heroic (Epic Games)_ fra Omarchy-menuen (`Super + Space`). Heroic lader dig køre Epic Games-titler, som OddSparks, der ikke er afhængige af anti-cheat — plus spil fra GOG og Amazon Prime Gaming. Desværre betyder det ingen Fortnite og ingen Rocket League — indtil Tim Sweeney kommer til Linux, er dette så tæt, som det kommer.

Ligesom Lutris kan den føles langsom og kluntet, mens den installerer spil. Giv den tid.
