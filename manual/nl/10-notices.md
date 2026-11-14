# Meldingen

Meldingen verschijnen in de rechterbovenhoek van het gefocuste scherm. Je kunt ook snel de datum en tijd, de batterijstatus en het huidige weer bekijken met de sneltoetsmeldingen.

## Meldingen

Meldingen van dezelfde app of site stapelen zich op tot een stapel, zodat een praatgraag Slack-kanaal je mislukte build niet van het scherm duwt. Beweeg de muis over een stapel om hem uit te waaieren; er schuift niets nieuws onder je aanwijzer terwijl je aan het lezen bent. Klik op een kaart om naar de bron te springen, klik met de rechtermuisknop, klik met de middelste muisknop of klik op de ✕ om hem te sluiten.

Kaarten bieden aan wat ze bij zich hebben: _Code kopiëren_ voor verificatiecodes (buiten de [klembordgeschiedenis](08-unified-clipboard-history.md) gehouden en na een minuut gewist), plus alle knoppen die de app aanbiedt. Links in de tekst van een melding openen wanneer je erop klikt.

Om ze zonder muis te gebruiken, druk je op `Super + Ctrl + ,`. De nieuwste melding is geselecteerd en de knoppen ervan zijn genummerd: druk op een nummer om er een te gebruiken, `Enter` om de melding aan te klikken, `↑` en `↓` om tussen meldingen te bewegen, `Delete` om er een te sluiten en `Esc` om het toetsenbord terug te geven. Na een paar seconden zonder activiteit laat hij ook vanzelf los.

Het dempen van meldingen houdt ze tegen, behalve Omarchy's eigen bevestigingen, noodmeldingen en verificatiecodes, waar je net om hebt gevraagd. Zet de laatste paar weer op het scherm, tegengehouden of niet, met `Super + Shift + Alt + ,`. De geschiedenis wordt een dag bewaard.

## Sneltoetsmeldingen

### Datum & tijd

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Weer

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

De locatie wordt gedetecteerd op basis van je IP-adres, wat meestal dichtbij genoeg is, maar niet altijd. Je kunt hem vastzetten met `omarchy weather location --set Malibu`, of er exact over zijn door coördinaten toe te voegen: `omarchy weather location --set Malibu 34.0259,-118.7798`. Voer `omarchy weather location` op zichzelf uit om te zien waar hij denkt dat je bent, en `--clear` om terug te gaan naar automatische detectie.

### Batterij

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
