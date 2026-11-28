# De bovenbalk

De strook langs de bovenkant van je scherm is de Omarchy-balk. Het is geen vastgeboute statusbalk, maar onderdeel van de Omarchy-shell, het ene langlopende Quickshell-proces dat ook het menu, de meldingen, de OSD-pop-ups en het vergrendelscherm tekent. Daarom stemt hij perfect af met al het andere en daarom opent een paneel meteen in plaats van een nieuwe app te starten.

Het is ook het enige onderdeel van de desktop dat altijd op het scherm staat, dus het loont om te weten wat al die kleine tekens doen.

## Wat er standaard op staat

De balk heeft drie secties. Links zit het Omarchy-logo (de menustarter) en de werkruimte-indicatoren. In het midden krijg je de statusindicatoren, de klok, Elsewhen (een wereldklok), het weer en een Omarchy-updatebadge. Rechts: het systeemvak, de toetsenbordindeling (wanneer meer dan één indeling of invoermethode is geconfigureerd), agents, bluetooth, netwerk, audio, beeldscherm en stroom.

Een paar daarvan verschijnen alleen wanneer ze iets te zeggen hebben. De toetsenbordindeling verschijnt alleen als je meer dan één indeling of invoermethode hebt geconfigureerd. De updatebadge verschijnt alleen wanneer er een Omarchy-update op je wacht.

## Overal op klikken

Bijna elke widget doet iets bij links klikken, rechts klikken en met de middelste knop klikken, en verschillende reageren op scrollen. Dit is het deel dat mensen missen — achter de rechter- en middelste knoppen verbergt zich veel van het goede spul.

| Widget | Links | Rechts | Midden / scrollen |
| --- | --- | --- | --- |
| Menu | Omarchy-menu | Nieuwe terminal | — |
| Werkruimtes | Focus die werkruimte op deze monitor | — | Scrollen: volgende/vorige werkruimte |
| Klok | Agenda-pop-up | Blader door de labelindelingen | Midden: tijdzonekiezer |
| Wereldklok | Wereldklokpaneel | Vernieuwen | Midden: vernieuwen |
| Weer | Weersverwachting-pop-up | Volledig weer als een melding | Midden: vernieuwen |
| Audio | Audiopaneel | Dempen | Midden: paneel · scrollen: volume |
| Microfoon | Demp de microfoon | — | Midden: audiopaneel · scrollen: invoervolume |
| Netwerk | Netwerkpaneel | — | — |
| Bluetooth | Bluetooth-paneel | Schakel de radio in/uit | — |
| Beeldscherm | Beeldschermpaneel | — | Scrollen: helderheid |
| Stroom | Stroompaneel | Schakel het batterijpercentage in/uit | — |
| Media | Afspelen/pauzeren | Pop-up met coverafbeelding | Midden: volgende · scrollen: vorige/volgende |
| Agents | Agents-paneel | Start je agent | Midden: vernieuw gebruik |
| Systeemvak | Beweeg eroverheen om de lade te tonen | Rechts op de chevron om te beheren | — |
| Omarchy-update | Voer de update uit | — | — |

Niet alles in die tabel staat standaard op je balk. De mediawidget (MPRIS nu spelend, met een scrollend nummer en artiest) en de microfoonwidget zijn beide ingebouwd maar standaard uit — voeg ze toe als je ze wilt, zoals hieronder beschreven.

## De panelen

Op een balkpictogram klikken opent een paneel, dat een echte pop-up is met schuifregelaars, lijsten en toetsenbordnavigatie in plaats van een tooltip. Elk paneel heeft ook een sneltoets, dus je hoeft nooit op een teken van 16 pixels te mikken:

