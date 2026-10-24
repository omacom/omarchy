# Varumärke

Omarchy låter dig ställa in din företagslogotyp eller personliga bild för både startupplåsningen, skärmsläckaren och om-skärmen.

### Startupplåsning

Du kan använda `omarchy plymouth preview` för att se hur din anpassade logotyp och dina färger skulle se ut. Det tar en bakgrundsfärg, en textfärg, en logotyp i png och en sökväg för förhandsgranskningsbilden:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Tillämpa sedan konfigurationen med `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, vilket också ger SDDM-inloggningsskärmen samma färger och logotyp. Om du vill återställa kan du använda `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Skärmsläckare

Du kan ändra logotypen som används för skärmsläckaren under _Stil > Skärmsläckare_. Det är en ASCII-logotyp, så du kan redigera texten direkt, men du kan också ge den en png- eller svg-bild, så konverterar vi den till ASCII. Det ser ganska coolt ut.

 ![branding-screensaver](images/branding-screensaver.webp)

Det finns tre poster i den menyn:

- **Redigera text** öppnar `~/.config/omarchy/branding/screensaver.txt` i din editor. Skriv eller klistra in vad du vill — ASCII-konst, ditt namn, ett grovt ord. Spara och avsluta, så startar skärmsläckaren omedelbart så att du kan se den.
- **Från bild** öppnar en filväljare för en png eller svg, konverterar den till ASCII och visar dig resultatet. Logotyper med en tydlig silhuett fungerar mycket bättre än foton.
- **Återställ standard** sätter tillbaka Omarchy-logotypen.

### Om-skärmen

Samma tre alternativ finns under _Stil > Om_ för _Om_-skärmen du får från Omarchy-menyn, och de fungerar identiskt — filen är `~/.config/omarchy/branding/about.txt`, och Om-fönstret dyker upp efter varje ändring. Om-konsten konverteras till en mindre storlek än skärmsläckarens, eftersom den måste få plats i ett fönster snarare än att fylla din skärm.

Medan fönstret är öppet lutar en grön glimt över konsten med några sekunders mellanrum och lämnar den sedan stilla igen. Din egen konst får den också, så länge varje tecken i den är en kolumn bred — allt som _Från bild_ producerar är det. Konst byggd av emoji eller dubbelbreda tecken förblir i stället stilla, och det gör skärmen också om du behåller en egen fastfetch-konfiguration: en stilla logotyp i de fallen är animationen som håller sig ur vägen snarare än att den misslyckas, eftersom att skjuta en glimt över dem skulle placera resten av raden på fel plats.

 ![branding-about](images/branding-about.webp)

### Konvertera bilder själv

Båda _Från bild_-alternativen anropar bara `omarchy transcode ascii`, som du kan köra direkt om du vill ha kontroll över konverteringen:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Det tar `--width` och `--height` i terminalkolumner och -rader, ett `--mode` på antingen `braille` (standard, och mycket finare) eller `block`, en `--threshold`-procentsats för att avgöra vilka pixlar som räknas som en del av logotypen, och `--invert` för när din logotyp är ljus på mörk bakgrund. Om en konvertering blir en klump är tröskeln vanligtvis den ratt man ska vrida på.

### Ord i stället för logotyp

`omarchy ascii` ritar text i Delta Corps Priest 1, FIGlet-typsnittet som själva Omarchy-ordmärket är ritat i, så en skärmsläckare kan säga något snarare än visa en bild:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Den tar texten som argument, eller läser den från en pipe när ingen ges. Typsnittet innehåller endast bokstäver och mellanslag — det ritades utan siffror eller skiljetecken — så allt annat släpps och namnges på stderr snarare än att sväljas i tysthet.
