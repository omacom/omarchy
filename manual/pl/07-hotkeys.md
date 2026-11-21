# Skróty klawiszowe

Wszystkie główne powiązania klawiszy możesz zobaczyć za pomocą `Super + K` (powiązania Tmux za pomocą `Super + Alt + K`, a powiązania Herdr za pomocą `Super + Ctrl + K`).

## Jak ułożone są skróty klawiszowe

Każdy skrót klawiszowy znajduje się na jednej płaszczyźnie, wyznaczanej przez jego modyfikatory, a każda płaszczyzna ma jedno zadanie. To właśnie dzięki temu skróty klawiszowe nie zlewają się ze sobą i zwykle możesz zgadnąć, gdzie coś się znajduje.

| Płaszczyzna | Co się tam znajduje | Przykłady |
| --- | --- | --- |
| `Super + key` | System: okna, obszary robocze, układy i główne menu | `Super + Space` menu Omarchy, `Super + W` zamknięcie okna, `Super + F` pełny ekran |
| `Super + Shift + key` | Aplikacje | `Super + Shift + B` przeglądarka, `Super + Shift + E` e-mail, `Super + Shift + N` edytor |
| `Super + Ctrl + key` | Panele i menu systemowe | `Super + Ctrl + A` audio, `Super + Ctrl + N` sieć, `Super + Ctrl + C` menu przechwytywania |
| `Super + Ctrl + Alt + key` | Szybkie akcje i komunikaty | `Super + Ctrl + Alt + T` pokaż czas, `Super + Ctrl + Alt + B` bateria, `Super + Ctrl + Alt + C` zrzut ekranu |

Dodanie `Alt` do skrótu klawiszowego daje wariant tego samego, nigdy coś niepowiązanego:

- `Super + Shift + B` otwiera przeglądarkę; `Super + Shift + Alt + B` otwiera okno prywatne
- `Super + Shift + E` otwiera e-mail; `Super + Shift + Alt + E` rozpoczyna nowy
- `Super + F` przechodzi w tryb pełnoekranowy; `Super + Alt + F` przechodzi na pełną szerokość
- `Super + Ctrl + C` otwiera menu przechwytywania; `Super + Ctrl + Alt + C` pomija menu i robi zrzut ekranu

Gdy dodajesz skrót klawiszowy:

1. Wybierz płaszczyznę na podstawie tego, co robi, a potem wybierz klawisz.
2. Nie przesuwaj istniejącego skrótu klawiszowego, żeby zrobić miejsce. Znajdź wolny klawisz na właściwej płaszczyźnie.
3. Używaj `Alt` tylko dla wariantu skrótu bez niego.

Kilka skrótów łamie te zasady, bo tak jest wygodniej. `Shift` ze strzałką lub `Tab` przesuwa lub odwraca zamiast otwierać aplikację, a `Print`, klawisze multimedialne, `Alt + Tab` i `Ctrl + Alt + Del` działają tak samo jak wszędzie indziej. To wyjątki, nie wzorce do kopiowania.

Jeśli domyślny skrót ci nie pasuje (powiedzmy, że chcesz `Super + Shift + S` do zrzutów ekranu jak w Windows), przypisz go ponownie w `~/.config/hypr/bindings.lua`.

## Nawigacja

