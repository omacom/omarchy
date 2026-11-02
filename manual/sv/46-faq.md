# FAQ

### Hur växlar jag mellan tangentbordslayouter?

Redigera din `~/.config/hypr/input.lua`-fil och lägg till detta för att växla mellan layouter på `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Fältet kommer automatiskt att visa din aktuella tangentbordslayout när du har flera layouter konfigurerade (och du kan klicka på det för att växla också).

### Hur ändrar jag klockformatet till 12-timmars?

Högerklicka på klockan i fältet för att bläddra igenom de vanliga formaten, inklusive 12-timmarsformaten. Du kan också ställa in formatet direkt:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Detta kommer att visa Sunday 10:55 AM.

### Hur ändrar jag min tidszon?

Kör _Uppdatera > Timezone_ i Omarchy-menyn och välj från listan. Om tidszonen är rätt men själva klockan har driftat startar _Uppdatera > Time_ om tidssynkroniseringen åt dig.

### Hur ändrar jag min DNS, delar mitt Wi-Fi eller kontrollerar min anslutningshastighet?

De finns alla i [nätverk](35-networking.md).

### Hur kontrollerar jag hur snabb min disk är?

_Utlös > Hastighetstest > Diskhastighetstest_ mäter läs- och skrivhastighet i realtid på din enhet, eller `omarchy disk speedtest` från terminalen.

### Varför kan jag inte logga in på mitt Google-konto i Chromium?

Den vanliga Chromium-versionen med öppen källkod levereras inte med de OAuth-uppgifter som Google kräver för kontoinloggning. Kör _Installera > Service > Chromium Account_ i Omarchy-menyn för att lägga till dem, starta om webbläsaren, så går inloggningen igenom.

### Hur lägger jag till en skrivare?

Utskrift är konfigurerat och körs direkt ur lådan, och du lägger till varje skrivare själv från _Print Settings_ i appstartaren (`Super + Space`).

Välj _Add_, och ge det en stund att leta: en skrivare inkopplad via USB, och de flesta nätverksskrivare, hittas åt dig. Om din inte finns i listan väljer du _Network Printer > Internet Printing Protocol (ipp)_ och anger dess adress — skrivarens egen display eller dess webbsida berättar vad det är, vanligtvis något i stil med `192.168.1.50` med en kö på `ipp/print`. _Forward_ erbjuder sedan en drivrutin, där en modern skrivare fungerar bäst på den drivrutinslösa _IPP Everywhere_-profilen och en äldre vill ha modellens egen drivrutin.

Högerklicka på en skrivare och välj _Set as Default_ för att välja vilken dina appar når först, och _Properties_ för att ställa in pappersstorlek, duplex och kvalitet.

Automatisk upptäckt, där skrivare i nätverket visas utan att läggas till, är tillfälligt avstängd medan den omarbetas, vilket är anledningen till att det första steget ovan är ditt snarare än automatiskt. Att skriva ut till en PDF-fil fungerar utan någon skrivare alls.

### Hur ändrar jag var skärmbilder eller skärminspelningar sparas?

Sparade skärmbilder går till `~/Pictures/Screenshots` som standard. För att använda en annan katalog lägger du till detta i en fil under `~/.config/uwsm/env.d/` (som `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Du kan göra samma sak för skärminspelningar med `OMARCHY_SCREENRECORD_DIR`.

Omasnap skapar sin skärmbildskatalog automatiskt. Skapa skärminspelningskatalogen själv, och starta sedan om Omarchy för att någon av miljöändringarna ska träda i kraft.

### Hur får jag högtalare + webbkamera att fungera på min Apple Studio Display?

Man skulle kunna tro att allt bara ska fungera med att koppla in USB C, men tyvärr är det inte fallet. Den lösning jag har funnit för att få det att fungera tillförlitligt är att använda [WJESOG DisplayPort + USB-A => USB-C-kabeln](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Då fungerar högtalare och webbkamera som en charm.

Kom ihåg att du har inbyggd ljusstyrkekontroll i Omarchy för Apple Displays (både Studio och XDR) med de vanliga ljusstyrkeknapparna på tangentbordet.

### Hur blir jag av med all extra mjukvara?

Om du inte vill ha program som Obsidian eller LibreOffice eller något av det andra förinstallerade kan du mycket enkelt ta bort det.

Kör _Ta bort > Package_ för att se varje installerat paket. Sedan kan du välja vilket paket du vill ta bort med tab, och börja ta bort allt du har valt med retur.

Och du kan använda _Ta bort > Web App_ från Omarchy-menyn för att ta bort någon av de förinstallerade webbapparna du inte vill ha.

Eller kör _Ta bort > Preinstalls_ för att sopa ut alla förinstallerade tillägg — webbappar, TUI:er och valfria applikationer — i ett svep. Snabbtangenterna som startade dem försvinner med dem, så du lämnas med ett rent blad av bindningar att fylla med dina egna i `~/.config/hypr/bindings.lua`.

---

För fel och trasiga delar, se [felsökningsavsnittet](45-troubleshooting.md).
