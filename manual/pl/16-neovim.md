# Neovim

[Neovim](https://neovim.io/) to nowoczesna implementacja [edytora vi](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) stworzonego przez Billa Joya już w 1976 roku. To edytor modalny, w którym tryb wstawiania i tryb poleceń są rozdzielone, i jest to w swoim rodzaju supermoc, gdy nauczysz się choćby podzbioru niesamowicie głębokiej listy poleceń klawiszowych. Ale ma też sporą krzywą uczenia się!

Jeśli jesteś zupełnie nowy w edycji w stylu vim, polecam serię [ThePrimeagen Vim As Your Editor](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) na YouTubie. Nauczy cię ona podstaw. Wiedz tylko, że w odróżnieniu od bardziej podobnych, mainstreamowych edytorów, opanowanie podstaw vim zajmie ci dłużej. Ale gdy już to zrobisz, nagroda jest też większa.

Neovim jest właściwie nieskończenie konfigurowalny. Jeśli naprawdę chcesz pójść w gwizdek, możesz stworzyć własną konfigurację Neovima od zera. Jest świetny kurs od [Typecraft o konfiguraniu Neovima od zera](https://www.youtube.com/watch?v=zHTeCSVAFNY). A [ThePrimeagen też ma taki](https://www.youtube.com/watch?v=w7i4amO_zaE).

Ale Omarchy dostarcza kompletny zestaw Neovim — pakiet `omarchy-nvim` — który został z miłością dostrojony tak, aby od razu pokazywał to, co najlepsze z możliwego. Bez konieczności pisania ani jednej linijki konfiguracji! Zbudowany jest na [LazyVim](https://www.lazyvim.org/), dystrybucji wtyczek i konfiguracji Neovima. Jest świetny.

## Podstawy LazyVim

Jak wspomniano, nie będę cię w tym krótkim wprowadzeniu uczył vima, ale mogę pokazać kilka podstaw LazyVim i jak się poruszać.

Po pierwsze, Neovim ma ideę klawisza wiodącego (leader). To w zasadzie brama do wszystkich poleceń. LazyVim ustawił ją na `Space`. Więc po prostu naciśnij ten klawisz, chwilę odczekaj, a zobaczysz zestaw opcji wyjaśnionych na miejscu, mniej więcej tak:

Oto kilka podstawowych poleceń, których używam cały czas:

- `Space Space` - Rozmyte znajdowanie dowolnego pliku w bieżącym katalogu.
- `Space S G` - Przeszukiwanie wszystkich plików przez grep z podglądem.
- `Space E` - Przełączanie drzewa plików włącz/wyłącz.
- `Ctrl + W W` - Skok z drzewa plików do edytora i z powrotem.
- `Shift + H` - Przesuwanie się w lewo między otwartymi kartami (vim nazywa je buforami).
- `Shift + L` - Przesuwanie się w prawo między otwartymi kartami.
- `Space B D` - Zamknięcie karty.
- `Space B O` - Zamknięcie wszystkich pozostałych kart poza bieżącą.
- `Space G G` - Uruchomienie LazyGit w pływającym panelu z bieżącego katalogu.
- `Space U W` - Przełączanie miękkiego zawijania.

Gdy jesteś w drzewie plików (odsłonięcie przez `Space E`, skok tam przez `Ctrl + W W`), możesz dodać nowy plik przez `a` lub nowy katalog przez `A`. Naciśnij `?` będąc w drzewie, żeby zobaczyć wszystkie polecenia.

Jeśli chcesz posłuchać bazowego języka vim, pisałem o [trzyczęściowej składni](https://world.hey.com/dhh/wonderful-vi-a1d034d3) oraz o tym, jak wykonać te imponujące ruchy combo!

Wszystkie możliwe polecenia zobaczysz na [stronie LazyVim Keymaps](https://www.lazyvim.org/keymaps).

## Uruchamianie Neovim

Neovim możesz uruchomić przez `Super + Shift + N` (przypisanie to uruchamia twój domyślny edytor, którym od razu jest Neovim), ale zwykle łatwiej się nim kieruje z terminala, przechodząc do katalogu, w którym chcesz pracować, i wpisując `n`. `n` to alias dla `nvim`, który domyślnie otworzy bieżący katalog. Pojedynczy plik możesz otworzyć przez `n myfile.txt`.

## Używanie Neovim do edycji z sudo

Jeśli musisz edytować pliki, które możesz zmieniać tylko jako superużytkownik, użyj Neovima wraz ze wszystkimi wtyczkami, uruchamiając `sudoedit /etc/sudoers.d/00-sudo-only-file`.
