# Branding

Met Omarchy kun je je bedrijfslogo of een persoonlijke afbeelding instellen voor zowel de screensaver als het Over-scherm.

### Screensaver

Je kunt het logo voor de screensaver wijzigen via _Appearance > Branding > Screensaver_. Het is een ASCII-logo, dus je kunt de tekst direct bewerken, maar je kunt het ook een png- of svg-afbeelding geven, en dan zetten wij die om naar ASCII. Dat ziet er behoorlijk gaaf uit.

 ![branding-screensaver](images/branding-screensaver.webp)

Dat menu heeft drie opties:

- **Edit Text** opent `~/.config/omarchy/branding/screensaver.txt` in je editor. Typ of plak wat je maar wilt — ASCII-art, je naam, een grof woord. Sla op en sluit af, en de screensaver start meteen zodat je het kunt zien.
- **Set From Image** opent een bestandsselector voor een png of svg, zet die om naar ASCII en toont je het resultaat. Logo's met een duidelijk silhouet werken veel beter dan foto's.
- **Restore Default** zet het Omarchy-logo terug.

### Over-scherm

Dezelfde drie opties staan onder _Appearance > Branding > About_ voor het _About_-scherm dat je via het Omarchy-menu opent, en ze werken identiek — het bestand is `~/.config/omarchy/branding/about.txt`, en het About-venster verschijnt na elke wijziging. De About-art wordt omgezet naar een kleiner formaat dan die van de screensaver, omdat het in een venster moet passen in plaats van je hele scherm te vullen.

Terwijl het venster open is, schuift er om de paar seconden een band fel wit licht over de art heen, waarna die weer stil blijft staan. Je eigen art krijgt dat ook, zolang elk teken erin één kolom breed is — en dat geldt voor alles wat _Set From Image_ maakt. Art opgebouwd uit emoji of tekens met dubbele breedte blijft in plaats daarvan stilstaan, en dat geldt ook voor het scherm als je een eigen fastfetch-config aanhoudt: een stilstaand logo is in die gevallen de animatie die uit de weg blijft in plaats van faalt, omdat een glans daaroverheen schuiven de rest van de regel op de verkeerde plek zou laten belanden.

 ![branding-about](images/branding-about.webp)

### Zelf afbeeldingen omzetten

Beide _Set From Image_-opties roepen alleen maar `omarchy transcode ascii` aan, wat je ook direct kunt uitvoeren als je zelf controle over de conversie wilt:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Het neemt `--width` en `--height` in terminalkolommen en -rijen, een `--mode` van `braille` (de standaard, en veel fijner) of `block`, een `--threshold`-percentage om te bepalen welke pixels als onderdeel van het logo tellen, en `--invert` voor als je logo licht is op een donkere achtergrond. Als een conversie als een klodder uit de bus komt, is de threshold meestal de knop waar je aan moet draaien.

### Woorden in plaats van een logo

`omarchy ascii` tekent tekst in Delta Corps Priest 1, het FIGlet-lettertype waarin het Omarchy-woordmerk zelf ook is getekend, zodat een screensaver iets kan zeggen in plaats van een plaatje te tonen:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Het neemt de tekst als argumenten, of leest die uit een pipe als je er geen opgeeft. Het lettertype bevat alleen letters en spaties — het is getekend zonder cijfers of leestekens — dus al het andere wordt weggelaten en op stderr benoemd in plaats van stilletjes ingeslikt.
