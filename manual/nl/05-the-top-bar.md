# De bovenbalk

De strook langs de bovenkant van je scherm is de Omarchy-balk. Het is geen achteraf vastgeschroefde statusbalk, maar een onderdeel van de Omarchy-shell, het ene langlopende Quickshell-proces dat ook het menu, de meldingen, de OSD-popups en het vergrendelscherm tekent. Daarom past het qua thema perfect bij al het andere en opent een paneel direct, in plaats van een nieuwe app te starten.

Het is ook het enige onderdeel van het bureaublad dat altijd in beeld is, dus het is de moeite waard om te weten wat al die kleine tekens doen.

## Wat er standaard op staat

De balk heeft drie secties. Links staat het Omarchy-logo (de menustarter) en de werkruimte-indicatoren. In het midden staan de statusindicatoren, de klok, Elsewhen (een wereldklok), het weer en een Omarchy-updatebadge. Rechts: het systeemvak, de toetsenbordindeling (wanneer er meer dan één is geconfigureerd), agents, bluetooth, netwerk, audio, beeldscherm en energie.

Een paar daarvan verschijnen alleen wanneer ze iets te melden hebben. De toetsenbordindeling verschijnt alleen als je meer dan één indeling hebt geconfigureerd. De updatebadge verschijnt alleen wanneer er een Omarchy-update klaarstaat. En het agents-pictogram verschijnt zodra Omarchy voor het eerst AI-codeergebruik op de machine aantreft (zie [AI](17-ai.md)).

## Rondklikken

Bijna elke widget doet iets bij links, rechts en in het midden klikken, en verschillende reageren op scrollen. Dit is het deel dat mensen missen — achter de rechter- en middelste knop zit veel van het goede spul verstopt.

| Widget | Links | Rechts | Midden / scrollen |
| --- | --- | --- | --- |
| Menu | Omarchy-menu | Nieuwe terminal | — |
| Werkruimten | Focus die werkruimte op deze monitor | — | Scrollen: volgende/vorige werkruimte |
| Klok | Kalenderpopup | Doorloop de labelindelingen | Midden: tijdzonekiezer |
| Weer | Weersverwachtingspopup | Volledig weer als melding | Midden: vernieuwen |
| Audio | Audiopaneel | Dempen | Midden: paneel · scrollen: volume |
| Microfoon | Demp de microfoon | — | Midden: audiopaneel · scrollen: invoervolume |
| Netwerk | Netwerkpaneel | — | — |
| Bluetooth | Bluetooth-paneel | Schakel de radio in/uit | — |
| Beeldscherm | Beeldschermpaneel | — | Scrollen: helderheid |
| Energie | Energiepaneel | Schakel het batterijpercentage in/uit | — |
| Media | Afspelen/pauzeren | Popup met coverafbeelding | Midden: volgende · scrollen: vorige/volgende |
| Agents | Agents-paneel | Start je agent | Midden: volgende abonnement |
| Systeemvak | Beweeg erover om de lade te tonen | Rechts op de chevron om te beheren | — |
| Omarchy-update | Voer de update uit | — | — |

Niet alles in die tabel staat standaard op je balk. De mediawidget (MPRIS speelt-nu, met een scrollende track en artiest) en de microfoonwidget zijn allebei ingebouwd maar standaard uitgeschakeld — voeg ze toe als je ze wilt, zoals hieronder beschreven.

## De panelen

Als je op een balkpictogram klikt, opent er een paneel: een echte popup met schuifregelaars, lijsten en toetsenbordnavigatie in plaats van een tooltip. Elk paneel heeft ook een sneltoets, zodat je nooit op een glyph van 16 pixels hoeft te mikken:

