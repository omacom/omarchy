# Lage ditt eget tema

Du kan legge til dine egne temaer i `~/.config/omarchy/themes`. Bare kopier et av de eksisterende som utgangspunkt (se i `/usr/share/omarchy/themes`), og juster det så mye du har lyst til. Så lenge temaet ditt ligger i den mappen, tas det med i temavelgermenyen.

Hovedfilen du må justere er `colors.toml`. Den definerer fargesettet som deretter brukes til å generere konfigurasjoner for terminalen (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian og hele Omarchy-skallet (topplinjen, menyen, varslene, OSD-en og låseskjermen).

Du kan også bruke den medfølgende Aether-applikasjonen til å lage et nytt tema med et lekkert GUI-grensesnitt der du kan leke med farger og søke etter bakgrunner. Bare start den fra apprutenettet med `Super + Alt + Space`.

### Hva et installert tema kan inneholde

Et tema du skriver selv i `~/.config/omarchy/themes` kan inneholde hva du vil — det er din maskin og din fil, og Omarchy tar i bruk alt sammen.

Et tema du installerer fra repoet til noen andre med `omarchy theme install` beholder alt som er farge, og mister den lille håndfullen filer som ville kjørt kode på maskinen din: enhver `.lua`-fil, terminalkonfigurasjonene (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) og `vscode.json`. Et temas `hyprland.lua` er Lua som kompositoren din kjører ved pålogging, en terminalkonfigurasjon navngir programmet terminalen din starter, og `vscode.json` navngir en VSCode-utvidelse som skal installeres. Å installere temaet til noen bør endre hvordan skrivebordet ditt ser ut, aldri hva det kjører.

Alt annet fungerer fortsatt akkurat som temaforfatteren skrev det — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, bakgrunnene og forhåndsvisningene blir alle beholdt. Bare det som ble droppet, blir generert på nytt fra `colors.toml` på maskinen din.

Omarchy skiller de to fra hverandre ved om temaet har sitt eget git-repo inni seg, noe `omarchy theme install` etterlater seg når det kloner. Så et tema du skrev, forblir ditt, og et du hentet fra internett, forblir farger.

### Lys modus

Hvis du lager et tema med lys modus, setter du `mode = "light"` øverst i `colors.toml`. Da blir det automatisk paret med lys modus for alle appene. (Den gamle måten med å slippe en tom fil kalt `light.mode` i roten av temaet ditt, fungerer fortsatt også.)

### Opplåsingsbilde

Temaer som leveres med bildene `unlock.png` og `preview-unlock.png`, blir oppført under _Utseende > Lås opp_. `unlock.png`-filen din bør helst være en gjennomsiktig png. Og du kan lage forhåndsvisningsbildet med `omarchy plymouth preview`.

### Tema for apper Omarchy ikke dekker

Hvis du bruker en app som ikke står på den listen, kan du selv lære Omarchy å sette tema på den med en mal. Slipp en fil i `~/.config/omarchy/themed/` navngitt etter konfigurasjonen den genererer pluss filendelsen `.tpl`, og skriv konfigurasjonen med `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` til og med `{{ color15 }}`, og resten av paletten som plassholdere. Hver gang du bytter tema, blir filen generert på nytt med fargene til det temaet.

Det ligger en fullstendig kommentert `alacritty.toml.tpl.sample` i den mappen du kan kopiere fra — den viser hver variabel du kan bruke, pluss modifikatorene `_strip` og `_rgb` for apper som vil ha fargene sine uten `#` eller som desimal RGB. Malene dine går foran Omarchys egne, så du kan også bruke dette til å overstyre hvordan en innebygd app får tema.

### Distribuere temaet ditt

Hvis du vil distribuere temaet ditt så andre kan bruke det, må du legge det på en offentlig git-tjener, som GitHub. Da kan folk installere det via _Installer > Stil > Tema_ i Omarchy-menyen med den URL-en. Det anbefales at du følger navnekonvensjonen `omarchy-[themename]-theme`, siden temaet da vises korrekt som bare `[themename]` i temavelgermenyen etter installasjonen.

Den gjenværende `[themename]` blir katalognavnet til temaet, så det må være ett Omarchy kan sende rundt trygt: det må starte med en bokstav, et siffer eller en understrek, og resten kan inneholde bokstaver, sifre, `.`, `_`, `+` og `-`. Store bokstaver gjøres om til små for deg, men alt annet — et mellomrom, et anførselstegn, et ikke-engelsk tegn — avvises ved installasjonen i stedet for å bli gjort om til et katalognavn. Så `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` og `omarchy-c++-theme` installeres alle helt fint.

Husk at når det først er installert fra et repo, droppes enhver `.lua`, terminalkonfigurasjon eller `vscode.json` det leveres med, så ikke bygg temaet rundt dem.

Du kan få temaet ditt lagt til på [siden med ekstra temaer](https://omarchy.org/themes/) ved å sende en pull request til [omarchy-site-repoet](https://github.com/omacom-io/omarchy-site).
