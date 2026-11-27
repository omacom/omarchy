# Bildskärmar

Omarchy utgår från att du som standard kör på en retina-klassad skärm med stöd för 2x. Det är vad du behöver för att få de där fina, skarpa programmerartypsnitten. Det är vad nästan alla nya premiumlaptops med högupplösta skärmar är optimerade för. Det är vad du vill köra på en 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) eller 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Men om du inte kör en skärm med en PPI på 218 eller högre vill du ändra bildskärmsinställningarna. Om du till exempel har en 27" eller 32" 4K kan du välja en bråkdelsskalning för den från bildskärmspanelen i överkanten, eller ange standarden för varje bildskärm genom att öppna `~/.config/hypr/monitors.lua` och byta till rekommendationen för den kombinationen:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Om du använder en 1080p- eller 1440p-skärm vill du förmodligen bara använda 1x-skalning, och samma sak för GTK- och X11-appar, så du kan använda:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Ändringar av `GDK_SCALE` gäller för program som startas efter ändringen (och GTK respekterar bara heltal, så håll den på närmaste heltal för din bildskärmsskala). Se därför till att stänga de fönster du har som är överdimensionerade efter ändringen (eller stäng alla fönster med `Ctrl + Alt + Del`!).

Du kan också snabbt stega igenom de viktigaste skalningsförhållandena för bildskärmar (1x, 1.25x, 1.6x, 2x, 3x, 4x) med `Super + /` för att gå högre och `Super + Alt + /` för att gå lägre, eller välja ett från bildskärmspanelen i överkanten. De ändrar bara den bildskärm du har i fokus, så en laptopskärm och en extern skärm kan var och en ha sin egen skala. Panelen anger också varje bildskärms upplösning, uppdateringsfrekvens och rotation. Dina val sparas för den fysiska bildskärmen i `~/.local/state/omarchy/monitors/settings`, så de finns kvar efter omstart och följer med bildskärmen till vilken port eller docka den ansluts till nästa gång. De har företräde framför alla regler för samma bildskärm i `~/.config/hypr/monitors.lua`, som Omarchy aldrig redigerar. Om du hellre anger dina bildskärmar helt i den filen lägger du till `omarchy_monitor_panel_settings = false` i den, och panelens ändringar varar då bara tills Hyprland laddas om. Eftersom `GDK_SCALE` är ett enda värde för alla skärmar anger en vald skala den från bildskärmen med lägst skala, så X11-appar blir lite små på den tätare skärmen i stället för överdimensionerade på den andra.

### Göra text större eller mindre

Bildskärmsskalning ändrar storleken på allt. Om allt du vill ha är större eller mindre _text_ finns det en enda ratt för det:

```
omarchy display text size 14
```

Det tar en pixelstorlek mellan 9 och 20 och flyttar Omarchy-skalet, GTK-program och din terminal tillsammans, så hela skrivbordet hålls i proportion. Kör det utan argument för att se var du ligger, och `omarchy display text size reset` för att gå tillbaka till standarden. Foot är den enda eftersläntraren: den har inget sätt att ladda om sin konfiguration, så terminaler som redan körs behåller sin gamla storlek tills du öppnar en ny.

### Utöka och spegla laptopskärmar

När du ansluter en extern skärm till din laptop utökas skärmen automatiskt. Men du kan ändra det till spegling i stället med _Extend_ | _Mirror_ i bildskärmspanelen i överkanten, _Trigger > Hardware_ i Omarchy-menyn eller `Super + Ctrl + Alt + Delete`. Detta är särskilt användbart om den externa skärmen är en projektor och du vill visa något medan du arbetar.

När du utökar stängs den interna skärmen automatiskt av när du stänger locket på laptopen. När du öppnar locket slås den på igen. Du kan också styra detta manuellt med _Trigger > Hardware_ i Omarchy-menyn eller `Super + Ctrl + Delete`.

Medan laptopen är ansluten till ström försätter den aldrig i viloläge när du stänger locket, så en dockad laptop håller sig vaken även om den externa skärmen tillfälligt kopplas bort. Utan någon extern skärm ansluten låses den bara när du stänger locket på ström. På batteri försätts den i viloläge som vanligt när du stänger locket.

