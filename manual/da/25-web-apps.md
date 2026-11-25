# Webapps

Du kan tilføje dine egne webapps med _Install > Web App_ i Omarchy-menuen (`Super + Space`). Den beder dig om appnavnet, app-URL'en og ikon-URL'en, hvis den ikke kan hente den via favicon. Du kan få flotte PNG-ikoner til mange populære webapps på [Dashboard Icons](https://dashboardicons.com).

De er derefter tilgængelige via appstarteren (`Super + Space`) og bruger det flotte rammeløse webapp-vindue.

Hvis du vil fjerne en webapp, skal du bare gå til _Remove > Web App_ i Omarchy-menuen.

Det er bedst, hvis du logger ind på alle dine konti med en almindelig browser, før du bruger genvejene til webappene. Den tynde indpakningsramme fungerer ikke godt med 1password, så det er bare nemmere at være logget direkte ind først.

Alle tastaturgenvejene til disse webapps kan ændres i `~/.config/hypr/bindings.lua`.

Når du er i en webapp, kan du kopiere den aktuelle URL til udklipsholderen med `Shift + Alt + L`.

Som standard leveres Omarchy allerede med et udvalg af standardapps:

## HEY

[HEY](https://www.hey.com/) er en e-mail- og kalendertjeneste, der er et godt alternativ for folk, der er trætte af Gmail, Outlook eller Apple Mail. Den er lavet af [37signals](https://37signals.com/), hvor Omarchy opstod.

Du kan starte HEY Email med `Super + Shift + E`, hoppe direkte til at skrive en ny e-mail med `Super + Shift + Alt + E` og starte HEY Calendar med `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) er en projektstyringstjeneste, der hjælper små teams med at arbejde hurtigere og gøre flere fremskridt. I stedet for at lappe en sammenblanding af Trello, Slack, Asana, Notion eller hvad som helst sammen, kan du have det hele ét sted med Basecamp. Den er lavet af [37signals](https://37signals.com/), hvor Omarchy opstod.

Du kan starte Basecamp med appstarteren (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) er den mest populære AI-chatbot i verden.

Du kan starte ChatGPT med `Super + Shift + A`.

## Grok

[Grok](https://grok.com) er xAI's chatbot.

Du kan starte Grok med `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) er en af de mest populære beskedtjenester i verden, og webversionen er en god mulighed til Linux.

Du kan starte WhatsApp med `Super + Shift + Alt + G`. Den åbner med Omarchys WhatsApp Slim-udvidelse, som får den til at følge dit tema og folder chatlisten sammen, når vinduet er smalt.

## Google-apps

Google Messages, Google Photos, Google Maps og Google Contacts er alle også inkluderet som webapps.

Du kan starte Google Messages med `Super + Shift + Ctrl + G`, Google Photos med `Super + Shift + P` og Google Maps med `Super + Shift + S`. Google Contacts er tilgængelig via appstarteren (`Super + Space`).

## X

X er stedet, hvor nyheder bryder frem.

Du kan starte X med `Super + Shift + X` og gå direkte til at skrive et nyt opslag med `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) er den mest populære videoplatform i verden.

Du kan starte YouTube med `Super + Shift + Y`.

## Netflix

[Netflix](https://www.netflix.com/) er inkluderet som webapp på nye installationer.

Du starter Netflix med appstarteren (`Super + Space`).

## Zoom

[Zoom](https://zoom.us/) er det mest populære videochatsystem i USA. Gode forbindelser over hele verden. Og møder på 40 minutter kan holdes uden en betalende konto. Omarchy indpakker Zooms webklient, og zoom-mødelinks åbner direkte i den.

Du starter Zoom med appstarteren (`Super + Space`).

## Discord

[Discord](https://discord.com/) er stedet, hvor de fleste gaming- og open source-fællesskaber hænger ud, herunder [Omarchys eget](https://discord.gg/tXFUdasqhY).

Du starter Discord med appstarteren (`Super + Space`).

## Microsoft-apps

Vælg _Install > Service > Microsoft_ for at tilføje Outlook, Word, Excel, PowerPoint, Teams og OneDrive som webapps. Hver app har sin egen starter og åbner direkte med de kommercielle Microsoft 365-URL'er og din eksisterende browserprofil. De åbner i de samme browserapp-vinduer som Omarchys andre webapps; de installerer ikke den separate Teams for Linux-klient.

Fjern pakken med _Remove > Services > Microsoft_, eller fjern enkelte apps med _Remove > Web App_. Du kan også installere kun de apps, du vil have, via _Install > Web App_.

Til en offentlig eller suveræn cloud skal du redigere URL'en på `Exec=`-linjen i den relevante starter under `~/.local/share/applications/`, såsom `Microsoft Teams.desktop`, med den URL, din organisation har leveret. Skriv ethvert bogstaveligt `%` på den linje som `%%`. Ændringer gælder ved næste start. Hvis du kører pakkens installationsprogram igen, erstatter det dens startere med standard-URL'erne.

For at holde arbejdslogins adskilt skal du føje en browserdatamappe til hver starters `Exec=`-linje:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Erstat eksempelmappen med en absolut sti efter eget valg, og brug den samme sti til alle seks startere for at dele arbejdslogins mellem dem. Webappene bruger Omarchys valgte understøttede browser og falder tilbage til Chrome, når standardbrowseren ikke understøttes.
