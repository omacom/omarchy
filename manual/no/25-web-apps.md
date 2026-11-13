# Nettapper

Du kan legge til dine egne nettapper med _Install > Web App_ i Omarchy-menyen (`Super + Space`). Den ber deg om appnavn, app-URL og ikon-URL, hvis den ikke kan hente det via favicon. Du kan få flotte PNG-ikoner for mange populære nettapper på [Dashboard Icons](https://dashboardicons.com).

De blir deretter tilgjengelige via appstarteren (`Super + Space`), og bruker det vakre, rammeløse nettappvinduet.

Hvis du vil fjerne en nettapp, går du bare til _Remove > Web App_ i Omarchy-menyen.

Det er best å logge inn på alle kontoene dine i en vanlig nettleser før du bruker snarveiene til nettappene. Den tynne innpakkingsrammen fungerer ikke godt med 1password, så det er rett og slett enklere å være logget inn direkte på forhånd.

Alle hurtigtastene for disse nettappene kan endres i `~/.config/hypr/bindings.lua`.

Når du er i en nettapp, kan du kopiere gjeldende URL til utklippstavlen med `Shift + Alt + L`.

Som standard leveres Omarchy allerede med et utvalg standardapper:

## HEY

[HEY](https://www.hey.com/) er en e-post- og kalendertjeneste som er et flott alternativ for folk som er lei av Gmail, Outlook eller Apple Mail. Den er laget av [37signals](https://37signals.com/), der Omarchy oppsto.

Du kan starte HEY Email med `Super + Shift + E`, hoppe rett til å skrive en ny e-post med `Super + Shift + Alt + E`, og starte HEY Calendar med `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) er en tjeneste for prosjektstyring som hjelper små team med å jobbe raskere og få gjort mer. I stedet for å lappe sammen et sammensurium av Trello, Slack, Asana, Notion eller hva det måtte være, kan du ha alt på ett sted med Basecamp. Den er laget av [37signals](https://37signals.com/), der Omarchy oppsto.

Du kan starte Basecamp med appstarteren (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) er den mest populære AI-chatboten i verden.

Du kan starte ChatGPT med `Super + Shift + A`.

## Grok

[Grok](https://grok.com) er xAIs chatbot.

Du kan starte Grok med `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) er en av de mest populære meldingstjenestene i verden, og nettversjonen er et flott alternativ for Linux.

Du kan starte WhatsApp med `Super + Shift + Alt + G`.

## Google-apper

Google Messages, Google Photos, Google Maps og Google Contacts er også inkludert som nettapper.

Du kan starte Google Messages med `Super + Shift + Ctrl + G`, Google Photos med `Super + Shift + P` og Google Maps med `Super + Shift + S`. Google Contacts er tilgjengelig via appstarteren (`Super + Space`).

## X

X er der nyhetene bryter.

Du kan starte X med `Super + Shift + X` og gå rett til å skrive et nytt innlegg med `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) er den mest populære videoplattformen i verden.

Du kan starte YouTube med `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) er det mest populære videochatsystemet som brukes i USA. Flotte forbindelser over hele verden. Og møter på 40 minutter kan holdes uten en betalende konto. Omarchy pakker inn Zooms nettklient, og lenker til Zoom-møter åpnes rett i den.

Du starter Zoom med appstarteren (`Super + Space`).

## Discord

[Discord](https://discord.com/) er der de fleste gaming- og åpen kildekode-miljøer holder til, inkludert [Omarchys eget](https://discord.gg/tXFUdasqhY).

Du starter Discord med appstarteren (`Super + Space`).

## Microsoft-apper

Velg _Install > Service > Microsoft_ for å legge til Outlook, Word, Excel, PowerPoint, Teams og OneDrive som nettapper. Hver app har sin egen starter og åpnes direkte, med de kommersielle Microsoft 365-URL-ene og din eksisterende nettleserprofil. De åpnes i de samme nettleserappvinduene som Omarchys andre nettapper; de installerer ikke den separate Teams for Linux-klienten.

Fjern pakken med _Remove > Service > Microsoft_, eller fjern enkeltapper med _Remove > Web App_. Du kan også installere bare appene du vil ha via _Install > Web App_.

For en offentlig eller suveren sky redigerer du URL-en på `Exec=`-linjen i den aktuelle starteren under `~/.local/share/applications/`, for eksempel `Microsoft Teams.desktop`, med URL-en du har fått fra organisasjonen din. Skriv et eventuelt bokstavelig `%` på den linjen som `%%`. Endringene gjelder fra neste oppstart. Hvis du kjører pakkeinstallasjonsprogrammet igjen, erstattes starterne med standard-URL-ene.

For å holde jobbinnlogginger adskilt legger du til en mappe for nettleserdata på slutten av hver starters `Exec=`-linje:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Erstatt eksempelmappen med en absolutt bane du velger selv, og bruk den samme banen for alle de seks starterne for å dele jobbinnlogginger mellom dem. Nettappene bruker Omarchys valgte støttede nettleser, og faller tilbake på Chrome når standardnettleseren ikke støttes.
