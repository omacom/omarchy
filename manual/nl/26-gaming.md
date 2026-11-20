# Gamen

Omarchy is niet alleen voor _pRoDuCtIvItEiT_, het is er ook om plezier te hebben, en wat is er leuker dan gamen? Omarchy wordt geleverd met een hele reeks game-opties — Steam en RetroArch voor native en retro gamen, Battle.net, Lutris en Heroic voor winkels buiten Steam, Moonlight voor pc-streaming, Xbox Cloud Gaming + NVIDIA GeForce NOW voor de cloud, plus de tijdloze klassieker Minecraft.

Dankzij het ongelooflijke werk van Valve aan [de Proton-compatibiliteitslaag](https://en.wikipedia.org/wiki/Proton_(software)) zijn er nu tienduizenden moderne games speelbaar op Linux. Oh, en wist je dat de [Steam Deck](https://store.steampowered.com/steamdeck/) eigenlijk Arch draait!

Alle game-installatieprogramma's staan onder _Installeren > Gamen_ in het Omarchy-menu (`Super + Space`). Als je er ooit een ongedaan wilt maken, gebruik je _Verwijderen > Gamen_.

## Steam

Installeer [Steam](https://store.steampowered.com/) door _Installeren > Gamen > Steam_ te selecteren in het Omarchy-menu (`Super + Space`).

Nadat je het hebt geïnstalleerd, kun je Steam starten met `Super + Space`.

Let op: Steam kan er 10-20 seconden over doen om op te starten en geeft geen enkele visuele feedback dat het aan het laden is.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Installeer [RetroArch](https://www.retroarch.com/) door _Installeren > Gamen > RetroArch_ te selecteren in het Omarchy-menu (`Super + Space`). Het wordt geleverd met de volledige set libretro-cores, dus alle klassieke systemen worden ondersteund.

RetroArch is volledig vooraf geconfigureerd met de prachtige CRT Royale-shader voor die perfecte retro-look.

Aan de slag:

1. Zet je BIOS-bestanden in `~/Games/bios` en je ROMs in `~/Games/roms`.
2. Start RetroArch met `Super + Space` en typ `retro`.
3. Scan de map `~/Games/roms` en je kunt spelen.

Je kunt een favoriet spel ook een eigen vermelding geven in de app-launcher met _Installeren > Gamen > RetroArch Game Launcher_, waarmee je een core en een ROM kiest en rechtstreeks vanuit `Super + Space` in het spel springt.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Installeer de Xbox Cloud Gaming-webapp door _Installeren > Gamen > Xbox Cloud Gaming_ te selecteren in het Omarchy-menu (`Super + Space`). Het is "gewoon" een webapp voor de dienst, maar start snel op en draait geweldig op 1080p.

Als je al Xbox Game Pass hebt, is dit een degelijke manier om Fortnite en andere titels te spelen die je niet native op Linux kunt draaien.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Installeer de cloudgamingdienst [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) door _Installeren > Gamen > NVIDIA GeForce NOW_ te selecteren in het Omarchy-menu (`Super + Space`). Nog een geweldige manier om titels te spelen die niet native beschikbaar zijn op Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Installeer Minecraft door _Installeren > Gamen > Minecraft_ te selecteren in het Omarchy-menu (`Super + Space`).

Net als bij Steam: let op dat het even kan duren voordat na het inloggen of opstarten het volgende scherm verschijnt, en je krijgt geen feedback terwijl je wacht.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox-controllers

Installeer ondersteuning voor Bluetooth Xbox-controllers door _Installeren > Gamen > Xbox Controllers_ te selecteren in het Omarchy-menu (`Super + Space`). Koppel de controllers via Bluetooth (`Super + Ctrl + B`) en ze werken in al je games. Je hebt dit niet nodig als je je controller gewoon met een USB-C-kabel aansluit.

## Moonlight (Games streamen vanaf een pc)

Installeer de [Moonlight-client](https://github.com/moonlight-stream/moonlight-qt) door _Installeren > Gamen > Moonlight_ te selecteren in het Omarchy-menu (`Super + Space`), en je kunt games streamen vanaf een Windows-pc waarop [Sunshine](https://app.lizardbyte.dev/Sunshine/) draait.

Als zowel je Omarchy-machine als de externe gaming-pc bekabeld zijn aangesloten, is de ervaring niet te onderscheiden van lokaal spelen. Zet de resolutie op native, stel de verversing in op 120Hz en zet de bitrate op maximaal — dit is de beste manier om competitieve shooters zoals Fortnite op Linux te spelen.

Je kunt van een Omarchy-machine ook de host maken door `omarchy install service sunshine` uit te voeren, waarmee Sunshine wordt geïnstalleerd en de Moonlight-streamingpoorten worden geopend voor je LAN en Tailscale.

## Battle.net

Installeer [Battle.net](https://eu.shop.battle.net/en-us) door _Installeren > Gamen > Battle.net_ te selecteren in het Omarchy-menu (`Super + Space`). Dit geeft je titels zoals Diablo, Starcraft en World of Warcraft als een zelfstandige installatie die draait onder GE-Proton — geen Steam, Lutris of Heroic nodig.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows-games)

Installeer [Lutris](https://lutris.net/) door _Installeren > Gamen > Lutris_ te selecteren in het Omarchy-menu (`Super + Space`). Lutris is dé manier om Windows-games te spelen uit winkels zoals EA en Ubisoft Connect die hierboven geen eigen installatieprogramma hebben.

De installatie is een beetje haperig en soms lijkt het alsof er niets gebeurt — heb gewoon geduld, het werkt op de achtergrond.

## Heroic Launcher (Epic Games)

Installeer de [Heroic Launcher](https://heroicgameslauncher.com/) door _Installeren > Gamen > Heroic (Epic Games)_ te selecteren in het Omarchy-menu (`Super + Space`). Met Heroic kun je Epic Games-titels draaien, zoals OddSparks, die niet afhankelijk zijn van anti-cheat — plus games van GOG en Amazon Prime Gaming. Helaas betekent dat geen Fortnite en geen Rocket League — totdat Tim Sweeney naar Linux komt, is dit het dichtst dat je erbij in de buurt komt.

Net als bij Lutris kan het traag en haperig aanvoelen tijdens het installeren van games. Geef het de tijd.
