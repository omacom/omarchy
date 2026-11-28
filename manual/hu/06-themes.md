# Témák

Az Omarchy huszonhárom gyönyörű témával érkezik. Az Omarchy Menu _Megjelenés > Téma_ pontjában választhatsz közülük (`Super + Space`), vagy a `Super + Ctrl + T` billentyűkombinációval közvetlenül a témaválasztóhoz ugorhatsz.

Minden téma az asztal, a terminál, a neovim, a tevékenységképernyő (btop), a böngésződ (Chrome, Chromium, Edge vagy Brave) és a teljes Omarchy felület megjelenését is meghatározza: a felső sávét, a menüét, az értesítésekét, az OSD-ét és a zárolási képernyőét. (Obsidian esetén az alkalmazáson belül, a _Megjelenés > Témák_ pontban kell kézzel kiválasztanod az Omarchy témát.)

A témákhoz tartozik egy sor háttérkép, amelyek közül a `Super + Ctrl + W` billentyűkombinációval választhatsz.

Még több témát találsz [a további témák oldalán](https://omarchy.org/themes/), vagy akár [saját témát is készíthetsz](43-making-your-own-theme.md).

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

Az alkalmazásindítóban és a dokkban az ikonok a témád színeivel vannak megrajzolva, így azzal együtt változnak. Egy ikonkészletből származnak, amelyet a témától külön választhatsz ki a _Megjelenés > Ikonok_ pontban, az egyes készletek előnézete alapján, ugyanúgy, ahogy a témát is kiválasztod:

- A _Papercraft_ az alapértelmezett: minden telepített alkalmazás egységes stílusban megrajzolva. A logójukról ismert alkalmazások, mint a Chrome, a HEY vagy a YouTube, megtartják az alakjukat, és felveszik a téma színeit.
- Az _Arcade_ ugyanazokat az alkalmazásokat 8 bites pixelgrafikával rajzolja meg, ahogy egy régi játékkonzol tenné.
- Az _Original_ minden alkalmazást azzal az ikonnal jelenít meg, amelyet a készítője adott neki.

Mások által készített ikonkészletet a _Telepítés > Stílus > Ikonok_ pontban (vagy az `omarchy icons install <git url>` paranccsal) telepíthetsz, és az _Eltávolítás > Ikonok_ pontban távolíthatod el újra. A _Frissítés > Extra ikonok_ lekéri a telepített készleteid legújabb verzióját.

Saját készlethez helyezd az ikonjaidat a `~/.config/omarchy/icons/<name>/` könyvtárba, alkalmazásonként egy fájlt, az alkalmazás `.desktop` fájljának `Icon=` sora szerint elnevezve. Az `.svg` végződésű fájlok úgy jelennek meg, ahogy vannak. Az `.svg.tpl` végződésű fájlok a téma színeivel rajzolódnak ki: írj `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` vagy `{{ icon_shadow }}` helyőrzőt oda, ahová szín kerül. Az alapértelmezett készlet a `/usr/share/omarchy/icons/papercraft/` könyvtárban jó kiindulópont. Adj hozzá egy `preview.png` fájlt, hogy a készleted megjelenjen a választóban; enélkül az Omarchy az ikonjaidból készít előnézetet. Az alapértelmezett készlet egyetlen ikonjának megváltoztatásához helyezd a saját verziódat a `~/.config/omarchy/icons/papercraft/` könyvtárba.

### Rendszerindítás és bejelentkezés

A számítógép indulásakor a meghajtó jelszavát kérő képernyő és a bejelentkezési képernyő is követi a témát. Minden témaváltáskor átveszik annak háttér-, szöveg-, kiemelő és piros színeit, így nincs külön kiválasztandó feloldási megjelenés. Apple Silicon Mac gépeken a meghajtó jelszavát kérő képernyő a témától függetlenül megtartja az Omarchy alapértelmezett megjelenését.
