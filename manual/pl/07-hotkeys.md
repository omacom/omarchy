# Skróty klawiszowe

Wszystkie główne skróty klawiszowe możesz zobaczyć za pomocą `Super + K` (skróty Tmux za pomocą `Super + Alt + K`, a skróty Herdr za pomocą `Super + Ctrl + K`).

## Jak są zorganizowane skróty klawiszowe

Każdy skrót klawiszowy znajduje się na jednej płaszczyźnie wyznaczonej przez jego modyfikatory, a każda płaszczyzna ma jedno zadanie. Dzięki temu skróty się ze sobą nie zlewają i zwykle możesz odgadnąć, gdzie czegoś szukać.

| Płaszczyzna | Co na niej jest | Przykłady |
| --- | --- | --- |
| `Super + key` | System: okna, obszary robocze, układy i podstawowe menu | `Super + Space` menu Omarchy, `Super + W` zamknięcie okna, `Super + F` pełny ekran |
| `Super + Shift + key` | Aplikacje | `Super + Shift + B` przeglądarka, `Super + Shift + E` e-mail, `Super + Shift + N` edytor |
| `Super + Ctrl + key` | Panele i menu systemowe | `Super + Ctrl + A` dźwięk, `Super + Ctrl + N` sieć, `Super + Ctrl + C` menu przechwytywania |
| `Super + Ctrl + Alt + key` | Szybkie akcje i powiadomienia | `Super + Ctrl + Alt + T` pokazanie czasu, `Super + Ctrl + Alt + B` bateria, `Super + Ctrl + Alt + C` zrzut ekranu |

Dodanie `Alt` do skrótu daje wariant tego samego, nigdy coś niezwiązanego:

- `Super + Shift + B` otwiera przeglądarkę; `Super + Shift + Alt + B` otwiera okno prywatne
- `Super + Shift + E` otwiera e-mail; `Super + Shift + Alt + E` rozpoczyna nowy
- `Super + F` włącza pełny ekran; `Super + Alt + F` włącza pełną szerokość
- `Super + Ctrl + C` otwiera menu przechwytywania; `Super + Ctrl + Alt + C` pomija menu i robi zrzut ekranu

Gdy dodajesz skrót:

1. Wybierz płaszczyznę na podstawie tego, co robi, a potem wybierz klawisz.
2. Nie przenoś istniejącego skrótu, żeby zrobić miejsce. Znajdź wolny klawisz na właściwej płaszczyźnie.
3. Używaj `Alt` tylko dla wariantu skrótu bez niego.

Kilka skrótów łamie te zasady, bo tak jest wygodniej. `Shift` ze strzałką lub `Tab` przenosi lub odwraca zamiast otwierać aplikację, a `Print`, klawisze multimedialne, `Alt + Tab` i `Ctrl + Alt + Del` działają tak samo jak wszędzie indziej. To wyjątki, nie wzorce do naśladowania.

Jeśli domyślny skrót ci nie pasuje (powiedzmy, że chcesz `Super + Shift + S` do zrzutów ekranu tak jak w Windows), przypisz go na nowo w `~/.config/hypr/bindings.lua`.

