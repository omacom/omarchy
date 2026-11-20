# FAQ

### Hvordan bytter jeg mellom tastaturoppsett?

Rediger filen `~/.config/hypr/input.lua` og legg til dette for å bytte mellom oppsett med `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Baren viser automatisk det gjeldende tastaturoppsettet ditt når du har konfigurert flere oppsett (og du kan klikke på det for å bytte også).

### Hvordan endrer jeg klokkeformatet til 12 timer?

Høyreklikk på klokken i baren for å bla gjennom de vanlige formatene, inkludert 12-timersformatene. Du kan også angi formatet direkte:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Dette viser søndag 10:55 AM.

### Hvordan endrer jeg tidssonen min?

Kjør _Setup > Region > Timezone_ i Omarchy-menyen og velg fra listen. Hvis tidssonen er riktig, men selve klokken har driftet, starter _Update > Time_ tidssynkroniseringen på nytt for deg.

### Hvordan endrer jeg DNS, deler Wi-Fi eller sjekker tilkoblingshastigheten min?

Alt det bor i [nettverk](35-networking.md).

### Hvordan sjekker jeg hvor rask disken min er?

_Trigger > Speed Test > Disk Speed Test_ måler lese- og skrivehastighet i sanntid på disken din, eller `omarchy disk speedtest` fra terminalen.

### Hvordan legger jeg til en skriver?

Utskrift er satt opp og kjører rett ut av boksen, og du legger til hver skriver selv fra _Print Settings_ i appstarteren (`Super + Space`).

Velg _Add_, og gi den et øyeblikk til å lete: en skriver som er koblet til via USB, og de fleste nettverksskrivere, blir funnet for deg. Hvis din ikke er i listen, velger du _Network Printer > Internet Printing Protocol (ipp)_ og skriver inn adressen dens — skriverens egen skjerm eller nettsiden dens forteller deg hva det er, vanligvis noe sånt som `192.168.1.50` med en kø på `ipp/print`. _Forward_ tilbyr deretter en driver, der en moderne skriver fungerer best med den driverløse _IPP Everywhere_-profilen og en eldre en vil ha modellens egen driver.

Høyreklikk på en skriver og velg _Set as Default_ for å velge hvilken en appene dine skal bruke først, og _Properties_ for å angi papirstørrelse, tosidig utskrift og kvalitet.

Automatisk oppdagelse, der skrivere på nettverket dukker opp uten å bli lagt til, er midlertidig slått av mens det omarbeides, og det er derfor det første trinnet over er ditt i stedet for automatisk. Å skrive ut til en PDF-fil fungerer helt uten noen skriver.

### Hvordan endrer jeg hvor skjermbilder eller skjermopptak lagres?

Lagrede skjermbilder går til `~/Pictures/Screenshots` som standard. For å bruke en annen mappe legger du til dette i en fil under `~/.config/uwsm/env.d/` (som `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Du kan gjøre det samme for skjermopptak ved å bruke `OMARCHY_SCREENRECORD_DIR`.

Omasnap oppretter skjermbildemappen sin automatisk. Opprett skjermopptaksmappen selv, og start deretter Omarchy på nytt for at en av miljøendringene skal tre i kraft.

### Hvordan får jeg høyttalerne + webkameraet til å fungere på min Apple Studio Display?

Du skulle tro at alt bare skulle fungere ved å koble til USB C, men dessverre er det ikke sånn. Løsningen jeg har funnet for å få det til å fungere pålitelig, er å bruke [WJESOG DisplayPort + USB-A => USB-C-kabelen](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Da fungerer høyttalere og webkamera som en drøm.

Husk at du har innebygd kontroll over lysstyrke i Omarchy for Apple-skjermene (både Studio og XDR) med de vanlige tastaturknappene for lysstyrke.

### Hvordan kvitter jeg meg med all den ekstra programvaren?

Hvis du ikke vil ha programmer som Obsidian eller LibreOffice eller noe av det andre forhåndsinstallerte, kan du veldig enkelt fjerne det.

Kjør _Remove > Package_ for å se hver pakke som er installert. Deretter kan du velge en hvilken som helst pakke du vil fjerne med tab, og begynne å fjerne alt du har valgt med return.

Og du kan bruke _Remove > Web App_ fra Omarchy-menyen for å fjerne noen av de forhåndsinstallerte webappene du ikke vil ha.

Eller kjør _Remove > Preinstalls_ for å feie ut alle de forhåndsinstallerte ekstratingene — webapper, TUI-er og valgfrie programmer — i ett sveip. Hurtigtastene som startet dem, forsvinner sammen med dem, så du sitter igjen med blanke ark av bindinger som du kan fylle med dine egne i `~/.config/hypr/bindings.lua`.

---

For feil og ødelagte ting, se [feilsøkingsdelen](45-troubleshooting.md).
