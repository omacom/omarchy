# Screenshots & Aufnahme

Alles, was du vom Bildschirm greifen kannst, hängt an der Print Screen-Taste. Eine Taste allein macht ein Bild, und die Modifikatoren machen eine Aufnahme, eine Farbe oder den Text in einem Bereich. Wenn deine Tastatur überhaupt keine Print Screen-Taste hat, macht `Super + Ctrl + Alt + C` denselben Screenshot, und `Super + Ctrl + C` öffnet die ganze Auswahl als Menü.

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

Drücke `Print Screen` (oder `Super + Ctrl + Alt + C`), und Omasnap erfasst den fokussierten Monitor, bevor sein Overlay erscheint, sodass sich nichts unter dir verschiebt, während du zielst. Ziehe einen Freiform-Bereich, klicke auf ein Fenster, um es aufzunehmen, oder klicke auf freien Raum, um den ganzen Monitor aufzunehmen. Drücke `S`, bevor du zeichnest, um einen scrollenden Bereich aufzunehmen. Anders überlegt? Drücke dieselbe Taste noch einmal, um Omasnap zu schließen.

Nachdem du einen Bereich ausgewählt hast, speichert Omasnap die Aufnahme, kopiert sie in die Zwischenablage und zeigt 10 Sekunden lang eine Vorschau. Nutze die Anheften-Schaltfläche der Vorschau oder `Ctrl + P`, um sie auf dem Bildschirm zu behalten, oder wähle Edit, um sie zu kommentieren.

Der Annotations-Editor kann Pfeile, Linien, Formen, Hervorhebungen, nummerierte Markierungen, Text und sichere Schwärzungen zeichnen; einen Teil des Bildes zuschneiden oder herausschneiden; seinen Text per OCR erkennen; und einen Hintergrund hinzufügen. Drücke im Editor `Enter`, um das fertige PNG zu kopieren und zu speichern, `Ctrl + C`, um es zu kopieren, ohne zu speichern, oder `Ctrl + S`, um es zu speichern, ohne zu kopieren.

Gespeicherte Screenshots landen standardmäßig in `~/Pictures/Screenshots`, mit einem Namen wie `screenshot-2026-08-13_14-22-05-firefox.png`. Setze `OMASNAP_SCREENSHOT_DIR`, um ein anderes Verzeichnis zu verwenden — wo Sitzungs-Umgebungsvariablen hingehören, steht in [der FAQ](46-faq.md). Omasnap erstellt das Verzeichnis, wenn es den ersten Screenshot speichert. Setze `[output] autosave = false` in `~/.config/omasnap/omasnap.conf`, um das automatische Speichern zu deaktivieren.

Vom Terminal aus öffnet `omarchy screenshot` dasselbe Overlay, und du kannst seinen Startmodus wählen: `omarchy capture screenshot region`, `windows`, `fullscreen` oder `scroll`. Ein zweites Argument `copy` oder `save` überspringt die Vorschau und schickt den Screenshot direkt an dieses Ziel. Um vor der Ausgabe zu bearbeiten, nutze `omarchy screenshot --editor=overlay` für einen Vollbild-Editor oder `omarchy screenshot --editor=window` für ein separates Fenster.

### Die Auswahl per Tastatur steuern

Während die Auswahl offen ist, musst du die Maus überhaupt nicht benutzen:

| Taste | Funktion |
| --- | -------- |
| `S` | Modus für scrollenden Bereich umschalten |
| `Super + Arrow keys` | Im Fenster-Modus zwischen Fenstern bewegen |
| `Return` | Das markierte Fenster aufnehmen |
| `Ctrl + A` | Den ganzen fokussierten Monitor aufnehmen |
| `R` | Den zuletzt in dieser Sitzung gezeichneten Bereich wiederherstellen |
| `Esc` | Omasnap schließen |

Diese Bindungen existieren nur, solange Omasnap offen ist, also können sie mit nichts in deiner eigenen Config kollidieren.

## Bildschirmaufnahme

`Alt + Print Screen` öffnet _Trigger > Capture > Screenrecord_, das fragt, was du auf der Tonspur haben willst: kein Audio, Desktop-Audio, Desktop plus Mikrofon oder Desktop plus Mikrofon plus Webcam. Die letzte Option erscheint nur, wenn du tatsächlich eine Kamera angeschlossen hast. Wähle eine, und Omarchys Aufnahme-Auswahl lässt dich einen Bereich ziehen oder auf ein Fenster oder einen Monitor klicken.

Die Aufnahme läuft auf gpu-screen-recorder, das auf der GPU mit 60fps kodiert und notfalls auf die CPU zurückfällt. Das Ergebnis ist ein MP4 in `~/Videos` mit dem Namen `screenrecording-2026-08-13_14-22-05.mp4`. Setze `OMARCHY_SCREENRECORD_DIR`, um das zu ändern — aber beachte, dass dieses Verzeichnis im Gegensatz zum Screenshot-Verzeichnis bereits existieren muss, sonst weigert sich die Aufnahme zu starten.

