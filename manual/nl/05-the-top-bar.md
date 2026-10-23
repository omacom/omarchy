# De bovenbalk

De strip langs de bovenkant van je scherm is de Omarchy-balk. Het is geen vastgeschroefde statusbalk maar onderdeel van de Omarchy-shell, het enige langlopende Quickshell-proces dat ook het menu, de meldingen, de OSD-popups en het vergrendelscherm tekent. Daarom thèmet hij perfect met al het andere en daarom opent een paneel direct in plaats van een nieuwe app te spawnen.

Het is ook het enige stukje van het bureaublad dat altijd op het scherm staat, dus het is de moeite waard om te weten wat al die kleine glyphs doen.

## Wat er standaard op staat

De balk heeft drie secties. Links zit het Omarchy-logo (de menustarter) en de werkbladindicatoren. In het midden krijg je de statusindicatoren, de klok, Elsewhen (een wereldklok), het weer en een Omarchy-updatebadge. Rechts: de toetsenbordindeling (wanneer er meer dan één is geconfigureerd), het systeemvak, agents, bluetooth, netwerk, audio, display en stroom.

Een paar daarvan verschijnen alleen wanneer ze iets te zeggen hebben. De toetsenbordindeling verschijnt alleen als je meer dan één indeling hebt geconfigureerd. De updatebadge verschijnt alleen wanneer er een Omarchy-update wacht. En het agents-pictogram verschijnt de eerste keer dat Omarchy AI-coderingsgebruik op de machine vindt (zie [AI](17-ai.md)).

## Rondklikken

Bijna elke widget doet iets bij links, rechts en midden klikken, en verschillende reageren op scrollen. Dit is het deel dat mensen missen — de rechter- en middenknoppen zijn waar veel van het goede spul zich verstopt.

| Widget | Links | Rechts | Midden / scrollen |
| --- | --- | --- | --- |
| Menu | Omarchy-menu | Nieuwe terminal | — |
| Werkbladen | Focus dat werkblad | — | Scrollen: volgend/vorig werkblad |
| Klok | Kalender-popup | Doorloop het labelformaat | Midden: tijdzonekiezer |
| Weer | Voorspellings-popup | Volledig weer als een melding | Midden: vernieuwen |
| Audio | Audiopaneel | Dempen | Midden: paneel · scrollen: volume |
| Microfoon | Dempt de microfoon | — | Midden: audiopaneel · scrollen: invoervolume |
| Netwerk | Netwerkpaneel | — | — |
| Bluetooth | Bluetooth-paneel | Schakel de radio | — |
| Display | Displaypaneel | — | Scrollen: helderheid |
| Stroom | Stroompaneel | Schakel het batterijpercentage | — |
| Media | Afspelen/pauze | Cover-art-popup | Midden: volgende · scrollen: vorige/volgende |
| Agents | Agents-paneel | Start je agent | Midden: volgend abonnement |
| Systeemvak | Zweef om de lade te onthullen | Rechts op de chevron om te beheren | — |
| Omarchy-update | Voer de update uit | — | — |

Niet alles in die tabel staat standaard op je balk. De media-widget (MPRIS now-playing, met een scrollende track en artiest) en de microfoon-widget zijn beide ingebouwd maar standaard uit — voeg ze toe als je ze wilt, zoals hieronder beschreven.

## De panelen

Op een balkpictogram klikken opent een paneel, wat een echte popup is met schuifregelaars, lijsten en toetsenbordnavigatie in plaats van een tooltip. Elk heeft ook een sneltoets, dus je hoeft nooit op een glyph van 16 pixels te mikken:

