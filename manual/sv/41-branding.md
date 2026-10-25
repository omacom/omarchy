# Branding

Omarchy låter dig ställa in din företagslogotyp eller personliga bild för både upplåsningen vid start, skärmsläckaren och Om-skärmen.

### Upplåsning vid start

Du kan använda `omarchy plymouth preview` för att se hur din anpassade logotyp och dina färger skulle se ut. Den tar en bakgrundsfärg, en textfärg, en png-logotyp och en sökväg för förhandsgranskningsbilden:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Tillämpa sedan konfigurationen med `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, vilket också ger SDDM-inloggningsskärmen samma färger och logotyp. Om du vill återställa kan du använda `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Skärmsläckare

Du kan ändra logotypen som används för skärmsläckaren under _Appearance > Branding > Screensaver_. Det är en ASCII-logotyp, så du kan redigera texten direkt, men du kan också ge den en png- eller svg-bild, så konverterar vi den till ASCII. Det ser ganska coolt ut.

 ![branding-screensaver](images/branding-screensaver.webp)

Det finns tre poster i den menyn:

- **Edit Text** öppnar `~/.config/omarchy/branding/screensaver.txt` i din textredigerare. Skriv eller klistra in vad du vill — ASCII-konst, ditt namn, ett fult ord. Spara och avsluta, så startar skärmsläckaren omedelbart så att du kan se den.
- **Set From Image** öppnar en filväljare för en png eller svg, konverterar den till ASCII och visar dig resultatet. Logotyper med en tydlig silhuett fungerar mycket bättre än foton.
- **Restore Default** sätter tillbaka Omarchy-logotypen.

### Om-skärmen

Samma tre alternativ finns under _Appearance > Branding > About_ för _About_-skärmen som du får från Omarchy-menyn, och de fungerar identiskt — filen är `~/.config/omarchy/branding/about.txt`, och About-fönstret dyker upp efter varje ändring. About-konsten konverteras till en mindre storlek än skärmsläckarens, eftersom den måste få plats i ett fönster i stället för att fylla hela din skärm.

Medan fönstret är öppet sveper en grön glimt över konsten med några sekunders mellanrum och lämnar den sedan stilla igen. Din egen konst får den också, så länge varje tecken i den är en kolumn brett — allt som _Set From Image_ producerar är det. Konst byggd av emoji eller tecken med dubbel bredd förblir i stället stilla, och det gör skärmen också om du behåller en egen fastfetch-konfiguration: en stilla logotyp i de fallen är animationen som håller sig undan snarare än den som misslyckas, eftersom en glimt som skjuts över dem skulle få resten av raden att hamna på fel plats.

 ![branding-about](images/branding-about.webp)

### Konvertera bilder själv

Båda _Set From Image_-alternativen anropar bara `omarchy transcode ascii`, som du kan köra direkt om du vill ha kontroll över konverteringen:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Den tar `--width` och `--height` i terminalkolumner och -rader, ett `--mode` med antingen `braille` (standard, och mycket finare) eller `block`, en `--threshold`-procentsats för att avgöra vilka pixlar som räknas som en del av logotypen, och `--invert` för när din logotyp är ljus på en mörk bakgrund. Om en konvertering blir till en klump är tröskeln vanligtvis ratten att vrida på.

### Ord i stället för en logotyp

`omarchy ascii` ritar text i Delta Corps Priest 1, FIGlet-typsnittet som själva Omarchy-ordmärket är ritat i, så en skärmsläckare kan säga något snarare än visa en bild:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Den tar texten som argument, eller läser den från en pipe när den inte får någon. Typsnittet innehåller endast bokstäver och mellanslag — det ritades utan siffror eller skiljetecken — så allt annat tappas bort och namnges på stderr i stället för att tyst sväljas.
