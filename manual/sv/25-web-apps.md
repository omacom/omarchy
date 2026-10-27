# Webbappar

Du kan lägga till dina egna webbappar via _Installera > Web App_ i Omarchy-menyn (`Super + Space`). Den frågar efter appnamn, app-URL och ikon-URL, om den inte kan hämta den via favicon. Du kan få utmärkta PNG-ikoner för många populära webbappar på [Dashboard Icons](https://dashboardicons.com).

De blir sedan tillgängliga via app-launchern (`Super + Space`), och använder det vackra ramlösa webbappsfönstret.

Om du vill ta bort en webbapp går du bara till _Ta bort > Web App_ i Omarchy-menyn.

Det är bäst om du loggar in på alla dina konton med en vanlig webbläsare innan du använder genvägarna till webbapparna. Den tunna wrapper-ramen fungerar inte bra med 1password, så det är bara lättare att vara direkt inloggad först.

Alla snabbtangenter för dessa webbappar kan ändras i `~/.config/hypr/bindings.lua`.

När du är inne i en webbapp kan du kopiera den aktuella URL:en till urklipp med `Shift + Alt + L`.

Som standard levereras Omarchy redan med ett urval av standardappar:

## HEY

[HEY](https://www.hey.com/) är en e-post- och kalendertjänst som fungerar som ett utmärkt alternativ för personer som tröttnat på Gmail, Outlook eller Apple Mail. Den görs av [37signals](https://37signals.com/) där Omarchy har sitt ursprung.

Du kan starta HEY Email med `Super + Shift + E`, hoppa direkt till att skriva ett nytt e-postmeddelande med `Super + Shift + Alt + E`, och starta HEY Calendar med `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) är en projekthanteringstjänst som hjälper små team att röra sig snabbare och göra mer framsteg. Istället för att lappa ihop ett sammelsurium av Trello, Slack, Asana, Notion eller vad det nu är, kan du ha allt på ett ställe med Basecamp. Den görs av [37signals](https://37signals.com/) där Omarchy har sitt ursprung.

Du kan starta Basecamp via app-launchern (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) är den mest populära AI-chattboten i världen.

Du kan starta ChatGPT med `Super + Shift + A`.

## Grok

[Grok](https://grok.com) är xAI:s chattbot.

Du kan starta Grok med `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) är en av de mest populära meddelandetjänsterna i världen, och webbversionen är ett utmärkt alternativ för Linux.

Du kan starta WhatsApp med `Super + Shift + Alt + G`.

## Google-appar

Google Messages, Google Photos, Google Maps och Google Contacts är också inkluderade som webbappar.

Du kan starta Google Messages med `Super + Shift + Ctrl + G`, Google Photos med `Super + Shift + P` och Google Maps med `Super + Shift + S`. Google Contacts finns tillgängligt via app-launchern (`Super + Space`).

## X

X är där nyheter bryter ut.

Du kan starta X med `Super + Shift + X` och gå direkt till att skriva ett nytt inlägg med `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) är den mest populära videoplattformen i världen.

Du kan starta YouTube med `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) är det mest populära videochattsystemet som används i USA. Utmärkta anslutningar över hela världen. Och 40-minutersmöten kan hållas utan ett betalande konto. Omarchy omsluter Zooms webbklient, och zoom-möteslänkar öppnas direkt i den.

Du startar Zoom via app-launchern (`Super + Space`).

## Discord

[Discord](https://discord.com/) är där de flesta spel- och open-source-communities hänger, inklusive [Omarchys egen](https://discord.gg/tXFUdasqhY).

Du startar Discord via app-launchern (`Super + Space`).

## Microsoft-appar

Välj _Installera > Service > Microsoft_ för att lägga till Outlook, Word, Excel, PowerPoint, Teams och OneDrive som webbappar. Varje app har sin egen launcher och öppnas direkt, med de kommersiella Microsoft 365-URL:erna och din befintliga webbläsarprofil. De öppnas i samma webbläsarappsfönster som Omarchys andra webbappar; de installerar inte den separata Teams for Linux-klienten.

Ta bort paketet med _Ta bort > Service > Microsoft_, eller ta bort enskilda appar med _Ta bort > Web App_. Du kan också installera bara de appar du vill ha via _Installera > Web App_.

För en statlig eller suverän molnmiljö, redigera URL:en på raden `Exec=` i relevant launcher under `~/.local/share/applications/`, som `Microsoft Teams.desktop`, med den URL som tillhandahålls av din organisation. Skriv varje bokstavligt `%` på den raden som `%%`. Ändringarna gäller vid nästa start. Att köra paketinstallern igen ersätter dess launchers med standard-URL:erna.

För att hålla arbetsinloggningar separata, lägg till en webbläsardatakatalog på varje launchers `Exec=`-rad:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Ersätt exempelkatalogen med en absolut sökväg efter eget val och använd samma sökväg för alla sex launchers för att dela arbetsinloggningar mellan dem. Webbapparna använder Omarchys valda webbläsare som stöds, och faller tillbaka till Chromium när standardwebbläsaren inte stöds.
