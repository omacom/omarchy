# Skärmar

Omarchy förutsätter som standard att du kör på en retina-klassad skärm med stöd för 2x. Det är vad du behöver för att få de där fina, skarpa programmerartypsnitten. Det är vad nästan alla nya premiumbärbara datorer med högupplösta skärmar är optimerade för. Det är vad du skulle vilja köra på en 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) eller 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Men om du inte kör en skärm med en PPI på 218 eller högre vill du ändra skärminställningarna. Om du till exempel har en 27" eller 32" 4K kan du använda fraktionell skalning genom att öppna `~/.config/hypr/monitors.lua` (via _Setup > Monitors_ i Omarchy-menyn) och byta till rekommendationen för den kombinationen:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Om du använder en 1080p- eller 1440p-skärm vill du förmodligen bara använda 1x-skalning, så du kan använda:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Ändringar av `GDK_SCALE` gäller för program som startas efter ändringen (och GTK accepterar bara heltal, så håll det vid det heltal som ligger närmast din skärmskalning). Så se till att avsluta de fönster du har som är överdimensionerade efter ändringen (eller stäng alla fönster med `Ctrl + Alt + Del`!).

Du kan också snabbt stega igenom de stora skalningsförhållandena för skärmar (1x, 1.25x, 1.6x, 2x, 3x, 4x) med `Super + /` för att gå högre och `Super + Alt + /` för att gå lägre, eller välja en från skärmpanelen i den övre listen. Dessa ändrar bara den skärm du har i fokus, så en bärbar dators skärm och en extern skärm kan var och en ha sin egen skala. Valet sparas till `~/.config/hypr/monitors.lua` som en `hl.monitor`-regel för den skärmen, så det finns kvar efter omstart och har företräde framför `omarchy_monitor_scale`, som förblir skalan för varje skärm utan en egen regel. Eftersom `GDK_SCALE` är ett enda värde för alla skärmar sätts det vid dessa ändringar från skärmen med den lägsta skalan, så att X11-appar blir lite små på den tätare skärmen snarare än överdimensionerade på den andra.

### Göra text större eller mindre

Skärmskalning ändrar storleken på allt. Om allt du vill ha är större eller mindre _text_ finns det en enda ratt för det:

```
omarchy display text size 14
```

Det tar en pixelstorlek mellan 9 och 20 och flyttar Omarchy-skalet, GTK-program och din terminal tillsammans, så att hela skrivbordet håller proportionerna. Kör det utan argument för att se var du ligger, och `omarchy display text size reset` för att gå tillbaka till standardvärdet. Foot är den enda eftersläntraren: den har inget sätt att läsa in sin konfiguration på nytt, så terminaler som körs behåller sin gamla storlek tills du öppnar en ny.

### Utöka och spegla skärmar på bärbar dator

När du ansluter en extern skärm till din bärbara dator utökas skärmen automatiskt. Men du kan ändra det till spegling i stället med _Trigger > Hardware_ i Omarchy-menyn eller `Super + Ctrl + Alt + Delete`. Det är särskilt hjälpsamt om den externa skärmen är en projektor och du vill visa något medan du arbetar.

När du utökar kommer den interna skärmen automatiskt att stängas av när du stänger locket på den bärbara datorn. Att öppna locket slår på den igen. Du kan också styra detta manuellt med _Trigger > Hardware_ i Omarchy-menyn eller `Super + Ctrl + Delete`.

### Arrangera flera skärmar

Hyprland fungerar utmärkt med flera skärmar. Läs mer om hur du lägger ut dem i [Hyprland-dokumentationen för skärmar](https://wiki.hypr.land/Configuring/Basics/Monitors/). I Omarchy läggs dessa i `~/.config/hypr/monitors.lua` som `hl.monitor`-poster — filen levereras med kommenterade exempel för att låsa en specifik skärm till en upplösning, position och rotation.

Varje skärm har sina egna arbetsytor 1 till 10, så `Super + 1` betyder alltid den första arbetsytan på skärmen du befinner dig på. Bakom kulisserna numrerar Hyprland ändå arbetsytor över alla skärmar: din bärbara dators skärm (eller första skärm) får 1–10, nästa skärm 11–20, och så vidare, och varje skärm behåller sitt block varje gång du ansluter den. Använd de numren om du skriver [regler för arbetsytor](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) eller fönsterregler för en specifik skärm, så att arbetsyta 12 är den andra arbetsytan på din andra skärm. `~/.local/state/omarchy/monitor-workspaces` listar vilket block varje skärm har.

Piltangenterna fungerar mellan skärmar som delar en kant i din layout. Skärmar som bara vidrör varandra i ett hörn, eller som har en lucka mellan sig, är inte grannar, så använd `Ctrl + Alt + Tab` för att ta dig mellan dem.

| Snabbtangent | Mellan skärmar |
| --- | --- |
| `Super + Arrow` | Flyttar fokus till skärmen på den sidan när det inte finns något fönster kvar i den riktningen |
| `Super + Shift + Arrow` | Byter plats med ett fönster på skärmen på den sidan |
| `Super + Alt + Arrow` | Flyttar fönstret till en grupp på skärmen på den sidan |
| `Super + Shift + Ctrl + Arrow` | Flyttar fönstret till skärmen på den sidan, till arbetsytan som den visar |
| `Super + Shift + Alt + Arrow` | Flyttar arbetsytan till skärmen på den sidan och behåller dess nummer om det är ledigt |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Flyttar fokus till nästa eller föregående skärm, oavsett layout |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Stannar på skärmen du befinner dig på |

Du kan också kolla in [Hyprmon](https://github.com/erans/hyprmon/), om du vill ha ett TUI som hjälper dig med positioneringen av flera skärmar.

### Styra ljusstyrkan

Skärmens ljusstyrka styrs av de dedikerade funktionstangenterna för ljusstyrka upp/ned. Om du håller ned shift medan du trycker på dessa går du till maximal eller minimal ljusstyrka. Tangenterna styr skärmen du har i fokus, så externa skärmar som talar DDC/CI justeras på samma sätt som den bärbara datorns skärm.

### Apple-skärmar

Om du använder en Apple-skärm fungerar de vanliga tangenterna för ljusstyrka på tangentbordet också automatiskt, om du har fokus på Apple-skärmen. Det görs via kommandot `asdcontrol`.

Observera att om du använder en Apple 6K XDR-skärm kan du se en fantomskärm i din `hyprctl monitors`-lista. Du kan stänga av den med något i stil med `hl.monitor({ output = "DP-2", disabled = true })` via _Setup > Monitors_.

På Intel-maskiner bör du ansluta till Apple-skärmar med en vanlig Thunderbolt-kabel. På andra maskiner utan Thunderbolt måste du vanligtvis använda en [DP + USB-A -> USB-C-kabel](https://www.amazon.com/dp/B0BNX7MS6N) för att få det att fungera.
