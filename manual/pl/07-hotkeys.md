# Skróty klawiszowe

Możesz zobaczyć wszystkie główne skróty klawiszowe za pomocą `Super + K` (skróty Tmux za pomocą `Super + Alt + K`, a skróty Herdr za pomocą `Super + Ctrl + K`).

## Jak ułożone są skróty klawiszowe

Każdy skrót klawiszowy znajduje się na płaszczyźnie wyznaczonej przez jego modyfikatory, a każda płaszczyzna ma jedno zadanie. To właśnie sprawia, że skróty nie zlewają się ze sobą, i oznacza, że zwykle możesz zgadnąć, gdzie coś się znajduje.

| Płaszczyzna | Co na niej jest | Przykłady |
| --- | --- | --- |
| `Super + key` | System: okna, przestrzenie robocze, układy i główne menu | `Super + Space` menu Omarchy, `Super + W` zamknij okno, `Super + F` pełny ekran |
| `Super + Shift + key` | Aplikacje | `Super + Shift + B` przeglądarka, `Super + Shift + E` e-mail, `Super + Shift + N` edytor |
| `Super + Ctrl + key` | Panele i menu systemowe | `Super + Ctrl + A` audio, `Super + Ctrl + N` sieć, `Super + Ctrl + C` menu przechwytywania |
| `Super + Ctrl + Alt + key` | Szybkie akcje i komunikaty | `Super + Ctrl + Alt + T` pokaż czas, `Super + Ctrl + Alt + B` bateria, `Super + Ctrl + Alt + C` zrzut ekranu |

Dodanie `Alt` do skrótu daje wariant tej samej rzeczy, nigdy coś niezwiązanego:

- `Super + Shift + B` otwiera przeglądarkę; `Super + Shift + Alt + B` otwiera okno prywatne
- `Super + Shift + E` otwiera e-mail; `Super + Shift + Alt + E` rozpoczyna nowy
- `Super + F` przechodzi na pełny ekran; `Super + Alt + F` przechodzi na pełną szerokość
- `Super + Ctrl + C` otwiera menu przechwytywania; `Super + Ctrl + Alt + C` pomija menu i robi zrzut ekranu

Gdy dodajesz skrót:

1. Wybierz płaszczyznę na podstawie tego, co robi, a potem wybierz klawisz.
2. Nie przenoś istniejącego skrótu, żeby zrobić miejsce. Znajdź wolny klawisz na właściwej płaszczyźnie.
3. Używaj `Alt` tylko do wariantu skrótu bez niego.

Kilka skrótów łamie te zasady, bo tak jest wygodniej. `Shift` ze strzałką lub `Tab` przenosi lub odwraca zamiast otwierać aplikację, a `Print`, klawisze multimedialne, `Alt + Tab` i `Ctrl + Alt + Del` działają tak, jak wszędzie indziej. To wyjątki, nie wzorce do kopiowania.

Jeśli domyślny Ci nie pasuje (powiedzmy, że chcesz `Super + Shift + S` do zrzutów ekranu jak w Windows), przypisz go na nowo w `~/.config/hypr/bindings.lua`.