| Sneltoets | Paneel |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + N` | Netwerk |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Beeldscherm |
| `Super + Ctrl + P` | Energie |
| `Super + Ctrl + Alt + D` | Kalender |
| `Super + Ctrl + Alt + E` | Wereldklok |
| `Super + Ctrl + 1-9` | Schakel het n-de paneel in de rechter sectie in/uit |

De panelen zijn geen uitleesschermen. Je doet er daadwerkelijk het werk:

- **Audio** heeft een hoofdvolumeschuifregelaar, een kiezer voor het uitvoerapparaat en een mixer per app, zodat je die ene browsertab zachter kunt zetten zonder al het andere aan te raken.
- **Netwerk** scant naar Wi-Fi, toont de signaalsterkte, maakt verbinding en laat je een DNS-provider kiezen.
- **Bluetooth** geeft je apparaten weer met verbinden/verbreken en batterijniveaus.
- **Energie** toont batterijstatistieken, schakelt tussen energieprofielen (het onthoudt een aparte keuze voor batterij en AC) en drukt wat systeeminformatie af.
- **Beeldscherm** bevat een helderheidsschuifregelaar, tekstgrootte, voorinstellingen voor monitorschaling en — wanneer je meer dan één scherm hebt — bedieningselementen per monitor. Zie [monitors](33-monitors.md) voor het diepere verhaal.
- **Klok** opent een maandrooster met ISO-weeknummers en stappen per maand.
- **Wereldklok** houdt een rij per stad bij, met het weer daar en hoe de dag daar verloopt. Zoeken vindt ook plaatsen en niet alleen tijdzones, dus Fort Lauderdale is Fort Lauderdale en niet New York. Als de regel bovenaan de verkeerde stad noemt, klik je erop en zeg je waar je bent; kies je ergens in een andere tijdzone, dan gaat de systeemklok daar ook naartoe, wat handig is wanneer je reist. Beweeg over een stad en klik op de persoonsknop om te zeggen wie daar woont — gewone namen, of `@` GitHub-handles om hun gezichten mee te nemen.

Elk paneel werkt net zo goed met het toetsenbord als met de muis: pijltjes verplaatsen, Return activeert, Tab stapt naar het naastgelegen paneel en Escape sluit.

`Super + Ctrl + 1-9` telt de panelen van links naar rechts in de rechter sectie, waarbij het systeemvak wordt overgeslagen omdat dat geen eigen paneel heeft. Het nummer komt dus overeen met het pictogram waar je naar zou wijzen.

### Tailscale en Dropbox

Er verschijnen nog twee widgets op de balk zodra je de bijbehorende service installeert via **Install → Service**, en beide zijn het kennen waard omdat ze meer doen dan alleen de status melden.

Het **Tailscale**-paneel verbindt en verbreekt het tailnet, wisselt tussen accounts en kiest een exit node (je eigen machines en Mullvad-regio's staan allebei in die lijst). Het bladert ook door je machines — en met er een geselecteerd stuurt `s` er bestanden naartoe via Taildrop, wat de snelste manier is om een bestand naar je telefoon of een andere laptop te verplaatsen. `c` kopieert het IP-adres van de machine, `n` de naam en `d` de volledige DNS-naam. Er staat ook een verzendknop op elke machinerij, als je liever klikt. Hetzelfde vanuit de terminal is `omarchy tailscale send <machine> [file...]`.

Het **Dropbox**-paneel regelt het inloggen, toont hoeveel opslag je hebt gebruikt en geeft recent gesynchroniseerde bestanden weer.

Als je een van beide services verwijdert, verdwijnt de bijbehorende widget weer van de balk.

## Indicatoren

Het kleine cluster in het midden is de indicatorenwidget. Dit zijn statusglyphs voor modi die je hebt ingeschakeld: niet storen, nachtlicht, een in de wachtrij staande [herinnering](09-reminders.md), een actieve schermopname, wakker blijven en [dictatie](11-text-extraction-dictation.md). Ze lichten op wanneer de modus actief is en blijven anders uit de weg — beweeg ergens over de balk om even naar de inactieve te gluren. Als je op een indicator klikt, schakel je die modus in of uit. Er is er nog één die alleen status is: een externe sessie licht rood op terwijl iemand via gliff met deze machine is verbonden.

Als je ze liever altijd zichtbaar hebt, stel je `alwaysShow` in op `true` op de widget. En als je alleen om sommige geeft, zet je de gewenste in `items`: `["Dnd", "Reminder", "NightLight"]`. Je kunt meer dan één indicatorenwidget hebben, zodat verschillende secties verschillende subsets kunnen tonen.

## De balk opnieuw indelen

De balk configureert zichzelf. Je hoeft geen configuratiebestand te openen om dingen te verplaatsen.

Pak een leeg stukje van de balk rond het midden en sleep het naar een andere schermrand, en de balk verplaatst daarheen — links, rechts, boven of onder werkt allemaal, en elke widget past zich aan (verticale balken vallen terug op compacte vormen met alleen pictogrammen). Met klikken-en-vasthouden start je dezelfde sleepactie. Dubbelklik met links op diezelfde lege ruimte om de balkachtergrond te doorlopen van transparant naar glasachtig naar ondoorzichtig. En sleep een willekeurige widget om hem opnieuw te ordenen of naar een andere sectie te gooien; de andere widgets schuiven uiteen om ruimte te maken waar hij terechtkomt.

Het midden van de balk is een box: wat erin zit, blijft als één groep gecentreerd, en de widgets aan weerszijden ervan hangen aan de randen. Terwijl je een widget sleept, verschijnt de box als een omlijning, of als een lijn over de balk wanneer hij leeg is, en je kunt erin of ernaast neerzetten. Wanneer een neerzetactie in de box zou uitkomen, groeit de box om de widget op te nemen.

Een widget die je wel bij de hand wilt hebben maar niet altijd in beeld, kan in de lade van het systeemvak: sleep hem op het systeemvak, en de lade opent om hem op te nemen. Hij staat daar achter de app-pictogrammen, verschijnt telkens wanneer de lade dat doet, en houdt zijn lade open terwijl zijn paneel openstaat. Sleep hem terug naar de balk om hem terug te zetten.

Als je liever uit een menu kiest, heeft **Appearance → Menu Bar** de positie, en **Bar Background** kiest hoe de balk wordt getekend: **Opaque Bar**, **Glassy Bar** (doorzichtig, met wat erachter zit vervaagd) of **Clear Bar**.

Dezelfde dingen hebben commando's, en dat is wat je wilt voor een [dotfiles](31-dotfiles.md)-setup:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Om een widget helemaal toe te voegen of te verwijderen, gebruik je de plugincommando's. `omarchy plugin list` drukt elke widget af die de shell kent, met zijn id, en daarna:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## De balk verbergen

`Super + Shift + Space` schakelt de balk uit en weer in zonder de shell te stoppen — panelen en sneltoetsen blijven werken, je krijgt alleen de pixels terug. Het staat ook in het menu onder **Appearance → Menu Bar → Hide Bar**.

## Het configuratiebestand

Dit alles wordt opgeslagen in `~/.config/omarchy/shell.json`, onder de sleutel `bar`. Hier is een ingekorte versie:

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

Elke widget is één item in een van de vijf layout-arrays, en zijn instellingen staan inline op dat item — er is geen apart instellingenbestand en geen `config`-subobject. De `format`, `formatAlt` (waar rechtsklikken naartoe doorloopt) en `verticalFormat` van de klok staan allemaal precies daar op `{ "id": "omarchy.clock" }`.

`center` is de box in het midden van de balk: alles daarin wordt als één groep op het scherm gecentreerd. `centerBegin` en `centerEnd` hangen aan weerszijden van de box, en zo blijft de klok precies in het midden, ook terwijl het weer en de updatebadge komen en gaan. Zet meer dan één widget in `center` en ze worden samen gecentreerd; laat hem leeg en `centerBegin` en `centerEnd` komen in het midden van de balk bij elkaar.

Eén regel die het waard is om je eigen te maken: **zodra je je eigen `shell.json` hebt, is die leidend**. Totdat je iets aanpast, leest de shell het standaardbestand van Omarchy. Zodra je een widget sleept, `omarchy bar` uitvoert of het bestand zelf bewerkt, is hij van jou — er is geen diepe samenvoeging, dus nieuwe standaardwidgets in toekomstige Omarchy-releases verschijnen niet automatisch op je balk. `omarchy bar defaults` zet de meegeleverde layout terug wanneer je met een schone lei wilt beginnen.

Dezelfde file bevat ook je idle-timings op het hoogste niveau, buiten de sleutel `bar`: `idle.screensaver` en `idle.lock`, allebei in seconden sinds je idle bent. De standaard screensaver treedt dus in werking na 150 seconden en de vergrendeling na 300.
