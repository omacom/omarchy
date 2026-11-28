# Varumärkning

Omarchy låter dig ställa in din företagslogotyp eller en personlig bild för både upplåsningen vid start, skärmsläckaren och om-skärmen.

### Upplåsning vid start

Du kan använda `omarchy plymouth preview` för att se hur din anpassade logotyp och dina färger skulle se ut. Den tar en bakgrundsfärg, en textfärg, en png-logotyp och en sökväg för förhandsgranskningsbilden:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Sedan tillämpar du konfigurationen med `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, vilket också ger SDDM-inloggningsskärmen samma färger och logotyp. Om du vill återställa kan du använda `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Skärmsläckare

Du kan ändra logotypen som används för skärmsläckaren under _Utseende > Varumärkning > Skärmsläckare_. Det är en ASCII-logotyp, så du kan redigera texten direkt, men du kan också ge den en png- eller svg-bild, så konverterar vi den till ASCII. Det ser ganska coolt ut.

 ![branding-screensaver](images/branding-screensaver.webp)

Det finns tre alternativ i den menyn:

- **Redigera text** öppnar `~/.config/omarchy/branding/screensaver.txt` i din editor. Skriv eller klistra in vad du vill — ASCII-konst, ditt namn, ett fult ord. Spara och avsluta, så startar skärmsläckaren omedelbart så att du kan se den.
- **Ställ in från bild** öppnar en filväljare för en png eller svg, konverterar den till ASCII och visar dig resultatet. Logotyper med en tydlig silhuett fungerar mycket bättre än foton.
- **Återställ standard** sätter tillbaka Omarchy-logotypen.

### Om-skärmen

Samma tre alternativ finns under _Utseende > Varumärkning > Om_ för _Om_-skärmen som du får från Omarchy-menyn, och de fungerar på samma sätt — filen är `~/.config/omarchy/branding/about.txt`, och Om-fönstret dyker upp efter varje ändring. Om-konsten konverteras till en mindre storlek än skärmsläckarens, eftersom den måste få plats i ett fönster i stället för att fylla hela skärmen.

Medan fönstret är öppet lutar ett band av starkt vitt ljus över konsten med några sekunders mellanrum och lämnar den sedan stilla igen. Din egen konst får det också, så länge varje tecken i den är en kolumn brett — allt som _Ställ in från bild_ producerar är det. Konst byggd av emoji eller tecken med dubbel bredd förblir i stället stilla, och det gör skärmen också om du behåller en egen fastfetch-konfiguration: en stilla logotyp i de fallen är animationen som håller sig undan snarare än att den misslyckas, eftersom att skjuta en glimt över dem skulle få resten av raden att hamna på fel plats.

 ![branding-about](images/branding-about.webp)

### Konvertera bilder själv

Båda alternativen för _Ställ in från bild_ anropar bara `omarchy transcode ascii`, som du kan köra direkt om du vill ha kontroll över konverteringen:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Den tar `--width` och `--height` i terminalkolumner och -rader, ett `--mode` med antingen `braille` (standard, och mycket finare) eller `block`, en `--threshold`-procent för att avgöra vilka pixlar som räknas som en del av logotypen, och `--invert` för när din logotyp är ljus på en mörk bakgrund. Om en konvertering blir en klump är det oftast threshold som är ratten att vrida på.

### Ord i stället för en logotyp

`omarchy ascii` ritar text i Delta Corps Priest 1, det FIGlet-typsnitt som själva Omarchy-ordmärket är ritat i, så en skärmsläckare kan säga något i stället för att visa en bild:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Den tar texten som argument, eller läser den från en pipe när den inte får någon. Typsnittet innehåller bara bokstäver och mellanslag — det ritades utan siffror eller skiljetecken — så allt annat tas bort och namnges på stderr i stället för att tyst sväljas.
