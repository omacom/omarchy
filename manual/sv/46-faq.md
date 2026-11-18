# FAQ

### Hur växlar jag mellan tangentbordslayouter?

Redigera din fil `~/.config/hypr/input.lua` och lägg till detta för att växla mellan layouter med `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Baren visar automatiskt din aktuella tangentbordslayout när du har flera layouter konfigurerade (och du kan klicka på den för att växla också).

### Hur ändrar jag klockformatet till 12-timmars?

Högerklicka på klockan i baren för att bläddra igenom de vanliga formaten, inklusive 12-timmarsformaten. Du kan också ställa in formatet direkt:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Detta visar Sunday 10:55 AM.

### Hur ändrar jag min tidszon?

Kör _Update > Timezone_ i Omarchy-menyn och välj från listan. Om tidszonen är rätt men själva klockan har drivit iväg startar _Update > Time_ om tidssynkroniseringen åt dig.

### Hur ändrar jag min DNS, delar mitt Wi-Fi eller kontrollerar min anslutningshastighet?

Allt det finns i [networking](35-networking.md).

### Hur kontrollerar jag hur snabb min disk är?

_Trigger > Speed Test > Disk Speed Test_ mäter aktuell läs- och skrivhastighet på din disk, eller `omarchy disk speedtest` från terminalen.

### Hur lägger jag till en skrivare?

Utskrift är konfigurerad och igång direkt från start, och du lägger till varje skrivare själv från _Print Settings_ i application launcher (`Super + Space`).

Välj _Add_, och ge det en stund att söka: en skrivare inkopplad via USB, och de flesta nätverksskrivare, hittas åt dig. Om din inte finns i listan, välj _Network Printer > Internet Printing Protocol (ipp)_ och ange dess adress — skrivarens egen display eller dess webbsida berättar vad det är, vanligtvis något i stil med `192.168.1.50` med en kö `ipp/print`. _Forward_ erbjuder sedan en drivrutin, där en modern skrivare fungerar bäst med den drivrutinslösa profilen _IPP Everywhere_ och en äldre vill ha modellens egen drivrutin.

Högerklicka på en skrivare och välj _Set as Default_ för att välja vilken dina appar använder först, och _Properties_ för att ställa in pappersstorlek, duplex och kvalitet.

Automatisk upptäckt, där skrivare på nätverket dyker upp utan att läggas till, är tillfälligt avstängd medan den görs om, vilket är varför första steget ovan är ditt och inte automatiskt. Utskrift till en PDF-fil fungerar helt utan skrivare.

### Hur ändrar jag var screenshots eller screenrecordings sparas?

Sparade screenshots hamnar i `~/Pictures/Screenshots` som standard. För att använda en annan katalog, lägg till detta i en fil under `~/.config/uwsm/env.d/` (som `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Du kan göra samma sak för screenrecordings med `OMARCHY_SCREENRECORD_DIR`.

Omasnap skapar sin screenshot-katalog automatiskt. Skapa screenrecording-katalogen själv, och starta sedan om Omarchy för att någon av miljövariabeländringarna ska börja gälla.

### Hur får jag högtalarna + webbkameran att fungera på min Apple Studio Display?

Man skulle tro att allt bara ska fungera genom att koppla in USB C, men så är det tyvärr inte. Lösningen jag har hittat för att få det att fungera pålitligt är att använda [the WJESOG DisplayPort + USB-A => USB-C cable](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Då fungerar högtalare och webbkamera som en dröm.

Kom ihåg att du har inbyggd ljusstyrkekontroll i Omarchy för Apple Displays (både Studio och XDR) med de vanliga tangentbordsknapparna för ljusstyrka.

### Hur blir jag av med all extra mjukvara?

Om du inte vill ha program som Obsidian eller LibreOffice eller något av det andra förinstallerade, kan du väldigt enkelt ta bort det.

Kör _Remove > Package_ för att se varje paket som är installerat. Sedan kan du välja vilket paket du vill ta bort med tab, och börja ta bort allt du har valt med return.

Och du kan använda _Remove > Web App_ från Omarchy-menyn för att ta bort någon av de förinstallerade webbappar du inte vill ha.

Eller kör _Remove > Preinstalls_ för att sopa ut alla förinstallerade tillbehör — webbappar, TUIs och valfria applikationer — i ett svep. Snabbkommandona som startade dem försvinner med dem, så du lämnas med en ren tavla av bindningar att fylla med dina egna i `~/.config/hypr/bindings.lua`.

---

För fel och trasiga delar, se [the Troubleshooting section](45-troubleshooting.md).
