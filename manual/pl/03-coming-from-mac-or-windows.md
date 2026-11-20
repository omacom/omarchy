# Jeśli przychodzisz z Maca lub Windowsa

Jeśli od lat korzystasz z macOS lub Windows, twoje palce znają setkę rzeczy, których twój mózg już nie pamięta, że kiedykolwiek się ich nauczył. Ten rozdział jest warstwą tłumaczącą: dokąd trafiają te odruchy w Omarchy. Same funkcje są szczegółowo opisane gdzie indziej — to jest tylko mapa.

### Super jest centrum wszystkiego

Cała pamięć mięśniowa związana z Cmd lub klawiszem Windows przenosi się na jeden klawisz: Super. To klawisz Windows na klawiaturze PC i kotwica niemal każdego skrótu klawiszowego w Omarchy.

Twój odruch sięgania po Spotlight, Raycast albo menu Start staje się `Super + Space`. To otwiera menu Omarchy, które uruchamia aplikacje, zmienia ustawienia, instaluje oprogramowanie, przechwytuje ekran — po prostu wszystko. Zacznij pisać, aby filtrować. `Super + Alt + Space` pokazuje wszystkie aplikacje na jednej siatce, tak jak robi to Launchpad. Zobacz [nawigację](04-navigation.md).

### Żadnych ikon na pulpicie, a dock pojawia się tylko w trybie pływającym

Żadnych ikon do układania na pulpicie i żadnego docka na kafelkowym obszarze roboczym — dock pojawia się tylko na pływającym obszarze roboczym (zobacz [nawigację](04-navigation.md)). Aplikacje uruchamiasz skrótem klawiszowym (`Super + Return` dla terminala, `Super + Shift + Return` dla przeglądarki i `Super + K` dla listy wszystkiego, co jest przypisane) albo z menu. Jedynym stałym elementem interfejsu jest [górny pasek](05-the-top-bar.md), który przejmuje to, co wcześniej robiły dla ciebie pasek menu, zasobnik systemowy i Notification Center — a niemal każdy widżet na nim robi coś po kliknięciu lewym, prawym i środkowym przyciskiem.

### Okna ustawiają się same

Największa zmiana mentalna: nie przeciągasz okien ani nie przyciągasz ich do połówek ekranu. Otwierasz okno i zajmuje cały ekran. Otwierasz drugie i dzielą ekran między siebie. Nigdy nie wyławiasz okna spod innego, bo okna na siebie nie nachodzą.

Gdy naprawdę potrzebujesz pływającego okna, `Super + T` wyłącza aktywne okno z układu kafelkowego (i włącza je z powrotem). Ale daj najpierw kafelkom prawdziwą szansę — to serce całego rozwiązania. [Nawigacja](04-navigation.md) przeprowadzi cię przez to.

Obszary robocze będą znajome: to macOS Spaces albo wirtualne pulpity Windows, tyle że naprawdę będziesz z nich korzystać, bo `Super + 1/2/3/4` przeskakuje prosto do konkretnego, a `Super + Shift + 1/2/3/4` wysyła tam aktywne okno. Żadnego opóźnienia animacji, tylko błyskawiczne skoki. Oznacza to, że możesz nawet nie potrzebować kilku monitorów, jeśli wcześniej był to twój standard.

### Kopiowanie i wklejanie po prostu działają

Na Macu wszędzie działało Cmd + C. Na Windows wszędzie działało Ctrl + C — poza terminalem, gdzie zabija twój program. Omarchy daje ci `Super + C`, `Super + X` i `Super + V`, a działają one wszędzie, także w terminalu. Nie musisz uczyć się osobnego odruchu dla powłoki.

Użytkownicy Windows: twoja historia schowka z Win + V mieszka pod `Super + Ctrl + V` i przechowuje obrazy oraz tekst. Zobacz [ujednolicony schowek i historię](08-unified-clipboard-history.md).

### Tabela tłumaczeń

| Po co sięgasz | W Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / menu Start | `Super + Space` — menu Omarchy |
| AirDrop | LocalSend, przez `Super + Ctrl + S` — zobacz [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` albo `Print Screen` — zobacz [zrzuty ekranu i nagrywanie](12-screenshots-recording.md) |
| Notification Center | Historia powiadomień pod `Super + Shift + Alt + ,` |
| Time Machine (dla systemu) | Automatyczne [migawki systemu](47-system-snapshots.md) przy każdej aktualizacji |
| App Store / pobieranie instalatora | _Zainstaluj_ w menu albo `omarchy pkg add` — zobacz [inne pakiety](29-other-packages.md) |
| Ustawienia systemowe / Panel sterowania | _Konfiguracja_ w menu, która edytuje zwykłe pliki konfiguracyjne — zobacz [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, pod `Super + Shift + F` — zobacz [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome pod `Super + Shift + Return`; inną wybierzesz w _Konfiguracja > Domyślne > Przeglądarka_ — zobacz [przeglądarki](23-browsers.md) |
| Preview / Photos | Omaview do zdjęć, wideo i muzyki, Document Viewer do plików PDF — zobacz [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, pod `Super + Shift + N`; inny wybierzesz w _Konfiguracja > Domyślne > Edytor_ |

### Niektóre rzeczy naprawdę są inne

Wiele ustawień mieszka w plikach tekstowych, które edytujesz, a nie w panelach, które przeklikujesz. Brzmi prymitywnie, dopóki nie zdasz sobie sprawy, że oznacza to, iż każdą zmianę można zobaczyć, skopiować na następną maszynę i trzymać w systemie kontroli wersji. Menu _Konfiguracja_ wrzuca cię prosto do właściwego pliku i po zakończeniu restartuje to, co trzeba zrestartować.

Aktualizacje przychodzą jednym poleceniem — _Aktualizacja > Omarchy_ — które aktualizuje samo Omarchy i każdy pakiet w systemie, najpierw robiąc migawkę. Żadnych aktualizatorów poszczególnych aplikacji, które nękają cię w losowych momentach. Zobacz [aktualizacje](30-updates.md).

Oprogramowanie pochodzi z menedżera pakietów, a nie z pobranych instalatorów.

A gdy zamkniesz okno, aplikacja naprawdę się kończy. Nie ma limbo znanego z macOS, w którym program działa dalej bez żadnych okien. `Super + W` — albo `Super + Q`, jeśli taką pamięć palców ze sobą przynosisz — oznacza: zniknęło.

### Na sprzęcie Mac

Omarchy działa dobrze na Macach z procesorami Intel — zobacz [wsparcie dla Maców](44-mac-support.md). A klawiatura jest dla ciebie łaskawa: Omarchy niczego nie przemapowuje, a Linux traktuje klawisz Command jako Super, więc Super siedzi dokładnie tam, gdzie zawsze był Cmd. Twój kciuk nawet nie zauważy przeprowadzki.

### Daj temu dwa tygodnie

Odruchy przeniosą się szybciej, niż myślisz. Przejrzyj raz rozdział o [skrótach klawiszowych](07-hotkeys.md), a gdy tylko zapomnisz jakiegoś przypisania, naciśnij `Super + K` — pokaże ci je wszystkie. To jedyny skrót, który naprawdę musisz zapamiętać.
