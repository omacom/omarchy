# Gaming

Omarchy ist nicht nur für _pRoDuKtIvItÄt_, es ist auch zum Spaßhaben da, und was macht mehr Spaß als Gaming? Omarchy bringt eine ganze Suite von Gaming-Optionen mit — Steam und RetroArch für natives und Retro-Spielen, Battle.net, Lutris und Heroic für Stores außerhalb von Steam, Moonlight für PC-Streaming, Xbox Cloud Gaming + NVIDIA GeForce NOW für die Cloud, plus den zeitlosen Klassiker Minecraft.

Dank Valves unglaublicher Arbeit an [der Proton-Kompatibilitätsschicht](https://en.wikipedia.org/wiki/Proton_(software)) gibt es inzwischen Zehntausende spielbarer moderner Spiele unter Linux. Ach, und wusstest du, dass das [Steam Deck](https://store.steampowered.com/steamdeck/) tatsächlich Arch ausführt!

Alle Gaming-Installer leben im Omarchy-Menü (`Super + Space`) unter _Installieren > Gaming_. Wenn du einen je rückgängig machen willst, verwende _Entfernen > Gaming_.

## Steam

Installiere [Steam](https://store.steampowered.com/), indem du im Omarchy-Menü (`Super + Space`) _Installieren > Gaming > Steam_ auswählst.

Nachdem du es installiert hast, kannst du Steam mit `Super + Space` starten.

Beachte, dass Steam 10-20 Sekunden zum Starten brauchen kann und keine visuelle Rückmeldung gibt, dass es lädt.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Installiere [RetroArch](https://www.retroarch.com/), indem du im Omarchy-Menü (`Super + Space`) _Installieren > Gaming > RetroArch_ auswählst. Es kommt mit dem vollständigen Satz an libretro-Kernen, sodass alle klassischen Systeme abgedeckt sind.

RetroArch ist vollständig mit dem schönen Shader CRT Royale für den perfekten Retro-Look vorkonfiguriert.

So legst du los:

1. Lege deine BIOS-Dateien in `~/Games/bios` und deine ROMs in `~/Games/roms`.
2. Starte RetroArch mit `Super + Space` und tippe `retro`.
3. Scanne das Verzeichnis `~/Games/roms`, und du bist spielbereit.

Du kannst einem Lieblingsspiel auch mit _Installieren > Gaming > RetroArch Game Launcher_ einen eigenen Eintrag im App-Launcher geben, womit du einen Kern und eine ROM auswählen und direkt aus `Super + Space` ins Spiel springen kannst.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Installiere die Web-App Xbox Cloud Gaming, indem du im Omarchy-Menü (`Super + Space`) _Installieren > Gaming > Xbox Cloud Gaming_ auswählst. Sie ist „nur“ eine Web-App für den Dienst, aber sie startet schnell und läuft großartig in 1080p.

Wenn du bereits Xbox Game Pass hast, ist dies eine solide Möglichkeit, Fortnite und andere Titel zu spielen, die du unter Linux nicht nativ ausführen kannst.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Installiere den Cloud-Gaming-Dienst [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/), indem du im Omarchy-Menü (`Super + Space`) _Installieren > Gaming > NVIDIA GeForce NOW_ auswählst. Eine weitere großartige Möglichkeit, Titel zu spielen, die unter Linux nicht nativ verfügbar sind.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Installiere Minecraft, indem du im Omarchy-Menü (`Super + Space`) _Installieren > Gaming > Minecraft_ auswählst.

Wie bei Steam beachte, dass es nach dem Anmelden oder Starten eine Weile dauern kann, bis der nächste Bildschirm erscheint, und du erhältst keine Rückmeldung, während du wartest.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox-Controller

Installiere die Unterstützung für Bluetooth-Xbox-Controller, indem du im Omarchy-Menü (`Super + Space`) _Installieren > Gaming > Xbox Controllers_ auswählst. Kopple die Controller per Bluetooth (`Super + Ctrl + B`), und sie funktionieren in all deinen Spielen. Das brauchst du nicht, wenn du deinen Controller einfach per USB-C-Kabel anschließt.

## Moonlight (Spiel-Streaming von einem PC)

Der [Moonlight-Client](https://github.com/moonlight-stream/moonlight-qt) ist in Omarchy vorinstalliert, sodass du sofort Spiele von einem Windows-PC streamen kannst, auf dem [Sunshine](https://app.lizardbyte.dev/Sunshine/) läuft. Starte Moonlight über `Super + Space`.

Wenn sowohl dein Omarchy-Rechner als auch der ferne Gaming-PC per Kabel verbunden sind, ist das Erlebnis von lokalem Spielen nicht zu unterscheiden. Dreh die Auflösung auf nativ, setze die Bildwiederholrate auf 120Hz und maximiere die Bitrate — so spielst du kompetitive Shooter wie Fortnite am besten unter Linux.

Du kannst einen Omarchy-Rechner auch zum Host machen, indem du `omarchy install service sunshine` ausführst, was Sunshine installiert und die Moonlight-Streaming-Ports für dein LAN und Tailscale öffnet.

## Battle.net

Installiere [Battle.net](https://eu.shop.battle.net/en-us), indem du im Omarchy-Menü (`Super + Space`) _Installieren > Gaming > Battle.net_ auswählst. Das gibt dir Titel wie Diablo, Starcraft und World of Warcraft als eigenständige Installation unter GE-Proton — kein Steam, Lutris oder Heroic nötig.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows-Spiele)

Installiere [Lutris](https://lutris.net/), indem du im Omarchy-Menü (`Super + Space`) _Installieren > Gaming > Lutris_ auswählst. Lutris ist der Weg, um Windows-Spiele aus Stores wie EA und Ubisoft Connect zu spielen, die oben keinen eigenen Installer haben.

Die Installation ist etwas holprig und sieht zeitweise so aus, als passiere nichts — hab einfach Geduld, es arbeitet im Hintergrund.

## Heroic Launcher (Epic Games)

Installiere den [Heroic Launcher](https://heroicgameslauncher.com/), indem du im Omarchy-Menü (`Super + Space`) _Installieren > Gaming > Heroic (Epic Games)_ auswählst. Heroic lässt dich Epic-Games-Titel wie OddSparks ausführen, die nicht auf Anti-Cheat angewiesen sind — plus Spiele von GOG und Amazon Prime Gaming. Leider bedeutet das: kein Fortnite und kein Rocket League — bis Tim Sweeney zu Linux kommt, ist dies das Nächstbeste.

Wie Lutris kann es sich beim Installieren von Spielen langsam und holprig anfühlen. Gib ihm Zeit.
