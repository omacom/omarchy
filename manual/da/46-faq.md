# FAQ

### Hvordan skifter jeg mellem tastaturlayouts?

Rediger din `~/.config/hypr/input.lua`-fil og tilføj dette for at skifte mellem layouts på `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Linjen vil automatisk vise dit aktuelle tastaturlayout, når du har flere layouts konfigureret (og du kan også klikke på det for at skifte).

### Hvordan ændrer jeg urformatet til 12-timers?

Højreklik på uret i linjen for at bladre gennem de almindelige formater, inklusive 12-timers-formaterne. Du kan også sætte formatet direkte:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Det vil vise Søndag 10:55 AM.

### Hvordan ændrer jeg min tidszone?

Kør _Opdater > Tidszone_ i Omarchy-menuen og vælg fra listen. Hvis tidszonen er rigtig, men uret selv er drevet, genstarter _Opdater > Tid_ tidssynkroniseringen for dig.

### Hvordan ændrer jeg min DNS, deler mit Wi-Fi eller tjekker min forbindelseshastighed?

De bor alle i [networking](35-networking.md).

### Hvordan tjekker jeg, hvor hurtig min disk er?

_Udløs > Hastighedstest > Diskhastighedstest_ måler live læse- og skrivehastighed på dit drev, eller `omarchy disk speedtest` fra terminalen.

### Hvorfor kan jeg ikke logge ind på min Google-konto i Chromium?

Den almindelige open source Chromium-build leveres ikke med de OAuth-legitimationsoplysninger, Google kræver til konto-login. Kør _Installer > Tjeneste > Chromium-konto_ i Omarchy-menuen for at tilføje dem, genstart browseren, og loginnet vil gå igennem.

### Hvordan tilføjer jeg en printer?

Print er sat op og kører ud af boksen, og du tilføjer hver printer selv fra _Printindstillinger_ i app-launcheren (`Super + Space`).

Vælg _Tilføj_, og giv det et øjeblik til at lede: en printer tilsluttet over USB og de fleste netværksprintere findes for dig. Hvis din ikke er på listen, så vælg _Netværksprinter > Internet Printing Protocol (ipp)_ og indtast dens adresse — printerens eget display eller dens webside vil fortælle dig, hvad det er, som regel noget som `192.168.1.50` med en kø på `ipp/print`. _Fremad_ tilbyder derefter en driver, hvor en moderne printer virker bedst på den driverløse _IPP Everywhere_-profil, og en ældre vil have modellens egen driver.

Højreklik på en printer og vælg _Sæt som standard_ for at vælge, hvilken en dine apps rækker ud efter først, og _Egenskaber_ for at sætte papirstørrelse, duplex og kvalitet.

Automatisk opdagelse, hvor printere på netværket vises uden at blive tilføjet, er midlertidigt slukket, mens den omarbejdes, hvilket er grunden til, at det første trin ovenfor er dit frem for automatisk. Print til en PDF-fil virker helt uden nogen printer.

### Hvordan ændrer jeg, hvor skærmbilleder eller skærmoptagelser gemmes?

Gemte skærmbilleder går til `~/Pictures/Screenshots` som standard. For at bruge en anden mappe skal du tilføje dette til en fil under `~/.config/uwsm/env.d/` (som `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Du kan gøre det samme for skærmoptagelser ved hjælp af `OMARCHY_SCREENRECORD_DIR`.

Omasnap opretter sin skærmbilledmappe automatisk. Opret skærmoptagelsesmappen selv, og genstart derefter Omarchy, for at en af miljøændringerne kan træde i kraft.

### Hvordan får jeg højttalerne + webcam til at virke på mit Apple Studio Display?

Du skulle tro, at det hele bare skulle virke ved at sætte USB C i, men desværre er det ikke tilfældet. Den løsning, jeg har fundet til at få det til at virke pålideligt, er at bruge [WJESOG DisplayPort + USB-A => USB-C-kablet](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Så virker højttalere og webcam som en drøm.

Husk, at du har indbygget lysstyrkekontrol i Omarchy til Apple Displays (både Studio og XDR) ved hjælp af de almindelige tastatur-lystyrkeknapper.

### Hvordan slipper jeg af med al den ekstra software?

Hvis du ikke vil have programmer som Obsidian eller LibreOffice eller noget af det andet forudinstallerede, kan du meget nemt fjerne det.

Kør _Fjern > Pakke_ for at se enhver pakke, der er installeret. Derefter kan du vælge enhver pakke, du gerne vil fjerne, med tab og begynde at fjerne alt, hvad du har valgt, med return.

Og du kan bruge _Fjern > Webapp_ fra Omarchy-menuen til at fjerne enhver af de forudinstallerede webapps, du ikke vil have.

Eller kør _Fjern > Forudinstallerede_ for at feje alle de forudinstallerede ekstra ting ud — webapps, TUI'er og valgfrie apps — i ét hug. Genvejstasterne, der startede dem, forsvinder med dem, så du står tilbage med en ren tavle af bindinger at fylde med dine egne i `~/.config/hypr/bindings.lua`.

---

For fejl og ødelagte dele, se [Fejlfinding-sektionen](45-troubleshooting.md).
