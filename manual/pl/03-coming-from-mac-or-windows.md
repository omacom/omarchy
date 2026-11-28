# Przechodzisz z Maca lub z Windows

Jeśli spędziłeś lata na macOS lub Windows, twoje palce znają setkę rzeczy, o których twój mózg już zapomniał, że kiedykolwiek się ich nauczył. Ten rozdział jest warstwą tłumaczącą: pokazuje, dokąd trafiają te odruchy w Omarchy. Same funkcje są szczegółowo opisane gdzie indziej — to tylko mapa.

### Super jest centrum wszystkiego

Cała pamięć mięśniowa, którą zbudowałeś wokół Cmd lub klawisza Windows, przenosi się na jeden klawisz: Super. To klawisz Windows na klawiaturze PC i kotwica prawie każdego skrótu klawiszowego w Omarchy.

Twój odruch sięgania po Spotlight, Raycast albo menu Start staje się `Super + Space`. Otwiera to menu Omarchy, które uruchamia aplikacje, zmienia ustawienia, instaluje oprogramowanie, przechwytuje ekran — właściwie wszystko. Zacznij pisać, aby filtrować. `Super + Alt + Space` pokazuje każdą aplikację na jednej siatce, tak jak robi to Launchpad. Zobacz [nawigacja](04-navigation.md).

### Brak ikon na pulpicie, a dock nie wchodzi w drogę

Żadnych ikon do układania na pulpicie, a dock ukrywa się, gdy tylko obszar roboczy ma okno, dopóki nie przesuniesz wskaźnika do jego krawędzi ekranu — dolnej, chyba że ją przeniesiesz (zobacz [nawigacja](04-navigation.md)). Aplikacje uruchamiasz skrótem klawiszowym (`Super + Return` dla terminala, `Super + Shift + Return` dla przeglądarki i `Super + K` dla listy wszystkiego, co jest przypisane) albo z menu. Jedynym stałym elementem interfejsu jest [górny pasek](05-the-top-bar.md), który przejmuje to, co wcześniej robiły dla ciebie pasek menu, zasobnik systemowy i Notification Center — i prawie każdy widżet na nim robi coś po kliknięciu lewym, prawym i środkowym przyciskiem.

### Okna układają się same

Największa zmiana sposobu myślenia: nie przeciągasz okien po ekranie ani nie przyciągasz ich do połówek ekranu. Otwórz okno, a zajmie cały ekran. Otwórz drugie, a podzielą go między siebie. Nigdy nie wyławiasz okna spod innego, bo okna na siebie nie nachodzą.

Gdy naprawdę potrzebujesz pływającego okna, `Super + T` wyciąga aktywne okno z układu kafelkowego (i wstawia je z powrotem). Ale najpierw daj kafelkowaniu prawdziwą szansę — to serce całości. [Nawigacja](04-navigation.md) przeprowadzi cię przez to.

Obszary robocze będą znajome: to macOS Spaces albo wirtualne pulpity Windows, tyle że naprawdę będziesz ich używać, bo `Super + 1/2/3/4` przeskakuje prosto do jednego z nich, a `Super + Shift + 1/2/3/4` wysyła tam aktywne okno. Żadnego opóźnienia animacji, tylko natychmiastowe skoki. Oznacza to, że możesz nawet nie potrzebować kilku monitorów, jeśli wcześniej byłeś do tego przyzwyczajony.

### Kopiowanie i wklejanie po prostu działają

Na Macu wszędzie miałeś Cmd + C. Na Windows wszędzie miałeś Ctrl + C — z wyjątkiem terminala, gdzie zabija to twój program. Omarchy daje ci `Super + C`, `Super + X` i `Super + V` i działają one wszędzie, łącznie z terminalem. Nie musisz uczyć się osobnego odruchu dla powłoki.

Ludzie z Windows: wasza historia schowka z Win + V mieszka na `Super + Ctrl + V` i przechowuje obrazy oraz tekst. Zobacz [ujednolicony schowek i historia](08-unified-clipboard-history.md).

### Tabela tłumaczeń

| Sięgasz po | W Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / menu Start | `Super + Space` — menu Omarchy |
| AirDrop | LocalSend, przez `Super + Ctrl + S` — zobacz [interfejsy graficzne](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` lub `Print Screen` — zobacz [zrzuty ekranu i nagrywanie](12-screenshots-recording.md) |
| Notification Center | Historia powiadomień na `Super + Shift + Alt + ,` |
| Time Machine (dla systemu) | Automatyczne [migawki systemu](47-system-snapshots.md) przy każdej aktualizacji |
| App Store / pobieranie instalatora | _Install_ w menu albo `omarchy pkg add` — zobacz [inne pakiety](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ w menu, które edytuje zwykłe pliki konfiguracyjne — zobacz [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, na `Super + Shift + F` — zobacz [interfejsy graficzne](22-guis.md) |
| Safari / Edge | Google Chrome na `Super + Shift + Return`; wybierz inną w _Setup > Defaults > Browser_ — zobacz [przeglądarki](23-browsers.md) |
| Preview / Photos | Omaview do zdjęć, wideo i muzyki, Document Viewer do plików PDF — zobacz [interfejsy graficzne](22-guis.md) |
| TextEdit / Notepad | Plain, na `Super + Shift + N`; wybierz inny w _Setup > Defaults > Editor_ |

### Niektóre rzeczy naprawdę są inne

Wiele ustawień mieszka w plikach tekstowych, które edytujesz, a nie w panelach, które przeklikujesz. Brzmi prymitywnie, dopóki nie uświadomisz sobie, że oznacza to, iż każdą zmianę można zobaczyć, skopiować na następną maszynę i umieścić w systemie kontroli wersji. Menu _Setup_ wrzuca cię prosto do właściwego pliku i po zakończeniu restartuje to, co trzeba zrestartować.

Aktualizacje przychodzą jednym poleceniem — _Update > Omarchy_ — które aktualizuje samo Omarchy i każdy pakiet w systemie, najpierw tworząc migawkę. Żadnych aktualizatorów poszczególnych aplikacji, które nękają cię w losowych momentach. Zobacz [aktualizacje](30-updates.md).

Oprogramowanie pochodzi z menedżera pakietów, a nie z pobranych instalatorów.

A gdy zamkniesz okno, aplikacja naprawdę się kończy. Nie ma otchłani macOS, w której program działa dalej bez żadnych okien. `Super + W` — albo `Super + Q`, jeśli przyjechałeś z taką pamięcią palców — oznacza, że już go nie ma.

### Na sprzęcie Mac

Omarchy działa dobrze na Macach z Intelem oraz na Macach M1, M2 i M3 z Omarchy for Apple Silicon. Zobacz [wsparcie dla Maców](44-mac-support.md). A klawiatura jest dla ciebie łaskawa: Omarchy niczego nie przemapowuje, a Linux traktuje klawisz Command jako Super, więc Super siedzi dokładnie tam, gdzie zawsze był Cmd. Twój kciuk nie zauważy przeprowadzki.

### Daj temu dwa tygodnie

Odruchy przenoszą się szybciej, niż myślisz. Przejrzyj raz rozdział [skróty klawiszowe](07-hotkeys.md), a za każdym razem, gdy wypadnie ci z głowy jakieś przypisanie, naciśnij `Super + K` — pokazuje wszystkie. To jedyny skrót, który naprawdę musisz zapamiętać.
