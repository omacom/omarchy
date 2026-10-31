# Je eigen thema maken

Je kunt je eigen thema's toevoegen aan `~/.config/omarchy/themes`. Kopieer gewoon een van de bestaande thema's als basis (kijk in `/usr/share/omarchy/themes`) en pas het daarna naar hartenlust aan. Zolang je thema in die map staat, wordt het opgenomen in het menu voor themaselectie.

Het belangrijkste bestand dat je moet aanpassen is `colors.toml`. Dat definieert de kleurenset die vervolgens wordt gebruikt om configuraties te genereren voor de terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian en de volledige Omarchy-shell (bovenbalk, menu, meldingen, OSD en vergrendelscherm).

Je kunt ook de meegeleverde applicatie Aether gebruiken om een nieuw thema te maken met een mooie GUI-interface om met kleuren te spelen en naar achtergronden te zoeken. Start hem gewoon vanuit het app-raster met `Super + Alt + Space`.

### Wat een geïnstalleerd thema kan bevatten

Een thema dat je zelf schrijft in `~/.config/omarchy/themes` kan bevatten wat je maar wilt — het is jouw machine en jouw bestand, en Omarchy past alles toe.

Een thema dat je installeert vanuit de repo van iemand anders met `omarchy theme install` behoudt alles wat kleur is, en verliest het handjevol bestanden dat code zou uitvoeren op jouw machine: elk `.lua`-bestand, de terminalconfiguraties (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) en `vscode.json`. De `hyprland.lua` van een thema is Lua die je compositor uitvoert bij het inloggen, een terminalconfiguratie benoemt het programma dat je terminal start, en `vscode.json` benoemt een VSCode-extensie om te installeren. Het installeren van iemands thema moet veranderen hoe je bureaublad eruitziet, nooit wat het uitvoert.

Al het andere werkt nog steeds precies zoals de auteur van het thema het heeft geschreven — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, de achtergronden en de previews blijven allemaal behouden. Alleen wat is weggelaten, wordt op jouw machine opnieuw gegenereerd vanuit `colors.toml`.

Omarchy onderscheidt de twee aan de hand van of het thema een eigen git-repo in zich heeft, wat `omarchy theme install` achterlaat wanneer het kloont. Dus een thema dat je zelf hebt geschreven blijft van jou, en een thema dat je van het internet hebt gehaald blijft kleuren.

### Lichte modus

Als je een thema in lichte modus maakt, zet dan `mode = "light"` bovenaan je `colors.toml`. Dan wordt het automatisch gekoppeld aan de lichte modus voor alle apps. (De oude manier, een leeg bestand met de naam `light.mode` in de hoofdmap van je thema plaatsen, werkt ook nog steeds.)

### Pictogramkleuren

Als je de pictogrammen van de bestandsbeheerder qua kleur wilt afstemmen op je thema, voeg dan een bestand toe met de naam `icons.theme` met de naam van de pictogrammenset die je wilt gebruiken. Standaard zijn de opties: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Ontgrendelingsafbeelding

Thema's die worden geleverd met `unlock.png`- en `preview-unlock.png`-afbeeldingen worden weergegeven onder _Weergave > Ontgrendelen_. Je `unlock.png` moet bij voorkeur een transparante png zijn. En je kunt de preview-afbeelding maken met `omarchy plymouth preview`.

### Thema toepassen op apps die Omarchy niet dekt

Als je een app gebruikt die niet in die lijst staat, kun je Omarchy zelf leren die te thematiseren met een sjabloon. Plaats een bestand in `~/.config/omarchy/themed/` met de naam van de configuratie die het genereert plus een `.tpl`-extensie, en schrijf de configuratie met `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` tot en met `{{ color15 }}` en de rest van het palet als placeholders. Elke keer dat je van thema wisselt, wordt het bestand opnieuw gegenereerd met de kleuren van dat thema.

In die map staat een volledig van commentaar voorzien `alacritty.toml.tpl.sample` om van te kopiëren — het vermeldt elke variabele die je kunt gebruiken, plus de modifiers `_strip` en `_rgb` voor apps die hun kleuren willen zonder de `#` of als decimale RGB. Je sjablonen hebben voorrang op die van Omarchy zelf, dus je kunt dit ook gebruiken om te overschrijven hoe een ingebouwde app wordt gethematiseerd.

### Je thema distribueren

Als je je thema wilt distribueren zodat anderen het kunnen gebruiken, moet je het op een openbare git-server zetten, zoals GitHub. Vervolgens kunnen mensen het installeren via _Installeren > Stijl > Thema_ in het Omarchy-menu met die URL. Het wordt aanbevolen dat je de naamgevingsconventie `omarchy-[themename]-theme` volgt, omdat het thema na installatie dan correct wordt weergegeven als alleen `[themename]` in het menu voor themaselectie.

Die overgebleven `[themename]` wordt de mapnaam van het thema, dus het moet er een zijn die Omarchy veilig kan doorgeven: het moet beginnen met een letter, een cijfer of een underscore, en de rest mag letters, cijfers, `.`, `_`, `+` en `-` bevatten. Hoofdletters worden voor je omgezet naar kleine letters, maar al het andere — een spatie, een aanhalingsteken, een niet-Engels teken — wordt bij de installatie geweigerd in plaats van te worden omgezet in een mapnaam. Dus `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` en `omarchy-c++-theme` installeren allemaal probleemloos.

Onthoud dat zodra het is geïnstalleerd vanuit een repo, elke `.lua`, terminalconfiguratie of `vscode.json` die het meelevert wordt weggelaten, dus bouw het thema niet rond die bestanden.

Je kunt je thema laten toevoegen aan [de pagina met extra thema's](https://omarchy.org/themes/) door een pull request te sturen naar [de omarchy-site-repo](https://github.com/omacom-io/omarchy-site).
