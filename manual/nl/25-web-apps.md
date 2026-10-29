# Webapps

Je kunt je eigen webapps toevoegen via _Installeren > Webapp_ in het Omarchy-menu (`Super + Space`). Het vraagt je om de appnaam, app-URL en de pictogram-URL, als het deze niet via favicon kan ophalen. Je kunt geweldige PNG-pictogrammen voor veel populaire webapps vinden op [Dashboard Icons](https://dashboardicons.com).

Ze zijn daarna toegankelijk via de app-launcher (`Super + Space`), en gebruiken het prachtige frameloze webapp-venster.

Als je een webapp wilt verwijderen, ga je gewoon naar _Verwijderen > Webapp_ in het Omarchy-menu.

Het is het beste als je inlogt op al je accounts met een gewone browser voordat je de webapp-snelkoppelingen gebruikt. Het dunne wrapper-frame werkt niet goed met 1password, dus het is gewoon gemakkelijker om eerst direct ingelogd te zijn.

Alle toetsenbordsneltoetsen voor deze webapps kunnen worden gewijzigd in `~/.config/hypr/bindings.lua`.

Wanneer je in een webapp bent, kun je de huidige URL naar het klembord kopiëren met `Shift + Alt + L`.

Standaard wordt Omarchy al geleverd met een assortiment standaardapps:

## HEY

[HEY](https://www.hey.com/) is een e-mail- en kalenderdienst die dient als een geweldig alternatief voor mensen die Gmail, Outlook of Apple Mail beu zijn. Het is gemaakt door [37signals](https://37signals.com/) waar Omarchy is ontstaan.

Je kunt HEY Email starten met `Super + Shift + E`, direct naar het opstellen van een nieuwe e-mail springen met `Super + Shift + Alt + E`, en HEY Calendar starten met `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) is een projectmanagementdienst die kleine teams helpt sneller te werken en meer vooruitgang te boeken. In plaats van een mengelmoes van Trello, Slack, Asana, Notion of wat dan ook aan elkaar te plakken, kun je het allemaal op één plek hebben met Basecamp. Het is gemaakt door [37signals](https://37signals.com/) waar Omarchy is ontstaan.

Je kunt Basecamp starten met de applicatie-launcher (`Super + Space`)

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

Google Messages, Google Photos, Google Maps en Google Contacts zijn allemaal ook inbegrepen als webapps.

Je kunt Google Messages starten met `Super + Shift + Ctrl + G`, Google Photos met `Super + Shift + P`, en Google Maps met `Super + Shift + S`. Google Contacts is beschikbaar via de app-launcher (`Super + Space`).

## X

X is waar het nieuws breekt.

Je kunt X starten met `Super + Shift + X` en direct naar het schrijven van een nieuw bericht gaan met `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) is het populairste videoplatform ter wereld.

Je kunt YouTube starten met `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) is het populairste videochatsysteem in de VS. Geweldige verbindingen over de hele wereld. En vergaderingen van 40 minuten kunnen worden gehouden zonder betalend account. Omarchy verpakt de webclient van Zoom, en zoom-vergaderlinks openen er direct in.

Je start Zoom met de applicatie-launcher (`Super + Space`).

## Discord

[Discord](https://discord.com/) is waar de meeste gaming- en opensource-community's rondhangen, inclusief [die van Omarchy zelf](https://discord.gg/tXFUdasqhY).

Je start Discord met de applicatie-launcher (`Super + Space`).

## Microsoft-apps

Selecteer _Installeren > Dienst > Microsoft_ om Outlook, Word, Excel, PowerPoint, Teams en OneDrive toe te voegen als webapps. Elke app heeft zijn eigen launcher en opent direct, met gebruik van de commerciële Microsoft 365-URL's en je bestaande browserprofiel. Ze openen in dezelfde browser-appvensters als Omarchy's andere webapps; ze installeren niet de afzonderlijke Teams for Linux-client.

Verwijder de bundel met _Verwijderen > Dienst > Microsoft_, of verwijder individuele apps met _Verwijderen > Webapp_. Je kunt ook alleen de apps installeren die je wilt via _Installeren > Webapp_.

Voor een overheids- of soevereine cloud bewerk je de URL op de `Exec=`-regel in de relevante launcher onder `~/.local/share/applications/`, zoals `Microsoft Teams.desktop`, met de URL die door je organisatie is verstrekt. Schrijf elke letterlijke `%` in die regel als `%%`. Wijzigingen zijn van toepassing bij de volgende start. Het opnieuw uitvoeren van het bundel-installatieprogramma vervangt zijn launchers door de standaard-URL's.

Om werkinloggegevens gescheiden te houden, voeg je een browserdatamap toe aan de `Exec=`-regel van elke launcher:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Vervang de voorbeeldmap door een absoluut pad naar keuze en gebruik hetzelfde pad voor alle zes launchers om werkinloggegevens tussen hen te delen. De webapps gebruiken Omarchy's geselecteerde ondersteunde browser, en vallen terug op Chromium wanneer de standaardbrowser niet wordt ondersteund.