## Nawigacja

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + Space`           | Menu Omarchy (aplikacje i wszystko inne)    |
| `Super + Alt + Space` | Siatka aplikacji |
| `Super + Escape` | Menu systemowe (uśpienie, ponowne uruchomienie itd.)  |
| `Super + Ctrl + L` | Zablokowanie komputera |
| `Super + W` or `Super + Q` | Zamknięcie okna             |
| `Ctrl + Alt + Del` | Zamknięcie wszystkich okien |
| `Super + K` | Pokazanie wszystkich skrótów |
| `Super + Alt + K` | Pokazanie skrótów tmux |
| `Super + Ctrl + K` | Pokazanie skrótów herdr |
| `Super + M` | Minimalizacja okna do docka |
| `Super + T`               | Przełączenie okna między trybem kafelkowym/pływającym             |
| `Super + J` | Przełączenie położenia okna (poziomo/pionowo) |
| `Super + O`               | Przełączenie wyskakującego okna w tryb sticky'n'floating |
| `Super + L`               | Przechodzenie po układach dwindle, scrolling i floating |
| `Super + Alt + L`         | Przechodzenie po układach w odwrotnej kolejności |
| `Super + P`               | Przełączenie stylu pseudo okna (naturalny vs rozciągnięty) |
| `Super + F`                 | Pełny ekran              |
| `Super + Alt + F`                 | Pełna szerokość              |
| `Super + Ctrl + F`                 | Pełny ekran wewnątrz okna              |
| `Super + 1…9/0`         | Przejście do konkretnego obszaru roboczego (0 to 10) na monitorze z fokusem |
| `Super + Tab` | Przejście do następnego obszaru roboczego na monitorze z fokusem |
| `Super + Shift + Tab` | Przejście do poprzedniego obszaru roboczego na monitorze z fokusem |
| `Super + Ctrl + Tab` | Przejście do wcześniejszego obszaru roboczego na monitorze z fokusem |
| `Super + Shift + 1…9/0` | Przeniesienie okna do obszaru roboczego na monitorze z fokusem |
| `Super + Shift + Alt + 1…9/0` | Przeniesienie okna do obszaru roboczego na monitorze z fokusem bez podążania za nim |
| `Super + S` | Przełączenie pełnego scratchpada |
| `Super + Alt + S` | Przeniesienie okna do pełnego scratchpada |
| `Super + Grave` | Przełączenie konsoli Quake |
| `Super + Shift + Grave` | Przeniesienie okna do konsoli Quake |
| `Super + Shift + Ctrl + Arrows` | Przeniesienie okna do monitora w tym kierunku |
| `Super + Shift + Alt + Arrows` | Przeniesienie obszaru roboczego do monitora w tym kierunku |
| `Super + Arrow`  | Przeniesienie fokusu na okno w kierunku strzałki, z przejściem na monitor po tej stronie na krawędzi ekranu |
| `Super + Shift + Arrow`  | Zamiana okna z innym w kierunku strzałki, w tym z oknem na monitorze po tej stronie |
| `Super + Minus` | Rozszerzenie okna w lewo |
| `Super + Equal` | Zmniejszenie okna w lewo |
| `Super + Shift + Minus` | Zmniejszenie okna w górę |
| `Super + Shift + Equal` | Rozszerzenie okna w dół |
| `Super + Alt + Minus/Equal` | Ta sama zmiana rozmiaru w mniejszych krokach |
| `Super + Ctrl + Minus/Equal` | Ta sama zmiana rozmiaru w większych krokach |
| `Super + Alt + Home` | Zapisanie szerokości okna |
| `Super + Home` | Przywrócenie zapisanej szerokości okna |
| `Super + Left Mouse` | Przeciąganie okna |
| `Super + Right Mouse` | Zmiana rozmiaru okna |
| `Super + Scroll Wheel` | Przewijanie obszarów roboczych na monitorze z fokusem |
| `Super + G`               | Przełączenie grupowania okna      |
| `Super + Alt + G`               | Wyjęcie okna z grupowania      |
| `Super + Alt + Tab`               | Przechodzenie między oknami w grupie      |
| `Super + Alt + Shift + Tab`               | Przechodzenie wstecz między oknami w grupie      |
| `Super + Alt + Scroll Wheel` | Przechodzenie między oknami w grupie |
| `Super + Alt + 1/2/3/4/5`               | Przejście do konkretnego okna w grupie      |
| `Super + Alt + Arrow`  | Wstawienie okna do grupy w kierunku strzałki, w tym okna na monitorze po tej stronie |
| `Super + Ctrl + Left/Right`  | Przechodzenie między oknami wewnątrz grupy kafelkowej |
| `Super + Ctrl + Z` | Powiększenie ekranu (powtarzaj, aby powiększyć bardziej) |
| `Super + Ctrl + Alt + Z` | Całkowite pomniejszenie ekranu |
| `Super + /` | Krok do przodu po opcjach skalowania monitora |
| `Super + Alt + /` | Krok wstecz po opcjach skalowania monitora |
| `Alt + Tab` | Przechodzenie do przodu po oknach w aktywnym obszarze roboczym |
| `Alt + Shift + Tab` | Przechodzenie wstecz po oknach w aktywnym obszarze roboczym |
| `Ctrl + Alt + Tab`| Przechodzenie fokusu do przodu po monitorach |
| `Ctrl + Alt + Shift + Tab`| Przechodzenie fokusu wstecz po monitorach |
| `Super + I` | Przełączenie języka wprowadzania (przy więcej niż jednym układzie lub metodzie wprowadzania) |
| `Super + Shift + I` | Przełączenie języka wprowadzania wstecz |

Na touchpadzie przeciągnięcia trzema i czterema palcami przełączają obszary robocze, przenoszą okna oraz otwierają menu i konsolę Quake; zobacz [klawiatura, mysz i trackpad](34-keyboard-mouse-trackpad.md), aby poznać gesty.

Skróty zmiany rozmiaru używają fizycznych klawiszy `code:20` i `code:21` (XKB `<AE11>` i `<AE12>`), niezależnie od znaków nadrukowanych na klawiaturze. Na klawiaturach US tymi klawiszami są `-` i `=`; na klawiaturach japońskich (JIS) są to `-` i `^`; na klawiaturach hiszpańskich są to `'` i `¡`. W JIS `Super + ^` to `Super + Equal`, natomiast `Super + Shift + -` (który wpisuje `=`) to `Super + Shift + Minus`.

