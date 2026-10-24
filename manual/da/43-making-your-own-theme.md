# Lav dit eget tema

Du kan tilføje dine egne temaer til `~/.config/omarchy/themes`. Kopiér bare et af de eksisterende som base (se i `/usr/share/omarchy/themes`), og justér derefter til din fornøjelse. Så længe dit tema er inde i den mappe, vil det være inkluderet i temavælgermenuen.

Hovedfilen, du skal justere, er `colors.toml`. Den definerer farvesættet, som derefter bruges til at generere konfigurationer til terminalen (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian og hele Omarchy-shellen (menulinje, menu, notifikationer, OSD og låseskærm).

Du kan også bruge den medfølgende Aether-app til at oprette et nyt tema ved hjælp af en dejlig GUI-grænseflade til at lege med farver og søge efter baggrunde. Start den bare fra app-gitteret på `Super + Alt + Space`.

### Hvad et installeret tema kan indeholde

Et tema, du selv skriver i `~/.config/omarchy/themes`, kan indeholde, hvad du vil — det er din maskine og din fil, og Omarchy anvender det hele.

Et tema, du installerer fra en andens repo med `omarchy theme install`, beholder alt, hvad der er farve, og mister den håndfuld filer, der ville køre kode på din maskine: enhver `.lua`-fil, terminalkonfigurationerne (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) og `vscode.json`. Et temas `hyprland.lua` er Lua, din compositor kører ved login, en terminalkonfiguration navngiver programmet, din terminal starter, og `vscode.json` navngiver en VSCode-udvidelse, der skal installeres. At installere en andens tema bør ændre, hvordan dit skrivebord ser ud, aldrig hvad det kører.

Alt andet virker stadig præcis, som temaforfatteren skrev det — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, baggrundene og forhåndsvisningerne bevares alle. Kun det, der blev droppet, regenereres fra `colors.toml` på din maskine.

Omarchy skelner de to fra hinanden ved, om temaet har sit eget git-repo inde i sig, hvilket er det, `omarchy theme install` efterlader, når det kloner. Så et tema, du skrev, forbliver dit, og et, du hentede fra internettet, forbliver farver.

### Lys tilstand

Hvis du laver et tema med lys tilstand, skal du sætte `mode = "light"` øverst i din `colors.toml`. Så parres det automatisk med lys tilstand til alle apps. (Den gamle måde at droppe en tom fil ved navn `light.mode` i roden af dit tema virker også stadig.)

### Ikonfarver

Hvis du gerne vil farvematch filhåndteringsikonerne til dit tema, skal du tilføje en fil ved navn `icons.theme` med navnet på det ikonsæt, du vil bruge. Som standard er mulighederne: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Oplåsningsbillede

Temaer leveret med billederne `unlock.png` og `preview-unlock.png` vil blive listet under _Stil > Lås op_. Din `unlock.png` bør helst være en gennemsigtig png. Og du kan oprette forhåndsvisningsbilledet med `omarchy plymouth preview`.

### Tema til apps, Omarchy ikke dækker

Hvis du bruger en app, der ikke er på den liste, kan du lære Omarchy at tematisere den selv med en skabelon. Læg en fil i `~/.config/omarchy/themed/` navngivet efter den konfiguration, den genererer, plus en `.tpl`-endelse, og skriv konfigurationen med `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` til `{{ color15 }}` og resten af paletten som pladsholdere. Hver gang du skifter tema, regenereres filen med det temas farver.

Der er en fuldt kommenteret `alacritty.toml.tpl.sample` i den mappe at kopiere fra — den lister enhver variabel, du kan bruge, plus `_strip`- og `_rgb`-modifikatorerne til apps, der vil have deres farver uden `#` eller som decimal RGB. Dine skabeloner har prioritet over Omarchys egne, så du kan også bruge det til at tilsidesætte, hvordan en indbygget app tematiseres.

### Distribuér dit tema

Hvis du vil distribuere dit tema, så andre kan bruge det, skal du lægge det på en offentlig git-server som GitHub. Så kan folk installere det ved hjælp af _Installer > Stil > Tema_ i Omarchy-menuen ved hjælp af den URL. Det anbefales, at du følger navngivningskonventionen `omarchy-[themename]-theme`, da temaet vil vises korrekt som blot `[themename]` i temavælgermenuen efter installation.

Det resterende `[themename]` bliver temaets mappenavn, så det skal være et, Omarchy kan give rundt sikkert: det skal starte med et bogstav, et tal eller en underscore, og resten må indeholde bogstaver, tal, `.`, `_`, `+` og `-`. Store bogstaver gøres små for dig, men alt andet — et mellemrum, et anførselstegn, et ikke-engelsk tegn — afvises ved installationstidspunktet frem for at blive til et mappenavn. Så `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` og `omarchy-c++-theme` installerer alle fint.

Husk, at når det først er installeret fra et repo, droppes enhver `.lua`, terminalkonfiguration eller `vscode.json`, det leverer, så byg ikke temaet omkring dem.

Du kan få dit tema tilføjet til [siden med ekstra temaer](https://omarchy.org/themes/) ved at sende en pull request til [omarchy-site-repoen](https://github.com/omacom-io/omarchy-site).