| Sneltoets | Paneel |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + W` | Netwerk |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Display |
| `Super + Ctrl + P` | Stroom |
| `Super + Ctrl + Alt + D` | Kalender |
| `Super + Ctrl + Alt + E` | Wereldklok |
| `Super + Ctrl + 1-9` | Schakel het n-de paneel in de rechter sectie |

De panelen zijn geen uitlezingen. Het is waar je het ding daadwerkelijk doet:

- **Audio** heeft een hoofdvolumeschuif, een uitvoerapparaatkiezer en een mixer per app, zodat je dat ene browsertabblad zachter kunt zetten zonder al het andere aan te raken.
- **Netwerk** scant naar Wi-Fi, toont signaalsterkte, verbindt en laat je een DNS-provider kiezen.
- **Bluetooth** geeft een lijst van je apparaten met verbinden/verbreken en batterijniveaus.
- **Stroom** toont batterijstatistieken, schakelt stroomprofielen (het onthoudt een aparte keuze voor batterij en netstroom) en print wat systeeminformatie.
- **Display** bevat een helderheidsschuif, tekstgrootte, monitorschalings-presets en — wanneer je meer dan één scherm hebt — besturing per monitor. Zie [monitoren](33-monitors.md) voor het diepere verhaal.
- **Klok** opent een maandraster met ISO-weeknummers en maandstappen.

Elk paneel neemt zowel het toetsenbord als de muis: pijlen bewegen, Return activeert, Tab stapt naar het naburige paneel en Escape sluit.

`Super + Ctrl + 1-9` telt panelen van links naar rechts in de rechter sectie, waarbij het systeemvak wordt overgeslagen omdat het geen eigen paneel heeft. Dus het nummer komt overeen met het pictogram waarnaar je zou wijzen.

### Tailscale en Dropbox

Nog twee widgets verschijnen op de balk pas als je de bijpassende service installeert via **Installeren → Service**, en beide zijn het waard om te kennen omdat ze meer doen dan status rapporteren.

Het **Tailscale**-paneel verbindt en verbreekt het tailnet, schakelt tussen accounts en kiest een exit node (je eigen machines en Mullvad-regio's verschijnen beide in die lijst). Het bladert ook door je machines — en met er een geselecteerd, stuurt `s` er bestanden naartoe via Taildrop, wat de snelste manier is om een bestand naar je telefoon of een andere laptop te verplaatsen. `c` kopieert het IP van de machine, `n` zijn naam en `d` zijn volledige DNS-naam. Er is ook een verzendknop op elke machinerij, als je liever klikt. Hetzelfde vanaf de terminal is `omarchy tailscale send <machine> [file...]`.

Het **Dropbox**-paneel behandelt inloggen, toont hoeveel opslag je hebt gebruikt en geeft een lijst van recent gesynchroniseerde bestanden.

Een van beide services verwijderen haalt zijn widget weer van de balk af.

## Indicatoren

Het kleine cluster in het midden is de indicatoren-widget. Dit zijn statusglyphs voor modi die je hebt ingeschakeld: niet storen, nachtlicht, een in de rij staande [herinnering](09-reminders.md), een actieve schermopname, wakker blijven en [dicteren](11-text-extraction-dictation.md). Ze lichten op wanneer de modus actief is en blijven anders uit de weg — zweef links van de klok (erboven op een verticale balk) om naar de inactieve te gluren. Op een indicator klikken schakelt die modus. Nog een is alleen status: een externe sessie licht rood op terwijl iemand via gliff met deze machine is verbonden.

Als je liever hebt dat ze altijd zichtbaar zijn, stel je `alwaysShow` in op `true` op de widget. En als je alleen om sommige geeft, lijst je degene die je wilt in `items`: `["Dnd", "Reminder", "NightLight"]`. Je kunt meer dan één indicatoren-widget hebben, zodat verschillende secties verschillende subsets kunnen tonen.

## De balk herschikken

De balk configureert zichzelf. Je hoeft geen configbestand te openen om dingen te verplaatsen.

Pak een leeg stukje van de balk rond het midden en sleep het naar een andere schermrand, en de balk verplaatst daarheen — links, rechts, boven of onder werken allemaal, en elke widget past zich aan (verticale balken vallen terug op compacte alleen-pictogram vormen). Klikken en vasthouden start dezelfde sleepactie. Dubbel-linksklik op diezelfde lege ruimte om de balkachtergrond te doorlopen van doorzichtig naar glazen naar ondoorzichtig. En sleep elke widget om hem te herschikken of in een andere sectie te gooien.

Een widget die je wel bij de hand wilt hebben maar niet altijd in beeld, kan in de lade van het systeemvak: sleep hem naar het systeemvak, en de lade opent om hem te ontvangen. Daar zit hij achter de app-pictogrammen, verschijnt hij telkens als de lade dat doet, en houdt hij de lade open zolang zijn paneel openstaat. Sleep hem terug naar buiten op de balk om hem terug te zetten.

Als je liever uit een menu kiest, heeft **Activeren → Weergave → Menubalk** de positie, en **Balkachtergrond** kiest hoe de balk wordt getekend: **Ondoorzichtige balk**, **Glazen balk** (doorschijnend, met wat erachter zit vervaagd), of **Doorzichtige balk**.

Dezelfde dingen hebben commando's, wat is wat je wilt voor een [dotfiles](31-dotfiles.md)-setup:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.clock --section center --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Om een widget helemaal toe te voegen of te verwijderen, gebruik je de plugin-commando's. `omarchy plugin list` print elke widget die de shell kent met zijn id, en dan:

```bash
omarchy plugin enable omarchy.media --section center
omarchy plugin disable omarchy.weather
```

## De balk verbergen

`Super + Shift + Space` schakelt de balk uit en weer aan zonder de shell te doden — panelen en sneltoetsen blijven werken, je krijgt alleen de pixels terug. Het staat ook in het menu onder **Activeren → Weergave → Menubalk → Balk verbergen**.

## Het configbestand

Dit alles wordt opgeslagen in `~/.config/omarchy/shell.json`, onder de `bar`-sleutel. Hier is een ingekorte versie:

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

Elke widget is één item in een van de drie layout-arrays, en zijn instellingen zitten inline op dat item — er is geen apart instellingenbestand en geen `config`-sub-object. De `format`, `formatAlt` (waar rechtsklikken naartoe doorloopt) en `verticalFormat` van de klok leven allemaal precies daar op `{ "id": "omarchy.clock" }`.

`centerAnchor` benoemt de ene center-widget die wordt vastgepind op het exacte midden van het scherm, met de anderen ernaast. Zo blijft de klok pal in het midden, zelfs als het weer en de updatebadge komen en gaan. Stel hem in op een lege string en de centerlijst wordt gewoon als groep gecentreerd.

Eén regel die het waard is om te internaliseren: **zodra je je eigen `shell.json` hebt, is hij canoniek**. Totdat je iets aanpast, leest de shell Omarchy's standaardbestand. Op het moment dat je een widget sleept, `omarchy bar` uitvoert, of het bestand zelf bewerkt, is hij van jou — er is geen deep merge, dus nieuwe standaardwidgets in toekomstige Omarchy-releases verschijnen niet automatisch op je balk. `omarchy bar defaults` zet de geleverde indeling terug wanneer je een schone lei wilt.

Hetzelfde bestand bevat ook je idle-timings op het hoogste niveau, buiten de `bar`-sleutel: `idle.screensaver` en `idle.lock`, beide in seconden sinds je idle ging. Dus de standaard schermbeveiliging treedt in werking bij 150 seconden en de vergrendeling bij 300.
