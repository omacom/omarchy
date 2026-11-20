# Gaming

Omarchy ist nicht nur für _pRoDUcTiVItY_ da, sondern auch für Spaß, und was macht mehr Spaß als Gaming? Omarchy liefert eine ganze Suite an Gaming-Optionen mit — Steam und RetroArch für natives Spielen und Retro-Spiele, Battle.net, Lutris und Heroic für Stores außerhalb von Steam, Moonlight für PC-Streaming, Xbox Cloud Gaming + NVIDIA GeForce NOW für die Cloud, plus den Dauerbrenner Minecraft.

Dank Valves unglaublicher Arbeit an [der Proton-Kompatibilitätsschicht](https://en.wikipedia.org/wiki/Proton_(software)) gibt es inzwischen Zehntausende spielbarer moderner Spiele unter Linux. Oh, und wusstest du, dass auf dem [Steam Deck](https://store.steampowered.com/steamdeck/) tatsächlich Arch läuft!

Alle Gaming-Installer findest du unter _Install > Gaming_ im Omarchy-Menü (`Super + Space`). Wenn du einen davon jemals rückgängig machen willst, nutze _Remove > Gaming_.

## Steam

Installiere [Steam](https://store.steampowered.com/), indem du _Install > Gaming > Steam_ im Omarchy-Menü (`Super + Space`) auswählst.

Nachdem du es installiert hast, kannst du Steam mit `Super + Space` starten.

Beachte, dass Steam 10-20 Sekunden zum Starten brauchen kann und dir keinerlei visuelles Feedback gibt, dass es gerade lädt.

 ![gaming-steam](images/gaming-steam.webp)

## RetroArch

Installiere [RetroArch](https://www.retroarch.com/), indem du _Install > Gaming > RetroArch_ im Omarchy-Menü (`Super + Space`) auswählst. Es kommt mit dem vollständigen Satz an libretro-Cores, sodass alle klassischen Systeme abgedeckt sind.

RetroArch ist vollständig mit dem wunderschönen CRT Royale Shader für den perfekten Retro-Look vorkonfiguriert.

So legst du los:

1. Lege deine BIOS-Dateien in `~/Games/bios` und deine ROMs in `~/Games/roms`.
2. Starte RetroArch mit `Super + Space` und tippe `retro` ein.
3. Scanne das Verzeichnis `~/Games/roms`, und du bist bereit zu spielen.

Du kannst einem Lieblingsspiel auch einen eigenen Eintrag im App-Launcher geben, mit _Install > Gaming > RetroArch Game Launcher_, womit du einen Core und ein ROM auswählen und direkt über `Super + Space` ins Spiel springen kannst.

 ![gaming-retroarch](images/gaming-retroarch.webp)

## Xbox Cloud Gaming

Installiere die Xbox Cloud Gaming Web-App, indem du _Install > Gaming > Xbox Cloud Gaming_ im Omarchy-Menü (`Super + Space`) auswählst. Sie ist „nur“ eine Web-App für den Dienst, aber sie startet schnell und läuft großartig bei 1080p.

Wenn du bereits Xbox Game Pass hast, ist das eine solide Möglichkeit, Fortnite und andere Titel zu spielen, die du nicht nativ unter Linux ausführen kannst.

 ![gaming-xbox-cloud](images/gaming-xbox-cloud.webp)

## NVIDIA GeForce Now

Installiere den Cloud-Gaming-Dienst [NVIDIA GeForce NOW](https://www.nvidia.com/en-us/geforce-now/), indem du _Install > Gaming > NVIDIA GeForce NOW_ im Omarchy-Menü (`Super + Space`) auswählst. Ein weiterer großartiger Weg, Titel zu spielen, die unter Linux nicht nativ verfügbar sind.

 ![gaming-geforce-now](images/gaming-geforce-now.webp)

## Minecraft

Installiere Minecraft, indem du _Install > Gaming > Minecraft_ im Omarchy-Menü (`Super + Space`) auswählst.

Wie bei Steam beachte, dass es nach dem Einloggen oder Starten eine Weile dauern kann, bis der nächste Bildschirm erscheint, und du keinerlei Feedback bekommst, während du wartest.

 ![gaming-minecraft](images/gaming-minecraft.webp)

## Xbox Controllers

Installiere die Unterstützung für Bluetooth-Xbox-Controller, indem du _Install > Gaming > Xbox Controllers_ im Omarchy-Menü (`Super + Space`) auswählst. Kopple die Controller via Bluetooth (`Super + Ctrl + B`), und sie funktionieren in all deinen Spielen. Du brauchst das nicht, wenn du deinen Controller einfach mit einem USB-C-Kabel verbindest.

## Moonlight (Game streaming from a PC)

Installiere den [Moonlight-Client](https://github.com/moonlight-stream/moonlight-qt), indem du _Install > Gaming > Moonlight_ im Omarchy-Menü (`Super + Space`) auswählst, und du kannst Spiele von einem Windows-PC streamen, auf dem [Sunshine](https://app.lizardbyte.dev/Sunshine/) läuft.

Wenn sowohl deine Omarchy-Maschine als auch der entfernte Gaming-PC kabelgebunden verbunden sind, ist das Erlebnis nicht von lokalem Spielen zu unterscheiden. Dreh die Auflösung auf nativ hoch, stelle die Bildwiederholrate auf 120Hz und maximiere die Bitrate — das ist der beste Weg, kompetitive Shooter wie Fortnite unter Linux zu spielen.

Du kannst eine Omarchy-Maschine auch zum Host machen, indem du `omarchy install service sunshine` ausführst, was Sunshine installiert und die Moonlight-Streaming-Ports für dein LAN und Tailscale öffnet.

## Battle.net

Installiere [Battle.net](https://eu.shop.battle.net/en-us), indem du _Install > Gaming > Battle.net_ im Omarchy-Menü (`Super + Space`) auswählst. Das gibt dir Titel wie Diablo, Starcraft und World of Warcraft als eigenständige Installation, die unter GE-Proton läuft — kein Steam, Lutris oder Heroic nötig.

 ![gaming-starcraft](images/gaming-starcraft.webp)

## Lutris (Windows games)

Installiere [Lutris](https://lutris.net/), indem du _Install > Gaming > Lutris_ im Omarchy-Menü (`Super + Space`) auswählst. Lutris ist der Weg, Windows-Spiele von Stores wie EA und Ubisoft Connect zu spielen, die oben keinen eigenen Installer haben.

Die Installation ist ein bisschen holprig und sieht zeitweise so aus, als würde nichts passieren — hab einfach Geduld, es arbeitet im Hintergrund.

## Heroic Launcher (Epic Games)

Installiere den [Heroic Launcher](https://heroicgameslauncher.com/), indem du _Install > Gaming > Heroic (Epic Games)_ im Omarchy-Menü (`Super + Space`) auswählst. Mit Heroic kannst du Epic-Games-Titel wie OddSparks ausführen, die nicht auf Anti-Cheat angewiesen sind — plus Spiele von GOG und Amazon Prime Gaming. Leider bedeutet das kein Fortnite und kein Rocket League — bis Tim Sweeney zu Linux kommt, kommt man dem nicht näher.

Wie Lutris kann es sich beim Installieren von Spielen langsam und holprig anfühlen. Gib ihm Zeit.
