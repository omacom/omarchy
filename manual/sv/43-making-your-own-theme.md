# Skapa ditt eget tema

Du kan lägga till dina egna teman i `~/.config/omarchy/themes`. Kopiera bara ett av de befintliga som grund (titta i `/usr/share/omarchy/themes`), och justera sedan tills du är nöjd. Så länge ditt tema ligger i den mappen kommer det med i menyn för temaval.

Huvudfilen du behöver justera är `colors.toml`. Den definierar färguppsättningen som sedan används för att generera konfigurationer för terminalen (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian och hela Omarchy-skalet (övre fältet, meny, aviseringar, OSD och låsskärm).

Du kan också använda den medföljande appen Aether för att skapa ett nytt tema med ett trevligt GUI-gränssnitt där du kan leka med färger och söka efter bakgrunder. Starta den bara från apprutnätet med `Super + Alt + Space`.

### Vad ett installerat tema kan innehålla

Ett tema du skriver själv i `~/.config/omarchy/themes` kan innehålla vad du vill — det är din maskin och din fil, och Omarchy tillämpar allt.

Ett tema du installerar från någon annans repo med `omarchy theme install` behåller allt som är färg, och förlorar den handfull filer som skulle köra kod på din maskin: alla `.lua`-filer, terminalkonfigurationerna (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) och `vscode.json`. Ett temas `hyprland.lua` är Lua som din compositor kör vid inloggning, en terminalkonfiguration anger programmet din terminal startar, och `vscode.json` anger ett VSCode-tillägg som ska installeras. Att installera någons tema ska ändra hur ditt skrivbord ser ut, aldrig vad det kör.

Allt annat fungerar fortfarande exakt som temats författare skrev det — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, bakgrunderna och förhandsvisningarna behålls alla. Bara det som togs bort återskapas från `colors.toml` på din maskin.

Omarchy skiljer de två åt genom om temat har sitt eget git-repo i sig, vilket är vad `omarchy theme install` lämnar efter sig när det klonar. Så ett tema du skrev förblir ditt, och ett du hämtade från internet förblir färger.

### Ljust läge

Om du gör ett tema med ljust läge ställer du in `mode = "light"` högst upp i din `colors.toml`. Då paras det automatiskt med ljust läge för alla appar. (Det gamla sättet att släppa en tom fil som heter `light.mode` i roten av ditt tema fungerar fortfarande också.)

### Ikonfärger

Om du vill färgmatcha filhanterarens ikoner med ditt tema lägger du till en fil som heter `icons.theme` med namnet på den ikonuppsättning du vill använda. Som standard är alternativen: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Upplåsningsbild

Teman som levereras med bilderna `unlock.png` och `preview-unlock.png` listas under _Utseende > Upplåsning_. Din `unlock.png` bör helst vara en genomskinlig png. Och du kan skapa förhandsvisningsbilden med `omarchy plymouth preview`.

### Tema för appar Omarchy inte täcker

Om du använder en app som inte finns i den listan kan du själv lära Omarchy att sätta tema på den med en mall. Släpp en fil i `~/.config/omarchy/themed/` uppkallad efter konfigurationen den genererar plus filändelsen `.tpl`, och skriv konfigurationen med `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` genom `{{ color15 }}`, och resten av paletten som platshållare. Varje gång du byter tema återskapas filen med det temats färger.

Det finns en fullständigt kommenterad `alacritty.toml.tpl.sample` i den mappen att kopiera från — den listar varje variabel du kan använda, plus modifierarna `_strip` och `_rgb` för appar som vill ha sina färger utan `#` eller som decimal RGB. Dina mallar har företräde framför Omarchys egna, så du kan också använda detta för att åsidosätta hur en inbyggd app får sitt tema.

### Distribuera ditt tema

Om du vill distribuera ditt tema så att andra kan använda det måste du lägga det på en offentlig git-server, som GitHub. Sedan kan folk installera det via _Installera > Stil > Tema_ i Omarchy-menyn med den URL:en. Det rekommenderas att du följer namngivningskonventionen `omarchy-[themename]-theme`, eftersom temat då visas korrekt som bara `[themename]` i menyn för temaval efter installationen.

Den återstående `[themename]` blir temats katalognamn, så det måste vara ett som Omarchy säkert kan hantera: det måste börja med en bokstav, en siffra eller ett understreck, och resten får innehålla bokstäver, siffror, `.`, `_`, `+` och `-`. Versaler omvandlas till gemener åt dig, men allt annat — ett mellanslag, ett citattecken, ett icke-engelskt tecken — avvisas vid installationen i stället för att förvandlas till ett katalognamn. Så `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` och `omarchy-c++-theme` installeras alla utan problem.

Kom ihåg att när det väl installerats från ett repo tas varje `.lua`, terminalkonfiguration eller `vscode.json` som det levereras med bort, så bygg inte temat kring dem.

Du kan få ditt tema tillagt på [sidan med extrateman](https://omarchy.org/themes/) genom att skicka en pull request till [omarchy-site-repot](https://github.com/omacom-io/omarchy-site).