## Sterowanie systemowe

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Panel dźwięku    |
| `Super + Ctrl + B`           | Panel Bluetooth    |
| `Super + Ctrl + N`           | Panel Wi-Fi/sieci    |
| `Super + Ctrl + D`           | Panel wyświetlacza    |
| `Super + Ctrl + P`           | Panel zasilania    |
| `Super + Ctrl + X`           | Panel agentów    |
| `Super + Ctrl + Alt + D`           | Panel kalendarza    |
| `Super + Ctrl + Alt + E`           | Panel zegara światowego    |
| `Super + Ctrl + 1-9`           | Przełączenie panelu paska według pozycji    |
| `Super + Ctrl + S` | Menu udostępniania (przez LocalSend) |
| `Super + Ctrl + C` | Sterowanie przechwytywaniem (zrzut ekranu/-nagrywanie/wybieranie) |
| `Super + Ctrl + O` | Przełączenie menu |
| `Super + Ctrl + H` | Menu sprzętu |
| `Super + Ctrl + E` | Wybieranie emoji |
| `Super + Ctrl + .` | Transkodowanie multimediów |
| `Super + Shift + Ctrl + A` | Wybór agenta AI |
| `Power` key | Menu systemowe |
| `Super + Shift + Copilot` key | Menu Omarchy |

## Regulacje

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maksymalna jasność ekranu |
| `Shift + Brightness Down` | Minimalna jasność ekranu |
| `Alt + Brightness Up/Down` | Precyzyjne zmiany jasności co 1% |
| `Alt + Volume Up/Down` | Precyzyjne zmiany głośności co 1% |
| `Keyboard Brightness Up/Down` | Podświetlenie klawiatury jaśniej/ciemniej |
| `Keyboard Backlight` | Przechodzenie po poziomach podświetlenia klawiatury |
| `Ctrl + Brightness Up/Down` | Podświetlenie klawiatury jaśniej/ciemniej, na klawiaturach bez własnych klawiszy |
| `Mic Mute` | Wyciszenie mikrofonu |
| `Shift + Mute` | Przełączenie wyjścia dźwięku |
| `Touchpad Toggle` | Włączenie lub wyłączenie touchpada |
| `Display` key | Przechodzenie po układach obszaru roboczego |
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

