# Lag ditt eget tema

Du kan legge til dine egne temaer i `~/.config/omarchy/themes`. Bare kopier ett av de eksisterende temaene som utgangspunkt (se i `/usr/share/omarchy/themes`), og tilpass det deretter akkurat slik du vil. Så lenge temaet ditt ligger i den mappen, blir det med i menyen for temavalg.

Hovedfilen du må endre, er `colors.toml`. Den definerer fargesettet som deretter brukes til å generere konfigurasjoner for terminalen (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian og hele Omarchy-skallet (topplinje, meny, varsler, OSD og låseskjerm).

Du kan også bruke den medfølgende Aether-applikasjonen til å lage et nytt tema med et nydelig GUI-grensesnitt der du kan leke med farger og søke etter bakgrunner. Bare start den fra appoversikten med `Super + Alt + Space`.

### Hva et installert tema kan inneholde

Et tema du skriver selv i `~/.config/omarchy/themes`, kan inneholde akkurat hva du vil — det er din maskin og din fil, og Omarchy bruker alt sammen.

Et tema du installerer fra repoet til noen andre med `omarchy theme install`, beholder alt som er farger, og mister den håndfullen filer som ville kjørt kode på maskinen din: alle `.lua`-filer, terminalkonfigurasjonene (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) og `vscode.json`. Et temas `hyprland.lua` er Lua som kompositoren din kjører ved innlogging, en terminalkonfigurasjon navngir programmet terminalen din starter, og `vscode.json` navngir en VSCode-utvidelse som skal installeres. Å installere temaet til noen andre skal endre hvordan skrivebordet ditt ser ut, aldri hva det kjører.

Alt annet fungerer fortsatt akkurat slik temaforfatteren skrev det — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, bakgrunnene og forhåndsvisningene blir alle beholdt. Bare det som ble fjernet, blir generert på nytt fra `colors.toml` på maskinen din.

Omarchy skiller de to fra hverandre ved å se om temaet har sitt eget git-repo inni seg, noe som er det `omarchy theme install` etterlater seg når det kloner. Så et tema du skrev, forblir ditt, og et tema du hentet fra internett, forblir farger.

### Lys modus

Hvis du lager et tema med lys modus, setter du `mode = "light"` øverst i `colors.toml`. Da blir det automatisk paret med lys modus for alle appene. (Den gamle måten, å legge en tom fil kalt `light.mode` i roten av temaet ditt, fungerer fortsatt også.)

### Ikonfarger

Hvis du vil fargetilpasse ikonene i filbehandleren til temaet ditt, legger du til en fil kalt `icons.theme` med navnet på ikonsettet du vil bruke. Som standard er alternativene: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Opplåsingsbilde

Temaer som leveres med bildene `unlock.png` og `preview-unlock.png`, blir listet under _Appearance > Unlock_. `unlock.png`-filen din bør helst være en gjennomsiktig png. Og du kan lage forhåndsvisningsbildet med `omarchy plymouth preview`.

### Tematisering av apper Omarchy ikke dekker

Hvis du bruker en app som ikke er på den listen, kan du lære Omarchy å tematisere den selv med en mal. Legg en fil i `~/.config/omarchy/themed/` oppkalt etter konfigurasjonen den genererer pluss endelsen `.tpl`, og skriv konfigurasjonen med `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` til `{{ color15 }}` og resten av paletten som plassholdere. Hver gang du bytter tema, genereres filen på nytt med fargene fra det temaet.

Det ligger en fullstendig kommentert `alacritty.toml.tpl.sample` i den mappen som du kan kopiere fra — den lister alle variabler du kan bruke, pluss modifikatorene `_strip` og `_rgb` for apper som vil ha fargene sine uten `#` eller som desimal RGB. Malene dine har prioritet over Omarchys egne, så du kan også bruke dette til å overstyre hvordan en innebygd app tematiseres.

### Distribuere temaet ditt

Hvis du vil distribuere temaet ditt slik at andre kan bruke det, må du legge det på en offentlig git-server, som GitHub. Da kan folk installere det via _Install > Style > Theme_ i Omarchy-menyen ved å bruke den URL-en. Det anbefales at du følger navnekonvensjonen `omarchy-[themename]-theme`, ettersom temaet da vises riktig som bare `[themename]` i menyen for temavalg etter installasjon.

Den gjenværende `[themename]`-delen blir temaets katalognavn, så det må være et navn Omarchy kan håndtere trygt: det må starte med en bokstav, et siffer eller en understrek, og resten kan inneholde bokstaver, sifre, `.`, `_`, `+` og `-`. Store bokstaver gjøres om til små for deg, men alt annet — et mellomrom, et anførselstegn, et ikke-engelsk tegn — avvises ved installasjon i stedet for å bli gjort om til et katalognavn. Så `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` og `omarchy-c++-theme` installeres alle uten problemer.

Husk at når det først er installert fra et repo, blir alle `.lua`-filer, terminalkonfigurasjoner eller `vscode.json` det leveres med, fjernet, så ikke bygg temaet rundt dem.

Du kan få temaet ditt lagt til på [siden med ekstra temaer](https://omarchy.org/themes/) ved å sende en pull request til [omarchy-site-repoet](https://github.com/omacom-io/omarchy-site).
