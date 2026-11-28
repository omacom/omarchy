# Branding

Met Omarchy kun je je bedrijfslogo of persoonlijke afbeelding instellen voor zowel de ontgrendeling bij het opstarten, de schermbeveiliging als het Over-scherm.

### Ontgrendeling bij het opstarten

Je kunt `omarchy plymouth preview` gebruiken om te zien hoe je aangepaste logo en kleuren eruit zouden zien. Het neemt een achtergrondkleur, een tekstkleur, een logo-png en een pad voor de voorbeeldafbeelding:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Pas de configuratie vervolgens toe met `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, waarmee ook het SDDM-inlogscherm dezelfde kleuren en hetzelfde logo krijgt. Als je dit wilt terugdraaien, kun je `omarchy plymouth reset` gebruiken.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Schermbeveiliging

Je kunt het logo dat voor de schermbeveiliging wordt gebruikt wijzigen onder _Appearance > Branding > Screensaver_. Het is een ASCII-logo, dus je kunt de tekst rechtstreeks bewerken, maar je kunt het ook een png- of svg-afbeelding geven, en dan zetten wij die om naar ASCII. Het ziet er behoorlijk gaaf uit.

 ![branding-screensaver](images/branding-screensaver.webp)

Dat menu bevat drie opties:

- **Edit Text** opent `~/.config/omarchy/branding/screensaver.txt` in je editor. Typ of plak wat je maar wilt — ASCII-kunst, je naam, een grof woord. Sla op en sluit af, en de schermbeveiliging start meteen zodat je het kunt zien.
- **Set From Image** opent een bestandsselector voor een png of svg, zet die om naar ASCII en laat je het resultaat zien. Logo's met een duidelijk silhouet werken veel beter dan foto's.
- **Restore Default** zet het Omarchy-logo terug.

### Over-scherm

Dezelfde drie opties staan onder _Appearance > Branding > About_ voor het _About_-scherm dat je via het Omarchy-menu opent, en ze werken identiek — het bestand is `~/.config/omarchy/branding/about.txt`, en het About-venster verschijnt na elke wijziging. De About-afbeelding wordt naar een kleiner formaat omgezet dan die van de schermbeveiliging, omdat deze in een venster moet passen in plaats van je hele scherm te vullen.

Terwijl het venster open is, schuift er om de paar seconden een band van fel wit licht schuin over de afbeelding heen en laat die daarna weer stil achter. Je eigen afbeelding krijgt dat ook, zolang elk teken erin één kolom breed is — en dat geldt voor alles wat _Set From Image_ produceert. Afbeeldingen die zijn opgebouwd uit emoji of tekens met dubbele breedte blijven in plaats daarvan stil, en dat geldt ook voor het scherm als je je eigen fastfetch-config behoudt: een stil logo is in die gevallen de animatie die uit de weg blijft in plaats van faalt, omdat een glinstering eroverheen schuiven ervoor zou zorgen dat de rest van de regel op de verkeerde plek terechtkomt.

 ![branding-about](images/branding-about.webp)

### Zelf afbeeldingen omzetten

Beide _Set From Image_-opties roepen alleen maar `omarchy transcode ascii` aan, wat je rechtstreeks kunt uitvoeren als je controle wilt over de omzetting:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Het neemt `--width` en `--height` in terminalkolommen en -rijen, een `--mode` van `braille` (de standaard, en veel fijner) of `block`, een `--threshold`-percentage om te bepalen welke pixels als onderdeel van het logo tellen, en `--invert` voor wanneer je logo licht is op een donkere achtergrond. Als een omzetting eruitkomt als een vlek, is de threshold meestal de knop waaraan je moet draaien.

### Woorden in plaats van een logo

`omarchy ascii` tekent tekst in Delta Corps Priest 1, het FIGlet-lettertype waarin het Omarchy-woordmerk zelf is getekend, zodat een schermbeveiliging iets kan zeggen in plaats van een afbeelding te tonen:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Het neemt de tekst als argumenten, of leest deze uit een pipe wanneer er geen worden gegeven. Het lettertype bevat alleen letters en spaties — het is getekend zonder cijfers of leestekens — dus al het andere wordt weggelaten en op stderr vermeld in plaats van stilletjes ingeslikt.