Zmień/dodaj przypisania w `~/.config/hypr/bindings.lua`.

## Uniwersalny schowek

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + A`           | Zaznaczenie wszystkiego w aplikacjach obsługujących `Ctrl + A`    |
| `Super + C`           | Kopiowanie    |
| `Super + X`           | Wycinanie (nie w terminalu)    |
| `Super + V`           | Wklejanie    |
| `Super + Ctrl + V`           | Menedżer schowka    |

Zwykle w systemie Linux potrzebujesz `Ctrl + Shift + C/V`, aby kopiować'n'wklejać w terminalu, oraz `Ctrl + C/V`, aby robić to wszędzie indziej. Te ujednolicone skróty schowka Omarchy działają wszędzie.

## Przechwytywanie

| Skrót              | Funkcja                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Zrzut ekranu                      |
| `Super + Ctrl + Alt + C`            | Zrzut ekranu (to samo ujęcie, dla klawiatur bez klawisza Print Screen) |
| `Super + Ctrl + C` | Menu przechwytywania |
| `Alt + Print Screen`            | Nagrywanie ekranu                     |
| `Super + Shift + Ctrl + Alt + C` | Nagrywanie ekranu bez dźwięku, z pominięciem menu (naciśnij ponownie, aby zatrzymać) |
| `Super + Print Screen` | Wybieranie koloru |
| `Super + Ctrl + Print Screen` | Wyodrębnianie tekstu do schowka |
| `Super + Alt + [` | Zmniejszenie nakładki kamery internetowej podczas nagrywania |
| `Super + Alt + ]` | Powiększenie nakładki kamery internetowej podczas nagrywania |
| `Alt + Shift + L` | Kopiowanie bieżącego adresu URL z aplikacji internetowej lub przeglądarki |
| `Alt + Shift + D` | Pobranie wideo z bieżącej strony do `~/Videos` |
| `Alt + Space` | Rozpoczęcie/zatrzymanie dyktowania (wymaga _Setup > Defaults > Dictation_) |
| `Right Alt` | Przytrzymaj, aby dyktować (wymaga _Setup > Defaults > Dictation_) |

W przypadku nagrań ekranu skrót najpierw pyta, jaki dźwięk chcesz, a potem rozpoczyna nagrywanie. Naciśnij go ponownie, aby zatrzymać. Zobacz [zrzuty ekranu i nagrywanie](12-screenshots-recording.md), aby poznać szczegóły.

Wszystkie opcje przechwytywania są dostępne także w _Trigger > Capture_ w menu Omarchy (`Super + Space`).

## Powiadomienia

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + ,` | Wykonanie akcji na najnowszym powiadomieniu: otwarcie go lub naciśnięcie jego jedynego przycisku, wybór spośród jego opcji lub odrzucenie go, gdy nie ma żadnej  |
| `Super + Shift + ,` | Odrzucenie wszystkich powiadomień |
| `Super + Ctrl + ,` | Sterowanie powiadomieniami za pomocą klawiatury  |
| `Super + Alt + ,` | Odrzucenie najnowszego powiadomienia  |
| `Super + Shift + Alt + ,` | Otwarcie historii powiadomień  |
| `Super + Ctrl + Alt + ,` | Przełączenie wyciszania powiadomień  |