Während du aufnimmst, erscheint eine kleine Anzeige in der Leiste. Klicke sie, um zu stoppen. Du kannst auch wieder mit `Alt + Print Screen` stoppen oder mit dem Eintrag _Stop Screenrecording_ unter _Trigger > Capture > Screenrecord_, der nur erscheint, solange tatsächlich etwas aufnimmt.

Das Stoppen räumt noch etwas auf, bevor es dir die Datei übergibt: Das erste Bild wird weggeschnitten, und wenn es Audio gibt, wird es auf -14 LUFS normalisiert, wobei das PipeWire-Aufnahme-Ploppen ganz am Anfang stummgeschaltet wird. Dann erscheint eine Benachrichtigung mit einem Vorschaubild aus der Aufnahme. Klicke sie, um die Datei in mpv abzuspielen.

### Das Webcam-Overlay

Wenn du mit einer Webcam aufnimmst, erscheint die Kamera als angeheftetes, zugeschnittenes Porträtfenster in der rechten unteren Ecke dessen, was du aufnimmst. Wenn sie auf etwas sitzt, das du brauchst, ändere ihre Größe im Flug:

| Hotkey | Funktion |
| ------ | -------- |
| `Super + Alt + [` | Das Webcam-Overlay kleiner machen |
| `Super + Alt + ]` | Das Webcam-Overlay größer machen |

Es gibt drei Größen — small, medium und large — und die Hotkeys schalten zwischen ihnen um. Medium ist der Standard. Sie sind proportional zur Aufnahme, also nimmt die Kamera denselben Anteil des Bildes ein, ob du einen 1080p-Monitor oder einen 6K-Monitor aufnimmst. Und wenn du einen Bereich statt eines ganzen Bildschirms aufgenommen hast, verankert sich das Overlay an der Ecke dieses Bereichs statt an der des Monitors, sodass es innerhalb der Aufnahme bleibt.

Du kannst es auch direkt mit `omarchy-capture-webcam-resize small` aufrufen, oder mit `reset`, um zu medium zurückzukehren.

## Text, QR-Codes und Farben

`Super + Ctrl + Print Screen` wählt einen Bereich aus und erkennt seinen Text per OCR in die Zwischenablage. Das wird in [Textextraktion & Diktat](11-text-extraction-dictation.md) richtig behandelt.

_Trigger > Capture > QR Code_ macht denselben Trick für QR-Codes. Wähle den Bereich mit dem Code darin, und der dekodierte Wert wandert in die Zwischenablage. Es sucht nur nach QR-Codes — dichter Bildschirminhalt hat sonst die Angewohnheit, fälschlich als Barcode durchzugehen. Wissenswert: Der dekodierte Wert geht in die Zwischenablage und nirgendwo sonst hin. Er wird nicht ausgedruckt, er steht nicht in der Benachrichtigung, und er ist als sensibel markiert, damit er nicht im [Zwischenablageverlauf](08-unified-clipboard-history.md) hängen bleibt. QR-Codes tragen routinemäßig Geheimnisse — die `otpauth://`-URI hinter einem 2FA-Einrichtungscode zum Beispiel — und das willst du nicht in einem Log haben. Einfügen funktioniert trotzdem einwandfrei.

`Super + Print Screen` (oder _Trigger > Capture > Color_) verwandelt den Cursor in eine Pipette. Klicke auf irgendetwas auf dem Bildschirm, und die Farbe landet in der Zwischenablage. Drücke den Hotkey noch einmal, um auszusteigen, ohne eine zu wählen.

## Vor dem Teilen transkodieren

Eine 4K-Bildschirmaufnahme oder ein rohes HEIC von deinem Telefon ist oft zu groß, um es einfach zu schicken. `Super + Ctrl + .` (oder _Trigger > Transcode_) behebt das. Es bietet dir eine unscharfe Dateiauswahl über `~/Pictures` und `~/Videos` und fragt dann nach einem Format und einer Größe.

Bilder gehen zu jpg oder png in high, medium oder low, was die Breite auf 3160, 2160 und 1080 Pixel begrenzt. Videos gehen zu mp4 oder einem animierten gif in 4k, 1080p oder 720p. Die konvertierte Datei wird neben dem Original geschrieben, mit der Auflösung im Namen — `demo-1080p.mp4` — und der Pfad wird als Datei-URI in die Zwischenablage kopiert, sodass du ihn direkt in eine App einfügen kannst, die Datei-Drops annimmt.

Es funktioniert auch vom Terminal aus, wenn du schon weißt, was du willst: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Es gibt auch `omarchy transcode ascii`, das ein Bild in ASCII-Art verwandelt — das ist vor allem für [Branding](41-branding.md).

## Es irgendwohin senden

Sobald du die Datei hast, öffnet `Super + Ctrl + S` das Share-Menü und sendet sie über LocalSend an ein anderes Gerät in deinem Netzwerk. Siehe dazu [GUIs](22-guis.md).