| Skrót klawiszowy                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + Space`           | Menu Omarchy (aplikacje i wszystko inne)    |
| `Super + Alt + Space` | Siatka aplikacji |
| `Super + Escape` | Menu systemowe (uśpienie, ponowne uruchomienie itd.)  |
| `Super + Ctrl + L` | Zablokuj komputer |
| `Super + W` or `Super + Q` | Zamknij okno             |
| `Ctrl + Alt + Del` | Zamknij wszystkie okna |
| `Super + K` | Pokaż wszystkie skróty klawiszowe |
| `Super + Alt + K` | Pokaż skróty klawiszowe tmux |
| `Super + Ctrl + K` | Pokaż skróty klawiszowe herdr |
| `Super + M` | Zminimalizuj okno do docka |
| `Super + T`               | Przełącz okno między trybem kafelkowym a pływającym             |
| `Super + J` | Przełącz pozycję okna (pozioma/pionowa) |
| `Super + O`               | Przełącz okno w tryb przyklejonego okna pływającego |
| `Super + L`               | Przełączaj kolejno układy dwindle, scrolling i floating |
| `Super + Alt + L`         | Przełączaj kolejno układy w odwrotnej kolejności |
| `Super + P`               | Przełącz styl okna pseudo (naturalny a rozciągnięty) |
| `Super + F`                 | Przejdź w tryb pełnoekranowy              |
| `Super + Alt + F`                 | Przejdź na pełną szerokość              |
| `Super + Ctrl + F`                 | Przejdź w tryb pełnoekranowy wewnątrz okna              |
| `Super + 1…9/0`         | Przejdź do określonego obszaru roboczego (0 to 10) na monitorze z fokusem |
| `Super + Tab` | Przejdź do następnego obszaru roboczego na monitorze z fokusem |
| `Super + Shift + Tab` | Przejdź do poprzedniego obszaru roboczego na monitorze z fokusem |
| `Super + Ctrl + Tab` | Przejdź do poprzedniego obszaru roboczego na monitorze z fokusem |
| `Super + Shift + 1…9/0` | Przenieś okno do obszaru roboczego na monitorze z fokusem |
| `Super + Shift + Alt + 1…9/0` | Przenieś okno do obszaru roboczego na monitorze z fokusem bez podążania za nim |
| `Super + S` | Przełącz pełny scratchpad |
| `Super + Alt + S` | Przenieś okno do pełnego scratchpada |
| `Super + Grave` | Przełącz konsolę Quake |
| `Super + Shift + Grave` | Przenieś okno do konsoli Quake |
| `Super + Shift + Ctrl + Arrows` | Przenieś okno na monitor w tym kierunku |
| `Super + Shift + Alt + Arrows` | Przenieś obszar roboczy na monitor w tym kierunku |
| `Super + Arrow`  | Przenieś fokus na okno w kierunku strzałki, przechodząc na monitor po tej stronie na krawędzi ekranu |
| `Super + Shift + Arrow`  | Zamień okno z innym w kierunku strzałki, w tym z oknem na monitorze po tej stronie |
| `Super + Minus` | Rozszerz okno w lewo |
| `Super + Equal` | Zwęź okno w lewo |
| `Super + Shift + Minus` | Zwęź okno w górę |
| `Super + Shift + Equal` | Rozszerz okno w dół |
| `Super + Alt + Minus/Equal` | To samo zmienianie rozmiaru mniejszymi krokami |
| `Super + Ctrl + Minus/Equal` | To samo zmienianie rozmiaru większymi krokami |
| `Super + Alt + Home` | Zapisz szerokość okna |
| `Super + Home` | Przywróć zapisaną szerokość okna |
| `Super + Left Mouse` | Przeciągaj okno |
| `Super + Right Mouse` | Zmień rozmiar okna |
| `Super + Scroll Wheel` | Przewijaj obszary robocze na monitorze z fokusem |
| `Super + G`               | Przełącz grupowanie okien      |
| `Super + Alt + G`               | Wyjmij okno z grupy      |
| `Super + Alt + Tab`               | Przełączaj kolejno okna w grupie      |
| `Super + Alt + Shift + Tab`               | Przełączaj kolejno okna w grupie wstecz      |
| `Super + Alt + Scroll Wheel` | Przełączaj kolejno okna w grupie |
| `Super + Alt + 1/2/3/4/5`               | Przejdź do określonego okna w grupie      |
| `Super + Alt + Arrow`  | Przenieś okno do grupy w kierunku strzałki, w tym na monitorze po tej stronie |
| `Super + Ctrl + Left/Right`  | Poruszaj się między oknami wewnątrz grupy kafelkowej |
| `Super + Ctrl + Z` | Powiększ ekran (powtórz, aby powiększyć bardziej) |
| `Super + Ctrl + Alt + Z` | Pomniejsz ekran całkowicie |
| `Super + /` | Przechodź do przodu przez opcje skalowania monitora |
| `Super + Alt + /` | Przechodź wstecz przez opcje skalowania monitora |
| `Alt + Tab` | Przełączaj kolejno do przodu okna w aktywnym obszarze roboczym |
| `Alt + Shift + Tab` | Przełączaj kolejno wstecz okna w aktywnym obszarze roboczym |
| `Ctrl + Alt + Tab`| Przełączaj fokus do przodu przez monitory |
| `Ctrl + Alt + Shift + Tab`| Przełączaj fokus wstecz przez monitory |
| `Super + I` | Przełącz język wprowadzania (przy więcej niż jednym układzie lub metodzie wprowadzania) |
| `Super + Shift + I` | Przełącz język wprowadzania z powrotem |

Na touchpadzie przesunięcia trzema i czterema palcami przełączają obszary robocze, przenoszą okna oraz otwierają menu i konsolę Quake; gesty znajdziesz w [klawiatura, mysz i touchpad](34-keyboard-mouse-trackpad.md).

Skróty zmiany rozmiaru używają fizycznych klawiszy `code:20` i `code:21` (XKB `<AE11>` i `<AE12>`), niezależnie od znaków nadrukowanych na klawiaturze. Na klawiaturach US tymi klawiszami są `-` i `=`; na japońskich klawiaturach (JIS) są to `-` i `^`; na klawiaturach hiszpańskich są to `'` i `¡`. W JIS `Super + ^` to `Super + Equal`, natomiast `Super + Shift + -` (które wpisuje `=`) to `Super + Shift + Minus`.

