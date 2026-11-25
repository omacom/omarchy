# Webbappar

Du kan lägga till dina egna webbappar via _Install > Web App_ i Omarchy-menyn (`Super + Space`). Den frågar dig efter appnamnet, appens URL och ikonens URL, om den inte kan hämta den via favicon. Du kan hitta bra PNG-ikoner för många populära webbappar på [Dashboard Icons](https://dashboardicons.com).

De blir sedan tillgängliga via appstartaren (`Super + Space`) och använder det vackra ramlösa webbappsfönstret.

Om du vill ta bort en webbapp går du bara till _Remove > Web App_ i Omarchy-menyn.

Det är bäst om du loggar in på alla dina konton i en vanlig webbläsare innan du använder webbappsgenvägarna. Den tunna omslagsramen fungerar inte bra med 1password, så det är helt enkelt lättare att vara inloggad direkt från början.

Alla kortkommandon för dessa webbappar kan ändras i `~/.config/hypr/bindings.lua`.

När du är i en webbapp kan du kopiera den aktuella URL:en till urklipp med `Shift + Alt + L`.

Som standard levereras Omarchy redan med ett urval av standardappar:

## HEY

[HEY](https://www.hey.com/) är en tjänst för e-post och kalender som fungerar som ett bra alternativ för folk som har tröttnat på Gmail, Outlook eller Apple Mail. Den är gjord av [37signals](https://37signals.com/) där Omarchy har sitt ursprung.

Du kan starta HEY Email med `Super + Shift + E`, hoppa direkt till att skriva ett nytt e-postmeddelande med `Super + Shift + Alt + E` och starta HEY Calendar med `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) är en projekthanteringstjänst som hjälper små team att röra sig snabbare och göra fler framsteg. I stället för att lappa ihop en salig röra av Trello, Slack, Asana, Notion eller vad som helst kan du ha allt på ett ställe med Basecamp. Den är gjord av [37signals](https://37signals.com/) där Omarchy har sitt ursprung.

Du kan starta Basecamp via appstartaren (`Super + Space`)

## ChatGPT

[ChatGPT](https://chatgpt.com) är världens mest populära AI-chattbot.

Du kan starta ChatGPT med `Super + Shift + A`.

## Grok

[Grok](https://grok.com) är xAI:s chattbot.

Du kan starta Grok med `Super + Shift + Alt + A`.

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) är en av världens mest populära meddelandetjänster, och webbversionen är ett bra alternativ för Linux.

Du kan starta WhatsApp med `Super + Shift + Alt + G`. Den öppnas med Omarchys WhatsApp Slim-tillägg, som får den att följa ditt tema och fäller ihop chattlistan när fönstret är smalt.

## Google-appar

Google Messages, Google Photos, Google Maps och Google Contacts ingår också som webbappar.

Du kan starta Google Messages med `Super + Shift + Ctrl + G`, Google Photos med `Super + Shift + P` och Google Maps med `Super + Shift + S`. Google Contacts finns tillgänglig via appstartaren (`Super + Space`).

## X

X är där nyheter bryter ut.

Du kan starta X med `Super + Shift + X` och gå direkt till att skriva ett nytt inlägg med `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) är världens mest populära videoplattform.

Du kan starta YouTube med `Super + Shift + Y`.

## Netflix

[Netflix](https://www.netflix.com/) ingår som en webbapp på nya installationer.

Du startar Netflix via appstartaren (`Super + Space`).

## Zoom

[Zoom](https://zoom.us/) är det mest populära videochattsystemet som används i USA. Bra förbindelser över hela världen. Och 40-minutersmöten kan hållas utan ett betalkonto. Omarchy omsluter Zooms webbklient, och zoom-möteslänkar öppnas direkt i den.

Du startar Zoom via appstartaren (`Super + Space`).

## Discord

[Discord](https://discord.com/) är där de flesta spel- och öppen källkods-gemenskaper håller till, inklusive [Omarchys egen](https://discord.gg/tXFUdasqhY).

Du startar Discord via appstartaren (`Super + Space`).

## Microsoft-appar

Välj _Install > Service > Microsoft_ för att lägga till Outlook, Word, Excel, PowerPoint, Teams och OneDrive som webbappar. Varje app har sin egen startare och öppnas direkt, med de kommersiella Microsoft 365-URL:erna och din befintliga webbläsarprofil. De öppnas i samma webbläsarappsfönster som Omarchys andra webbappar; de installerar inte den separata Teams for Linux-klienten.

Ta bort paketet med _Remove > Services > Microsoft_, eller ta bort enskilda appar med _Remove > Web App_. Du kan också installera bara de appar du vill ha via _Install > Web App_.

För ett statligt eller suveränt moln redigerar du URL:en på `Exec=`-raden i den relevanta startaren under `~/.local/share/applications/`, till exempel `Microsoft Teams.desktop`, med den URL som din organisation har tillhandahållit. Skriv varje bokstavligt `%` på den raden som `%%`. Ändringar gäller vid nästa start. Om du kör paketinstallationsprogrammet igen ersätts dess startare med standard-URL:erna.

För att hålla arbetsinloggningar åtskilda lägger du till en webbläsardatakatalog i slutet av varje startares `Exec=`-rad:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Ersätt exempelmappen med en absolut sökväg som du själv väljer och använd samma sökväg för alla sex startare för att dela arbetsinloggningar mellan dem. Webbapparna använder Omarchys valda webbläsare som stöds, och faller tillbaka på Chrome när standardwebbläsaren inte stöds.
