# Branding

Mit Omarchy kannst du dein Firmenlogo oder ein persönliches Bild sowohl für die Entsperrung beim Booten als auch für den Bildschirmschoner und den Info-Bildschirm festlegen.

### Entsperrung beim Booten

Mit `omarchy plymouth preview` kannst du dir ansehen, wie dein eigenes Logo und deine Farben aussehen würden. Der Befehl nimmt eine Hintergrundfarbe, eine Textfarbe, ein Logo als png und einen Pfad für das Vorschaubild entgegen:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Wende die Einrichtung dann mit `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png` an; dadurch erhält auch der SDDM-Anmeldebildschirm dieselben Farben und dasselbe Logo. Wenn du das rückgängig machen willst, kannst du `omarchy plymouth reset` verwenden.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Bildschirmschoner

Das für den Bildschirmschoner verwendete Logo kannst du unter _Erscheinungsbild > Branding > Bildschirmschoner_ ändern. Es ist ein ASCII-Logo, du kannst den Text also direkt bearbeiten, aber du kannst ihm auch ein png- oder svg-Bild geben, und wir wandeln das in ASCII um. Sieht ziemlich cool aus.

 ![branding-screensaver](images/branding-screensaver.webp)

In diesem Menü gibt es drei Einträge:

- **Text bearbeiten** öffnet `~/.config/omarchy/branding/screensaver.txt` in deinem Editor. Tippe oder füge ein, was immer du willst — ASCII-Kunst, deinen Namen, ein unanständiges Wort. Speichere und beende den Editor, und der Bildschirmschoner startet sofort, damit du es dir ansehen kannst.
- **Aus Bild setzen** öffnet eine Dateiauswahl für ein png oder svg, wandelt es in ASCII um und zeigt dir das Ergebnis. Logos mit einer klaren Silhouette funktionieren weitaus besser als Fotos.
- **Standard wiederherstellen** bringt das Omarchy-Logo zurück.

### Info-Bildschirm

Dieselben drei Optionen findest du unter _Erscheinungsbild > Branding > Info_ für den _Info_-Bildschirm, den du über das Omarchy-Menü aufrufst, und sie funktionieren identisch — die Datei ist `~/.config/omarchy/branding/about.txt`, und das Info-Fenster poppt nach jeder Änderung auf. Die Grafik für den Info-Bildschirm wird in eine kleinere Größe umgewandelt als die für den Bildschirmschoner, da sie in ein Fenster passen muss, statt deine Anzeige zu füllen.

Während das Fenster geöffnet ist, legt sich alle paar Sekunden ein Streifen hellen weißen Lichts schräg über die Grafik und lässt sie danach wieder still stehen. Deine eigene Grafik bekommt das auch, solange jedes Zeichen darin genau eine Spalte breit ist — und das ist alles, was _Aus Bild setzen_ erzeugt. Aus Emojis oder Zeichen doppelter Breite gebaute Grafik bleibt stattdessen still stehen, und dasselbe gilt für den Bildschirm, wenn du eine eigene fastfetch-Konfiguration behältst: Ein stilles Logo bedeutet in diesen Fällen, dass die Animation sich heraushält, statt zu versagen, denn ließe man einen Lichtschimmer darübergleiten, würde der Rest der Zeile an der falschen Stelle landen.

 ![branding-about](images/branding-about.webp)

### Bilder selbst umwandeln

Beide _Aus Bild setzen_-Optionen rufen einfach nur `omarchy transcode ascii` auf, das du auch direkt ausführen kannst, wenn du die Umwandlung selbst steuern willst:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Es nimmt `--width` und `--height` in Terminalspalten und -zeilen entgegen, einen `--mode` mit entweder `braille` (die Standardeinstellung und viel feiner) oder `block`, einen Prozentsatz für `--threshold`, um zu entscheiden, welche Pixel als Teil des Logos zählen, und `--invert` für den Fall, dass dein Logo hell auf dunklem Hintergrund ist. Wenn bei einer Umwandlung nur ein Klumpen herauskommt, ist der Schwellenwert normalerweise der Regler, an dem du drehen musst.

### Worte statt eines Logos

`omarchy ascii` zeichnet Text in Delta Corps Priest 1, der FIGlet-Schriftart, in der auch die Omarchy-Wortmarke selbst gezeichnet ist, sodass ein Bildschirmschoner etwas sagen kann, statt ein Bild zu zeigen:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Es nimmt den Text als Argumente entgegen oder liest ihn aus einer Pipe, wenn keine angegeben werden. Die Schriftart enthält nur Buchstaben und Leerzeichen — sie wurde ohne Ziffern oder Satzzeichen gezeichnet —, sodass alles andere verworfen und auf stderr ausdrücklich genannt wird, statt stillschweigend verschluckt zu werden.
