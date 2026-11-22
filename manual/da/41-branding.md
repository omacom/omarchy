# Branding

Omarchy lader dig indstille dit firmalogo eller et personligt billede til både opstartsoplåsningen, pauseskærmen og Om-skærmen.

### Opstartsoplåsning

Du kan bruge `omarchy plymouth preview` til at se, hvordan dit eget logo og dine egne farver ville se ud. Den tager en baggrundsfarve, en tekstfarve, en logo-png og en sti til forhåndsvisningsbilledet:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Anvend derefter opsætningen med `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, hvilket også giver SDDM-loginskærmen de samme farver og det samme logo. Hvis du vil fortryde, kan du bruge `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Pauseskærm

Du kan ændre det logo, der bruges til pauseskærmen, under _Udseende > Branding > Pauseskærm_. Det er et ASCII-logo, så du kan redigere teksten direkte, men du kan også give den et png- eller svg-billede, så konverterer vi det til ASCII. Det ser ret fedt ud.

 ![branding-screensaver](images/branding-screensaver.webp)

Der er tre punkter i den menu:

- **Rediger tekst** åbner `~/.config/omarchy/branding/screensaver.txt` i din editor. Skriv eller indsæt, hvad du vil — ASCII-kunst, dit navn, et grimt ord. Gem og afslut, så starter pauseskærmen med det samme, så du kan se den.
- **Indstil fra billede** åbner en filvælger til en png eller svg, konverterer den til ASCII og viser dig resultatet. Logoer med en tydelig silhuet fungerer langt bedre end fotos.
- **Gendan standard** sætter Omarchy-logoet tilbage.

### Om-skærm

De samme tre muligheder findes under _Udseende > Branding > Om_ til _Om_-skærmen, du får fra Omarchy-menuen, og de fungerer på samme måde — filen er `~/.config/omarchy/branding/about.txt`, og Om-vinduet dukker op efter hver ændring. Om-grafikken konverteres til en mindre størrelse end pauseskærmens, da den skal passe i et vindue i stedet for at fylde hele din skærm.

Mens vinduet er åbent, læner et bånd af skarpt hvidt lys sig hen over grafikken med få sekunders mellemrum og efterlader den derefter i ro igen. Din egen grafik får det også, så længe hvert tegn i den er én kolonne bredt — det er alt, hvad _Indstil fra billede_ producerer. Grafik bygget af emoji eller tegn med dobbelt bredde forbliver i stedet i ro, og det gør skærmen også, hvis du beholder din egen fastfetch-konfiguration: Et logo i ro i de tilfælde er animationen, der holder sig væk, snarere end at fejle, da det at lade et lysglimt glide hen over dem ville få resten af linjen til at lande det forkerte sted.

 ![branding-about](images/branding-about.webp)

### Konvertér selv billeder

Begge muligheder under _Indstil fra billede_ kalder blot `omarchy transcode ascii`, som du kan køre direkte, hvis du vil have kontrol over konverteringen:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Den tager `--width` og `--height` i terminalkolonner og -rækker, en `--mode` på enten `braille` (standarden og meget finere) eller `block`, en `--threshold`-procent til at afgøre, hvilke pixels der tæller som en del af logoet, og `--invert` til når dit logo er lyst på en mørk baggrund. Hvis en konvertering ender som en klat, er tærsklen normalt den knap, du skal dreje på.

### Ord i stedet for et logo

`omarchy ascii` tegner tekst i Delta Corps Priest 1, den FIGlet-skrifttype, som selve Omarchy-ordmærket er tegnet i, så en pauseskærm kan sige noget i stedet for at vise et billede:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Den tager teksten som argumenter eller læser den fra en pipe, når den ikke får nogen. Skrifttypen indeholder kun bogstaver og mellemrum — den blev tegnet uden tal eller tegnsætning — så alt andet fjernes og nævnes på stderr i stedet for stille at blive slugt.
