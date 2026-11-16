# Textextraktion & Diktieren

### Textextraktion

Drücke `Super + Ctrl + PrtScr`, um einen Bereich auf dem Bildschirm für die Textextraktion auszuwählen. Das quelloffene OCR-Modell tesseract wandelt diese Auswahl dann schnell in Text um und legt ihn in die Zwischenablage. Dann drückst du einfach `Super + V` zum Einfügen.

Das ist sehr hilfreich, um Adressen aus Bildfußzeilen oder Telefonnummern zu übernehmen, die in Überschriften auf Websites eingebettet sind.

 ![text-extraction](images/text-extraction.webp)

### Diktieren

Bei Neuinstallationen ist [Superwhisper](https://superwhisper.com/) das Standard-Backend für das Diktieren und nutzt Cloud-Verarbeitung ohne Downloads von Offline-Modellen. Wähle Superwhisper, [Voxtype](https://voxtype.io/) oder [Hex](https://anoma.ly/hex/) über _Setup > Defaults > Dictation_ im Omarchy-Menü. Beim Auswählen eines Backends wird es bei Bedarf installiert und als Standard für das Diktieren festgelegt. Voxtype lädt ein englisches Basismodell, das 150MB belegt; ändere das Modell mit `voxtype setup model` und andere Einstellungen über `~/.config/voxtype/config.toml`. Superwhisper öffnet seine Einstellungen, um Cloud- oder lokale Verarbeitung zu wählen, und OPR hält die Anwendung aktuell. Hex lädt sein On-Device-Sprachmodell während der Einrichtung herunter und läuft als User-Service `hex.service`; öffne sein Fenster über das Tray-Symbol in der Leiste oder durch Ausführen von `hex`, um das Modell und andere Einstellungen zu ändern.

Du diktierst, indem du `Right Alt` gedrückt hältst, oder indem du mit `Alt + Space` umschaltest, und der diktierte Text erscheint im fokussierten Eingabebereich. Diese Tastenkürzel nutzen das ausgewählte Backend. Right Alt startet das Diktieren auch, wenn es in einer Modifikatorkombination verwendet wird; verwende Left Alt für solche Kombinationen. Auf Tastaturlayouts, bei denen Right Alt AltGr ist, verwende `Alt + Space`, damit AltGr zum Tippen verfügbar bleibt. Installationen aus der Zeit, bevor Alt + Space zum Standard wurde, behalten `F9` für Push-to-Talk und `Super + Ctrl + X` zum Umschalten, hinzugefügt zu `~/.config/hypr/bindings.lua`, wo dieses `Super + Ctrl + X` den Platz des Agenten-Panels einnimmt; entferne sie dort, um diese Tasten wieder an Anwendungen und das Panel zurückzugeben.

Die gleichen Tastenkürzel funktionieren mit jedem Backend. Wähle dein Backend über Setup > Defaults > Dictation. Das Installationsprogramm des Backends konfiguriert es und speichert die Auswahl. Führe `omarchy default dictation` aus, um zu sehen, welches ausgewählt ist. Die Auswahl wird in `~/.config/omarchy/defaults/dictation` gespeichert. Neuinstallationen wählen automatisch Superwhisper.

Omarchy lädt die Desktop-Integration des ausgewählten Backends automatisch. In `~/.config/hypr/` ist keine Konfiguration für Superwhisper nötig.

Benutzerdefinierte Tastenkombinationen und Skripte können `omarchy dictation start`, `omarchy dictation stop` und `omarchy dictation toggle` verwenden. Das ausgewählte Backend übernimmt die Aufnahme und Transkription. Beim Auswählen von Superwhisper wird sein natives Halte-Tastenkürzel deaktiviert und sein natives Umschalt-Tastenkürzel auf `Ctrl + Alt + Space` gesetzt, sodass es getrennt von Omarchys Aufnahmetasten bleibt. Superwhisper erfordert mindestens ein natives Aufnahme-Tastenkürzel, und sein Abbrechen-Tastenkürzel bleibt verfügbar.

Weitere Backends können sich integrieren, ohne Omarchy zu ändern. Stelle eine ausführbare Datei namens `omarchy-dictation-<backend>` im PATH bereit, die `start`, `stop` und `toggle` akzeptiert und unverzüglich zurückkehrt, mit einem Status ungleich null bei einem Fehler. Ihr Installationsprogramm konfiguriert den Anbieter und ruft nach erfolgreicher Einrichtung `omarchy-dictation-use <backend>` auf. Dadurch wird das vorherige Backend gestoppt und die Auswahl atomar gespeichert; `stop` muss erfolgreich sein, wenn der Anbieter im Leerlauf oder nicht verfügbar ist. Backend-Namen verwenden Kleinbuchstaben, Ziffern und Bindestriche. Stelle `omarchy-install-dictation-<backend>` für die Einrichtung bereit; `omarchy default dictation <backend>` startet es. Füge über eine Omarchy-Menüerweiterung einen Eintrag in das Defaults-Menü ein, um diesen Selektor aufzurufen. Optionale Desktop-Integration kann in `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua` liegen.
