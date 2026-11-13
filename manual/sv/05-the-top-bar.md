# Listen högst upp

Remsan längs skärmens överkant är Omarchy-listen. Det är inte en påskruvad statuslist utan en del av Omarchy-skalet, den enda långkörande Quickshell-processen som också ritar menyn, aviseringarna, OSD-popuperna och låsskärmen. Därför passar dess tema perfekt med allt annat och därför öppnas en panel omedelbart i stället för att starta en ny app.

Det är också den enda delen av skrivbordet som alltid finns på skärmen, så det är värt att veta vad alla de där små glyferna gör.

## Vad som finns på den som standard

Listen har tre sektioner. Till vänster sitter Omarchy-logotypen (menystartaren) och arbetsyteindikatorerna. I mitten får du statusindikatorerna, klockan, Elsewhen (en världsklocka), vädret och ett uppdateringsmärke för Omarchy. Till höger: systembrickan, tangentbordslayouten (när mer än en är konfigurerad), agenter, bluetooth, nätverk, ljud, bildskärm och ström.

Några av dem dyker bara upp när de har något att säga. Tangentbordslayouten visas bara om du har konfigurerat mer än en layout. Uppdateringsmärket visas bara när en Omarchy-uppdatering väntar. Och agentikonen visas första gången Omarchy hittar AI-kodningsanvändning på maskinen (se [AI](17-ai.md)).

## Klicka runt

Nästan varje widget gör något vid vänster-, höger- och mittenklick, och flera svarar på rullning. Det här är delen folk missar — höger- och mittenknapparna är där mycket av det goda gömmer sig.

| Widget | Vänster | Höger | Mitten / rulla |
| --- | --- | --- | --- |
| Meny | Omarchy-menyn | Ny terminal | — |
| Arbetsytor | Fokusera den arbetsytan på den här bildskärmen | — | Rulla: nästa/föregående arbetsyta |
| Klocka | Kalenderpopup | Växla etikettformatet | Mitten: tidszonväljare |
| Väder | Prognospopup | Fullständigt väder som en avisering | Mitten: uppdatera |
| Ljud | Ljudpanel | Tysta | Mitten: panel · rulla: volym |
| Mikrofon | Tysta mikrofonen | — | Mitten: ljudpanel · rulla: ingångsvolym |
| Nätverk | Nätverkspanel | — | — |
| Bluetooth | Bluetooth-panel | Slå av/på radion | — |
| Bildskärm | Bildskärmspanel | — | Rulla: ljusstyrka |
| Ström | Strömpanel | Slå av/på batteriprocenten | — |
| Media | Spela/pausa | Popup för omslagsbild | Mitten: nästa · rulla: föregående/nästa |
| Agenter | Agentpanel | Starta din agent | Mitten: nästa prenumeration |
| Systembricka | Håll musen över för att visa lådan | Högerklicka på chevronen för att hantera | — |
| Omarchy-uppdatering | Kör uppdateringen | — | — |

Allt i den tabellen finns inte på din list direkt ur lådan. Mediawidgeten (MPRIS nu spelas, med ett rullande spår och artist) och mikrofonwidgeten är båda inbyggda men avstängda som standard — lägg till dem om du vill ha dem, enligt beskrivningen nedan.

## Panelerna

Att klicka på en listikon öppnar en panel, som är en riktig popup med reglage, listor och tangentbordsnavigering snarare än ett verktygstips. Var och en har också en snabbtangent, så du aldrig behöver sikta på en glyf på 16 pixlar:

| Snabbtangent | Panel |
| --- | --- |
| `Super + Ctrl + A` | Ljud |
| `Super + Ctrl + N` | Nätverk |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Bildskärm |
| `Super + Ctrl + P` | Ström |
| `Super + Ctrl + Alt + D` | Kalender |
| `Super + Ctrl + Alt + E` | Världsklocka |
| `Super + Ctrl + 1-9` | Slå av/på den n:te panelen i den högra sektionen |

