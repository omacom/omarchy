# Lav dit eget tema

Du kan tilføje dine egne temaer i `~/.config/omarchy/themes`. Kopiér bare et af de eksisterende som udgangspunkt (se i `/usr/share/omarchy/themes`), og tilpas det derefter, som du har lyst. Så længe dit tema ligger i den mappe, bliver det inkluderet i menuen til valg af tema.

Den vigtigste fil, du skal tilpasse, er `colors.toml`. Den definerer det farvesæt, der derefter bruges til at generere konfigurationer til terminalen (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian og hele Omarchy-skallen (øverste bjælke, menu, notifikationer, OSD og låseskærm).

Du kan også bruge det medfølgende Aether-program til at oprette et nyt tema i en dejlig GUI-grænseflade, hvor du kan lege med farver og søge efter baggrunde. Start det bare fra app-oversigten med `Super + Alt + Space`.

### Hvad et installeret tema kan indeholde

Et tema, du selv skriver i `~/.config/omarchy/themes`, kan indeholde, hvad du vil — det er din maskine og din fil, og Omarchy anvender det hele.

Et tema, du installerer fra en andens repo med `omarchy theme install`, beholder alt det, der er farve, og mister den lille håndfuld filer, der ville køre kode på din maskine: enhver `.lua`-fil, terminalkonfigurationerne (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) og `vscode.json`. Et temas `hyprland.lua` er Lua, som din compositor kører ved login, en terminalkonfiguration angiver det program, din terminal starter, og `vscode.json` angiver en VSCode-udvidelse, der skal installeres. Når du installerer en andens tema, skal det ændre, hvordan dit skrivebord ser ud, aldrig hvad det kører.

Alt andet fungerer stadig præcis, som temaets forfatter skrev det — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, baggrundene og forhåndsvisningerne bliver alle beholdt. Kun det, der blev fjernet, bliver regenereret ud fra `colors.toml` på din maskine.

Omarchy skelner mellem de to ved, om temaet har sit eget git-repo i sig, hvilket er det, `omarchy theme install` efterlader, når det kloner. Så et tema, du selv har skrevet, forbliver dit, og et, du har hentet fra internettet, forbliver farver.

### Lys tilstand

Hvis du laver et tema med lys tilstand, skal du sætte `mode = "light"` øverst i din `colors.toml`. Så bliver det automatisk parret med lys tilstand for alle apps. (Den gamle måde med at lægge en tom fil ved navn `light.mode` i roden af dit tema virker stadig også.)

### Oplåsningsbillede

Temaer, der leveres med billederne `unlock.png` og `preview-unlock.png`, bliver vist under _Udseende > Lås op_. Din `unlock.png` bør helst være en gennemsigtig png. Og du kan oprette forhåndsvisningsbilledet med `omarchy plymouth preview`.

### Tema til apps, som Omarchy ikke dækker

Hvis du bruger en app, der ikke er på den liste, kan du selv lære Omarchy at give den et tema med en skabelon. Læg en fil i `~/.config/omarchy/themed/` opkaldt efter den konfiguration, den genererer, plus endelsen `.tpl`, og skriv konfigurationen med `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` til og med `{{ color15 }}` og resten af paletten som pladsholdere. Hver gang du skifter tema, bliver filen regenereret med det temas farver.

Der ligger en fuldt kommenteret `alacritty.toml.tpl.sample` i den mappe, som du kan kopiere fra — den viser alle de variabler, du kan bruge, plus modifikatorerne `_strip` og `_rgb` til apps, der vil have deres farver uden `#` eller som decimale RGB-værdier. Dine skabeloner har forrang frem for Omarchys egne, så du kan også bruge dette til at tilsidesætte, hvordan en indbygget app får tema.

### Distribution af dit tema

Hvis du vil distribuere dit tema, så andre kan bruge det, skal du lægge det på en offentlig git-server, som GitHub. Derefter kan folk installere det via _Installér > Stil > Tema_ i Omarchy-menuen ved hjælp af den URL. Det anbefales, at du følger navngivningskonventionen `omarchy-[themename]-theme`, da temaet så korrekt bliver vist som bare `[themename]` i menuen til valg af tema efter installationen.

Det resterende `[themename]` bliver temaets mappenavn, så det skal være et, som Omarchy sikkert kan sende rundt: Det skal starte med et bogstav, et ciffer eller en understreg, og resten må indeholde bogstaver, cifre, `.`, `_`, `+` og `-`. Store bogstaver bliver gjort til små for dig, men alt andet — et mellemrum, et anførselstegn, et ikke-engelsk tegn — bliver afvist ved installationen i stedet for at blive gjort til et mappenavn. Så `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` og `omarchy-c++-theme` kan alle installeres uden problemer.

Husk, at når det er installeret fra et repo, bliver enhver `.lua`, terminalkonfiguration eller `vscode.json`, som det leveres med, fjernet, så byg ikke temaet op omkring dem.

Du kan få dit tema føjet til [siden med ekstra temaer](https://omarchy.org/themes/) ved at sende en pull request til [omarchy-site-repoet](https://github.com/omacom-io/omarchy-site).
