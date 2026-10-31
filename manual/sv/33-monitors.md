# Skärmar

Omarchy utgår som standard från att du använder en skärm i retina-klass med stöd för 2x. Det är vad du behöver för att få de där fina, skarpa programmerartypsnitten. Det är vad nästan alla nya premiumlaptops med högupplösta skärmar är optimerade för. Det är vad du vill köra på en 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) eller 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Men om du inte kör en skärm med 218 PPI eller högre vill du ändra skärminställningarna. Om du till exempel har en 27" eller 32" 4K kan du välja en bråkdelsskalning för den från skärmpanelen i toppfältet, eller ange standarden för varje skärm genom att öppna `~/.config/hypr/monitors.lua` och byta till rekommendationen för den kombinationen:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Om du använder en 1080p- eller 1440p-skärm vill du förmodligen bara använda 1x-skalning, och samma för GTK- och X11-appar, så du kan använda:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Ändringar av `GDK_SCALE` gäller för applikationer som startas efter ändringen (och GTK accepterar bara heltal, så håll den på det närmaste heltalet till din skärmskalning). Så se till att du stänger de fönster du har som är för stora efter ändringen (eller stäng alla fönster med `Ctrl + Alt + Del`!).

Du kan också snabbt stega igenom de stora skalningsförhållandena för skärmar (1x, 1.25x, 1.6x, 2x, 3x, 4x) med `Super + /` för att gå högre och `Super + Alt + /` för att gå lägre, eller välja ett från skärmpanelen i toppfältet. De ändrar bara den skärm du har i fokus, så en laptopskärm och en extern skärm kan var och en ha sin egen skala. Panelen anger också varje skärms upplösning. Dina val sparas för den fysiska skärmen i `~/.local/state/omarchy/monitors/settings`, så de finns kvar efter omstart och följer med skärmen till vilken port eller docka den ansluts till härnäst. De har företräde framför alla regler för samma skärm i `~/.config/hypr/monitors.lua`, som Omarchy aldrig redigerar. Om du hellre anger dina skärmar helt och hållet i den filen lägger du till `omarchy_monitor_panel_settings = false` i den, och panelens ändringar varar då bara tills Hyprland laddas om. Eftersom `GDK_SCALE` är ett enda värde för alla skärmar sätts den från skärmen med lägst skala när du väljer en skala, så X11-appar blir lite små på den tätare skärmen i stället för för stora på den andra.

### Göra text större eller mindre

Skärmskalning ändrar storleken på allt. Om allt du vill ha är större eller mindre _text_ finns det en enda ratt för det:

```
omarchy display text size 14
```

Den tar en pixelstorlek mellan 9 och 20, och flyttar Omarchy-skalet, GTK-applikationer och din terminal tillsammans, så hela skrivbordet håller sig i proportion. Kör den utan argument för att se var du ligger, och `omarchy display text size reset` för att gå tillbaka till standarden. Foot är den enda eftersläntraren: den har inget sätt att ladda om sin konfiguration, så körande terminaler behåller sin gamla storlek tills du öppnar en ny.

### Utöka och spegla laptopskärmar

När du ansluter en extern skärm till din laptop utökas skärmen automatiskt. Men du kan ändra det till spegling i stället via _Trigger > Hardware_ i Omarchy-menyn eller `Super + Ctrl + Alt + Delete`. Det är särskilt hjälpsamt om den externa skärmen är en projektor, och du vill visa något medan du arbetar.

När du utökar stängs den interna skärmen automatiskt av när du stänger locket på laptopen. När du öppnar locket slås den på igen. Du kan också styra det här manuellt via _Trigger > Hardware_ i Omarchy-menyn eller `Super + Ctrl + Delete`.

### Ordna flera skärmar

Hyprland fungerar utmärkt med flera skärmar. Skärmpanelen i toppfältet ritar dem där de sitter: dra en mot sidan av en annan för att flytta den dit, och arrangemanget sparas tillsammans med varje skärms övriga inställningar. För allt som panelen inte täcker kan du läsa mer om hur du lägger ut dem i [Hyprlands skärmdokumentation](https://wiki.hypr.land/Configuring/Basics/Monitors/). I Omarchy läggs de här i `~/.config/hypr/monitors.lua` som `hl.monitor`-poster — filen levereras med kommenterade exempel för att låsa en specifik skärm till en upplösning, position och rotation.

Varje skärm har sina egna arbetsytor 1 till 10, så `Super + 1` betyder alltid den första arbetsytan på den skärm du är på. Bakom kulisserna numrerar Hyprland ändå arbetsytor över alla skärmar: din laptopskärm (eller första skärm) får 1–10, nästa skärm 11–20, och så vidare, och varje skärm behåller sitt block varje gång du ansluter den. Använd de numren om du skriver [arbetsytsregler](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) eller fönsterregler för en specifik skärm, så arbetsyta 12 är den andra arbetsytan på din andra skärm. `~/.local/state/omarchy/monitors/workspaces` listar vilket block varje skärm har.

Piltangenterna fungerar över skärmar som delar en kant i din layout. Skärmar som bara möts i ett hörn, eller som har ett mellanrum mellan sig, är inte grannar, så använd `Ctrl + Alt + Tab` för att komma mellan dem.

| Kortkommando | Mellan skärmar |
| --- | --- |
| `Super + Arrow` | Flyttar fokus till skärmen på den sidan när det inte finns något fönster kvar i den riktningen |
| `Super + Shift + Arrow` | Byter plats med ett fönster på skärmen på den sidan |
| `Super + Alt + Arrow` | Flyttar fönstret till en grupp på skärmen på den sidan |
| `Super + Shift + Ctrl + Arrow` | Flyttar fönstret till skärmen på den sidan, till arbetsytan den visar |
| `Super + Shift + Alt + Arrow` | Flyttar arbetsytan till skärmen på den sidan, och behåller dess nummer om det är ledigt |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Flyttar fokus till nästa eller föregående skärm, oavsett layout |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Stannar på den skärm du är på |

Du kan också kolla in [Hyprmon](https://github.com/erans/hyprmon/), om du vill ha en TUI som hjälper dig med placeringen av flera skärmar.

### Styra ljusstyrka

Skärmens ljusstyrka styrs med de dedikerade funktionstangenterna för ljusstyrka upp/ner. Om du håller ned shift medan du trycker på dem går du till maximal eller minimal ljusstyrka. Tangenterna styr den skärm du har i fokus, så externa skärmar som talar DDC/CI justeras på samma sätt som laptopskärmen.

### Apple-skärmar

Om du använder en Apple-skärm fungerar de vanliga tangenterna för ljusstyrka på tangentbordet också automatiskt, om du har fokus på Apple-skärmen. Det görs via kommandot `asdcontrol`.

Observera att om du använder en Apple 6K XDR-skärm kan du se en fantomskärm i din `hyprctl monitors`-listning. Du kan stänga av den med något i stil med `hl.monitor({ output = "DP-2", disabled = true })` i `~/.config/hypr/monitors.lua`.

På Intel-maskiner ska du ansluta till Apple-skärmar med en vanlig Thunderbolt-kabel. På andra maskiner utan Thunderbolt måste du vanligtvis använda en [DP + USB-A -> USB-C-kabel](https://www.amazon.com/dp/B0BNX7MS6N) för att få det att fungera.