## Sterowanie systemem

| Skrót klawiszowy                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Panel audio    |
| `Super + Ctrl + B`           | Panel Bluetooth    |
| `Super + Ctrl + N`           | Panel Wi-Fi/sieci    |
| `Super + Ctrl + D`           | Panel wyświetlacza    |
| `Super + Ctrl + P`           | Panel zasilania    |
| `Super + Ctrl + X`           | Panel agentów    |
| `Super + Ctrl + Shift + X`           | Panel modeli lokalnych    |
| `Super + Ctrl + Alt + D`           | Panel kalendarza    |
| `Super + Ctrl + Alt + E`           | Panel zegara światowego    |
| `Super + Ctrl + 1-9`           | Przełącz panel paska według pozycji    |
| `Super + Ctrl + S` | Menu udostępniania (przez LocalSend) |
| `Super + Ctrl + C` | Sterowanie przechwytywaniem (zrzut ekranu/nagrywanie/picker) |
| `Super + Ctrl + O` | Przełącz menu |
| `Super + Ctrl + H` | Menu sprzętu |
| `Super + Ctrl + E` | Wybierak emoji |
| `Super + Ctrl + .` | Transkoduj multimedia |
| `Super + Shift + Ctrl + A` | Wybierz agenta AI |
| `Power` key | Menu systemowe |
| `Super + Shift + Copilot` key | Menu Omarchy |

## Regulacje

| Skrót klawiszowy                  | Funkcja              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maksymalna jasność ekranu |
| `Shift + Brightness Down` | Minimalna jasność ekranu |
| `Alt + Brightness Up/Down` | Precyzyjne zmiany jasności co 1% |
| `Alt + Volume Up/Down` | Precyzyjne zmiany głośności co 1% |
| `Keyboard Brightness Up/Down` | Jaśniejsze/słabsze podświetlenie klawiatury |
| `Keyboard Backlight` | Przełączaj kolejno poziomy podświetlenia klawiatury |
| `Ctrl + Brightness Up/Down` | Jaśniejsze/słabsze podświetlenie klawiatury na klawiaturach bez własnych klawiszy |
| `Mic Mute` | Wycisz mikrofon |
| `Shift + Mute` | Przełącz wyjście audio |
| `Touchpad Toggle` | Włącz lub wyłącz touchpad |
| `Display` key | Przełącz układ obszaru roboczego |
| `Alt + Play` | Następny utwór |
| `Alt + Shift + Play` | Poprzedni utwór |

