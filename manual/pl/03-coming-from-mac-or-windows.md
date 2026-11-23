# Przesiadka z Maca lub Windowsa

Jeśli od lat używasz macOS lub Windows, twoje palce znają sto rzeczy, o których twój mózg zapomniał, że w ogóle się ich nauczył. Ten rozdział to warstwa tłumacząca: dokąd trafiają te odruchy w Omarchy. Same funkcje są dogłębnie opisane gdzie indziej — to jest tylko mapa.

### Super jest centrum wszystkiego

Cała pamięć mięśniowa wypracowana wokół Cmd lub klawisza Windows przenosi się na jeden klawisz: Super. To właśnie klawisz Windows na klawiaturze PC i to on jest osią niemal każdego skrótu klawiszowego w Omarchy.

Twój odruch sięgania po Spotlight, Raycast albo menu Start zamienia się w `Super + Space`. Otwiera to menu Omarchy, które uruchamia aplikacje, zmienia ustawienia, instaluje oprogramowanie, przechwytuje ekran — właściwie wszystko. Zacznij pisać, aby filtrować. `Super + Alt + Space` pokazuje wszystkie aplikacje na jednej siatce, tak jak robi to Launchpad. Zobacz [nawigację](04-navigation.md).

### Bez ikon na pulpicie, a dock pojawia się tylko w trybie pływającym

Żadnych ikon do układania na pulpicie i żadnego docka na kafelkowym obszarze roboczym — dock pojawia się tylko na pływającym obszarze roboczym (zobacz [nawigację](04-navigation.md)). Aplikacje uruchamiasz skrótem klawiszowym (`Super + Return` dla terminala, `Super + Shift + Return` dla przeglądarki i `Super + K` dla listy wszystkiego, co jest przypisane) albo z menu. Jedynym stałym elementem interfejsu jest [górny pasek](05-the-top-bar.md), który przejmuje to, co wcześniej robiły dla ciebie pasek menu, zasobnik systemowy i Notification Center — a prawie każdy widżet na nim robi coś po kliknięciu lewym, prawym i środkowym przyciskiem myszy.

### Okna ustawiają się same

Największa zmiana w sposobie myślenia: nie przeciągasz okien po ekranie ani nie przyciągasz ich do połówek ekranu. Otwierasz okno i zajmuje cały ekran. Otwierasz drugie i dzielą ekran między siebie. Nigdy nie wyławiasz okna spod innego, bo okna się nie nakładają.

Gdy naprawdę potrzebujesz pływającego okna, `Super + T` wyciąga aktywne okno z układu kafelkowego (i z powrotem). Ale najpierw daj kafelkowaniu prawdziwą szansę — to serce całej sprawy. [Nawigacja](04-navigation.md) przeprowadzi cię przez to krok po kroku.

Obszary robocze będą wydawać się znajome: to odpowiednik Spaces z macOS lub wirtualnych pulpitów z Windows, tyle że naprawdę będziesz z nich korzystać, bo `Super + 1/2/3/4` przeskakuje od razu na wybrany, a `Super + Shift + 1/2/3/4` wysyła tam aktywne okno. Żadnego opóźnienia na animację, tylko natychmiastowe przeskoki. Oznacza to, że możesz nawet nie potrzebować kilku monitorów, jeśli wcześniej z nich korzystałeś.

### Kopiowanie i wklejanie po prostu działają

Na Macu wszędzie było Cmd + C. Na Windows wszędzie było Ctrl + C — z wyjątkiem terminala, gdzie zabija to twój program. Omarchy daje ci `Super + C`, `Super + X` i `Super + V`, i działają one wszędzie, także w terminalu. Żadnego osobnego odruchu do nauki dla powłoki.

Użytkownicy Windows: wasza historia schowka z Win + V mieszka pod `Super + Ctrl + V` i przechowuje obrazy, a nie tylko tekst. Zobacz [ujednolicony schowek i historię](08-unified-clipboard-history.md).

### Tabela odpowiedników

| Sięgasz po | W Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / menu Start | `Super + Space` — menu Omarchy |
| AirDrop | LocalSend, za pomocą `Super + Ctrl + S` — zobacz [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` lub `Print Screen` — zobacz [zrzuty ekranu i nagrywanie](12-screenshots-recording.md) |
| Notification Center | Historia powiadomień pod `Super + Shift + Alt + ,` |
| Time Machine (dla systemu) | Automatyczne [migawki systemu](47-system-snapshots.md) przy każdej aktualizacji |
| App Store / pobieranie instalatora | _Install_ w menu albo `omarchy pkg add` — zobacz [inne pakiety](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ w menu, które edytuje zwykłe pliki konfiguracyjne — zobacz [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, pod `Super + Shift + F` — zobacz [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome pod `Super + Shift + Return`; wybierz inną w _Setup > Defaults > Browser_ — zobacz [przeglądarki](23-browsers.md) |
| Preview / Photos | Omaview do zdjęć, wideo i muzyki, Document Viewer do PDF-ów — zobacz [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, pod `Super + Shift + N`; wybierz inny w _Setup > Defaults > Editor_ |

### Niektóre rzeczy naprawdę są inne

Wiele ustawień mieszka w plikach tekstowych, które edytujesz, a nie w panelach, przez które się przeklikujesz. Brzmi to prymitywnie, dopóki nie zdasz sobie sprawy, że oznacza to, iż każdą zmianę można zobaczyć, skopiować na następną maszynę i umieścić pod kontrolą wersji. Menu _Setup_ wrzuca cię prosto do właściwego pliku i po zakończeniu restartuje wszystko, co wymaga restartu.

Aktualizacje przychodzą przez jedną komendę — _Update > Omarchy_ — która aktualizuje samo Omarchy i każdy pakiet w systemie, najpierw robiąc migawkę. Żadnych osobnych aktualizatorów dla każdej aplikacji, które męczą cię w losowych momentach. Zobacz [aktualizacje](30-updates.md).

Oprogramowanie pochodzi z menedżera pakietów, a nie z pobranych instalatorów.

A gdy zamkniesz okno, aplikacja naprawdę się kończy. Nie ma limbo znanego z macOS, w którym program dalej działa bez żadnych okien. `Super + W` — albo `Super + Q`, jeśli z taką pamięcią palców tu przychodzisz — oznacza koniec.

### Na sprzęcie Mac

Omarchy działa dobrze na Macach z Intelem oraz na Macach z M1, M2 i M3 z Omarchy for Apple Silicon. Zobacz [wsparcie dla Maców](44-mac-support.md). A klawiatura jest dla ciebie łaskawa: Omarchy niczego nie przemapowuje, a Linux traktuje klawisz Command jako Super, więc Super siedzi dokładnie tam, gdzie zawsze było Cmd. Twój kciuk nie zauważy przeprowadzki.

### Daj sobie dwa tygodnie

Odruchy przenoszą się szybciej, niż myślisz. Przejrzyj raz rozdział o [skrótach klawiszowych](07-hotkeys.md), a gdy tylko zapomnisz jakiegoś przypisania, wciśnij `Super + K` — pokaże ci wszystkie. To jedyny skrót, który tak naprawdę musisz zapamiętać.
