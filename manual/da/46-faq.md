# FAQ

### Hvordan skifter jeg mellem tastaturlayouts?

Rediger filen `~/.config/hypr/input.lua`, og tilføj dette for at skifte mellem layouts med `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Bjælken viser automatisk dit nuværende tastaturlayout, når du har konfigureret flere layouts (og du kan også klikke på den for at skifte).

### Hvordan ændrer jeg urformatet til 12 timer?

Højreklik på uret i bjælken for at bladre gennem de almindelige formater, herunder 12-timers formaterne. Du kan også indstille formatet direkte:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Dette viser Søndag 10:55 AM.

### Hvordan ændrer jeg min tidszone?

Kør _Opdater > Tidszone_ i Omarchy-menuen, og vælg fra listen. Hvis tidszonen er rigtig, men selve uret er drevet ud af sync, genstarter _Opdater > Tid_ tidssynkroniseringen for dig.

### Hvordan ændrer jeg min DNS, deler mit Wi-Fi eller kontrollerer min forbindelseshastighed?

Det hele findes under [netværk](35-networking.md).

### Hvordan kontrollerer jeg, hvor hurtig min disk er?

_Udløser > Hastighedstest > Diskhastighedstest_ måler live læse- og skrivehastighed på dit drev, eller `omarchy disk speedtest` fra terminalen.

### Hvordan tilføjer jeg en printer?

Udskrivning er sat op og kører fra start, og du tilføjer selv hver printer fra _Udskriftsindstillinger_ i appstarteren (`Super + Space`).

Vælg _Tilføj_, og giv den et øjeblik til at søge: en printer tilsluttet via USB og de fleste netværksprintere bliver fundet for dig. Hvis din ikke er på listen, skal du vælge _Netværksprinter > Internet Printing Protocol (ipp)_ og indtaste dens adresse — printerens eget display eller dens webside fortæller dig, hvad det er, normalt noget i stil med `192.168.1.50` med en kø på `ipp/print`. _Videre_ tilbyder derefter en driver, hvor en moderne printer fungerer bedst på den driverløse _IPP Everywhere_-profil, og en ældre vil have modellens egen driver.

Højreklik på en printer, og vælg _Angiv som standard_ for at vælge, hvilken en dine apps går til først, og _Egenskaber_ for at indstille papirstørrelse, duplex og kvalitet.

Automatisk registrering, hvor printere på netværket vises uden at blive tilføjet, er midlertidigt slået fra, mens det omarbejdes, og det er derfor, det første trin ovenfor er dit i stedet for automatisk. Udskrivning til en PDF-fil fungerer helt uden nogen printer.

### Hvordan ændrer jeg, hvor skærmbilleder eller skærmoptagelser gemmes?

Gemte skærmbilleder går som standard til `~/Pictures/Screenshots`. Hvis du vil bruge en anden mappe, så tilføj dette til en fil under `~/.config/uwsm/env.d/` (f.eks. `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Du kan gøre det samme for skærmoptagelser med `OMARCHY_SCREENRECORD_DIR`.

Omasnap opretter automatisk sin skærmbilledmappe. Opret selv skærmoptagelsesmappen, og genstart derefter Omarchy, for at en af miljøændringerne kan træde i kraft.

### Hvordan får jeg højttalerne + webkameraet til at fungere på min Apple Studio Display?

Man skulle tro, at det hele bare virkede ved at tilslutte USB C, men sådan er det desværre ikke. Den løsning, jeg har fundet til at få det til at fungere pålideligt, er at bruge [WJESOG DisplayPort + USB-A => USB-C-kablet](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Så fungerer højttalere og webkamera som en drøm.

Husk, at du har indbygget lysstyrkestyring i Omarchy til Apple-skærme (både Studio og XDR) med de almindelige lysstyrkeknapper på tastaturet.

### Hvordan slipper jeg af med al den ekstra software?

Hvis du ikke vil have programmer som Obsidian eller LibreOffice eller noget af det andet forudinstallerede stads, kan du meget nemt fjerne det.

Kør _Fjern > Pakke_ for at se hver pakke, der er installeret. Derefter kan du vælge enhver pakke, du gerne vil fjerne, med tab, og begynde at fjerne alt, hvad du har valgt, med return.

Og du kan bruge _Fjern > Webapp_ fra Omarchy-menuen til at fjerne enhver af de forudinstallerede webapps, du ikke vil have.

Eller kør _Fjern > Forudinstallerede_ for at feje alle de forudinstallerede ekstrating ud — webapps, TUI'er og valgfrie programmer — på én gang. De genvejstaster, der startede dem, forsvinder med dem, så du står tilbage med en ren tavle af bindinger, som du kan fylde med dine egne i `~/.config/hypr/bindings.lua`.

---

For fejl og ting, der er gået i stykker, se [afsnittet Fejlfinding](45-troubleshooting.md).