## Uruchamianie aplikacji

| Skrót klawiszowy                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Terminal Tmux |
| `Super + Ctrl + Return` | Herdr (menedżer agentów) |
| `Super + Shift + Return` or `Super + Shift + B`  | Przeglądarka    |
| `Super + Shift + Alt + B`           | Przeglądarka (prywatna/incognito)    |
| `Super + Shift + F`           | Menedżer plików    |
| `Super + Shift + Alt + F`           | Menedżer plików w bieżącym katalogu terminala    |
| `Super + Shift + M`           | Muzyka (Spotify)    |
| `Super + Shift + Alt + M`           | Muzyka (cliamp)    |
| `Super + Shift + /`           | Menedżer haseł (1password)    |
| `Super + Shift + Q` or `Calculator` key  | Kalkulator (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, po zainstalowaniu)    |
| `Super + Shift + T`           | Aktywność (btop)    |
| `Super + Shift + N`           | Edytor (Plain lub wybrany przez ciebie domyślny)  |
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
| `Super + Shift + Alt + X`           | X (nowy post) |
| `Super + Shift + Y`           | YouTube |

Zmień/dodaj powiązania w `~/.config/hypr/bindings.lua`.

## Uniwersalny schowek

| Skrót klawiszowy                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + A`           | Zaznacz wszystko w aplikacjach obsługujących `Ctrl + A`    |
| `Super + C`           | Kopiuj    |
| `Super + X`           | Wytnij (nie w terminalu)    |
| `Super + V`           | Wklej    |
| `Super + Ctrl + V`           | Menedżer schowka    |

Zazwyczaj w Linuksie w terminalu potrzebujesz `Ctrl + Shift + C/V`, żeby kopiować i wklejać, a `Ctrl + C/V`, żeby robić to wszędzie indziej. Te ujednolicone skróty schowka Omarchy działają wszędzie.

## Przechwytywanie

| Skrót klawiszowy              | Funkcja                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Zrzut ekranu                      |
| `Super + Ctrl + Alt + C`            | Zrzut ekranu (ten sam zrzut, dla klawiatur bez klawisza Print Screen) |
| `Super + Ctrl + C` | Menu przechwytywania |
| `Alt + Print Screen`            | Nagrywanie ekranu                     |
| `Super + Shift + Ctrl + Alt + C` | Nagrywanie ekranu bez dźwięku, z pominięciem menu (naciśnij ponownie, aby zatrzymać) |
| `Super + Print Screen` | Próbnik kolorów |
| `Super + Ctrl + Print Screen` | Wyodrębnianie tekstu do schowka |
| `Super + Alt + [` | Zmniejsz nakładkę kamery internetowej podczas nagrywania |
| `Super + Alt + ]` | Powiększ nakładkę kamery internetowej podczas nagrywania |
| `Alt + Shift + L` | Kopiuj bieżący URL z aplikacji internetowej lub przeglądarki |
| `Alt + Shift + D` | Pobierz wideo z bieżącej strony do `~/Videos` |
| `Alt + Space` | Rozpocznij/zatrzymaj dyktowanie (wymaga _Setup > Defaults > Dictation_) |
| `Right Alt` | Przytrzymaj, aby dyktować (wymaga _Setup > Defaults > Dictation_) |

Przy nagrywaniu ekranu skrót najpierw pyta, jaki dźwięk chcesz, a potem rozpoczyna nagrywanie. Naciśnij go ponownie, aby zatrzymać. Szczegóły znajdziesz w [zrzuty ekranu i nagrywanie](12-screenshots-recording.md).

Wszystkie opcje przechwytywania są też dostępne w _Trigger > Capture_ w menu Omarchy (`Super + Space`).

## Powiadomienia

| Skrót klawiszowy                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + ,` | Wykonaj akcję na najnowszym powiadomieniu: otwórz je lub naciśnij jego jedyny przycisk, wybierz spośród jego opcji albo odrzuć je, gdy nie ma żadnej  |
| `Super + Shift + ,` | Odrzuć wszystkie powiadomienia |
| `Super + Ctrl + ,` | Steruj powiadomieniami za pomocą klawiatury  |
| `Super + Alt + ,` | Odrzuć najnowsze powiadomienie  |
| `Super + Shift + Alt + ,` | Otwórz historię powiadomień  |
| `Super + Ctrl + Alt + ,` | Przełącz wyciszanie powiadomień  |

