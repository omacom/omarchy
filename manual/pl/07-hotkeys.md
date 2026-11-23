# Skróty klawiszowe

Możesz zobaczyć wszystkie główne skróty klawiszowe za pomocą `Super + K` (skróty Tmux za pomocą `Super + Alt + K`, a skróty Herdr za pomocą `Super + Ctrl + K`).

## Jak są zorganizowane skróty klawiszowe

Każdy skrót klawiszowy leży na jednej płaszczyźnie, wyznaczonej przez jego modyfikatory, a każda płaszczyzna ma jedno zadanie. To właśnie sprawia, że skróty klawiszowe się ze sobą nie zlewają, i oznacza, że zwykle możesz zgadnąć, gdzie coś mieszka.

| Płaszczyzna | Co na niej mieszka | Przykłady |
| --- | --- | --- |
| `Super + key` | System: okna, obszary robocze, układy i główne menu | `Super + Space` menu Omarchy, `Super + W` zamknięcie okna, `Super + F` pełny ekran |
| `Super + Shift + key` | Aplikacje | `Super + Shift + B` przeglądarka, `Super + Shift + E` e-mail, `Super + Shift + N` edytor |
| `Super + Ctrl + key` | Panele i menu systemowe | `Super + Ctrl + A` audio, `Super + Ctrl + N` sieć, `Super + Ctrl + C` menu przechwytywania |
| `Super + Ctrl + Alt + key` | Szybkie akcje i powiadomienia | `Super + Ctrl + Alt + T` pokaż czas, `Super + Ctrl + Alt + B` bateria, `Super + Ctrl + Alt + C` zrzut ekranu |

Dodanie `Alt` do skrótu klawiszowego daje wariant tego samego, nigdy coś niezwiązanego:

- `Super + Shift + B` otwiera przeglądarkę; `Super + Shift + Alt + B` otwiera okno prywatne
- `Super + Shift + E` otwiera e-mail; `Super + Shift + Alt + E` zaczyna nowy
- `Super + F` przechodzi na pełny ekran; `Super + Alt + F` przechodzi na pełną szerokość
- `Super + Ctrl + C` otwiera menu przechwytywania; `Super + Ctrl + Alt + C` pomija menu i robi zrzut ekranu

Dodając skrót klawiszowy:

1. Wybierz płaszczyznę na podstawie tego, co robi, a potem wybierz klawisz.
2. Nie przesuwaj istniejącego skrótu klawiszowego, żeby zrobić miejsce. Znajdź wolny klawisz na właściwej płaszczyźnie.
3. Używaj `Alt` tylko jako wariantu skrótu klawiszowego bez niego.

Kilka skrótów klawiszowych łamie te zasady, bo tak jest wygodnie. `Shift` ze strzałką lub `Tab` przesuwa lub odwraca zamiast otwierać aplikację, a `Print`, klawisze multimedialne, `Alt + Tab` i `Ctrl + Alt + Del` działają tak, jak działają wszędzie indziej. To wyjątki, nie wzorce do kopiowania.

Jeśli domyślny ci nie pasuje (powiedzmy, że chcesz `Super + Shift + S` do zrzutów ekranu jak w Windows), zmień go w `~/.config/hypr/bindings.lua`.

## Nawigacja

