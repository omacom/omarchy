# Skróty klawiszowe

Możesz zobaczyć wszystkie główne przypisania klawiszy za pomocą `Super + K` (przypisania Tmux za pomocą `Super + Alt + K`, a przypisania Herdr za pomocą `Super + Ctrl + K`).

## Jak są zorganizowane skróty klawiszowe

Każdy skrót klawiszowy siedzi na płaszczyźnie, wyznaczanej przez jego modyfikatory, a każda płaszczyzna ma jedno zadanie. To właśnie zapobiega zlewaniu się skrótów ze sobą i sprawia, że zwykle możesz zgadnąć, gdzie coś mieszka.

| Płaszczyzna | Co się tam znajduje | Przykłady |
| --- | --- | --- |
| `Super + key` | System: okna, obszary robocze, układy i główne menu | `Super + Space` menu Omarchy, `Super + W` zamknij okno, `Super + F` pełny ekran |
| `Super + Shift + key` | Aplikacje | `Super + Shift + B` przeglądarka, `Super + Shift + E` e-mail, `Super + Shift + N` edytor |
| `Super + Ctrl + key` | Panele i menu systemowe | `Super + Ctrl + A` audio, `Super + Ctrl + N` sieć, `Super + Ctrl + C` menu przechwytywania |
| `Super + Ctrl + Alt + key` | Szybkie akcje i komunikaty | `Super + Ctrl + Alt + T` pokaż czas, `Super + Ctrl + Alt + B` bateria, `Super + Ctrl + Alt + C` zrzut ekranu |

Dodanie `Alt` do skrótu daje ci wariant tej samej rzeczy, nigdy coś niepowiązanego:

- `Super + Shift + B` otwiera przeglądarkę; `Super + Shift + Alt + B` otwiera okno prywatne
- `Super + Shift + E` otwiera e-mail; `Super + Shift + Alt + E` rozpoczyna nowy
- `Super + F` przechodzi do pełnego ekranu; `Super + Alt + F` przechodzi do pełnej szerokości
- `Super + Ctrl + C` otwiera menu przechwytywania; `Super + Ctrl + Alt + C` pomija menu i robi zrzut ekranu

Dodając skrót klawiszowy:

1. Wybierz płaszczyznę na podstawie tego, co robi, a potem wybierz klawisz.
2. Nie przenoś istniejącego skrótu, żeby zrobić miejsce. Znajdź wolny klawisz na właściwej płaszczyźnie.
3. Używaj `Alt` tylko dla wariantu skrótu bez niego.

Kilka skrótów łamie te zasady, bo tak jest wygodniej. `Shift` ze strzałką lub `Tab` przenosi albo odwraca zamiast otwierać aplikację, a `Print`, klawisze multimedialne, `Alt + Tab` i `Ctrl + Alt + Del` działają tak, jak działają wszędzie indziej. To wyjątki, nie wzorce do kopiowania.

Jeśli domyślny ci nie pasuje (powiedzmy, że chcesz `Super + Shift + S` do zrzutów ekranu jak w Windows), przypisz go ponownie w `~/.config/hypr/bindings.lua`.

## Nawigacja

