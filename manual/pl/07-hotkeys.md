# Skróty klawiszowe

Możesz zobaczyć wszystkie główne powiązania klawiszy za pomocą `Super + K` (powiązania Tmux za pomocą `Super + Alt + K`, a powiązania Herdr za pomocą `Super + Ctrl + K`).

## Jak ułożone są skróty klawiszowe

Każdy skrót klawiszowy siedzi na płaszczyźnie, wyznaczonej przez jego modyfikatory, a każda płaszczyzna ma jedno zadanie. To właśnie zapobiega zlewaniu się skrótów w jedno, i oznacza, że zazwyczaj da się zgadnąć, gdzie coś mieszka.

| Płaszczyzna | Co tam mieszka | Przykłady |
| --- | --- | --- |
| `Super + key` | System: okna, obszary robocze, układy i główne menu | `Super + Space` menu Omarchy, `Super + W` zamknięcie okna, `Super + F` pełny ekran |
| `Super + Shift + key` | Aplikacje | `Super + Shift + B` przeglądarka, `Super + Shift + E` e-mail, `Super + Shift + N` edytor |
| `Super + Ctrl + key` | Panele i menu systemowe | `Super + Ctrl + A` audio, `Super + Ctrl + N` sieć, `Super + Ctrl + C` menu przechwytywania |
| `Super + Ctrl + Alt + key` | Szybkie akcje i komunikaty | `Super + Ctrl + Alt + T` pokaż czas, `Super + Ctrl + Alt + B` bateria, `Super + Ctrl + Alt + C` zrzut ekranu |

Dodanie `Alt` do skrótu daje ci wariant tego samego, nigdy coś niepowiązanego:

- `Super + Shift + B` otwiera przeglądarkę; `Super + Shift + Alt + B` otwiera okno prywatne
- `Super + Shift + E` otwiera e-mail; `Super + Shift + Alt + E` zaczyna nowy
- `Super + F` przechodzi na pełny ekran; `Super + Alt + F` przechodzi na pełną szerokość
- `Super + Ctrl + C` otwiera menu przechwytywania; `Super + Ctrl + Alt + C` pomija menu i robi zrzut ekranu

Przy dodawaniu skrótu:

1. Najpierw wybierz płaszczyznę na podstawie tego, co robi, potem wybierz klawisz.
2. Nie przesuwaj istniejącego skrótu, żeby zrobić miejsce. Znajdź wolny klawisz na właściwej płaszczyźnie.
3. Używaj `Alt` tylko dla wariantu skrótu bez niego.

Kilka skrótów łamie te zasady, bo tak jest wygodniej. `Shift` ze strzałką lub `Tab` przesuwa albo odwraca, zamiast otwierać aplikację, a `Print`, klawisze multimedialne, `Alt + Tab` i `Ctrl + Alt + Del` działają tak, jak wszędzie indziej. To wyjątki, nie wzorce do kopiowania.

Jeśli domyślny ci nie pasuje (powiedzmy, że chcesz `Super + Shift + S` do zrzutów ekranu, jak w Windows), zmień go w `~/.config/hypr/bindings.lua`.

