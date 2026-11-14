# Webapps

Je kunt je eigen webapps toevoegen via _Install > Web App_ in het Omarchy-menu (`Super + Space`). Het vraagt je om de naam van de app, de URL van de app en de URL van het pictogram, als het die niet via de favicon kan ophalen. Op [Dashboard Icons](https://dashboardicons.com) vind je geweldige PNG-pictogrammen voor veel populaire webapps.

Daarna zijn ze toegankelijk via de app launcher (`Super + Space`) en gebruiken ze het prachtige frameloze webapp-venster.

Als je een webapp wilt verwijderen, ga je gewoon naar _Remove > Web App_ in het Omarchy-menu.

Het is het beste om met een gewone browser in te loggen op al je accounts voordat je de snelkoppelingen voor webapps gebruikt. Het dunne wrapper-frame werkt niet goed met 1password, dus het is gewoon makkelijker om eerst direct ingelogd te zijn.

Alle sneltoetsen voor deze webapps kun je wijzigen in `~/.config/hypr/bindings.lua`.

Als je in een webapp zit, kun je de huidige URL met `Shift + Alt + L` naar het klembord kopiëren.

Standaard wordt Omarchy al geleverd met een assortiment standaardapps:

## HEY

[HEY](https://www.hey.com/) is een e-mail- en agendadienst die een geweldig alternatief vormt voor mensen die Gmail, Outlook of Apple Mail zat zijn. Het is gemaakt door [37signals](https://37signals.com/), waar Omarchy is ontstaan.

Je kunt HEY Email starten met `Super + Shift + E`, direct naar het opstellen van een nieuwe e-mail gaan met `Super + Shift + Alt + E` en HEY Calendar starten met `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) is een dienst voor projectbeheer die kleine teams helpt sneller te werken en meer vooruitgang te boeken. In plaats van een ratjetoe van Trello, Slack, Asana, Notion of wat dan ook aan elkaar te plakken, heb je met Basecamp alles op één plek. Het is gemaakt door [37signals](https://37signals.com/), waar Omarchy is ontstaan.

Je kunt Basecamp starten via de application launcher (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) is de populairste AI-chatbot ter wereld.

Je kunt ChatGPT starten met `Super + Shift + A`.

## Grok

[Grok](https://grok.com) is de chatbot van xAI.

Je kunt Grok starten met `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) is een van de populairste berichtendiensten ter wereld, en de webversie is een geweldige optie voor Linux.

Je kunt WhatsApp starten met `Super + Shift + Alt + G`.

## Google-apps

Google Messages, Google Photos, Google Maps en Google Contacts zijn ook allemaal inbegrepen als webapps.

Je kunt Google Messages starten met `Super + Shift + Ctrl + G`, Google Photos met `Super + Shift + P` en Google Maps met `Super + Shift + S`. Google Contacts is beschikbaar via de app launcher (`Super + Space`).

## X

X is de plek waar nieuws breekt.

Je kunt X starten met `Super + Shift + X` en met `Super + Shift + Alt + X` direct een nieuw bericht gaan schrijven.

## YouTube

[YouTube](https://youtube.com/) is het populairste videoplatform ter wereld.

Je kunt YouTube starten met `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) is het populairste videochatsysteem dat in de VS wordt gebruikt. Geweldige verbindingen over de hele wereld. En vergaderingen van 40 minuten kunnen worden gehouden zonder betalend account. Omarchy wikkelt de webclient van Zoom in, en Zoom-vergaderlinks openen er direct in.

Je start Zoom via de application launcher (`Super + Space`).

## Discord

[Discord](https://discord.com/) is waar de meeste gaming- en open source-communities rondhangen, waaronder [die van Omarchy zelf](https://discord.gg/tXFUdasqhY).

Je start Discord via de application launcher (`Super + Space`).

## Microsoft-apps

Selecteer _Install > Service > Microsoft_ om Outlook, Word, Excel, PowerPoint, Teams en OneDrive als webapps toe te voegen. Elke app heeft zijn eigen launcher en opent direct, met de commerciële Microsoft 365-URL's en je bestaande browserprofiel. Ze openen in dezelfde browserapp-vensters als de andere webapps van Omarchy; ze installeren niet de aparte Teams for Linux-client.

Verwijder de bundel met _Remove > Service > Microsoft_, of verwijder afzonderlijke apps met _Remove > Web App_. Je kunt via _Install > Web App_ ook alleen de apps installeren die je wilt.

Voor een overheidscloud of soevereine cloud bewerk je de URL op de `Exec=`-regel in de betreffende launcher onder `~/.local/share/applications/`, zoals `Microsoft Teams.desktop`, met de URL die je organisatie heeft verstrekt. Schrijf elke letterlijke `%` in die regel als `%%`. Wijzigingen worden van kracht bij de volgende start. Als je het installatieprogramma van de bundel opnieuw uitvoert, vervangt dat zijn launchers door de standaard-URL's.

Om inlogsessies voor werk gescheiden te houden, voeg je aan de `Exec=`-regel van elke launcher een map voor browsergegevens toe:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Vervang de voorbeeldmap door een absoluut pad naar keuze en gebruik hetzelfde pad voor alle zes launchers om inlogsessies voor werk tussen hen te delen. De webapps gebruiken de door Omarchy geselecteerde ondersteunde browser, en vallen terug op Chrome wanneer de standaardbrowser niet wordt ondersteund.
