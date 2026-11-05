# Den översta raden

Raden längs överkanten av skärmen är Omarchy-raden. Den är inte en påskruvad statusrad utan en del av Omarchy-skalet, den enda långlivade Quickshell-processen som också ritar menyn, aviseringarna, OSD-popupfönstren och låsskärmen. Det är därför den får perfekt tema tillsammans med allt annat och varför en panel öppnas direkt i stället för att starta en ny app.

Det är också den enda delen av skrivbordet som alltid syns på skärmen, så det är värt att veta vad alla de där små glyferna gör.

## Vad som finns på den som standard

Raden har tre sektioner. Till vänster sitter Omarchy-logotypen (menystartaren) och arbetsyteindikatorerna. I mitten får du statusindikatorerna, klockan, Elsewhen (en världsklocka), vädret och ett märke för Omarchy-uppdateringar. Till höger: systemfältet, tangentbordslayouten (när fler än en är konfigurerad), agenter, bluetooth, nätverk, ljud, bildskärm och ström.

Några av dem visas bara när de har något att säga. Tangentbordslayouten visas bara om du har konfigurerat fler än en layout. Uppdateringsmärket visas bara när en Omarchy-uppdatering väntar. Och agentikonen visas första gången Omarchy hittar AI-kodningsanvändning på datorn (se [AI](17-ai.md)).

## Klicka runt

Nästan varje widget gör något vid vänster-, höger- och mittenklick, och flera svarar på rullning. Det här är delen folk missar — höger- och mittenknapparna är där mycket av det bra gömmer sig.

| Widget | Vänster | Höger | Mitten / rullning |
| --- | --- | --- | --- |
| Meny | Omarchy-menyn | Ny terminal | — |
| Arbetsytor | Fokusera den arbetsytan på den här skärmen | — | Rullning: nästa/föregående arbetsyta |
| Klocka | Kalender-popup | Växla etikettformatet i en cykel | Mitten: tidszonsväljare |
| Väder | Prognos-popup | Fullständigt väder som en avisering | Mitten: uppdatera |
| Ljud | Ljudpanelen | Stäng av ljudet | Mitten: panel · rullning: volym |
| Mikrofon | Stäng av mikrofonen | — | Mitten: ljudpanel · rullning: ingångsvolym |
| Nätverk | Nätverkspanelen | — | — |
| Bluetooth | Bluetooth-panelen | Växla radion på/av | — |
| Bildskärm | Bildskärmspanelen | — | Rullning: ljusstyrka |
| Ström | Strömpanelen | Växla batteriprocenten på/av | — |
| Media | Spela/pausa | Popup för omslagsbild | Mitten: nästa · rullning: föregående/nästa |
| Agenter | Agentpanelen | Starta din agent | Mitten: nästa abonnemang |
| Systemfält | Håll musen över för att visa lådan | Högerklicka på chevronen för att hantera | — |
| Omarchy-uppdatering | Kör uppdateringen | — | — |

Allt i den tabellen finns inte på din rad direkt ur lådan. Mediawidgeten (MPRIS som spelas nu, med ett rullande spår och artist) och mikrofonwidgeten är båda inbyggda men avstängda som standard — lägg till dem om du vill ha dem, enligt beskrivningen nedan.

## Panelerna

Att klicka på en radikon öppnar en panel, vilket är ett riktigt popupfönster med skjutreglage, listor och tangentbordsnavigering snarare än ett verktygstips. Var och en har också en snabbtangent, så du aldrig behöver sikta på en glyf på 16 pixlar:

| Snabbtangent | Panel |
| --- | --- |
| `Super + Ctrl + A` | Ljud |
| `Super + Ctrl + N` | Nätverk |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Bildskärm |
| `Super + Ctrl + P` | Ström |
| `Super + Ctrl + Alt + D` | Kalender |
| `Super + Ctrl + Alt + E` | Världsklocka |
| `Super + Ctrl + 1-9` | Växla den n:te panelen i den högra sektionen |

Panelerna är inte avläsningar. De är där du faktiskt gör saken:

- **Ljud** har ett huvudvolymreglage, en väljare för utmatningsenhet och en mixer per app, så du kan sänka den där enda webbläsarfliken utan att röra allt annat.
- **Nätverk** söker efter Wi-Fi, visar signalstyrka, ansluter och låter dig välja en DNS-leverantör.
- **Bluetooth** listar dina enheter med anslut/koppla från och batterinivåer.
- **Ström** visar batteristatistik, växlar strömprofiler (den kommer ihåg ett separat val för batteri och AC) och skriver ut en del systeminfo.
- **Bildskärm** har ett reglage för ljusstyrka, textstorlek, förinställningar för skärmskalning och — när du har fler än en skärm — kontroller per skärm. Se [skärmar](33-monitors.md) för den djupare historien.
- **Klocka** öppnar ett månadsrutnät med ISO-veckonummer och stegning mellan månader.
- **Världsklocka** håller en rad per stad, med dess väder och hur dess dag går. Sök hittar orter såväl som tidszoner, så Fort Lauderdale är Fort Lauderdale och inte New York. Om raden längst upp anger fel stad, klicka på den och säg var du är; välj någonstans i en annan tidszon och systemklockan flyttar dit också, vilket är praktiskt när du reser. Håll musen över en stad och klicka på personknappen för att säga vem som bor där — vanliga namn, eller `@` GitHub-användarnamn för att ta med deras ansikten.

Varje panel tar tangentbordet såväl som musen: pilar flyttar, Return aktiverar, Tab går till panelen bredvid, och Escape stänger.

`Super + Ctrl + 1-9` räknar paneler från vänster till höger i den högra sektionen och hoppar över systemfältet eftersom det inte har någon egen panel. Så numret matchar ikonen du skulle peka på.

