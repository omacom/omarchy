# Screenshots & Bildschirmaufnahme

Alles, was du dir vom Bildschirm schnappen kannst, hängt an der Print Screen-Taste. Die Taste allein macht ein Foto, und die Modifikatortasten machen eine Aufnahme, holen eine Farbe oder den Text in einem Bereich. Wenn deine Tastatur überhaupt keine Print Screen-Taste hat, macht `Super + Ctrl + Alt + C` denselben Screenshot, und `Super + Ctrl + C` öffnet das ganze Set als Menü.

| Tastenkombination | Funktion |
| ------ | -------- |
| `Print Screen` | Screenshot |
| `Super + Ctrl + Alt + C` | Screenshot |
| `Alt + Print Screen` | Bildschirmaufnahme (oder die laufende stoppen) |
| `Super + Print Screen` | Farbpipette |
| `Super + Ctrl + Print Screen` | Text aus einem Bereich extrahieren |
| `Super + Ctrl + C` | Aufnahme-Menü |
| `Super + Ctrl + .` | Ein Bild oder Video transkodieren |

## Screenshots

Drücke `Print Screen` (oder `Super + Ctrl + Alt + C`), und Omasnap erfasst den fokussierten Monitor, bevor sein Overlay erscheint, sodass sich nichts unter dir verschiebt, während du zielst. Ziehe einen Freiform-Bereich auf, klicke auf ein Fenster, um es zu erfassen, oder klicke auf eine freie Fläche, um den ganzen Monitor zu erfassen. Drücke `S`, bevor du zeichnest, um einen scrollenden Bereich zu erfassen. Anders überlegt? Drücke dieselbe Taste noch einmal, um Omasnap zu schließen.

Nachdem du einen Bereich ausgewählt hast, speichert Omasnap die Aufnahme, kopiert sie in die Zwischenablage und zeigt eine Benachrichtigung mit ihrem Vorschaubild, genau wie bei einer gespeicherten Bildschirmaufnahme. Wähle Öffnen, um den gespeicherten Schnappschuss in deinem Bildbetrachter anzusehen, oder Bearbeiten, um ihn zu kommentieren.

Der Editor für Anmerkungen kann Pfeile, Linien, Formen, Hervorhebungen, nummerierte Markierungen, Text und sichere Schwärzungen zeichnen; einen Teil des Bildes zuschneiden oder ausschneiden; seinen Text per OCR erkennen; und einen Hintergrund hinzufügen. Drücke im Editor `Enter`, um das fertige PNG zu kopieren und zu speichern, `Ctrl + C`, um es ohne Speichern zu kopieren, oder `Ctrl + S`, um es ohne Kopieren zu speichern.

Gespeicherte Screenshots landen standardmäßig in `~/Pictures/Screenshots`, mit einem Namen wie `screenshot-2026-08-13_14-22-05-firefox.png`. Setze `OMASNAP_SCREENSHOT_DIR`, um ein anderes Verzeichnis zu verwenden — siehe [die FAQ](46-faq.md), wo Sitzungs-Umgebungsvariablen hingehören. Omasnap erstellt das Verzeichnis, wenn es den ersten Schnappschuss speichert. Setze `[output] autosave = false` in `~/.config/omasnap/omasnap.conf`, um das automatische Speichern zu deaktivieren; Aufnahmen werden dann nur kopiert und 7 Sekunden lang in einer Vorschau gezeigt, die du mit ihrer Pin-Schaltfläche oder `Ctrl + P` auf dem Bildschirm halten kannst.

Vom Terminal aus öffnet `omarchy screenshot` dasselbe Overlay, und du kannst seinen Startmodus wählen: `omarchy capture screenshot region`, `windows`, `fullscreen` oder `scroll`. Ein zweites Argument `copy` oder `save` schickt den Schnappschuss direkt an dieses Ziel. Um vor der Ausgabe zu bearbeiten, verwende `omarchy screenshot --editor=overlay` für einen Editor im Vollbild oder `omarchy screenshot --editor=window` für ein separates Fenster.

### Die Auswahl per Tastatur steuern

Während die Auswahl geöffnet ist, musst du die Maus überhaupt nicht benutzen:

| Taste | Funktion |
| --- | -------- |
| `S` | Modus für scrollenden Bereich umschalten |
| `Super + Arrow keys` | Im Fenster-Modus zwischen Fenstern wechseln |
| `Return` | Das hervorgehobene Fenster erfassen |
| `Ctrl + A` | Den gesamten fokussierten Monitor erfassen |
| `R` | Den letzten in dieser Sitzung gezeichneten Bereich wiederherstellen |
| `Esc` | Omasnap schließen |

Diese Tastenkombinationen existieren nur, solange Omasnap geöffnet ist, also können sie mit nichts in deiner eigenen Konfiguration kollidieren.

## Bildschirmaufnahme

`Alt + Print Screen` öffnet _Auslöser > Aufnahme > Bildschirmaufnahme_, wo du gefragt wirst, was auf der Tonspur sein soll: kein Audio, Desktop-Audio, Desktop plus Mikrofon oder Desktop plus Mikrofon plus Webcam. Die letzte Option taucht nur auf, wenn du tatsächlich eine Kamera angeschlossen hast. Wähle eine aus, und die Aufnahmeauswahl von Omarchy lässt dich einen Bereich aufziehen oder auf ein Fenster oder einen Monitor klicken.

