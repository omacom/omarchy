# Branding

Omarchy ermöglicht es dir, dein Firmenlogo oder ein persönliches Bild sowohl für den Bildschirmschoner als auch für den Info-Bildschirm festzulegen.

### Bildschirmschoner

Das Logo für den Bildschirmschoner kannst du unter _Darstellung > Branding > Bildschirmschoner_ ändern. Es ist ein ASCII-Logo, du kannst den Text also direkt bearbeiten, aber du kannst auch ein png- oder svg-Bild übergeben, und wir wandeln es in ASCII um. Sieht ziemlich cool aus.

 ![branding-screensaver](images/branding-screensaver.webp)

Es gibt drei Einträge in diesem Menü:

- **Text bearbeiten** öffnet `~/.config/omarchy/branding/screensaver.txt` in deinem Editor. Tippe oder füge ein, was du willst — ASCII-Art, deinen Namen, ein unanständiges Wort. Speichern und beenden, und der Bildschirmschoner startet sofort, damit du es sehen kannst.
- **Aus Bild festlegen** öffnet einen Dateiauswahldialog für ein png oder svg, wandelt es in ASCII um und zeigt dir das Ergebnis. Logos mit einer klaren Silhouette funktionieren weitaus besser als Fotos.
- **Standard wiederherstellen** setzt das Omarchy-Logo zurück.

### Info-Bildschirm

Die gleichen drei Optionen findest du unter _Darstellung > Branding > Info_ für den _Info_-Bildschirm, den du über das Omarchy-Menü aufrufst, und sie funktionieren identisch — die Datei ist `~/.config/omarchy/branding/about.txt`, und das Info-Fenster erscheint nach jeder Änderung. Die Info-Grafik wird in einer kleineren Größe umgewandelt als die des Bildschirmschoners, da sie in ein Fenster passen muss, statt deine Anzeige auszufüllen.

Während das Fenster geöffnet ist, zieht alle paar Sekunden ein Band aus hellem weißen Licht über die Grafik und lässt sie dann wieder still stehen. Deine eigene Grafik bekommt das auch, solange jedes Zeichen darin eine Spalte breit ist — alles, was _Aus Bild festlegen_ erzeugt, ist es. Grafik aus Emoji oder Zeichen mit doppelter Breite bleibt stattdessen still stehen, und der Bildschirm tut das auch, wenn du eine eigene fastfetch-Konfiguration behältst: Ein stillstehendes Logo ist in diesen Fällen die Animation, die sich zurückhält, statt zu versagen, da ein darübergleitender Lichtstreifen den Rest der Zeile an die falsche Stelle rücken würde.

 ![branding-about](images/branding-about.webp)

### Bilder selbst umwandeln

Beide _Aus Bild festlegen_-Optionen rufen einfach `omarchy transcode ascii` auf, das du direkt ausführen kannst, wenn du die Kontrolle über die Umwandlung haben willst:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Es akzeptiert `--width` und `--height` in Terminal-Spalten und -Zeilen, einen `--mode` von entweder `braille` (der Standard und viel feiner) oder `block`, einen `--threshold`-Prozentsatz, um zu entscheiden, welche Pixel als Teil des Logos zählen, und `--invert` für den Fall, dass dein Logo hell auf dunklem Hintergrund ist. Wenn eine Umwandlung als Klumpen herauskommt, ist der Schwellenwert normalerweise der Regler, an dem du drehen musst.

### Wörter statt eines Logos

`omarchy ascii` zeichnet Text in Delta Corps Priest 1, der FIGlet-Schrift, in der auch die Omarchy-Wortmarke selbst gezeichnet ist, sodass ein Bildschirmschoner etwas sagen kann, statt ein Bild zu zeigen:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Es nimmt den Text als Argumente entgegen oder liest ihn aus einer Pipe, wenn keine angegeben sind. Die Schrift enthält nur Buchstaben und Leerzeichen — sie wurde ohne Ziffern oder Satzzeichen gezeichnet — also wird alles andere verworfen und auf stderr benannt, statt stillschweigend verschluckt zu werden.
