# Przechodząc z Maca lub Windowsa

Po latach na macOS lub Windows twoje palce wiedzą sto rzeczy, o których nauce twój mózg już dawno zapomniał. Ten rozdział jest warstwą tłumaczącą: pokazuje, dokąd trafiają te nawyki w Omarchy. Same funkcje są szczegółowo opisane gdzie indziej — to jest tylko mapa.

### Super jest centrum wszystkiego

Cała pamięć mięśniowa wyrobiona wokół Cmd lub klawisza Windows przenosi się na jeden klawisz: Super. To klawisz Windows na klawiaturze PC i kotwica dla niemal każdego skrótu klawiszowego w Omarchy.

Odruch sięgania po Spotlight, Raycast lub menu Start staje się `Super + Space`. To otwiera menu Omarchy, które uruchamia aplikacje, zmienia ustawienia, instaluje oprogramowanie, przechwytuje ekran — niemal wszystko. Zacznij pisać, aby filtrować. `Super + Alt + Space` pokazuje wszystkie aplikacje na jednej siatce, tak jak robi to Launchpad. Zobacz [nawigacja](04-navigation.md).

### Nie ma docka ani ikon na pulpicie

Nie ma nic do klikania w celu uruchamiania rzeczy, żadnych ikon do układania na pulpicie. Aplikacje startują ze skrótu klawiszowego (`Super + Return` dla terminala, `Super + Shift + Return` dla przeglądarki i `Super + K` dla listy wszystkiego, co jest przypisane) albo z menu. Jedynym stałym elementem interfejsu jest [górny pasek](05-the-top-bar.md), który pokrywa to, co wcześniej robiły dla ciebie pasek menu, zasobnik systemowy i Notification Center — a niemal każdy widżet na nim robi coś po kliknięciu lewym, prawym i środkowym przyciskiem.

### Okna same się układają

Największa zmiana w sposobie myślenia: nie przeciągasz okien ani nie przyciągasz ich do połówek ekranu. Otwierasz okno i zajmuje cały ekran. Otwierasz drugie i dzielą ekran między siebie. Nigdy nie wyławiasz okna spod innego, bo okna się nie nakładają.

Kiedy naprawdę potrzebujesz pływającego okna, `Super + T` wyciąga aktywne okno z układu kafelkowego (i wkłada je z powrotem). Ale najpierw daj kafelkom prawdziwą szansę — to serce całości. [Nawigacja](04-navigation.md) cię przez to przeprowadzi.

Przestrzenie robocze będą znajome: to macOS Spaces lub wirtualne pulpity Windows, tyle że faktycznie będziesz ich używać, bo `Super + 1/2/3/4` przeskakuje prosto do jednej z nich, a `Super + Shift + 1/2/3/4` wysyła tam aktywne okno. Żadnego opóźnienia animacji, tylko natychmiastowe skoki. Oznacza to, że możesz nawet nie potrzebować kilku monitorów, jeśli do tego przywykłeś wcześniej.

### Kopiowanie i wklejanie po prostu działają

Na Macu wszędzie miałeś Cmd + C. Na Windows wszędzie miałeś Ctrl + C — z wyjątkiem terminala, gdzie zabija to twój program. Omarchy daje ci `Super + C`, `Super + X` i `Super + V`, i działają wszędzie, z terminalem włącznie. Żadnego osobnego odruchu do nauki dla shella.

Ludzie z Windows: wasza historia schowka Win + V mieszka pod `Super + Ctrl + V` i trzyma obrazy równie dobrze jak tekst. Zobacz [ujednolicony schowek i historia](08-unified-clipboard-history.md).

### Tabela tłumaczeń

| Po co sięgasz | W Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / menu Start | `Super + Space` — menu Omarchy |
| AirDrop | LocalSend, przez `Super + Ctrl + S` — zobacz [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` lub `Print Screen` — zobacz [zrzuty ekranu i nagrywanie](12-screenshots-recording.md) |
| Notification Center | Historia powiadomień pod `Super + Shift + Alt + ,` |
| Time Machine (dla systemu) | Automatyczne [migawki systemu](47-system-snapshots.md) przy każdej aktualizacji |
| App Store / pobieranie instalatora | _Install_ w menu lub `omarchy pkg add` — zobacz [inne pakiety](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ w menu, które edytuje zwykłe pliki konfiguracyjne — zobacz [dotfiles](31-dotfiles.md) |

### Niektóre rzeczy naprawdę są inne

Wiele ustawień mieszka w plikach tekstowych, które edytujesz, a nie w panelach, przez które się przeklikujesz. Brzmi to prymitywnie, dopóki nie uświadomisz sobie, że oznacza to, iż każdą zmianę można zobaczyć, skopiować na następną maszynę i objąć kontrolą wersji. Menu _Setup_ wrzuca cię prosto do właściwego pliku i restartuje to, co trzeba zrestartować, kiedy skończysz.

Aktualizacje przychodzą przez jedno polecenie — _Update > Omarchy_ — które aktualizuje samo Omarchy i każdy pakiet w systemie, robiąc najpierw migawkę. Żadnych aktualizatorów osobnych aplikacji, które męczą cię w losowych momentach. Zobacz [aktualizacje](30-updates.md).

Oprogramowanie pochodzi z menedżera pakietów, a nie z pobranych instalatorów.

A kiedy zamykasz okno, aplikacja faktycznie się kończy. Nie ma zawieszenia rodem z macOS, w którym program dalej działa bez żadnych okien. `Super + W` — albo `Super + Q`, jeśli z taką pamięcią palców tu trafiłeś — oznacza koniec.

### Na sprzęcie Mac

Omarchy działa dobrze na Macach z Intel — zobacz [wsparcie dla Maca](44-mac-support.md). A klawiatura jest dla ciebie łaskawa: Omarchy niczego nie przemapowuje, a Linux traktuje klawisz Command jako Super, więc Super siedzi dokładnie tam, gdzie zawsze było Cmd. Twój kciuk nie zauważy przeprowadzki.

### Daj temu dwa tygodnie

Nawyki przenoszą się szybciej, niż myślisz. Przejrzyj rozdział [skróty klawiszowe](07-hotkeys.md) raz, a za każdym razem, gdy zapomnisz przypisania, wciśnij `Super + K` — pokazuje ci wszystkie. To jedyny skrót, który naprawdę musisz zapamiętać.
