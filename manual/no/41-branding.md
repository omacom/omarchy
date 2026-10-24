# Merkevare

Omarchy lar deg sette firmalogoen din eller et personlig bilde for både oppstartsopplåsingen, skjermspareren og Om-skjermen.

### Oppstartsopplåsing

Du kan bruke `omarchy plymouth preview` for å se hvordan den egendefinerte logoen og fargene dine ville sett ut. Den tar en bakgrunnsfarge, en tekstfarge, en logo-png og en bane for forhåndsvisningsbildet:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Bruk deretter oppsettet med `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, som også gir SDDM-påloggingsskjermen de samme fargene og logoen. Hvis du vil angre, kan du bruke `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Skjermsparer

Du kan endre logoen som brukes for skjermspareren under _Stil > Skjermsparer_. Det er en ASCII-logo, så du kan redigere teksten direkte, men du kan også gi den et png- eller svg-bilde, så konverterer vi det til ASCII. Det ser ganske kult ut.

 ![branding-screensaver](images/branding-screensaver.webp)

Det er tre oppføringer i den menyen:

- **Rediger tekst** åpner `~/.config/omarchy/branding/screensaver.txt` i editoren din. Skriv eller lim inn hva du vil — ASCII-kunst, navnet ditt, et stygt ord. Lagre og avslutt, så fyrer skjermspareren i gang umiddelbart slik at du kan se det.
- **Sett fra bilde** åpner en filvelger for en png eller svg, konverterer den til ASCII og viser deg resultatet. Logoer med en klar silhuett fungerer langt bedre enn fotoer.
- **Gjenopprett standard** setter Omarchy-logoen tilbake.

### Om-skjerm

De samme tre alternativene finnes under _Stil > Om_ for _Om_-skjermen du får fra Omarchy-menyen, og de fungerer identisk — filen er `~/.config/omarchy/branding/about.txt`, og Om-vinduet spretter opp etter hver endring. Om-kunsten konverteres til en mindre størrelse enn skjermsparerens, siden den må passe i et vindu i stedet for å fylle skjermen din.

Mens vinduet er åpent, lener et grønt gjenskinn seg over kunsten med noen sekunders mellomrom og lar den så stå stille igjen. Din egen kunst får det også, så lenge hvert tegn i den er én kolonne bredt — alt _Sett fra bilde_ produserer er det. Kunst bygget av emoji eller tegn med dobbel bredde står stille i stedet, og det gjør skjermen også hvis du beholder en egen fastfetch-konfigurasjon: en stille logo i de tilfellene er animasjonen som holder seg unna veien i stedet for å feile, siden å skyve et gjenskinn over dem ville landet resten av linjen på feil sted.

 ![branding-about](images/branding-about.webp)

### Konvertere bilder selv

Begge _Sett fra bilde_-alternativene kaller bare `omarchy transcode ascii`, som du kan kjøre direkte hvis du vil ha kontroll over konverteringen:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Den tar `--width` og `--height` i terminalkolonner og -rader, en `--mode` som enten `braille` (standard, og mye finere) eller `block`, en `--threshold`-prosent for å avgjøre hvilke piksler som teller som del av logoen, og `--invert` for når logoen din er lys på mørk bakgrunn. Hvis en konvertering kommer ut som en klump, er terskelen vanligvis knotten å skru på.

### Ord i stedet for en logo

`omarchy ascii` tegner tekst i Delta Corps Priest 1, FIGlet-fonten selve Omarchy-ordmerket er tegnet i, så en skjermsparer kan si noe i stedet for å vise et bilde:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Den tar teksten som argumenter, eller leser den fra en pipe når den ikke får noen. Fonten bærer bare bokstaver og mellomrom — den ble tegnet uten sifre eller tegnsetting — så alt annet droppes og navngis på stderr i stedet for å bli svelget i stillhet.
