# Den övre listen

Listen längs överkanten på skärmen är Omarchy-listen. Den är ingen påskruvad statuslist utan en del av Omarchy-skalet, den enda långlivade Quickshell-processen som också ritar menyn, aviseringarna, OSD-popupfönstren och låsskärmen. Det är därför den matchar temat perfekt med allt annat och varför en panel öppnas direkt i stället för att starta en ny app.

Den är också den enda delen av skrivbordet som alltid syns på skärmen, så det är värt att veta vad alla de där små glyferna gör.

## Vad som finns på den som standard

Listen har tre sektioner. Till vänster sitter Omarchy-logotypen (menystartaren) och arbetsyteindikatorerna. I mitten får du statusindikatorerna, klockan, Elsewhen (en världsklocka), vädret och ett Omarchy-uppdateringsmärke. Till höger: systemfältet, tangentbordslayouten (när mer än en layout eller inmatningsmetod är konfigurerad), agents, bluetooth, nätverk, ljud, skärm och ström.

Några av dem visas bara när de har något att säga. Tangentbordslayouten visas bara om du har konfigurerat mer än en layout eller inmatningsmetod. Uppdateringsmärket visas bara när det väntar en Omarchy-uppdatering.

## Klicka runt

Nästan varje widget gör något vid vänster-, höger- och mittenklick, och flera svarar på rullning. Det här är delen folk missar — det är bakom höger- och mittenknapparna som mycket av det bra gömmer sig.

| Widget | Vänster | Höger | Mitten / rullning |
| --- | --- | --- | --- |
| Meny | Omarchy-meny | Ny terminal | — |
| Arbetsytor | Fokusera den arbetsytan på den här skärmen | — | Rulla: nästa/föregående arbetsyta |
| Klocka | Kalender-popup | Växla etikettformatet | Mitten: tidszonsväljare |
| Världsklocka | Världsklockspanel | Uppdatera | Mitten: uppdatera |
| Väder | Prognos-popup | Fullständigt väder som en avisering | Mitten: uppdatera |
| Ljud | Ljudpanel | Tyst | Mitten: panel · rulla: volym |
| Mikrofon | Tysta mikrofonen | — | Mitten: ljudpanel · rulla: inmatningsvolym |
| Nätverk | Nätverkspanel | — | — |
| Bluetooth | Bluetooth-panel | Slå av/på radion | — |
| Skärm | Skärmpanel | — | Rulla: ljusstyrka |
| Ström | Strömpanel | Slå av/på batteriprocenten | — |
| Media | Spela/pausa | Popup för omslagsbild | Mitten: nästa · rulla: föreg./nästa |
| Agents | Agents-panel | Starta din agent | Mitten: uppdatera användning |
| Systemfält | Hovra för att visa lådan | Högerklicka på chevronen för att hantera | — |
| Omarchy-uppdatering | Kör uppdateringen | — | — |

Allt i den tabellen finns inte på din list direkt från start. Mediawidgeten (MPRIS som visar vad som spelas nu, med en rullande låt och artist) och mikrofonwidgeten är båda inbyggda men avstängda som standard — lägg till dem om du vill ha dem, så som det beskrivs nedan.

## Panelerna

Att klicka på en listikon öppnar en panel, som är ett riktigt popupfönster med skjutreglage, listor och tangentbordsnavigering snarare än en verktygstipsruta. Var och en har också en snabbtangent, så du aldrig behöver sikta på en glyf på 16 pixlar:

