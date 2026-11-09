# Ofte stilte spørsmål

### Hvordan bytter jeg mellom tastaturlayouter?

Rediger `~/.config/hypr/input.lua`-filen din og legg til dette for å bytte mellom layouter på `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Linjen vil automatisk vise gjeldende tastaturlayout når du har flere layouter konfigurert (og du kan klikke på den for å bytte også).

### Hvordan endrer jeg klokkeformatet til 12-timers?

Høyreklikk på klokken i linjen for å bla gjennom de vanlige formatene, inkludert 12-timersformatene. Du kan også sette formatet direkte:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Dette vil vise Sunday 10:55 AM.

### Hvordan endrer jeg tidssonen min?

Kjør _Oppdater > Tidssone_ i Omarchy-menyen og velg fra listen. Hvis tidssonen er riktig, men selve klokken har drevet, starter _Oppdater > Tid_ tidssynkroniseringen på nytt for deg.

### Hvordan endrer jeg DNS-en min, deler Wi-Fi-en min eller sjekker tilkoblingshastigheten min?

Alt det bor i [nettverk](35-networking.md).

### Hvordan sjekker jeg hvor rask disken min er?

_Utløs > Hastighetstest > Diskhastighetstest_ måler sanntids lese- og skrivehastighet på disken din, eller `omarchy disk speedtest` fra terminalen.

### Hvorfor kan jeg ikke logge på Google-kontoen min i Chromium?

Den vanlige åpen kildekode-Chromium-bygget leveres ikke med OAuth-legitimasjonen som Google krever for kontopålogging. Kjør _Installer > Tjeneste > Chromium-konto_ i Omarchy-menyen for å legge dem til, start nettleseren på nytt, og påloggingen går gjennom.

### Hvordan legger jeg til en skriver?

Utskrift er satt opp og kjører rett ut av boksen, og du legger til hver skriver selv fra _Print Settings_ i appstarteren (`Super + Space`).

Velg _Add_, og gi den et øyeblikk til å lete: en skriver plugget inn over USB, og de fleste nettverksskrivere, blir funnet for deg. Hvis din ikke er på listen, velg _Network Printer > Internet Printing Protocol (ipp)_ og skriv inn adressen — skriverens eget display eller nettsiden dens vil fortelle deg hva det er, vanligvis noe sånt som `192.168.1.50` med en kø på `ipp/print`. _Forward_ tilbyr deretter en driver, der en moderne skriver fungerer best på den driverløse _IPP Everywhere_-profilen og en eldre vil ha modellens egen driver.

Høyreklikk på en skriver og velg _Set as Default_ for å velge hvilken appene dine går til først, og _Properties_ for å sette papirstørrelse, tosidig utskrift og kvalitet.

Automatisk oppdagelse, der skrivere på nettverket dukker opp uten å bli lagt til, er midlertidig slått av mens det omarbeides, og det er derfor det første trinnet over er ditt i stedet for automatisk. Å skrive ut til en PDF-fil fungerer uten noen skriver i det hele tatt.

### Hvordan endrer jeg hvor skjermbilder eller skjermopptak lagres?

Lagrede skjermbilder går til `~/Pictures/Screenshots` som standard. For å bruke en annen mappe, legg til dette i en fil under `~/.config/uwsm/env.d/` (som `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Du kan gjøre det samme for skjermopptak med `OMARCHY_SCREENRECORD_DIR`.

Omasnap oppretter skjermbildemappen sin automatisk. Opprett skjermopptaksmappen selv, og start deretter Omarchy på nytt for at en av miljøendringene skal tre i kraft.

### Hvordan får jeg høyttalerne + webkameraet til å fungere på Apple Studio Display-en min?

Man skulle tro at alt bare skulle fungere ved å plugge inn USB C, men dessverre er det ikke tilfellet. Løsningen jeg har funnet for å få det til å fungere pålitelig, er å bruke [WJESOG DisplayPort + USB-A => USB-C-kabelen](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Da fungerer høyttalere og webkamera som en drøm.

Husk at du har innebygd lysstyrkekontroll i Omarchy for Apple-skjermene (både Studio og XDR) med de vanlige tastaturlysstyrkeknappene.

### Hvordan blir jeg kvitt all den ekstra programvaren?

Hvis du ikke vil ha programmer som Obsidian eller LibreOffice eller noe av det andre forhåndsinstallerte, kan du veldig enkelt fjerne det.

Kjør _Fjern > Pakke_ for å se hver pakke som er installert. Deretter kan du velge enhver pakke du vil fjerne med tab, og begynne å fjerne alt du har valgt med return.

Og du kan bruke _Fjern > Nettapp_ fra Omarchy-menyen for å fjerne enhver av de forhåndsinstallerte nettappene du ikke vil ha.

Eller kjør _Fjern > Forhåndsinstallerte_ for å feie ut alle de forhåndsinstallerte ekstratingene — nettapper, TUI-er og valgfrie applikasjoner — i ett jafs. Hurtigtastene som startet dem, forsvinner med dem, så du sitter igjen med en ren tavle med bindinger å fylle med dine egne i `~/.config/hypr/bindings.lua`.

---

For feil og ødelagte biter, se [Feilsøking-delen](45-troubleshooting.md).