| Skrót klawiszowy                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + Space`           | Menu Omarchy (aplikacje i wszystko inne)    |
| `Super + Alt + Space` | Siatka aplikacji |
| `Super + Escape` | Menu systemowe (uśpienie, ponowne uruchomienie itd.)  |
| `Super + Ctrl + L` | Zablokuj komputer |
| `Super + W` or `Super + Q` | Zamknij okno             |
| `Ctrl + Alt + Del` | Zamknij wszystkie okna |
| `Super + T`               | Przełącz okno między trybem kafelkowym a pływającym             |
| `Super + J` | Przełącz położenie okna (poziome/pionowe) |
| `Super + O`               | Przełącz okno w tryb sticky'n'floating |
| `Super + L`               | Przełączaj cyklicznie między układami dwindle, scrolling i floating |
| `Super + Alt + L`         | Przełączaj cyklicznie między układami w odwrotnym kierunku |
| `Super + P`               | Przełącz styl okna pseudo (naturalny kontra rozciągnięty) |
| `Super + F`                 | Przejdź do pełnego ekranu              |
| `Super + Alt + F`                 | Przejdź do pełnej szerokości              |
| `Super + Ctrl + F`                 | Przejdź do pełnego ekranu wewnątrz okna              |
| `Super + 1/2/3/4`         | Przeskocz do konkretnego obszaru roboczego na monitorze z fokusem |
| `Super + Tab` | Przeskocz do następnego obszaru roboczego na monitorze z fokusem |
| `Super + Shift + Tab` | Przeskocz do poprzedniego obszaru roboczego na monitorze z fokusem |
| `Super + Ctrl + Tab` | Przeskocz do wcześniejszego obszaru roboczego na monitorze z fokusem |
| `Super + Shift + 1/2/3/4` | Przenieś okno do obszaru roboczego na monitorze z fokusem |
| `Super + Shift + Alt + 1/2/3/4` | Przenieś okno do obszaru roboczego na monitorze z fokusem bez podążania za nim |
| `Super + S` | Przełącz pełny scratchpad |
| `Super + Alt + S` | Przenieś okno do pełnego scratchpadu |
| `Super + Grave` | Przełącz konsolę Quake |
| `Super + Shift + Grave` | Przenieś okno do konsoli Quake |
| `Super + Shift + Ctrl + Arrows` | Przenieś okno na monitor w tym kierunku |
| `Super + Shift + Alt + Arrows` | Przenieś obszar roboczy na monitor w tym kierunku |
| `Super + Arrow`  | Przenieś fokus do okna w kierunku strzałki, przechodząc na monitor po tej stronie na krawędzi ekranu |
| `Super + Shift + Arrow`  | Zamień okno z innym w kierunku strzałki, w tym z oknem na monitorze po tej stronie |
| `Super + Minus` | Rozszerz okno w lewo |
| `Super + Equal` | Zmniejsz okno w lewo |
| `Super + Shift + Minus` | Zmniejsz okno w górę |
| `Super + Shift + Equal` | Rozszerz okno w dół |
| `Super + Alt + Minus/Equal` | To samo zmienianie rozmiaru mniejszymi krokami |
| `Super + Ctrl + Minus/Equal` | To samo zmienianie rozmiaru większymi krokami |
| `Super + Alt + Home` | Zapisz szerokość okna |
| `Super + Home` | Przywróć zapisaną szerokość okna |
| `Super + Left Mouse` | Przeciągaj okno |
| `Super + Right Mouse` | Zmień rozmiar okna |
| `Super + Scroll Wheel` | Przewijaj obszary robocze na monitorze z fokusem |
| `Super + G`               | Przełącz grupowanie okien      |
| `Super + Alt + G`               | Wyprowadź okno z grupy      |
| `Super + Alt + Tab`               | Przełączaj cyklicznie między oknami w grupie      |
| `Super + Alt + Shift + Tab`               | Przełączaj cyklicznie wstecz między oknami w grupie      |
| `Super + Alt + Scroll Wheel` | Przełączaj cyklicznie między oknami w grupie |
| `Super + Alt + 1/2/3/4/5`               | Przeskocz do konkretnego okna w grupie      |
| `Super + Alt + Arrow`  | Przenieś okno do grupy w kierunku strzałki, w tym okno na monitorze po tej stronie |
| `Super + Ctrl + Left/Right`  | Poruszaj się między oknami wewnątrz grupy kafelkowej |
| `Super + Ctrl + Z` | Powiększ ekran (powtórz, aby powiększyć bardziej) |
| `Super + Ctrl + Alt + Z` | Całkowicie pomniejsz ekran |
| `Super + /` | Przechodź krok po kroku do przodu przez opcje skalowania monitora |
| `Super + Alt + /` | Przechodź krok po kroku wstecz przez opcje skalowania monitora |
| `Alt + Tab` | Przełączaj cyklicznie do przodu między oknami w aktywnym obszarze roboczym |
| `Alt + Shift + Tab` | Przełączaj cyklicznie wstecz między oknami w aktywnym obszarze roboczym |
| `Ctrl + Alt + Tab`| Przełączaj cyklicznie fokus do przodu między monitorami |
| `Ctrl + Alt + Shift + Tab`| Przełączaj cyklicznie fokus wstecz między monitorami |

Skróty zmiany rozmiaru używają fizycznych klawiszy `code:20` i `code:21` (XKB `<AE11>` i `<AE12>`), niezależnie od znaków nadrukowanych na klawiaturze. Na klawiaturach US tymi klawiszami są `-` i `=`; na klawiaturach japońskich (JIS) są to `-` i `^`; na klawiaturach hiszpańskich są to `'` i `¡`. Na JIS `Super + ^` to `Super + Equal`, natomiast `Super + Shift + -` (który wpisuje `=`) to `Super + Shift + Minus`.

