# Updates

Omarchy und deine Pakete hältst du über _Update > Omarchy_ im Omarchy-Menü (`Super + Space`) auf dem neuesten Stand.

Omarchy selbst wird als reguläre pacman-Pakete aus dem [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs) installiert, sodass ein Update [die neueste Omarchy-Version](https://github.com/omacom/omarchy/releases) installiert, alle ausstehenden Migrationen ausführt, um dein System mit der neuesten Version abzugleichen, und alle Systempakete aus dem [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) und der [AUR](https://aur.archlinux.org/) aktualisiert (falls du AUR-Pakete installiert hast).

Wenn neue Versionen erscheinen, wird rechts neben deiner Uhr ein Symbol mit einem kreisförmigen Pfeil angezeigt. Klicke darauf, und der Update-Vorgang startet.

![update-available](images/update-available.webp)

### Vier Kanäle

Omarchy wird über vier Kanäle aktualisiert: stable, RC, edge und dev. Neue Installationen starten auf dem stable-Kanal, der den [offiziellen Versionen](https://github.com/omacom/omarchy/releases/) folgt, sowie dem [stabilen Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror), der einen Monat hinter dem neuesten Stand liegt, damit wir neue Inkompatibilitäten, die Konfigurationsänderungen erfordern, abfangen können, bevor sie den Leuten Probleme bereiten.

Aber wenn du helfen möchtest, diese potenziellen Probleme aufzuspüren, kannst du auf dem edge-Kanal laufen. Damit folgen deine Omarchy-Pakete den neuesten Entwicklungs-Builds, und du kannst auf die neuesten Arch-Pakete aktualisieren, sobald sie verfügbar sind. Du solltest das nur tun, wenn du Erfahrung mit Linux hast und weißt, wie du ein System wiederherstellst, das Probleme hat.

Vor jeder neuen größeren Version führen wir die abschließende Validierung über den RC-Kanal durch. Wenn du Interesse hast, beim letzten Feinschliff zu helfen, schau in #omarchy-release-candidates auf dem Discord vorbei.

Schließlich gibt es den dev-Kanal, der Omarchy direkt mit einem git-Checkout des Quellcodes in `~/omarchy` verknüpft, kombiniert mit den edge-Paketen. Du solltest diesen Kanal nur verwenden, wenn du ein erfahrener Linux-Nutzer bist, direkt an Omarchy arbeitest und bereit bist, kaputte Dinge in Kauf zu nehmen.

Du kannst über _Update > Channel_ im Omarchy-Menü (oder `omarchy-channel-set` im Terminal) zwischen den Kanälen wechseln.

### Kernel wechseln

Omarchy bootet seinen eigenen `linux-omarchy`-Kernel, aber du kannst andere daneben installiert lassen, etwa den Standard-Arch-Kernel `linux` oder einen experimentellen Build, den du gerade testest. Wenn mehr als einer vorhanden ist, listet _Update > Kernel_ im Omarchy-Menü sie mit einem Häkchen neben demjenigen auf, der standardmäßig bootet. Wähle einen anderen aus, gib einmal dein Passwort ein, und er bootet nach dem nächsten Neustart. Die anderen Kernel bleiben im Boot-Menü, sodass du weiterhin von Hand einen auswählen kannst, falls der neue Standard dir Probleme macht. Im Terminal ist es `omarchy-kernel`, um den aktuellen Standard zu sehen, `omarchy-kernel list` für das, was installiert ist, und `omarchy-kernel set <kernel>`, um zu wechseln.

### Firmware-Updates

Deine Pakete sind nicht das Einzige, was veraltet. Viele Laptops und Peripheriegeräte erhalten BIOS-, SSD- und Dock-Firmware über den Linux Vendor Firmware Service, und _Update > Firmware_ im Omarchy-Menü holt und installiert, was auch immer für deine Hardware bereitliegt. Beim ersten Ausführen wird `fwupd` installiert. Viele Firmware kann nur während eines Neustarts geschrieben werden, also wundere dich nicht, wenn du zu einem aufgefordert wirst.

### Warnung vor direkten pacman/yay-Updates

Wenn du dich schon mit Arch auskennst, könntest du versucht sein, einfach selbst `pacman -Syu` oder `yay -Syu` auszuführen, aber wenn du das tust, verpasst du den Snapshot, die Migrationen und die Konfigurations-Updates, die Omarchy zusammen mit neuen Paketen ausführt. Deshalb stoppt Omarchy ein direktes System-Upgrade tatsächlich und verweist dich stattdessen auf `omarchy update`. (Wenn du wirklich weißt, was du tust, sagt dir der Schutz, wie du ihn für eine einzelne Transaktion umgehen kannst.)

### Schlechte Updates zurückrollen

Wenn du nach einem Update jemals ein Problem hast, kannst du dein System auf den Snapshot zurückrollen, der vor dem Update erstellt wurde. Starte einfach neu und wähle im Boot-Menü den Snapshot aus der Zeit, bevor du das Update gestartet hast.

![bootloader](images/bootloader.webp)

Falls deine Konfigurationsdateien irgendwie beschädigt wurden, kannst du mit `omarchy reinstall` im Terminal auch eine Omarchy-Neuinstallation durchführen. Dadurch werden alle Standard-Omarchy-Pakete neu installiert, du wirst auf stable gesetzt, alle Pakete, die zu neu sind, werden herabgestuft, und alle Konfigurationsdateien werden zurückgesetzt. Beachte, dass dabei alle deine Benutzeränderungen an den Omarchy-Standards überschrieben werden!
