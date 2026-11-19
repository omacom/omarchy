# FAQ

### Hur växlar jag mellan tangentbordslayouter?

Redigera filen `~/.config/hypr/input.lua` och lägg till detta för att växla mellan layouter med `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Panelen visar automatiskt din aktuella tangentbordslayout när du har flera layouter konfigurerade (och du kan klicka på den för att växla också).

### Hur ändrar jag klockformatet till 12-timmars?

Högerklicka på klockan i panelen för att växla mellan de vanligaste formaten, inklusive 12-timmarsformaten. Du kan också ange formatet direkt:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Detta visar Söndag 10:55 AM.

### Hur ändrar jag min tidszon?

Kör _Installation > Region > Tidszon_ i Omarchy-menyn och välj från listan. Om tidszonen är rätt men själva klockan har dragit sig, startar _Uppdatering > Tid_ om tidssynkroniseringen åt dig.

### Hur ändrar jag min DNS, delar mitt Wi-Fi eller kontrollerar min anslutningshastighet?

Allt det finns i [nätverk](35-networking.md).

### Hur kontrollerar jag hur snabb min disk är?

_Utlösare > Hastighetstest > Diskhastighetstest_ mäter den aktuella läs- och skrivhastigheten på din disk, eller `omarchy disk speedtest` från terminalen.

### Hur lägger jag till en skrivare?

Utskrift är konfigurerad och igång direkt från start, och du lägger till varje skrivare själv från _Utskriftsinställningar_ i programstartaren (`Super + Space`).

Välj _Lägg till_ och ge den en stund att leta: en skrivare som är ansluten via USB, och de flesta nätverksskrivare, hittas åt dig. Om din inte finns med i listan väljer du _Nätverksskrivare > Internet Printing Protocol (ipp)_ och anger dess adress — skrivarens egen display eller dess webbsida talar om vad den är, oftast något i stil med `192.168.1.50` med en kö på `ipp/print`. _Framåt_ erbjuder sedan en drivrutin, där en modern skrivare fungerar bäst med den drivrutinslösa profilen _IPP Everywhere_ och en äldre vill ha modellens egen drivrutin.

Högerklicka på en skrivare och välj _Ange som standard_ för att välja vilken dina appar ska använda först, och _Egenskaper_ för att ställa in pappersstorlek, duplex och kvalitet.

Automatisk upptäckt, där skrivare i nätverket dyker upp utan att läggas till, är tillfälligt avstängd medan den görs om, vilket är anledningen till att det första steget ovan är ditt i stället för automatiskt. Att skriva ut till en PDF-fil fungerar helt utan någon skrivare.

### Hur ändrar jag var skärmdumpar eller skärminspelningar sparas?

Sparade skärmdumpar hamnar i `~/Pictures/Screenshots` som standard. Om du vill använda en annan katalog lägger du till detta i en fil under `~/.config/uwsm/env.d/` (som `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Du kan göra samma sak för skärminspelningar med `OMARCHY_SCREENRECORD_DIR`.

Omasnap skapar sin katalog för skärmdumpar automatiskt. Skapa katalogen för skärminspelningar själv och starta sedan om Omarchy för att någon av miljöändringarna ska börja gälla.

### Hur får jag högtalarna + webbkameran att fungera på min Apple Studio Display?

Man skulle tro att allt bara ska fungera när man kopplar in USB C, men tyvärr är det inte så. Lösningen jag har hittat för att få det att fungera pålitligt är att använda [WJESOG DisplayPort + USB-A => USB-C-kabeln](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Då fungerar högtalare och webbkamera som en dröm.

Kom ihåg att du har inbyggd kontroll av ljusstyrkan i Omarchy för Apple-skärmarna (både Studio och XDR) med de vanliga tangenterna för ljusstyrka på tangentbordet.

### Hur blir jag av med all extra programvara?

Om du inte vill ha program som Obsidian eller LibreOffice eller något av det andra förinstallerade, kan du mycket enkelt ta bort det.

Kör _Ta bort > Paket_ för att se alla paket som är installerade. Sedan kan du markera vilket paket du vill ta bort med tab, och börja ta bort allt du har markerat med return.

Och du kan använda _Ta bort > Webbapp_ från Omarchy-menyn för att ta bort någon av de förinstallerade webbapparna du inte vill ha.

Eller kör _Ta bort > Förinstallerade_ för att sopa ut alla förinstallerade extrafunktioner — webbappar, TUIs och valfria program — i ett svep. Snabbtangenterna som startade dem försvinner med dem, så du lämnas med en ren tavla av bindningar att fylla med dina egna i `~/.config/hypr/bindings.lua`.

---

Vid fel och trasiga delar, se [avsnittet Felsökning](45-troubleshooting.md).
