# Webapps

Du kan tilføje dine egne webapps ved hjælp af _Installer > Web App_ i Omarchy-menuen (`Super + Space`). Den vil bede dig om appnavnet, app-URL'en og ikon-URL'en, hvis den ikke kan hente den via favicon. Du kan få fantastiske PNG-ikoner til mange populære webapps på [Dashboard Icons](https://dashboardicons.com).

De vil derefter være tilgængelige gennem app-starteren (`Super + Space`) og bruge det smukke rammeløse webapp-vindue.

Hvis du ønsker at fjerne en webapp, skal du bare gå til _Fjern > Web App_ i Omarchy-menuen.

Det er bedst, hvis du logger ind på alle dine konti ved hjælp af en almindelig browser, før du bruger webapp-genvejene. Den tynde indpakningsramme fungerer ikke godt med 1password, så det er bare nemmere at være logget ind direkte først.

Alle tastaturgenvejene til disse webapps kan ændres i `~/.config/hypr/bindings.lua`.

Når du er i en webapp, kan du kopiere den aktuelle URL til udklipsholderen ved hjælp af `Shift + Alt + L`.

Som standard leveres Omarchy allerede med et udvalg af standardapps:

## HEY

[HEY](https://www.hey.com/) er en e-mail- og kalendertjeneste, der fungerer som et fantastisk alternativ til folk, der er trætte af Gmail, Outlook eller Apple Mail. Den er lavet af [37signals](https://37signals.com/), hvor Omarchy opstod.

Du kan starte HEY Email ved hjælp af `Super + Shift + E`, hoppe direkte til at skrive en ny e-mail ved hjælp af `Super + Shift + Alt + E` og starte HEY Calendar ved hjælp af `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) er en projektstyringstjeneste, der hjælper små teams med at rykke hurtigere og gøre flere fremskridt. I stedet for at lappe en rodebutik af Trello, Slack, Asana, Notion eller hvad som helst sammen kan du have det hele ét sted med Basecamp. Den er lavet af [37signals](https://37signals.com/), hvor Omarchy opstod.

Du kan starte Basecamp ved hjælp af applikationsstarteren (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) er den mest populære AI-chatbot i verden.

Du kan starte ChatGPT ved hjælp af `Super + Shift + A`.

## Grok

[Grok](https://grok.com) er xAI's chatbot.

Du kan starte Grok ved hjælp af `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) er en af de mest populære beskedtjenester i verden, og webversionen er en fantastisk mulighed til Linux.

Du kan starte WhatsApp ved hjælp af `Super + Shift + Alt + G`.

## Google-apps

Google Messages, Google Photos, Google Maps og Google Contacts er alle også inkluderet som webapps.

Du kan starte Google Messages ved hjælp af `Super + Shift + Ctrl + G`, Google Photos ved hjælp af `Super + Shift + P` og Google Maps ved hjælp af `Super + Shift + S`. Google Contacts er tilgængelig gennem app-starteren (`Super + Space`).

## X

X er, hvor nyheder bryder frem.

Du kan starte X ved hjælp af `Super + Shift + X` og gå direkte til at skrive et nyt opslag med `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) er den mest populære videoplatform i verden.

Du kan starte YouTube ved hjælp af `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) er det mest populære videochatsystem, der bruges i USA. Fantastiske forbindelser over hele verden. Og møder på 40 minutter kan afholdes uden en betalt konto. Omarchy pakker Zooms webklient ind, og zoom-mødelinks åbner direkte i den.

Du starter Zoom ved hjælp af applikationsstarteren (`Super + Space`).

## Discord

[Discord](https://discord.com/) er, hvor de fleste gaming- og open source-fællesskaber hænger ud, inklusive [Omarchys eget](https://discord.gg/tXFUdasqhY).

Du starter Discord ved hjælp af applikationsstarteren (`Super + Space`).

## Microsoft-apps

Vælg _Installer > Service > Microsoft_ for at tilføje Outlook, Word, Excel, PowerPoint, Teams og OneDrive som webapps. Hver app har sin egen starter og åbner direkte ved hjælp af de kommercielle Microsoft 365-URL'er og din eksisterende browserprofil. De åbner i de samme browserapp-vinduer som Omarchys andre webapps; de installerer ikke den separate Teams for Linux-klient.

Fjern bundtet med _Fjern > Service > Microsoft_, eller fjern individuelle apps med _Fjern > Web App_. Du kan også installere kun de apps, du ønsker, gennem _Installer > Web App_.

Til en offentlig eller suveræn cloud skal du redigere URL'en på `Exec=`-linjen i den relevante starter under `~/.local/share/applications/`, såsom `Microsoft Teams.desktop`, ved hjælp af den URL, din organisation har leveret. Skriv et bogstaveligt `%` på den linje som `%%`. Ændringer gælder ved næste start. At køre bundtinstallationsprogrammet igen erstatter dets startere med standard-URL'erne.

For at holde arbejdslogins adskilt skal du tilføje en browserdatamappe til hver starters `Exec=`-linje:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Erstat eksempel-mappen med en absolut sti efter eget valg, og brug den samme sti til alle seks startere for at dele arbejdslogins mellem dem. Webappene bruger Omarchys valgte understøttede browser og falder tilbage til Chromium, når standardbrowseren ikke er understøttet.
