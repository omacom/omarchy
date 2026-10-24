# Przesiadka z Maca lub Windowsa

Jeśli spędziłeś lata na macOS lub Windowsie, twoje palce znają setkę rzeczy, których twój mózg dawno zapomniał, że kiedykolwiek się nauczył. Ten rozdział jest warstwą tłumaczącą: dokąd te nawyki trafiają w Omarchy. Same funkcje są szczegółowo opisane gdzie indziej — tu dostajesz tylko mapę.

### Super jest centrum wszystkiego

Cała pamięć mięśniowa, którą wyrobiłeś wokół klawisza Cmd lub klawisza Windows, przenosi się na jeden klawisz: Super. To klawisz Windows na klawiaturze PC i punkt oparcia dla niemal każdego skrótu w Omarchy.

Twój odruch Spotlight, Raycasta albo menu Start staje się `Super + Space`. Otwiera to menu Omarchy, które uruchamia aplikacje, zmienia ustawienia, instaluje oprogramowanie, przechwytuje ekran — właściwie wszystko. Zacznij pisać, żeby filtrować. `Super + Alt + Space` pokazuje wszystkie aplikacje na jednej siatce, tak jak Launchpad. Zob. [nawigacja](04-navigation.md).

### Nie ma docka ani ikon na pulpicie

Nie ma w co klikać, żeby uruchamiać rzeczy, ani ikon do porządkowania na pulpicie. Aplikacje startują ze skrótu (`Super + Return` dla terminala, `Super + Shift + Return` dla przeglądarki i `Super + K` dla listy wszystkiego, co jest przypisane) albo z menu. Jedynym stałym elementem interfejsu jest [górny pasek](05-the-top-bar.md), który przejmuje to, co wcześniej robił dla ciebie pasek menu, zasobnik systemowy i Centrum powiadomień — a prawie każdy widget na nim robi coś po kliknięciu lewym, prawym i środkowym przyciskiem.

### Okna same się układają

Największa zmiana myślenia: nie przeciągasz okien tu i tam ani nie przyciągasz ich do połów ekranu. Otwierasz okno i zajmuje cały ekran. Otwierasz drugie i dzielą ekran na pół. Nigdy nie wyciągasz okna spod innego, bo okna się nie nakładają.

Gdy naprawdę potrzebujesz pływającego okna, `Super + T` przełącza aktywne okno poza układ kafelkowy (i z powrotem). Ale najpierw daj kafelkom prawdziwą szansę — to serce całej sprawy. [Nawigacja](04-navigation.md) przeprowadza cię przez temat krok po kroku.

Obszary robocze będą znajome: to odpowiednik Spaces z macOS albo wirtualnych pulpitów z Windowsa, z tą różnicą, że faktycznie będziesz ich używać, bo `Super + 1/2/3/4` przenosi cię prosto na wybrany obszar, a `Super + Shift + 1/2/3/4` wysyła tam aktywne okno. Bez opóźnienia animacji, po prostu natychmiastowe skoki. Oznacza to, że być może nie będziesz nawet potrzebować wielu monitorów, jeśli wcześniej byłeś do nich przyzwyczajony.

### Kopiuj i wklej po prostu działają

Na Macu wszędzie miałeś Cmd + C. Na Windowsie wszędzie miałeś Ctrl + C — poza terminalem, gdzie zabija twój program. Omarchy daje ci `Super + C`, `Super + X` i `Super + V`, a działają one wszędzie, także w terminalu. Żadnego osobnego odruchu do nauczenia się dla powłoki.

Użytkownicy Windowsa: wasza historia schowka spod Win + V mieszka pod `Super + Ctrl + V` i trzyma obrazy równie dobrze jak tekst. Zob. [ujednolicony schowek i historia](08-unified-clipboard-history.md).

### Tabela tłumaczeń

| Sięgasz po | W Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / menu Start | `Super + Space` — menu Omarchy |
| AirDrop | LocalSend, przez `Super + Ctrl + S` — zob. [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Print Screen` — zob. [zrzuty ekranu i nagrywanie](12-screenshots-recording.md) |
| Centrum powiadomień | Historia powiadomień pod `Super + Shift + Alt + ,` |
| Time Machine (dla systemu) | Automatyczne [migawek systemu](47-system-snapshots.md) przy każdej aktualizacji |
| App Store / pobieranie instalatora | _Instaluj_ w menu albo `omarchy pkg add` — zob. [inne pakiety](29-other-packages.md) |
| Ustawienia systemu / Panel sterowania | _Ustawienia_ w menu, które edytują zwykłe pliki konfiguracyjne — zob. [dotfiles](31-dotfiles.md) |

### Niektóre rzeczy naprawdę są inne

Wiele ustawień mieszka w plikach tekstowych, które edytujesz, a nie w panelach, które klikasz. Brzmi prymitywnie, dopóki nie uświadomisz sobie, że to oznacza, iż każdą poprawkę można zobaczyć, skopiować na następną maszynę i trzymać pod kontrolą wersji. Menu _Ustawienia_ wrzuca cię prosto do właściwego pliku i restartuje wszystko, co trzeba zrestartować, gdy skończysz.

Aktualizacje przychodzą przez jedno polecenie — _Aktualizuj > Omarchy_ — które aktualizuje samo Omarchy i każdy pakiet w systemie, najpierw tworząc migawkę. Żadnych osobnych aktualizatorów per aplikacja dręczących cię losowo. Zob. [aktualizacje](30-updates.md).

Oprogramowanie pochodzi z menedżera pakietów, a nie z pobieranych instalatorów.

A gdy zamkniesz okno, aplikacja naprawdę się kończy. Nie ma macowego limbo, w którym program działa dalej bez okien. `Super + W` — albo `Super + Q`, jeśli z taką pamięcią palców tu dotarłeś — oznacza: koniec.

### Na sprzęcie Mac

Omarchy działa dobrze na Macach z procesorem Intel — zob. [obsługa Maców](44-mac-support.md). A klawiatura jest dla ciebie łaskawa: Omarchy niczego nie przemapowuje, a Linux traktuje klawisz Command jako Super, więc Super siedzi dokładnie tam, gdzie zawsze był Cmd. Twój kciuk nawet nie zauważy przeprowadzki.

### Daj sobie dwa tygodnie

Nawyki przenoszą się szybciej, niż myślisz. Przejrzyj raz rozdział [skróty](07-hotkeys.md), a gdy będziesz miał pustkę co do przypisania, naciśnij `Super + K` — pokaże ci je wszystkie. To jedyny skrót, który naprawdę musisz zapamiętać.
