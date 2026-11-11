# Skróty klawiszowe

Wszystkie główne powiązania klawiszy możesz zobaczyć za pomocą `Super + K` (powiązania Tmux za pomocą `Super + Alt + K`, a powiązania Herdr za pomocą `Super + Ctrl + K`).

## Jak ułożone są skróty klawiszowe

Każdy skrót klawiszowy znajduje się na płaszczyźnie wyznaczonej przez jego modyfikatory, a każda płaszczyzna ma jedno zadanie. To właśnie sprawia, że skróty nie zlewają się ze sobą, i oznacza, że zazwyczaj możesz zgadnąć, gdzie coś się znajduje.

| Płaszczyzna | Co się tam znajduje | Przykłady |
| --- | --- | --- |
| `Super + key` | System: okna, obszary robocze, układy i główne menu | `Super + Space` menu Omarchy, `Super + W` zamknij okno, `Super + F` pełny ekran |
| `Super + Shift + key` | Aplikacje | `Super + Shift + B` przeglądarka, `Super + Shift + E` e-mail, `Super + Shift + N` edytor |
| `Super + Ctrl + key` | Panele i menu systemowe | `Super + Ctrl + A` audio, `Super + Ctrl + N` sieć, `Super + Ctrl + C` menu przechwytywania |
| `Super + Ctrl + Alt + key` | Szybkie akcje i komunikaty | `Super + Ctrl + Alt + T` pokaż czas, `Super + Ctrl + Alt + B` bateria, `Super + Ctrl + Alt + C` zrzut ekranu |

Dodanie `Alt` do skrótu daje wariant tego samego, nigdy coś niepowiązanego:

- `Super + Shift + B` otwiera przeglądarkę; `Super + Shift + Alt + B` otwiera okno prywatne
- `Super + Shift + E` otwiera e-mail; `Super + Shift + Alt + E` rozpoczyna nowy
- `Super + F` przechodzi na pełny ekran; `Super + Alt + F` przechodzi na pełną szerokość
- `Super + Ctrl + C` otwiera menu przechwytywania; `Super + Ctrl + Alt + C` pomija menu i robi zrzut ekranu

Podczas dodawania skrótu:

1. Najpierw wybierz płaszczyznę na podstawie tego, co robi, potem wybierz klawisz.
2. Nie przesuwaj istniejącego skrótu, żeby zrobić miejsce. Znajdź wolny klawisz na właściwej płaszczyźnie.
3. Używaj `Alt` tylko dla wariantu skrótu bez niego.

Kilka skrótów łamie te zasady, bo tak jest wygodniej. `Shift` ze strzałką lub `Tab` przesuwa lub odwraca kierunek zamiast otwierać aplikację, a `Print`, klawisze multimedialne, `Alt + Tab` i `Ctrl + Alt + Del` działają tak, jak wszędzie indziej. To wyjątki, a nie wzorce do naśladowania.

Jeśli domyślny układ ci nie odpowiada (powiedzmy, że chcesz `Super + Shift + S` do zrzutów ekranu, jak w Windows), zmień go w `~/.config/hypr/bindings.lua`.

