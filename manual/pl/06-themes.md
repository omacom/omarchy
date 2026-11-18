# Motywy

Omarchy zawiera dwadzieścia dwa piękne motywy. Możesz wybierać między nimi w sekcji _Wygląd > Motyw_ w menu Omarchy (`Super + Space`) albo przejść bezpośrednio do wyboru motywu za pomocą `Super + Ctrl + T`.

Każdy motyw nadaje styl pulpitowi, terminalowi, neovim, ekranowi aktywności (btop), Chromium oraz całej powłoce Omarchy: górnemu paskowi, menu, powiadomieniom, OSD i ekranowi blokady. (W przypadku Obsidian musisz ręcznie wybrać motyw Omarchy w sekcji _Wygląd > Motywy_ wewnątrz aplikacji).

Motywy mają zestaw obrazów tła, spośród których możesz wybierać za pomocą `Super + Ctrl + W`.

Jeszcze więcej motywów znajdziesz na [stronie z dodatkowymi motywami](https://omarchy.org/themes/), a nawet możesz [stworzyć własny motyw](43-making-your-own-theme.md).

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

### Ikony aplikacji

Ikony w programie uruchamiającym aplikacje i w docku są rysowane w kolorach Twojego motywu, więc zmieniają się wraz z nim. Pochodzą z zestawu ikon, który wybierasz niezależnie od motywu w sekcji _Wygląd > Ikony_, na podstawie podglądów każdego zestawu, w ten sam sposób, w jaki wybierasz motyw:

- _Papercraft_ to zestaw domyślny: wszystko, co jest zainstalowane, narysowane w jednym stylu. Aplikacje znane z logo, takie jak Chrome, HEY czy YouTube, zachowują jego kształt i przybierają kolory motywu.
- _Arcade_ rysuje te same aplikacje jako 8-bitową grafikę pikselową, jak na starej konsoli do gier.
- _Original_ pokazuje każdą aplikację z ikoną nadaną jej przez twórcę.

Możesz zainstalować zestaw ikon stworzony przez kogoś innego w sekcji _Instalacja > Styl > Ikony_ (lub za pomocą `omarchy icons install <git url>`), a usunąć go ponownie w sekcji _Usuwanie > Ikony_. _Aktualizacja > Dodatkowe ikony_ pobiera najnowszą wersję zainstalowanych zestawów.

Aby stworzyć własny zestaw, umieść ikony w `~/.config/omarchy/icons/<name>/`, po jednym pliku na aplikację, nazwanym zgodnie z wierszem `Icon=` w pliku `.desktop` aplikacji. Plik z końcówką `.svg` jest wyświetlany tak, jak jest. Plik z końcówką `.svg.tpl` jest rysowany w kolorach motywu: wpisz `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` lub `{{ icon_shadow }}` tam, gdzie ma się znaleźć kolor. Dobrym punktem wyjścia jest domyślny zestaw w `/usr/share/omarchy/icons/papercraft/`. Dodaj plik `preview.png`, aby pokazać swój zestaw w selektorze; bez niego Omarchy narysuje podgląd na podstawie Twoich ikon. Aby zmienić pojedynczą ikonę zestawu domyślnego, umieść swoją wersję w `~/.config/omarchy/icons/papercraft/`.

### Odblokowywanie

Motywy mogą mieć także własny projekt odblokowywania, używany podczas procesu odszyfrowywania przy rozruchu. Możesz wybrać jeden z nich w sekcji _Wygląd > Odblokowywanie_. Wyglądają tak:

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
