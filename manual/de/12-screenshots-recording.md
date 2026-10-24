# Screenshots & Aufnahme

Alles, was du vom Bildschirm greifen kannst, hängt an der Taste Print Screen. Eine Taste allein macht ein Bild, und die Modifikatoren machen eine Aufnahme, eine Farbe oder den Text innerhalb eines Bereichs. Wenn deine Tastatur überhaupt keine Taste Print Screen hat, öffnet `Super + Ctrl + C` dieselbe Auswahl als Menü.

| Tastenkürzel | Funktion |
| ------ | -------- |
| `Print Screen` | Screenshot |
| `Alt + Print Screen` | Bildschirmaufnahme (oder die laufende stoppen) |
| `Super + Print Screen` | Farbwähler |
| `Super + Ctrl + Print Screen` | Text aus einem Bereich extrahieren |
| `Super + Ctrl + C` | Aufnehmen-Menü |
| `Super + Ctrl + .` | Ein Bild oder Video transkodieren |

## Screenshots

Drücke `Print Screen`, und Omasnap nimmt den fokussierten Monitor auf, bevor sein Overlay erscheint, sodass sich nichts unter dir verschiebt, während du zielst. Ziehe einen Freiform-Bereich, klicke auf ein Fenster, um es aufzunehmen, oder klicke auf freien Raum, um den ganzen Monitor aufzunehmen. Drücke `S` vor dem Zeichnen, um einen Scroll-Bereich aufzunehmen. Hast du es dir anders überlegt? Drücke `Print Screen` erneut, um Omasnap zu schließen.

Nachdem du einen Bereich ausgewählt hast, speichert Omasnap die Aufnahme, kopiert sie in die Zwischenablage und zeigt 10 Sekunden lang eine Vorschau. Verwende die Anheft-Schaltfläche der Vorschau oder `Ctrl + P`, um sie auf dem Bildschirm zu behalten, oder wähle Bearbeiten, um sie zu kommentieren.

Der Annotations-Editor kann Pfeile, Linien, Formen, Hervorhebungen, nummerierte Markierungen, Text und sichere Schwärzungen zeichnen; einen Teil des Bildes zuschneiden oder herausschneiden; seinen Text per OCR erkennen; und einen Hintergrund hinzufügen. Drücke im Editor `Enter`, um die fertige PNG zu kopieren und zu speichern, `Ctrl + C`, um sie zu kopieren, ohne zu speichern, oder `Ctrl + S`, um sie zu speichern, ohne zu kopieren.

Gespeicherte Screenshots landen standardmäßig in `~/Pictures/Screenshots`, mit einem Namen wie `screenshot-2026-08-13_14-22-05-firefox.png`. Setze `OMASNAP_SCREENSHOT_DIR`, um ein anderes Verzeichnis zu verwenden — siehe [die FAQ](46-faq.md), wo Sitzungs-Umgebungsvariablen hingehören. Omasnap erstellt das Verzeichnis, wenn es den ersten Screenshot speichert. Setze `[output] autosave = false` in `~/.config/omasnap/omasnap.conf`, um das automatische Speichern zu deaktivieren.

Vom Terminal aus öffnet `omarchy screenshot` dasselbe Overlay, und du kannst seinen Startmodus wählen: `omarchy capture screenshot region`, `windows`, `fullscreen` oder `scroll`. Ein zweites Argument `copy` oder `save` überspringt die Vorschau und schickt den Screenshot direkt an dieses Ziel. Um vor der Ausgabe zu bearbeiten, verwende `omarchy screenshot --editor=overlay` für einen Vollbild-Editor oder `omarchy screenshot --editor=window` für ein separates Fenster.

### Den Picker über die Tastatur steuern

Während die Auswahl offen ist, musst du die Maus überhaupt nicht verwenden:

| Taste | Funktion |
| --- | -------- |
| `S` | Scroll-Bereich-Modus umschalten |
| `Super + Arrow keys` | Im Fenster-Modus zwischen Fenstern bewegen |
| `Return` | Das hervorgehobene Fenster aufnehmen |
| `Ctrl + A` | Den vollständig fokussierten Monitor aufnehmen |
| `R` | Den zuletzt in dieser Sitzung gezeichneten Bereich wiederherstellen |
| `Esc` | Omasnap schließen |

Diese Zuordnungen existieren nur, während Omasnap offen ist, sodass sie mit nichts in deiner eigenen Konfiguration kollidieren können.

## Bildschirmaufnahme

`Alt + Print Screen` öffnet _Auslösen > Aufnehmen > Bildschirmaufnahme_, was fragt, was du auf der Tonspur haben willst: kein Audio, Desktop-Audio, Desktop plus Mikrofon oder Desktop plus Mikrofon plus Webcam. Die letzte Option erscheint nur, wenn du tatsächlich eine Kamera angeschlossen hast. Wähle eine, und Omarchys Aufnahme-Picker lässt dich einen Bereich ziehen oder auf ein Fenster oder einen Monitor klicken.

Die Aufnahme läuft auf gpu-screen-recorder, der auf der GPU mit 60 fps kodiert und bei Bedarf auf die CPU zurückfällt. Das Ergebnis ist eine MP4 in `~/Videos` mit dem Namen `screenrecording-2026-08-13_14-22-05.mp4`. Setze `OMARCHY_SCREENRECORD_DIR`, um das zu ändern — beachte aber, dass dieses Verzeichnis im Gegensatz zum Screenshot-Verzeichnis bereits existieren muss, sonst weigert sich die Aufnahme zu starten.

