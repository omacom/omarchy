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

Linjen vil automatisk vise det nåværende tastaturoppsettet ditt når du har konfigurert flere oppsett (og du kan klikke på den for å bytte også).

### Hvordan endrer jeg klokkeformatet til 12-timers?

Høyreklikk på klokken i linjen for å bla gjennom de vanlige formatene, inkludert 12-timersformatene. Du kan også angi formatet direkte:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Dette vil vise søndag 10:55 AM.

### Hvordan endrer jeg tidssonen min?

Kjør _Oppsett > Region > Tidssone_ i Omarchy-menyen og velg fra listen. Hvis tidssonen er riktig, men selve klokken har driftet, starter _Oppdater > Tid_ tidssynkroniseringen på nytt for deg.

### Hvordan endrer jeg DNS-en min, deler Wi-Fi-en min eller sjekker tilkoblingshastigheten min?

Det finner du alt sammen i [nettverk](35-networking.md).

### Hvordan sjekker jeg hvor rask disken min er?

_Utløser > Hastighetstest > Diskhastighetstest_ måler sanntids lese- og skrivehastighet på disken din, eller `omarchy disk speedtest` fra terminalen.

### Hvordan legger jeg til en skriver?

Utskrift er satt opp og kjører rett ut av boksen, og du legger til hver skriver selv fra _Print Settings_ i appstarteren (`Super + Alt + Space`).

Velg _Legg til_, og gi den et øyeblikk til å lete: en skriver som er koblet til over USB, og de fleste nettverksskrivere, blir funnet for deg. Hvis din ikke er på listen, velger du _Nettverksskriver > Internet Printing Protocol (ipp)_ og skriver inn adressen dens — skriverens eget display eller nettsiden dens vil fortelle deg hva det er, vanligvis noe sånt som `192.168.1.50` med en kø på `ipp/print`. _Videre_ tilbyr deretter en driver, der en moderne skriver fungerer best med den driverløse profilen _IPP Everywhere_ og en eldre en vil ha modellens egen driver.

Høyreklikk på en skriver og velg _Angi som standard_ for å velge hvilken en appene dine bruker først, og _Egenskaper_ for å angi papirstørrelse, tosidig utskrift og kvalitet.

Automatisk oppdagelse, der skrivere på nettverket vises uten å bli lagt til, er midlertidig slått av mens den omarbeides. Det er derfor det første trinnet over er ditt i stedet for automatisk. Utskrift til en PDF-fil fungerer helt uten noen skriver.

### Hvordan endrer jeg hvor skjermbilder eller skjermopptak lagres?

Lagrede skjermbilder går til `~/Pictures/Screenshots` som standard. For å bruke en annen mappe legger du til dette i en fil under `~/.config/uwsm/env.d/` (som `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Du kan gjøre det samme for skjermopptak ved å bruke `OMARCHY_SCREENRECORD_DIR`.

Omasnap oppretter skjermbildemappen sin automatisk. Opprett skjermopptaksmappen selv, og start deretter Omarchy på nytt for at den aktuelle miljøendringen skal tre i kraft.

### Hvordan får jeg høyttalerne + webkameraet til å fungere på Apple Studio Display-skjermen min?

Man skulle tro at alt bare skulle fungere ved å koble til USB C, men det er dessverre ikke tilfelle. Løsningen jeg har funnet for å få det til å fungere pålitelig, er å bruke [the WJESOG DisplayPort + USB-A => USB-C cable](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Da fungerer høyttalere og webkamera helt utmerket.

Husk at du har innebygd lysstyrkekontroll i Omarchy for Apple-skjermene (både Studio og XDR) med de vanlige lysstyrkeknappene på tastaturet.

### Hvordan kvitter jeg meg med all den ekstra programvaren?

Hvis du ikke vil ha programmer som Obsidian eller LibreOffice eller noe annet av det forhåndsinstallerte, kan du veldig enkelt fjerne det.

Kjør _Fjern > Pakke_ for å se alle pakkene som er installert. Deretter kan du velge hvilken som helst pakke du vil fjerne, med tab, og begynne å fjerne alt du har valgt, med return.

Og du kan bruke _Fjern > Webapp_ fra Omarchy-menyen til å fjerne noen av de forhåndsinstallerte webappene du ikke vil ha.

Eller kjør _Fjern > Forhåndsinstallerte_ for å feie ut alle de forhåndsinstallerte ekstratingene — webapper, TUI-er og valgfrie programmer — i ett jafs. Hurtigtastene som startet dem, forsvinner sammen med dem, så du sitter igjen med blanke ark av bindinger som du kan fylle med dine egne i `~/.config/hypr/bindings.lua`.

---

For feil og ødelagte ting, se [feilsøkingsdelen](45-troubleshooting.md).
