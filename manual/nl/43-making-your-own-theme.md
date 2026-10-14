# Je eigen thema maken

Je kunt je eigen thema's toevoegen aan `~/.config/omarchy/themes`. Kopieer gewoon een van de bestaande als basis (kijk in `/usr/share/omarchy/themes`) en pas hem vervolgens naar hartenlust aan. Zolang je thema in die map staat, wordt het opgenomen in het themakeuzemenu.

Het belangrijkste bestand dat je moet aanpassen is `colors.toml`. Dat definieert de kleurenset die vervolgens wordt gebruikt om configuraties te genereren voor de terminal (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian en de volledige Omarchy-shell (bovenste balk, menu, meldingen, OSD en vergrendelscherm).

Je kunt ook de meegeleverde Aether-applicatie gebruiken om een nieuw thema te maken met een mooie GUI-interface om met kleuren te spelen en naar achtergronden te zoeken. Start hem gewoon vanuit het app-raster met `Super + Alt + Space`.

### Wat een geïnstalleerd thema kan bevatten

Een thema dat je zelf schrijft in `~/.config/omarchy/themes` kan bevatten wat je wilt — het is jouw machine en jouw bestand, en Omarchy past alles toe.

Een thema dat je installeert uit andermans repo met `omarchy theme install` behoudt alles wat kleur is, en verliest de handvol bestanden die code op je machine zouden uitvoeren: elk `.lua`-bestand, de terminalconfigs (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) en `vscode.json`. De `hyprland.lua` van een thema is Lua die je compositor uitvoert bij het inloggen, een terminalconfig benoemt het programma dat je terminal start, en `vscode.json` benoemt een te installeren VSCode-extensie. Het installeren van iemands thema moet veranderen hoe je bureaublad eruitziet, nooit wat het uitvoert.

Al het andere werkt nog steeds precies zoals de thema-auteur het schreef — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, de achtergronden en de previews blijven allemaal behouden. Alleen wat werd weggelaten wordt opnieuw gegenereerd uit `colors.toml` op je machine.

Omarchy onderscheidt de twee aan de hand van of het thema een eigen git-repo in zich heeft, wat `omarchy theme install` achterlaat als het kloont. Dus een thema dat je schreef blijft van jou, en een dat je van internet hebt gehaald blijft kleuren.

### Lichte modus

Als je een thema voor de lichte modus maakt, zet dan `mode = "light"` bovenaan je `colors.toml`. Dan wordt het automatisch gekoppeld aan de lichte modus voor alle apps. (De oude manier van een leeg bestand met de naam `light.mode` in de root van je thema zetten werkt ook nog steeds.)

### Pictogramkleuren

Als je de pictogrammen van de bestandsbeheerder qua kleur wilt afstemmen op je thema, voeg dan een bestand toe met de naam `icons.theme` met de naam van de pictogrammenset die je wilt gebruiken. Standaard zijn de opties: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Ontgrendelafbeelding

Thema's die worden geleverd met `unlock.png`- en `preview-unlock.png`-afbeeldingen worden vermeld onder _Stijl > Unlock_. Je `unlock.png` moet bij voorkeur een transparante png zijn. En je kunt de voorbeeldafbeelding maken met `omarchy plymouth preview`.

### Apps thematiseren die Omarchy niet dekt

Als je een app gebruikt die niet in die lijst staat, kun je Omarchy zelf leren hem te thematiseren met een sjabloon. Zet een bestand in `~/.config/omarchy/themed/` vernoemd naar de config die het genereert plus een `.tpl`-extensie, en schrijf de config met `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` tot en met `{{ color15 }}` en de rest van het palet als plaatsaanduidingen. Elke keer dat je van thema wisselt, wordt het bestand opnieuw gegenereerd met de kleuren van dat thema.

Er staat een volledig van commentaar voorziene `alacritty.toml.tpl.sample` in die map om van te kopiëren — die somt elke variabele op die je kunt gebruiken, plus de modifiers `_strip` en `_rgb` voor apps die hun kleuren zonder de `#` of als decimale RGB willen. Je sjablonen hebben voorrang op die van Omarchy zelf, dus je kunt dit ook gebruiken om te overschrijven hoe een ingebouwde app wordt gethematiseerd.

### Je thema verspreiden

Als je je thema wilt verspreiden zodat anderen het kunnen gebruiken, moet je het op een openbare git-server zetten, zoals GitHub. Dan kunnen mensen het installeren via _Installeren > Style > Theme_ in het Omarchy-menu met die URL. Het is aanbevolen dat je de naamgevingsconventie `omarchy-[themename]-theme` volgt, omdat het thema na installatie correct wordt getoond als gewoon `[themename]` in het themakeuzemenu.

Dat overgebleven `[themename]` wordt de mapnaam van het thema, dus het moet er een zijn die Omarchy veilig kan doorgeven: het moet beginnen met een letter, een cijfer of een underscore, en de rest mag letters, cijfers, `.`, `_`, `+` en `-` bevatten. Hoofdletters worden voor je omgezet naar kleine letters, maar al het andere — een spatie, een aanhalingsteken, een niet-Engels teken — wordt bij de installatie geweigerd in plaats van te worden omgezet in een mapnaam. Dus `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` en `omarchy-c++-theme` installeren allemaal prima.

Onthoud dat zodra het uit een repo is geïnstalleerd, elke `.lua`, terminalconfig of `vscode.json` die het meelevert wordt weggelaten, dus bouw het thema daar niet omheen.

Je kunt je thema laten toevoegen aan [de pagina met extra thema's](https://omarchy.org/themes/) door een pull request te sturen naar [de omarchy-site repo](https://github.com/omacom-io/omarchy-site).
