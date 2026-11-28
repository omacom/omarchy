# Ruhezustand des Systems

Omarchy aktiviert den Bereitschaftsmodus standardmäßig und den Ruhezustand, sobald er eingerichtet ist, aber wenn du auf deiner Maschine Probleme mit einem von beiden hast, kannst du sie deaktivieren.

Auf NVIDIA GB10-Maschinen wie dem DGX Spark und dem ASUS Ascent GX10 sind Bereitschaftsmodus und Ruhezustand deaktiviert, genau wie in NVIDIAs DGX OS, weil noch nicht nachgewiesen wurde, dass der Ruhezustand auf dieser Hardware funktioniert. Der Schalter für den Bereitschaftsmodus und die Einrichtung des Ruhezustands gelten dort nicht. Um den Ruhezustand wieder einzuschalten, entferne `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` mit `sudo rm`; Bereitschaft erscheint dann wieder im Menü, und der Ruhezustand kann wie auf anderen Maschinen eingerichtet werden. Das Ausführen von `sudo omarchy apply hardware --install-user "$USER"` stellt die Datei wieder her.

### Energieprofile

Auf einem Laptop merkt sich Omarchy dein Energieprofil getrennt für den Netzbetrieb und den Akkubetrieb und wechselt zwischen den beiden, wenn du das Netzteil einsteckst und absteckst. Standardmäßig bedeutet das Leistung im Netzbetrieb und Ausgewogen im Akkubetrieb.

Mit `omarchy powerprofiles list` kannst du sehen, was deine Maschine anbietet, und mit `omarchy powerprofiles set autodetect power-saver` das gewünschte Profil für den Zustand festlegen, in dem du dich gerade befindest. Um den anderen Zustand festzulegen, ohne irgendetwas abzustecken, gib ihn direkt an: `omarchy powerprofiles set battery power-saver`. Was auch immer du auswählst, bekommst du beim nächsten Mal in diesem Zustand wieder.

### Bereitschaftsmodus ein-/ausschalten

Du schaltest den Bereitschaftsmodus um, indem du `omarchy toggle suspend` im Terminal ausführst. Dadurch wird die Option unter _System_ (oder `Super + Esc`) nur ein- bzw. ausgeblendet, und dann kannst du sehen, ob sie auf deinem System zuverlässig funktioniert. Wenn nicht, kannst du sie mit demselben Befehl wieder ausblenden.

### Ruhezustand ein-/ausschalten

Du richtest den Ruhezustand ein, indem du `omarchy hibernation setup` im Terminal ausführst (auf Apple Silicon Macs ist er nicht verfügbar). Der Ruhezustand erstellt ein /swap-Subvolume auf deinem Boot-Laufwerk in der Größe deines physischen RAM, stelle also sicher, dass du reichlich Platz übrig hast. Auf einer Maschine mit 32GB brauchst du für dieses Volume immer 32GB+ freien Speicher. Der Ruhezustand erfordert außerdem den Standard-Bootloader Limine.

Nach der Einrichtung siehst du die Option für den Ruhezustand unter _System_ (oder `Super + Esc`), und dann kannst du sehen, ob sie auf deinem System zuverlässig funktioniert. Wenn nicht, kannst du sie durch Ausführen von `omarchy hibernation remove` wieder entfernen.
