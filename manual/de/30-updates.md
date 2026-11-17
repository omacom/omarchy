# Aktualisierungen

Omarchy und deine Pakete hältst du über _Update > Omarchy_ im Omarchy-Menü (`Super + Space`) auf dem neuesten Stand.

Omarchy selbst wird als reguläre pacman-Pakete aus dem [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs) installiert, sodass eine Aktualisierung [die neueste Omarchy-Version](https://github.com/omacom/omarchy/releases) installiert, alle ausstehenden Migrationen ausführt, um dein System mit der neuesten Version in Einklang zu bringen, und alle Systempakete aus dem [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) und der [AUR](https://aur.archlinux.org/) aktualisiert (falls du AUR-Pakete installiert hast).

Wenn neue Versionen erscheinen, wird rechts neben deiner Uhr ein Symbol mit einem kreisförmigen Pfeil angezeigt. Klicke darauf, und der Aktualisierungsvorgang startet.

![update-available](images/update-available.webp)

### Vier Kanäle

Omarchy wird über vier Kanäle aktualisiert: stable, RC, edge und dev. Neue Installationen starten auf dem stable-Kanal, der den [offiziellen Versionen](https://github.com/omacom/omarchy/releases/) folgt, sowie dem [stabilen Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror), der einen Monat hinter dem neuesten Stand zurückliegt, damit wir alle neuen Inkompatibilitäten, die Konfigurationsänderungen erfordern, abfangen können, bevor sie den Leuten Probleme bereiten.

Wenn du aber dabei helfen möchtest, diese potenziellen Probleme aufzuspüren, kannst du den edge-Kanal verwenden. Dadurch folgen deine Omarchy-Pakete den neuesten Entwicklungs-Builds, und du kannst auf die neuesten Arch-Pakete aktualisieren, sobald sie verfügbar sind. Tu das nur, wenn du Erfahrung mit Linux hast und weißt, wie man ein System mit Problemen wiederherstellt.

Vor jeder neuen größeren Version führen wir die abschließende Validierung über den RC-Kanal durch. Wenn du beim letzten Feinschliff helfen möchtest, schau in #omarchy-release-candidates auf dem Discord vorbei.

Schließlich gibt es den dev-Kanal, der Omarchy direkt mit einem git-Checkout des Quellcodes in `~/omarchy` verknüpft, kombiniert mit den edge-Paketen. Du solltest diesen Kanal nur verwenden, wenn du ein erfahrener Linux-Nutzer bist, direkt an Omarchy arbeitest und bereit bist, Bruch in Kauf zu nehmen.

Du kannst über _Update > Channel_ im Omarchy-Menü (oder `omarchy-channel-set` im Terminal) zwischen den Kanälen wechseln.

### Kernel wechseln

Omarchy startet seinen eigenen `linux-omarchy`-Kernel, aber du kannst daneben andere installiert lassen, etwa den Standard-Arch-Kernel `linux` oder einen experimentellen Build, den du gerade testest. Wenn mehr als einer vorhanden ist, listet _Update > Kernel_ im Omarchy-Menü sie mit einem Häkchen neben demjenigen auf, der standardmäßig startet. Wähle einen anderen aus, gib einmal dein Passwort ein, und er startet nach dem nächsten Neustart. Die anderen Kernel bleiben im Boot-Menü, sodass du trotzdem von Hand einen auswählen kannst, falls dir der neue Standard Ärger macht. Im Terminal siehst du mit `omarchy-kernel` den aktuellen Standard, mit `omarchy-kernel list`, was installiert ist, und mit `omarchy-kernel set <kernel>` wechselst du.

### Firmware-Aktualisierungen

Nicht nur deine Pakete werden veraltet. Viele Laptops und Peripheriegeräte liefern BIOS-, SSD- und Dock-Firmware über den Linux Vendor Firmware Service aus, und _Update > Firmware_ im Omarchy-Menü holt und installiert alles, was für deine Hardware bereitliegt. Beim ersten Ausführen installiert es `fwupd`. Viel Firmware kann nur während eines Neustarts geschrieben werden, also wundere dich nicht, wenn du zu einem aufgefordert wirst.

Wenn du eine Einstellung im BIOS selbst ändern musst, halte `Alt` im Systemmenü (`Super + Escape`) gedrückt, und _Reboot_ wird zu _Reboot to BIOS_, was direkt in die Firmware-Einrichtung neu startet, ohne dass du beim Booten die richtige Taste erwischen musst. Im Terminal geht das mit `omarchy system firmware`.

### Warnung vor direkten pacman/yay-Aktualisierungen

Wenn du dich schon mit Arch auskennst, könntest du versucht sein, einfach selbst `pacman -Syu` oder `yay -Syu` auszuführen, aber wenn du das tust, verpasst du den Snapshot, die Migrationen und die Konfigurationsaktualisierungen, die Omarchy zusammen mit neuen Paketen ausführt. Deshalb stoppt Omarchy eine direkte Systemaktualisierung tatsächlich und verweist dich stattdessen auf `omarchy update`. (Wenn du wirklich weißt, was du tust, sagt dir die Schutzfunktion, wie du sie für eine einzelne Transaktion umgehen kannst.)

### Schlechte Aktualisierungen zurücksetzen

Falls du nach einer Aktualisierung jemals ein Problem hast, kannst du dein System auf den Snapshot zurücksetzen, der vor der Aktualisierung erstellt wurde. Starte einfach neu und wähle im Boot-Lademenü den Snapshot von vor dem Start der Aktualisierung aus.

![bootloader](images/bootloader.webp)

Falls deine Konfigurationsdateien irgendwie beschädigt wurden, kannst du mit `omarchy reinstall` im Terminal auch eine Omarchy-Neuinstallation durchführen. Dadurch werden alle standardmäßigen Omarchy-Pakete neu installiert, du wirst auf stable gesetzt und alle Pakete, die zu neu sind, werden herabgestuft, und alle Konfigurationsdateien werden zurückgesetzt. Beachte, dass dabei alle deine Benutzer-Konfigurationsänderungen an den Omarchy-Standards überschrieben werden!
