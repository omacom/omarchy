# Branding

Omarchy lar deg sette firmalogoen din eller et personlig bilde for både skjermspareren og About-skjermen.

### Skjermsparer

Du kan endre logoen som brukes til skjermspareren under _Appearance > Branding > Screensaver_. Det er en ASCII-logo, så du kan redigere teksten direkte, men du kan også gi den et png- eller svg-bilde, så konverterer vi det til ASCII. Det ser ganske kult ut.

 ![branding-screensaver](images/branding-screensaver.webp)

Det er tre oppføringer i den menyen:

- **Edit Text** åpner `~/.config/omarchy/branding/screensaver.txt` i tekstredigereren din. Skriv eller lim inn hva du vil — ASCII-kunst, navnet ditt, et stygt ord. Lagre og avslutt, så starter skjermspareren umiddelbart, slik at du kan se den.
- **Set From Image** åpner en filvelger for en png eller svg, konverterer den til ASCII og viser deg resultatet. Logoer med en tydelig silhuett fungerer langt bedre enn fotografier.
- **Restore Default** setter Omarchy-logoen tilbake.

### About-skjermen

De samme tre alternativene finnes under _Appearance > Branding > About_ for _About_-skjermen du får fra Omarchy-menyen, og de fungerer helt likt — filen er `~/.config/omarchy/branding/about.txt`, og About-vinduet spretter opp etter hver endring. About-kunsten konverteres til en mindre størrelse enn skjermsparerens, siden den må få plass i et vindu i stedet for å fylle hele skjermen din.

Mens vinduet er åpent, legger et bånd av sterkt hvitt lys seg på skrå over kunsten med noen få sekunders mellomrom og lar den så være i ro igjen. Din egen kunst får det også, så lenge hvert tegn i den er én kolonne bredt — og det er alt _Set From Image_ lager. Kunst bygget av emoji eller tegn med dobbel bredde holder seg i stedet stille, og det gjør skjermen også hvis du beholder en egen fastfetch-konfigurasjon: en stille logo i de tilfellene er animasjonen som holder seg unna i stedet for å mislykkes, siden å skyve et glimt over dem ville fått resten av linjen til å havne på feil sted.

 ![branding-about](images/branding-about.webp)

### Konverter bilder selv

Begge _Set From Image_-alternativene kaller bare `omarchy transcode ascii`, som du kan kjøre direkte hvis du vil ha kontroll over konverteringen:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Den tar `--width` og `--height` i terminalkolonner og -rader, en `--mode` med enten `braille` (standardvalget, og mye finere) eller `block`, en `--threshold` i prosent for å avgjøre hvilke piksler som regnes som en del av logoen, og `--invert` for når logoen din er lys på mørk bakgrunn. Hvis en konvertering blir en klump, er terskelen vanligvis knotten å skru på.

### Ord i stedet for en logo

`omarchy ascii` tegner tekst i Delta Corps Priest 1, FIGlet-fonten selve Omarchy-ordmerket er tegnet i, så en skjermsparer kan si noe i stedet for å vise et bilde:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Den tar teksten som argumenter, eller leser den fra en pipe når den ikke får noen. Fonten har bare bokstaver og mellomrom — den ble tegnet uten sifre eller tegnsetting — så alt annet blir droppet og navngitt på stderr i stedet for å svelges i stillhet.
