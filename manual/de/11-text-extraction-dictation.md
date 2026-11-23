# Textextraktion & Diktat

### Textextraktion

Drücke `Super + Ctrl + PrtScr`, um einen Bereich auf dem Bildschirm für die Textextraktion auszuwählen. Das Open-Source-OCR-Modell tesseract wandelt diese Auswahl dann schnell in Text um und legt ihn in die Zwischenablage. Dann drückst du einfach `Super + V`, um ihn einzufügen.

Das ist sehr hilfreich, um Adressen aus Fußzeilen von Bildern oder Telefonnummern zu erfassen, die in Überschriften auf Websites eingebettet sind.

 ![text-extraction](images/text-extraction.webp)

### Diktat

Bei frischen Installationen ist [Superwhisper](https://superwhisper.com/) das Standard-Backend für das Diktieren und nutzt Cloud-Verarbeitung ohne Downloads von Offline-Modellen. Wähle Superwhisper, [Voxtype](https://voxtype.io/) oder [Hex](https://anoma.ly/hex/) über _Setup > Defaults > Dictation_ im Omarchy-Menü. Durch die Auswahl eines Backends wird es bei Bedarf installiert und als Standard für das Diktieren festgelegt. Voxtype lädt ein englisches Basismodell, das 150MB belegt; ändere das Modell mit `voxtype setup model` und andere Einstellungen über `~/.config/voxtype/config.toml`. Superwhisper öffnet seine Einstellungen, um zwischen Cloud- und lokaler Verarbeitung zu wählen, und OPR hält die Anwendung aktuell. Hex lädt sein Sprachmodell zur Verarbeitung auf dem Gerät während der Einrichtung herunter und läuft als `hex.service` User-Service; öffne sein Fenster über das Tray-Symbol in der Leiste oder durch Ausführen von `hex`, um das Modell und andere Einstellungen zu ändern.

Du diktierst, indem du `Right Alt` gedrückt hältst oder mit `Alt + Space` umschaltest, und der diktierte Text erscheint im fokussierten Eingabebereich. Diese Tastaturkürzel nutzen das ausgewählte Backend. Right Alt startet das Diktat auch, wenn es in einer Modifier-Kombination verwendet wird; nutze Left Alt für diese Kombinationen. Bei Tastaturlayouts, bei denen Right Alt als AltGr dient, auch wenn ein solches Layout eines ist, zu dem du wechselst, halte es für einen Moment allein gedrückt, um zu diktieren; AltGr gibt, zusammen mit einer anderen Taste gedrückt, weiterhin sein Zeichen ein. Installationen aus der Zeit, bevor Alt + Space zum Standard wurde, behalten `F9` für Push-to-Talk und `Super + Ctrl + X` zum Umschalten, hinzugefügt zu `~/.config/hypr/bindings.lua`, wo dieses `Super + Ctrl + X` an die Stelle des Agents-Panels tritt; entferne sie dort, um diese Tasten wieder an Anwendungen und das Panel zurückzugeben.

Dieselben Tastaturkürzel funktionieren mit jedem Backend. Wähle dein Backend über Setup > Defaults > Dictation. Der Backend-Installer konfiguriert es und speichert die Auswahl. Führe `omarchy default dictation` aus, um zu sehen, welches ausgewählt ist. Die Auswahl wird in `~/.config/omarchy/defaults/dictation` gespeichert. Frische Installationen wählen Superwhisper automatisch aus.

Omarchy lädt die Desktop-Integration des ausgewählten Backends automatisch. In `~/.config/hypr/` ist keine Superwhisper-Konfiguration nötig.

Benutzerdefinierte Bindings und Skripte können `omarchy dictation start`, `omarchy dictation stop` und `omarchy dictation toggle` nutzen. Das ausgewählte Backend übernimmt die Aufnahme und Transkription. Die Auswahl von Superwhisper deaktiviert sein natives Kürzel zum Gedrückthalten und setzt seine native Umschaltung auf `Ctrl + Alt + Space`, sodass sie von Omarchys Aufnahmetasten getrennt bleibt. Superwhisper erfordert mindestens ein natives Aufnahmekürzel, und sein Kürzel zum Abbrechen bleibt verfügbar.

Zusätzliche Backends können sich ohne Änderung an Omarchy integrieren. Stelle eine ausführbare Datei mit dem Namen `omarchy-dictation-<backend>` im PATH bereit, die `start`, `stop` und `toggle` akzeptiert und umgehend zurückkehrt, mit einem Status ungleich Null im Fehlerfall. Ihr Installer konfiguriert den Provider und ruft nach erfolgreicher Einrichtung `omarchy-dictation-use <backend>` auf. Dies stoppt das vorherige Backend und speichert die Auswahl atomar; `stop` muss erfolgreich sein, wenn der Provider im Leerlauf oder nicht verfügbar ist. Backend-Namen verwenden Kleinbuchstaben, Ziffern und Bindestriche. Stelle `omarchy-install-dictation-<backend>` für die Einrichtung bereit; `omarchy default dictation <backend>` startet ihn. Füge über eine Omarchy-Menüerweiterung einen Eintrag im Defaults-Menü hinzu, um diesen Selektor aufzurufen. Optionale Desktop-Integration kann in `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua` liegen.
