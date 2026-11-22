# Aktualisierungen

Omarchy und deine Pakete hältst du über _Update > Omarchy_ im Omarchy-Menü (`Super + Space`) auf dem neuesten Stand.

Omarchy selbst wird als reguläre pacman-Pakete aus dem [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs) installiert, also installiert eine Aktualisierung [das neueste Omarchy-Release](https://github.com/omacom/omarchy/releases), führt alle ausstehenden Migrationen aus, um dein System mit der neuesten Version abzugleichen, und aktualisiert alle Systempakete aus dem [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) und der [AUR](https://aur.archlinux.org/) (falls du AUR-Pakete installiert hast).

Wenn es neue Releases gibt, erscheint rechts von deiner Uhr ein Symbol mit einem kreisförmigen Pfeil. Klicke es an und der Aktualisierungsvorgang startet.

![update-available](images/update-available.webp)

### Vier Kanäle

Omarchy wird über vier Kanäle aktualisiert: stable, RC, edge und dev. Neue Installationen starten auf dem stable-Kanal, der den [offiziellen Releases](https://github.com/omacom/omarchy/releases/) folgt sowie dem [stable Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror), der einen Monat hinter der neuesten Version zurückliegt, damit wir neue Inkompatibilitäten, die Konfigurationsänderungen erfordern, abfangen können, bevor sie den Leuten Probleme bereiten.

Aber wenn du helfen willst, solche potenziellen Probleme aufzuspüren, kannst du den edge-Kanal nutzen. Dadurch folgen deine Omarchy-Pakete den neuesten Entwicklungs-Builds, und du kannst auf die neuesten Arch-Pakete aktualisieren, sobald sie verfügbar sind. Du solltest das nur tun, wenn du erfahren mit Linux bist und weißt, wie man ein System mit Problemen wiederherstellt.

Vor jedem neuen Major-Release machen wir die abschließende Validierung über den RC-Kanal. Wenn du beim letzten Feinschliff helfen willst, komm in #omarchy-release-candidates auf dem Discord vorbei.

Schließlich gibt es den dev-Kanal, der Omarchy direkt mit einem git-Checkout des Quellcodes in `~/omarchy` verknüpft, kombiniert mit den edge-Paketen. Du solltest diesen Kanal nur nutzen, wenn du ein erfahrener Linux-Nutzer bist, direkt an Omarchy arbeitest und bereit bist, kaputte Zustände in Kauf zu nehmen.

Du kannst mit _Update > Channel_ aus dem Omarchy-Menü zwischen den Kanälen wechseln (oder mit `omarchy channel set <stable|rc|edge|dev>` im Terminal, mit `omarchy channel current`, um zu sehen, wo du bist).

### Kernel wechseln

Omarchy bootet seinen eigenen `linux-omarchy`-Kernel, aber du kannst daneben andere installiert lassen, etwa den Standard-Arch-`linux`-Kernel oder einen experimentellen Build, den du testest. Wenn mehr als einer vorhanden ist, listet _Update > Kernel_ im Omarchy-Menü sie mit einem Häkchen neben dem, der standardmäßig bootet, auf. Wähle einen anderen, gib einmal dein Passwort ein, und er bootet nach dem nächsten Neustart. Die anderen Kernel bleiben im Boot-Menü, also kannst du immer noch von Hand einen wählen, falls der neue Standard dir Ärger macht. Im Terminal ist es `omarchy kernel`, um den aktuellen Standard zu sehen, `omarchy kernel list` für das, was installiert ist, und `omarchy kernel set <kernel>` zum Wechseln.

### Firmware-Aktualisierungen

Nicht nur deine Pakete veralten. Viele Laptops und Peripheriegeräte liefern BIOS-, SSD- und Dock-Firmware über den Linux Vendor Firmware Service aus, und _Update > Firmware_ im Omarchy-Menü lädt und installiert, was für deine Hardware bereitliegt. Beim ersten Ausführen installiert es `fwupd`. Jede Menge Firmware kann nur während eines Neustarts geschrieben werden, also wundere dich nicht, wenn du um einen gebeten wirst.

Wenn du eine Einstellung im BIOS selbst ändern musst, halte `Alt` im Systemmenü (`Super + Escape`) gedrückt, und _Reboot_ wird zu _Reboot to BIOS_, was direkt in das Firmware-Setup neu startet, ohne beim Booten die richtige Taste erwischen zu müssen. Vom Terminal aus ist es `omarchy system firmware`.

### Warnung vor direkten pacman/yay-Aktualisierungen

Wenn du Arch schon kennst, könntest du versucht sein, einfach selbst `pacman -Syu` oder `yay -Syu` auszuführen, aber wenn du das tust, verpasst du den Snapshot, die Migrationen und die Konfigurationsaktualisierungen, die Omarchy zusammen mit neuen Paketen ausführt. Deshalb stoppt Omarchy ein direktes System-Upgrade tatsächlich und verweist dich stattdessen auf `omarchy update`. (Wenn du wirklich weißt, was du tust, sagt dir der Schutz, wie du ihn für eine einzelne Transaktion umgehen kannst.)

### Schlechte Aktualisierungen zurückrollen

Falls du nach einer Aktualisierung jemals ein Problem hast, kannst du dein System auf den Snapshot zurückrollen, der vor der Aktualisierung erstellt wurde. Starte einfach neu und wähle im Boot-Menü den Snapshot von vor Beginn der Aktualisierung.

![bootloader](images/bootloader.webp)

Falls deine Konfigurationsdateien irgendwie beschädigt wurden, kannst du mit `omarchy reinstall` im Terminal auch eine Omarchy-Neuinstallation durchführen. Das installiert alle standardmäßigen Omarchy-Pakete neu, setzt dich auf stable (edge auf Apple Silicon), stuft alle Pakete herab, die zu neu sind, und setzt alle Konfigurationsdateien zurück. Beachte, dass dabei alle deine Benutzer-Konfigurationsänderungen an den Omarchy-Standards überschrieben werden!
