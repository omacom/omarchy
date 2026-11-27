# FAQ

### Hoe schakel ik tussen toetsenbordindelingen?

Bewerk je bestand `~/.config/hypr/input.lua` en voeg dit toe om met `Left Alt + Right Alt` tussen indelingen te schakelen:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

De balk toont automatisch je huidige toetsenbordindeling zodra je meerdere indelingen hebt geconfigureerd (en je kunt er ook op klikken om te schakelen).

### Hoe verander ik de klokindeling naar 12-uurs?

Klik met rechts op de klok in de balk om door de gangbare indelingen te bladeren, waaronder de 12-uursindelingen. Je kunt de indeling ook direct instellen:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Dit geeft zondag 10:55 AM weer.

### Hoe verander ik mijn tijdzone?

Voer _Instellen > Regio > Tijdzone_ uit in het Omarchy-menu en kies uit de lijst. Als de tijdzone klopt maar de klok zelf is verlopen, herstart _Bijwerken > Tijd_ de tijdsynchronisatie voor je.

### Hoe verander ik mijn DNS, deel ik mijn Wi-Fi of controleer ik mijn verbindingssnelheid?

Die vind je allemaal in [netwerken](35-networking.md).

### Hoe controleer ik hoe snel mijn schijf is?

_Trigger > Snelheidstest > Schijfsnelheidstest_ meet live de lees- en schrijfsnelheid van je schijf, of `omarchy disk speedtest` vanuit de terminal.

### Hoe voeg ik een printer toe?

Printen is kant-en-klaar ingesteld en actief, en je voegt elke printer zelf toe vanuit _Printinstellingen_ in de app-starter (`Super + Alt + Space`).

Kies _Toevoegen_ en geef het een moment om te zoeken: een printer die via USB is aangesloten, en de meeste netwerkprinters, worden voor je gevonden. Als die van jou niet in de lijst staat, kies dan _Netwerkprinter > Internet Printing Protocol (ipp)_ en voer het adres in — het display van de printer zelf of de webpagina ervan vertelt je wat dat is, meestal iets als `192.168.1.50` met een wachtrij van `ipp/print`. _Volgende_ biedt vervolgens een stuurprogramma aan, waarbij een moderne printer het beste werkt op het stuurprogrammaloze profiel _IPP Everywhere_ en een oudere het eigen stuurprogramma van het model wil.

Klik met rechts op een printer en kies _Instellen als standaard_ om te kiezen welke je apps als eerste gebruiken, en _Eigenschappen_ om papierformaat, dubbelzijdig printen en kwaliteit in te stellen.

Automatische detectie, waarbij printers op het netwerk verschijnen zonder dat ze zijn toegevoegd, is tijdelijk uitgeschakeld terwijl er opnieuw aan wordt gewerkt, en daarom is de eerste stap hierboven aan jou en niet automatisch. Printen naar een PDF-bestand werkt helemaal zonder printer.

### Hoe verander ik waar screenshots of schermopnamen worden opgeslagen?

Opgeslagen screenshots gaan standaard naar `~/Pictures/Screenshots`. Om een andere map te gebruiken, voeg je dit toe aan een bestand onder `~/.config/uwsm/env.d/` (zoals `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Hetzelfde kun je doen voor schermopnamen met `OMARCHY_SCREENRECORD_DIR`.

Omasnap maakt zijn screenshotmap automatisch. Maak de map voor schermopnamen zelf en herstart daarna Omarchy om een van beide omgevingswijzigingen van kracht te laten worden.

### Hoe krijg ik de luidsprekers + webcam aan de praat op mijn Apple Studio Display?

Je zou denken dat alles gewoon zou moeten werken door USB C aan te sluiten, maar helaas is dat niet het geval. De oplossing die ik heb gevonden om het betrouwbaar te laten werken, is [de WJESOG DisplayPort + USB-A => USB-C-kabel](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/) gebruiken. Dan werken luidsprekers en webcam als een zonnetje.

Vergeet niet dat je in Omarchy ingebouwde helderheidsregeling hebt voor de Apple Displays (zowel Studio als XDR) met de gewone helderheidstoetsen op het toetsenbord.

### Hoe raak ik alle extra software kwijt?

Als je programma's zoals Obsidian of LibreOffice of een van de andere vooraf geïnstalleerde dingen niet wilt, kun je ze heel eenvoudig verwijderen.

Voer _Verwijderen > Pakket_ uit om elk geïnstalleerd pakket te zien. Daarna kun je met tab elk pakket selecteren dat je wilt verwijderen, en met return beginnen met het verwijderen van alles wat je hebt geselecteerd.

En je kunt _Verwijderen > Webapp_ in het Omarchy-menu gebruiken om alle vooraf geïnstalleerde webapps te verwijderen die je niet wilt.

Of voer _Verwijderen > Voorinstallaties_ uit om alle vooraf geïnstalleerde extra's — webapps, TUI's en optionele applicaties — in één keer op te ruimen. De sneltoetsen waarmee ze werden gestart, verdwijnen met ze, dus je houdt een schone lei aan toewijzingen over om te vullen met je eigen toewijzingen in `~/.config/hypr/bindings.lua`.

---

Voor fouten en kapotte onderdelen, zie [het gedeelte Problemen oplossen](45-troubleshooting.md).
