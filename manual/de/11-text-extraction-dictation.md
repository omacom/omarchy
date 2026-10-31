# Textextraktion & Diktieren

### Textextraktion

Drücke `Super + Ctrl + PrtScr`, um einen Bereich auf dem Bildschirm für die Textextraktion auszuwählen. Das Open-Source-OCR-Modell tesseract wird diese Auswahl dann schnell in Text umwandeln und in die Zwischenablage legen. Dann drückst du einfach `Super + V` zum Einfügen.

Das ist sehr hilfreich, um Adressen aus Bild-Fußzeilen zu greifen oder Telefonnummern, die in Überschriften auf Websites eingebettet sind.

 ![text-extraction](images/text-extraction.webp)

### Diktieren

Bei Neuinstallationen ist [Superwhisper](https://superwhisper.com/) das Standard-Backend für das Diktieren und nutzt Cloud-Verarbeitung ohne Downloads von Offline-Modellen. Wähle Superwhisper oder [Voxtype](https://voxtype.io/) über _Setup > Defaults > Dictation_ im Omarchy-Menü. Die Auswahl eines Backends installiert es bei Bedarf und macht es zum Standard für das Diktieren. Voxtype lädt ein englisches Basismodell, das 150MB belegt; ändere das Modell mit `voxtype setup model` und weitere Einstellungen über `~/.config/voxtype/config.toml`. Superwhisper öffnet seine Einstellungen, um zwischen Cloud- und lokaler Verarbeitung zu wählen, und OPR hält die Anwendung aktuell.

Du diktierst, indem du `Right Alt` gedrückt hältst oder mit `Alt + Space` umschaltest, und der diktierte Text erscheint im fokussierten Eingabebereich. Diese Tastenkombinationen nutzen das ausgewählte Backend. Right Alt startet das Diktieren auch, wenn es in einer Modifikatorkombination verwendet wird; nutze für diese Kombinationen Left Alt. Bei Tastaturlayouts, bei denen Right Alt AltGr ist, nutze `Alt + Space`, damit AltGr weiterhin zum Tippen verfügbar bleibt. Installationen aus der Zeit, bevor Alt + Space zum Standard wurde, behalten `F9` für Push-to-Talk und `Super + Ctrl + X` zum Umschalten, hinzugefügt zu `~/.config/hypr/bindings.lua`; entferne sie dort, um diese Tasten wieder an Anwendungen zurückzugeben.

Dieselben Tastenkombinationen funktionieren mit beiden Backends. Wähle dein Backend über Setup > Defaults > Dictation aus. Der Backend-Installer konfiguriert es und speichert die Auswahl. Führe `omarchy default dictation` aus, um zu sehen, welches ausgewählt ist. Die Auswahl wird in `~/.config/omarchy/defaults/dictation` gespeichert. Neuinstallationen wählen Superwhisper automatisch aus.

Omarchy lädt die Desktop-Integration des ausgewählten Backends automatisch. In `~/.config/hypr/` ist keine Superwhisper-Konfiguration erforderlich.

Benutzerdefinierte Bindings und Skripte können `omarchy dictation start`, `omarchy dictation stop` und `omarchy dictation toggle` verwenden. Das ausgewählte Backend übernimmt die Aufnahme und Transkription. Die Auswahl von Superwhisper deaktiviert seine native Halte-Tastenkombination und setzt seine native Umschalt-Tastenkombination auf `Ctrl + Alt + Space`, sodass sie getrennt von Omarchys Aufnahmetasten bleibt. Superwhisper erfordert mindestens eine native Aufnahme-Tastenkombination, und seine Tastenkombination zum Abbrechen bleibt verfügbar.

Zusätzliche Backends können sich integrieren, ohne Omarchy zu verändern. Stelle eine ausführbare Datei namens `omarchy-dictation-<backend>` auf PATH bereit, die `start`, `stop` und `toggle` akzeptiert und unverzüglich zurückkehrt, mit einem Status ungleich null bei einem Fehler. Ihr Installer konfiguriert den Provider und ruft nach erfolgreicher Einrichtung `omarchy-dictation-use <backend>` auf. Dies stoppt das vorherige Backend und speichert die Auswahl atomar; `stop` muss erfolgreich sein, wenn der Provider im Leerlauf oder nicht verfügbar ist. Backend-Namen verwenden Kleinbuchstaben, Ziffern und Bindestriche. Stelle `omarchy-install-dictation-<backend>` für die Einrichtung bereit; `omarchy default dictation <backend>` startet sie. Füge über eine Omarchy-Menüerweiterung einen Defaults-Menüeintrag hinzu, um diesen Selektor aufzurufen. Eine optionale Desktop-Integration kann in `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua` liegen.