| Skrót | Funkcja |
| ----------------------- | --------------------- |
| `Super + Space`           | Menu Omarchy (aplikacje i wszystko pozostałe)    |
| `Super + Alt + Space` | Siatka aplikacji |
| `Super + Escape` | Menu systemowe (uśpienie, ponowne uruchomienie itd.)  |
| `Super + Ctrl + L` | Zablokuj komputer |
| `Super + W` or `Super + Q` | Zamknij okno             |
| `Ctrl + Alt + Del` | Zamknij wszystkie okna |
| `Super + K` | Pokaż wszystkie skróty klawiszowe |
| `Super + Alt + K` | Pokaż skróty klawiszowe tmux |
| `Super + Ctrl + K` | Pokaż skróty klawiszowe herdr |
| `Super + M` | Zminimalizuj okno do docka |
| `Super + T`               | Przełącz okno między trybem kafelkowym/swobodnym             |
| `Super + J` | Przełącz pozycję okna (pozioma/pionowa) |
| `Super + O`               | Przełącz wyrzucanie okna do trybu sticky'n'floating |
| `Super + L`               | Przechodź przez układy dwindle, scrolling i floating |
| `Super + Alt + L`         | Przechodź przez układy w odwrotnej kolejności |
| `Super + P`               | Przełącz styl okna pseudo (natural v stretch) |
| `Super + F`                 | Przejdź na pełny ekran              |
| `Super + Alt + F`                 | Przejdź na pełną szerokość              |
| `Super + Ctrl + F`                 | Przejdź na pełny ekran wewnątrz okna              |
| `Super + 1…9/0`         | Przejdź do określonego obszaru roboczego (0 to 10) na monitorze z fokusem |
| `Super + Tab` | Przejdź do następnego obszaru roboczego na monitorze z fokusem |
| `Super + Shift + Tab` | Przejdź do poprzedniego obszaru roboczego na monitorze z fokusem |
| `Super + Ctrl + Tab` | Przejdź do wcześniejszego obszaru roboczego na monitorze z fokusem |
| `Super + Shift + 1…9/0` | Przenieś okno na obszar roboczy na monitorze z fokusem |
| `Super + Shift + Alt + 1…9/0` | Przenieś okno na obszar roboczy na monitorze z fokusem bez podążania za nim |
| `Super + S` | Przełącz pełny scratchpad |
| `Super + Alt + S` | Przenieś okno na pełny scratchpad |
| `Super + the key above Tab` (grave na układach US) | Przełącz konsolę Quake |
| `Super + Shift + the key above Tab` (grave na układach US) | Przenieś okno do konsoli Quake |
| `Super + Shift + Ctrl + Arrows` | Przenieś okno na monitor w tym kierunku |
| `Super + Shift + Alt + Arrows` | Przenieś obszar roboczy na monitor w tym kierunku |
| `Super + Arrow`  | Przenieś fokus na okno w kierunku strzałki, przechodząc na monitor po tej stronie przy krawędzi ekranu |
| `Super + Shift + Arrow`  | Zamień okno z innym w kierunku strzałki, w tym z oknem na monitorze po tej stronie |
| `Super + Minus` | Poszerz okno w lewo |
| `Super + Equal` | Zwęź okno w lewo |
| `Super + Shift + Minus` | Zmniejsz okno w górę |
| `Super + Shift + Equal` | Poszerz okno w dół |
| `Super + Alt + Minus/Equal` | To samo zmienianie rozmiaru w mniejszych krokach |
| `Super + Ctrl + Minus/Equal` | To samo zmienianie rozmiaru w większych krokach |
| `Super + Alt + Home` | Zapisz szerokość okna |
| `Super + Home` | Przywróć zapisaną szerokość okna |
| `Super + Left Mouse` | Przeciągaj okno |
| `Super + Right Mouse` | Zmieniaj rozmiar okna |
| `Super + Scroll Wheel` | Przewijaj obszary robocze na monitorze z fokusem |
| `Super + G`               | Przełącz grupowanie okien      |
| `Super + Alt + G`               | Wyjmij okno z grupy      |
| `Super + Alt + Tab`               | Przechodź między oknami w grupie      |
| `Super + Alt + Shift + Tab`               | Przechodź wstecz między oknami w grupie      |
| `Super + Alt + Scroll Wheel` | Przechodź między oknami w grupie |
| `Super + Alt + 1/2/3/4/5`               | Przejdź do określonego okna w grupie      |
| `Super + Alt + Arrow`  | Przenieś okno do grupy w kierunku strzałki, w tym okno na monitorze po tej stronie |
| `Super + Ctrl + Left/Right`  | Poruszaj się między oknami wewnątrz grupy kafelkowej |
| `Super + Ctrl + Z` | Powiększ ekran (powtórz, aby powiększyć bardziej) |
| `Super + Ctrl + Alt + Z` | Oddal ekran całkowicie |
| `Super + /` | Przejdź do przodu przez opcje skalowania monitora |
| `Super + Alt + /` | Przejdź wstecz przez opcje skalowania monitora |
| `Alt + Tab` | Przechodź do przodu między oknami na aktywnym obszarze roboczym |
| `Alt + Shift + Tab` | Przechodź wstecz między oknami na aktywnym obszarze roboczym |
| `Ctrl + Alt + Tab`| Przechodź fokus do przodu między monitorami |
| `Ctrl + Alt + Shift + Tab`| Przechodź fokus wstecz między monitorami |
| `Super + I` | Przełącz język wprowadzania (przy więcej niż jednym układzie lub metodzie wprowadzania) |
| `Super + Shift + I` | Przełącz język wprowadzania wstecz |