| Sneltoets | Paneel |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + N` | Netwerk |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Beeldscherm |
| `Super + Ctrl + P` | Stroom |
| `Super + Ctrl + Alt + D` | Agenda |
| `Super + Ctrl + Alt + E` | Wereldklok |
| `Super + Ctrl + X` | Agents |
| `Super + Ctrl + 1-9` | Schakel het n-de paneel in de rechter sectie in/uit |

De panelen zijn geen uitlezingen. Ze zijn waar je daadwerkelijk het ding doet:

- **Audio** heeft een hoofdvolumeschuifregelaar, een kiezer voor het uitvoerapparaat en een mixer per app, zodat je die ene browsertab zachter kunt zetten zonder al het andere aan te raken.
- **Netwerk** scant naar Wi-Fi, toont de signaalsterkte, maakt verbinding en laat je een DNS-provider kiezen.
- **Bluetooth** somt je apparaten op met verbinden/verbreken en batterijniveaus.
- **Stroom** toont batterijstatistieken, schakelt tussen stroomprofielen (het onthoudt een aparte keuze voor batterij en AC) en toont wat systeeminformatie.
- **Beeldscherm** bevat een helderheidsschuifregelaar, tekstgrootte, presets voor monitorschaling en — wanneer je meer dan één scherm hebt — bediening per monitor. Zie [monitoren](33-monitors.md) voor het diepere verhaal.
- **Klok** opent een maandrooster met ISO-weeknummers en stappen per maand.
- **Wereldklok** houdt een rij per stad bij, met het weer daar en hoe de dag daar verloopt. Zoeken vindt plaatsen evenals tijdzones, dus Fort Lauderdale is Fort Lauderdale en niet New York. Als de regel bovenin de verkeerde stad noemt, klik erop en zeg waar je bent; kies ergens in een andere tijdzone en de systeemklok verhuist daar ook naartoe, wat handig is wanneer je reist. Beweeg over een stad en klik op de persoonsknop om te zeggen wie daar woont — gewone namen, of `@` GitHub-handles om hun gezichten mee te nemen.

Elk paneel accepteert ook het toetsenbord naast de muis: pijlen bewegen, Return activeert, Tab stapt naar het naburige paneel en Escape sluit.

`Super + Ctrl + 1-9` telt panelen van links naar rechts in de rechter sectie en slaat het systeemvak over, omdat dat geen eigen paneel heeft. Dus het nummer komt overeen met het pictogram waar je naar zou wijzen.

### Tailscale en Dropbox

Twee extra widgets verschijnen alleen op de balk zodra je de bijpassende service installeert vanuit **Installeren → Service**, en beide zijn het waard om te kennen omdat ze meer doen dan status rapporteren.

Het **Tailscale**-paneel verbindt en verbreekt het tailnet, wisselt tussen accounts en kiest een exit node (je eigen machines en Mullvad-regio's komen beide in die lijst voor). Het bladert ook door je machines — en met één geselecteerd stuurt `s` bestanden ernaartoe via Taildrop, wat de snelste manier is om een bestand naar je telefoon of een andere laptop te verplaatsen. `c` kopieert het IP van de machine, `n` de naam ervan en `d` de volledige DNS-naam ervan. Er staat ook een verzendknop op elke machinerij, als je liever klikt. Hetzelfde vanuit de terminal is `omarchy tailscale send <machine> [file...]`.

Het **Dropbox**-paneel handelt de login af, toont hoeveel opslag je hebt gebruikt en somt recent gesynchroniseerde bestanden op.

Elk van beide services verwijderen haalt zijn widget weer van de balk.

## Indicatoren

De kleine cluster in het midden is de indicatorenwidget. Dit zijn statustekens voor modi die je hebt aangezet: niet storen, nachtlicht, een in de wachtrij staande [herinnering](09-reminders.md), een actieve schermopname en wakker blijven, plus waarschuwingen terwijl wachtwoordloos sudo aan staat of iemand verbonden is met een externe sessie. Ze lichten op wanneer de modus actief is en blijven anders uit de weg — beweeg er vlak naast, waar de inactieve zouden zitten, om naar die te gluren. Op een indicator klikken schakelt die modus in/uit. Nog één is alleen status: een externe sessie licht rood op terwijl iemand via gliff verbonden is met deze machine.

Als je liever hebt dat ze altijd zichtbaar zijn, zet `alwaysShow` op `true` op de widget. En als alleen sommige je interesseren, som de degene die je wilt op in `items`: `["Dnd", "Reminder", "NightLight"]`. Je kunt meer dan één indicatorenwidget hebben, zodat verschillende secties verschillende subsets kunnen tonen.

## De balk herschikken

De balk configureert zichzelf. Je hoeft geen configbestand te openen om dingen te verplaatsen.

Pak een leeg stuk van de balk rond het midden vast en sleep het naar een andere schermrand, en de balk verhuist daarheen — links, rechts, boven of onder werken allemaal, en elke widget past zich aan (verticale balken vallen terug op compacte vormen met alleen pictogrammen). Klikken en vasthouden begint dezelfde sleepactie. Dubbelklik links op diezelfde lege ruimte om de balkachtergrond te doorlopen van transparant naar glasachtig naar ondoorzichtig. En sleep elke widget om hem te herschikken of in een andere sectie te gooien; de andere widgets schuiven uiteen om ruimte te maken waar hij zal landen.

Het midden van de balk is een doos: wat erin zit, blijft als één groep gecentreerd, en de widgets aan weerszijden ervan hangen aan de randen ervan. Terwijl je een widget sleept, toont de doos zich als een omtrek, of een lijn over de balk wanneer hij leeg is, en je kunt erin of ernaast neerzetten. Wanneer een neerzetactie in de doos zou landen, groeit de doos om de widget op te nemen.

Een widget die je bij de hand wilt hebben maar niet altijd in beeld, kan in de lade van het systeemvak: sleep hem op het systeemvak, en de lade opent om hem op te nemen. Hij zit daar na de app-pictogrammen, verschijnt wanneer de lade dat doet en houdt zijn lade open terwijl zijn paneel open is. Sleep hem terug op de balk om hem terug te zetten.

Als je liever uit een menu kiest, heeft **Uiterlijk → Menubalk** de positie, en **Balkachtergrond** kiest hoe de balk wordt getekend: **Ondoorzichtige balk**, **Glasachtige balk** (doorzichtig, met wat erachter zit vervaagd) of **Transparante balk**.

Dezelfde dingen hebben commando's, wat je wilt voor een [dotfiles](31-dotfiles.md)-opzet:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Om een widget helemaal toe te voegen of te verwijderen, gebruik je de plugin-commando's. `omarchy plugin list` drukt elke widget af die de shell kent, met zijn id, en daarna:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## De balk verbergen

`Super + Shift + Space` schakelt de balk uit en weer in zonder de shell te doden — panelen en sneltoetsen blijven werken, je krijgt alleen de pixels terug. Het staat ook in het menu onder **Uiterlijk → Menubalk → Balk verbergen**.

## Het configbestand

Alles wordt opgeslagen in `~/.config/omarchy/shell.json`, onder de `bar`-sleutel. Hier is een ingekorte versie:

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

Elke widget is één item in één van de vijf layout-arrays, en zijn instellingen staan inline op dat item — er is geen apart instellingenbestand en geen `config`-subobject. De `format`, `formatAlt` (waar rechts klikken naartoe doorloopt) en `verticalFormat` van de klok wonen allemaal precies daar op `{ "id": "omarchy.clock" }`.

`center` is de doos in het midden van de balk: alles erin wordt als één groep gecentreerd op het scherm. `centerBegin` en `centerEnd` hangen aan weerszijden van de doos, en zo blijft de klok precies in het midden, zelfs als het weer en de updatebadge komen en gaan. Zet meer dan één widget in `center` en ze worden samen gecentreerd; laat het leeg en `centerBegin` en `centerEnd` komen samen in het midden van de balk.

Eén regel die het waard is om te internaliseren: **zodra je je eigen `shell.json` hebt, is die canoniek**. Tot je iets aanpast, leest de shell het standaardbestand van Omarchy. Op het moment dat je een widget sleept, `omarchy bar` uitvoert of het bestand zelf bewerkt, is hij van jou — er is geen diepe samenvoeging, dus nieuwe standaardwidgets in toekomstige Omarchy-releases verschijnen niet automatisch op je balk. `omarchy bar defaults` zet de meegeleverde layout terug wanneer je een schone lei wilt.

Hetzelfde bestand bevat ook je idle-timings op het hoogste niveau, buiten de `bar`-sleutel: `idle.screensaver` en `idle.lock`, beide in seconden sinds je idle bent gegaan. Dus de standaard screensaver treedt in werking bij 150 seconden en de vergrendeling bij 300.
