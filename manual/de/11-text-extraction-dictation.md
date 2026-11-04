# Textextraktion & Diktat

### Textextraktion

Drücke `Super + Ctrl + PrtScr`, um einen Bereich auf dem Bildschirm für die Textextraktion auszuwählen. Das Open-Source-OCR-Modell tesseract wandelt diese Auswahl dann schnell in Text um und legt ihn in die Zwischenablage. Dann drückst du einfach `Super + V`, um ihn einzufügen.

Das ist sehr hilfreich, um Adressen aus Fußzeilen von Bildern oder in Überschriften von Websites eingebettete Telefonnummern zu übernehmen.

 ![text-extraction](images/text-extraction.webp)

### Diktat

Bei Neuinstallationen ist [Superwhisper](https://superwhisper.com/) das Standard-Backend für das Diktat, mit Cloud-Verarbeitung ohne Downloads von Offline-Modellen. Wähle Superwhisper, [Voxtype](https://voxtype.io/) oder [Hex](https://anoma.ly/hex/) über _Setup > Defaults > Dictation_ im Omarchy-Menü. Die Auswahl eines Backends installiert es bei Bedarf und macht es zum Standard für das Diktat. Voxtype lädt ein englisches Basismodell, das 150MB belegt; ändere das Modell mit `voxtype setup model` und andere Einstellungen über `~/.config/voxtype/config.toml`. Superwhisper öffnet seine Einstellungen, um zwischen Cloud- und lokaler Verarbeitung zu wählen, und OPR hält die Anwendung aktuell. Hex lädt sein Sprachmodell für die Verarbeitung auf dem Gerät während der Einrichtung herunter und läuft als User-Service `hex.service`; öffne sein Fenster über das Tray-Symbol in der Leiste oder indem du `hex` ausführst, um das Modell und andere Einstellungen zu ändern.

Du diktierst, indem du `Right Alt` gedrückt hältst oder mit `Alt + Space` umschaltest, und der diktierte Text erscheint im fokussierten Eingabebereich. Diese Tastenkombinationen verwenden das ausgewählte Backend. Right Alt startet das Diktat auch, wenn es in einer Modifier-Kombination verwendet wird; verwende für diese Kombinationen Left Alt. Verwende auf Tastaturlayouts, bei denen Right Alt AltGr ist, `Alt + Space`, damit AltGr weiterhin zum Tippen verfügbar bleibt. Installationen von vor der Zeit, als Alt + Space zum Standard wurde, behalten `F9` für Push-to-Talk und `Super + Ctrl + X` zum Umschalten, hinzugefügt zu `~/.config/hypr/bindings.lua`; entferne sie dort, um diese Tasten wieder den Anwendungen zu überlassen.

Dieselben Tastenkombinationen funktionieren mit jedem Backend. Wähle dein Backend über Setup > Defaults > Dictation. Das Installationsprogramm des Backends konfiguriert es und speichert die Auswahl. Führe `omarchy default dictation` aus, um zu sehen, welches ausgewählt ist. Die Auswahl wird in `~/.config/omarchy/defaults/dictation` gespeichert. Neuinstallationen wählen Superwhisper automatisch aus.

Omarchy lädt die Desktop-Integration des ausgewählten Backends automatisch. In `~/.config/hypr/` ist keine Superwhisper-Konfiguration nötig.

Benutzerdefinierte Tastenzuordnungen und Skripte können `omarchy dictation start`, `omarchy dictation stop` und `omarchy dictation toggle` verwenden. Das ausgewählte Backend übernimmt Aufnahme und Transkription. Die Auswahl von Superwhisper deaktiviert seine native Halte-Tastenkombination und setzt seine native Umschalt-Tastenkombination auf `Ctrl + Alt + Space`, sodass sie getrennt von Omarchys Aufnahmetasten bleibt. Superwhisper erfordert mindestens eine native Aufnahme-Tastenkombination, und seine Abbruch-Tastenkombination bleibt verfügbar.

Zusätzliche Backends können sich integrieren, ohne Omarchy zu ändern. Stelle eine ausführbare Datei namens `omarchy-dictation-<backend>` im PATH bereit, die `start`, `stop` und `toggle` akzeptiert, umgehend zurückkehrt und bei einem Fehler einen von Null verschiedenen Status zurückgibt. Ihr Installationsprogramm konfiguriert den Anbieter und ruft nach erfolgreicher Einrichtung `omarchy-dictation-use <backend>` auf. Dadurch wird das vorherige Backend gestoppt und die Auswahl atomar gespeichert; `stop` muss erfolgreich sein, wenn der Anbieter im Leerlauf oder nicht verfügbar ist. Backend-Namen verwenden Kleinbuchstaben, Ziffern und Bindestriche. Stelle `omarchy-install-dictation-<backend>` für die Einrichtung bereit; `omarchy default dictation <backend>` startet es. Füge über eine Omarchy-Menüerweiterung einen Eintrag im Defaults-Menü hinzu, der diese Auswahlfunktion aufruft. Optionale Desktop-Integration kann in `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua` liegen.