## Nawigacja

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + Space`           | Menu Omarchy (aplikacje i wszystko inne)    |
| `Super + Alt + Space` | Siatka aplikacji |
| `Super + Escape` | Menu systemowe (uśpij, uruchom ponownie itd.)  |
| `Super + Ctrl + L` | Zablokuj komputer |
| `Super + W` or `Super + Q` | Zamknij okno             |
| `Ctrl + Alt + Del` | Zamknij wszystkie okna |
| `Super + K` | Pokaż wszystkie skróty klawiszowe |
| `Super + Alt + K` | Pokaż skróty klawiszowe tmux |
| `Super + Ctrl + K` | Pokaż skróty klawiszowe herdr |
| `Super + M` | Zminimalizuj okno do docka |
| `Super + T`               | Przełącz okno między trybem kafelkowym a pływającym             |
| `Super + J` | Przełącz pozycję okna (poziomo/pionowo) |
| `Super + O`               | Przełącz okno w tryb sticky'n'floating |
| `Super + L`               | Przełączaj między układami dwindle, scrolling i floating |
| `Super + Alt + L`         | Przełączaj układy w odwrotnej kolejności |
| `Super + P`               | Przełącz styl pseudo okna (naturalny kontra rozciągnięty) |
| `Super + F`                 | Przejdź na pełny ekran              |
| `Super + Alt + F`                 | Przejdź na pełną szerokość              |
| `Super + Ctrl + F`                 | Przejdź na pełny ekran wewnątrz okna              |
| `Super + 1…9/0`         | Przejdź do konkretnej przestrzeni roboczej (0 to 10) na aktywnym monitorze |
| `Super + Tab` | Przejdź do następnej przestrzeni roboczej na aktywnym monitorze |
| `Super + Shift + Tab` | Przejdź do poprzedniej przestrzeni roboczej na aktywnym monitorze |
| `Super + Ctrl + Tab` | Przejdź do wcześniejszej przestrzeni roboczej na aktywnym monitorze |
| `Super + Shift + 1…9/0` | Przenieś okno do przestrzeni roboczej na aktywnym monitorze |
| `Super + Shift + Alt + 1…9/0` | Przenieś okno do przestrzeni roboczej na aktywnym monitorze bez podążania za nim |
| `Super + S` | Przełącz pełny scratchpad |
| `Super + Alt + S` | Przenieś okno do pełnego scratchpada |
| `Super + the key above Tab` (grave w układach amerykańskich) | Przełącz konsolę Quake |
| `Super + Shift + the key above Tab` (grave w układach amerykańskich) | Przenieś okno do konsoli Quake |
| `Super + Shift + Ctrl + Arrows` | Przenieś okno na monitor w tym kierunku |
| `Super + Shift + Alt + Arrows` | Przenieś przestrzeń roboczą na monitor w tym kierunku |
| `Super + Arrow`  | Przenieś fokus na okno w kierunku strzałki, przechodząc na monitor po tej stronie na krawędzi ekranu |
| `Super + Shift + Arrow`  | Zamień okno z innym w kierunku strzałki, w tym z oknem na monitorze po tej stronie |
| `Super + Minus` | Powiększ okno w lewo |
| `Super + Equal` | Pomniejsz okno w lewo |
| `Super + Shift + Minus` | Pomniejsz okno w górę |
| `Super + Shift + Equal` | Powiększ okno w dół |
| `Super + Alt + Minus/Equal` | To samo zmienianie rozmiaru w mniejszych krokach |
| `Super + Ctrl + Minus/Equal` | To samo zmienianie rozmiaru w większych krokach |
| `Super + Alt + Home` | Zapisz szerokość okna |
| `Super + Home` | Przywróć zapisaną szerokość okna |
| `Super + Left Mouse` | Przeciągaj okno |
| `Super + Right Mouse` | Zmień rozmiar okna |
| `Super + Scroll Wheel` | Przewijaj przestrzenie robocze na aktywnym monitorze |
| `Super + G`               | Przełącz grupowanie okien      |
| `Super + Alt + G`               | Wyprowadź okno z grupy      |
| `Super + Alt + Tab`               | Przełączaj między oknami w grupie      |
| `Super + Alt + Shift + Tab`               | Przełączaj wstecz między oknami w grupie      |
| `Super + Alt + Scroll Wheel` | Przełączaj między oknami w grupie |
| `Super + Alt + 1/2/3/4/5`               | Przejdź do konkretnego okna w grupie      |
| `Super + Alt + Arrow`  | Przenieś okno do grupy w kierunku strzałki, w tym okno na monitorze po tej stronie |
| `Super + Ctrl + Left/Right`  | Przechodź między oknami wewnątrz grupy kafelkowej |
| `Super + Ctrl + Z` | Powiększ ekran (powtórz, aby powiększyć bardziej) |
| `Super + Ctrl + Alt + Z` | Całkowicie pomniejsz ekran |
| `Super + /` | Przechodź do przodu przez opcje skalowania monitora |
| `Super + Alt + /` | Przechodź wstecz przez opcje skalowania monitora |
| `Alt + Tab` | Przełączaj do przodu między oknami w aktywnej przestrzeni roboczej |
| `Alt + Shift + Tab` | Przełączaj wstecz między oknami w aktywnej przestrzeni roboczej |
| `Ctrl + Alt + Tab`| Przełączaj fokus do przodu między monitorami |
| `Ctrl + Alt + Shift + Tab`| Przełączaj fokus wstecz między monitorami |
| `Super + I` | Przełącz język wprowadzania (przy więcej niż jednym układzie lub metodzie wprowadzania) |
| `Super + Shift + I` | Przełącz język wprowadzania z powrotem |

Na touchpadzie przeciągnięcia trzema i czterema palcami przełączają przestrzenie robocze, przenoszą okna oraz otwierają menu i konsolę Quake; zobacz [klawiatura, mysz i touchpad](34-keyboard-mouse-trackpad.md), aby poznać gesty.

Zmiana rozmiaru używa dwóch klawiszy na prawo od 0, cokolwiek Twoja klawiatura na nich drukuje: `-` i `=` na klawiaturach amerykańskich, `+` i `´` na duńskich i szwedzkich, `+` i `\` na norweskiej, `ß` i `´` na niemieckiej, `'` i `¡` na hiszpańskiej oraz `-` i `^` na japońskiej (JIS). `Super + K` wyświetla je tak, jak drukuje je Twoja klawiatura. Na JIS `Super + ^` to `Super + Equal`, natomiast `Super + Shift + -` (który wpisuje `=`) to `Super + Shift + Minus`. Skalowanie monitora i menedżer haseł używają `/`; w układach, które wpisują `/` tylko z Shift, jak większość europejskich, używają zamiast tego klawisza na lewo od prawego Shift (`-` na duńskim i niemieckim).