## Styl

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Wybór nowego motywu (także `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Wybór tła motywu (także `Super + Ctrl + Space`) |
| `Super + Backspace` | Przełączenie przezroczystości okna |
| `Super + Ctrl + Backspace` | Przełączenie kwadratowych proporcji pojedynczego okna |

Dodatkowe obrazy tła znajdują się w `~/.config/omarchy/backgrounds/<theme name>`. Dostępne także przez _Install > Style > Background_ w menu Omarchy.

Wszystkie opcje stylu są dostępne także w _Appearance_ w menu Omarchy (`Super + Space`).

## Przełączniki

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Przełączenie blokowania przy bezczynności |
| `Super + Ctrl + Delete` | Przełączenie wyświetlacza laptopa wł./wył. |
| `Super + Ctrl + Alt + Delete` | Przełączenie dublowania wyświetlacza laptopa |
| `Super + Shift + Space` | Przełączenie górnego paska  |
| `Shift + Mute` | Przełączenie na następne wyjście dźwięku |
| `Shift + Play` | Przełączenie na następne źródło multimediów |
| `Super + Shift + Backspace` | Przełączenie odstępów między oknami |
| `Super + Ctrl + Alt + F` | Przełączenie pulpitu na pełnym ekranie (górny pasek + odstępy między oknami) |

## Przypomnienia

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Ustawienie przypomnienia  |
| `Super + Ctrl + Alt + R` | Wyświetlenie wszystkich przypomnień  |
| `Super + Ctrl + Shift + R` | Wyczyszczenie wszystkich przypomnień  |

## Komunikaty

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Pokazanie czasu jako powiadomienia  |
| `Super + Ctrl + Alt + B` | Pokazanie baterii jako powiadomienia  |
| `Super + Ctrl + Alt + W` | Przełączenie pogody jako powiadomienia  |

## Tmux

Klawiszem prefiksu jest `Ctrl + Space` (`Ctrl + B` też działa). Te przypisania możesz zmienić w `~/.config/tmux/tmux.conf`.

### Pane

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Prefix + v` | Podział panelu obok (pionowo) |
| `Prefix + h` | Podział panelu poniżej (poziomo) |
| `Prefix + x` | Zamknięcie panelu |
| `Prefix + z` | Przełączenie powiększenia panelu (pełny ekran) |
| `Alt + Enter` | Podział panelu poniżej (bez prefiksu) |
| `Alt + Shift + Enter` | Podział panelu obok (bez prefiksu) |
| `Alt + Escape` | Zamknięcie panelu (bez prefiksu) |
| `Ctrl + Alt + Arrows` | Przechodzenie między panelami |
| `Ctrl + Alt + Shift + Arrows` | Zmiana rozmiaru paneli |

### Okna

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Prefix + c` | Nowe okno |
| `Prefix + k` | Zamknięcie okna |
| `Prefix + r` | Zmiana nazwy okna |
| `Alt + 1-9` | Przejście do konkretnego okna |
| `Alt + Arrow Left/Right` | Przechodzenie między oknami |
| `Alt + Shift + Arrow Left/Right` | Przeniesienie okna w lewo/w prawo |

### Sesje

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Prefix + C` | Nowa sesja |
| `Prefix + K` | Zamknięcie sesji |
| `Prefix + R` | Zmiana nazwy sesji |
| `Prefix + N` | Następna sesja |
| `Prefix + P` | Poprzednia sesja |
| `Alt + Arrow Up/Down` | Przechodzenie między sesjami |
| `Prefix + s` | Lista sesji |
| `Prefix + d` | Odłączenie od sesji |

### Tryb kopiowania (w stylu vi)

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Prefix + [` | Wejście do trybu kopiowania |
| `v` | Rozpoczęcie zaznaczania (w trybie kopiowania) |
| `y` | Kopiowanie zaznaczenia (w trybie kopiowania) |

### Ogólne

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Prefix + q` | Ponowne wczytanie konfiguracji |
| `Prefix + ?` | Pokazanie skrótów Tmux |
| `Prefix + :` | Wiersz poleceń |

### Funkcje układu Tmux

Te funkcje muszą być uruchamiane wewnątrz sesji Tmux.

| Polecenie | Funkcja |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Tworzenie układu deweloperskiego z edytorem, AI i terminalem |
| `tdlm <ai> [<second_ai>]` | Tworzenie układu deweloperskiego dla każdego podkatalogu |
| `tsl <count> <command>` | Tworzenie układu roju z wieloma panelami |

## Terminal Ghostty

Terminal Ghostty instaluje się za pomocą _Install > Terminal_ w menu Omarchy.

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nowy podział poniżej |
| `Ctrl + Shift + O` | Nowy podział obok |
| `Ctrl + Alt + Arrows` | Przechodzenie między podziałami |
| `Super + Ctrl + Shift + Arrows` | Zmiana rozmiaru podziału o 10 linii |
| `Super + Ctrl + Shift + Alt + Arrows` | Zmiana rozmiaru podziału o 100 linii |
| `Ctrl + Shift + T` | Nowa karta  |
| `Ctrl + Shift + Arrows` | Przechodzenie między kartami |
| `Alt + Numbers` | Przejście do konkretnej karty |
| `Shift + Pg Up/Down` | Przewijanie historii |
| `Ctrl + Left mouse` | Otwarcie łącza w przeglądarce |

## Menedżer plików

| Skrót              | Funkcja                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Przejście do ścieżki                     |
| `Space`               | Podgląd pliku (strzałki nawigują) |
| `Alt + Up`       | Przejście w górę do folderu nadrzędnego        |

## Neovim (z lazyvim)

### Nawigacja

| Skrót                   | Funkcja                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Pokazanie opcji poleceń            |
| `Space Space`              | Otwarcie pliku przez wyszukiwanie rozmyte      |
| `Space E`                  | Przełączenie paska bocznego                  |
| `Space G G`                | Pokazanie kontrolek git               |
| `Space S G`                | Wyszukiwanie w treści pliku             |
| `Ctrl + W W`               | Przechodzenie między paskiem bocznym a edytorem |
| `Ctrl + Left/right arrow`  | Zmiana rozmiaru paska bocznego          |
| `Shift + H`                      | Przejście do lewej karty pliku             |
| `Shift + L`                      | Przejście do prawej karty pliku            |
| `Space B D`                | Zamknięcie karty pliku                  |

### W pasku bocznym

| Skrót                   | Funkcja                        |
| ------------------------ | ------------------------------- |
| `A`                        | Dodanie nowego pliku w katalogu nadrzędnym      |
| `Shift + A`                | Dodanie nowego podkatalogu w katalogu nadrzędnym    |
| `D`                        | Usunięcie zaznaczonego pliku/katalogu     |
| `M`                        | Przeniesienie zaznaczonego pliku/katalogu       |
| `R`                        | Zmiana nazwy zaznaczonego pliku/katalogu     |
| `?`                        | Pokazanie pomocy dla wszystkich poleceń      |

[Zobacz wszystkie skróty Neovim skonfigurowane przez LazyVim](https://www.lazyvim.org/keymaps).

## Szybkie emoji

Możesz użyć `Super + Ctrl + E`, aby wyświetlić kompletny selektor emoji, który umieści wybór w schowku, albo możesz użyć tych opcji szybkiego dostępu.

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
| `Shift + CapsLock M X` | 🎉 | świętowanie |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | toast      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | powitanie |
| `Shift + CapsLock M A` |💪 | ramię |
| `Shift + CapsLock M B` |🤯 | oszołomienie |

## Szybkie uzupełnienia

| Skrót       | Uzupełnienie       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (pauza)   |
| `Shift + CapsLock Space N` | Twoje imię (podane podczas konfiguracji)  |
| `Shift + CapsLock Space E` | Twój e-mail (podany podczas konfiguracji)  |

Możesz dodać więcej własnych, edytując `~/.XCompose`, a następnie uruchamiając `omarchy restart xcompose` w terminalu, aby zmiany zostały wczytane.
