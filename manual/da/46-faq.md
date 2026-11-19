# FAQ

### Hvordan skifter jeg mellem tastaturlayout?

Rediger din `~/.config/hypr/input.lua`-fil og tilføj dette for at skifte mellem layout på `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Bjælken viser automatisk dit nuværende tastaturlayout, når du har konfigureret flere layout (og du kan også klikke på den for at skifte).

### Hvordan ændrer jeg urformatet til 12-timers?

Højreklik på uret i bjælken for at bladre gennem de almindelige formater, herunder 12-timersformaterne. Du kan også indstille formatet direkte:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Dette viser Søndag 10:55 AM.

### Hvordan ændrer jeg min tidszone?

Kør _Setup > Region > Timezone_ i Omarchy-menuen og vælg fra listen. Hvis tidszonen er rigtig, men selve uret er skredet, genstarter _Update > Time_ tidssynkroniseringen for dig.

### Hvordan ændrer jeg min DNS, deler mit Wi-Fi eller tjekker min forbindelseshastighed?

Det hele findes under [netværk](35-networking.md).

### Hvordan tjekker jeg, hvor hurtig min disk er?

_Trigger > Speed Test > Disk Speed Test_ måler læse- og skrivehastigheden på dit drev i realtid, eller `omarchy disk speedtest` fra terminalen.

### Hvordan tilføjer jeg en printer?

Print er sat op og kører fra start, og du tilføjer selv hver printer fra _Print Settings_ i app-starteren (`Super + Space`).

Vælg _Add_, og giv den et øjeblik til at lede: En printer tilsluttet via USB og de fleste netværksprintere bliver fundet for dig. Hvis din ikke er på listen, skal du vælge _Network Printer > Internet Printing Protocol (ipp)_ og indtaste dens adresse — printerens eget display eller dens webside fortæller dig, hvad det er, som regel noget i retning af `192.168.1.50` med en kø på `ipp/print`. _Forward_ tilbyder derefter en driver, hvor en moderne printer fungerer bedst med den driverløse _IPP Everywhere_-profil, og en ældre en vil have modellens egen driver.

Højreklik på en printer og vælg _Set as Default_ for at vælge, hvilken en dine apps skal bruge først, og _Properties_ for at indstille papirstørrelse, duplex og kvalitet.

Automatisk opdagelse, hvor printere på netværket vises uden at blive tilføjet, er midlertidigt slået fra, mens det bliver omarbejdet, og det er derfor, det første trin ovenfor er dit i stedet for automatisk. Print til en PDF-fil fungerer helt uden nogen printer.

### Hvordan ændrer jeg, hvor skærmbilleder eller skærmoptagelser gemmes?

Gemte skærmbilleder går som standard til `~/Pictures/Screenshots`. Hvis du vil bruge en anden mappe, skal du tilføje dette til en fil under `~/.config/uwsm/env.d/` (som `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Du kan gøre det samme for skærmoptagelser med `OMARCHY_SCREENRECORD_DIR`.

Omasnap opretter automatisk sin mappe til skærmbilleder. Opret selv mappen til skærmoptagelser, og genstart derefter Omarchy, for at begge miljøændringer kan træde i kraft.

### Hvordan får jeg højttalerne + webkameraet til at virke på min Apple Studio Display?

Man skulle tro, at det hele bare virkede ved at tilslutte USB C, men sådan er det desværre ikke. Den løsning, jeg har fundet frem til for at få det til at virke pålideligt, er at bruge [WJESOG DisplayPort + USB-A => USB-C-kablet](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Så fungerer højttalere og webkamera som en drøm.

Husk, at du har indbygget styring af lysstyrke i Omarchy til Apple-skærmene (både Studio og XDR) med de almindelige knapper til lysstyrke på tastaturet.

### Hvordan slipper jeg af med al den ekstra software?

Hvis du ikke vil have programmer som Obsidian eller LibreOffice eller noget af det andet forudinstallerede, kan du meget nemt fjerne det.

Kør _Remove > Package_ for at se alle pakker, der er installeret. Derefter kan du med tab vælge enhver pakke, du gerne vil fjerne, og med return begynde at fjerne alt det, du har valgt.

Og du kan bruge _Remove > Web App_ fra Omarchy-menuen til at fjerne alle de forudinstallerede webapps, du ikke vil have.

Eller kør _Remove > Preinstalls_ for at feje alle de forudinstallerede ekstrating — webapps, TUI'er og valgfrie programmer — ud i ét hug. De genvejstaster, der startede dem, forsvinder sammen med dem, så du står tilbage med en ren tavle af bindinger, du kan fylde med dine egne i `~/.config/hypr/bindings.lua`.

---

For fejl og ødelagte ting, se [afsnittet om fejlfinding](45-troubleshooting.md).