## Nawigacja

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + Space`           | Menu Omarchy (aplikacje i wszystko inne)    |
| `Super + Alt + Space` | Siatka aplikacji |
| `Super + Escape` | Menu systemowe (uśpij, uruchom ponownie itd.)  |
| `Super + Ctrl + L` | Zablokuj komputer |
| `Super + W` lub `Super + Q` | Zamknij okno             |
| `Ctrl + Alt + Del` | Zamknij wszystkie okna |
| `Super + T`               | Przełącz okno między trybem kafelkowym a pływającym             |
| `Super + J` | Przełącz pozycję okna (poziomo/pionowo) |
| `Super + O`               | Przełącz okno w tryb sticky'n'floating |
| `Super + L`               | Przełączaj cyklicznie układy dwindle, scrolling i floating |
| `Super + Alt + L`         | Przełączaj cyklicznie układy w odwrotnej kolejności |
| `Super + P`               | Przełącz styl pseudo okna (naturalny kontra rozciągnięty) |
| `Super + F`                 | Przejdź na pełny ekran              |
| `Super + Alt + F`                 | Przejdź na pełną szerokość              |
| `Super + Ctrl + F`                 | Przejdź na pełny ekran wewnątrz okna              |
| `Super + 1/2/3/4`         | Przejdź do określonego obszaru roboczego na monitorze z fokusem |
| `Super + Tab` | Przejdź do następnego obszaru roboczego na monitorze z fokusem |
| `Super + Shift + Tab` | Przejdź do poprzedniego obszaru roboczego na monitorze z fokusem |
| `Super + Ctrl + Tab` | Przejdź do wcześniejszego obszaru roboczego na monitorze z fokusem |
| `Super + Shift + 1/2/3/4` | Przenieś okno do obszaru roboczego na monitorze z fokusem |
| `Super + Shift + Alt + 1/2/3/4` | Przenieś okno do obszaru roboczego na monitorze z fokusem bez podążania za nim |
| `Super + S` | Przełącz pełny scratchpad |
| `Super + Alt + S` | Przenieś okno do pełnego scratchpada |
| `Super + Grave` | Przełącz konsolę Quake |
| `Super + Shift + Grave` | Przenieś okno do konsoli Quake |
| `Super + Shift + Ctrl + Arrows` | Przenieś okno na monitor w tym kierunku |
| `Super + Shift + Alt + Arrows` | Przenieś obszar roboczy na monitor w tym kierunku |
| `Super + Arrow`  | Przenieś fokus na okno w kierunku strzałki, przechodząc na monitor po tej stronie przy krawędzi ekranu |
| `Super + Shift + Arrow`  | Zamień okno z innym w kierunku strzałki, w tym z oknem na monitorze po tej stronie |
| `Super + Minus` | Powiększ okno w lewo |
| `Super + Equal` | Zmniejsz okno w lewo |
| `Super + Shift + Minus` | Zmniejsz okno w górę |
| `Super + Shift + Equal` | Powiększ okno w dół |
| `Super + Alt + Minus/Equal` | To samo zmienianie rozmiaru w mniejszych krokach |
| `Super + Ctrl + Minus/Equal` | To samo zmienianie rozmiaru w większych krokach |
| `Super + Alt + Home` | Zapisz szerokość okna |
| `Super + Home` | Przywróć zapisaną szerokość okna |
| `Super + Left Mouse` | Przeciągnij okno |
| `Super + Right Mouse` | Zmień rozmiar okna |
| `Super + Scroll Wheel` | Przewijaj obszary robocze na monitorze z fokusem |
| `Super + G`               | Przełącz grupowanie okien      |
| `Super + Alt + G`               | Wyjmij okno z grupy      |
| `Super + Alt + Tab`               | Przełączaj cyklicznie okna w grupie      |
| `Super + Alt + Shift + Tab`               | Przełączaj cyklicznie wstecz okna w grupie      |
| `Super + Alt + Scroll Wheel` | Przełączaj cyklicznie okna w grupie |
| `Super + Alt + 1/2/3/4/5`               | Przejdź do określonego okna w grupie      |
| `Super + Alt + Arrow`  | Przenieś okno do grupy w kierunku strzałki, w tym okno na monitorze po tej stronie |
| `Super + Ctrl + Left/Right`  | Przemieszczaj się między oknami wewnątrz grupy kafelkowej |
| `Super + Ctrl + Z` | Przybliż ekran (powtórz, aby przybliżyć bardziej) |
| `Super + Ctrl + Alt + Z` | Oddal ekran całkowicie |
| `Super + /` | Przechodź do przodu przez opcje skalowania monitora |
| `Super + Alt + /` | Przechodź do tyłu przez opcje skalowania monitora |
| `Alt + Tab` | Przełączaj cyklicznie do przodu okna w aktywnym obszarze roboczym |
| `Alt + Shift + Tab` | Przełączaj cyklicznie wstecz okna w aktywnym obszarze roboczym |
| `Ctrl + Alt + Tab`| Przełączaj cyklicznie fokus do przodu między monitorami |
| `Ctrl + Alt + Shift + Tab`| Przełączaj cyklicznie fokus wstecz między monitorami |

Skróty do zmiany rozmiaru używają fizycznych klawiszy `code:20` i `code:21` (XKB `<AE11>` i `<AE12>`), niezależnie od znaków nadrukowanych na klawiaturze. Na klawiaturach amerykańskich te klawisze to `-` i `=`; na klawiaturach japońskich (JIS) to `-` i `^`; na klawiaturach hiszpańskich to `'` i `¡`. W JIS `Super + ^` to `Super + Equal`, a `Super + Shift + -` (który wpisuje `=`) to `Super + Shift + Minus`.

