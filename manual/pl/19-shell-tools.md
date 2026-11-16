# Narzędzia powłoki

Oprócz standardowych narzędzi Linuksa, Omarchy dostarcza również zestaw ulepszonych narzędzi powłoki. Oto najważniejsze z nich.

## fzf

[fzf](https://junegunn.github.io/fzf/) zapewnia rozmyte wyszukiwanie plików za pomocą aliasu `ff`. Przejdź do dowolnego katalogu, wpisz `ff`, a będziesz mógł rozmyto odnaleźć drogę do dowolnego pliku w tym drzewie, widząc jednocześnie podgląd plików, które zawężasz, po prawej stronie.

Możesz użyć `Ctrl + R`, aby użyć fzf do rozmytego przeszukiwania historii poleceń.

To narzędzie jest również używane przez Neovim, gdy wpisujesz `Space Space`.

Pełny podręcznik można znaleźć za pomocą `man fzf`.

## Zoxide

[Zoxide](https://github.com/ajeetdsouza/zoxide) jest zamiennikiem cd. Pamięta katalogi, w których byłeś, dzięki czemu możesz łatwiej do nich przeskoczyć następnym razem. Załóżmy, że raz wykonasz `cd ~/.config/omarchy`. Następnym razem możesz po prostu wykonać `cd omarchy` (lub nawet tylko `cd oma`), a Zoxide zabierze cię bezpośrednio tam.

Pełny podręcznik można znaleźć za pomocą `man zoxide`.

## ripgrep

[ripgrep](https://github.com/BurntSushi/ripgrep) przeszukuje zawartość plików za pomocą `rg <pattern> <path>`, na przykład `rg Controller app/`, aby znaleźć wszystkie wzmianki o `Controller` w katalogu app.

To narzędzie jest również używane przez Neovim, gdy wpisujesz `Space S G`.

Pełny podręcznik można znaleźć za pomocą `man rg`.

## eza

[eza](https://eza.rocks/) jest zamiennikiem ls. Zapewnia listingi katalogów z większą ilością informacji, kolorem i ikonami. Domyślnie eza jest aliasowane jako ls. Możesz również użyć `lt`, aby uzyskać listing dwóch poziomów zagnieżdżenia. `lsa` zapewnia listing obejmujący pliki ukryte. A `lta` zagnieżdżony listing z plikami ukrytymi.

Pełny podręcznik można znaleźć za pomocą `man eza`.

## fd

[fd](https://github.com/sharkdp/fd) jest łatwiejszym w użyciu zamiennikiem `find`. Użyj `fd person.rb`, aby znaleźć plik o nazwie `person.rb` w bieżącym drzewie. `fd person.rb /` przeszuka cały system plików. `fd person.rb / -H` przeszukuje cały system plików, w tym katalogi ukryte.

Pełny podręcznik można znaleźć za pomocą `man fd`.

## bat

[bat](https://github.com/sharkdp/bat) to `cat` z podświetlaniem składni, numerami wierszy i stronicowaniem. Uruchom `bat somefile.rb`, a zobaczysz, dlaczego trudno wrócić. Po cichu wykonuje też pracę dla ciebie gdzie indziej: to on koloruje twoje strony man i renderuje podglądy w `ff`.

Pełny podręcznik można znaleźć za pomocą `man bat`.

## tldr

[tldr](https://tldr.sh/) jest antidotum na strony man, które otwierają się trzema ekranami historii, zanim pokażą choćby jeden przykład. `tldr tar` daje ci garść wywołań, których rzeczywiście chciałeś.

## yt-dlp

[yt-dlp](https://github.com/yt-dlp/yt-dlp) pobiera wideo z YouTube i setek innych witryn. `yt-dlp <url>` pobiera najlepszą dostępną jakość do bieżącego katalogu.

Pełny podręcznik można znaleźć za pomocą `man yt-dlp`.

## try

[try](https://github.com/tobi/try) ułatwia zarządzanie eksperymentami programistycznymi w katalogach opatrzonych datą. Wszystkie eksperymenty żyją w `~/Work/tries` i możesz uzyskać do nich dostęp za pomocą `try`.

Omarchy nie dodaje automatycznie katalogu `bin/` projektu do `PATH`. Uruchamiaj zaufane narzędzia lokalne dla projektu z jawną ścieżką względną, taką jak `bin/rails` lub `./bin/dev`.
