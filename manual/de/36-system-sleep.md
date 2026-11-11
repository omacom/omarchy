# Schlafmodus des Systems

Omarchy aktiviert Bereitschaft und Ruhezustand standardmäßig, aber wenn du mit einem von beiden Probleme auf deiner Maschine hast, kannst du sie ausschalten.

Auf NVIDIA GB10-Maschinen wie dem DGX Spark und dem ASUS Ascent GX10 sind Bereitschaft und Ruhezustand ausgeschaltet, wie auch in NVIDIAs DGX OS, weil noch nicht gezeigt wurde, dass Schlaf auf dieser Hardware funktioniert. Dasselbe gilt für das ASUS Zenbook A16 (UX3607OA), wo die Bereitschaft den Chip noch nicht vollständig in den Schlaf versetzt und über Nacht hängen bleiben kann. Der Bereitschafts-Schalter und die Ruhezustands-Einrichtung gelten dort nicht. Um den Schlaf wieder einzuschalten, entferne `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf` mit `sudo rm`; Bereitschaft kehrt dann ins Menü zurück, und der Ruhezustand kann wie auf anderen Maschinen eingerichtet werden. Das Ausführen von `sudo omarchy apply hardware --install-user "$USER"` stellt die Datei wieder her.

### Leistungsprofile

Auf einem Laptop merkt sich Omarchy dein Leistungsprofil getrennt für Netzbetrieb und Akkubetrieb und wechselt zwischen beiden, wenn du das Netzteil ein- oder aussteckst. Standardmäßig bedeutet das Leistung am Netz und ausgewogen im Akkubetrieb.

Was deine Maschine anbietet, siehst du mit `omarchy powerprofiles list`, und das gewünschte Profil für den Zustand, in dem du dich gerade befindest, stellst du mit `omarchy powerprofiles set autodetect power-saver` ein. Um den anderen Zustand einzustellen, ohne irgendetwas auszustecken, nenne ihn direkt: `omarchy powerprofiles set battery power-saver`. Was auch immer du auswählst, bekommst du beim nächsten Mal in diesem Zustand wieder.

### Bereitschaft umschalten

Du schaltest die Bereitschaft um, indem du `omarchy toggle suspend` im Terminal ausführst. Das zeigt/verbirgt nur die Option unter _System_ (oder `Super + Esc`), und dann kannst du sehen, ob sie auf deinem System zuverlässig funktioniert. Wenn nicht, kannst du sie mit demselben Befehl wieder verbergen.

### Ruhezustand umschalten

Du richtest den Ruhezustand ein, indem du `omarchy hibernation setup` im Terminal ausführst. Der Ruhezustand erstellt ein /swap-Subvolume auf deinem Boot-Laufwerk in der Größe deiner physischen RAM-Zuteilung, also stelle sicher, dass du reichlich Platz übrig hast. Auf einer 32GB-Maschine brauchst du für dieses Volume immer 32GB+ frei. Der Ruhezustand erfordert außerdem den Standard-Bootloader Limine.

Nach der Einrichtung siehst du die Ruhezustandsoption unter _System_ (oder `Super + Esc`), und dann kannst du sehen, ob sie auf deinem System zuverlässig funktioniert. Wenn nicht, kannst du sie wieder entfernen, indem du `omarchy hibernation remove` ausführst.
