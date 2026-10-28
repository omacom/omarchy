# Skärmar

Omarchy utgår som standard från att du kör på en skärm i retina-klassen med stöd för 2x. Det är vad du behöver för att få de där fina, skarpa programmerartypsnitten. Det är vad nästan alla nya premiumlaptops med högupplösta skärmar är optimerade för. Det är vad du skulle vilja köra på en 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) eller 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Men om du inte kör en skärm med en PPI på 218 eller högre kommer du att vilja ändra skärminställningarna. Om du till exempel har en 27" eller 32" 4K kan du använda fraktionell skalning genom att öppna `~/.config/hypr/monitors.lua` (via _Inställningar > Skärmar_ i Omarchy-menyn) och byta till rekommendationen för den kombinationen:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Om du använder en 1080p- eller 1440p-skärm vill du förmodligen bara använda 1x-skalning, så du kan använda:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Ändringar av `GDK_SCALE` gäller för program som startas efter ändringen (och GTK accepterar bara heltal, så håll den vid det närmaste heltalet till din skärmskalning). Så se till att du stänger fönstren du har som är överdimensionerade efter ändringen (eller stäng alla fönster med `Ctrl + Alt + Del`!).

Du kan också snabbt stega igenom de stora skalningsförhållandena för skärmar (1x, 1.25x, 1.6x, 2x, 3x, 4x) med `Super + /` för att gå högre och `Super + Alt + /` för att gå lägre, eller välja ett från skärmpanelen i det övre fältet. Dessa ändrar bara skärmen du har i fokus, så en laptopskärm och en extern skärm kan var och en ha sin egen skala. Valet sparas i `~/.config/hypr/monitors.lua` som en `hl.monitor`-regel för den skärmen, så det finns kvar efter omstart och har företräde framför `omarchy_monitor_scale`, som förblir skalan för varje skärm utan en egen regel.

### Göra texten större eller mindre

Skärmskalning ändrar storleken på allt. Om allt du vill ha är större eller mindre _text_ finns det en enda ratt för det:

```
omarchy display text size 14
```

Den tar en pixelstorlek mellan 9 och 20, och flyttar Omarchy-skalet, GTK-program och din terminal tillsammans, så att hela skrivbordet håller proportionerna. Kör den utan argument för att se var du befinner dig, och `omarchy display text size reset` för att gå tillbaka till standardvärdet. Foot är den enda eftersläntraren: den har inget sätt att ladda om sin konfiguration, så terminaler som redan körs behåller sin gamla storlek tills du öppnar en ny.

### Utöka och spegla laptopskärmar

När du ansluter en extern skärm till din laptop utökas skrivbordet automatiskt. Men du kan ändra det till spegling i stället via _Utlösare > Hårdvara_ i Omarchy-menyn eller `Super + Ctrl + Alt + Delete`. Det är särskilt hjälpsamt om den externa skärmen är en projektor och du vill visa något medan du arbetar.

När du utökar kommer locket på laptopen, när du stänger det, automatiskt att stänga av den interna skärmen. När du öppnar locket slås den på igen. Du kan också styra detta manuellt via _Utlösare > Hårdvara_ i Omarchy-menyn eller `Super + Ctrl + Delete`.

### Arrangera flera skärmar

Hyprland fungerar utmärkt med flera skärmar. Läs mer om hur du lägger ut dem i [Hyprlands skärmdokumentation](https://wiki.hypr.land/Configuring/Basics/Monitors/). I Omarchy ligger dessa i `~/.config/hypr/monitors.lua` som `hl.monitor`-poster — filen levereras med utkommenterade exempel för att fästa en specifik skärm vid en upplösning, position och rotation.

Varje skärm har sina egna arbetsytor 1 till 10, så `Super + 1` betyder alltid den första arbetsytan på skärmen du befinner dig på. Bakom kulisserna numrerar Hyprland fortfarande arbetsytor över alla skärmar: din laptopskärm (eller första skärm) får 1–10, nästa skärm 11–20, och så vidare, och varje skärm behåller sitt block varje gång du ansluter den. Använd de numren om du skriver [regler för arbetsytor](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) eller fönsterregler för en specifik skärm, så att arbetsyta 12 är den andra arbetsytan på din andra skärm. `~/.local/state/omarchy/monitor-workspaces` listar vilket block varje skärm har.

Piltangenterna fungerar över skärmar som delar en kant i din layout. Skärmar som bara nuddar varandra i ett hörn, eller som har ett glapp mellan sig, är inte grannar, så använd `Ctrl + Alt + Tab` för att ta dig mellan dem.

| Tangentkombination | Mellan skärmar |
| --- | --- |
| `Super + Arrow` | Flyttar fokus till skärmen på den sidan när det inte längre finns något fönster i den riktningen |
| `Super + Shift + Arrow` | Byter plats med ett fönster på skärmen på den sidan |
| `Super + Alt + Arrow` | Flyttar fönstret till en grupp på skärmen på den sidan |
| `Super + Shift + Ctrl + Arrow` | Flyttar fönstret till skärmen på den sidan, till den arbetsyta den visar |
| `Super + Shift + Alt + Arrow` | Flyttar arbetsytan till skärmen på den sidan, och behåller dess nummer om det är ledigt |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Flyttar fokus till nästa eller föregående skärm, oavsett layout |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Stannar på skärmen du befinner dig på |

Du kan också kolla in [Hyprmon](https://github.com/erans/hyprmon/), om du vill ha ett TUI som hjälper dig med positioneringen av flera skärmar.

### Styra ljusstyrkan

Skärmens ljusstyrka styrs med de dedikerade funktionstangenterna för ljusstyrka upp/ned. Om du håller ned Shift medan du trycker på dessa går du till maximal eller minimal ljusstyrka. Tangenterna styr skärmen du har i fokus, så externa skärmar som talar DDC/CI justeras på samma sätt som laptopskärmen.

### Apple-skärmar

Om du använder en Apple-skärm kommer de vanliga tangenterna för ljusstyrka på tangentbordet också automatiskt att fungera, om du har fokus på Apple-skärmen. Detta görs via kommandot `asdcontrol`.

Observera att om du använder en Apple 6K XDR-skärm kan du se en fantomskärm i din `hyprctl monitors`-listning. Du kan stänga av detta med något i stil med `hl.monitor({ output = "DP-2", disabled = true })` via _Inställningar > Skärmar_.

På Intel-maskiner bör du ansluta till Apple-skärmar med en vanlig Thunderbolt-kabel. På andra maskiner utan Thunderbolt måste du vanligtvis använda en [DP + USB-A -> USB-C-kabel](https://www.amazon.com/dp/B0BNX7MS6N) för att få det att fungera.
