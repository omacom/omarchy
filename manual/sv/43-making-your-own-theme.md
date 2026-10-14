# Gör ditt eget tema

Du kan lägga till egna teman i `~/.config/omarchy/themes`. Kopiera bara ett av de befintliga som bas (titta i `/usr/share/omarchy/themes`), och justera sedan efter hjärtats lust. Så länge ditt tema finns inuti den mappen kommer det att ingå i temavalmenyn.

Huvudfilen du måste justera är `colors.toml`. Den definierar färguppsättningen som sedan används för att generera konfigurationer för terminalen (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian och hela Omarchy-skalet (menyfält, meny, aviseringar, OSD och låsskärm).

Du kan också använda den medföljande Aether-applikationen för att skapa ett nytt tema med ett härligt GUI-gränssnitt för att leka med färger och söka efter bakgrunder. Starta den bara från apprutnätet på `Super + Alt + Space`.

### Vad ett installerat tema kan innehålla

Ett tema du skriver själv i `~/.config/omarchy/themes` kan innehålla vad du vill — det är din dator och din fil, och Omarchy tillämpar allt.

Ett tema du installerar från någon annans repo med `omarchy theme install` behåller allt som är färg, och förlorar det fåtal filer som skulle köra kod på din dator: alla `.lua`-filer, terminalkonfigurationerna (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) och `vscode.json`. Ett temas `hyprland.lua` är Lua som din kompositör kör vid inloggning, en terminalkonfiguration namnger programmet som din terminal startar, och `vscode.json` namnger ett VSCode-tillägg att installera. Att installera någons tema ska ändra hur ditt skrivbord ser ut, aldrig vad det kör.

Allt annat fungerar fortfarande exakt som temaförfattaren skrev det — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, bakgrunderna och förhandsgranskningarna behålls alla. Endast det som släppts återskapas från `colors.toml` på din dator.

Omarchy skiljer de två åt genom om temat har sitt eget git-repo inuti, vilket är vad `omarchy theme install` lämnar efter sig när det klonar. Så ett tema du skrev förblir ditt, och ett du hämtade från internet förblir färger.

### Ljust läge

Om du gör ett tema i ljust läge ställer du in `mode = "light"` högst upp i din `colors.toml`. Då paras det automatiskt ihop med ljust läge för alla apparna. (Det gamla sättet att släppa en tom fil med namnet `light.mode` i roten av ditt tema fungerar fortfarande också.)

### Ikonfärger

Om du vill färgmatcha filhanterarikonerna till ditt tema lägger du till en fil med namnet `icons.theme` med namnet på den ikonuppsättning du vill använda. Som standard är alternativen: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Bild för upplåsning

Teman som levereras med bilderna `unlock.png` och `preview-unlock.png` kommer att listas under _Stil > Lås upp_. Din `unlock.png` bör helst vara en transparent png. Och du kan skapa förhandsgranskningsbilden med `omarchy plymouth preview`.

### Tema för appar som Omarchy inte täcker

Om du använder en app som inte finns i den listan kan du själv lära Omarchy att ge den ett tema med en mall. Släpp en fil i `~/.config/omarchy/themed/` namngiven efter konfigurationen den genererar plus ett `.tpl`-tillägg, och skriv konfigurationen med `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` till `{{ color15 }}` och resten av paletten som platshållare. Varje gång du byter tema återskapas filen med det temat färger.

Det finns en fullständigt kommenterad `alacritty.toml.tpl.sample` i den mappen att kopiera från — den listar varje variabel du kan använda, plus modifierarna `_strip` och `_rgb` för appar som vill ha sina färger utan `#` eller som decimalt RGB. Dina mallar har företräde framför Omarchys egna, så du kan också använda detta för att åsidosätta hur en inbyggd app får sitt tema.

### Distribuera ditt tema

Om du vill distribuera ditt tema så att andra kan använda det måste du lägga det på en offentlig git-server, som GitHub. Då kan folk installera det via _Installera > Stil > Tema_ i Omarchy-menyn med den URL:en. Det rekommenderas att du följer namnkonventionen `omarchy-[themename]-theme`, eftersom temat kommer att visas korrekt som enbart `[themename]` i temavalmenyn efter installation.

Det överblivna `[themename]` blir temats katalogsnamn, så det måste vara ett som Omarchy kan skicka runt på ett säkert sätt: det måste börja med en bokstav, en siffra eller ett understreck, och resten får innehålla bokstäver, siffror, `.`, `_`, `+` och `-`. Versaler görs om till gemener åt dig, men allt annat — ett mellanslag, ett citattecken, ett icke-engelskt tecken — vägras vid installationstillfället snarare än att förvandlas till ett katalogsnamn. Så `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` och `omarchy-c++-theme` installeras alla fint.

Kom ihåg att när det väl är installerat från ett repo släpps alla `.lua`, terminalkonfigurationer eller `vscode.json` det levererar, så bygg inte temat kring dem.

Du kan få ditt tema tillagt på [sidan för extrateman](https://omarchy.org/themes/) genom att skicka en pull request till [repot omarchy-site](https://github.com/omacom-io/omarchy-site).
