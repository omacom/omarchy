# Themen

Omarchy liefert zweiundzwanzig wunderschöne Themen mit. Du kannst über _Aussehen > Thema_ im Omarchy-Menü (`Super + Space`) zwischen ihnen wählen oder mit `Super + Ctrl + T` direkt zur Themenauswahl springen.

Jedes Thema gestaltet den Desktop, das Terminal, Neovim, den Aktivitätsbildschirm (btop), Chromium und die gesamte Omarchy-Shell: obere Leiste, Menü, Benachrichtigungen, OSD und den Sperrbildschirm. (Für Obsidian musst du das Omarchy-Thema manuell über _Aussehen > Themen_ in der App auswählen).

Themen bringen eine Reihe von Hintergrundbildern mit, zwischen denen du mit `Super + Ctrl + W` wählen kannst.

Noch mehr Themen findest du auf [der Seite mit zusätzlichen Themen](https://omarchy.org/themes/) oder du kannst sogar [dein eigenes Thema erstellen](43-making-your-own-theme.md).

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

### App-Symbole

Die Symbole im App-Launcher und im Dock werden in den Farben deines Themas gezeichnet, sie ändern sich also mit ihm. Sie stammen aus einem Symbolsatz, den du getrennt vom Thema unter _Aussehen > Symbole_ auswählst:

- _Papercraft_ ist die Voreinstellung: alles, was installiert mitkommt, in einem Stil gezeichnet. Apps, die man an ihrem Logo erkennt, wie Chrome, HEY oder YouTube, behalten ihre Form und übernehmen die Farben des Themas.
- _Arcade_ zeichnet dieselben Apps als 8-Bit-Pixelkunst, wie es eine alte Spielekonsole tun würde.
- _Original_ zeigt jede App mit dem Symbol, das ihr Hersteller ihr gegeben hat.

Du kannst einen Symbolsatz, den jemand anders erstellt hat, mit _Installieren > Stil > Symbole_ (oder `omarchy icons install <git url>`) installieren und ihn unter _Entfernen > Symbole_ wieder entfernen. _Aktualisieren > Zusätzliche Symbole_ holt die neueste Version der von dir installierten Sätze.

Um deinen eigenen zu erstellen, lege deine Symbole in `~/.config/omarchy/icons/<name>/` ab, eine Datei pro App, benannt nach der `Icon=`-Zeile der `.desktop`-Datei der App. Eine Datei, die auf `.svg` endet, wird so angezeigt, wie sie ist. Eine Datei, die auf `.svg.tpl` endet, wird in den Farben des Themas gezeichnet: Schreibe `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` oder `{{ icon_shadow }}` dorthin, wo eine Farbe hingehört. Der Standardsatz in `/usr/share/omarchy/icons/papercraft/` ist ein guter Ausgangspunkt. Um ein einzelnes Symbol des Standardsatzes zu ändern, lege deine Version in `~/.config/omarchy/icons/papercraft/` ab.

### Entsperr-Designs

Themen können auch ein eigenes Entsperr-Design haben, das für den Entschlüsselungsvorgang beim Booten verwendet wird. Du kannst eines davon unter _Aussehen > Entsperren_ auswählen. Sie sehen so aus:

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

 ![lumon](../themes/lumon/preview-unlock.png)
_Lumon_

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

 ![tokyo-night](../themes/tokyo-night/preview-unlock.png)
_Tokyo Night_

 ![vantablack](../themes/vantablack/preview-unlock.png)
_Vantablack_

 ![white](../themes/white/preview-unlock.png)
_White_