## Sterowanie systemowe

| Skrót klawiszowy                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Panel audio    |
| `Super + Ctrl + B`           | Panel Bluetooth    |
| `Super + Ctrl + N`           | Panel Wi-Fi/sieci    |
| `Super + Ctrl + D`           | Panel wyświetlacza    |
| `Super + Ctrl + P`           | Panel zasilania    |
| `Super + Ctrl + X`           | Panel agentów    |
| `Super + Ctrl + Alt + D`           | Panel kalendarza    |
| `Super + Ctrl + Alt + E`           | Panel zegara światowego    |
| `Super + Ctrl + 1-9`           | Przełącz panel paska według pozycji    |
| `Super + Ctrl + S` | Menu udostępniania (przez LocalSend) |
| `Super + Ctrl + C` | Sterowanie przechwytywaniem (zrzut ekranu/nagrywanie/wybierak) |
| `Super + Ctrl + O` | Menu przełączania |
| `Super + Ctrl + H` | Menu sprzętu |
| `Super + Ctrl + E` | Wybierak emoji |
| `Super + Ctrl + .` | Transkoduj media |
| `Super + Shift + Ctrl + A` | Wybierz agenta AI |

## Regulacje

| Skrót klawiszowy                  | Funkcja              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maksymalna jasność ekranu |
| `Shift + Brightness Down` | Minimalna jasność ekranu |
| `Alt + Brightness Up/Down` | Precyzyjne zmiany jasności co 1% |
| `Alt + Volume Up/Down` | Precyzyjne zmiany głośności co 1% |
| `Keyboard Brightness Up/Down` | Podświetlenie klawiatury jaśniej/ciemniej |
| `Keyboard Backlight` | Przełączaj cyklicznie poziomy podświetlenia klawiatury |
| `Alt + Play` | Następny utwór |
| `Alt + Shift + Play` | Poprzedni utwór |

## Uruchamianie aplikacji

