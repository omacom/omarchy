# Neovim

[Neovim](https://neovim.io/) to nowoczesna implementacja [edytora vi](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) stworzonego przez Billa Joya jeszcze w 1976 roku. To edytor modalny, w którym tryb wstawiania i tryb poleceń są od siebie oddzielone, i to trochę supermoc, gdy nauczysz się choćby części niewiarygodnie bogatego zestawu poleceń klawiszowych. Trzeba się jednak trochę namęczyć, żeby się tego nauczyć!

Jeśli dopiero zaczynasz przygodę z edycją w stylu vim, polecam sprawdzić [serię ThePrimeagena Vim As Your Editor](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) na YouTube. Nauczy cię ona podstaw. Pamiętaj tylko, że w odróżnieniu od bardziej podobnych do siebie popularnych edytorów, osiągnięcie podstawowej biegłości w vimie zajmie ci więcej czasu. Gdy już to zrobisz, zysk jest jednak również większy.

Neovim można natomiast konfigurować właściwie w nieskończoność. Jeśli naprawdę chcesz zaszaleć, możesz stworzyć własną konfigurację Neovim od podstaw. Jest świetny kurs [Typecraft o konfigurowaniu Neovim od podstaw](https://www.youtube.com/watch?v=zHTeCSVAFNY). [ThePrimeagen też ma taki kurs](https://www.youtube.com/watch?v=w7i4amO_zaE).

Omarchy jest jednak dostarczane z kompletną konfiguracją Neovim — pakietem `omarchy-nvim` — która została starannie dopracowana, aby od razu po wyjęciu z pudełka pokazać to, co najlepsze. Bez konieczności pisania przez ciebie choćby jednej linii konfiguracji! Jest oparta na [LazyVim](https://www.lazyvim.org/), dystrybucji wtyczek i konfiguracji Neovim. Jest świetna.

## Podstawy LazyVim

Jak wspomniałem, nie nauczę cię vima w tym krótkim wprowadzeniu, ale mogę pokazać ci kilka podstaw LazyVim i poruszania się po programie.

Po pierwsze, Neovim ma koncepcję klawisza leader. To w zasadzie brama do wszystkich poleceń. LazyVim ustawiło go na `Space`. Po prostu naciśnij ten klawisz, poczekaj sekundę, a zobaczysz wiele opcji wyjaśnionych bezpośrednio w następujący sposób:

Oto kilka podstawowych poleceń, których używam cały czas:

- `Space Space` - Wyszukiwanie rozmyte dowolnego pliku w bieżącym katalogu.
- `Space S G` - Przeszukiwanie wszystkich plików za pomocą grep z podglądem.
- `Space E` - Włączanie/wyłączanie drzewa plików.
- `Ctrl + W W` - Przechodzenie między drzewem plików a edytorem.
- `Shift + H` - Przejście w lewo między otwartymi kartami (vim nazywa je buforami).
- `Shift + L` - Przejście w prawo między otwartymi kartami.
- `Space B D` - Zamknięcie karty.
- `Space B O` - Zamknięcie wszystkich pozostałych kart poza bieżącą.
- `Space G G` - Uruchomienie LazyGit w pływającym panelu z bieżącego katalogu.
- `Space U W` - Włączanie/wyłączanie miękkiego zawijania wierszy.

Gdy jesteś w drzewie plików (`Space E`, aby je wyświetlić, `Ctrl + W W`, aby tam przeskoczyć), możesz dodać nowy plik za pomocą `a` lub nowy katalog za pomocą `A`. Naciśnij `?` w drzewie, aby zobaczyć wszystkie polecenia.

Jeśli chcesz przyswoić podstawowy język vima, napisałem o [trzyczęściowej składni](https://world.hey.com/dhh/wonderful-vi-a1d034d3) i o tym, jak wykonywać te efektowne ruchy kombinowane!

Wszystkie możliwe polecenia możesz zobaczyć na [stronie LazyVim Keymaps](https://www.lazyvim.org/keymaps).

## Uruchamianie Neovim

`Super + Shift + N` uruchamia twój domyślny edytor, którym w nowych instalacjach jest Plain; wybierz Neovim w _Setup > Defaults > Editor_, aby zamiast niego uruchamiał się Neovim. Zwykle łatwiej jest jednak obsługiwać go z terminala, przechodząc do katalogu, w którym chcesz pracować, i wpisując `n`. `n` to alias dla `nvim`, który domyślnie użyje bieżącego katalogu do otwarcia. Pojedynczy plik możesz otworzyć za pomocą `n myfile.txt`.

## Używanie Neovim do edycji z sudo

Jeśli musisz edytować pliki, które możesz zmieniać tylko jako superużytkownik, uruchom `sudoedit /etc/sudoers.d/00-sudo-only-file`. Otwiera to twój domyślny edytor, więc ustaw Neovim w _Setup > Defaults > Editor_, jeśli chcesz go tam mieć ze wszystkimi swoimi wtyczkami.
