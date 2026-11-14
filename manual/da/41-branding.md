# Branding

Omarchy lader dig indstille dit firmalogo eller et personligt billede til både opstartsoplåsningen, pauseskærmen og Om-skærmen.

### Opstartsoplåsning

Du kan bruge `omarchy plymouth preview` til at se, hvordan dit eget logo og dine egne farver ville se ud. Den tager en baggrundsfarve, en tekstfarve, en logo-png og en sti til forhåndsvisningsbilledet:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Anvend derefter opsætningen med `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, som også giver SDDM-loginskærmen de samme farver og det samme logo. Hvis du vil fortryde det, kan du bruge `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Pauseskærm

Du kan ændre det logo, der bruges til pauseskærmen, under _Appearance > Branding > Screensaver_. Det er et ASCII-logo, så du kan redigere teksten direkte, men du kan også give den et png- eller svg-billede, så konverterer vi det til ASCII. Det ser ret fedt ud.

 ![branding-screensaver](images/branding-screensaver.webp)

Der er tre punkter i den menu:

- **Edit Text** åbner `~/.config/omarchy/branding/screensaver.txt` i din editor. Skriv eller indsæt, hvad du har lyst til — ASCII-kunst, dit navn, et frækt ord. Gem og luk, så starter pauseskærmen med det samme, så du kan se det.
- **Set From Image** åbner en filvælger til en png eller svg, konverterer den til ASCII og viser dig resultatet. Logoer med en tydelig silhuet fungerer langt bedre end fotos.
- **Restore Default** sætter Omarchy-logoet tilbage.

### Om-skærm

De samme tre muligheder findes under _Appearance > Branding > About_ til den _About_-skærm, du får fra Omarchy-menuen, og de fungerer identisk — filen er `~/.config/omarchy/branding/about.txt`, og About-vinduet dukker op efter hver ændring. About-kunsten konverteres til en mindre størrelse end pauseskærmens, da den skal passe i et vindue i stedet for at fylde hele din skærm.

Mens vinduet er åbent, glider et grønt glimt hen over kunsten med få sekunders mellemrum og lader den derefter stå stille igen. Din egen kunst får det også, så længe hvert tegn i den er én kolonne bred — det er alt, hvad _Set From Image_ producerer. Kunst bygget af emoji eller tegn med dobbelt bredde forbliver i stedet stille, og det gør skærmen også, hvis du beholder en fastfetch-konfiguration, du selv har lavet: et stille logo i de tilfælde er animationen, der holder sig af vejen, snarere end at fejle, eftersom at lade et glimt glide hen over dem ville få resten af linjen til at lande det forkerte sted.

 ![branding-about](images/branding-about.webp)

### Sådan konverterer du selv billeder

Begge _Set From Image_-muligheder kalder blot `omarchy transcode ascii`, som du kan køre direkte, hvis du vil have kontrol over konverteringen:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Den tager `--width` og `--height` i terminalkolonner og -rækker, en `--mode` på enten `braille` (standardindstillingen, og meget finere) eller `block`, en `--threshold`-procent til at afgøre, hvilke pixels der tæller som en del af logoet, og `--invert` til når dit logo er lyst på en mørk baggrund. Hvis en konvertering ender som en klat, er tærsklen som regel den knap, du skal dreje på.

### Ord i stedet for et logo

`omarchy ascii` tegner tekst i Delta Corps Priest 1, den FIGlet-skrifttype, som selve Omarchy-ordmærket er tegnet i, så en pauseskærm kan sige noget i stedet for at vise et billede:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Den tager teksten som argumenter eller læser den fra en pipe, når den ikke får nogen. Skrifttypen rummer kun bogstaver og mellemrum — den blev tegnet uden cifre eller tegnsætning — så alt andet droppes og nævnes på stderr i stedet for stille at blive slugt.