Na touchpadzie przeciągnięcia trzema i czterema palcami przełączają obszary robocze, przenoszą okna oraz otwierają menu i konsolę Quake; zobacz [klawiatura, mysz i trackpad](34-keyboard-mouse-trackpad.md), aby poznać gesty.

Zmienianie rozmiaru używa dwóch klawiszy na prawo od 0, niezależnie od tego, co twoja klawiatura na nich drukuje: `-` i `=` na klawiaturach US, `+` i `´` na duńskich i szwedzkich, `+` i `\` na norweskich, `ß` i `´` na niemieckich, `'` i `¡` na hiszpańskich oraz `-` i `^` na japońskich (JIS). `Super + K` wypisuje je tak, jak drukuje je twoja klawiatura. Na JIS `Super + ^` to `Super + Equal`, natomiast `Super + Shift + -` (które wpisuje `=`) to `Super + Shift + Minus`. Skalowanie monitora i menedżer haseł używają `/`; na układach, które wpisują `/` tylko z Shift, jak większość europejskich, używają zamiast tego klawisza na lewo od prawego Shift (`-` na duńskim i niemieckim).

## Sterowanie systemem

| Skrót | Funkcja |
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
| `Super + Ctrl + C` | Sterowanie przechwytywaniem (zrzut ekranu/-nagrywanie/wybierak) |
| `Super + Ctrl + O` | Przełącz menu |
| `Super + Ctrl + H` | Menu sprzętu |
| `Super + Ctrl + E` | Wybierak emoji |
| `Super + Ctrl + .` | Transkoduj multimedia |
| `Super + Shift + Ctrl + A` | Uruchom swojego domyślnego agenta |
| `Power` key | Menu systemowe |
| `Super + Shift + Copilot` key | Menu Omarchy |

## Regulacje

| Skrót | Funkcja |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maksymalna jasność ekranu |
| `Shift + Brightness Down` | Minimalna jasność ekranu |
| `Alt + Brightness Up/Down` | Precyzyjne zmiany jasności o 1% |
| `Alt + Volume Up/Down` | Precyzyjne zmiany głośności o 1% |
| `Keyboard Brightness Up/Down` | Podświetlenie klawiatury jaśniej/ciemniej |
| `Keyboard Backlight` | Przełączaj poziomy podświetlenia klawiatury |
| `Ctrl + Brightness Up/Down` | Podświetlenie klawiatury jaśniej/ciemniej, na klawiaturach bez własnych klawiszy |
| `Mic Mute` | Wycisz mikrofon |
| `Shift + Mute` | Przełącz wyjście audio |
| `Touchpad Toggle` | Włącz lub wyłącz touchpad |
| `Display` key | Przełączaj układ obszaru roboczego |
| `Alt + Play` | Następny utwór |
| `Alt + Shift + Play` | Poprzedni utwór |

## Uruchamianie aplikacji

| Skrót | Funkcja |
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
| `Super + Shift + A`           | Twój domyślny agent lub ChatGPT, dopóki nie wybierzesz własnego |
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

Zmień/dodaj skróty w `~/.config/hypr/bindings.lua`.

## Uniwersalny schowek

| Skrót | Funkcja |
| ----------------------- | --------------------- |
| `Super + A`           | Zaznacz wszystko w aplikacjach, które obsługują `Ctrl + A`    |
| `Super + C`           | Kopiuj    |
| `Super + X`           | Wytnij (nie w terminalu)    |
| `Super + V`           | Wklej    |
| `Super + Ctrl + V`           | Menedżer schowka    |

Zwykle w Linuksie potrzebujesz `Ctrl + Shift + C/V`, aby kopiować i wklejać w terminalu, oraz `Ctrl + C/V`, aby robić to wszędzie indziej. Te ujednolicone skróty klawiszowe schowka Omarchy działają wszędzie.

## Przechwytywanie

