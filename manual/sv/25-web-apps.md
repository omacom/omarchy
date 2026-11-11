# Webbappar

Du kan lägga till dina egna webbappar med _Installera > Webbapp_ i Omarchy-menyn (`Super + Space`). Den kommer att be dig om appnamnet, appens URL och ikonens URL, om den inte kan hämta den via favicon. Du kan hitta snygga PNG-ikoner för många populära webbappar på [Dashboard Icons](https://dashboardicons.com).

De blir sedan tillgängliga via appstartaren (`Super + Space`) och använder det vackra ramlösa webbappsfönstret.

Om du vill ta bort en webbapp går du bara till _Ta bort > Webbapp_ i Omarchy-menyn.

Det är bäst om du loggar in på alla dina konton med en vanlig webbläsare innan du använder genvägarna till webbapparna. Den tunna omslagsramen fungerar inte bra med 1password, så det är helt enkelt enklare att vara inloggad direkt från början.

Alla tangentbordsgenvägar för dessa webbappar kan ändras i `~/.config/hypr/bindings.lua`.

När du är i en webbapp kan du kopiera den aktuella URL:en till urklipp med `Shift + Alt + L`.

Som standard levereras Omarchy redan med ett urval av standardappar:

## HEY

[HEY](https://www.hey.com/) är en tjänst för e-post och kalender som är ett utmärkt alternativ för personer som är trötta på Gmail, Outlook eller Apple Mail. Den är gjord av [37signals](https://37signals.com/) där Omarchy har sitt ursprung.

Du kan starta HEY Email med `Super + Shift + E`, gå direkt till att skriva ett nytt e-postmeddelande med `Super + Shift + Alt + E` och starta HEY Calendar med `Super + Shift + C`.

## Basecamp

[Basecamp](https://basecamp.com/) är en projekthanteringstjänst som hjälper små team att arbeta snabbare och göra fler framsteg. I stället för att lappa ihop en salig blandning av Trello, Slack, Asana, Notion eller vad som helst kan du få allt på ett ställe med Basecamp. Den är gjord av [37signals](https://37signals.com/) där Omarchy har sitt ursprung.

Du kan starta Basecamp med appstartaren (`Super + Space`)

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

Google Messages, Google Photos, Google Maps och Google Contacts ingår också som webbappar.

Du kan starta Google Messages med `Super + Shift + Ctrl + G`, Google Photos med `Super + Shift + P` och Google Maps med `Super + Shift + S`. Google Contacts är tillgängligt via appstartaren (`Super + Space`).

## X

X är där nyheterna bryter fram.

Du kan starta X med `Super + Shift + X` och gå direkt till att skriva ett nytt inlägg med `Super + Shift + Alt + X`.

## YouTube

[YouTube](https://youtube.com/) är den mest populära videoplattformen i världen.

Du kan starta YouTube med `Super + Shift + Y`.

## Zoom

[Zoom](https://zoom.us/) är det mest populära videochattsystemet som används i USA. Bra uppkopplingar över hela världen. Och 40-minutersmöten kan hållas utan ett betalkonto. Omarchy kapslar in Zoom-webbklienten, och Zoom-möteslänkar öppnas direkt i den.

Du startar Zoom med appstartaren (`Super + Space`).

## Discord

[Discord](https://discord.com/) är där de flesta spel- och open source-gemenskaperna hänger, inklusive [Omarchys egen](https://discord.gg/tXFUdasqhY).

Du startar Discord med appstartaren (`Super + Space`).

## Microsoft-appar

Välj _Installera > Tjänst > Microsoft_ för att lägga till Outlook, Word, Excel, PowerPoint, Teams och OneDrive som webbappar. Varje app har sin egen startare och öppnas direkt, med de kommersiella Microsoft 365-URL:erna och din befintliga webbläsarprofil. De öppnas i samma webbläsarappfönster som Omarchys andra webbappar; de installerar inte den separata Teams for Linux-klienten.

Ta bort paketet med _Ta bort > Tjänst > Microsoft_, eller ta bort enskilda appar med _Ta bort > Webbapp_. Du kan också installera bara de appar du vill ha via _Installera > Webbapp_.

För ett statligt eller suveränt moln redigerar du URL:en på `Exec=`-raden i den aktuella startaren under `~/.local/share/applications/`, till exempel `Microsoft Teams.desktop`, med den URL som din organisation har tillhandahållit. Skriv varje bokstavligt `%` på den raden som `%%`. Ändringar träder i kraft vid nästa start. Om du kör paketinstalleraren igen ersätts dess startare med standard-URL:erna.

För att hålla arbetsinloggningar åtskilda lägger du till en katalog för webbläsardata på varje startares `Exec=`-rad:

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

Ersätt exempelkatalogen med en absolut sökväg som du väljer själv och använd samma sökväg för alla sex startare för att dela arbetsinloggningar mellan dem. Webbapparna använder Omarchys valda webbläsare som stöds och faller tillbaka till Chrome när standardwebbläsaren inte stöds.