## Sterowanie systemowe

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
| `Super + Ctrl + C` | Sterowanie przechwytywaniem (zrzut ekranu/nagrywanie/wybierak) |
| `Super + Ctrl + O` | Przełącz menu |
| `Super + Ctrl + H` | Menu sprzętu |
| `Super + Ctrl + E` | Wybierak emoji |
| `Super + Ctrl + .` | Transkoduj multimedia |
| `Super + Shift + Ctrl + A` | Uruchom domyślnego agenta |
| `Power` klawisz | Menu systemowe |
| `Super + Shift + Copilot` klawisz | Menu Omarchy |

## Regulacje

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maksymalna jasność ekranu |
| `Shift + Brightness Down` | Minimalna jasność ekranu |
| `Alt + Brightness Up/Down` | Precyzyjne zmiany jasności co 1% |
| `Alt + Volume Up/Down` | Precyzyjne zmiany głośności co 1% |
| `Keyboard Brightness Up/Down` | Podświetlenie klawiatury jaśniejsze/słabsze |
| `Keyboard Backlight` | Przełączaj poziomy podświetlenia klawiatury |
| `Ctrl + Brightness Up/Down` | Podświetlenie klawiatury jaśniejsze/słabsze, na klawiaturach bez własnych klawiszy |
| `Mic Mute` | Wycisz mikrofon |
| `Shift + Mute` | Przełącz wyjście audio |
| `Touchpad Toggle` | Włącz lub wyłącz touchpad |
| `Display` klawisz | Przełączaj układ przestrzeni roboczej |
| `Alt + Play` | Następny utwór |
| `Alt + Shift + Play` | Poprzedni utwór |

