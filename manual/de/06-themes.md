# Themes

Omarchy wird mit dreiundzwanzig wunderschönen Themes ausgeliefert. Du kannst über _Appearance > Theme_ im Omarchy Menu (`Super + Space`) zwischen ihnen wählen oder mit `Super + Ctrl + T` direkt zur Theme-Auswahl springen.

Jedes Theme gestaltet den Desktop, das Terminal, Neovim, den Aktivitätsbildschirm (btop), deinen Browser (Chrome, Chromium, Edge oder Brave) und die gesamte Omarchy-Shell: obere Leiste, Menü, Benachrichtigungen, OSD und den Sperrbildschirm. (Für Obsidian musst du das Omarchy-Theme in der App manuell über _Appearance > Themes_ auswählen).

Themes verfügen über eine Reihe von Hintergrundbildern, zwischen denen du mit `Super + Ctrl + W` wählen kannst.

Noch mehr Themes findest du auf [der Seite mit weiteren Themes](https://omarchy.org/themes/) oder du kannst sogar [dein eigenes Theme erstellen](43-making-your-own-theme.md).

 ![tokyo-night](../themes/tokyo-night/preview.png)
_Tokyo Night_

 ![catppuccin](../themes/catppuccin/preview.png)
_Catppuccin_

 ![lumon](../themes/lumon/preview.png)
_Lumon_

 ![ethereal](../themes/ethereal/preview.png)
_Ethereal_

 ![everforest](../themes/everforest/preview.png)
_Everforest_

 ![gruvbox](../themes/gruvbox/preview.png)
_Gruvbox_

 ![miasma](../themes/miasma/preview.png)
_Miasma_

 ![hackerman](../themes/hackerman/preview.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview.png)
_Kanagawa_

 ![nord](../themes/nord/preview.png)
_Nord_

 ![matte-black](../themes/matte-black/preview.png)
_Matte Black_

 ![vantablack](../themes/vantablack/preview.png)
_Vantablack_

 ![ristretto](../themes/ristretto/preview.png)
_Ristretto_

 ![retro-82](../themes/retro-82/preview.png)
_Retro 82_

 ![flexoki-light](../themes/flexoki-light/preview.png)
_Flexoki Light_

 ![rose-pine](../themes/rose-pine/preview.png)
_Rose Pine_

 ![catppuccin-latte](../themes/catppuccin-latte/preview.png)
_Catppuccin Latte_

 ![white](../themes/white/preview.png)
_White_

 ![last-horizon](../themes/last-horizon/preview.png)
_Last Horizon_

 ![lupine](../themes/lupine/preview.png)
_Lupine_

 ![solitude](../themes/solitude/preview.png)
_Solitude_

 ![starship](../themes/starship/preview.png)
_Starship_

### App-Icons

Die Icons im App-Launcher und im Dock sind in den Farben deines Themes gezeichnet, sodass sie sich zusammen mit ihm ändern. Sie stammen aus einem Icon-Set, das du getrennt vom Theme unter _Appearance > Icons_ aus Vorschauen der einzelnen Sets auswählst, auf dieselbe Weise, wie du ein Theme auswählst:

- _Papercraft_ ist der Standard: alles, was installiert mitgeliefert wird, in einem einheitlichen Stil gezeichnet. Apps, die man an ihrem Logo erkennt, wie Chrome, HEY oder YouTube, behalten dessen Form und nehmen die Farben des Themes an.
- _Arcade_ zeichnet dieselben Apps als 8-Bit-Pixelkunst, wie es eine alte Spielekonsole tun würde.
- _Original_ zeigt jede App mit dem Icon, das ihr Schöpfer ihr gegeben hat.

Du kannst ein Icon-Set, das jemand anderes erstellt hat, mit _Install > Style > Icons_ installieren (oder mit `omarchy icons install <git url>`) und es unter _Remove > Icons_ wieder entfernen. _Update > Extra Icons_ lädt die neueste Version der von dir installierten Sets herunter.

Um dein eigenes zu erstellen, lege deine Icons in `~/.config/omarchy/icons/<name>/` ab, eine Datei pro App, benannt nach der `Icon=`-Zeile der `.desktop`-Datei der App. Eine Datei, die auf `.svg` endet, wird so angezeigt, wie sie ist. Eine Datei, die auf `.svg.tpl` endet, wird in den Farben des Themes gezeichnet: Schreibe `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` oder `{{ icon_shadow }}` dorthin, wo eine Farbe hingehört. Das Standard-Set in `/usr/share/omarchy/icons/papercraft/` ist ein guter Ausgangspunkt. Füge eine `preview.png` hinzu, um dein Set in der Auswahl anzuzeigen; ohne eine solche Datei zeichnet Omarchy eine Vorschau aus deinen Icons. Um ein einzelnes Icon des Standard-Sets zu ändern, lege deine Version in `~/.config/omarchy/icons/papercraft/` ab.

### Entsperr-Designs

Themes können auch ein eigenes Entsperr-Design haben, das für die Entschlüsselung beim Booten verwendet wird. Du kannst eines davon unter _Appearance > Unlock_ auswählen. Sie sehen so aus:

 ![catppuccin](../themes/catppuccin/preview-unlock.png)
_Catppuccin_

 ![catppuccin-latte](../themes/catppuccin-latte/preview-unlock.png)
_Catppuccin Latte_

 ![ethereal](../themes/ethereal/preview-unlock.png)
_Ethereal_

 ![everforest](../themes/everforest/preview-unlock.png)
_Everforest_

 ![flexoki-light](../themes/flexoki-light/preview-unlock.png)
_Flexoki Light_

 ![gruvbox](../themes/gruvbox/preview-unlock.png)
_Gruvbox_

 ![hackerman](../themes/hackerman/preview-unlock.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview-unlock.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview-unlock.png)
_Kanagawa_

 ![last-horizon](../themes/last-horizon/preview-unlock.png)
_Last Horizon_

 ![lumon](../themes/lumon/preview-unlock.png)
_Lumon_

 ![lupine](../themes/lupine/preview-unlock.png)
_Lupine_

 ![matte-black](../themes/matte-black/preview-unlock.png)
_Matte Black_

![miasma](../themes/miasma/preview-unlock.png)
_Miasma_

 ![nord](../themes/nord/preview-unlock.png)
_Nord_

 ![retro-82](../themes/retro-82/preview-unlock.png)
_Retro 82_

 ![ristretto](../themes/ristretto/preview-unlock.png)
_Ristretto_

![rose-pine](../themes/rose-pine/preview-unlock.png)
_Rose Pine_

 ![solitude](../themes/solitude/preview-unlock.png)
_Solitude_

 ![tokyo-night](../themes/tokyo-night/preview-unlock.png)
_Tokyo Night_

 ![vantablack](../themes/vantablack/preview-unlock.png)
_Vantablack_

 ![white](../themes/white/preview-unlock.png)
_White_
