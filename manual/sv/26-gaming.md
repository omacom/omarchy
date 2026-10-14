# Gaming

Omarchy är inte bara för _pRoDUcTiVItY_, det är också för att ha roligt, och vad är roligare än gaming? Omarchy levereras med en hel svit av gamingalternativ — Steam och RetroArch för native och retro-spel, Battle.net, Lutris och Heroic för butiker utanför Steam, Moonlight för PC-streaming, Xbox Cloud Gaming + NVIDIA GeForce NOW för molnet, plus den eviga klassikern Minecraft.

Tack vare Valves otroliga arbete med [proton-kompatibilitetslagret](https://en.wikipedia.org/wiki/Proton_(software)) finns det nu tiotusentals spelbara moderna spel på Linux. Ja, och visste du att [Steam Deck](https://store.steampowered.com/steamdeck/) faktiskt kör Arch!

Alla gaminginstallers bor under _Installera > Gaming_ i Omarchy-menyn (`Super + Space`). Om du någonsin vill ångra en, använd _Ta bort > Gaming_.

## Steam

Installera [Steam](https://store.steampowered.com/) genom att välja _Installera > Gaming > Steam_ från Omarchy-menyn (`Super + Space`).

När du har installerat det kommer du att kunna starta Steam med `Super + Space`.

Observera att Steam kan ta 10-20 sekunder att starta, och det ger ingen visuell återkoppling om att det laddar.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Installera [RetroArch](https://www.retroarch.com/) genom att välja _Installera > Gaming > RetroArch_ från Omarchy-menyn (`Super + Space`). Det kommer med den fullständiga uppsättningen libretro-kärnor, så alla klassiska system är täckta.

RetroArch är helt förkonfigurerat med den vackra CRT Royale-shadern för det perfekta retroutseendet.

För att komma igång:

1. Lägg dina BIOS-filer i `~/Games/bios` och dina ROM:ar i `~/Games/roms`.
2. Starta RetroArch med `Super + Space` och skriv `retro`.
3. Skanna katalogen `~/Games/roms` så är du redo att spela.

Du kan också ge ett favoritspel dess egen post i app-launchern med _Installera > Gaming > RetroArch Game Launcher_, vilket låter dig välja en kärna och en ROM, och hoppa rakt in i spelet från `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Installera webbappen Xbox Cloud Gaming genom att välja _Installera > Gaming > Xbox Cloud Gaming_ från Omarchy-menyn (`Super + Space`). Det är "bara" en webbapp för tjänsten, men den startar snabbt och körs bra i 1080p.

Om du redan har Xbox Game Pass är det här ett gediget sätt att spela Fortnite och andra titlar du inte kan köra nativt på Linux.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Installera molngamingtjänsten [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) genom att välja _Installera > Gaming > NVIDIA GeForce NOW_ från Omarchy-menyn (`Super + Space`). Ännu ett utmärkt sätt att spela titlar som inte finns nativt för Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Installera Minecraft genom att välja _Installera > Gaming > Minecraft_ från Omarchy-menyn (`Super + Space`).

Precis som Steam, observera att det kan ta ett tag efter inloggning eller uppstart innan nästa skärm visas, och du får ingen återkoppling medan du väntar.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox Controllers

Installera stöd för Bluetooth Xbox-kontroller genom att välja _Installera > Gaming > Xbox Controllers_ från Omarchy-menyn (`Super + Space`). Parkoppla kontrollerna via Bluetooth (`Super + Ctrl + B`) så fungerar de i alla dina spel. Du behöver inte det här om du bara kopplar in din kontroller med en USB-C-kabel.

## Moonlight (Spelstreaming från en PC)

[Moonlight-klienten](https://github.com/moonlight-stream/moonlight-qt) kommer förinstallerad med Omarchy, så du kan streama spel från en Windows-PC som kör [Sunshine](https://app.lizardbyte.dev/Sunshine/) direkt. Starta Moonlight via `Super + Space`.

Om både din Omarchy-maskin och den fjärrstyrda spel-PC:n är trådbundna går upplevelsen inte att skilja från att spela lokalt. Vrid upp upplösningen till native, ställ in uppdateringen till 120Hz och maxa bitrate — det här är det bästa sättet att spela konkurrenskraftiga skjutspel som Fortnite på Linux.

Du kan också förvandla en Omarchy-maskin till värd genom att köra `omarchy install service sunshine`, vilket installerar Sunshine och öppnar Moonlights streamingportar för ditt LAN och Tailscale.

## Battle.net

Installera [Battle.net](https://eu.shop.battle.net/en-us) genom att välja _Installera > Gaming > Battle.net_ från Omarchy-menyn (`Super + Space`). Det ger dig titlar som Diablo, Starcraft och World of Warcraft som en fristående installation som körs under GE-Proton — inget Steam, Lutris eller Heroic behövs.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows-spel)

Installera [Lutris](https://lutris.net/) genom att välja _Installera > Gaming > Lutris_ från Omarchy-menyn (`Super + Space`). Lutris är sättet att spela Windows-spel från butiker som EA och Ubisoft Connect som inte har sin egen installer ovan.

Installationen är lite skakig och ser ibland ut som att ingenting händer — ha bara tålamod, den arbetar i bakgrunden.

## Heroic Launcher (Epic Games)

Installera [Heroic Launcher](https://heroicgameslauncher.com/) genom att välja _Installera > Gaming > Heroic (Epic Games)_ från Omarchy-menyn (`Super + Space`). Heroic låter dig köra Epic Games-titlar, som OddSparks, som inte förlitar sig på anti-cheat — plus spel från GOG och Amazon Prime Gaming. Tyvärr innebär det inget Fortnite och inget Rocket League — tills Tim Sweeney kommer till Linux är det här så nära det blir.

Precis som Lutris kan den kännas långsam och skakig medan den installerar spel. Ge den tid.