Panelerna är inte avläsningar. Det är där du faktiskt gör saken:

- **Ljud** har ett huvudvolymreglage, en väljare för utmatningsenhet och en mixer per app, så att du kan sänka den där enda webbläsarfliken utan att röra allt annat.
- **Nätverk** söker efter Wi-Fi, visar signalstyrka, ansluter och låter dig välja en DNS-leverantör.
- **Bluetooth** listar dina enheter med anslut/koppla från och batterinivåer.
- **Ström** visar batteristatistik, byter strömprofiler (den kommer ihåg ett separat val för batteri och AC) och skriver ut lite systeminfo.
- **Bildskärm** har ett ljusstyrkereglage, textstorlek, förinställningar för bildskärmsskalning och — när du har mer än en skärm — kontroller per bildskärm. Se [bildskärmar](33-monitors.md) för den djupare historien.
- **Klocka** öppnar ett rutnät för månaden med ISO-veckonummer och stegning mellan månader.
- **Världsklocka** har en rad per stad, med dess väder och hur dess dag går. Sök hittar orter såväl som tidszoner, så Fort Lauderdale är Fort Lauderdale och inte New York. Om raden högst upp anger fel stad klickar du på den och säger var du är; väljer du någonstans i en annan tidszon flyttar systemklockan dit också, vilket är praktiskt när du reser. Håll musen över en stad och klicka på personknappen för att säga vem som bor där — vanliga namn, eller `@` GitHub-handtag för att få med deras ansikten.

Varje panel tar tangentbordet såväl som musen: pilarna flyttar, Return aktiverar, Tab stegar till grannpanelen och Escape stänger.

`Super + Ctrl + 1-9` räknar paneler från vänster till höger i den högra sektionen, och hoppar över systembrickan eftersom den inte har någon egen panel. Så numret matchar ikonen du skulle peka på.

### Tailscale och Dropbox

Ytterligare två widgetar dyker upp på listen först när du installerar den matchande tjänsten från **Installera → Tjänst**, och båda är värda att känna till eftersom de gör mer än att rapportera status.

**Tailscale**-panelen ansluter och kopplar från tailnet, byter mellan konton och väljer en exit-nod (både dina egna maskiner och Mullvad-regioner dyker upp i den listan). Den bläddrar också bland dina maskiner — och med en vald skickar `s` filer till den via Taildrop, vilket är det snabbaste sättet att flytta en fil till din telefon eller en annan bärbar dator. `c` kopierar maskinens IP, `n` dess namn och `d` dess fullständiga DNS-namn. Det finns en skicka-knapp på varje maskinrad också, om du hellre klickar. Samma sak från terminalen är `omarchy tailscale send <machine> [file...]`.

**Dropbox**-panelen hanterar inloggning, visar hur mycket lagring du har använt och listar nyligen synkade filer.

Att ta bort någon av tjänsterna tar bort dess widget från listen igen.

## Indikatorer

Det lilla klustret i mitten är indikatorwidgeten. Det är statusglyfer för lägen du har slagit på: stör ej, nattljus, en köad [påminnelse](09-reminders.md), en aktiv skärminspelning, håll vaken och [diktering](11-text-extraction-dictation.md). De lyser upp när läget är aktivt och håller sig annars undan — håll musen precis bredvid dem, där de inaktiva skulle sitta, för att tjuvkika på dem. Att klicka på en indikator slår av/på det läget. Ytterligare en är endast status: en fjärrsession lyser rött medan någon är ansluten till den här maskinen via gliff.

Om du hellre vill att de alltid ska vara synliga sätter du `alwaysShow` till `true` på widgeten. Och om du bara bryr dig om några av dem listar du dem du vill ha i `items`: `["Dnd", "Reminder", "NightLight"]`. Du kan ha mer än en indikatorwidget, så olika sektioner kan visa olika delmängder.

## Ordna om listen

Listen konfigurerar sig själv. Du behöver inte öppna en konfigurationsfil för att flytta saker.

