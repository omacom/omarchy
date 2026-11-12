# De bovenbalk

De strip bovenaan je scherm is de Omarchy-balk. Het is geen erop geschroefde statusbalk, maar onderdeel van de Omarchy-shell, dat ene langlopende Quickshell-proces dat ook het menu, de meldingen, de OSD-popups en het vergrendelscherm tekent. Daarom sluit het qua thema perfect aan op al het andere en opent een paneel meteen, in plaats van een nieuwe app te starten.

Het is ook het enige onderdeel van de desktop dat altijd in beeld is, dus het is de moeite waard om te weten wat al die kleine glyphs doen.

## Wat er standaard op staat

De balk heeft drie delen. Links zit het Omarchy-logo (de menustarter) en de werkruimte-indicatoren. In het midden krijg je de statusindicatoren, de klok, Elsewhen (een wereldklok), het weer en een Omarchy-updatebadge. Rechts: het systeemvak, de toetsenbordindeling (wanneer er meer dan één is geconfigureerd), agents, bluetooth, netwerk, audio, scherm en stroom.

Een paar daarvan verschijnen alleen als ze iets te melden hebben. De toetsenbordindeling verschijnt alleen als je meer dan één indeling hebt geconfigureerd. De updatebadge verschijnt alleen wanneer er een Omarchy-update klaarstaat. En het agents-pictogram verschijnt de eerste keer dat Omarchy AI-codeergebruik op de machine vindt (zie [AI](17-ai.md)).

## Rondklikken

Bijna elke widget doet iets bij klikken met links, rechts en de middelste knop, en verschillende reageren op scrollen. Dit is het deel dat mensen missen — achter de rechter- en middelste knop zit veel van het goede spul verborgen.

| Widget | Links | Rechts | Midden / scrollen |
| --- | --- | --- | --- |
| Menu | Omarchy-menu | Nieuwe terminal | — |
| Werkruimten | Focus die werkruimte op deze monitor | — | Scrollen: volgende/vorige werkruimte |
| Klok | Kalenderpopup | Door de labelformaten bladeren | Midden: tijdzonekiezer |
| Weer | Popup met weersverwachting | Volledig weer als melding | Midden: vernieuwen |
| Audio | Audiopaneel | Dempen | Midden: paneel · scrollen: volume |
| Microfoon | Dempt de microfoon | — | Midden: audiopaneel · scrollen: invoervolume |
| Netwerk | Netwerkpaneel | — | — |
| Bluetooth | Bluetooth-paneel | Schakel de radio in/uit | — |
| Scherm | Schermpaneel | — | Scrollen: helderheid |
| Stroom | Stroompaneel | Schakel het batterijpercentage in/uit | — |
| Media | Afspelen/pauzeren | Popup met coverafbeelding | Midden: volgende · scrollen: vorige/volgende |
| Agents | Agents-paneel | Start je agent | Midden: volgend abonnement |
| Systeemvak | Beweeg eroverheen om de lade te onthullen | Rechtsklik op de chevron om te beheren | — |
| Omarchy-update | Voer de update uit | — | — |

Niet alles in die tabel staat standaard op je balk. De mediawidget (MPRIS now-playing, met een scrollende track en artiest) en de microfoonwidget zijn allebei ingebouwd, maar staan standaard uit — voeg ze toe als je ze wilt, zoals hieronder beschreven.

## De panelen

Klikken op een balkpictogram opent een paneel, een echte popup met schuifregelaars, lijsten en toetsenbordnavigatie in plaats van een tooltip. Elk paneel heeft ook een sneltoets, zodat je nooit op een glyph van 16 pixels hoeft te mikken:

