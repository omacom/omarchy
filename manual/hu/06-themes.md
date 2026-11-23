# Témák

Az Omarchy huszonhárom gyönyörű témával érkezik. Választani közülük az Omarchy Menu _Megjelenés > Téma_ pontjában tudsz (`Super + Space`), vagy közvetlenül a témaválasztóhoz ugorhatsz a `Super + Ctrl + T` kombinációval.

Mindegyik téma formálja az asztal, a terminál, a neovim, a tevékenységképernyő (btop), a böngésződ (Chrome, Chromium, Edge vagy Brave) és az egész Omarchy shell megjelenését: a felső sávot, a menüt, az értesítéseket, az OSD-t és a zárolási képernyőt. (Az Obsidian esetében az Omarchy témát az alkalmazáson belül, a _Megjelenés > Témák_ pontban kell kézzel kiválasztanod).

Minden témához tartozik egy sor háttérkép, amelyek közül a `Super + Ctrl + W` kombinációval választhatsz.

Még több témát találsz [az extra témák oldalán](https://omarchy.org/themes/), vagy akár [saját témát is készíthetsz](43-making-your-own-theme.md).

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

### Alkalmazásikonok

Az alkalmazásindítóban és a dokkban az ikonok a témád színeivel rajzolódnak, így azzal együtt változnak. Egy ikonkészletből származnak, amelyet a témától külön választasz ki a _Megjelenés > Ikonok_ pontban, az egyes készletek előnézetei alapján, ugyanúgy, ahogy témát választasz:

- A _Papercraft_ az alapértelmezett: minden, ami telepítve érkezik, egyetlen stílusban megrajzolva. A logójukról ismert alkalmazások, mint a Chrome, a HEY vagy a YouTube, megtartják az alakjukat, és felveszik a téma színeit.
- Az _Arcade_ ugyanezeket az alkalmazásokat 8 bites pixelgrafikaként rajzolja meg, ahogy egy régi játékkonzol tenné.
- Az _Original_ minden alkalmazást azzal az ikonnal mutat, amelyet a készítője adott neki.

Telepítheted mások által készített ikonkészletet a _Telepítés > Stílus > Ikonok_ pontban (vagy az `omarchy icons install <git url>` paranccsal), és az _Eltávolítás > Ikonok_ pontban tudod ismét eltávolítani. A _Frissítés > Extra ikonok_ letölti a telepített készleteid legújabb verzióját.

Saját készítéséhez tedd az ikonjaidat a `~/.config/omarchy/icons/<name>/` mappába, alkalmazásonként egy fájlt, az alkalmazás `.desktop` fájljának `Icon=` sora után elnevezve. A `.svg` végződésű fájl úgy jelenik meg, ahogy van. A `.svg.tpl` végződésű fájl a téma színeivel rajzolódik: írd be a `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` vagy `{{ icon_shadow }}` egyikét oda, ahová szín kerül. Az alapértelmezett készlet a `/usr/share/omarchy/icons/papercraft/` mappában jó kiindulópont. Adj hozzá egy `preview.png` fájlt, hogy a készleted megjelenjen a választóban; ha nincs ilyen, az Omarchy az ikonjaidból rajzol előnézetet. Az alapértelmezett készlet egyetlen ikonjának lecseréléséhez tedd a saját változatodat a `~/.config/omarchy/icons/papercraft/` mappába.

### Feloldások

A témáknak egyedi feloldási dizájnjuk is lehet, amelyet a rendszerindítási visszafejtési folyamat használ. Ezek közül a _Megjelenés > Feloldás_ pontban választhatsz egyet. Így néznek ki:

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