### Tailscale och Dropbox

Två widgetar till visas på raden först när du installerar matchande tjänst från **Installera → Tjänst**, och båda är värda att känna till eftersom de gör mer än att rapportera status.

**Tailscale**-panelen ansluter och kopplar från tailnet, växlar mellan konton och väljer en exit node (både dina egna datorer och Mullvad-regioner visas i den listan). Den bläddrar också bland dina datorer — och med en vald skickar `s` filer till den över Taildrop, vilket är det snabbaste sättet att flytta en fil till din telefon eller en annan bärbar dator. `c` kopierar datorns IP, `n` dess namn och `d` dess fullständiga DNS-namn. Det finns en skicka-knapp på varje datorrad också, om du hellre klickar. Samma sak från terminalen är `omarchy tailscale send <machine> [file...]`.

**Dropbox**-panelen hanterar inloggning, visar hur mycket lagring du har använt och listar nyligen synkade filer.

Att ta bort någon av tjänsterna tar bort dess widget från raden igen.

## Indikatorer

Den lilla klungan i mitten är indikatorwidgeten. Det är statusglyfer för lägen du har slagit på: stör ej, nattljus, en köad [påminnelse](09-reminders.md), en aktiv skärminspelning, håll dig vaken och [diktering](11-text-extraction-dictation.md). De lyser upp när läget är aktivt och håller sig annars undan — håll musen någonstans över raden för att kika på de inaktiva. Att klicka på en indikator växlar det läget. En till är endast status: en fjärrsession lyser rött medan någon är ansluten till den här datorn via gliff.

Om du hellre vill att de alltid ska visas, ställ in `alwaysShow` på `true` på widgeten. Och om du bara bryr dig om några av dem, lista dem du vill ha i `items`: `["Dnd", "Reminder", "NightLight"]`. Du kan ha fler än en indikatorwidget, så olika sektioner kan visa olika delmängder.

## Ordna om raden

Raden konfigurerar sig själv. Du behöver inte öppna en konfigurationsfil för att flytta saker.

Ta tag i en tom fläck på raden runt mitten och dra den mot en annan skärmkant, så flyttar raden dit — vänster, höger, överst eller nederst fungerar alla, och varje widget anpassar sig (vertikala rader faller tillbaka på kompakta former med endast ikoner). Ett klick-och-håll startar samma drag. Dubbelvänsterklicka på samma tomma yta för att växla radens bakgrund i en cykel från genomskinlig till glasartad till ogenomskinlig. Och dra valfri widget för att ordna om den eller kasta den i en annan sektion; de andra widgetarna glider isär för att göra plats där den kommer att landa.

Mitten av raden är en låda: det som finns i den stannar centrerat som en grupp, och widgetarna på vardera sidan om den hänger på dess kanter. Medan du drar en widget visas lådan som en kontur, eller en linje över raden när den är tom, och du kan släppa i den eller bredvid den. När ett släpp skulle landa i lådan växer lådan för att ta in widgeten.

En widget du vill ha runt omkring men inte alltid i sikte kan hamna i systemfältets låda: dra den till systemfältet, så öppnas lådan för att ta emot den. Den sitter där efter appikonerna, visas varje gång lådan gör det, och håller sin låda öppen medan dess panel är uppe. Dra tillbaka den ut på raden för att sätta tillbaka den.

Om du hellre väljer från en meny har **Utseende → Menyrad** positionen, och **Radens bakgrund** väljer hur raden ritas: **Ogenomskinlig rad**, **Glasartad rad** (genomskinlig, med det bakomliggande suddigt) eller **Genomskinlig rad**.

Samma saker har kommandon, vilket är vad du vill ha för en [dotfiles](31-dotfiles.md)-konfiguration:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

För att lägga till eller ta bort en widget helt, använd plugin-kommandona. `omarchy plugin list` skriver ut varje widget skalet känner till med dess id, och sedan:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Dölja raden

`Super + Shift + Space` slår av och på raden igen utan att döda skalet — paneler och snabbtangenter fortsätter att fungera, du får bara tillbaka pixlarna. Den finns också i menyn under **Utseende → Menyrad → Dölj raden**.

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

Varje widget är en post i en av de fem layoutmatriserna, och dess inställningar sitter infogade på den posten — det finns ingen separat inställningsfil och inget `config`-underobjekt. Klockans `format`, `formatAlt` (det högerklick växlar till i en cykel) och `verticalFormat` finns alla just där på `{ "id": "omarchy.clock" }`.

`center` är lådan i mitten av raden: allt i den centreras på skärmen som en grupp. `centerBegin` och `centerEnd` hänger på vardera sidan om lådan, vilket är hur klockan stannar exakt i mitten även när vädret och uppdateringsmärket kommer och går. Lägg fler än en widget i `center` och de centreras tillsammans; lämna den tom och `centerBegin` och `centerEnd` möts i mitten av raden.

En regel värd att internalisera: **när du väl har din egen `shell.json` är den kanonisk**. Tills du anpassar något läser skalet Omarchys standardfil. I det ögonblick du drar en widget, kör `omarchy bar` eller redigerar filen själv äger du den — det finns ingen djup sammanslagning, så nya standardwidgetar i framtida Omarchy-versioner kommer inte att visas på din rad automatiskt. `omarchy bar defaults` sätter tillbaka den levererade layouten när du vill ha ett rent blad.

Samma fil innehåller också dina vilotider på översta nivån, utanför nyckeln `bar`: `idle.screensaver` och `idle.lock`, båda i sekunder sedan du blev inaktiv. Så standardskärmsläckaren sätter igång efter 150 sekunder och låset efter 300.
