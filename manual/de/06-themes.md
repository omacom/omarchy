# Themes

Omarchy wird mit dreiundzwanzig wunderschönen Themes ausgeliefert. Du kannst über _Erscheinungsbild > Theme_ im Omarchy-Menü (`Super + Space`) zwischen ihnen wählen oder mit `Super + Ctrl + T` direkt zur Theme-Auswahl springen.

Jedes Theme gestaltet den Desktop, das Terminal, Neovim, den Aktivitätsbildschirm (btop), deinen Browser (Chrome, Chromium, Edge oder Brave) und die gesamte Omarchy-Shell: obere Leiste, Menü, Benachrichtigungen, OSD und den Sperrbildschirm. (Für Obsidian musst du das Omarchy-Theme manuell über _Erscheinungsbild > Themes_ in der App auswählen).

Themes haben einen Satz Hintergrundbilder, zwischen denen du mit `Super + Ctrl + W` wählen kannst.

Noch mehr Themes findest du auf [der Seite mit zusätzlichen Themes](https://omarchy.org/themes/) oder du kannst sogar [dein eigenes Theme erstellen](43-making-your-own-theme.md).

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

### App-Symbole

Die Symbole im App-Launcher und im Dock werden in den Farben deines Themes gezeichnet, sie ändern sich also mit ihm. Sie stammen aus einem Symbolsatz, den du getrennt vom Theme unter _Erscheinungsbild > Symbole_ auswählst, anhand von Vorschauen jedes Satzes, auf dieselbe Weise, wie du ein Theme auswählst:

- _Papercraft_ ist der Standard: alles, was installiert mitgeliefert wird, in einem Stil gezeichnet. Apps, die man an ihrem Logo erkennt, wie Chrome, HEY oder YouTube, behalten ihre Form und übernehmen die Farben des Themes.
- _Arcade_ zeichnet dieselben Apps als 8-Bit-Pixelkunst, wie es eine alte Spielekonsole tun würde.
- _Original_ zeigt jede App mit dem Symbol, das ihr Hersteller ihr gegeben hat.

Du kannst einen Symbolsatz, den jemand anderes erstellt hat, mit _Installieren > Stil > Symbole_ (oder `omarchy icons install <git url>`) installieren und ihn unter _Entfernen > Symbole_ wieder entfernen. _Aktualisieren > Zusätzliche Symbole_ holt die neueste Version der Sätze, die du installiert hast.

Um deinen eigenen zu erstellen, lege deine Symbole in `~/.config/omarchy/icons/<name>/` ab, eine Datei pro App, benannt nach der `Icon=`-Zeile der `.desktop`-Datei der App. Eine Datei mit der Endung `.svg` wird so gezeigt, wie sie ist. Eine Datei mit der Endung `.svg.tpl` wird in den Farben des Themes gezeichnet: Schreibe `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` oder `{{ icon_shadow }}` dorthin, wo eine Farbe hingehört. Der Standardsatz in `/usr/share/omarchy/icons/papercraft/` ist ein guter Ausgangspunkt. Füge eine `preview.png` hinzu, um deinen Satz in der Auswahl anzuzeigen; ohne eine solche Datei zeichnet Omarchy eine Vorschau aus deinen Symbolen. Um ein einzelnes Symbol des Standardsatzes zu ändern, lege deine Version in `~/.config/omarchy/icons/papercraft/` ab.

### Start und Anmeldung

Der Bildschirm, der beim Start des Computers nach deinem Laufwerkspasswort fragt, und der Anmeldebildschirm folgen ebenfalls dem Theme. Jedes Mal, wenn du das Theme wechselst, übernehmen sie dessen Hintergrund-, Text-, Akzent- und Rotfarben, sodass es kein separates Entsperrdesign auszuwählen gibt. Auf Apple Silicon Macs behält der Bildschirm für das Laufwerkspasswort unabhängig vom Theme das Standardaussehen von Omarchy.
