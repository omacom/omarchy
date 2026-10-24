# Branding

Met Omarchy kun je je bedrijfslogo of persoonlijke afbeelding instellen voor zowel de opstartontgrendeling, de schermbeveiliging als het Over-scherm.

### Opstartontgrendeling

Je kunt `omarchy plymouth preview` gebruiken om te zien hoe je aangepaste logo en kleuren eruit zouden zien. Het neemt een achtergrondkleur, een tekstkleur, een logo-png en een pad voor de voorbeeldafbeelding:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Pas de instelling vervolgens toe met `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, wat het SDDM-inlogscherm ook dezelfde kleuren en hetzelfde logo geeft. Als je wilt terugdraaien, kun je `omarchy plymouth reset` gebruiken.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Schermbeveiliging

Je kunt het logo dat voor de schermbeveiliging wordt gebruikt wijzigen onder _Stijl > Screensaver_. Het is een ASCII-logo, dus je kunt de tekst direct bewerken, maar je kunt hem ook een png- of svg-afbeelding geven, en wij zetten die om naar ASCII. Het ziet er behoorlijk cool uit.

 ![branding-screensaver](images/branding-screensaver.webp)

Er zijn drie opties in dat menu:

- **Edit Text** opent `~/.config/omarchy/branding/screensaver.txt` in je editor. Typ of plak wat je wilt — ASCII-art, je naam, een grof woord. Sla op en sluit af, en de schermbeveiliging start meteen zodat je het kunt zien.
- **Set From Image** opent een bestandsselector voor een png of svg, zet hem om naar ASCII en toont je het resultaat. Logo's met een duidelijk silhouet werken veel beter dan foto's.
- **Restore Default** zet het Omarchy-logo terug.

### Over-scherm

Dezelfde drie opties staan onder _Stijl > About_ voor het _Over_-scherm dat je krijgt via het Omarchy-menu, en ze werken identiek — het bestand is `~/.config/omarchy/branding/about.txt`, en het Over-venster verschijnt na elke wijziging. De Over-art wordt omgezet naar een kleiner formaat dan die van de schermbeveiliging, omdat hij in een venster moet passen in plaats van je scherm te vullen.

Terwijl het venster open is, leunt er om de paar seconden een glinstering van groen over de art heen en laat hem dan weer stil. Je eigen art krijgt dat ook, zolang elk teken erin één kolom breed is — alles wat _Set From Image_ produceert is dat. Art gebouwd uit emoji of tekens met dubbele breedte blijft in plaats daarvan stil, en dat geldt ook voor het scherm als je een eigen fastfetch-config behoudt: een stil logo in die gevallen is de animatie die uit de weg blijft in plaats van te falen, omdat het schuiven van een glinstering eroverheen de rest van de regel op de verkeerde plek zou laten belanden.

 ![branding-about](images/branding-about.webp)

### Zelf afbeeldingen omzetten

Beide _Set From Image_-opties roepen gewoon `omarchy transcode ascii` aan, wat je direct kunt uitvoeren als je controle wilt over de conversie:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Het neemt `--width` en `--height` in terminalkolommen en -rijen, een `--mode` van `braille` (de standaard, en veel fijner) of `block`, een `--threshold`-percentage om te beslissen welke pixels meetellen als deel van het logo, en `--invert` voor als je logo licht is op een donkere achtergrond. Als een conversie uitkomt als een blob, is de threshold meestal de knop om aan te draaien.

### Woorden in plaats van een logo

`omarchy ascii` tekent tekst in Delta Corps Priest 1, het FIGlet-lettertype waarin het Omarchy-woordmerk zelf is getekend, zodat een schermbeveiliging iets kan zeggen in plaats van een plaatje te tonen:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Het neemt de tekst als argumenten, of leest hem uit een pipe als er geen zijn gegeven. Het lettertype bevat alleen letters en spaties — het is getekend zonder cijfers of interpunctie — dus al het andere wordt weggelaten en benoemd op stderr in plaats van stilletjes te worden ingeslikt.
