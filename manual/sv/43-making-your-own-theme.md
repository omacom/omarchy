# Skapa ditt eget tema

Du kan lägga till dina egna teman i `~/.config/omarchy/themes`. Kopiera bara ett av de befintliga som bas (titta i `/usr/share/omarchy/themes`) och justera det sedan precis som du vill. Så länge ditt tema ligger i den mappen kommer det att finnas med i menyn för temaval.

Huvudfilen du behöver justera är `colors.toml`. Den definierar färguppsättningen som sedan används för att generera konfigurationer för terminalen (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, Qt-appar, tangentbordets bakgrundsbelysning, inmatningsmetoden, väljaren för skärmdelning, appikonerna, flera AI-verktyg (Claude, Pi, Hermes, T3 Code, Herdr) och hela Omarchy-skalet (toppfältet, menyn, aviseringar, OSD och låsskärmen).

Du kan också använda den medföljande appen Aether för att skapa ett nytt tema med ett härligt GUI-gränssnitt där du kan leka med färger och söka efter bakgrunder. Starta den bara från apprutnätet med `Super + Alt + Space`.

### Vad ett installerat tema kan innehålla

Ett tema du skriver själv i `~/.config/omarchy/themes` kan innehålla vad du vill — det är din maskin och din fil, och Omarchy tillämpar allt.

Ett tema du installerar från någon annans repo med `omarchy theme install` behåller allt som är färg och förlorar den handfull filer som skulle köra kod på din maskin: alla `.lua`-filer, terminalkonfigurationerna (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) och `vscode.json`. Ett temas `hyprland.lua` är Lua som din compositor kör vid inloggning, en terminalkonfiguration anger vilket program din terminal startar och `vscode.json` anger ett VSCode-tillägg som ska installeras. Att installera någon annans tema ska ändra hur ditt skrivbord ser ut, aldrig vad det kör.

Allt annat fungerar fortfarande precis som temats upphovsperson skrev det — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, bakgrunderna och förhandsvisningarna behålls alla. Bara det som togs bort återskapas från `colors.toml` på din maskin.

Omarchy skiljer de två åt genom att kontrollera om temat har ett eget git-repo i sig, vilket är vad `omarchy theme install` lämnar efter sig när det klonar. Så ett tema du har skrivit förblir ditt, och ett tema du hämtade från internet förblir färger.

### Ljust läge

Om du gör ett tema med ljust läge anger du `mode = "light"` högst upp i din `colors.toml`. Då paras det automatiskt ihop med ljust läge för alla appar. (Det gamla sättet att lägga en tom fil med namnet `light.mode` i roten av ditt tema fungerar fortfarande också.)

### Uppstarts- och inloggningsskärmar

Skärmen som frågar efter diskens lösenord vid uppstart och inloggningsskärmen ritar Omarchy-logotypen i ditt temas `accent`-färg på dess `background`, med lösenordsfältet i dess `foreground` och `red` för ett felaktigt lösenord. Det finns inget extra att skicka med för dem: Omarchy använder inte längre ett temas `unlock.png` eller `preview-unlock.png`. På Mac-datorer med Apple Silicon behåller skärmen för diskens lösenord Omarchys standardutseende oavsett tema.

### Tillämpa teman på appar som Omarchy inte täcker

Om du använder en app som inte finns med i den listan kan du själv lära Omarchy att tillämpa teman på den med en mall. Lägg en fil i `~/.config/omarchy/themed/` med samma namn som konfigurationen den genererar plus filändelsen `.tpl`, och skriv konfigurationen med `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` till och med `{{ color15 }}` och resten av paletten som platshållare. Varje gång du byter tema återskapas filen med det temats färger.

Det finns en fullständigt kommenterad `alacritty.toml.tpl.sample` i den mappen att kopiera från — den listar alla variabler du kan använda, plus modifierarna `_strip` och `_rgb` för appar som vill ha sina färger utan `#` eller som decimal RGB. Dina mallar har företräde framför Omarchys egna, så du kan också använda detta för att åsidosätta hur en inbyggd app får sitt tema.

### Distribuera ditt tema

Om du vill distribuera ditt tema så att andra kan använda det måste du lägga det på en offentlig git-server, som GitHub. Sedan kan folk installera det via _Installera > Stil > Tema_ i Omarchy-menyn med hjälp av den URL:en. Det rekommenderas att du följer namngivningskonventionen `omarchy-[themename]-theme`, eftersom temat då visas korrekt som bara `[themename]` i menyn för temaval efter installationen.

Den återstående delen `[themename]` blir temats katalognamn, så den måste vara ett namn som Omarchy kan hantera säkert: det måste börja med en bokstav, en siffra eller ett understreck, och resten får innehålla bokstäver, siffror, `.`, `_`, `+` och `-`. Versaler omvandlas till gemener åt dig, men allt annat — ett mellanslag, ett citattecken, ett icke-engelskt tecken — avvisas vid installationen i stället för att förvandlas till ett katalognamn. Så `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` och `omarchy-c++-theme` installeras alla utan problem.

Kom ihåg att när det väl har installerats från ett repo tas alla `.lua`-filer, terminalkonfigurationer eller `vscode.json` som det innehåller bort, så bygg inte temat kring dem.

Du kan få ditt tema tillagt på [sidan med extra teman](https://omarchy.org/themes/) genom att skicka en pull request till [omarchy-site-repot](https://github.com/omacom-io/omarchy-site).
