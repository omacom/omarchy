# Motywy

Omarchy zawiera dwadzieścia trzy piękne motywy. Możesz wybierać spośród nich w menu Omarchy (`Super + Space`), w sekcji _Wygląd > Motyw_, albo przejść bezpośrednio do selektora motywów za pomocą `Super + Ctrl + T`.

Każdy motyw nadaje styl pulpitowi, terminalowi, neovim, ekranowi aktywności (btop), Twojej przeglądarce (Chrome, Chromium, Edge lub Brave) oraz całej powłoce Omarchy: górnemu paskowi, menu, powiadomieniom, OSD i ekranowi blokady. (W przypadku Obsidian musisz ręcznie wybrać motyw Omarchy w aplikacji, w sekcji _Wygląd > Motywy_).

Motywy mają zestaw obrazów tła, spośród których możesz wybierać za pomocą `Super + Ctrl + W`.

Możesz znaleźć jeszcze więcej motywów na [stronie z dodatkowymi motywami](https://omarchy.org/themes/) albo nawet [stworzyć własny motyw](43-making-your-own-theme.md).

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

### Ikony aplikacji

Ikony w programie uruchamiającym aplikacje i w doku są rysowane w kolorach Twojego motywu, więc zmieniają się razem z nim. Pochodzą z zestawu ikon, który wybierasz niezależnie od motywu w sekcji _Wygląd > Ikony_, na podstawie podglądów każdego zestawu, w ten sam sposób, w jaki wybierasz motyw:

- _Papercraft_ jest domyślny: wszystko, co jest zainstalowane, narysowane w jednym stylu. Aplikacje znane ze swojego logo, takie jak Chrome, HEY czy YouTube, zachowują jego kształt i przybierają kolory motywu.
- _Arcade_ rysuje te same aplikacje jako 8-bitową grafikę pikselową, tak jak zrobiłaby to stara konsola do gier.
- _Original_ pokazuje każdą aplikację z ikoną nadaną jej przez jej twórcę.

Zestaw ikon stworzony przez kogoś innego możesz zainstalować w sekcji _Instaluj > Styl > Ikony_ (albo za pomocą `omarchy icons install <git url>`), a usunąć go ponownie w sekcji _Usuń > Ikony_. _Aktualizuj > Dodatkowe ikony_ pobiera najnowszą wersję zainstalowanych przez Ciebie zestawów.

Aby stworzyć własny zestaw, umieść swoje ikony w `~/.config/omarchy/icons/<name>/`, jeden plik na aplikację, nazwany zgodnie z wierszem `Icon=` z pliku `.desktop` aplikacji. Plik kończący się na `.svg` jest wyświetlany tak, jak jest. Plik kończący się na `.svg.tpl` jest rysowany w kolorach motywu: wpisz `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` lub `{{ icon_shadow }}` tam, gdzie ma się znaleźć kolor. Domyślny zestaw w `/usr/share/omarchy/icons/papercraft/` to dobre miejsce, od którego warto zacząć. Dodaj `preview.png`, aby pokazać swój zestaw w selektorze; bez niego Omarchy narysuje podgląd na podstawie Twoich ikon. Aby zmienić pojedynczą ikonę domyślnego zestawu, umieść swoją wersję w `~/.config/omarchy/icons/papercraft/`.

### Uruchamianie i logowanie

Ekran, który prosi o hasło do dysku podczas uruchamiania komputera, oraz ekran logowania również podążają za motywem. Za każdym razem, gdy zmieniasz motyw, przejmują jego tło, kolor tekstu, kolor akcentu i czerwony kolor, więc nie ma osobnego projektu odblokowywania do wyboru. Na komputerach Mac z Apple Silicon ekran hasła do dysku zachowuje domyślny wygląd Omarchy niezależnie od motywu.
