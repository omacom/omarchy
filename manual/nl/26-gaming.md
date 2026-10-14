# Gaming

Omarchy is niet alleen voor _pRoDUcTiVItEiT_, het is ook om plezier te hebben, en wat is leuker dan gamen? Omarchy wordt geleverd met een hele suite aan gamingopties — Steam en RetroArch voor native en retro spelen, Battle.net, Lutris en Heroic voor niet-Steam-winkels, Moonlight voor pc-streaming, Xbox Cloud Gaming + NVIDIA GeForce NOW voor cloud, plus het tijdloze Minecraft.

Dankzij Valve's ongelooflijke werk aan [de Proton-compatibiliteitslaag](https://en.wikipedia.org/wiki/Proton_(software)), zijn er nu tienduizenden speelbare moderne games op Linux. Oh, en wist je dat de [Steam Deck](https://store.steampowered.com/steamdeck/) daadwerkelijk Arch draait!

Alle gaming-installatieprogramma's leven onder _Installeren > Gaming_ in het Omarchy-menu (`Super + Space`). Als je er ooit een ongedaan wilt maken, gebruik je _Verwijderen > Gaming_.

## Steam

Installeer [Steam](https://store.steampowered.com/) door _Installeren > Gaming > Steam_ te selecteren in het Omarchy-menu (`Super + Space`).

Nadat je het hebt geïnstalleerd, kun je Steam starten met `Super + Space`.

Let op dat Steam 10-20 seconden kan duren om op te starten, en het geeft geen visuele feedback dat het aan het laden is.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Installeer [RetroArch](https://www.retroarch.com/) door _Installeren > Gaming > RetroArch_ te selecteren in het Omarchy-menu (`Super + Space`). Het wordt geleverd met de volledige set libretro-cores, dus alle klassieke systemen worden gedekt.

RetroArch is volledig vooraf geconfigureerd met de prachtige CRT Royale-shader voor die perfecte retro-look.

Om aan de slag te gaan:

1. Zet je BIOS-bestanden in `~/Games/bios` en je ROM's in `~/Games/roms`.
2. Start RetroArch met `Super + Space` en typ `retro`.
3. Scan de map `~/Games/roms` en je bent klaar om te spelen.

Je kunt een favoriete game ook zijn eigen vermelding in de app-launcher geven met _Installeren > Gaming > RetroArch-spelstarter_, waarmee je een core en een ROM kunt kiezen, en direct in de game kunt springen vanuit `Super + Space`.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Installeer de Xbox Cloud Gaming-webapp door _Installeren > Gaming > Xbox Cloud Gaming_ te selecteren in het Omarchy-menu (`Super + Space`). Het is "slechts" een webapp voor de dienst, maar het start snel en draait geweldig op 1080p.

Als je al Xbox Game Pass hebt, is dit een solide manier om Fortnite en andere titels te spelen die je niet native op Linux kunt draaien.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Installeer de cloudgamingdienst [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/) door _Installeren > Gaming > NVIDIA GeForce NOW_ te selecteren in het Omarchy-menu (`Super + Space`). Nog een geweldige manier om titels te spelen die niet native beschikbaar zijn op Linux.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Installeer Minecraft door _Installeren > Gaming > Minecraft_ te selecteren in het Omarchy-menu (`Super + Space`).

Net als bij Steam, let op dat het na het inloggen of opstarten even kan duren voordat het volgende scherm verschijnt, en je krijgt geen feedback terwijl je wacht.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox-controllers

Installeer ondersteuning voor Bluetooth Xbox-controllers door _Installeren > Gaming > Xbox-controllers_ te selecteren in het Omarchy-menu (`Super + Space`). Koppel de controllers via Bluetooth (`Super + Ctrl + B`) en ze werken in al je games. Je hebt dit niet nodig als je je controller gewoon bedraad aansluit met een USB-C-kabel.

## Moonlight (Game-streaming vanaf een pc)

De [Moonlight-client](https://github.com/moonlight-stream/moonlight-qt) wordt vooraf geïnstalleerd met Omarchy, dus je kunt direct games streamen vanaf een Windows-pc die [Sunshine](https://app.lizardbyte.dev/Sunshine/) draait. Start Moonlight via `Super + Space`.

Als zowel je Omarchy-machine als de externe gaming-pc bedraad zijn aangesloten, is de ervaring niet te onderscheiden van lokaal spelen. Draai de resolutie op naar native, stel de verversing in op 120Hz, en max de bitrate — dit is de beste manier om competitieve shooters zoals Fortnite op Linux te spelen.

Je kunt een Omarchy-machine ook in de host veranderen door `omarchy install service sunshine` uit te voeren, wat Sunshine installeert en de Moonlight-streamingpoorten opent voor je LAN en Tailscale.

## Battle.net

Installeer [Battle.net](https://eu.shop.battle.net/en-us) door _Installeren > Gaming > Battle.net_ te selecteren in het Omarchy-menu (`Super + Space`). Dit geeft je titels zoals Diablo, Starcraft en World of Warcraft als een standalone installatie die draait onder GE-Proton — geen Steam, Lutris of Heroic nodig.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows-games)

Installeer [Lutris](https://lutris.net/) door _Installeren > Gaming > Lutris_ te selecteren in het Omarchy-menu (`Super + Space`). Lutris is de manier om Windows-games te spelen van winkels zoals EA en Ubisoft Connect die hierboven geen eigen installatieprogramma hebben.

De installatie is een beetje rommelig en het lijkt soms alsof er niets gebeurt — wees gewoon geduldig, het werkt op de achtergrond.

## Heroic Launcher (Epic Games)

Installeer de [Heroic Launcher](https://heroicgameslauncher.com/) door _Installeren > Gaming > Heroic (Epic Games)_ te selecteren in het Omarchy-menu (`Super + Space`). Met Heroic kun je Epic Games-titels draaien, zoals OddSparks, die niet afhankelijk zijn van anti-cheat — plus games van GOG en Amazon Prime Gaming. Helaas betekent dat geen Fortnite en geen Rocket League — totdat Tim Sweeney naar Linux komt, is dit zo dichtbij als het wordt.

Net als Lutris kan het traag en rommelig aanvoelen tijdens het installeren van games. Geef het de tijd.