| Skrót | Funkcja |
| ------------------- | ------------------------------ |
| `Print Screen`            | Zrzut ekranu                      |
| `Super + Ctrl + Alt + C`            | Zrzut ekranu (ten sam zrzut, dla klawiatur bez klawisza Print Screen) |
| `Super + Ctrl + C` | Menu przechwytywania |
| `Alt + Print Screen`            | Nagrywanie ekranu                     |
| `Super + Shift + Ctrl + Alt + C` | Nagrywanie ekranu bez dźwięku, z pominięciem menu (naciśnij ponownie, aby zatrzymać) |
| `Super + Print Screen` | Wybierak kolorów |
| `Super + Ctrl + Print Screen` | Wyodrębnianie tekstu do schowka |
| `Super + Alt + [` | Zmniejsz nakładkę kamery internetowej podczas nagrywania |
| `Super + Alt + ]` | Zwiększ nakładkę kamery internetowej podczas nagrywania |
| `Alt + Shift + L` | Kopiuj bieżący URL z aplikacji webowej lub przeglądarki |
| `Alt + Shift + D` | Pobierz wideo z bieżącej strony do `~/Videos` |
| `Alt + Space` | Start/stop dyktowania (wymaga _Setup > Defaults > Dictation_) |
| `Right Alt` | Przytrzymaj, aby dyktować (wymaga _Setup > Defaults > Dictation_) |

Przy nagraniach ekranu skrót klawiszowy najpierw pyta, jaki dźwięk chcesz, a potem zaczyna nagrywać. Naciśnij go ponownie, aby zatrzymać. Zobacz [zrzuty ekranu i nagrywanie](12-screenshots-recording.md), aby poznać szczegóły.

Wszystkie opcje przechwytywania są też dostępne w _Trigger > Capture_ w menu Omarchy (`Super + Space`).

## Powiadomienia

| Skrót | Funkcja |
| ----------------------- | --------------------- |
| `Super + ,` | Działaj na najnowsze powiadomienie: otwórz je lub naciśnij jego jedyny przycisk, wybierz spośród jego opcji albo odrzuć je, gdy nie ma żadnej  |
| `Super + Shift + ,` | Odrzuć wszystkie powiadomienia |
| `Super + Ctrl + ,` | Steruj powiadomieniami za pomocą klawiatury  |
| `Super + Alt + ,` | Odrzuć najnowsze powiadomienie  |
| `Super + Shift + Alt + ,` | Otwórz historię powiadomień  |
| `Super + Ctrl + Alt + ,` | Przełącz wyciszanie powiadomień  |

## Styl