Ta tag i en tom fläck på listen runt mitten och dra den mot en annan skärmkant, så flyttar listen dit — vänster, höger, överst eller nederst fungerar alla, och varje widget anpassar sig (vertikala lister faller tillbaka på kompakta former med endast ikoner). Ett klick-och-håll startar samma drag. Dubbelvänsterklicka på samma tomma yta för att växla listbakgrunden från klar till glasig till ogenomskinlig. Och dra valfri widget för att ordna om den eller kasta in den i en annan sektion; de andra widgetarna glider isär för att göra plats där den kommer att landa.

Listens mitt är en låda: vad som än finns i den stannar centrerat som en grupp, och widgetarna på vardera sidan om den hänger på dess kanter. Medan du drar en widget visas lådan som en kontur, eller en linje tvärs över listen när den är tom, och du kan släppa in i den eller bredvid den. När ett släpp skulle landa i lådan växer lådan för att ta in widgeten.

En widget du vill ha i närheten men inte alltid i sikte kan hamna i systembrickans låda: dra den till systembrickan, så öppnas lådan för att ta emot den. Den sitter där efter appikonerna, dyker upp närhelst lådan gör det och håller sin låda öppen medan dess panel är uppe. Dra den tillbaka ut på listen för att sätta tillbaka den.

Om du hellre väljer från en meny har **Utseende → Menylist** positionen, och **Listbakgrund** väljer hur listen ritas: **Ogenomskinlig list**, **Glasig list** (genomskinlig, med det som ligger bakom suddigt) eller **Klar list**.

Samma saker har kommandon, vilket är vad du vill ha för en [dotfiles](31-dotfiles.md)-uppsättning:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

För att lägga till eller ta bort en widget helt använder du plugin-kommandona. `omarchy plugin list` skriver ut varje widget som skalet känner till med dess id, och sedan:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Dölja listen

`Super + Shift + Space` slår av listen och på den igen utan att döda skalet — paneler och snabbtangenter fortsätter att fungera, du får bara tillbaka pixlarna. Den finns också i menyn under **Utseende → Menylist → Dölj list**.

## Konfigurationsfilen

Allt lagras i `~/.config/omarchy/shell.json`, under `bar`-nyckeln. Här är en nedkortad version:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "centerBegin": [{ "id": "omarchy.indicators" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "centerEnd": [{ "id": "omarchy.weather" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Varje widget är en post i en av de fem layoutmatriserna, och dess inställningar sitter inline på den posten — det finns ingen separat inställningsfil och inget `config`-underobjekt. Klockans `format`, `formatAlt` (vad högerklick växlar till) och `verticalFormat` bor alla precis där på `{ "id": "omarchy.clock" }`.

`center` är lådan i listens mitt: allt i den centreras på skärmen som en grupp. `centerBegin` och `centerEnd` hänger på vardera sidan av lådan, vilket är hur klockan stannar exakt i mitten även när vädret och uppdateringsmärket kommer och går. Sätt mer än en widget i `center` så centreras de tillsammans; lämna den tom så möts `centerBegin` och `centerEnd` i listens mitt.

En regel värd att internalisera: **när du väl har din egen `shell.json` är den kanonisk**. Tills du anpassar något läser skalet Omarchys standardfil. I samma ögonblick som du drar en widget, kör `omarchy bar` eller redigerar filen själv äger du den — det finns ingen djup sammanslagning, så nya standardwidgetar i framtida Omarchy-versioner kommer inte att dyka upp på din list automatiskt. `omarchy bar defaults` sätter tillbaka den medföljande layouten närhelst du vill börja om från början.

Samma fil innehåller också dina inaktivitetstider på den översta nivån, utanför `bar`-nyckeln: `idle.screensaver` och `idle.lock`, båda i sekunder sedan du gick in i inaktivitet. Så standardskärmsläckaren går igång vid 150 sekunder och låset vid 300.
