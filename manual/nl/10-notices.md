# Meldingen

Notificaties landen in de rechterbovenhoek van het gefocuste scherm. Je hebt ook snel toegang tot de datum en tijd, batterijstatus en het huidige weer via de sneltoetsmeldingen.

## Notificaties

Notificaties van dezelfde app of site stapelen zich op in een stapel, zodat een spraakzaam Slack-kanaal je bouwfout niet van het scherm duwt. Beweeg met je muis over een stapel om hem uit te waaieren; er schuift niets nieuws onder je aanwijzer terwijl je leest. Klik op een kaart om te springen naar waar hij vandaan kwam, klik met de rechtermuisknop, klik met de middelste muisknop of klik op de ✕ om hem te sluiten.

Kaarten bieden wat ze bij zich hebben: _Code kopiëren_ voor verificatiecodes (buiten de [klembordgeschiedenis](08-unified-clipboard-history.md) gehouden en na een minuut gewist), plus alle knoppen die de app biedt. Links in de tekst van een notificatie openen wanneer je erop klikt.

`Super + ,` sluit de nieuwste notificatie, of opent waar hij naar verwijst wanneer hij dat biedt, `Super + Alt + ,` sluit alleen de laatste, `Super + Shift + ,` sluit ze allemaal, en `Super + Shift + Alt + ,` opent de geschiedenis. Om ze zonder de muis te gebruiken, druk je op `Super + Ctrl + ,`. De nieuwste notificatie wordt geselecteerd en de knoppen worden genummerd: druk op een nummer om er een te gebruiken, `Enter` om op de notificatie te klikken, `↑` en `↓` om tussen notificaties te bewegen, `Delete` om er een te sluiten, en `Esc` om het toetsenbord terug te geven. Hij laat ook vanzelf los na een paar seconden zonder activiteit.

Het dempen van notificaties houdt ze tegen, behalve Omarchy's eigen bevestigingen, noodmeldingen en verificatiecodes, waar je net om vroeg. Zet de laatste paar weer op het scherm, tegengehouden of niet, met `Super + Shift + Alt + ,`. De geschiedenis wordt een dag bewaard.

## Sneltoetsmeldingen

### Datum en tijd

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Weer

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

De locatie wordt gedetecteerd op basis van je IP-adres, wat meestal dichtbij genoeg is, maar niet altijd. Je kunt hem vastzetten met `omarchy weather location --set Malibu`, of er exact over zijn door coördinaten toe te voegen: `omarchy weather location --set Malibu 34.0259,-118.7798`. Voer `omarchy weather location` afzonderlijk uit om te zien waar hij denkt dat je bent, en `--clear` om terug te gaan naar automatische detectie.

### Batterij

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
