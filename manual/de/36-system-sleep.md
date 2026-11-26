# Ruhezustand

Omarchy aktiviert standardmäßig den Bereitschaftsmodus und den Ruhezustand, sobald er eingerichtet ist, aber wenn du mit einem der beiden auf deiner Maschine Probleme hast, kannst du sie deaktivieren.

Auf NVIDIA GB10-Maschinen wie dem DGX Spark und dem ASUS Ascent GX10 sind Bereitschaftsmodus und Ruhezustand deaktiviert, so wie in NVIDIAs DGX OS, weil der Ruhezustand auf dieser Hardware bislang nicht nachweislich funktioniert. Dasselbe gilt für das ASUS Zenbook A16 (UX3607OA), bei dem der Bereitschaftsmodus den Chip noch nicht vollständig in den Ruhezustand versetzt und über Nacht hängen bleiben kann. Der Umschalter für den Bereitschaftsmodus und die Einrichtung des Ruhezustands gelten dort nicht. Um den Ruhezustand wieder einzuschalten, entferne `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` mit `sudo rm`; Bereitschaft kehrt dann ins Menü zurück, und der Ruhezustand kann wie auf anderen Maschinen eingerichtet werden. Mit `sudo omarchy apply hardware --install-user "$USER"` wird die Datei wiederhergestellt.

### Energieprofile

Auf einem Laptop merkt sich Omarchy dein Energieprofil getrennt für den Netzbetrieb und den Akkubetrieb und wechselt beim Einstecken und Abstecken zwischen beiden. Ab Werk bedeutet das Leistung im Netzbetrieb und ausgewogen im Akkubetrieb.

Du siehst, was deine Maschine anbietet, mit `omarchy powerprofiles list`, und legst das gewünschte Profil für den Zustand, in dem du dich gerade befindest, mit `omarchy powerprofiles set autodetect power-saver` fest. Um den anderen Zustand festzulegen, ohne irgendetwas abzustecken, nenne ihn direkt: `omarchy powerprofiles set battery power-saver`. Was auch immer du auswählst, bekommst du beim nächsten Mal in diesem Zustand auch wieder.

### Bereitschaftsmodus umschalten

Du schaltest den Bereitschaftsmodus um, indem du `omarchy toggle suspend` im Terminal ausführst. Das zeigt/verbirgt nur die Option unter _System_ (oder `Super + Esc`), und dann kannst du sehen, ob sie auf deinem System zuverlässig funktioniert. Wenn nicht, kannst du sie mit demselben Befehl wieder ausblenden.

### Ruhezustand umschalten

Du richtest den Ruhezustand ein, indem du `omarchy hibernation setup` im Terminal ausführst (auf Apple Silicon Macs ist er nicht verfügbar). Der Ruhezustand erstellt ein /swap-Subvolume auf deinem Boot-Laufwerk in der Größe deines physischen RAM, stelle also sicher, dass du reichlich Platz übrig hast. Auf einer 32GB-Maschine brauchst du für dieses Volume immer 32GB+ frei. Der Ruhezustand erfordert außerdem den standardmäßigen Limine-Bootloader.

Wenn er eingerichtet ist, siehst du die Ruhezustand-Option unter _System_ (oder `Super + Esc`), und dann kannst du sehen, ob sie auf deinem System zuverlässig funktioniert. Wenn nicht, kannst du ihn wieder entfernen, indem du `omarchy hibernation remove` ausführst.
