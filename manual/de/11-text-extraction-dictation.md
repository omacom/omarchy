# Textextraktion & Diktat

### Textextraktion

Drücke `Super + Ctrl + PrtScr`, um einen Bereich auf dem Bildschirm für die Textextraktion auszuwählen. Das Open-Source-OCR-Modell Tesseract wandelt diese Auswahl dann schnell in Text um und legt ihn in die Zwischenablage. Dann drückst du einfach `Super + V` zum Einfügen.

Das ist sehr hilfreich, um Adressen aus Bild-Fußzeilen oder Telefonnummern zu greifen, die in Website-Überschriften eingebettet sind.

 ![text-extraction](images/text-extraction.webp)

### Diktat

Bei frischen Installationen ist [Superwhisper](https://superwhisper.com/) das Standard-Diktat-Backend und nutzt Cloud-Verarbeitung ohne Offline-Modell-Downloads. Wähle Superwhisper oder [Voxtype](https://voxtype.io/) über _Einrichtung > Standards > Diktat_ im Omarchy-Menü. Die Auswahl eines Backends installiert es bei Bedarf und macht es zum Standard für das Diktat. Voxtype lädt ein englisches Basismodell, das 150 MB beansprucht; ändere das Modell mit `voxtype setup model` und andere Einstellungen über `~/.config/voxtype/config.toml`. Superwhisper öffnet seine Einstellungen, um Cloud- oder lokale Verarbeitung zu wählen, und OPR hält die Anwendung aktuell.

Du diktierst, indem du `Right Alt` oder `F9` gedrückt hältst oder mit `Super + Ctrl + X` umschaltest, und der diktierte Text erscheint im fokussierten Eingabebereich. Diese Tastenkürzel verwenden das ausgewählte Backend. Right Alt startet das Diktat auch, wenn es in einem Modifikator-Akkord verwendet wird; verwende Left Alt für diese Akkorde. Auf Tastaturlayouts, auf denen Right Alt AltGr ist, verwende `F9`, um AltGr zum Tippen verfügbar zu halten.

Dieselben Tastenkürzel funktionieren mit beiden Backends. Wähle dein Backend über Einrichtung > Standards > Diktat. Der Backend-Installer konfiguriert es und speichert die Auswahl. Führe `omarchy default dictation` aus, um zu sehen, welches ausgewählt ist. Die Auswahl wird in `~/.config/omarchy/defaults/dictation` gespeichert. Frische Installationen wählen Superwhisper automatisch.

Omarchy lädt die Desktop-Integration des ausgewählten Backends automatisch. In `~/.config/hypr/` ist keine Superwhisper-Konfiguration nötig.

Benutzerdefinierte Zuordnungen und Skripte können `omarchy dictation start`, `omarchy dictation stop` und `omarchy dictation toggle` verwenden. Das ausgewählte Backend übernimmt die Aufnahme und Transkription. Die Auswahl von Superwhisper deaktiviert sein natives Halte-Tastenkürzel und setzt sein natives Umschalt-Tastenkürzel auf `Alt + Space`, sodass es von Omarchys Aufnahmetasten getrennt bleibt. Superwhisper erfordert mindestens ein natives Aufnahme-Tastenkürzel, und sein Abbruch-Tastenkürzel bleibt verfügbar.

Zusätzliche Backends können sich integrieren, ohne Omarchy zu ändern. Stelle eine ausführbare Datei namens `omarchy-dictation-<backend>` im PATH bereit, die `start`, `stop` und `toggle` akzeptiert und umgehend zurückkehrt, mit einem Status ungleich null bei einem Fehler. Ihr Installer konfiguriert den Anbieter und ruft nach erfolgreicher Einrichtung `omarchy-dictation-use <backend>` auf. Das stoppt das vorherige Backend und speichert die Auswahl atomar; `stop` muss erfolgreich sein, wenn der Anbieter im Leerlauf oder nicht verfügbar ist. Backend-Namen verwenden Kleinbuchstaben, Ziffern und Bindestriche. Stelle `omarchy-install-dictation-<backend>` für die Einrichtung bereit; `omarchy default dictation <backend>` startet es. Füge einen Standards-Menüeintrag über eine Omarchy-Menüerweiterung hinzu, um diesen Selektor aufzurufen. Optionale Desktop-Integration kann in `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua` leben.