Während du aufnimmst, erscheint eine kleine Anzeige in der Leiste. Klicke darauf, um zu stoppen. Du kannst auch mit `Alt + Print Screen` erneut stoppen oder mit dem Eintrag _Aufnahme stoppen_ unter _Auslösen > Aufnehmen > Bildschirmaufnahme_, der nur erscheint, während tatsächlich etwas aufnimmt.

Das Stoppen räumt ein wenig auf, bevor es dir die Datei übergibt: Das erste Bild wird abgeschnitten, und wenn es Audio gibt, wird es auf -14 LUFS normalisiert, wobei der PipeWire-Aufnahme-Knacks ganz am Anfang stumm geschaltet wird. Dann erscheint eine Benachrichtigung mit einem Vorschaubild aus der Aufnahme. Klicke darauf, um die Datei in mpv abzuspielen.

### Das Webcam-Overlay

Wenn du mit einer Webcam aufnimmst, erscheint die Kamera als angeheftetes, zugeschnittenes Porträtfenster in der unteren rechten Ecke dessen, was du aufnimmst. Wenn sie auf etwas sitzt, das du brauchst, ändere ihre Größe im laufenden Betrieb:

| Tastenkürzel | Funktion |
| ------ | -------- |
| `Super + Alt + [` | Das Webcam-Overlay kleiner machen |
| `Super + Alt + ]` | Das Webcam-Overlay größer machen |

Es gibt drei Größen — klein, mittel und groß — und die Tastenkürzel wechseln zwischen ihnen. Mittel ist der Standard. Sie sind proportional zur Aufnahme, sodass die Kamera denselben Anteil des Bildes einnimmt, egal ob du einen 1080p-Monitor oder einen 6K-Monitor aufnimmst. Und wenn du einen Bereich statt eines ganzen Displays aufgenommen hast, verankert sich das Overlay an der Ecke dieses Bereichs statt an der des Monitors, sodass es innerhalb der Aufnahme bleibt.

Du kannst es auch direkt mit `omarchy-capture-webcam-resize small` aufrufen oder mit `reset`, um zu mittel zurückzukehren.

## Text, QR-Codes und Farben

`Super + Ctrl + Print Screen` wählt einen Bereich aus und erkennt ihn per OCR in die Zwischenablage. Das wird in [Textextraktion & Diktat](11-text-extraction-dictation.md) ausführlich behandelt.

_Auslösen > Aufnehmen > QR-Code_ macht denselben Trick für QR-Codes. Wähle den Bereich mit dem Code darin aus, und der dekodierte Wert geht in die Zwischenablage. Es sucht nur nach QR-Codes — dichter Bildschirminhalt neigt sonst dazu, fälschlicherweise als Barcode erkannt zu werden. Wichtige Info: Der dekodierte Wert geht in die Zwischenablage und sonst nirgendwo hin. Er wird nicht ausgegeben, er ist nicht in der Benachrichtigung, und er ist als sensibel markiert, sodass er nicht im [Zwischenablageverlauf](08-unified-clipboard-history.md) hängen bleibt. QR-Codes tragen routinemäßig Geheimnisse — zum Beispiel die `otpauth://`-URI hinter einem 2FA-Einrichtungscode — und du willst das nicht in einem Log haben. Einfügen funktioniert trotzdem einwandfrei.

`Super + Print Screen` (oder _Auslösen > Aufnehmen > Farbe_) verwandelt den Cursor in eine Pipette. Klicke auf irgendetwas auf dem Bildschirm, und die Farbe landet in der Zwischenablage. Drücke das Tastenkürzel erneut, um abzubrechen, ohne zu wählen.

## Transkodieren vor dem Teilen

Eine 4K-Bildschirmaufnahme oder ein rohes HEIC von deinem Telefon ist oft zu groß, um es einfach zu senden. `Super + Ctrl + .` (oder _Auslösen > Transkodieren_) behebt das. Es bietet dir einen Fuzzy-Dateipicker über `~/Pictures` und `~/Videos` und fragt dann nach einem Format und einer Größe.

Bilder gehen zu jpg oder png in hoch, mittel oder niedrig, was die Breite auf 3160, 2160 und 1080 Pixel begrenzt. Videos gehen zu mp4 oder einem animierten gif in 4k, 1080p oder 720p. Die konvertierte Datei wird neben dem Original mit der Auflösung im Namen geschrieben — `demo-1080p.mp4` — und der Pfad wird als Datei-URI in die Zwischenablage kopiert, sodass du sie direkt in eine App einfügen kannst, die Datei-Drops akzeptiert.

Es funktioniert auch vom Terminal aus, wenn du schon weißt, was du willst: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Es gibt auch `omarchy transcode ascii`, das ein Bild in ASCII-Kunst verwandelt — das ist hauptsächlich für [Branding](41-branding.md) gedacht.

## Es irgendwohin senden

Sobald du die Datei hast, öffnet `Super + Ctrl + S` das Teilen-Menü und sendet sie über LocalSend an ein anderes Gerät in deinem Netzwerk. Siehe [GUIs](22-guis.md) dazu.