## Kontrola systemu

| Skrót                  | Funkcja              |
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
| `Super + Ctrl + C` | Kontrola przechwytywania (zrzut ekranu/nagrywanie/wybierak) |
| `Super + Ctrl + O` | Przełącz menu |
| `Super + Ctrl + H` | Menu sprzętu |
| `Super + Ctrl + E` | Wybierak emoji |
| `Super + Ctrl + .` | Transkoduj multimedia |
| `Super + Shift + Ctrl + A` | Wybierz agenta AI |

## Regulacje

| Skrót                  | Funkcja              |
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

| Skrót                  | Funkcja              |
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

Zmień/dodaj powiązania w `~/.config/hypr/bindings.lua`.

## Uniwersalny schowek

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + A`           | Zaznacz wszystko w aplikacjach, które obsługują `Ctrl + A`    |
| `Super + C`           | Kopiuj    |
| `Super + X`           | Wytnij (nie w terminalu)    |
| `Super + V`           | Wklej    |
| `Super + Ctrl + V`           | Menedżer schowka    |

Zazwyczaj w systemie Linux potrzebujesz `Ctrl + Shift + C/V`, aby kopiować i wklejać w terminalu, oraz `Ctrl + C/V`, aby robić to wszędzie indziej. Te ujednolicone skróty schowka Omarchy działają wszędzie.

## Przechwytywanie

| Skrót              | Funkcja                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Zrzut ekranu                      |
| `Super + Ctrl + Alt + C`            | Zrzut ekranu (ten sam zrzut, dla klawiatur bez klawisza Print Screen) |
| `Super + Ctrl + C` | Menu przechwytywania |
| `Alt + Print Screen`            | Nagrywanie ekranu                     |
| `Super + Print Screen` | Wybierak kolorów |
| `Super + Ctrl + Print Screen` | Wyodrębnianie tekstu do schowka |
| `Super + Alt + [` | Zmniejsz nakładkę kamery internetowej podczas nagrywania |
| `Super + Alt + ]` | Powiększ nakładkę kamery internetowej podczas nagrywania |
| `Alt + Shift + L` | Kopiuj bieżący URL z aplikacji internetowej lub Chromium |
| `Alt + Shift + D` | Pobierz wideo z bieżącej strony do `~/Videos` |
| `Alt + Space` | Rozpocznij/zatrzymaj dyktowanie (wymaga _Konfiguracja > Domyślne > Dyktowanie_) |
| `Right Alt` | Przytrzymaj, aby dyktować (wymaga _Konfiguracja > Domyślne > Dyktowanie_) |

W przypadku nagrywania ekranu skrót najpierw pyta, które audio chcesz, a potem rozpoczyna nagrywanie. Naciśnij go ponownie, aby zatrzymać. Szczegóły znajdziesz w [zrzuty ekranu i nagrywanie](12-screenshots-recording.md).

Wszystkie opcje przechwytywania są też dostępne w _Wyzwalacz > Przechwytywanie_ w menu Omarchy (`Super + Space`).

## Powiadomienia

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + ,` | Działaj na najnowszym powiadomieniu: otwórz je lub naciśnij jego jedyny przycisk, wybierz jedną z jego opcji albo odrzuć je, gdy nie ma żadnej  |
| `Super + Shift + ,` | Odrzuć wszystkie powiadomienia |
| `Super + Ctrl + ,` | Steruj powiadomieniami za pomocą klawiatury  |
| `Super + Alt + ,` | Odrzuć najnowsze powiadomienie  |
| `Super + Shift + Alt + ,` | Otwórz historię powiadomień  |
| `Super + Ctrl + Alt + ,` | Przełącz wyciszanie powiadomień  |

