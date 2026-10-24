# Aktualisierungen

Omarchy und deine Pakete werden im Omarchy-Menü (`Super + Space`) über _Aktualisieren > Omarchy_ auf dem neuesten Stand gehalten.

Omarchy selbst ist als normale pacman-Pakete aus dem [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs) installiert, sodass eine Aktualisierung [das neueste Omarchy-Release](https://github.com/omacom/omarchy/releases) installiert, alle ausstehenden Migrationen ausführt, um dein System mit dem neuesten Stand zu synchronisieren, und alle Systempakete aus dem [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) und dem [AUR](https://aur.archlinux.org/) aktualisiert (falls du AUR-Pakete installiert hast).

Wenn neue Releases erscheinen, erscheint rechts neben deiner Uhr ein Kreispfeil-Symbol. Klicke es an, und der Aktualisierungsvorgang startet.

![update-available](images/update-available.webp)

### Vier Kanäle

Omarchy wird über vier Kanäle aktualisiert: stable, RC, edge und dev. Neue Installationen beginnen auf dem Stable-Kanal, der den [offiziellen Releases](https://github.com/omacom/omarchy/releases/) folgt, sowie dem [stabilen Omarchy-Arch-Mirror](https://github.com/omacom-io/omarchy-mirror), der einen Monat hinter dem neuesten Stand läuft, damit wir neue Inkompatibilitäten, die Konfigurationsänderungen erfordern, abfangen können, bevor sie den Leuten Probleme bereiten.

Aber wenn du helfen möchtest, diese potenziellen Probleme zu entdecken, kannst du auf dem Edge-Kanal laufen. Das hält deine Omarchy-Pakete auf den neuesten Entwicklungs-Builds und lässt dich auf die neuesten Arch-Pakete aktualisieren, sobald sie verfügbar sind. Das solltest du nur tun, wenn du mit Linux erfahren bist und weißt, wie du ein System mit Problemen wiederherstellst.

Vor jedem neuen Major-Release führen wir die abschließende Validierung über den RC-Kanal durch. Wenn du an der finalen Politur mithelfen möchtest, komm in #omarchy-release-candidates auf Discord vorbei.

Schließlich gibt es den Dev-Kanal, der Omarchy direkt mit einem Git-Checkout des Quellcodes in `~/omarchy` verknüpft, kombiniert mit den Edge-Paketen. Den solltest du nur nutzen, wenn du ein erfahrener Linux-Benutzer bist, direkt an Omarchy arbeitest und bereit bist, Brüche zu tolerieren.

Zwischen den Kanälen kannst du im Omarchy-Menü über _Aktualisieren > Channel_ wechseln (oder über `omarchy-channel-set` im Terminal).

### Firmware-Aktualisierungen

Nicht nur deine Pakete veralten. Viele Laptops und Peripheriegeräte liefern BIOS-, SSD- und Dock-Firmware über den Linux Vendor Firmware Service, und _Aktualisieren > Firmware_ im Omarchy-Menü holt und installiert alles, was auf deine Hardware wartet. Beim ersten Ausführen installiert es `fwupd`. Viel Firmware kann nur während eines Neustarts geschrieben werden, also sei nicht überrascht, wenn du zu einem aufgefordert wirst.

### Warnung vor direkten pacman/yay-Aktualisierungen

Wenn du mit Arch schon vertraut bist, könntest du versucht sein, einfach selbst `pacman -Syu` oder `yay -Syu` auszuführen, aber dann verpasst du den Snapshot, die Migrationen und die Konfigurationsaktualisierungen, die Omarchy zusammen mit neuen Paketen ausführt. Deshalb stoppt Omarchy ein direktes System-Upgrade tatsächlich und verweist dich stattdessen auf `omarchy update`. (Wenn du wirklich weißt, was du tust, sagt dir die Schutzvorrichtung, wie du sie für eine einzige Transaktion umgehst.)

### Schlechte Aktualisierungen zurückrollen

Wenn du nach einer Aktualisierung je ein Problem hast, kannst du dein System auf den vor der Aktualisierung aufgenommenen Snapshot zurückrollen. Starte einfach neu und wähle im Boot-Menü den Snapshot von vor Beginn der Aktualisierung aus.

![bootloader](images/bootloader.webp)

Falls deine Konfigurationsdateien irgendwie beschädigt wurden, kannst du mit `omarchy reinstall` im Terminal auch eine Omarchy-Neuinstallation durchführen. Das installiert alle Omarchy-Standardpakete neu, setzt dich auf stable, downgradet alle zu neuen Pakete und setzt alle Konfigurationsdateien zurück. Beachte, dass dabei alle deine benutzerdefinierten Änderungen an den Omarchy-Standards überschrieben werden!
