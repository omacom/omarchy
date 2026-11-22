# Nettapper

Du kan legge til dine egne nettapper med _Installer > Nettapp_ i Omarchy-menyen (`Super + Space`). Den ber deg om appnavnet, app-URL-en og ikon-URL-en hvis den ikke kan hente den via favicon. Du finner flotte PNG-ikoner for mange populære nettapper på [Dashboard Icons](https://dashboardicons.com).

Deretter er de tilgjengelige via appstarteren (`Super + Space`), og bruker det vakre rammeløse nettappvinduet.

Hvis du vil fjerne en nettapp, går du bare til _Fjern > Nettapp_ i Omarchy-menyen.

Det er best å logge inn på alle kontoene dine i en vanlig nettleser før du bruker snarveiene til nettappene. Den tynne innpakningsrammen fungerer ikke godt med 1password, så det er rett og slett enklere å være logget inn direkte på forhånd.

Alle hurtigtastene for disse nettappene kan endres i `~/.config/hypr/bindings.lua`.

Når du er i en nettapp, kan du kopiere gjeldende URL til utklippstavlen med `Shift + Alt + L`.

Som standard leveres Omarchy allerede med et utvalg av standardapper:

## HEY

[HEY](https://www.hey.com/) er en e-post- og kalendertjeneste som er et godt alternativ for folk som er lei av Gmail, Outlook eller Apple Mail. Den lages av [37signals](https://37signals.com/), der Omarchy oppsto.

Du kan starte HEY Email med `Super + Shift + E`, gå rett til å skrive en ny e-post med `Super + Shift + Alt + E`, og starte HEY Calendar med `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) er en prosjektstyringstjeneste som hjelper små team med å jobbe raskere og få gjort mer. I stedet for å lappe sammen et virvar av Trello, Slack, Asana, Notion eller hva det måtte være, kan du ha alt på ett sted med Basecamp. Den lages av [37signals](https://37signals.com/), der Omarchy oppsto.

Du kan starte Basecamp via appstarteren (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) er den mest populære AI-chatboten i verden.

Du kan starte ChatGPT med `Super + Shift + A`.

## Grok

[Grok](https://grok.com) er chatboten til xAI.

Du kan starte Grok med `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) er en av de mest populære meldingstjenestene i verden, og nettversjonen er et godt alternativ for Linux.

Du kan starte WhatsApp med `Super + Shift + Alt + G`. Den åpnes med Omarchys WhatsApp Slim-utvidelse, som får den til å følge temaet ditt og folder sammen chattelisten når vinduet er smalt.

## Google-apper

Google Messages, Google Photos, Google Maps og Google Contacts er også inkludert som nettapper.

Du kan starte Google Messages med `Super + Shift + Ctrl + G`, Google Photos med `Super + Shift + P` og Google Maps med `Super + Shift + S`. Google Contacts er tilgjengelig via appstarteren (`Super + Space`).

## X

X er der nyheter bryter.

Du kan starte X med `Super + Shift + X` og gå rett til å skrive et nytt innlegg med `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) er den mest populære videoplattformen i verden.

Du kan starte YouTube med `Super + Shift + Y`.

## Netflix

[Netflix](https://www.netflix.com/) er inkludert som nettapp på nye installasjoner.

Du starter Netflix via appstarteren (`Super + Space`).

## Zoom

[Zoom](https://zoom.us/) er det mest populære videochatsystemet som brukes i US. Gode forbindelser over hele verden. Og 40-minutters møter kan holdes uten en betalende konto. Omarchy pakker inn Zooms nettklient, og zoom-møtelenker åpner rett i den.

Du starter Zoom via appstarteren (`Super + Space`).

## Discord

[Discord](https://discord.com/) er der de fleste spill- og åpen kildekode-fellesskap holder til, inkludert [Omarchys eget](https://discord.gg/tXFUdasqhY).

Du starter Discord via appstarteren (`Super + Space`).

## Microsoft-apper

Velg _Installer > Tjeneste > Microsoft_ for å legge til Outlook, Word, Excel, PowerPoint, Teams og OneDrive som nettapper. Hver app har sin egen starter og åpner direkte, med de kommersielle Microsoft 365-URL-ene og din eksisterende nettleserprofil. De åpner i de samme nettleserappvinduene som Omarchys andre nettapper; de installerer ikke den separate Teams for Linux-klienten.

Fjern pakken med _Fjern > Tjenester > Microsoft_, eller fjern enkeltapper med _Fjern > Nettapp_. Du kan også installere bare appene du vil ha, via _Installer > Nettapp_.

For en offentlig eller suveren sky redigerer du URL-en på `Exec=`-linjen i den relevante starteren under `~/.local/share/applications/`, for eksempel `Microsoft Teams.desktop`, med URL-en organisasjonen din har oppgitt. Skriv et bokstavelig `%`-tegn på den linjen som `%%`. Endringene gjelder fra neste oppstart. Hvis du kjører pakkeinstalleren på nytt, erstattes starterne dens med standard-URL-ene.

For å holde jobbinnlogginger adskilt legger du til en nettleserdatakatalog på `Exec=`-linjen i hver starter:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Erstatt eksempelkatalogen med en absolutt sti du velger selv, og bruk samme sti for alle de seks starterne for å dele jobbinnlogginger mellom dem. Nettappene bruker Omarchys valgte støttede nettleser, og faller tilbake på Chrome når standardnettleseren ikke støttes.
