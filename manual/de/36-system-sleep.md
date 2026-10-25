# Ruhezustand des Systems

Omarchy aktiviert standardmäßig den Bereitschaftsmodus und den Ruhezustand, aber wenn du Probleme mit einem von beiden auf deinem Rechner hast, kannst du sie deaktivieren.

Auf NVIDIA GB10-Rechnern wie der DGX Spark und dem ASUS Ascent GX10 sind der Bereitschaftsmodus und der Ruhezustand deaktiviert, genau wie in NVIDIAs DGX OS, weil noch nicht nachgewiesen wurde, dass der Ruhezustand auf dieser Hardware funktioniert. Der Schalter für den Bereitschaftsmodus und die Einrichtung des Ruhezustands gelten dort nicht. Um den Ruhezustand wieder einzuschalten, entferne `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` mit `sudo rm`; Suspend erscheint dann wieder im Menü, und der Ruhezustand kann wie auf anderen Rechnern eingerichtet werden. Wenn du `sudo omarchy apply hardware --install-user "$USER"` ausführst, wird die Datei wiederhergestellt.

### Energieprofile

Auf einem Laptop merkt sich Omarchy dein Energieprofil getrennt für den Betrieb am Netzstrom und im Akkubetrieb und wechselt zwischen beiden, wenn du das Netzteil ein- oder aussteckst. Standardmäßig bedeutet das Leistung bei Netzstrom und Ausgewogen im Akkubetrieb.

Du kannst dir mit `omarchy powerprofiles list` anzeigen lassen, was dein Rechner anbietet, und mit `omarchy powerprofiles set autodetect power-saver` das gewünschte Profil für den Zustand festlegen, in dem du dich gerade befindest. Um den anderen Zustand festzulegen, ohne irgendetwas auszustecken, benenne ihn direkt: `omarchy powerprofiles set battery power-saver`. Was auch immer du auswählst, bekommst du beim nächsten Mal in diesem Zustand wieder.

### Bereitschaftsmodus umschalten

Du schaltest den Bereitschaftsmodus um, indem du `omarchy toggle suspend` im Terminal ausführst. Dadurch wird die Option unter _System_ (oder `Super + Esc`) nur ein- bzw. ausgeblendet, und dann kannst du sehen, ob sie auf deinem System zuverlässig funktioniert. Wenn nicht, kannst du sie mit demselben Befehl wieder ausblenden.

### Ruhezustand umschalten

Du richtest den Ruhezustand ein, indem du `omarchy hibernation setup` im Terminal ausführst. Der Ruhezustand erstellt ein /swap-Subvolume auf deinem Boot-Laufwerk in der Größe deiner physischen RAM-Ausstattung, also stelle sicher, dass du reichlich freien Platz hast. Auf einem 32GB-Rechner brauchst du für dieses Volume immer 32GB+ frei. Der Ruhezustand erfordert außerdem den standardmäßigen Limine-Bootloader.

Wenn er eingerichtet ist, siehst du die Option für den Ruhezustand unter _System_ (oder `Super + Esc`), und dann kannst du sehen, ob er auf deinem System zuverlässig funktioniert. Wenn nicht, kannst du ihn wieder entfernen, indem du `omarchy hibernation remove` ausführst.