| Skrót klawiszowy                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Terminal Tmux |
| `Super + Ctrl + Return` | Herdr (menedżer agentów) |
| `Super + Shift + Return`           | Przeglądarka    |
| `Super + Shift + Alt + B`           | Przeglądarka (prywatna/incognito)    |
| `Super + Shift + F`           | Menedżer plików    |
| `Super + Shift + Alt + F`           | Menedżer plików w cwd terminala    |
| `Super + Shift + M`           | Muzyka (Spotify)    |
| `Super + Shift + Alt + M`           | Muzyka (cliamp)    |
| `Super + Shift + /`           | Menedżer haseł (1password)    |
| `Super + Shift + Q`           | Kalkulator (Omacalc)    |
| `Super + Shift + T`           | Aktywność (btop)    |
| `Super + Shift + N`           | Edytor (Neovim)  |
| `Super + Shift + C`           | Kalendarz ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | E-mail ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Nowy e-mail ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | AI (ChatGPT)  |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Komunikator (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Komunikator (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Komunikator (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Pisanie (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X Compose |
| `Super + Shift + Y`           | YouTube |

Zmień/dodaj przypisania w `~/.config/hypr/bindings.lua`.

## Uniwersalny schowek

| Skrót klawiszowy                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + A`           | Zaznacz wszystko w aplikacjach obsługujących `Ctrl + A`    |
| `Super + C`           | Kopiuj    |
| `Super + X`           | Wytnij (nie w terminalu)    |
| `Super + V`           | Wklej    |
| `Super + Ctrl + V`           | Menedżer schowka    |

Zwykle na Linuksie potrzebujesz `Ctrl + Shift + C/V`, żeby kopiować'n'wklejać w terminalu, oraz `Ctrl + C/V`, żeby robić to wszędzie indziej. Te ujednolicone skróty schowka Omarchy działają wszędzie.

## Przechwytywanie

| Skrót klawiszowy              | Funkcja                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Zrzut ekranu                      |
| `Super + Ctrl + Alt + C`            | Zrzut ekranu (to samo ujęcie, dla klawiatur bez klawisza Print Screen) |
| `Super + Ctrl + C` | Menu przechwytywania |
| `Alt + Print Screen`            | Nagrywanie ekranu                     |
| `Super + Shift + Ctrl + Alt + C` | Nagrywanie ekranu bez dźwięku, z pominięciem menu (naciśnij ponownie, aby zatrzymać) |
| `Super + Print Screen` | Wybierak kolorów |
| `Super + Ctrl + Print Screen` | Wyodrębnianie tekstu do schowka |
| `Super + Alt + [` | Zmniejsz nakładkę kamery internetowej podczas nagrywania |
| `Super + Alt + ]` | Powiększ nakładkę kamery internetowej podczas nagrywania |
| `Alt + Shift + L` | Kopiuj bieżący URL z aplikacji internetowej lub przeglądarki |
| `Alt + Shift + D` | Pobierz wideo z bieżącej strony do `~/Videos` |
| `Alt + Space` | Rozpocznij/zatrzymaj dyktowanie (wymaga _Setup > Defaults > Dictation_) |
| `Right Alt` | Przytrzymaj, aby dyktować (wymaga _Setup > Defaults > Dictation_) |

Przy nagrywaniu ekranu skrót najpierw pyta, jakiego dźwięku chcesz, a potem zaczyna nagrywać. Naciśnij go ponownie, aby zatrzymać. Szczegóły znajdziesz w [zrzutach ekranu i nagrywaniu](12-screenshots-recording.md).

Wszystkie opcje przechwytywania są dostępne także w _Trigger > Capture_ w menu Omarchy (`Super + Space`).

## Powiadomienia

| Skrót klawiszowy                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + ,` | Działaj na najnowszym powiadomieniu: otwórz je albo naciśnij jego jedyny przycisk, wybierz jedną z jego opcji, albo odrzuć je, gdy nie ma żadnej  |
| `Super + Shift + ,` | Odrzuć wszystkie powiadomienia |
| `Super + Ctrl + ,` | Steruj powiadomieniami za pomocą klawiatury  |
| `Super + Alt + ,` | Odrzuć najnowsze powiadomienie  |
| `Super + Shift + Alt + ,` | Otwórz historię powiadomień  |
| `Super + Ctrl + Alt + ,` | Przełącz wyciszanie powiadomień  |

## Styl

| Skrót klawiszowy                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Wybierz nowy motyw (także `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Wybierz tło motywu (także `Super + Ctrl + Space`) |
| `Super + Backspace` | Przełącz przezroczystość okna |
| `Super + Ctrl + Backspace` | Przełącz kwadratowe proporcje pojedynczego okna |

Dodatkowe obrazy tła znajdują się w `~/.config/omarchy/backgrounds/<theme name>`. Dostępne także przez _Install > Style > Background_ w menu Omarchy.

Wszystkie opcje stylu są dostępne także w _Style_ w menu Omarchy (`Super + Space`).

## Przełączniki

| Skrót klawiszowy                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Przełącz blokowanie przy bezczynności |
| `Super + Ctrl + Delete` | Przełącz wyświetlacz laptopa wł./wył. |
| `Super + Ctrl + Alt + Delete` | Przełącz dublowanie wyświetlacza laptopa |
| `Super + Shift + Space` | Przełącz górny pasek  |
| `Shift + Mute` | Przełącz na następne wyjście audio |
| `Shift + Play` | Przełącz na następne źródło multimediów |
| `Super + Shift + Backspace` | Przełącz odstępy między oknami |
| `Super + Ctrl + Alt + F` | Przełącz pulpit pełnoekranowy (górny pasek + odstępy między oknami) |

## Przypomnienia

| Skrót klawiszowy                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Ustaw przypomnienie  |
| `Super + Ctrl + Alt + R` | Zobacz wszystkie przypomnienia  |
| `Super + Ctrl + Shift + R` | Wyczyść wszystkie przypomnienia  |

## Komunikaty

| Skrót klawiszowy                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Pokaż czas jako powiadomienie  |
| `Super + Ctrl + Alt + B` | Pokaż baterię jako powiadomienie  |
| `Super + Ctrl + Alt + W` | Przełącz pogodę jako powiadomienie  |

## Tmux

Klawisz prefix to `Ctrl + Space` (`Ctrl + B` też działa). Możesz zmienić te przypisania w `~/.config/tmux/tmux.conf`.

### Panele

| Skrót klawiszowy                  | Funkcja              |
| ----------------------- | --------------------- |
| `Prefix + v` | Podziel panel obok (pionowo) |
| `Prefix + h` | Podziel panel poniżej (poziomo) |
| `Prefix + x` | Zabij panel |
| `Prefix + z` | Przełącz powiększenie panelu (pełny ekran) |
| `Alt + Enter` | Podziel panel poniżej (bez prefiksu) |
| `Alt + Shift + Enter` | Podziel panel obok (bez prefiksu) |
| `Alt + Escape` | Zabij panel (bez prefiksu) |
| `Ctrl + Alt + Arrows` | Poruszaj się między panelami |
| `Ctrl + Alt + Shift + Arrows` | Zmień rozmiar paneli |

### Okna

| Skrót klawiszowy                  | Funkcja              |
| ----------------------- | --------------------- |
| `Prefix + c` | Nowe okno |
| `Prefix + k` | Zabij okno |
| `Prefix + r` | Zmień nazwę okna |
| `Alt + 1-9` | Przejdź do konkretnego okna |
| `Alt + Arrow Left/Right` | Poruszaj się między oknami |
| `Alt + Shift + Arrow Left/Right` | Przenieś okno w lewo/w prawo |

### Sesje

| Skrót klawiszowy                  | Funkcja              |
| ----------------------- | --------------------- |
| `Prefix + C` | Nowa sesja |
| `Prefix + K` | Zabij sesję |
| `Prefix + R` | Zmień nazwę sesji |
| `Prefix + N` | Następna sesja |
| `Prefix + P` | Poprzednia sesja |
| `Alt + Arrow Up/Down` | Poruszaj się między sesjami |
| `Prefix + s` | Wyświetl listę sesji |
| `Prefix + d` | Odłącz się od sesji |

### Tryb kopiowania (w stylu vi)

| Skrót klawiszowy                  | Funkcja              |
| ----------------------- | --------------------- |
| `Prefix + [` | Wejdź do trybu kopiowania |
| `v` | Rozpocznij zaznaczanie (w trybie kopiowania) |
| `y` | Kopiuj zaznaczenie (w trybie kopiowania) |

### Ogólne

| Skrót klawiszowy                  | Funkcja              |
| ----------------------- | --------------------- |
| `Prefix + q` | Załaduj ponownie konfigurację |
| `Prefix + ?` | Pokaż przypisania klawiszy Tmux |
| `Prefix + :` | Wiersz poleceń |

### Funkcje układu Tmux

Te funkcje muszą być uruchamiane wewnątrz sesji Tmux.

| Polecenie | Funkcja |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Utwórz układ deweloperski z edytorem, AI i terminalem |
| `tdlm <ai> [<second_ai>]` | Utwórz układ deweloperski dla każdego podkatalogu |
| `tsl <count> <command>` | Utwórz układ roju z wieloma panelami |

## Terminal Ghostty

Terminal Ghostty instaluje się za pomocą _Install > Terminal_ w menu Omarchy.

| Skrót klawiszowy                  | Funkcja              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nowy podział poniżej |
| `Ctrl + Shift + O` | Nowy podział obok |
| `Ctrl + Alt + Arrows` | Poruszaj się między podziałami |
| `Super + Ctrl + Shift + Arrows` | Zmień rozmiar podziału o 10 linii |
| `Super + Ctrl + Shift + Alt + Arrows` | Zmień rozmiar podziału o 100 linii |
| `Ctrl + Shift + T` | Nowa karta  |
| `Ctrl + Shift + Arrows` | Poruszaj się między kartami |
| `Alt + Numbers` | Przejdź do konkretnej karty |
| `Shift + Pg Up/Down` | Przewijaj historię |
| `Ctrl + Left mouse` | Otwórz link w przeglądarce |

## Menedżer plików

| Skrót klawiszowy              | Funkcja                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Przejdź do ścieżki                     |
| `Space`               | Podgląd pliku (nawigacja strzałkami) |
| `Alt + Up`       | Przejdź w górę do folderu nadrzędnego        |

## Neovim (z lazyvim)

### Nawigacja

| Skrót klawiszowy                   | Funkcja                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Pokaż opcje poleceń            |
| `Space Space`              | Otwórz plik przez wyszukiwanie rozmyte      |
| `Space E`                  | Przełącz pasek boczny                  |
| `Space G G`                | Pokaż elementy sterujące git               |
| `Space S G`                | Szukaj w zawartości plików             |
| `Ctrl + W W`               | Przeskakuj między paskiem bocznym a edytorem |
| `Ctrl + Left/right arrow`  | Zmień rozmiar paska bocznego          |
| `Shift + H`                      | Przejdź do lewej karty pliku             |
| `Shift + L`                      | Przejdź do prawej karty pliku            |
| `Space B D`                | Zamknij kartę pliku                  |

### W pasku bocznym

| Skrót klawiszowy                   | Funkcja                        |
| ------------------------ | ------------------------------- |
| `A`                        | Dodaj nowy plik w katalogu nadrzędnym      |
| `Shift + A`                | Dodaj nowy podkatalog w katalogu nadrzędnym    |
| `D`                        | Usuń podświetlony plik/katalog     |
| `M`                        | Przenieś podświetlony plik/katalog       |
| `R`                        | Zmień nazwę podświetlonego pliku/katalogu     |
| `?`                        | Pokaż pomoc dla wszystkich poleceń      |

[Zobacz wszystkie skróty klawiszowe Neovim skonfigurowane przez LazyVim](https://www.lazyvim.org/keymaps).

## Szybkie emoji

Możesz użyć `Super + Ctrl + E`, aby wyświetlić kompletny wybierak emoji, który umieści wybór w schowku, albo możesz użyć tych opcji szybkiego dostępu.

| Skrót klawiszowy       | EM | Wskazówka       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | uśmiech      |
| `Shift + CapsLock M C` | 😂 | płacz        |
| `Shift + CapsLock M L` | 😍 | miłość       |
| `Shift + CapsLock M V` | ✌️ | zwycięstwo    |
| `Shift + CapsLock M H` | ❤️ | serce      |
| `Shift + CapsLock M Y` | 👍 | tak        |
| `Shift + CapsLock M N` | 👎 | nie         |
| `Shift + CapsLock M F` | 🖕 | fuck       |
| `Shift + CapsLock M W` | 🤞 | życzenie       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | całus       |
| `Shift + CapsLock M E` | 🙄 | przewracanie oczami    |
| `Shift + CapsLock M I` | 😉 | mrugnięcie       |
| `Shift + CapsLock M P` | 🙏 | modlitwa |
| `Shift + CapsLock M D` | 🤤 | ślinienie się      |
| `Shift + CapsLock M M` | 💰 | pieniądze      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | toast      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | powitanie |
| `Shift + CapsLock M A` |💪 | ramię |
| `Shift + CapsLock M B` |🤯 | wybuch |

## Szybkie uzupełnienia

| Skrót klawiszowy       | Uzupełnienie       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (pauza)   |
| `Shift + CapsLock Space N` | Twoje imię (jak wprowadzono podczas konfiguracji)  |
| `Shift + CapsLock Space E` | Twój e-mail (jak wprowadzono podczas konfiguracji)  |

Możesz dodać więcej własnych, edytując `~/.XCompose`, a następnie uruchamiając `omarchy-restart-xcompose` w terminalu, aby zmiany zostały wykryte.
