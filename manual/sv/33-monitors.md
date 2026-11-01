# Skärmar

Omarchy utgår som standard från att du kör på en retina-klassad skärm med stöd för 2x. Det är vad du behöver för att få de där fina, skarpa programmerartypsnitten. Det är vad nästan alla nya premiumbärbara datorer med högupplösta skärmar är optimerade för. Det är vad du skulle vilja köra på en 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) eller en 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Men om du inte kör en skärm med en PPI på 218 eller högre kommer du att vilja ändra skärminställningarna. Om du till exempel har en 27" eller 32" 4K kan du välja en fraktionell skala för den från skärmpanelen i översta fältet, eller ange standardvärdet för varje skärm genom att öppna `~/.config/hypr/monitors.lua` och byta till rekommendationen för den kombinationen:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Om du använder en 1080p- eller 1440p-skärm vill du förmodligen bara använda 1x-skalning, och samma för GTK- och X11-appar, så du kan använda:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Ändringar av `GDK_SCALE` gäller för program som startas efter ändringen (och GTK respekterar bara heltal, så håll det på det närmaste heltalet till din skärmskala). Så se till att du stänger fönstren du har som är överdimensionerade efter ändringen (eller stäng alla fönster med `Ctrl + Alt + Del`!).

Du kan också snabbt stega igenom de stora skalningsförhållandena för skärmar (1x, 1.25x, 1.6x, 2x, 3x, 4x) med `Super + /` för att gå högre och `Super + Alt + /` för att gå lägre, eller välja ett från skärmpanelen i översta fältet. Dessa ändrar bara den skärm du har i fokus, så en bärbar dators skärm och en extern skärm kan var och en ha sin egen skala. Panelen anger också varje skärms upplösning, uppdateringsfrekvens och rotation. Dina val sparas för den fysiska skärmen i `~/.local/state/omarchy/monitors/settings`, så de finns kvar efter omstart och följer med skärmen till vilken port eller docka den ansluts till nästa gång. De har företräde framför varje regel för samma skärm i `~/.config/hypr/monitors.lua`, som Omarchy aldrig redigerar. Om du hellre vill ställa in dina skärmar helt och hållet i den filen lägger du till `omarchy_monitor_panel_settings = false` i den, och panelens ändringar varar då bara tills Hyprland laddar om. Eftersom `GDK_SCALE` är ett enda värde för alla skärmar anger en vald skala det från skärmen med den lägsta skalan, så X11-appar blir lite små på den tätare skärmen snarare än överdimensionerade på den andra.

### Göra text större eller mindre

Skärmskalning ändrar storleken på allt. Om allt du vill ha är större eller mindre _text_ finns det ett enda reglage för det:

```
omarchy display text size 14
```

Det tar en pixelstorlek mellan 9 och 20 och skalar Omarchy-skalet, GTK-program och din terminal tillsammans, så att hela skrivbordet håller proportionerna. Kör det utan argument för att se var du ligger, och `omarchy display text size reset` för att gå tillbaka till standardvärdet. Foot är den enda eftersläntraren: den har inget sätt att ladda om sin konfiguration, så terminaler som körs behåller sin gamla storlek tills du öppnar en ny.

### Utöka och spegla skärmar på bärbara datorer

När du ansluter en extern skärm till din bärbara dator utökas skärmen automatiskt. Men du kan ändra det till spegling i stället via _Trigger > Hardware_ i Omarchy-menyn eller `Super + Ctrl + Alt + Delete`. Det är särskilt hjälpsamt om den externa skärmen är en projektor och du vill visa något medan du arbetar.

När du utökar stängs den interna skärmen automatiskt av när du fäller ned locket på den bärbara datorn. När du fäller upp locket slås den på igen. Du kan också styra detta manuellt via _Trigger > Hardware_ i Omarchy-menyn eller `Super + Ctrl + Delete`.

### Ordna flera skärmar

Hyprland fungerar utmärkt med flera skärmar. Skärmpanelen i översta fältet ritar upp dem där de sitter: dra en mot sidan av en annan för att flytta den dit, så sparas arrangemanget tillsammans med varje skärms övriga inställningar. För allt som panelen inte täcker kan du läsa mer om hur du lägger ut dem i [dokumentationen för Hyprland-skärmar](https://wiki.hypr.land/Configuring/Basics/Monitors/). I Omarchy läggs dessa i `~/.config/hypr/monitors.lua` som `hl.monitor`-poster — filen levereras med kommenterade exempel för att hålla en skärm avstängd, lägen som panelen inte erbjuder, 10-bitars färg och variabel uppdateringsfrekvens.

Varje skärm har sina egna arbetsytor 1 till 10, så `Super + 1` betyder alltid den första arbetsytan på skärmen du är på. Bakom kulisserna numrerar Hyprland fortfarande arbetsytor över alla skärmar: din bärbara dators skärm (eller första skärmen) får 1–10, nästa skärm 11–20, och så vidare, och varje skärm behåller sitt block varje gång du ansluter den. Använd de numren om du skriver [arbetsyteregler](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) eller fönsterregler för en specifik skärm, så att arbetsyta 12 är den andra arbetsytan på din andra skärm. `~/.local/state/omarchy/monitors/workspaces` listar vilket block varje skärm har.

Piltangenterna fungerar över skärmar som delar en kant i din layout. Skärmar som bara nuddar varandra i ett hörn, eller som har ett mellanrum mellan sig, är inte grannar, så använd `Ctrl + Alt + Tab` för att ta dig mellan dem.

| Kortkommando | Mellan skärmar |
| --- | --- |
| `Super + Arrow` | Flyttar fokus till skärmen på den sidan när det inte finns något fönster kvar i den riktningen |
| `Super + Shift + Arrow` | Byter plats med ett fönster på skärmen på den sidan |
| `Super + Alt + Arrow` | Flyttar fönstret till en grupp på skärmen på den sidan |
| `Super + Shift + Ctrl + Arrow` | Flyttar fönstret till skärmen på den sidan, till arbetsytan den visar |
| `Super + Shift + Alt + Arrow` | Flyttar arbetsytan till skärmen på den sidan och behåller dess nummer om det är ledigt |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Flyttar fokus till nästa eller föregående skärm, oavsett layout |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Stannar på skärmen du är på |

Du kan också kolla in [Hyprmon](https://github.com/erans/hyprmon/), om du vill ha ett TUI som hjälper dig med positioneringen av flera skärmar.

### Styra ljusstyrka

Skärmens ljusstyrka styrs med de dedikerade funktionstangenterna för ljusstyrka upp/ned. Om du håller ned shift medan du trycker på dessa går du till maximal eller minimal ljusstyrka. Tangenterna styr skärmen du har i fokus, så externa skärmar som talar DDC/CI justeras på samma sätt som den bärbara datorns skärm.

### Apple-skärmar

Om du använder en Apple-skärm fungerar de vanliga tangenterna för ljusstyrka på tangentbordet också automatiskt, om du har fokus på Apple-skärmen. Detta görs via kommandot `asdcontrol`.

Observera att om du använder en Apple 6K XDR-skärm kan du se en fantomskärm i din `hyprctl monitors`-listning. Du kan stänga av detta med något i stil med `hl.monitor({ output = "DP-2", disabled = true })` i `~/.config/hypr/monitors.lua`.

På Intel-maskiner bör du ansluta till Apple-skärmar med en vanlig Thunderbolt-kabel. På andra maskiner utan Thunderbolt måste du vanligtvis använda en [DP + USB-A -> USB-C-kabel](https://www.amazon.com/dp/B0BNX7MS6N) för att få det att fungera.