## Nawigacja

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + Space`           | Menu Omarchy (aplikacje i wszystko inne)    |
| `Super + Alt + Space` | Siatka aplikacji |
| `Super + Escape` | Menu systemowe (uśpij, uruchom ponownie itd.)  |
| `Super + Ctrl + L` | Zablokuj komputer |
| `Super + W` or `Super + Q` | Zamknij okno             |
| `Ctrl + Alt + Del` | Zamknij wszystkie okna |
| `Super + T`               | Przełącz okno między kafelkowaniem a pływaniem             |
| `Super + J` | Przełącz pozycję okna (poziomo/pionowo) |
| `Super + O`               | Przełącz wyskakujące okno na tryb sticky'n'floating |
| `Super + L`               | Przełączaj między układami dwindle, scrolling i floating |
| `Super + Alt + L`         | Przełączaj między układami w odwrotnej kolejności |
| `Super + P`               | Przełącz styl pseudo okna (naturalny kontra rozciągnięty) |
| `Super + F`                 | Przejdź na pełny ekran              |
| `Super + Alt + F`                 | Przejdź na pełną szerokość              |
| `Super + Ctrl + F`                 | Przejdź na pełny ekran wewnątrz okna              |
| `Super + 1/2/3/4`         | Przeskocz do konkretnego obszaru roboczego na monitorze z fokusem |
| `Super + Tab` | Przeskocz do następnego obszaru roboczego na monitorze z fokusem |
| `Super + Shift + Tab` | Przeskocz do poprzedniego obszaru roboczego na monitorze z fokusem |
| `Super + Ctrl + Tab` | Przeskocz do dawnego obszaru roboczego na monitorze z fokusem |
| `Super + Shift + 1/2/3/4` | Przenieś okno do obszaru roboczego na monitorze z fokusem |
| `Super + Shift + Alt + 1/2/3/4` | Przenieś okno do obszaru roboczego na monitorze z fokusem bez podążania za nim |
| `Super + S` | Przełącz pełny scratchpad |
| `Super + Alt + S` | Przenieś okno do pełnego scratchpadu |
| `Super + Grave` | Przełącz konsolę Quake |
| `Super + Shift + Grave` | Przenieś okno do konsoli Quake |
| `Super + Shift + Ctrl + Arrows` | Przenieś okno na monitor w tym kierunku |
| `Super + Shift + Alt + Arrows` | Przenieś obszar roboczy na monitor w tym kierunku |
| `Super + Arrow`  | Przenieś fokus na okno w kierunku strzałki, przechodząc na monitor po tej stronie przy krawędzi ekranu |
| `Super + Shift + Arrow`  | Zamień okno z innym w kierunku strzałki, w tym z oknem na monitorze po tej stronie |
| `Super + Minus` | Poszerz okno w lewo |
| `Super + Equal` | Zwęź okno w lewo |
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
| `Super + Alt + G`               | Wyprowadź okno z grupowania      |
| `Super + Alt + Tab`               | Przełączaj między oknami w grupowaniu      |
| `Super + Alt + Shift + Tab`               | Przełączaj wstecz między oknami w grupowaniu      |
| `Super + Alt + Scroll Wheel` | Przełączaj między oknami w grupowaniu |
| `Super + Alt + 1/2/3/4/5`               | Przeskocz do konkretnego okna w grupowaniu      |
| `Super + Alt + Arrow`  | Przenieś okno do grupowania w kierunku strzałki, w tym jedno na monitorze po tej stronie |
| `Super + Ctrl + Left/Right`  | Poruszaj się między oknami wewnątrz grupy kafelkowania |
| `Super + Ctrl + Z` | Powiększ ekran (powtórz, aby powiększyć bardziej) |
| `Super + Ctrl + Alt + Z` | Całkowicie pomniejsz ekran |
| `Super + /` | Krok do przodu przez opcje skalowania monitora |
| `Super + Alt + /` | Krok wstecz przez opcje skalowania monitora |
| `Alt + Tab` | Przełączaj do przodu między oknami na aktywnym obszarze roboczym |
| `Alt + Shift + Tab` | Przełączaj wstecz między oknami na aktywnym obszarze roboczym |
| `Ctrl + Alt + Tab`| Przełączaj fokus do przodu między monitorami |
| `Ctrl + Alt + Shift + Tab`| Przełączaj fokus wstecz między monitorami |

Skróty zmiany rozmiaru używają fizycznych klawiszy `code:20` i `code:21` (XKB `<AE11>` i `<AE12>`), niezależnie od znaków nadrukowanych na klawiaturze. Na klawiaturach US te klawisze to `-` i `=`; na klawiaturach japońskich (JIS) to `-` i `^`; na klawiaturach hiszpańskich to `'` i `¡`. W JIS `Super + ^` to `Super + Equal`, natomiast `Super + Shift + -` (który wpisuje `=`) to `Super + Shift + Minus`.

## Sterowanie systemem

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
| `Super + Ctrl + O` | Menu przełączników |
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
| `Keyboard Brightness Up/Down` | Podświetlenie klawiatury jaśniejsze/ciemniejsze |
| `Keyboard Backlight` | Przełączaj poziomy podświetlenia klawiatury |
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
| `Super + A`           | Zaznacz wszystko w aplikacjach obsługujących `Ctrl + A`    |
| `Super + C`           | Kopiuj    |
| `Super + X`           | Wytnij (nie w terminalu)    |
| `Super + V`           | Wklej    |
| `Super + Ctrl + V`           | Menedżer schowka    |

Zazwyczaj w Linuksie potrzebujesz `Ctrl + Shift + C/V`, aby kopiować'n'wklejać w terminalu, oraz `Ctrl + C/V`, aby robić to wszędzie indziej. Te ujednolicone skróty schowka Omarchy działają wszędzie.

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
| `Alt + Shift + L` | Kopiuj bieżący URL z webappu lub przeglądarki |
| `Alt + Shift + D` | Pobierz wideo z bieżącej strony do `~/Videos` |
| `Alt + Space` | Start/stop dyktowania (wymaga _Setup > Defaults > Dictation_) |
| `Right Alt` | Przytrzymaj, aby dyktować (wymaga _Setup > Defaults > Dictation_) |

Przy nagrywaniu ekranu skrót najpierw pyta, jakie audio chcesz, a potem zaczyna nagrywać. Naciśnij go ponownie, aby zatrzymać. Zobacz [zrzuty ekranu i nagrywanie](12-screenshots-recording.md), aby poznać szczegóły.

