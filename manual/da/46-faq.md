# FAQ

### Hvordan skifter jeg mellem tastaturlayout?

Rediger din `~/.config/hypr/input.lua`-fil og tilføj dette for at skifte mellem layouts med `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Baren viser automatisk dit aktuelle tastaturlayout, når du har konfigureret flere layouts (og du kan også klikke på den for at skifte).

### Hvordan ændrer jeg urformatet til 12-timers?

Højreklik på uret i baren for at bladre gennem de almindelige formater, herunder 12-timers formaterne. Du kan også indstille formatet direkte:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Dette vil vise Søndag 10:55 AM.

### Hvordan ændrer jeg min tidszone?

Kør _Setup > Region > Timezone_ i Omarchy-menuen og vælg fra listen. Hvis tidszonen er rigtig, men selve uret er drevet, genstarter _Update > Time_ tidssynkroniseringen for dig.

### Hvordan ændrer jeg min DNS, deler min Wi-Fi eller tjekker min forbindelseshastighed?

Det hele bor i [netværk](35-networking.md).

### Hvordan tjekker jeg, hvor hurtig min disk er?

_Trigger > Speed Test > Disk Speed Test_ måler live læse- og skrivehastighed på dit drev, eller `omarchy disk speedtest` fra terminalen.

### Hvordan tilføjer jeg en printer?

Udskrivning er sat op og kører lige ud af boksen, og du tilføjer selv hver printer fra _Print Settings_ i app-starteren (`Super + Alt + Space`).

Vælg _Add_, og giv den et øjeblik til at søge: en printer tilsluttet over USB, og de fleste netværksprintere, bliver fundet for dig. Hvis din ikke er på listen, skal du vælge _Network Printer > Internet Printing Protocol (ipp)_ og indtaste dens adresse — printerens eget display eller dens webside fortæller dig, hvad det er, normalt noget i stil med `192.168.1.50` med en kø på `ipp/print`. _Forward_ tilbyder derefter en driver, hvor en moderne printer fungerer bedst på den driverløse _IPP Everywhere_-profil, og en ældre vil have modellens egen driver.

Højreklik på en printer og vælg _Set as Default_ for at vælge, hvilken en dine apps går til først, og _Properties_ for at indstille papirstørrelse, duplex og kvalitet.

Automatisk registrering, hvor printere på netværket vises uden at blive tilføjet, er midlertidigt slået fra, mens det bliver omarbejdet, og det er derfor, det første trin ovenfor er dit i stedet for automatisk. Udskrivning til en PDF-fil fungerer helt uden en printer.

### Hvordan ændrer jeg, hvor screenshots eller skærmoptagelser gemmes?

Gemte screenshots går som standard til `~/Pictures/Screenshots`. For at bruge en anden mappe skal du tilføje dette til en fil under `~/.config/uwsm/env.d/` (som `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Du kan gøre det samme for skærmoptagelser ved at bruge `OMARCHY_SCREENRECORD_DIR`.

Omasnap opretter automatisk sin screenshot-mappe. Opret selv mappen til skærmoptagelser, og genstart derefter Omarchy, for at begge miljøændringer kan træde i kraft.

### Hvordan får jeg højttalerne + webkameraet til at fungere på min Apple Studio Display?

Man skulle tro, at det hele bare ville fungere ved at tilslutte USB C, men det er desværre ikke tilfældet. Den løsning, jeg har fundet til at få det til at fungere pålideligt, er at bruge [WJESOG DisplayPort + USB-A => USB-C-kablet](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Så fungerer højttalere og webkamera som en drøm.

Husk, at du har indbygget lysstyrkestyring i Omarchy til Apple-skærmene (både Studio og XDR) ved hjælp af de almindelige tastaturknapper til lysstyrke.

### Hvordan slipper jeg af med al det ekstra software?

Hvis du ikke vil have programmer som Obsidian eller LibreOffice eller noget af det andet forudinstallerede, kan du meget nemt fjerne det.

Kør _Remove > Package_ for at se hver pakke, der er installeret. Derefter kan du vælge enhver pakke, du vil fjerne, med tab og begynde at fjerne alt det, du har valgt, med return.

Og du kan bruge _Remove > Web App_ fra Omarchy-menuen til at fjerne alle de forudinstallerede webapps, du ikke vil have.

Eller kør _Remove > Preinstalls_ for at feje alle de forudinstallerede ekstrating ud — webapps, TUI'er og valgfrie applikationer — på én gang. Genvejstasterne, der startede dem, forsvinder sammen med dem, så du står tilbage med en ren tavle af bindinger, som du kan fylde med dine egne i `~/.config/hypr/bindings.lua`.

---

For fejl og ødelagte ting, se [afsnittet Fejlfinding](45-troubleshooting.md).
