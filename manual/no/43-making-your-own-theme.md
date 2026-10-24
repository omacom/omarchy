# Lage ditt eget tema

Du kan legge til dine egne temaer i `~/.config/omarchy/themes`. Bare kopier ett av de eksisterende som grunnlag (se i `/usr/share/omarchy/themes`), og juster deretter til hjertens lyst. Så lenge temaet ditt er inne i den mappen, blir det inkludert i temavalgmenyen.

Hovedfilen du må justere er `colors.toml`. Den definerer fargesettet som deretter brukes til å generere konfigurasjoner for terminalen (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian og hele Omarchy-skallet (menylinje, meny, varsler, OSD og låseskjerm).

Du kan også bruke den inkluderte Aether-applikasjonen til å lage et nytt tema med et nydelig GUI-grensesnitt for å leke med farger og søke etter bakgrunner. Bare start den fra apprutenettet på `Super + Alt + Space`.

### Hva et installert tema kan inneholde

Et tema du skriver selv i `~/.config/omarchy/themes` kan inneholde hva du vil — det er din maskin og din fil, og Omarchy bruker alt sammen.

Et tema du installerer fra noen andres repo med `omarchy theme install` beholder alt som er farge, og mister det håndfull filer som ville kjørt kode på maskinen din: enhver `.lua`-fil, terminalkonfigurasjonene (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) og `vscode.json`. Et temas `hyprland.lua` er Lua som kompositoren din kjører ved pålogging, en terminalkonfigurasjon navngir programmet terminalen din starter, og `vscode.json` navngir en VSCode-utvidelse som skal installeres. Å installere noens tema skal endre hvordan skrivebordet ditt ser ut, aldri hva det kjører.

Alt annet fungerer fortsatt akkurat slik temaforfatteren skrev det — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, bakgrunnene og forhåndsvisningene beholdes alle. Bare det som ble droppet, genereres på nytt fra `colors.toml` på maskinen din.

Omarchy skiller de to fra hverandre ved om temaet har sitt eget git-repo inni seg, som er det `omarchy theme install` etterlater seg når det kloner. Så et tema du skrev, forblir ditt, og ett du hentet fra internett, forblir farger.

### Lys modus

Hvis du lager et tema i lys modus, sett `mode = "light"` øverst i `colors.toml`. Da pares det automatisk med lys modus for alle appene. (Den gamle måten med å slippe en tom fil kalt `light.mode` i roten av temaet ditt fungerer fortsatt også.)

### Ikonfarger

Hvis du vil fargetilpasse filbehandlerikonene til temaet ditt, legg til en fil kalt `icons.theme` med navnet på ikonsettet du vil bruke. Som standard er alternativene: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Opplåsingsbilde

Temaer levert med `unlock.png`- og `preview-unlock.png`-bilder vil bli listet under _Stil > Lås opp_. `unlock.png`-en din bør helst være en gjennomsiktig png. Og du kan lage forhåndsvisningsbildet med `omarchy plymouth preview`.

### Tematisere apper Omarchy ikke dekker

Hvis du bruker en app som ikke er på den listen, kan du lære Omarchy å tematisere den selv med en mal. Slipp en fil i `~/.config/omarchy/themed/` oppkalt etter konfigurasjonen den genererer pluss en `.tpl`-endelse, og skriv konfigurasjonen med `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` til `{{ color15 }}` og resten av paletten som plassholdere. Hver gang du bytter tema, genereres filen på nytt med det temaets farger.

Det finnes en fullt kommentert `alacritty.toml.tpl.sample` i den mappen å kopiere fra — den lister hver variabel du kan bruke, pluss `_strip`- og `_rgb`-modifikatorene for apper som vil ha fargene sine uten `#` eller som desimal RGB. Malene dine har forrang over Omarchys egne, så du kan også bruke dette til å overstyre hvordan en innebygd app tematiseres.

### Distribuere temaet ditt

Hvis du vil distribuere temaet ditt slik at andre kan bruke det, må du legge det på en offentlig git-server, som GitHub. Da kan folk installere det med _Installer > Stil > Tema_ i Omarchy-menyen med den URL-en. Det anbefales at du følger navnekonvensjonen `omarchy-[themename]-theme`, ettersom temaet vil vises riktig som bare `[themename]` i temavalgmenyen etter installasjon.

Den gjenværende `[themename]` blir temaets mappenavn, så det må være ett Omarchy kan håndtere trygt: det må begynne med en bokstav, et siffer eller en understrek, og resten kan inneholde bokstaver, sifre, `.`, `_`, `+` og `-`. Store bokstaver gjøres til små for deg, men alt annet — et mellomrom, et anførselstegn, et ikke-engelsk tegn — avvises ved installasjonstidspunktet i stedet for å bli gjort til et mappenavn. Så `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` og `omarchy-c++-theme` installeres alle fint.

Husk at når det først er installert fra et repo, droppes enhver `.lua`, terminalkonfigurasjon eller `vscode.json` det leveres med, så ikke bygg temaet rundt de.

Du kan få temaet ditt lagt til på [siden med ekstrabetemaer](https://omarchy.org/themes/) ved å sende en pull request til [omarchy-site-repoet](https://github.com/omacom-io/omarchy-site).
