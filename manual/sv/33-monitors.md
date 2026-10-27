# Bildskärmar

Omarchy utgår som standard från att du kör på en retina-klassad skärm med stöd för 2x. Det är vad du behöver för att få de där fina, skarpa programmerartypsnitten. Det är vad nästan alla nya premiumlaptops med högupplösta skärmar är optimerade för. Det är vad du skulle vilja köra på en 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) eller 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Men om du inte kör på en skärm med en PPI på 218 eller högre vill du ändra bildskärmsinställningarna. Om du till exempel har en 27" eller 32" 4K kan du använda bråkdels­skalning genom att öppna `~/.config/hypr/monitors.lua` (via _Setup > Monitors_ i Omarchy-menyn) och byta till rekommendationen för den kombinationen:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Om du använder en 1080p- eller 1440p-skärm vill du förmodligen bara använda 1x-skalning, så du kan använda:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Ändringar av `GDK_SCALE` gäller för program som startas efter ändringen (och GTK accepterar bara heltal, så håll den på det heltal som ligger närmast din bildskärmsskalning). Så se till att du stänger de fönster du har som är för stora efter ändringen (eller stäng alla fönster med `Ctrl + Alt + Del`!).

Du kan också snabbt stega igenom de stora bildskärmsskalningsförhållandena (1x, 1.25x, 1.6x, 2x, 3x, 4x) med `Super + /` för att gå högre och `Super + Alt + /` för att gå lägre. Om du har standardkonfigurationen kommer dessa ändringar också att finnas kvar efter omstart.

### Göra text större eller mindre

Bildskärmsskalning ändrar storleken på allt. Om allt du vill ha är större eller mindre _text_ finns det en enda ratt för det:

```
omarchy display text size 14
```

Den tar en pixelstorlek mellan 9 och 20 och flyttar Omarchy-skalet, GTK-program och din terminal tillsammans, så att hela skrivbordet behåller sina proportioner. Kör den utan argument för att se var du ligger, och `omarchy display text size reset` för att gå tillbaka till standardvärdet. Foot är den enda eftersläntraren: den har inget sätt att läsa in sin konfiguration igen, så terminaler som redan körs behåller sin gamla storlek tills du öppnar en ny.

### Utöka och spegla laptopskärmar

När du ansluter en extern skärm till din laptop utökas skärmen automatiskt. Men du kan ändra det till spegling i stället via _Trigger > Hardware_ i Omarchy-menyn eller `Super + Ctrl + Alt + Delete`. Det är särskilt hjälpsamt om den externa skärmen är en projektor och du vill visa något medan du arbetar.

När du utökar stängs den interna skärmen automatiskt av när du stänger locket på laptopen. När du öppnar locket slås den på igen. Du kan också styra detta manuellt via _Trigger > Hardware_ i Omarchy-menyn eller `Super + Ctrl + Delete`.

### Ordna flera skärmar

Hyprland fungerar utmärkt med flera skärmar. Läs mer om hur du placerar dem i [Hyprland-dokumentationen för bildskärmar](https://wiki.hypr.land/Configuring/Basics/Monitors/). I Omarchy läggs dessa i `~/.config/hypr/monitors.lua` som `hl.monitor`-poster — filen levereras med kommenterade exempel för att fästa en specifik bildskärm vid en upplösning, position och rotation.

Varje bildskärm har sina egna arbetsytor 1 till 10, så `Super + 1` betyder alltid den första arbetsytan på den bildskärm du är på. Bakom kulisserna numrerar Hyprland ändå arbetsytor över alla bildskärmar: din laptopskärm (eller första bildskärm) får 1–10, nästa bildskärm 11–20 och så vidare, och varje bildskärm behåller sitt block varje gång du ansluter den. Använd de numren om du skriver [arbetsytsregler](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) eller fönsterregler för en specifik bildskärm, så att arbetsyta 12 är den andra arbetsytan på din andra bildskärm. `~/.local/state/omarchy/monitor-workspaces` listar vilket block varje bildskärm har.

Piltangenterna fungerar mellan bildskärmar som delar en kant i din layout. Skärmar som bara nuddar varandra i ett hörn, eller som har ett mellanrum mellan sig, är inte grannar, så använd `Ctrl + Alt + Tab` för att ta dig mellan dem.

| Snabbtangent | Mellan bildskärmar |
| --- | --- |
| `Super + Arrow` | Flyttar fokus till bildskärmen på den sidan när det inte finns något fönster kvar i den riktningen |
| `Super + Shift + Arrow` | Byter plats med ett fönster på bildskärmen på den sidan |
| `Super + Alt + Arrow` | Flyttar fönstret till en grupp på bildskärmen på den sidan |
| `Super + Shift + Ctrl + Arrow` | Flyttar fönstret till bildskärmen på den sidan, till den arbetsyta den visar |
| `Super + Shift + Alt + Arrow` | Flyttar arbetsytan till bildskärmen på den sidan och behåller dess nummer om det är ledigt |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Flyttar fokus till nästa eller föregående bildskärm, oavsett layout |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Stannar på den bildskärm du är på |

Du kan också kolla in [Hyprmon](https://github.com/erans/hyprmon/), om du vill ha ett TUI som hjälper dig med placeringen av flera skärmar.

### Styra ljusstyrkan

Bildskärmens ljusstyrka styrs med de dedikerade funktionstangenterna för ljusstyrka upp/ner. Om du håller ned Shift medan du trycker på dessa går du till maximal eller minimal ljusstyrka. Tangenterna styr den skärm du har i fokus, så externa bildskärmar som talar DDC/CI justeras på samma sätt som laptopskärmen.

### Apple-skärmar

Om du använder en Apple-skärm kommer de vanliga tangenterna för ljusstyrka på tangentbordet också automatiskt att fungera, om du har fokus på Apple-skärmen. Detta görs via kommandot `asdcontrol`.

Observera att om du använder en Apple 6K XDR-skärm kan du se en fantomskärm i din `hyprctl monitors`-listning. Du kan stänga av den med något i stil med `hl.monitor({ output = "DP-2", disabled = true })` via _Setup > Monitors_.

På Intel-maskiner bör du ansluta till Apple-skärmar med en vanlig Thunderbolt-kabel. På andra maskiner utan Thunderbolt måste du vanligtvis använda en [DP + USB-A -> USB-C cable](https://www.amazon.com/dp/B0BNX7MS6N) för att få det att fungera.