## Uruchamianie aplikacji

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminal    |
| `Super + Alt + Return` | Terminal Tmux |
| `Super + Ctrl + Return` | Herdr (menedżer agentów) |
| `Super + Shift + Return` or `Super + Shift + B`  | Przeglądarka    |
| `Super + Shift + Alt + B`           | Przeglądarka (prywatna/incognito)    |
| `Super + Shift + F`           | Menedżer plików    |
| `Super + Shift + Alt + F`           | Menedżer plików w cwd terminala    |
| `Super + Shift + M`           | Muzyka (Spotify)    |
| `Super + Shift + Alt + M`           | Muzyka (cliamp)    |
| `Super + Shift + /`           | Menedżer haseł (1password)    |
| `Super + Shift + Q` or `Calculator` klawisz  | Kalkulator (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, po zainstalowaniu)    |
| `Super + Shift + T`           | Aktywność (btop)    |
| `Super + Shift + N`           | Edytor (Plain lub wybrany przez Ciebie domyślny)  |
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

Zmień/dodaj przypisania w `~/.config/hypr/bindings.lua`.

## Uniwersalny schowek

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + A`           | Zaznacz wszystko w aplikacjach obsługujących `Ctrl + A`    |
| `Super + C`           | Kopiuj    |
| `Super + X`           | Wytnij (nie w terminalu)    |
| `Super + V`           | Wklej    |
| `Super + Ctrl + V`           | Menedżer schowka    |

Zwykle w systemie Linux potrzebujesz `Ctrl + Shift + C/V`, aby kopiować i wklejać w terminalu, oraz `Ctrl + C/V`, aby robić to wszędzie indziej. Te ujednolicone skróty schowka Omarchy działają wszędzie.

## Przechwytywanie

| Skrót              | Funkcja                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Zrzut ekranu                      |
| `Super + Ctrl + Alt + C`            | Zrzut ekranu (ten sam zrzut, dla klawiatur bez klawisza Print Screen) |
| `Super + Ctrl + C` | Menu przechwytywania |
| `Alt + Print Screen`            | Nagrywanie ekranu                     |
| `Super + Shift + Ctrl + Alt + C` | Nagrywanie ekranu bez dźwięku, z pominięciem menu (naciśnij ponownie, aby zatrzymać) |
| `Super + Print Screen` | Wybierak koloru |
| `Super + Ctrl + Print Screen` | Wyodrębnianie tekstu do schowka |
| `Super + Alt + [` | Zmniejsz nakładkę kamery internetowej podczas nagrywania |
| `Super + Alt + ]` | Powiększ nakładkę kamery internetowej podczas nagrywania |
| `Alt + Shift + L` | Kopiuj bieżący URL z aplikacji webowej lub przeglądarki |
| `Alt + Shift + D` | Pobierz wideo z bieżącej strony do `~/Videos` |
| `Alt + Space` | Start/stop dyktowania (wymaga _Setup > Defaults > Dictation_) |
| `Right Alt` | Przytrzymaj, aby dyktować (wymaga _Setup > Defaults > Dictation_) |

Przy nagrywaniu ekranu skrót najpierw pyta, jakiego dźwięku chcesz, a potem zaczyna nagrywać. Naciśnij go ponownie, aby zatrzymać. Zobacz [zrzuty ekranu i nagrywanie](12-screenshots-recording.md), aby poznać szczegóły.

Wszystkie opcje przechwytywania są też dostępne w _Trigger > Capture_ w menu Omarchy (`Super + Space`).

## Powiadomienia

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + ,` | Działaj na najnowszym powiadomieniu: otwórz je lub naciśnij jego jedyny przycisk, wybierz spośród jego opcji albo odrzuć je, gdy nie ma żadnej  |
| `Super + Shift + ,` | Odrzuć wszystkie powiadomienia |
| `Super + Ctrl + ,` | Steruj powiadomieniami za pomocą klawiatury  |
| `Super + Alt + ,` | Odrzuć najnowsze powiadomienie  |
| `Super + Shift + Alt + ,` | Otwórz historię powiadomień  |
| `Super + Ctrl + Alt + ,` | Przełącz wyciszanie powiadomień  |