| Hotkey | Panel |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + N` | Network |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Display |
| `Super + Ctrl + P` | Power |
| `Super + Ctrl + Alt + D` | Calendar |
| `Super + Ctrl + Alt + E` | World clock |
| `Super + Ctrl + X` | Agents |
| `Super + Ctrl + 1-9` | Toggle the nth panel in the right section |

Panelerna är inga avläsningar. Det är där du faktiskt gör grejen:

- **Audio** har ett huvudvolymreglage, en väljare för utmatningsenhet och en mixer per app, så du kan sänka just den där webbläsarfliken utan att röra allt annat.
- **Network** söker efter Wi-Fi, visar signalstyrka, ansluter och låter dig välja en DNS-leverantör.
- **Bluetooth** listar dina enheter med anslut/koppla från och batterinivåer.
- **Power** visar batteristatistik, växlar strömprofiler (den kommer ihåg ett separat val för batteri och AC) och skriver ut lite systeminfo.
- **Display** har ett reglage för ljusstyrka, textstorlek, förinställningar för skärmskalning och — när du har mer än en skärm — kontroller per skärm. Se [bildskärmar](33-monitors.md) för hela historien.
- **Clock** öppnar ett månadsrutnät med ISO-veckonummer och stegning mellan månader.
- **World clock** håller en rad per stad, med dess väder och hur dess dag fortlöper. Sök hittar orter såväl som tidszoner, så Fort Lauderdale är Fort Lauderdale och inte New York. Om raden högst upp anger fel stad, klicka på den och säg var du är; välj någonstans i en annan tidszon och systemklockan flyttar dit också, vilket är praktiskt när du reser. Hovra över en stad och klicka på personknappen för att säga vem som bor där — vanliga namn, eller `@` GitHub-användarnamn för att ta med deras ansikten.

Varje panel tar emot tangentbordet såväl som musen: pilar flyttar, Return aktiverar, Tab går till panelen bredvid och Escape stänger.

`Super + Ctrl + 1-9` räknar paneler från vänster till höger i den högra sektionen, och hoppar över systemfältet eftersom det inte har någon egen panel. Så numret matchar ikonen du skulle peka på.

### Tailscale och Dropbox

Ytterligare två widgets visas på listen först när du installerar matchande tjänst från **Install → Service**, och båda är värda att känna till eftersom de gör mer än att rapportera status.

**Tailscale**-panelen ansluter och kopplar från tailnet, växlar mellan konton och väljer en exit node (både dina egna maskiner och Mullvad-regioner dyker upp i den listan). Den bläddrar också bland dina maskiner — och med en vald skickar `s` filer till den via Taildrop, vilket är det snabbaste sättet att flytta en fil till din telefon eller en annan bärbar dator. `c` kopierar maskinens IP, `n` dess namn och `d` dess fullständiga DNS-namn. Det finns en skicka-knapp på varje maskinrad också, om du hellre klickar. Samma sak från terminalen är `omarchy tailscale send <machine> [file...]`.

**Dropbox**-panelen hanterar inloggning, visar hur mycket lagring du har använt och listar nyligen synkade filer.

Att ta bort någon av tjänsterna tar bort dess widget från listen igen.

## Indikatorer

Den lilla klungan i mitten är indikatorwidgeten. Det här är statusglyfer för lägen du har slagit på: stör ej, nattljus, en köad [påminnelse](09-reminders.md), en aktiv skärminspelning och håll dig vaken, plus varningar medan lösenordslös sudo är på eller någon är ansluten till en fjärrsession. De lyser upp när läget är aktivt och håller sig annars undan — hovra precis bredvid dem, där de inaktiva skulle sitta, för att tjuvkika på dem. Att klicka på en indikator slår av/på det läget. Ytterligare en är endast status: en fjärrsession lyser rött medan någon är ansluten till den här maskinen via gliff.

Om du hellre vill att de alltid ska synas, sätt `alwaysShow` till `true` på widgeten. Och om du bara bryr dig om några av dem, lista dem du vill ha i `items`: `["Dnd", "Reminder", "NightLight"]`. Du kan ha mer än en indikatorwidget, så olika sektioner kan visa olika delmängder.

## Ordna om listen

Listen konfigurerar sig själv. Du behöver inte öppna en konfigurationsfil för att flytta saker.

Ta tag i en tom yta på listen runt mitten och dra den mot en annan skärmkant, så flyttar listen dit — vänster, höger, överst eller nederst fungerar allt, och varje widget anpassar sig (vertikala lister faller tillbaka till kompakta former med bara ikoner). Ett klick-och-håll startar samma dragning. Dubbelvänsterklicka på samma tomma yta för att växla listbakgrunden från klar till glasig till ogenomskinlig. Och dra vilken widget som helst för att ordna om den eller kasta in den i en annan sektion; de andra widgetarna glider isär för att göra plats där den kommer att landa.

Mitten av listen är en låda: vad som än finns i den förblir centrerat som en grupp, och widgetarna på var sida om den hänger på dess kanter. Medan du drar en widget visas lådan som en kontur, eller en linje tvärs över listen när den är tom, och du kan släppa in i den eller bredvid den. När ett släpp skulle landa i lådan växer lådan för att ta in widgeten.

En widget som du vill ha i närheten men inte alltid i sikte kan hamna i systemfältets låda: dra den till systemfältet, så öppnas lådan för att ta emot den. Den sitter där efter appikonerna, visas närhelst lådan gör det och håller sin låda öppen medan dess panel är uppe. Dra tillbaka den till listen för att sätta tillbaka den.

Om du hellre väljer från en meny har **Appearance → Menu Bar** positionen, och **Bar Background** väljer hur listen ritas: **Opaque Bar**, **Glassy Bar** (genomskinlig, med det som ligger bakom suddigt) eller **Clear Bar**.

Samma saker har kommandon, vilket är vad du vill ha för en [dotfiles](31-dotfiles.md)-uppsättning:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

För att lägga till eller ta bort en widget helt, använd plugin-kommandona. `omarchy plugin list` skriver ut varje widget som skalet känner till med dess id, och sedan:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Dölja listen

`Super + Shift + Space` slår av listen och slår på den igen utan att döda skalet — paneler och snabbtangenter fortsätter fungera, du får bara pixlarna tillbaka. Det finns också i menyn under **Appearance → Menu Bar → Hide Bar**.

## Konfigurationsfilen

Allt lagras i `~/.config/omarchy/shell.json`, under nyckeln `bar`. Här är en trimmad version:

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

Varje widget är en post i en av de fem layoutlistorna, och dess inställningar sitter inline på den posten — det finns ingen separat inställningsfil och inget `config`-underobjekt. Klockans `format`, `formatAlt` (det som högerklick växlar till) och `verticalFormat` bor alla precis där på `{ "id": "omarchy.clock" }`.

`center` är lådan i mitten av listen: allt i den centreras på skärmen som en grupp. `centerBegin` och `centerEnd` hänger på var sida om lådan, vilket är hur klockan håller sig exakt i mitten även när vädret och uppdateringsmärket kommer och går. Lägg mer än en widget i `center` så centreras de tillsammans; lämna den tom så möts `centerBegin` och `centerEnd` i mitten av listen.

En regel värd att internalisera: **när du väl har din egen `shell.json` är den kanonisk**. Tills du anpassar något läser skalet Omarchys standardfil. I samma ögonblick som du drar en widget, kör `omarchy bar` eller redigerar filen själv äger du den — det sker ingen djup sammanslagning, så nya standardwidgets i framtida Omarchy-versioner kommer inte att dyka upp på din list automatiskt. `omarchy bar defaults` sätter tillbaka den medföljande layouten närhelst du vill börja om från noll.

Samma fil håller också dina inaktivitetstider på toppnivå, utanför nyckeln `bar`: `idle.screensaver` och `idle.lock`, båda i sekunder sedan du blev inaktiv. Så standardskärmsläckaren slår till efter 150 sekunder och låset efter 300.
