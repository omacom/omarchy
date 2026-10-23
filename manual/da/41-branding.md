# Branding

Omarchy giver dig mulighed for at sætte dit firmalogo eller personlige billede til både boot-oplåsningen, pauseskærmen og Om-skærmen.

### Boot-oplåsning

Du kan bruge `omarchy plymouth preview` til at se, hvordan dit brugerdefinerede logo og dine farver ville se ud. Det tager en baggrundsfarve, en tekstfarve, en logo-png og en sti til forhåndsvisningsbilledet:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Anvend derefter opsætningen med `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, som også giver SDDM-login-skærmen de samme farver og logo. Hvis du vil fortryde, kan du bruge `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Pauseskærm

Du kan ændre logoet, der bruges til pauseskærmen, under _Stil > Pauseskærm_. Det er et ASCII-logo, så du kan redigere teksten direkte, men du kan også give det et png- eller svg-billede, og så konverterer vi det til ASCII. Det ser ret fedt ud.

 ![branding-screensaver](images/branding-screensaver.webp)

Der er tre poster i den menu:

- **Rediger tekst** åbner `~/.config/omarchy/branding/screensaver.txt` i din editor. Skriv eller indsæt, hvad du vil — ASCII-kunst, dit navn, et groft ord. Gem og afslut, og pauseskærmen starter med det samme, så du kan se den.
- **Sæt fra billede** åbner en filvælger til en png eller svg, konverterer den til ASCII og viser dig resultatet. Logoer med en klar silhuet fungerer langt bedre end fotos.
- **Gendan standard** sætter Omarchy-logoet tilbage.

### Om-skærm

De samme tre muligheder findes under _Stil > Om_ til _Om_-skærmen, du får fra Omarchy-menuen, og de virker identisk — filen er `~/.config/omarchy/branding/about.txt`, og Om-vinduet dukker op efter hver ændring. Om-kunsten konverteres til en mindre størrelse end pauseskærmens, da den skal passe i et vindue frem for at fylde dit display.

Mens vinduet er åbent, læner et grønt glimt sig hen over kunsten med få sekunders mellemrum og efterlader den derefter stille igen. Din egen kunst får det også, så længe hvert tegn i den er én kolonne bredt — alt, hvad _Sæt fra billede_ producerer, er det. Kunst bygget af emoji eller tegn i dobbelt bredde forbliver i stedet stille, og det gør skærmen også, hvis du beholder din egen fastfetch-konfiguration: et stille logo i de tilfælde er animationen, der holder sig af vejen frem for at fejle, da det at glide et glimt hen over dem ville få resten af linjen til at lande det forkerte sted.

 ![branding-about](images/branding-about.webp)

### Konvertér billeder selv

Begge _Sæt fra billede_-muligheder kalder blot `omarchy transcode ascii`, som du kan køre direkte, hvis du vil have kontrol over konverteringen:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Det tager `--width` og `--height` i terminalkolonner og -rækker, en `--mode` på enten `braille` (standarden og meget finere) eller `block`, en `--threshold`-procentdel til at afgøre, hvilke pixels der tæller som en del af logoet, og `--invert` til, når dit logo er lyst på en mørk baggrund. Hvis en konvertering kommer ud som en klat, er tærsklen som regel den knap, man skal dreje på.

### Ord i stedet for et logo

`omarchy ascii` tegner tekst i Delta Corps Priest 1, den FIGlet-skrifttype, Omarchy-wordmarket selv er tegnet i, så en pauseskærm kan sige noget frem for at vise et billede:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Det tager teksten som argumenter eller læser den fra en pipe, når der ikke gives nogen. Skrifttypen har kun bogstaver og mellemrum — den blev tegnet uden tal eller tegnsætning — så alt andet droppes og navngives på stderr frem for stille at blive slugt.