Die Aufnahme läuft mit gpu-screen-recorder, der auf der GPU mit 60fps kodiert und notfalls auf die CPU zurückfällt; auf GPUs, die er nicht unterstützt, wie die von Apple Silicon, nimmt Omarchy stattdessen mit wf-recorder auf. Das Ergebnis ist eine MP4 in `~/Videos` mit einem Namen wie `screenrecording-2026-08-13_14-22-05.mp4`. Setze `OMARCHY_SCREENRECORD_DIR`, um das zu ändern — aber beachte, dass dieses Verzeichnis, anders als das Screenshot-Verzeichnis, bereits existieren muss, sonst weigert sich die Aufnahme zu starten.

Während du aufnimmst, erscheint eine kleine Anzeige in der Leiste. Klicke darauf, um zu stoppen. Du kannst auch erneut mit `Alt + Print Screen` stoppen oder mit dem Eintrag _Bildschirmaufnahme stoppen_ unter _Auslöser > Aufnahme > Bildschirmaufnahme_, der nur erscheint, solange tatsächlich etwas aufnimmt.

Beim Stoppen wird noch ein bisschen aufgeräumt, bevor du die Datei bekommst: Das erste Bild wird weggeschnitten, und falls Audio vorhanden ist, wird es auf -14 LUFS normalisiert, wobei das PipeWire-Aufnahme-Ploppen ganz am Anfang stummgeschaltet wird. Dann erscheint eine Benachrichtigung mit einem Vorschaubild aus der Aufnahme. Wähle _Öffnen_, um die Datei in Omaview abzuspielen, oder _Zuschneiden_, um sie in Omacut zu trimmen.

### Das Webcam-Overlay

Wenn du mit einer Webcam aufnimmst, erscheint die Kamera als angeheftetes, zugeschnittenes Porträtfenster in der unteren rechten Ecke dessen, was du gerade aufnimmst. Wenn sie auf etwas sitzt, das du brauchst, ändere ihre Größe im Flug:

| Tastenkombination | Funktion |
| ------ | -------- |
| `Super + Alt + [` | Das Webcam-Overlay kleiner machen |
| `Super + Alt + ]` | Das Webcam-Overlay größer machen |

Es gibt drei Größen — klein, mittel und groß — und die Tastenkombinationen schalten zwischen ihnen durch. Mittel ist die Standardeinstellung. Sie sind proportional zur Aufnahme, sodass die Kamera denselben Anteil des Bildes einnimmt, egal ob du einen 1080p-Monitor oder einen 6K-Monitor aufnimmst. Und wenn du einen Bereich statt einer ganzen Anzeige aufgenommen hast, verankert sich das Overlay an der Ecke dieses Bereichs statt an der des Monitors, sodass es innerhalb des Schnappschusses bleibt.

Du kannst es auch direkt mit `omarchy-capture-webcam-resize small` aufrufen, oder mit `reset`, um zu mittel zurückzukehren.

## Text, QR-Codes und Farben

`Super + Ctrl + Print Screen` wählt einen Bereich aus und kopiert ihn per OCR in die Zwischenablage. Das wird in [Textextraktion & Diktieren](11-text-extraction-dictation.md) richtig behandelt.

_Auslöser > Aufnahme > QR Code_ macht denselben Trick für QR-Codes. Wähle den Bereich mit dem Code darin aus, und der dekodierte Wert landet in der Zwischenablage. Es wird nur nach QR-Codes gesucht — dichter Bildschirminhalt wird sonst gern fälschlich als Barcode erkannt. Gut zu wissen: Der dekodierte Wert landet in der Zwischenablage und sonst nirgendwo. Er wird nicht ausgegeben, er steht nicht in der Benachrichtigung, und er ist als sensibel markiert, sodass er nicht im [Verlauf der Zwischenablage](08-unified-clipboard-history.md) hängen bleibt. QR-Codes tragen routinemäßig Geheimnisse — die `otpauth://`-URI hinter einem 2FA-Einrichtungscode zum Beispiel — und die willst du nicht in einem Protokoll haben. Einfügen funktioniert trotzdem einwandfrei.

`Super + Print Screen` (oder _Auslöser > Aufnahme > Farbe_) verwandelt den Cursor in eine Pipette. Klicke auf irgendetwas auf dem Bildschirm, und die Farbe landet in der Zwischenablage. Drücke die Tastenkombination erneut, um abzubrechen, ohne etwas auszuwählen.

## Transkodieren vor dem Teilen

Eine 4K-Bildschirmaufnahme oder ein rohes HEIC von deinem Telefon ist oft zu groß, um es einfach zu verschicken. `Super + Ctrl + .` (oder _Auslöser > Transkodieren_) behebt das. Es bietet dir eine Fuzzy-Dateiauswahl über `~/Pictures` und `~/Videos` und fragt dann nach einem Format und einer Größe.

Bilder werden zu jpg oder png in hoch, mittel oder niedrig, was die Breite auf 3160, 2160 und 1080 Pixel begrenzt. Videos werden zu mp4 oder einem animierten gif in 4k, 1080p oder 720p. Die konvertierte Datei wird neben das Original geschrieben, mit der Auflösung im Namen — `demo-1080p.mp4` — und der Pfad wird als Datei-URI in die Zwischenablage kopiert, sodass du sie direkt in eine App einfügen kannst, die Datei-Drops annimmt.

Es funktioniert auch vom Terminal aus, wenn du schon weißt, was du willst: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Es gibt auch `omarchy transcode ascii`, das ein Bild in ASCII-Kunst verwandelt — das ist hauptsächlich für [Branding](41-branding.md).

## Irgendwohin senden

Sobald du die Datei hast, öffnet `Super + Ctrl + S` das Teilen-Menü und sendet sie über LocalSend an ein anderes Gerät in deinem Netzwerk. Siehe dazu [GUIs](22-guis.md).