## Styl

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Wybierz nowy motyw (także `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Wybierz tło motywu (także `Super + Ctrl + Space`) |
| `Super + Backspace` | Przełącz przezroczystość okna |
| `Super + Ctrl + Backspace` | Przełącz kwadratowe proporcje pojedynczego okna |

Dodatkowe obrazy tła znajdują się w `~/.config/omarchy/backgrounds/<theme name>`. Dostępne także przez _Install > Style > Background_ w menu Omarchy.

Wszystkie opcje stylu są też dostępne w _Appearance_ w menu Omarchy (`Super + Space`).

## Przełączniki

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Przełącz blokowanie przy bezczynności |
| `Super + Ctrl + Delete` | Przełącz wyświetlacz laptopa wł./wył. |
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

Klawisz prefix to `Ctrl + Space` (`Ctrl + B` też działa). Możesz zmienić te przypisania w `~/.config/tmux/tmux.conf`.

### Panele

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Prefix + v` | Podziel panel obok (pionowo) |
| `Prefix + h` | Podziel panel poniżej (poziomo) |
| `Prefix + x` | Zamknij panel |
| `Prefix + z` | Przełącz powiększenie panelu (pełny ekran) |
| `Alt + Enter` | Podziel panel poniżej (bez prefiksu) |
| `Alt + Shift + Enter` | Podziel panel obok (bez prefiksu) |
| `Alt + Escape` | Zamknij panel (bez prefiksu) |
| `Ctrl + Alt + Arrows` | Przechodź między panelami |
| `Ctrl + Alt + Shift + Arrows` | Zmień rozmiar paneli |

### Okna

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Prefix + c` | Nowe okno |
| `Prefix + k` | Zamknij okno |
| `Prefix + r` | Zmień nazwę okna |
| `Alt + 1-9` | Przejdź do konkretnego okna |
| `Alt + Arrow Left/Right` | Przechodź między oknami |
| `Alt + Shift + Arrow Left/Right` | Przenieś okno w lewo/w prawo |

### Sesje

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Prefix + C` | Nowa sesja |
| `Prefix + K` | Zamknij sesję |
| `Prefix + R` | Zmień nazwę sesji |
| `Prefix + N` | Następna sesja |
| `Prefix + P` | Poprzednia sesja |
| `Alt + Arrow Up/Down` | Przechodź między sesjami |
| `Prefix + s` | Wyświetl listę sesji |
| `Prefix + d` | Odłącz od sesji |

### Tryb kopiowania (w stylu vi)

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Prefix + [` | Wejdź w tryb kopiowania |
| `v` | Rozpocznij zaznaczanie (w trybie kopiowania) |
| `y` | Kopiuj zaznaczenie (w trybie kopiowania) |

### Ogólne

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Prefix + q` | Przeładuj konfigurację |
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

Terminal Ghostty instaluje się za pomocą _Install > Terminal_ w menu Omarchy.

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nowy podział poniżej |
| `Ctrl + Shift + O` | Nowy podział obok |
| `Ctrl + Alt + Arrows` | Przechodź między podziałami |
| `Super + Ctrl + Shift + Arrows` | Zmień rozmiar podziału o 10 wierszy |
| `Super + Ctrl + Shift + Alt + Arrows` | Zmień rozmiar podziału o 100 wierszy |
| `Ctrl + Shift + T` | Nowa karta  |
| `Ctrl + Shift + Arrows` | Przechodź między kartami |
| `Alt + Numbers` | Przejdź do konkretnej karty |
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
| `Space G G`                | Pokaż sterowanie git               |
| `Space S G`                | Szukaj w treści pliku             |
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
| `Shift + CapsLock M B` |🤯 | wybuch |

## Szybkie uzupełnienia

| Skrót       | Uzupełnienie       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Twoje imię (jak podano podczas konfiguracji)  |
| `Shift + CapsLock Space E` | Twój e-mail (jak podano podczas konfiguracji)  |

Możesz dodać więcej własnych, edytując `~/.XCompose`, a następnie uruchamiając `omarchy restart xcompose` w terminalu, aby zmiany zostały wczytane.
