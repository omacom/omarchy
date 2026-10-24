# System-Sleep

Omarchy aktiviert Standby und Ruhezustand standardmäßig, aber wenn du auf deinem Rechner Probleme damit hast, kannst du sie ausschalten.

### Energieprofile

Auf einem Laptop merkt sich Omarchy dein Energieprofil getrennt für Netzbetrieb und Akkubetrieb und wechselt beim Ein- und Ausstecken zwischen beiden. Von Anfang an bedeutet das Leistung am Netz und Ausgewogen im Akkubetrieb.

Was dein Rechner anbietet, siehst du mit `omarchy powerprofiles list`, und mit `omarchy powerprofiles set autodetect power-saver` setzt du das Profil für den Zustand, in dem du gerade bist. Um den anderen Zustand zu setzen, ohne etwas auszustecken, nenn ihn direkt: `omarchy powerprofiles set battery power-saver`. Was du wählst, bekommst du beim nächsten Mal in diesem Zustand wieder.

### Standby umschalten

Standby schaltest du um, indem du `omarchy toggle suspend` im Terminal ausführst. Das zeigt die Option unter _System_ (oder `Super + Esc`) nur an oder versteckt sie, und dann kannst du sehen, ob sie auf deinem System zuverlässig funktioniert. Falls nicht, versteckst du sie mit demselben Befehl wieder.

### Ruhezustand umschalten

Den Ruhezustand richtest du ein, indem du `omarchy hibernation setup` im Terminal ausführst. Der Ruhezustand erstellt auf deiner Bootplatte ein /swap-Subvolume in der Größe deines physischen RAM, also stelle sicher, dass du reichlich Platz übrig hast. Auf einem Rechner mit 32GB brauchst du für dieses Volume immer mehr als 32GB frei. Der Ruhezustand erfordert außerdem den Standard-Bootloader Limine.

Wenn er eingerichtet ist, siehst du die Option für den Ruhezustand unter _System_ (oder `Super + Esc`), und dann kannst du sehen, ob sie auf deinem System zuverlässig funktioniert. Falls nicht, entfernst du sie wieder mit `omarchy hibernation remove`.
