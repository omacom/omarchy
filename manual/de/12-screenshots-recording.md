# Screenshots & Aufnahme

Alles, was du vom Bildschirm greifen kannst, hängt an der Print Screen-Taste. Eine Taste allein macht ein Bild, und die Modifikatoren machen eine Aufnahme, eine Farbe oder den Text in einem Bereich. Wenn deine Tastatur überhaupt keine Print Screen-Taste hat, macht `Super + Ctrl + Alt + C` denselben Screenshot, und `Super + Ctrl + C` öffnet das ganze Set als Menü.

| Hotkey | Funktion |
| ------ | -------- |
| `Print Screen` | Screenshot |
| `Super + Ctrl + Alt + C` | Screenshot |
| `Alt + Print Screen` | Bildschirmaufnahme (oder die laufende stoppen) |
| `Super + Print Screen` | Farbwähler |
| `Super + Ctrl + Print Screen` | Text aus einem Bereich extrahieren |
| `Super + Ctrl + C` | Aufnahme-Menü |
| `Super + Ctrl + .` | Ein Bild oder Video transkodieren |

## Screenshots

Drücke `Print Screen` (oder `Super + Ctrl + Alt + C`), und Omasnap erfasst den fokussierten Monitor, bevor sein Overlay erscheint, sodass sich nichts unter dir verschiebt, während du zielst. Ziehe einen Freiform-Bereich auf, klicke auf ein Fenster, um es aufzunehmen, oder klicke auf freien Raum, um den ganzen Monitor aufzunehmen. Drücke `S`, bevor du zeichnest, um einen scrollenden Bereich aufzunehmen. Anders überlegt? Drücke dieselbe Taste noch einmal, um Omasnap zu schließen.

Nachdem du einen Bereich ausgewählt hast, speichert Omasnap die Aufnahme, kopiert sie in die Zwischenablage und zeigt eine Benachrichtigung mit ihrem Vorschaubild, genau wie eine gespeicherte Bildschirmaufnahme. Wähle Open, um den gespeicherten Shot in deinem Bildbetrachter anzusehen, oder Edit, um ihn zu kommentieren.

Der Annotations-Editor kann Pfeile, Linien, Formen, Hervorhebungen, nummerierte Markierungen, Text und sichere Schwärzungen zeichnen; einen Teil des Bildes zuschneiden oder herausschneiden; seinen Text per OCR erkennen; und einen Hintergrund hinzufügen. Drücke im Editor `Enter`, um die fertige PNG zu kopieren und zu speichern, `Ctrl + C`, um sie ohne Speichern zu kopieren, oder `Ctrl + S`, um sie ohne Kopieren zu speichern.

Gespeicherte Screenshots landen standardmäßig in `~/Pictures/Screenshots`, mit einem Namen wie `screenshot-2026-08-13_14-22-05-firefox.png`. Setze `OMASNAP_SCREENSHOT_DIR`, um ein anderes Verzeichnis zu verwenden — siehe [die FAQ](46-faq.md), wo du Umgebungsvariablen für die Sitzung einträgst. Omasnap erstellt das Verzeichnis, wenn es den ersten Shot speichert. Setze `[output] autosave = false` in `~/.config/omasnap/omasnap.conf`, um das automatische Speichern zu deaktivieren; Aufnahmen werden dann nur kopiert und in einer Vorschau für 10 Sekunden gezeigt, die du mit ihrem Pin-Button oder `Ctrl + P` auf dem Bildschirm halten kannst.

Vom Terminal aus öffnet `omarchy screenshot` dasselbe Overlay, und du kannst seinen Startmodus wählen: `omarchy capture screenshot region`, `windows`, `fullscreen` oder `scroll`. Ein zweites Argument `copy` oder `save` schickt den Shot direkt an dieses Ziel. Um vor der Ausgabe zu bearbeiten, verwende `omarchy screenshot --editor=overlay` für einen Vollbild-Editor oder `omarchy screenshot --editor=window` für ein separates Fenster.

### Den Picker per Tastatur steuern

Solange die Auswahl oben ist, musst du die Maus überhaupt nicht benutzen:

| Taste | Funktion |
| --- | -------- |
| `S` | Scroll-Bereich-Modus umschalten |
| `Super + Arrow keys` | Zwischen Fenstern im Window-Modus wechseln |
| `Return` | Das hervorgehobene Fenster aufnehmen |
| `Ctrl + A` | Den ganzen fokussierten Monitor aufnehmen |
| `R` | Den letzten in dieser Sitzung gezeichneten Bereich wiederherstellen |
| `Esc` | Omasnap schließen |

Diese Bindungen existieren nur, solange Omasnap offen ist, also können sie mit nichts in deiner eigenen Config kollidieren.

## Bildschirmaufnahme

`Alt + Print Screen` öffnet _Trigger > Capture > Screenrecord_, das fragt, was du auf der Tonspur haben willst: kein Audio, Desktop-Audio, Desktop plus Mikrofon oder Desktop plus Mikrofon plus Webcam. Die letzte Option taucht nur auf, wenn du tatsächlich eine Kamera angeschlossen hast. Wähle eine, und Omarchys Aufnahme-Picker lässt dich einen Bereich aufziehen oder auf ein Fenster oder einen Monitor klicken.