## Styl

| Skrót klawiszowy                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Wybierz nowy motyw (również `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Wybierz tło motywu (również `Super + Ctrl + Space`) |
| `Super + Backspace` | Przełącz przezroczystość okna |
| `Super + Ctrl + Backspace` | Przełącz kwadratowe proporcje pojedynczego okna |

Dodatkowe obrazy tła znajdują się w `~/.config/omarchy/backgrounds/<theme name>`. Dostępne również przez _Install > Style > Background_ w menu Omarchy.

Wszystkie opcje stylu są też dostępne w _Appearance_ w menu Omarchy (`Super + Space`).

## Przełączniki

| Skrót klawiszowy                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Przełącz blokowanie przy bezczynności |
| `Super + Ctrl + Delete` | Przełącz włączanie/wyłączanie wyświetlacza laptopa |
| `Super + Ctrl + Alt + Delete` | Przełącz dublowanie wyświetlacza laptopa |
| `Super + Shift + Space` | Przełącz górny pasek  |
| `Shift + Mute` | Przełącz na następne wyjście audio |
| `Shift + Play` | Przełącz na następne źródło multimediów |
| `Super + Shift + Backspace` | Przełącz przerwy między oknami |
| `Super + Ctrl + Alt + F` | Przełącz pełnoekranowy pulpit (górny pasek + przerwy między oknami) |

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

Klawisz prefix to `Ctrl + Space` (`Ctrl + B` też działa). Te powiązania możesz zmienić w `~/.config/tmux/tmux.conf`.

### Okienka

| Skrót klawiszowy                  | Funkcja              |
| ----------------------- | --------------------- |
| `Prefix + v` | Podziel okienko obok (pionowo) |
| `Prefix + h` | Podziel okienko poniżej (poziomo) |
| `Prefix + x` | Zamknij okienko |
| `Prefix + z` | Przełącz powiększenie okienka (pełny ekran) |
| `Alt + Enter` | Podziel okienko poniżej (bez prefixu) |
| `Alt + Shift + Enter` | Podziel okienko obok (bez prefixu) |
| `Alt + Escape` | Zamknij okienko (bez prefixu) |
| `Ctrl + Alt + Arrows` | Poruszaj się między okienkami |
| `Ctrl + Alt + Shift + Arrows` | Zmień rozmiar okienek |

### Okna

| Skrót klawiszowy                  | Funkcja              |
| ----------------------- | --------------------- |
| `Prefix + c` | Nowe okno |
| `Prefix + k` | Zamknij okno |
| `Prefix + r` | Zmień nazwę okna |
| `Alt + 1-9` | Przejdź do określonego okna |
| `Alt + Arrow Left/Right` | Poruszaj się między oknami |
| `Alt + Shift + Arrow Left/Right` | Przenieś okno w lewo/w prawo |

### Sesje

| Skrót klawiszowy                  | Funkcja              |
| ----------------------- | --------------------- |
| `Prefix + C` | Nowa sesja |
| `Prefix + K` | Zamknij sesję |
| `Prefix + R` | Zmień nazwę sesji |
| `Prefix + N` | Następna sesja |
| `Prefix + P` | Poprzednia sesja |
| `Alt + Arrow Up/Down` | Poruszaj się między sesjami |
| `Prefix + s` | Wyświetl listę sesji |
| `Prefix + d` | Odłącz się od sesji |

### Tryb kopiowania (w stylu vi)

| Skrót klawiszowy                  | Funkcja              |
| ----------------------- | --------------------- |
| `Prefix + [` | Wejdź w tryb kopiowania |
| `v` | Rozpocznij zaznaczanie (w trybie kopiowania) |
| `y` | Kopiuj zaznaczenie (w trybie kopiowania) |

### Ogólne

| Skrót klawiszowy                  | Funkcja              |
| ----------------------- | --------------------- |
| `Prefix + q` | Przeładuj konfigurację |
| `Prefix + ?` | Pokaż powiązania klawiszy Tmux |
| `Prefix + :` | Wiersz poleceń |

### Funkcje układu Tmux

Tych funkcji należy używać wewnątrz sesji Tmux.

| Polecenie | Funkcja |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Utwórz układ deweloperski z edytorem, AI i terminalem |
| `tdlm <ai> [<second_ai>]` | Utwórz układ deweloperski dla każdego podkatalogu |
| `tsl <count> <command>` | Utwórz układ roju z wieloma okienkami |

## Terminal Ghostty

Terminal Ghostty instaluje się za pomocą _Install > Terminal_ w menu Omarchy.

| Skrót klawiszowy                  | Funkcja              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nowy podział poniżej |
| `Ctrl + Shift + O` | Nowy podział obok |
| `Ctrl + Alt + Arrows` | Poruszaj się między podziałami |
| `Super + Ctrl + Shift + Arrows` | Zmień rozmiar podziału o 10 wierszy |
| `Super + Ctrl + Shift + Alt + Arrows` | Zmień rozmiar podziału o 100 wierszy |
| `Ctrl + Shift + T` | Nowa karta  |
| `Ctrl + Shift + Arrows` | Poruszaj się między kartami |
| `Alt + Numbers` | Przejdź do określonej karty |
| `Shift + Pg Up/Down` | Przewijaj historię |
| `Ctrl + Left mouse` | Otwórz link w przeglądarce |

## Menedżer plików

| Skrót klawiszowy              | Funkcja                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Przejdź do ścieżki                     |
| `Space`               | Podgląd pliku (strzałki nawigują) |
| `Alt + Up`       | Przejdź w górę do folderu nadrzędnego        |

## Neovim (z lazyvim)

### Nawigacja

| Skrót klawiszowy                   | Funkcja                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Pokaż opcje poleceń            |
| `Space Space`              | Otwórz plik przez wyszukiwanie rozmyte      |
| `Space E`                  | Przełącz pasek boczny                  |
| `Space G G`                | Pokaż sterowanie git               |
| `Space S G`                | Wyszukaj treść pliku             |
| `Ctrl + W W`               | Przechodź między paskiem bocznym a edytorem |
| `Ctrl + Left/right arrow`  | Zmień rozmiar paska bocznego          |
| `Shift + H`                      | Przejdź do lewej karty pliku             |
| `Shift + L`                      | Przejdź do prawej karty pliku            |
| `Space B D`                | Zamknij kartę pliku                  |

### Gdy jesteś na pasku bocznym

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
| `Shift + CapsLock M B` |🤯 | oszołomienie |

## Szybkie uzupełnienia

| Skrót klawiszowy       | Uzupełnienie       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (myślnik)   |
| `Shift + CapsLock Space N` | Twoja nazwa (podana podczas konfiguracji)  |
| `Shift + CapsLock Space E` | Twój e-mail (podany podczas konfiguracji)  |

Możesz dodać więcej własnych, edytując `~/.XCompose`, a następnie uruchamiając `omarchy restart xcompose` w terminalu, aby zmiany zostały wykryte.
