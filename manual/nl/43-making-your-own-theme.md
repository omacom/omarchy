# Je eigen thema maken

Je kunt je eigen thema's toevoegen aan `~/.config/omarchy/themes`. Kopieer gewoon een van de bestaande als basis (kijk in `/usr/share/omarchy/themes`) en pas het daarna naar hartenlust aan. Zolang je thema in die map staat, wordt het opgenomen in het menu voor themaselectie.

Het belangrijkste bestand dat je moet aanpassen, is `colors.toml`. Dat definieert de kleurenset die vervolgens wordt gebruikt om configuraties te genereren voor de terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian en de volledige Omarchy-shell (bovenbalk, menu, meldingen, OSD en vergrendelscherm).

Je kunt ook de meegeleverde Aether-applicatie gebruiken om een nieuw thema te maken met een mooie GUI-interface om met kleuren te spelen en naar achtergronden te zoeken. Start hem gewoon vanuit het app-raster met `Super + Alt + Space`.

### Wat een geïnstalleerd thema kan bevatten

Een thema dat je zelf schrijft in `~/.config/omarchy/themes` kan bevatten wat je maar wilt — het is jouw machine en jouw bestand, en Omarchy past alles toe.

Een thema dat je met `omarchy theme install` uit de repo van iemand anders installeert, behoudt alles wat kleur is en verliest het handjevol bestanden dat code op jouw machine zou uitvoeren: elk `.lua`-bestand, de terminalconfiguraties (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) en `vscode.json`. De `hyprland.lua` van een thema is Lua die je compositor uitvoert bij het inloggen, een terminalconfiguratie benoemt het programma dat je terminal start, en `vscode.json` benoemt een VSCode-extensie om te installeren. Het installeren van iemands thema moet veranderen hoe je bureaublad eruitziet, nooit wat het uitvoert.

Al het andere werkt nog precies zoals de auteur van het thema het heeft geschreven — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, de achtergronden en de previews blijven allemaal behouden. Alleen wat is weggelaten, wordt op jouw machine opnieuw gegenereerd uit `colors.toml`.

Omarchy onderscheidt de twee op basis van of het thema een eigen git-repo in zich heeft, wat `omarchy theme install` achterlaat wanneer het kloont. Dus een thema dat je zelf hebt geschreven blijft van jou, en een thema dat je van internet hebt gehaald blijft kleuren.

### Lichte modus

Als je een thema voor de lichte modus maakt, zet dan `mode = "light"` bovenaan je `colors.toml`. Dan wordt het automatisch gekoppeld aan de lichte modus voor alle apps. (De oude manier, een leeg bestand genaamd `light.mode` in de hoofdmap van je thema plaatsen, werkt ook nog.)

### Ontgrendelingsafbeelding

Thema's die worden geleverd met de afbeeldingen `unlock.png` en `preview-unlock.png` worden vermeld onder _Uiterlijk > Ontgrendelen_. Je `unlock.png` moet bij voorkeur een transparante png zijn. En je kunt de previewafbeelding maken met `omarchy plymouth preview`.

### Thema's toepassen op apps die Omarchy niet dekt

Als je een app gebruikt die niet in die lijst staat, kun je Omarchy zelf leren om die van een thema te voorzien met een template. Plaats een bestand in `~/.config/omarchy/themed/` dat is vernoemd naar de configuratie die het genereert plus een `.tpl`-extensie, en schrijf de configuratie met `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` tot en met `{{ color15 }}` en de rest van het palet als placeholders. Elke keer dat je van thema wisselt, wordt het bestand opnieuw gegenereerd met de kleuren van dat thema.

In die map staat een volledig van commentaar voorziene `alacritty.toml.tpl.sample` om van te kopiëren — die vermeldt elke variabele die je kunt gebruiken, plus de modifiers `_strip` en `_rgb` voor apps die hun kleuren zonder de `#` willen of als decimale RGB. Jouw templates hebben voorrang op die van Omarchy zelf, dus je kunt dit ook gebruiken om te overschrijven hoe een ingebouwde app van een thema wordt voorzien.

### Je thema verspreiden

Als je je thema wilt verspreiden zodat anderen het kunnen gebruiken, moet je het op een openbare git-server zetten, zoals GitHub. Vervolgens kunnen mensen het met die URL installeren via _Installeren > Stijl > Thema_ in het Omarchy-menu. Het wordt aanbevolen om de naamgevingsconventie `omarchy-[themename]-theme` te volgen, omdat het thema na installatie dan correct wordt weergegeven als alleen `[themename]` in het menu voor themaselectie.

Dat overgebleven `[themename]` wordt de mapnaam van het thema, dus het moet er een zijn die Omarchy veilig kan doorgeven: het moet beginnen met een letter, een cijfer of een underscore, en de rest mag letters, cijfers, `.`, `_`, `+` en `-` bevatten. Hoofdletters worden voor je omgezet naar kleine letters, maar al het andere — een spatie, een aanhalingsteken, een niet-Engels teken — wordt bij de installatie geweigerd in plaats van omgezet in een mapnaam. Dus `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` en `omarchy-c++-theme` installeren allemaal probleemloos.

Onthoud dat zodra het vanuit een repo is geïnstalleerd, elke meegeleverde `.lua`, terminalconfiguratie of `vscode.json` wordt weggelaten, dus bouw het thema daar niet omheen.

Je kunt je thema laten toevoegen aan [de pagina met extra thema's](https://omarchy.org/themes/) door een pull request te sturen naar [de omarchy-site-repo](https://github.com/omacom-io/omarchy-site).