Die Aufnahme läuft auf gpu-screen-recorder, der auf der GPU mit 60fps kodiert und notfalls auf die CPU zurückfällt. Das Ergebnis ist eine MP4 in `~/Videos` mit dem Namen `screenrecording-2026-08-13_14-22-05.mp4`. Setze `OMARCHY_SCREENRECORD_DIR`, um das zu ändern — aber beachte: Anders als das Screenshot-Verzeichnis muss dieses bereits existieren, sonst weigert sich die Aufnahme zu starten.

Während du aufnimmst, taucht eine kleine Anzeige in der Leiste auf. Klicke sie, um zu stoppen. Du kannst auch mit `Alt + Print Screen` noch einmal stoppen oder mit dem Eintrag _Stop Screenrecording_ unter _Trigger > Capture > Screenrecord_, der nur erscheint, solange tatsächlich etwas aufnimmt.

Das Stoppen räumt noch ein bisschen auf, bevor es dir die Datei gibt: Das erste Bild wird weggeschnitten, und falls es Audio gibt, wird es auf -14 LUFS normalisiert, wobei das PipeWire-Aufnahme-Knacken ganz am Anfang stummgeschaltet wird. Dann erscheint eine Benachrichtigung mit einem Vorschaubild aus der Aufnahme. Klicke sie, um die Datei in mpv abzuspielen.

### Das Webcam-Overlay

Wenn du mit einer Webcam aufnimmst, erscheint die Kamera als angeheftetes, zugeschnittenes Portrait-Fenster in der unteren rechten Ecke dessen, was du aufnimmst. Wenn sie auf etwas sitzt, das du brauchst, ändere ihre Größe im Flug:

| Hotkey | Funktion |
| ------ | -------- |
| `Super + Alt + [` | Das Webcam-Overlay kleiner machen |
| `Super + Alt + ]` | Das Webcam-Overlay größer machen |

Es gibt drei Größen — klein, mittel und groß — und die Hotkeys schalten zwischen ihnen durch. Mittel ist der Standard. Sie sind proportional zur Aufnahme, sodass die Kamera denselben Anteil des Bildes einnimmt, egal ob du einen 1080p-Monitor oder einen 6K-Monitor aufnimmst. Und wenn du einen Bereich statt eines ganzen Displays aufgenommen hast, verankert sich das Overlay an der Ecke dieses Bereichs statt an der des Monitors, sodass es im Shot bleibt.

Du kannst es auch direkt mit `omarchy-capture-webcam-resize small` aufrufen oder mit `reset`, um zu mittel zurückzukehren.

## Text, QR-Codes und Farben

`Super + Ctrl + Print Screen` wählt einen Bereich aus und kopiert ihn per OCR in die Zwischenablage. Das wird in [Textextraktion & Diktat](11-text-extraction-dictation.md) richtig behandelt.

_Trigger > Capture > QR Code_ macht denselben Trick für QR-Codes. Wähle den Bereich mit dem Code darin aus, und der dekodierte Wert landet in der Zwischenablage. Es sucht nur nach QR-Codes — dichter Bildschirminhalt neigt sonst dazu, fälschlich als Barcode erkannt zu werden. Wissenswert: Der dekodierte Wert geht in die Zwischenablage und sonst nirgendwohin. Er wird nicht ausgegeben, er steht nicht in der Benachrichtigung, und er ist als sensibel markiert, sodass er nicht in der [Zwischenablage-Historie](08-unified-clipboard-history.md) hängen bleibt. QR-Codes tragen routinemäßig Geheimnisse — die `otpauth://`-URI hinter einem 2FA-Einrichtungscode zum Beispiel — und das willst du nicht in einem Log haben. Einfügen funktioniert trotzdem einwandfrei.

`Super + Print Screen` (oder _Trigger > Capture > Color_) verwandelt den Cursor in eine Pipette. Klicke auf irgendetwas auf dem Bildschirm, und die Farbe landet in der Zwischenablage. Drücke den Hotkey noch einmal, um ohne Auswahl wieder auszusteigen.

## Transkodieren, bevor du teilst

Eine 4K-Bildschirmaufnahme oder eine rohe HEIC von deinem Telefon ist oft zu groß, um sie einfach zu schicken. `Super + Ctrl + .` (oder _Trigger > Transcode_) behebt das. Es bietet dir einen Fuzzy-Dateipicker über `~/Pictures` und `~/Videos` und fragt dann nach einem Format und einer Größe.

Bilder gehen nach jpg oder png in hoch, mittel oder niedrig, was die Breite auf 3160, 2160 und 1080 Pixel begrenzt. Videos gehen nach mp4 oder als animiertes gif in 4k, 1080p oder 720p. Die konvertierte Datei wird neben dem Original mit der Auflösung im Namen geschrieben — `demo-1080p.mp4` — und der Pfad wird als Datei-URI in die Zwischenablage kopiert, sodass du sie direkt in eine App einfügen kannst, die Datei-Drops annimmt.

Es funktioniert auch vom Terminal aus, wenn du schon weißt, was du willst: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Es gibt auch `omarchy transcode ascii`, das ein Bild in ASCII-Art verwandelt — das ist vor allem für [Branding](41-branding.md).

## Irgendwohin senden

Sobald du die Datei hast, öffnet `Super + Ctrl + S` das Share-Menü und schickt sie über LocalSend an ein anderes Gerät in deinem Netzwerk. Siehe dazu [GUIs](22-guis.md).
