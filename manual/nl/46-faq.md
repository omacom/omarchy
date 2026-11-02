# Veelgestelde vragen

### Hoe wissel ik tussen toetsenbordindelingen?

Bewerk je bestand `~/.config/hypr/input.lua` en voeg dit toe om tussen indelingen te wisselen met `Left Alt + Right Alt`:

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

### Hoe wijzig ik het klokformaat naar 12-uurs?

Klik met de rechtermuisknop op de klok in de balk om door de gangbare formaten te bladeren, inclusief de 12-uursformaten. Je kunt het formaat ook direct instellen:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Dit toont Sunday 10:55 AM.

### Hoe wijzig ik mijn tijdzone?

Voer _Bijwerken > Timezone_ uit in het Omarchy-menu en kies uit de lijst. Als de tijdzone klopt maar de klok zelf is afgedreven, herstart _Bijwerken > Time_ de tijdsynchronisatie voor je.

### Hoe wijzig ik mijn DNS, deel ik mijn wifi of controleer ik mijn verbindingssnelheid?

Die staan allemaal in [netwerken](35-networking.md).

### Hoe controleer ik hoe snel mijn schijf is?

_Activeren > Speed Test > Disk Speed Test_ meet live lees- en schrijfsnelheid op je schijf, of `omarchy disk speedtest` vanuit de terminal.

### Waarom kan ik me in Chromium niet aanmelden bij mijn Google-account?

De gewone opensource Chromium-build wordt niet geleverd met de OAuth-inloggegevens die Google vereist voor accountaanmelding. Voer _Installeren > Service > Chromium Account_ uit in het Omarchy-menu om ze toe te voegen, herstart de browser, en de aanmelding gaat door.

### Hoe voeg ik een printer toe?

Printen is ingesteld en werkt meteen uit de doos, en je voegt elke printer zelf toe vanuit _Print Settings_ in de app-launcher (`Super + Space`).

Kies _Add_ en geef het even de tijd om te zoeken: een printer die via USB is aangesloten, en de meeste netwerkprinters, worden voor je gevonden. Als de jouwe niet in de lijst staat, kies dan _Network Printer > Internet Printing Protocol (ipp)_ en voer het adres in — het scherm van de printer zelf of de webpagina vertelt je wat dat is, meestal iets als `192.168.1.50` met een wachtrij van `ipp/print`. _Forward_ biedt vervolgens een stuurprogramma aan, waarbij een moderne printer het beste werkt met het stuurprogrammaloze _IPP Everywhere_-profiel en een oudere het eigen stuurprogramma van het model wil.

Klik met de rechtermuisknop op een printer en kies _Set as Default_ om te kiezen welke je apps als eerste pakken, en _Properties_ om papierformaat, duplex en kwaliteit in te stellen.

Automatische ontdekking, waarbij printers op het netwerk verschijnen zonder te worden toegevoegd, is tijdelijk uitgeschakeld terwijl eraan wordt gewerkt, en daarom is de eerste stap hierboven aan jou in plaats van automatisch. Printen naar een PDF-bestand werkt zonder enige printer.

### Hoe wijzig ik waar schermafbeeldingen of schermopnames worden opgeslagen?

Opgeslagen schermafbeeldingen gaan standaard naar `~/Pictures/Screenshots`. Om een andere map te gebruiken, voeg je dit toe aan een bestand onder `~/.config/uwsm/env.d/` (zoals `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Je kunt hetzelfde doen voor schermopnames met `OMARCHY_SCREENRECORD_DIR`.

Omasnap maakt zijn schermafbeeldingenmap automatisch aan. Maak de schermopnamemap zelf aan en herstart vervolgens Omarchy om een van beide omgevingswijzigingen van kracht te laten worden.

### Hoe krijg ik de luidsprekers + webcam werkend op mijn Apple Studio Display?

Je zou denken dat het allemaal zou moeten werken door gewoon USB-C in te pluggen, maar dat is helaas niet het geval. De oplossing die ik heb gevonden om het betrouwbaar te laten werken is [de WJESOG DisplayPort + USB-A => USB-C-kabel](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Dan werken luidsprekers en webcam als een tierelier.

Onthoud dat je in Omarchy ingebouwde helderheidsregeling hebt voor de Apple Displays (zowel Studio als XDR) met de gewone helderheidsknoppen op het toetsenbord.

### Hoe kom ik af van alle extra software?

Als je programma's zoals Obsidian of LibreOffice of een van de andere vooraf geïnstalleerde dingen niet wilt, kun je ze heel eenvoudig verwijderen.

Voer _Verwijderen > Package_ uit om elk geïnstalleerd pakket te zien. Vervolgens kun je met tab elk pakket selecteren dat je wilt verwijderen, en met return beginnen alles te verwijderen wat je hebt geselecteerd.

En je kunt _Verwijderen > Web App_ uit het Omarchy-menu gebruiken om alle vooraf geïnstalleerde webapps te verwijderen die je niet wilt.

Of voer _Verwijderen > Preinstalls_ uit om alle vooraf geïnstalleerde extra's — webapps, TUI's en optionele applicaties — in één keer weg te vegen. De sneltoetsen die ze startten verdwijnen met ze mee, zodat je achterblijft met een schone lei aan toewijzingen om te vullen met je eigen in `~/.config/hypr/bindings.lua`.

---

Zie voor fouten en kapotte stukken [het gedeelte Probleemoplossing](45-troubleshooting.md).