Wszystkie opcje przechwytywania są też dostępne w _Trigger > Capture_ w menu Omarchy (`Super + Space`).

## Powiadomienia

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + ,` | Wykonaj akcję na najnowszym powiadomieniu: otwórz je lub naciśnij jego jedyny przycisk, wybierz spośród jego opcji albo odrzuć je, gdy nie ma żadnej  |
| `Super + Shift + ,` | Odrzuć wszystkie powiadomienia |
| `Super + Ctrl + ,` | Steruj powiadomieniami klawiaturą  |
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

Dodatkowe obrazy tła mieszkają w `~/.config/omarchy/backgrounds/<theme name>`. Dostępne też przez _Install > Style > Background_ w menu Omarchy.

Wszystkie opcje stylu są też dostępne w _Style_ w menu Omarchy (`Super + Space`).

## Przełączniki

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Przełącz blokowanie przy bezczynności |
| `Super + Ctrl + Delete` | Przełącz wyświetlacz laptopa wł./wył. |
| `Super + Ctrl + Alt + Delete` | Przełącz klonowanie wyświetlacza laptopa |
| `Super + Shift + Space` | Przełącz górny pasek  |
| `Shift + Mute` | Przełącz na następne wyjście audio |
| `Shift + Play` | Przełącz na następne źródło multimediów |
| `Super + Shift + Backspace` | Przełącz odstępy między oknami |
| `Super + Ctrl + Alt + F` | Przełącz pulpit na pełnym ekranie (górny pasek + odstępy między oknami) |

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

Klawisz prefix to `Ctrl + Space` (działa też `Ctrl + B`). Możesz zmienić te powiązania w `~/.config/tmux/tmux.conf`.

### Okienka

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Prefix + v` | Podziel okienko obok (pionowo) |
| `Prefix + h` | Podziel okienko poniżej (poziomo) |
| `Prefix + x` | Zabij okienko |
| `Prefix + z` | Przełącz zoom okienka (pełny ekran) |
| `Alt + Enter` | Podziel okienko poniżej (bez prefixu) |
| `Alt + Shift + Enter` | Podziel okienko obok (bez prefixu) |
| `Alt + Escape` | Zabij okienko (bez prefixu) |
| `Ctrl + Alt + Arrows` | Poruszaj się między okienkami |
| `Ctrl + Alt + Shift + Arrows` | Zmień rozmiar okienek |

### Okna

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Prefix + c` | Nowe okno |
| `Prefix + k` | Zabij okno |
| `Prefix + r` | Zmień nazwę okna |
| `Alt + 1-9` | Przejdź do konkretnego okna |
| `Alt + Arrow Left/Right` | Poruszaj się między oknami |
| `Alt + Shift + Arrow Left/Right` | Przenieś okno w lewo/prawo |

### Sesje

| Skrót                  | Funkcja              |
| ----------------------- | --------------------- |
| `Prefix + C` | Nowa sesja |
| `Prefix + K` | Zabij sesję |
| `Prefix + R` | Zmień nazwę sesji |
| `Prefix + N` | Następna sesja |
| `Prefix + P` | Poprzednia sesja |
| `Alt + Arrow Up/Down` | Poruszaj się między sesjami |
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
| `Prefix + ?` | Pokaż powiązania klawiszy Tmux |
| `Prefix + :` | Wiersz poleceń |

### Funkcje układów Tmux

Te funkcje muszą być uruchamiane wewnątrz sesji Tmux.

| Polecenie | Funkcja |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Utwórz układ dev z edytorem, AI i terminalem |
| `tdlm <ai> [<second_ai>]` | Utwórz układ dev na podkatalog |
| `tsl <count> <command>` | Utwórz układ roju z wieloma okienkami |

## Terminal Ghostty

Terminal Ghostty instaluje się za pomocą _Install > Terminal_ w menu Omarchy.

| Skrót                  | Funkcja              |
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
| `Space S G`                | Szukaj zawartości plików             |
| `Ctrl + W W`               | Przeskakuj między paskiem bocznym a edytorem |
| `Ctrl + Left/right arrow`  | Zmień rozmiar paska bocznego          |
| `Shift + H`                      | Przejdź do lewej karty pliku             |
| `Shift + L`                      | Przejdź do prawej karty pliku            |
| `Space B D`                | Zamknij kartę pliku                  |

### Będąc w pasku bocznym

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
| `Shift + CapsLock M D` | 🤤 | ślinka      |
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

Możesz dodać więcej własnych, edytując `~/.XCompose`, a następnie uruchamiając `omarchy-restart-xcompose` w terminalu, aby zmiany zostały wykryte.
