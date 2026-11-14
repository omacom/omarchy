# Spel

Omarchy är inte bara för _pRoDUcTiVItY_, det är också till för att ha kul, och vad är roligare än spel? Omarchy levereras med en hel svit av spelalternativ — Steam och RetroArch för native- och retrospel, Battle.net, Lutris och Heroic för butiker utanför Steam, Moonlight för PC-streaming, Xbox Cloud Gaming + NVIDIA GeForce NOW för molnspel, plus den eviga klassikern Minecraft.

Tack vare Valves otroliga arbete med [Proton-kompatibilitetslagret](https://en.wikipedia.org/wiki/Proton_(software)) finns det nu tiotusentals spelbara moderna spel på Linux. Åh, och visste du att [Steam Deck](https://store.steampowered.com/steamdeck/) faktiskt kör Arch!

Alla spelinstallationsprogram finns under _Installera > Spel_ i Omarchy-menyn (`Super + Space`). Om du någonsin vill ångra en installation använder du _Ta bort > Spel_.

## Steam

Installera [Steam](https://store.steampowered.com/) genom att välja _Installera > Spel > Steam_ i Omarchy-menyn (`Super + Space`).

När du har installerat det kan du starta Steam med `Super + Space`.

Observera att Steam kan ta 10-20 sekunder att starta, och det ger ingen visuell feedback på att det laddar.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Installera [RetroArch](https://www.retroarch.com/) genom att välja _Installera > Spel > RetroArch_ i Omarchy-menyn (`Super + Space`). Det levereras med hela uppsättningen libretro cores, så alla klassiska system täcks.

RetroArch är helt förkonfigurerat med den vackra CRT Royale-shadern för den perfekta retrolooken.

För att komma igång:

1. Lägg dina BIOS-filer i `~/Games/bios` och dina ROMs i `~/Games/roms`.
2. Starta RetroArch med `Super + Space` och skriv `retro`.
3. Skanna katalogen `~/Games/roms` så är du redo att spela.

Du kan också ge ett favoritspel en egen post i appstartaren med _Installera > Spel > RetroArch Game Launcher_, där du kan välja en core och en ROM och hoppa rakt in i spelet från `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Installera webbappen för Xbox Cloud Gaming genom att välja _Installera > Spel > Xbox Cloud Gaming_ i Omarchy-menyn (`Super + Space`). Den är "bara" en webbapp för tjänsten, men den startar snabbt och körs utmärkt i 1080p.

Om du redan har Xbox Game Pass är det här ett stabilt sätt att spela Fortnite och andra titlar som du inte kan köra native på Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Installera molnspeltjänsten [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) genom att välja _Installera > Spel > NVIDIA GeForce NOW_ i Omarchy-menyn (`Super + Space`). Ännu ett utmärkt sätt att spela titlar som inte finns native på Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Installera Minecraft genom att välja _Installera > Spel > Minecraft_ i Omarchy-menyn (`Super + Space`).

Precis som med Steam, observera att det kan ta en stund efter inloggning eller uppstart innan nästa skärm visas, och du får ingen feedback medan du väntar.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox Controllers

Installera stöd för Bluetooth Xbox Controllers genom att välja _Installera > Spel > Xbox Controllers_ i Omarchy-menyn (`Super + Space`). Para kontrollerna via Bluetooth (`Super + Ctrl + B`) så fungerar de i alla dina spel. Du behöver inte det här om du bara kopplar in kontrollen med en USB-C-kabel.

## Moonlight (Game streaming from a PC)

Installera [Moonlight client](https://github.com/moonlight-stream/moonlight-qt) genom att välja _Installera > Spel > Moonlight_ i Omarchy-menyn (`Super + Space`), så kan du streama spel från en Windows PC som kör [Sunshine](https://app.lizardbyte.dev/Sunshine/).

Om både din Omarchy-maskin och den fjärranslutna spel-PC:n är trådbundna går upplevelsen inte att skilja från att spela lokalt. Skruva upp upplösningen till native, ställ in uppdateringsfrekvensen på 120Hz och maxa bitraten — det här är det bästa sättet att spela tävlingsinriktade shooters som Fortnite på Linux.

Du kan också göra en Omarchy-maskin till värd genom att köra `omarchy install service sunshine`, vilket installerar Sunshine och öppnar Moonlight-streamingportarna för ditt LAN och Tailscale.

## Battle.net

Installera [Battle.net](https://eu.shop.battle.net/en-us) genom att välja _Installera > Spel > Battle.net_ i Omarchy-menyn (`Super + Space`). Det ger dig titlar som Diablo, Starcraft och World of Warcraft som en fristående installation som körs under GE-Proton — ingen Steam, Lutris eller Heroic behövs.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows games)

Installera [Lutris](https://lutris.net/) genom att välja _Installera > Spel > Lutris_ i Omarchy-menyn (`Super + Space`). Lutris är sättet att spela Windows-spel från butiker som EA och Ubisoft Connect som inte har ett eget installationsprogram ovan.

Installationen är lite knasig och ser ibland ut som att ingenting händer — ha bara tålamod, den arbetar i bakgrunden.

## Heroic Launcher (Epic Games)

Installera [Heroic Launcher](https://heroicgameslauncher.com/) genom att välja _Installera > Spel > Heroic (Epic Games)_ i Omarchy-menyn (`Super + Space`). Heroic låter dig köra Epic Games-titlar, som OddSparks, som inte är beroende av anti-cheat — plus spel från GOG och Amazon Prime Gaming. Tyvärr betyder det ingen Fortnite och ingen Rocket League — tills Tim Sweeney kommer till Linux är det här så nära det går att komma.

Precis som Lutris kan det kännas segt och knasigt när spel installeras. Ge det tid.
