# Menyfältet

Remsan längs överkanten av din skärm är Omarchy-fältet. Det är inte ett påbultat statusfält utan en del av Omarchy-skalet, den enda långvariga Quickshell-processen som också ritar menyn, aviseringarna, OSD-popuparna och låsskärmen. Det är därför den tematiseras perfekt med allt annat och varför en panel öppnas omedelbart i stället för att starta en ny app.

Det är också den enda delen av skrivbordet som alltid syns på skärmen, så det är värt att veta vad alla de små symbolerna gör.

## Vad som finns på det som standard

Fältet har tre sektioner. Till vänster sitter Omarchy-logotypen (menystartaren) och arbetsyteindikatorerna. I mitten får du statusindikatorerna, klockan, Elsewhen (en världsklocka), vädret och ett Omarchy-uppdateringsmärke. Till höger: tangentbordslayouten (när mer än en är konfigurerad), systemfältet, agenter, bluetooth, nätverk, ljud, skärm och ström.

Några av dem visas bara när de har något att säga. Tangentbordslayouten visas bara om du har konfigurerat mer än en layout. Uppdateringsmärket visas bara när en Omarchy-uppdatering väntar. Och agentikonen visas första gången Omarchy hittar AI-kodanvändning på maskinen (se [AI](17-ai.md)).

## Klicka runt

Nästan varje widget gör något vid vänster-, höger- och mittenklick, och flera svarar på rullning. Det är den här delen folk missar — höger- och mittenknapparna är där mycket av det goda gömmer sig.

| Widget | Vänster | Höger | Mitten / rullning |
| --- | --- | --- | --- |
| Menu | Omarchy-menyn | Ny terminal | — |
| Workspaces | Fokusera den arbetsytan | — | Rullning: nästa/föregående arbetsyta |
| Clock | Kalender-popup | Cykla etikettformatet | Mitten: tidszonsväljare |
| Weather | Prognos-popup | Fullt väder som avisering | Mitten: uppdatera |
| Audio | Ljudpanel | Tysta | Mitten: panel · rullning: volym |
| Microphone | Tysta mikrofonen | — | Mitten: ljudpanel · rullning: ingångsvolym |
| Network | Nätverkspanel | — | — |
| Bluetooth | Bluetooth-panel | Växla radion | — |
| Display | Skärmpanel | — | Rullning: ljusstyrka |
| Power | Strömpanel | Växla batteriprocenten | — |
| Media | Spela/pausa | Omslags-popup | Mitten: nästa · rullning: föreg./nästa |
| Agents | Agentpanel | Starta din agent | Mitten: nästa prenumeration |
| Tray | Hovra för att visa lådan | Höger på chevronen för att hantera | — |
| Omarchy update | Kör uppdateringen | — | — |

Inte allt i den tabellen finns på ditt fält direkt ur lådan. Mediawidgeten (MPRIS nu-spelande, med rullande spår och artist) och mikrofonwidgeten är båda inbyggda men av som standard — lägg till dem om du vill, enligt beskrivningen nedan.

## Panelerna

Att klicka på en fältikon öppnar en panel, som är en ordentlig popup med skjutreglage, listor och tangentbordsnavigering snarare än ett verktygstips. Varje panel har också en snabbtangent, så du aldrig behöver sikta på en 16-pixels symbol:

| Snabbtangent | Panel |
| --- | --- |
| `Super + Ctrl + A` | Ljud |
| `Super + Ctrl + W` | Nätverk |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Skärm |
| `Super + Ctrl + P` | Ström |
| `Super + Ctrl + Alt + D` | Kalender |
| `Super + Ctrl + Alt + E` | Världsklocka |
| `Super + Ctrl + 1-9` | Växla den n:te panelen i högersektionen |

Panelerna är inte avläsningar. De är där du faktiskt gör saken:

- **Audio** har ett huvudvolymreglage, en väljare för utmatningsenhet och en mixer per app, så att du kan sänka den där enda webbläsarfliken utan att röra allt annat.
- **Network** söker efter Wi-Fi, visar signalstyrka, ansluter och låter dig välja en DNS-leverantör.
- **Bluetooth** listar dina enheter med anslut/frånkoppla och batterinivåer.
- **Power** visar batteristatistik, växlar strömprofiler (den kommer ihåg ett separat val för batteri och AC) och skriver ut viss systeminformation.
- **Display** har ett ljusstyrkereglerage, textstorlek, förinställningar för skärmskalning och — när du har mer än en skärm — kontroller per skärm. Se [skärmar](33-monitors.md) för den djupare historien.
- **Clock** öppnar ett månadsrutnät med ISO-veckonummer och månadssteg.

Varje panel tar tangentbordet såväl som musen: pilarna flyttar, Return aktiverar, Tab går till grannpanelen och Escape stänger.

`Super + Ctrl + 1-9` räknar paneler från vänster till höger i högersektionen och hoppar över systemfältet eftersom det inte har någon egen panel. Så numret matchar ikonen du skulle peka på.

### Tailscale och Dropbox

Ytterligare två widgetar visas på fältet först när du installerar matchande tjänst från **Install → Service**, och båda är värda att känna till eftersom de gör mer än att rapportera status.