| Hotkey | Panel |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + N` | Network |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Display |
| `Super + Ctrl + P` | Power |
| `Super + Ctrl + Alt + D` | Calendar |
| `Super + Ctrl + Alt + E` | World clock |
| `Super + Ctrl + 1-9` | Toggle the nth panel in the right section |

De panelen zijn geen afleesschermen. Daar doe je het werk echt:

- **Audio** heeft een hoofdvolumeschuifregelaar, een kiezer voor het uitvoerapparaat en een mixer per app, zodat je dat ene browsertabblad zachter kunt zetten zonder al het andere aan te raken.
- **Network** scant naar Wi-Fi, toont de signaalsterkte, maakt verbinding en laat je een DNS-provider kiezen.
- **Bluetooth** zet je apparaten op een rij met verbinden/verbreken en batterijniveaus.
- **Power** toont batterijstatistieken, wisselt van stroomprofiel (het onthoudt een aparte keuze voor batterij en AC) en toont wat systeeminformatie.
- **Display** heeft een helderheidsschuifregelaar, tekstgrootte, presets voor monitorschaling en — wanneer je meer dan één scherm hebt — bediening per monitor. Zie [monitoren](33-monitors.md) voor het diepere verhaal.
- **Clock** opent een maandrooster met ISO-weeknummers en stappen per maand.
- **World clock** houdt een rij per stad bij, met het weer daar en hoe de dag daar verloopt. Zoeken vindt plaatsen net als tijdzones, dus Fort Lauderdale is Fort Lauderdale en niet New York. Als de regel bovenaan de verkeerde stad noemt, klik erop en geef aan waar je bent; kies ergens in een andere tijdzone en de systeemklok verhuist daar ook naartoe, wat handig is als je reist. Beweeg over een stad en klik op de persoonsknop om te zeggen wie daar woont — gewone namen, of `@` GitHub-handles om hun gezichten mee te nemen.

Elk paneel werkt met het toetsenbord net als met de muis: pijltjes bewegen, Return activeert, Tab gaat naar het naburige paneel en Escape sluit.

`Super + Ctrl + 1-9` telt de panelen van links naar rechts in het rechterdeel, waarbij het systeemvak wordt overgeslagen omdat dat geen eigen paneel heeft. Dus het nummer komt overeen met het pictogram waar je naar zou wijzen.

### Tailscale and Dropbox

Twee extra widgets verschijnen pas op de balk zodra je de bijbehorende service installeert via **Install → Service**, en beide zijn de moeite waard om te kennen omdat ze meer doen dan alleen status melden.

Het **Tailscale**-paneel verbindt en verbreekt het tailnet, wisselt tussen accounts en kiest een exit node (je eigen machines en Mullvad-regio's verschijnen allebei in die lijst). Het bladert ook door je machines — en als er een is geselecteerd, stuurt `s` er bestanden naartoe via Taildrop, wat de snelste manier is om een bestand naar je telefoon of een andere laptop te verplaatsen. `c` kopieert het IP van de machine, `n` de naam en `d` de volledige DNS-naam. Er staat ook een verzendknop op elke machinerij, als je liever klikt. Hetzelfde vanuit de terminal is `omarchy tailscale send <machine> [file...]`.

Het **Dropbox**-paneel regelt het inloggen, toont hoeveel opslag je hebt gebruikt en zet recent gesynchroniseerde bestanden op een rij.

Als je een van beide services verwijdert, verdwijnt de widget weer van de balk.

## Indicatoren

Het kleine cluster in het midden is de indicatorenwidget. Dit zijn statusglyphs voor modi die je hebt aangezet: niet storen, nachtlicht, een [herinnering](09-reminders.md) in de wachtrij, een actieve schermopname, wakker blijven en [dicteren](11-text-extraction-dictation.md). Ze lichten op wanneer de modus actief is en blijven anders uit de weg — beweeg er net naast, waar de inactieve zouden zitten, om die te bekijken. Klikken op een indicator schakelt die modus in of uit. Eén extra is alleen status: een externe sessie licht rood op terwijl iemand via gliff met deze machine is verbonden.

Als je liever hebt dat ze altijd zichtbaar zijn, zet `alwaysShow` op `true` bij de widget. En als je alleen sommige belangrijk vindt, zet degene die je wilt in `items`: `["Dnd", "Reminder", "NightLight"]`. Je kunt meer dan één indicatorenwidget hebben, zodat verschillende delen verschillende subsets kunnen tonen.

## De balk opnieuw indelen

De balk configureert zichzelf. Je hoeft geen configuratiebestand te openen om dingen te verplaatsen.

Pak een leeg stuk van de balk rond het midden en sleep het naar een andere schermrand, en de balk verhuist daarheen — links, rechts, boven of onder werkt allemaal, en elke widget past zich aan (verticale balken vallen terug op compacte vormen met alleen pictogrammen). Klikken en vasthouden start dezelfde sleepbeweging. Dubbelklik met links op diezelfde lege ruimte om de achtergrond van de balk te laten wisselen van doorzichtig naar glasachtig naar ondoorzichtig. En sleep een willekeurige widget om hem opnieuw te ordenen of in een ander deel te gooien; de andere widgets schuiven uiteen om ruimte te maken waar hij terechtkomt.

Het midden van de balk is een vak: wat erin zit blijft als één groep gecentreerd, en de widgets aan weerszijden ervan hangen aan de randen ervan. Terwijl je een widget sleept, verschijnt het vak als een omtrek, of als een lijn over de balk wanneer het leeg is, en je kunt erin of ernaast neerzetten. Wanneer een neerzetactie in het vak zou landen, groeit het vak om de widget op te nemen.

Een widget die je bij de hand wilt hebben maar niet altijd in beeld, kan in de lade van het systeemvak: sleep hem op het systeemvak en de lade opent om hem op te nemen. Hij zit daar achter de app-pictogrammen, verschijnt wanneer de lade dat doet en houdt zijn lade open terwijl zijn paneel openstaat. Sleep hem terug naar de balk om hem terug te zetten.

Als je liever uit een menu kiest, staat de positie onder **Appearance → Menu Bar** en kies je met **Bar Background** hoe de balk wordt getekend: **Opaque Bar**, **Glassy Bar** (doorzichtig, met wat erachter zit vervaagd) of **Clear Bar**.

Dezelfde dingen hebben commando's, wat je wilt voor een [dotfiles](31-dotfiles.md)-setup:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Om een widget helemaal toe te voegen of te verwijderen, gebruik je de plugincommando's. `omarchy plugin list` print elke widget die de shell kent met zijn id, en daarna:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## De balk verbergen

`Super + Shift + Space` schakelt de balk uit en weer in zonder de shell te stoppen — panelen en sneltoetsen blijven werken, je krijgt alleen de pixels terug. Het staat ook in het menu onder **Appearance → Menu Bar → Hide Bar**.

## Het configuratiebestand

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

Elke widget is één item in een van de vijf layout-arrays en zijn instellingen staan inline bij dat item — er is geen apart instellingenbestand en geen `config`-subobject. `format`, `formatAlt` (waar rechtsklikken naartoe wisselt) en `verticalFormat` van de klok staan allemaal precies daar bij `{ "id": "omarchy.clock" }`.

`center` is het vak in het midden van de balk: alles erin wordt als één groep in het midden van het scherm gecentreerd. `centerBegin` en `centerEnd` hangen aan weerszijden van het vak, waardoor de klok precies in het midden blijft, ook als het weer en de updatebadge komen en gaan. Zet meer dan één widget in `center` en ze worden samen gecentreerd; laat het leeg en `centerBegin` en `centerEnd` komen samen in het midden van de balk.

Eén regel die de moeite waard is om te internaliseren: **zodra je je eigen `shell.json` hebt, is die canoniek**. Totdat je iets aanpast, leest de shell het standaardbestand van Omarchy. Zodra je een widget sleept, `omarchy bar` uitvoert of het bestand zelf bewerkt, is het van jou — er is geen deep merge, dus nieuwe standaardwidgets in toekomstige Omarchy-releases verschijnen niet automatisch op je balk. `omarchy bar defaults` zet de meegeleverde indeling terug wanneer je met een schone lei wilt beginnen.

Hetzelfde bestand bevat ook je idle-tijden op het hoogste niveau, buiten de `bar`-sleutel: `idle.screensaver` en `idle.lock`, beide in seconden sinds je inactief werd. Dus de standaard screensaver treedt in werking na 150 seconden en de vergrendeling na 300.
