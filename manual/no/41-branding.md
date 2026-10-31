# Branding

Omarchy lar deg angi firmaets logo eller et personlig bilde for både oppstartsopplåsingen, skjermspareren og om-skjermen.

### Oppstartsopplåsing

Du kan bruke `omarchy plymouth preview` for å se hvordan den tilpassede logoen og fargene dine ville sett ut. Den tar en bakgrunnsfarge, en tekstfarge, en logo-png og en sti til forhåndsvisningsbildet:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Deretter bruker du oppsettet med `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, som også gir SDDM-innloggingsskjermen de samme fargene og logoen. Hvis du vil angre, kan du bruke `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Skjermsparer

Du kan endre logoen som brukes til skjermspareren under _Utseende > Branding > Skjermsparer_. Det er en ASCII-logo, så du kan redigere teksten direkte, men du kan også gi den et png- eller svg-bilde, så konverterer vi det til ASCII. Det ser ganske kult ut.

 ![branding-screensaver](images/branding-screensaver.webp)

Det er tre oppføringer i den menyen:

- **Rediger tekst** åpner `~/.config/omarchy/branding/screensaver.txt` i redigeringsprogrammet ditt. Skriv eller lim inn hva du vil — ASCII-kunst, navnet ditt, et stygt ord. Lagre og avslutt, så starter skjermspareren umiddelbart slik at du kan se den.
- **Angi fra bilde** åpner en filvelger for en png eller svg, konverterer den til ASCII og viser deg resultatet. Logoer med en tydelig silhuett fungerer langt bedre enn fotografier.
- **Gjenopprett standard** setter Omarchy-logoen tilbake.

### Om-skjermen

De samme tre alternativene ligger under _Utseende > Branding > Om_ for _Om_-skjermen du får fra Omarchy-menyen, og de fungerer på nøyaktig samme måte — filen er `~/.config/omarchy/branding/about.txt`, og Om-vinduet dukker opp etter hver endring. Om-grafikken konverteres til en mindre størrelse enn skjermsparerens, siden den må få plass i et vindu i stedet for å fylle hele skjermen.

Mens vinduet er åpent, glir et grønt glimt over grafikken med noen sekunders mellomrom og lar den deretter ligge stille igjen. Din egen grafikk får det også, så lenge hvert tegn i den er én kolonne bredt — alt _Angi fra bilde_ lager, er det. Grafikk bygd opp av emoji eller tegn med dobbel bredde holder seg i stedet stille, og det gjør skjermen også hvis du beholder en egen fastfetch-konfigurasjon: en stille logo i de tilfellene er animasjonen som holder seg unna i stedet for å feile, siden det å skyve et glimt over dem ville fått resten av linjen til å havne på feil sted.

 ![branding-about](images/branding-about.webp)

### Konverter bilder selv

Begge _Angi fra bilde_-alternativene kaller bare `omarchy transcode ascii`, som du kan kjøre direkte hvis du vil ha kontroll over konverteringen:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Den tar `--width` og `--height` i terminalkolonner og -rader, en `--mode` som enten er `braille` (standardvalget, og mye finere) eller `block`, en `--threshold` i prosent for å avgjøre hvilke piksler som regnes som en del av logoen, og `--invert` for når logoen din er lys på en mørk bakgrunn. Hvis en konvertering blir en klump, er det vanligvis terskelen du skal skru på.

### Ord i stedet for en logo

`omarchy ascii` tegner tekst i Delta Corps Priest 1, FIGlet-skrifttypen selve Omarchy-ordmerket er tegnet i, slik at en skjermsparer kan si noe i stedet for å vise et bilde:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Den tar teksten som argumenter, eller leser den fra en pipe når den ikke får noen. Skrifttypen har bare bokstaver og mellomrom — den ble tegnet uten sifre eller tegnsetting — så alt annet slippes og nevnes på stderr i stedet for å bli svelget i stillhet.
