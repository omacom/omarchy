# Veelgestelde vragen

### Hoe wissel ik tussen toetsenbordindelingen?

Bewerk je bestand `~/.config/hypr/input.lua` en voeg dit toe om met `Left Alt + Right Alt` tussen indelingen te wisselen:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

De balk toont automatisch je huidige toetsenbordindeling zodra je meerdere indelingen hebt geconfigureerd (en je kunt er ook op klikken om te wisselen).

### Hoe wijzig ik de kloknotatie naar 12-uurs?

Klik met de rechtermuisknop op de klok in de balk om door de gangbare notaties te bladeren, waaronder de 12-uursnotaties. Je kunt de notatie ook direct instellen:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Dit geeft zondag 10:55 AM weer.

### Hoe wijzig ik mijn tijdzone?

Voer _Setup > Region > Timezone_ uit in het Omarchy-menu en kies uit de lijst. Als de tijdzone klopt maar de klok zelf is verlopen, herstart _Update > Time_ de tijdsynchronisatie voor je.

### Hoe wijzig ik mijn DNS, deel ik mijn Wi-Fi of controleer ik mijn verbindingssnelheid?

Die vind je allemaal bij [netwerken](35-networking.md).

### Hoe controleer ik hoe snel mijn schijf is?

_Trigger > Speed Test > Disk Speed Test_ meet live de lees- en schrijfsnelheid van je schijf, of `omarchy disk speedtest` vanuit de terminal.

### Hoe voeg ik een printer toe?

Printen is kant-en-klaar ingesteld en werkt direct, en je voegt elke printer zelf toe vanuit _Print Settings_ in de app-launcher (`Super + Space`).

Kies _Add_ en geef het even de tijd om te zoeken: een printer die via USB is aangesloten, en de meeste netwerkprinters, worden voor je gevonden. Staat die van jou niet in de lijst, kies dan _Network Printer > Internet Printing Protocol (ipp)_ en voer het adres in — het scherm van de printer zelf of de webpagina ervan vertelt je wat dat is, meestal iets als `192.168.1.50` met een wachtrij `ipp/print`. _Forward_ biedt vervolgens een driver aan, waarbij een moderne printer het beste werkt met het driverloze _IPP Everywhere_-profiel en een oudere printer de eigen driver van het model wil.

Klik met de rechtermuisknop op een printer en kies _Set as Default_ om te bepalen welke printer je apps als eerste gebruiken, en _Properties_ om papierformaat, duplex en kwaliteit in te stellen.

Automatische detectie, waarbij printers op het netwerk verschijnen zonder dat je ze toevoegt, is tijdelijk uitgeschakeld terwijl eraan wordt gewerkt, en daarom is de eerste stap hierboven handwerk in plaats van automatisch. Afdrukken naar een PDF-bestand werkt helemaal zonder printer.

### Hoe wijzig ik waar screenshots of schermopnames worden opgeslagen?

Opgeslagen screenshots gaan standaard naar `~/Pictures/Screenshots`. Om een andere map te gebruiken, voeg je dit toe aan een bestand onder `~/.config/uwsm/env.d/` (zoals `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Je kunt hetzelfde doen voor schermopnames met `OMARCHY_SCREENRECORD_DIR`.

Omasnap maakt de map voor screenshots automatisch aan. Maak de map voor schermopnames zelf aan en herstart daarna Omarchy om een van beide omgevingswijzigingen actief te maken.

### Hoe krijg ik de speakers + webcam aan de praat op mijn Apple Studio Display?

Je zou denken dat het allemaal gewoon werkt door USB C aan te sluiten, maar helaas is dat niet het geval. De oplossing die ik heb gevonden om het betrouwbaar te laten werken, is [de WJESOG DisplayPort + USB-A => USB-C cable](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/) gebruiken. Daarna werken speakers en webcam als een zonnetje.

Vergeet niet dat je in Omarchy ingebouwde helderheidsregeling hebt voor de Apple Displays (zowel Studio als XDR) met de gewone helderheidstoetsen op het toetsenbord.

### Hoe kom ik van al die extra software af?

Als je programma's als Obsidian of LibreOffice of een van de andere vooraf geïnstalleerde dingen niet wilt, kun je ze heel eenvoudig verwijderen.

Voer _Remove > Package_ uit om alle geïnstalleerde pakketten te zien. Vervolgens kun je met tab elk pakket selecteren dat je wilt verwijderen, en met return beginnen met het verwijderen van alles wat je hebt geselecteerd.

En je kunt _Remove > Web App_ in het Omarchy-menu gebruiken om alle vooraf geïnstalleerde webapps te verwijderen die je niet wilt.

Of voer _Remove > Preinstalls_ uit om alle vooraf geïnstalleerde extra's — webapps, TUI's en optionele applicaties — in één keer op te ruimen. De sneltoetsen waarmee je ze startte, verdwijnen mee, zodat je met een schone lei aan bindings overblijft die je met je eigen bindings kunt vullen in `~/.config/hypr/bindings.lua`.

---

Voor fouten en dingen die kapot zijn, zie [het hoofdstuk Probleemoplossing](45-troubleshooting.md).