Panelen **Tailscale** ansluter och kopplar från tailnetet, växlar mellan konton och väljer en exit-nod (dina egna maskiner och Mullvad-regioner visas båda i den listan). Den bläddrar också bland dina maskiner — och med en vald skickar `s` filer till den över Taildrop, vilket är det snabbaste sättet att flytta en fil till din telefon eller en annan bärbar dator. `c` kopierar maskinens IP, `n` dess namn och `d` dess fullständiga DNS-namn. Det finns också en skicka-knapp på varje maskinrad, om du hellre vill klicka. Samma sak från terminalen är `omarchy tailscale send <machine> [file...]`.

Panelen **Dropbox** hanterar inloggning, visar hur mycket lagring du har använt och listar nyligen synkroniserade filer.

Att ta bort någon av tjänsterna tar bort dess widget från fältet.

## Indikatorer

Den lilla klungan i mitten är indikatorwidgeten. Det är statussymboler för lägen du har slagit på: stör ej, nattljus, en köad [påminnelse](09-reminders.md), en aktiv skärminspelning, håll vaken och [diktering](11-text-extraction-dictation.md). De tänds när läget är aktivt och håller sig annars ur vägen — hovra till vänster om klockan (ovanför den på ett vertikalt fält) för att tjuvkika på de inaktiva. Att klicka på en indikator växlar det läget. Ytterligare en är endast status: en fjärrsession lyser rött medan någon är ansluten till den här maskinen via gliff.

Om du hellre vill att de alltid ska synas, ställ in `alwaysShow` till `true` på widgeten. Och om du bara bryr dig om några av dem, lista dem du vill ha i `items`: `["Dnd", "Reminder", "NightLight"]`. Du kan ha mer än en indikatorwidget, så olika sektioner kan visa olika delmängder.

## Arrangera om fältet

Fältet konfigurerar sig själv. Du behöver inte öppna en konfigurationsfil för att flytta saker.

Ta tag i en tom fläck av fältet runt mitten och dra den mot en annan skärmkant, så flyttar fältet dit — vänster, höger, överst eller underst fungerar alla, och varje widget anpassar sig (vertikala fält faller tillbaka till kompakta former med endast ikoner). Ett klick-och-håll startar samma drag. Dubbelvänsterklicka på samma tomma utrymme för att cykla fältbakgrunden från klar till glasig till ogenomskinlig. Och dra valfri widget för att ordna om den eller kasta den i en annan sektion.

En widget du vill ha kvar men inte alltid vill se kan hamna i systemfältets låda: dra den till systemfältet, så öppnas lådan för att ta emot den. Den sitter där efter appikonerna, dyker upp när lådan gör det och håller lådan öppen medan dess panel är uppe. Dra tillbaka den ut på fältet för att sätta tillbaka den.

Om du hellre vill välja från en meny har **Trigger → Appearance → Menu Bar** positionen, och **Bar Background** väljer hur fältet ritas: **Opaque Bar**, **Glassy Bar** (genomskinlig, med det bakom oskarpt) eller **Clear Bar**.

Samma saker har kommandon, vilket är vad du vill ha för en [dotfiles](31-dotfiles.md)-konfiguration:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.clock --section center --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

För att lägga till eller ta bort en widget helt, använd plugin-kommandona. `omarchy plugin list` skriver ut varje widget skalet känner till med dess id, och sedan:

```bash
omarchy plugin enable omarchy.media --section center
omarchy plugin disable omarchy.weather
```

## Dölja fältet

`Super + Shift + Space` växlar fältet av och tillbaka på utan att döda skalet — paneler och snabbtangenter fortsätter att fungera, du får bara tillbaka pixlarna. Det finns också i menyn under **Trigger → Appearance → Menu Bar → Hide Bar**.

## Konfigurationsfilen

Allt lagras i `~/.config/omarchy/shell.json`, under nyckeln `bar`. Här är en nedklippt version:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "centerAnchor": "omarchy.clock",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Varje widget är en post i en av de tre layoutarrayerna, och dess inställningar sitter inline på den posten — det finns ingen separat inställningsfil och inget `config`-underobjekt. Klockans `format`, `formatAlt` (vad högerklick cyklar till) och `verticalFormat` bor alla precis där på `{ "id": "omarchy.clock" }`.

`centerAnchor` namnger den enda mittwidgeten som fästs exakt i skärmens mitt, med de andra flankerande den. Det är så klockan förblir död i mitten även när vädret och uppdateringsmärket kommer och går. Ställ in den på en tom sträng så centreras mittlistan bara som en grupp i stället.

En regel värd att internalisera: **när du väl har din egen `shell.json` är den kanonisk**. Tills du anpassar någonting läser skalet Omarchys standardfil. I samma ögonblick som du drar en widget, kör `omarchy bar` eller redigerar filen själv äger du den — det finns ingen djup sammanslagning, så nya standardwidgetar i framtida Omarchy-versioner dyker inte upp på ditt fält automatiskt. `omarchy bar defaults` sätter tillbaka den levererade layouten när du vill ha ett rent blad.

Samma fil innehåller också dina inaktivitetstider på toppnivå, utanför nyckeln `bar`: `idle.screensaver` och `idle.lock`, båda i sekunder sedan du blev inaktiv. Så standardskärmsläckaren aktiveras vid 150 sekunder och låset vid 300.
