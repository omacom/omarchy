# Skärmar

Omarchy antar att du kör på en 2x-kapabel retina-klassad skärm som standard. Det är vad du behöver för att få de där fina, skarpa programmerartypsnitten. Det är vad nästan alla nya premium-laptops med högupplösta skärmar är optimerade för. Det är vad du vill köra på en 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) eller 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Men om du inte kör en skärm med en PPI på 218 eller högre vill du ändra skärminställningarna. Till exempel, om du har en 27" eller 32" 4K kan du använda bråkdels-skalning genom att öppna `~/.config/hypr/monitors.lua` (via _Installation > Skärmar_ i Omarchy-menyn) och växla till rekommendationen för den kombinationen:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Om du använder en 1080p- eller 1440p-skärm vill du förmodligen bara använda 1x-skalning, så du kan använda:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Ändringar av `GDK_SCALE` gäller applikationer som startas efter ändringen (och GTK respekterar bara heltal, så håll det till närmaste heltal av din skärmskala). Så se till att du avslutar de fönster du har som är för stora efter ändringen (eller stäng alla fönster med `Ctrl + Alt + Del`!).

Du kan också snabbt stega igenom de stora förhållandena för skärmskalning (1x, 1.25x, 1.6x, 2x, 3x, 4x) med `Super + /` för att gå högre och `Super + Alt + /` för att gå lägre. Om du har standardkonfigurationen kommer dessa ändringar också att kvarstå efter omstart.

### Göra text större eller mindre

Skärmskalning ändrar storleken på allt. Om allt du vill ha är större eller mindre _text_ finns det en enda ratt för det:

```
omarchy display text size 14
```

Det tar en pixelstorlek mellan 9 och 20, och flyttar Omarchy-skalet, GTK-applikationer och din terminal tillsammans, så att hela skrivbordet förblir i proportion. Kör det utan argument för att se var du befinner dig, och `omarchy display text size reset` för att gå tillbaka till standard. Foot är den enda eftersläntraren: den har inget sätt att ladda om sin config, så körande terminaler behåller sin gamla storlek tills du öppnar en ny.

### Utöka och spegla laptop-skärmar

När du ansluter en extern skärm till din laptop utökas skärmen automatiskt. Men du kan ändra det till spegling istället via _Utlös > Hardware_ i Omarchy-menyn eller `Super + Ctrl + Alt + Delete`. Det är särskilt hjälpsamt om den externa skärmen är en projektor, och du vill visa något medan du arbetar.

När du utökar stänger laptop-locket automatiskt av den interna skärmen. Att öppna locket slår på den igen. Du kan också styra det manuellt via _Utlös > Hardware_ i Omarchy-menyn eller `Super + Ctrl + Delete`.

### Arrangera flera skärmar

Hyprland fungerar utmärkt med flera skärmar. Läs mer om hur du lägger ut dem i [Hyprlands dokumentation om skärmar](https://wiki.hypr.land/Configuring/Basics/Monitors/). Du kan också [binda specifika arbetsytor till specifika skärmar](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/). I Omarchy hamnar dessa regler i `~/.config/hypr/monitors.lua` som `hl.monitor`-poster — filen levereras med kommenterade exempel för att fästa en specifik skärm till en upplösning, position och rotation.

Du kan också titta på [Hyprmon](https://github.com/erans/hyprmon/), om du vill ha ett TUI som hjälper dig med positioneringen av flera skärmar.

### Styra ljusstyrkan

Skärmens ljusstyrka styrs av de dedikerade funktionstangenterna för ljusstyrka upp/ner. Om du håller ned shift medan du trycker på dessa går du till maximal eller minimal ljusstyrka. Tangenterna styr den skärm du är fokuserad på, så externa skärmar som talar DDC/CI justeras på samma sätt som laptop-skärmen.

### Apple-skärmar

Om du använder en Apple-skärm kommer de vanliga tangentbordstangenterna för ljusstyrka också att fungera automatiskt, om du är fokuserad på Apple-skärmen. Det görs via kommandot `asdcontrol`.

Observera att om du använder en Apple 6K XDR-skärm kan du se en fantomskärm i din `hyprctl monitors`-listning. Du kan stänga av den med något som `hl.monitor({ output = "DP-2", disabled = true })` via _Installation > Skärmar_.

På Intel-maskiner bör du ansluta till Apple-skärmar med en vanlig Thunderbolt-kabel. På andra maskiner utan Thunderbolt måste du typiskt använda en [DP + USB-A -> USB-C cable](https://www.amazon.com/dp/B0BNX7MS6N) för att få det att fungera.