| Skrót | Funkcja |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Wybierz nowy motyw (także `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Wybierz tło motywu (także `Super + Ctrl + Space`) |
| `Super + Backspace` | Przełącz przezroczystość okna |
| `Super + Ctrl + Backspace` | Przełącz kwadratowe proporcje pojedynczego okna |

Dodatkowe obrazy tła znajdują się w `~/.config/omarchy/backgrounds/<theme name>`. Dostępne także przez _Install > Style > Background_ w menu Omarchy.

Wszystkie opcje stylu są też dostępne w _Appearance_ w menu Omarchy (`Super + Space`).

## Przełączniki

| Skrót | Funkcja |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Przełącz blokowanie przy bezczynności |
| `Super + Ctrl + Delete` | Przełącz wyświetlacz laptopa wł./wył. |
| `Super + Ctrl + Alt + Delete` | Przełącz dublowanie wyświetlacza laptopa |
| `Super + Shift + Space` | Przełącz górny pasek  |
| `Shift + Mute` | Przełącz na następne wyjście audio |
| `Shift + Play` | Przełącz na następne źródło multimediów |
| `Super + Shift + Backspace` | Przełącz odstępy między oknami |
| `Super + Ctrl + Alt + F` | Przełącz pulpit na pełnym ekranie (górny pasek + odstępy między oknami) |

## Przypomnienia

| Skrót | Funkcja |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Ustaw przypomnienie  |
| `Super + Ctrl + Alt + R` | Zobacz wszystkie przypomnienia  |
| `Super + Ctrl + Shift + R` | Wyczyść wszystkie przypomnienia  |

## Komunikaty

| Skrót | Funkcja |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Pokaż czas jako powiadomienie  |
| `Super + Ctrl + Alt + B` | Pokaż baterię jako powiadomienie  |
| `Super + Ctrl + Alt + W` | Przełącz pogodę jako powiadomienie  |

## Tmux

Klawiszem prefix jest `Ctrl + Space` (`Ctrl + B` też działa). Możesz zmienić te skróty w `~/.config/tmux/tmux.conf`.

### Panele

| Skrót | Funkcja |
| ----------------------- | --------------------- |
| `Prefix + v` | Podziel panel obok (w pionie) |
| `Prefix + h` | Podziel panel poniżej (w poziomie) |
| `Prefix + x` | Zabij panel |
| `Prefix + z` | Przełącz powiększenie panelu (pełny ekran) |
| `Alt + Enter` | Podziel panel poniżej (bez prefix) |
| `Alt + Shift + Enter` | Podziel panel obok (bez prefix) |
| `Alt + Escape` | Zabij panel (bez prefix) |
| `Ctrl + Alt + Arrows` | Poruszaj się między panelami |
| `Ctrl + Alt + Shift + Arrows` | Zmieniaj rozmiar paneli |

### Okna

| Skrót | Funkcja |
| ----------------------- | --------------------- |
| `Prefix + c` | Nowe okno |
| `Prefix + k` | Zabij okno |
| `Prefix + r` | Zmień nazwę okna |
| `Alt + 1-9` | Przejdź do określonego okna |
| `Alt + Arrow Left/Right` | Poruszaj się między oknami |
| `Alt + Shift + Arrow Left/Right` | Przesuń okno w lewo/w prawo |

### Sesje

| Skrót | Funkcja |
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

| Skrót | Funkcja |
| ----------------------- | --------------------- |
| `Prefix + [` | Wejdź w tryb kopiowania |
| `v` | Rozpocznij zaznaczanie (w trybie kopiowania) |
| `y` | Kopiuj zaznaczenie (w trybie kopiowania) |

### Ogólne

| Skrót | Funkcja |
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
| `tsl <count> <command>` | Utwórz układ roju z wieloma panelami |

## Terminal Ghostty

Terminal Ghostty instaluje się za pomocą _Install > Terminal_ w menu Omarchy.

| Skrót | Funkcja |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nowy podział poniżej |
| `Ctrl + Shift + O` | Nowy podział obok |
| `Ctrl + Alt + Arrows` | Poruszaj się między podziałami |
| `Super + Ctrl + Shift + Arrows` | Zmień rozmiar podziału o 10 linii |
| `Super + Ctrl + Shift + Alt + Arrows` | Zmień rozmiar podziału o 100 linii |
| `Ctrl + Shift + T` | Nowa karta  |
| `Ctrl + Shift + Arrows` | Poruszaj się między kartami |
| `Alt + Numbers` | Przejdź do określonej karty |
| `Shift + Pg Up/Down` | Przewijaj historię |
| `Ctrl + Left mouse` | Otwórz link w przeglądarce |

## Menedżer plików

| Skrót | Funkcja |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Idź do ścieżki                     |
| `Space`               | Podgląd pliku (strzałki nawigują) |
| `Alt + Up`       | Idź w górę do folderu nadrzędnego        |

## Neovim (w/ lazyvim)

### Nawigacja

| Skrót | Funkcja |
| ------------------------ | ------------------------------- |
| `Space`                    | Pokaż opcje poleceń            |
| `Space Space`              | Otwórz plik przez wyszukiwanie rozmyte      |
| `Space E`                  | Przełącz pasek boczny                  |
| `Space G G`                | Pokaż sterowanie git               |
| `Space S G`                | Szukaj w zawartości pliku             |
| `Ctrl + W W`               | Przeskakuj między paskiem bocznym a edytorem |
| `Ctrl + Left/right arrow`  | Zmień rozmiar paska bocznego          |
| `Shift + H`                      | Idź do lewej karty pliku             |
| `Shift + L`                      | Idź do prawej karty pliku            |
| `Space B D`                | Zamknij kartę pliku                  |

### Będąc w pasku bocznym

| Skrót | Funkcja |
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

| Skrót | EM | Wskazówka |
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
| `Shift + CapsLock M K` | 😘 | buziak       |
| `Shift + CapsLock M E` | 🙄 | przewracanie oczami    |
| `Shift + CapsLock M I` | 😉 | mrugnięcie       |
| `Shift + CapsLock M P` | 🙏 | modlitwa |
| `Shift + CapsLock M D` | 🤤 | ślinienie      |
| `Shift + CapsLock M M` | 💰 | pieniądze      |
| `Shift + CapsLock M X` | 🎉 | świętowanie |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | toast      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | powitanie |
| `Shift + CapsLock M A` |💪 | ramię |
| `Shift + CapsLock M B` |🤯 | wybuch |

## Szybkie uzupełnienia

| Skrót | Uzupełnienie |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Twoje imię i nazwisko (jak podano podczas konfiguracji)  |
| `Shift + CapsLock Space E` | Twój e-mail (jak podano podczas konfiguracji)  |

Możesz dodać więcej własnych, edytując `~/.XCompose`, a potem uruchamiając `omarchy restart xcompose` w terminalu, aby zmiany zostały wczytane.