### Ordna flera skärmar

Hyprland fungerar utmärkt med flera skärmar. Bildskärmspanelen i överkanten ritar dem där de sitter: dra en mot sidan av en annan för att flytta den dit, och arrangemanget sparas tillsammans med varje bildskärms övriga inställningar. För allt som panelen inte täcker kan du läsa mer om hur du lägger ut dem i [Hyprlands dokumentation för bildskärmar](https://wiki.hypr.land/Configuring/Basics/Monitors/). I Omarchy läggs dessa i `~/.config/hypr/monitors.lua` som `hl.monitor`-poster — filen levereras med kommenterade exempel för att hålla en bildskärm avstängd, lägen som panelen inte erbjuder, 10-bitars färg och variabel uppdateringsfrekvens.

Varje bildskärm har sina egna arbetsytor 1 till 10, så `Super + 1` betyder alltid den första arbetsytan på den bildskärm du är på. Bakom kulisserna numrerar Hyprland ändå arbetsytor över alla bildskärmar: din laptopskärm (eller första bildskärm) får 1–10, nästa bildskärm 11–20 och så vidare, och varje bildskärm behåller sitt block varje gång du ansluter den. Använd de numren om du skriver [arbetsyteregler](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) eller fönsterregler för en specifik bildskärm, så arbetsyta 12 är den andra arbetsytan på din andra bildskärm. `~/.local/state/omarchy/monitors/workspaces` listar vilket block varje bildskärm har.

Piltangenterna fungerar mellan bildskärmar som delar en kant i din layout. Skärmar som bara nuddar varandra i ett hörn, eller som har ett glapp mellan sig, är inte grannar, så använd `Ctrl + Alt + Tab` för att komma mellan dem.

| Snabbtangent | Mellan bildskärmar |
| --- | --- |
| `Super + Arrow` | Flyttar fokus till bildskärmen på den sidan när det inte finns något fönster kvar i den riktningen |
| `Super + Shift + Arrow` | Växlar med ett fönster på bildskärmen på den sidan |
| `Super + Alt + Arrow` | Flyttar fönstret till en grupp på bildskärmen på den sidan |
| `Super + Shift + Ctrl + Arrow` | Flyttar fönstret till bildskärmen på den sidan, till arbetsytan den visar |
| `Super + Shift + Alt + Arrow` | Flyttar arbetsytan till bildskärmen på den sidan och behåller dess nummer om det är ledigt |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Flyttar fokus till nästa eller föregående bildskärm, oavsett layout |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Stannar kvar på den bildskärm du är på |

Du kan också kolla in [Hyprmon](https://github.com/erans/hyprmon/), om du vill ha ett TUI som hjälper dig med positioneringen av flera skärmar.

### Styra ljusstyrka

Bildskärmens ljusstyrka styrs med de dedikerade funktionstangenterna för ljusstyrka upp/ned. Om du håller ned shift medan du trycker på dem går du till maximal eller minimal ljusstyrka. Tangenterna styr skärmen du har i fokus, så externa bildskärmar som talar DDC/CI justeras på samma sätt som laptopskärmen.

### Apple-skärmar

Om du använder en Apple-skärm fungerar de vanliga tangenterna för ljusstyrka på tangentbordet också automatiskt, om du har fokus på Apple-skärmen. Detta görs via kommandot `asdcontrol`.

Observera att om du använder en Apple 6K XDR-skärm kan du se en fantomskärm i din `hyprctl monitors`-lista. Du kan stänga av den med något i stil med `hl.monitor({ output = "DP-2", disabled = true })` i `~/.config/hypr/monitors.lua`.

På Intel-maskiner bör du ansluta till Apple-skärmar med en vanlig Thunderbolt-kabel. På andra maskiner utan Thunderbolt måste du vanligtvis använda en [DP + USB-A -> USB-C-kabel](https://www.amazon.com/dp/B0BNX7MS6N) för att få det att fungera.
