# Webapper

Du kan legge til dine egne webapper med _Installer > Webapp_ i Omarchy-menyen (`Super + Space`). Den ber deg om appnavn, app-URL og ikon-URL, hvis den ikke kan hente den via favicon. Du kan få flotte PNG-ikoner for mange populære webapper på [Dashboard Icons](https://dashboardicons.com).

De blir deretter tilgjengelige via appstarteren (`Super + Space`) og bruker det vakre rammeløse webapp-vinduet.

Hvis du vil fjerne en webapp, går du bare til _Fjern > Webapp_ i Omarchy-menyen.

Det er best om du logger inn på alle kontoene dine med en vanlig nettleser før du bruker webapp-snarveiene. Den tynne innpakningsrammen fungerer ikke godt med 1password, så det er enklere å være logget inn direkte først.

Alle hurtigtastene for disse webappene kan endres i `~/.config/hypr/bindings.lua`.

Når du er i en webapp, kan du kopiere gjeldende URL til utklippstavlen med `Shift + Alt + L`.

Som standard leveres Omarchy allerede med et utvalg av standardapper:

## HEY

[HEY](https://www.hey.com/) er en e-post- og kalendertjeneste som er et flott alternativ for folk som er lei av Gmail, Outlook eller Apple Mail. Den er laget av [37signals](https://37signals.com/), der Omarchy oppsto.

Du kan starte HEY Email med `Super + Shift + E`, hoppe rett til å skrive en ny e-post med `Super + Shift + Alt + E`, og starte HEY Calendar med `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) er en prosjektstyringstjeneste som hjelper små team med å bevege seg raskere og gjøre mer fremgang. I stedet for å lappe sammen en salat av Trello, Slack, Asana, Notion eller hva det måtte være, kan du ha alt på ett sted med Basecamp. Den er laget av [37signals](https://37signals.com/), der Omarchy oppsto.

Du kan starte Basecamp med appstarteren (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) er den mest populære KI-chatteboten i verden.

Du kan starte ChatGPT med `Super + Shift + A`.

## Grok

[Grok](https://grok.com) er xAIs chattebot.

Du kan starte Grok med `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) er en av de mest populære meldingstjenestene i verden, og webversjonen er et flott valg for Linux.

Du kan starte WhatsApp med `Super + Shift + Alt + G`.

## Google-apper

Google Messages, Google Photos, Google Maps og Google Contacts er alle inkludert som webapper også.

Du kan starte Google Messages med `Super + Shift + Ctrl + G`, Google Photos med `Super + Shift + P` og Google Maps med `Super + Shift + S`. Google Contacts er tilgjengelig via appstarteren (`Super + Space`).

## X

X er der nyheter bryter.

Du kan starte X med `Super + Shift + X` og gå rett til å skrive et nytt innlegg med `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) er den mest populære videoplattformen i verden.

Du kan starte YouTube med `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) er det mest populære videochatsystemet som brukes i USA. Flotte forbindelser over hele verden. Og 40-minuttersmøter kan holdes uten betalingskonto. Omarchy pakker inn Zooms webklient, og Zoom-møtelenker åpnes rett inn i den.

Du starter Zoom med appstarteren (`Super + Space`).

## Discord

[Discord](https://discord.com/) er der de fleste spill- og åpen kildekode-fellesskap henger, inkludert [Omarchys eget](https://discord.gg/tXFUdasqhY).

Du starter Discord med appstarteren (`Super + Space`).

## Microsoft-apper

Velg _Installer > Tjeneste > Microsoft_ for å legge til Outlook, Word, Excel, PowerPoint, Teams og OneDrive som webapper. Hver app har sin egen starter og åpnes direkte, med de kommersielle Microsoft 365-URL-ene og din eksisterende nettleserprofil. De åpnes i de samme nettleserapp-vinduene som Omarchys andre webapper; de installerer ikke den separate Teams for Linux-klienten.

Fjern pakken med _Fjern > Tjeneste > Microsoft_, eller fjern enkeltapper med _Fjern > Webapp_. Du kan også installere bare appene du vil ha via _Installer > Webapp_.

For en offentlig eller suveren sky, rediger URL-en på `Exec=`-linjen i den aktuelle starteren under `~/.local/share/applications/`, som `Microsoft Teams.desktop`, med URL-en fra organisasjonen din. Skriv en eventuell bokstavelig `%` i den linjen som `%%`. Endringer gjelder ved neste start. Å kjøre pakkeinstallasjonsprogrammet igjen erstatter starterne med standard-URL-ene.

For å holde jobbpåloggingene separate, legg til en nettleserdatamappe på hver starters `Exec=`-linje:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Erstatt eksempelmappen med en absolutt sti du velger selv, og bruk samme sti for alle seks starterne for å dele jobbpålogginger mellom dem. Webappene bruker Omarchys valgte støttede nettleser, og faller tilbake på Chromium når standardnettleseren ikke støttes.
