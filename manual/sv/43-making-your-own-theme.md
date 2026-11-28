# Skapa ditt eget tema

Du kan lägga till dina egna teman i `~/.config/omarchy/themes`. Kopiera bara ett av de befintliga som bas (titta i `/usr/share/omarchy/themes`) och justera sedan efter hjärtans lust. Så länge ditt tema ligger i den mappen kommer det med i menyn för temaval.

Huvudfilen du behöver justera är `colors.toml`. Den definierar färguppsättningen som sedan används för att generera konfigurationer för terminalen (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, Qt-appar, tangentbordets bakgrundsbelysning, inmatningsmetoden, väljaren för skärmdelning, appikonerna, flera AI-verktyg (Claude, Pi, Hermes, T3 Code, Herdr) och hela Omarchy-skalet (övre fältet, menyn, aviseringar, OSD och låsskärmen).

Du kan också använda den medföljande appen Aether för att skapa ett nytt tema med ett trevligt GUI-gränssnitt där du kan leka med färger och söka efter bakgrunder. Starta den bara från apprutnätet med `Super + Alt + Space`.

### Vad ett installerat tema kan innehålla

Ett tema du skriver själv i `~/.config/omarchy/themes` kan innehålla vad du vill — det är din dator och din fil, och Omarchy tillämpar allt.

Ett tema du installerar från någon annans repo med `omarchy theme install` behåller allt som är färg och förlorar den handfull filer som skulle köra kod på din dator: alla `.lua`-filer, terminalkonfigurationerna (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) och `vscode.json`. Ett temas `hyprland.lua` är Lua som din compositor kör vid inloggning, en terminalkonfiguration anger vilket program din terminal startar, och `vscode.json` anger ett VSCode-tillägg som ska installeras. Att installera någons tema ska ändra hur ditt skrivbord ser ut, aldrig vad det kör.

Allt annat fungerar fortfarande exakt som temaförfattaren skrev det — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, bakgrunderna och förhandsvisningarna behålls alla. Bara det som togs bort genereras på nytt från `colors.toml` på din dator.

Omarchy skiljer de två åt genom att se om temat har ett eget git-repo i sig, vilket är det `omarchy theme install` lämnar efter sig när det klonar. Så ett tema du skrev förblir ditt, och ett du hämtade från internet förblir färger.

### Ljust läge

Om du gör ett tema med ljust läge ställer du in `mode = "light"` överst i din `colors.toml`. Då paras det automatiskt ihop med ljust läge för alla appar. (Det gamla sättet att släppa en tom fil med namnet `light.mode` i roten av ditt tema fungerar fortfarande också.)

### Upplåsningsbild

Teman som levereras med bilderna `unlock.png` och `preview-unlock.png` kommer att listas under _Utseende > Lås upp_. Din `unlock.png` ska helst vara en transparent png. Och du kan skapa förhandsvisningsbilden med `omarchy plymouth preview`.

### Sätta tema på appar som Omarchy inte täcker

Om du använder en app som inte finns i den listan kan du själv lära Omarchy att sätta tema på den med en mall. Släpp en fil i `~/.config/omarchy/themed/` med samma namn som konfigurationen den genererar plus filändelsen `.tpl`, och skriv konfigurationen med `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` till `{{ color15 }}` och resten av paletten som platshållare. Varje gång du byter tema genereras filen på nytt med det temats färger.

Det finns en fullt kommenterad `alacritty.toml.tpl.sample` i den mappen att kopiera från — den listar alla variabler du kan använda, plus modifierarna `_strip` och `_rgb` för appar som vill ha sina färger utan `#` eller som decimal RGB. Dina mallar har företräde framför Omarchys egna, så du kan också använda detta för att åsidosätta hur en inbyggd app får sitt tema.

### Distribuera ditt tema

Om du vill distribuera ditt tema så att andra kan använda det måste du lägga det på en offentlig git-server, som GitHub. Sedan kan folk installera det via _Installera > Stil > Tema_ i Omarchy-menyn med den URL:en. Det rekommenderas att du följer namnkonventionen `omarchy-[themename]-theme`, eftersom temat då visas korrekt som bara `[themename]` i menyn för temaval efter installationen.

Den kvarvarande delen `[themename]` blir temats katalognamn, så det måste vara ett som Omarchy säkert kan hantera: det måste börja med en bokstav, en siffra eller ett understreck, och resten får innehålla bokstäver, siffror, `.`, `_`, `+` och `-`. Versaler omvandlas till gemener åt dig, men allt annat — ett mellanslag, ett citattecken, ett icke-engelskt tecken — avvisas vid installationen i stället för att förvandlas till ett katalognamn. Så `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` och `omarchy-c++-theme` installeras alla utan problem.

Kom ihåg att när det väl har installerats från ett repo tas alla `.lua`-filer, terminalkonfigurationer eller `vscode.json` som det levereras med bort, så bygg inte temat kring dem.

Du kan få ditt tema tillagt på [sidan med extra teman](https://omarchy.org/themes/) genom att skicka en pull request till [repot omarchy-site](https://github.com/omacom-io/omarchy-site).
