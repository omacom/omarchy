# Branding

Omarchy ermöglicht es dir, dein Firmenlogo oder ein persönliches Bild sowohl für die Boot-Entsperrung, den Bildschirmschoner als auch den Info-Bildschirm festzulegen.

### Boot-Entsperrung

Mit `omarchy plymouth preview` kannst du dir ansehen, wie dein eigenes Logo und deine Farben aussehen würden. Der Befehl nimmt eine Hintergrundfarbe, eine Textfarbe, ein Logo als png und einen Pfad für das Vorschaubild entgegen:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Anschließend übernimmst du die Einrichtung mit `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, wodurch auch der SDDM-Anmeldebildschirm dieselben Farben und dasselbe Logo erhält. Wenn du alles rückgängig machen willst, kannst du `omarchy plymouth reset` verwenden.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Bildschirmschoner

Das für den Bildschirmschoner verwendete Logo kannst du unter _Appearance > Branding > Screensaver_ ändern. Es ist ein ASCII-Logo, du kannst den Text also direkt bearbeiten, aber du kannst ihm auch ein png- oder svg-Bild übergeben, und wir wandeln es in ASCII um. Das sieht ziemlich cool aus.

 ![branding-screensaver](images/branding-screensaver.webp)

Dieses Menü enthält drei Einträge:

- **Edit Text** öffnet `~/.config/omarchy/branding/screensaver.txt` in deinem Editor. Tippe oder füge ein, was immer du willst — ASCII-Art, deinen Namen, ein unanständiges Wort. Speichere und beende den Editor, und der Bildschirmschoner startet sofort, damit du es dir ansehen kannst.
- **Set From Image** öffnet eine Dateiauswahl für ein png oder svg, wandelt es in ASCII um und zeigt dir das Ergebnis. Logos mit einer klaren Silhouette funktionieren weitaus besser als Fotos.
- **Restore Default** stellt das Omarchy-Logo wieder her.

### Info-Bildschirm

Dieselben drei Optionen findest du unter _Appearance > Branding > About_ für den _About_-Bildschirm, den du über das Omarchy-Menü aufrufst, und sie funktionieren identisch — die Datei ist `~/.config/omarchy/branding/about.txt`, und das About-Fenster öffnet sich nach jeder Änderung. Die About-Grafik wird in einer kleineren Größe konvertiert als die des Bildschirmschoners, da sie in ein Fenster passen muss, statt deine Anzeige auszufüllen.

Während das Fenster geöffnet ist, zieht alle paar Sekunden ein grüner Schimmer über die Grafik und lässt sie dann wieder still stehen. Deine eigene Grafik bekommt ihn auch, solange darin jedes Zeichen eine Spalte breit ist — alles, was _Set From Image_ erzeugt, ist es. Aus Emoji oder Zeichen mit doppelter Breite aufgebaute Grafik bleibt stattdessen still stehen, und das gilt auch für den Bildschirm, wenn du eine eigene fastfetch-Konfiguration behältst: Ein stillstehendes Logo ist in diesen Fällen die Animation, die sich zurückhält, statt zu versagen, denn ein Schimmer, der darüber hinweggleitet, würde den Rest der Zeile an der falschen Stelle landen lassen.

 ![branding-about](images/branding-about.webp)

### Bilder selbst konvertieren

Beide _Set From Image_-Optionen rufen lediglich `omarchy transcode ascii` auf, das du auch direkt ausführen kannst, wenn du die Kontrolle über die Konvertierung haben willst:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Es nimmt `--width` und `--height` in Terminalspalten und -zeilen, einen `--mode` von entweder `braille` (der Standard und viel feiner) oder `block`, einen `--threshold`-Prozentwert, der entscheidet, welche Pixel als Teil des Logos gelten, und `--invert` für den Fall, dass dein Logo hell auf dunklem Hintergrund ist. Wenn bei einer Konvertierung nur ein Klecks herauskommt, ist der Schwellenwert meist der Regler, an dem du drehen musst.

### Worte statt eines Logos

`omarchy ascii` zeichnet Text in Delta Corps Priest 1, der FIGlet-Schrift, in der auch die Omarchy-Wortmarke selbst gezeichnet ist, sodass ein Bildschirmschoner etwas sagen kann, statt ein Bild zu zeigen:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Es nimmt den Text als Argumente entgegen oder liest ihn aus einer Pipe, wenn keine angegeben werden. Die Schrift enthält nur Buchstaben und Leerzeichen — sie wurde ohne Ziffern oder Satzzeichen gezeichnet —, sodass alles andere verworfen und auf stderr benannt wird, statt still verschluckt zu werden.