## Styl

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Wybierz nowy motyw (również `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Wybierz tło motywu (również `Super + Ctrl + Space`) |
| `Super + Backspace` | Przełącz przezroczystość okna |
| `Super + Ctrl + Backspace` | Przełącz kwadratowe proporcje pojedynczego okna |

Dodatkowe obrazy tła znajdują się w `~/.config/omarchy/backgrounds/<theme name>`. Dostępne też przez _Instaluj > Styl > Tło_ w menu Omarchy.

Wszystkie opcje stylu są też dostępne w _Styl_ w menu Omarchy (`Super + Space`).

## Przełączniki

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Przełącz blokowanie przy bezczynności |
| `Super + Ctrl + Delete` | Przełącz wyświetlacz laptopa włączony/wyłączony |
| `Super + Ctrl + Alt + Delete` | Przełącz dublowanie wyświetlacza laptopa |
| `Super + Shift + Space` | Przełącz górny pasek  |
| `Shift + Mute` | Przełącz na następne wyjście audio |
| `Shift + Play` | Przełącz na następne źródło multimediów |
| `Super + Shift + Backspace` | Przełącz odstępy między oknami |
| `Super + Ctrl + Alt + F` | Przełącz pełnoekranowy pulpit (górny pasek + odstępy między oknami) |

## Przypomnienia

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Ustaw przypomnienie  |
| `Super + Ctrl + Alt + R` | Zobacz wszystkie przypomnienia  |
| `Super + Ctrl + Shift + R` | Wyczyść wszystkie przypomnienia  |

## Komunikaty

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Pokaż czas jako powiadomienie  |
| `Super + Ctrl + Alt + B` | Pokaż baterię jako powiadomienie  |
| `Super + Ctrl + Alt + W` | Przełącz pogodę jako powiadomienie  |

## Tmux

Klawisz prefiksu to `Ctrl + Space` (działa też `Ctrl + B`). Te powiązania możesz zmienić w `~/.config/tmux/tmux.conf`.

### Panele

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Prefix + v` | Podziel panel obok (pionowo) |
| `Prefix + h` | Podziel panel poniżej (poziomo) |
| `Prefix + x` | Zabij panel |
| `Prefix + z` | Przełącz powiększenie panelu (pełny ekran) |
| `Alt + Enter` | Podziel panel poniżej (bez prefiksu) |
| `Alt + Shift + Enter` | Podziel panel obok (bez prefiksu) |
| `Alt + Escape` | Zabij panel (bez prefiksu) |
| `Ctrl + Alt + Arrows` | Przemieszczaj się między panelami |
| `Ctrl + Alt + Shift + Arrows` | Zmień rozmiar paneli |

### Okna

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Prefix + c` | Nowe okno |
| `Prefix + k` | Zabij okno |
| `Prefix + r` | Zmień nazwę okna |
| `Alt + 1-9` | Przejdź do określonego okna |
| `Alt + Arrow Left/Right` | Przemieszczaj się między oknami |
| `Alt + Shift + Arrow Left/Right` | Przenieś okno w lewo/w prawo |

### Sesje

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Prefix + C` | Nowa sesja |
| `Prefix + K` | Zabij sesję |
| `Prefix + R` | Zmień nazwę sesji |
| `Prefix + N` | Następna sesja |
| `Prefix + P` | Poprzednia sesja |
| `Alt + Arrow Up/Down` | Przemieszczaj się między sesjami |
| `Prefix + s` | Wyświetl listę sesji |
| `Prefix + d` | Odłącz się od sesji |

### Tryb kopiowania (w stylu vi)

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Prefix + [` | Wejdź w tryb kopiowania |
| `v` | Rozpocznij zaznaczanie (w trybie kopiowania) |
| `y` | Kopiuj zaznaczenie (w trybie kopiowania) |

### Ogólne

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Prefix + q` | Załaduj ponownie konfigurację |
| `Prefix + ?` | Pokaż skróty klawiszowe Tmux |
| `Prefix + :` | Wiersz poleceń |

### Funkcje układu Tmux

Te funkcje muszą być uruchamiane wewnątrz sesji Tmux.

| Polecenie | Funkcja |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Utwórz układ deweloperski z edytorem, AI i terminalem |
| `tdlm <ai> [<second_ai>]` | Utwórz układ deweloperski dla każdego podkatalogu |
| `tsl <count> <command>` | Utwórz układ swarm z wieloma panelami |

## Terminal Ghostty

Terminal Ghostty instaluje się przez _Instaluj > Terminal_ w menu Omarchy.

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nowy podział poniżej |
| `Ctrl + Shift + O` | Nowy podział obok |
| `Ctrl + Alt + Arrows` | Przemieszczaj się między podziałami |
| `Super + Ctrl + Shift + Arrows` | Zmień rozmiar podziału o 10 wierszy |
| `Super + Ctrl + Shift + Alt + Arrows` | Zmień rozmiar podziału o 100 wierszy |
| `Ctrl + Shift + T` | Nowa karta  |
| `Ctrl + Shift + Arrows` | Przemieszczaj się między kartami |
| `Alt + Numbers` | Przejdź do określonej karty |
| `Shift + Pg Up/Down` | Przewijaj historię |
| `Ctrl + Left mouse` | Otwórz link w przeglądarce |

## Menedżer plików

| Skrót              | Funkcja                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Przejdź do ścieżki                     |
| `Space`               | Podgląd pliku (strzałki nawigują) |
| `Alt + Up`       | Przejdź w górę do folderu nadrzędnego        |

## Neovim (z lazyvim)

### Nawigacja

| Skrót                   | Funkcja                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Pokaż opcje poleceń            |
| `Space Space`              | Otwórz plik przez wyszukiwanie rozmyte      |
| `Space E`                  | Przełącz pasek boczny                  |
| `Space G G`                | Pokaż elementy sterujące git               |
| `Space S G`                | Przeszukaj zawartość pliku             |
| `Ctrl + W W`               | Przeskakuj między paskiem bocznym a edytorem |
| `Ctrl + Left/right arrow`  | Zmień rozmiar paska bocznego          |
| `Shift + H`                      | Przejdź do lewej karty pliku             |
| `Shift + L`                      | Przejdź do prawej karty pliku            |
| `Space B D`                | Zamknij kartę pliku                  |

### W pasku bocznym

| Skrót                   | Funkcja                        |
| ------------------------ | ------------------------------- |
| `A`                        | Dodaj nowy plik w katalogu nadrzędnym      |
| `Shift + A`                | Dodaj nowy podkatalog w katalogu nadrzędnym    |
| `D`                        | Usuń podświetlony plik/katalog     |
| `M`                        | Przenieś podświetlony plik/katalog       |
| `R`                        | Zmień nazwę podświetlonego pliku/katalogu     |
| `?`                        | Pokaż pomoc dla wszystkich poleceń      |

[Zobacz wszystkie skróty klawiszowe Neovim skonfigurowane przez LazyVim](https://www.lazyvim.org/keymaps).

## Szybkie emoji

Możesz użyć `Super + Ctrl + E`, aby pokazać kompletny wybierak emoji, który umieści wybór w schowku, albo możesz użyć tych opcji szybkiego dostępu.

| Skrót       | EM | Wskazówka       |
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
| `Shift + CapsLock M K` | 😘 | pocałunek       |
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
| `Shift + CapsLock M B` |🤯 | wybuch głowy |

## Szybkie uzupełnienia

| Skrót       | Uzupełnienie       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (pauza)   |
| `Shift + CapsLock Space N` | Twoje imię (jak podano podczas konfiguracji)  |
| `Shift + CapsLock Space E` | Twój e-mail (jak podano podczas konfiguracji)  |

Możesz dodać więcej własnych, edytując `~/.XCompose`, a potem uruchamiając `omarchy-restart-xcompose` w terminalu, aby zmiany zostały wczytane.
