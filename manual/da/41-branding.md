# Branding

Omarchy lader dig indstille dit firmalogo eller dit personlige billede til både pauseskærmen og Om-skærmen.

### Pauseskærm

Du kan ændre det logo, der bruges til pauseskærmen, under _Udseende > Branding > Pauseskærm_. Det er et ASCII-logo, så du kan redigere teksten direkte, men du kan også give det et png- eller svg-billede, så konverterer vi det til ASCII. Det ser ret fedt ud.

 ![branding-screensaver](images/branding-screensaver.webp)

Der er tre punkter i den menu:

- **Rediger tekst** åbner `~/.config/omarchy/branding/screensaver.txt` i din editor. Skriv eller indsæt lige, hvad du vil — ASCII-kunst, dit navn, et grimt ord. Gem og luk, så starter pauseskærmen med det samme, så du kan se det.
- **Indstil fra billede** åbner en filvælger til en png eller svg, konverterer den til ASCII og viser dig resultatet. Logoer med en tydelig silhuet fungerer langt bedre end fotos.
- **Gendan standard** sætter Omarchy-logoet tilbage.

### Om-skærm

De samme tre muligheder findes under _Udseende > Branding > Om_ til den _Om_-skærm, du får fra Omarchy-menuen, og de fungerer på præcis samme måde — filen er `~/.config/omarchy/branding/about.txt`, og Om-vinduet dukker op efter hver ændring. Om-kunsten konverteres til en mindre størrelse end pauseskærmens, eftersom den skal passe i et vindue i stedet for at fylde hele din skærm.

Mens vinduet er åbent, læner et bånd af skarpt hvidt lys sig hen over kunsten med få sekunders mellemrum og lader den derefter stå stille igen. Din egen kunst får det også, så længe hvert tegn i den er én kolonne bredt — og det er alt, hvad _Indstil fra billede_ producerer. Kunst bygget af emoji eller tegn med dobbelt bredde forbliver i stedet stille, og det gør skærmen også, hvis du beholder en fastfetch-konfiguration af din egen: Et stille logo er i de tilfælde animationen, der holder sig væk, frem for en fejl, eftersom det at lade et glimt glide hen over dem ville få resten af linjen til at lande det forkerte sted.

 ![branding-about](images/branding-about.webp)

### Sådan konverterer du selv billeder

Begge _Indstil fra billede_-muligheder kalder bare `omarchy transcode ascii`, som du kan køre direkte, hvis du vil have kontrol over konverteringen:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Den tager `--width` og `--height` i terminalkolonner og -rækker, en `--mode` på enten `braille` (standarden og meget finere) eller `block`, en `--threshold`-procent til at afgøre, hvilke pixels der tæller som en del af logoet, og `--invert`, når dit logo er lyst på en mørk baggrund. Hvis en konvertering ender som en klat, er det som regel threshold, du skal skrue på.

### Ord i stedet for et logo

`omarchy ascii` tegner tekst i Delta Corps Priest 1, den FIGlet-skrifttype, som selve Omarchy-ordmærket er tegnet i, så en pauseskærm kan sige noget frem for at vise et billede:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Den tager teksten som argumenter eller læser den fra en pipe, når den ikke får nogen. Skrifttypen indeholder kun bogstaver og mellemrum — den blev tegnet uden cifre eller tegnsætning — så alt andet droppes og nævnes på stderr i stedet for stille at blive slugt.
