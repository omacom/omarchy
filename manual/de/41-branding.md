# Branding

Mit Omarchy kannst du dein Firmenlogo oder dein persönliches Bild für die Boot-Entsperrung, den Bildschirmschoner und den Über-Bildschirm setzen.

### Boot-Entsperrung

Mit `omarchy plymouth preview` siehst du, wie dein eigenes Logo und deine Farben aussehen würden. Der Befehl nimmt eine Hintergrundfarbe, eine Textfarbe, ein Logo-PNG und einen Pfad für das Vorschaubild:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Dann wendest du das Setup mit `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png` an, was auch dem SDDM-Anmeldebildschirm dieselben Farben und dasselbe Logo gibt. Wenn du es rückgängig machen willst, nimmst du `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Bildschirmschoner

Das Logo für den Bildschirmschoner änderst du unter _Stil > Bildschirmschoner_. Es ist ein ASCII-Logo, sodass du den Text direkt bearbeiten kannst, aber du kannst auch ein PNG- oder SVG-Bild übergeben, und wir wandeln es in ASCII um. Sieht ziemlich cool aus.

 ![branding-screensaver](images/branding-screensaver.webp)

In diesem Menü gibt es drei Einträge:

- **Text bearbeiten** öffnet `~/.config/omarchy/branding/screensaver.txt` in deinem Editor. Tippe oder füge ein, was du magst — ASCII-Kunst, deinen Namen, ein unanständiges Wort. Speichern und beenden, und der Bildschirmschoner startet sofort, damit du es sehen kannst.
- **Aus Bild setzen** öffnet einen Dateiauswahldialog für ein PNG oder SVG, wandelt es in ASCII um und zeigt dir das Ergebnis. Logos mit klarer Silhouette funktionieren weit besser als Fotos.
- **Standard wiederherstellen** bringt das Omarchy-Logo zurück.

### Über-Bildschirm

Dieselben drei Optionen findest du unter _Stil > Über_ für den _Über_-Bildschirm, den du aus dem Omarchy-Menü bekommst, und sie funktionieren identisch — die Datei ist `~/.config/omarchy/branding/about.txt`, und das Über-Fenster erscheint nach jeder Änderung. Die Über-Grafik wird kleiner umgewandelt als die des Bildschirmschoners, weil sie in ein Fenster passen muss, statt dein Display zu füllen.

Solange das Fenster offen ist, zieht alle paar Sekunden ein grüner Glanz über die Grafik und lässt sie dann wieder still. Deine eigene Grafik bekommt ihn auch, solange jedes Zeichen darin eine Spalte breit ist — alles, was _Aus Bild setzen_ erzeugt, ist das. Grafik aus Emoji oder doppelbreiten Zeichen bleibt stattdessen still, und der Bildschirm tut das auch, wenn du eine eigene Fastfetch-Konfiguration behältst: Ein stilles Logo bedeutet in diesen Fällen, dass die Animation sich zurückhält, statt zu fehlzuschlagen, weil ein darübergleitender Glanz den Rest der Zeile an die falsche Stelle setzen würde.

 ![branding-about](images/branding-about.webp)

### Bilder selbst umwandeln

Beide Optionen _Aus Bild setzen_ rufen nur `omarchy transcode ascii` auf, was du auch direkt ausführen kannst, wenn du die Umwandlung kontrollieren willst:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Es nimmt `--width` und `--height` in Terminalspalten und -zeilen, einen `--mode` von entweder `braille` (Standard und viel feiner) oder `block`, einen `--threshold`-Prozentsatz, um zu entscheiden, welche Pixel zum Logo zählen, und `--invert` für den Fall, dass dein Logo hell auf dunklem Hintergrund liegt. Wenn eine Umwandlung als Klumpen herauskommt, ist der Schwellenwert meist der Regler, an dem du drehen musst.

### Worte statt eines Logos

`omarchy ascii` zeichnet Text in Delta Corps Priest 1, der FIGlet-Schrift, in der auch das Omarchy-Wortzeichen selbst gezeichnet ist, sodass ein Bildschirmschoner etwas sagen kann, statt ein Bild zu zeigen:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Es nimmt den Text als Argumente oder liest ihn aus einer Pipe, wenn nichts übergeben wird. Die Schrift trägt nur Buchstaben und Leerzeichen — sie wurde ohne Ziffern oder Satzzeichen gezeichnet —, sodass alles andere wegfällt und auf stderr genannt wird, statt still verschluckt zu werden.
