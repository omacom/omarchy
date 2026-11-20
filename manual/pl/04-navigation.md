# Nawigacja

Wszystko w Omarchy odbywa się za pomocą klawiatury — _WSZYSTKO!_ Gdy system uruchamia się po raz pierwszy, za pomocą samej myszy dosłownie nic nie zrobisz. Możesz jednak nacisnąć `Super + Space`, aby wyświetlić Menu Omarchy, a stamtąd możesz zrobić niemal wszystko.

Ale Menu Omarchy wcale nie ma być głównym sposobem obsługi systemu przez większość czasu. Możemy działać szybciej! Wszystkie najważniejsze aplikacje są przypisane bezpośrednio do osobnych skrótów klawiszowych. Terminal uruchomisz za pomocą `Super + Return`, a przeglądarkę za pomocą `Super + Shift + Return`. Spróbuj zrobić jedno po drugim, a zobaczysz magię kafelkowania Hyprland w akcji:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Możesz wtedy nacisnąć `Super + J`, aby ułożyć je jedno na drugim zamiast obok siebie:

 ![navigation-stacked](images/navigation-stacked.webp)

Naciśnij `Super + J` ponownie, aby przywrócić je do pozycji obok siebie. Następnie, będąc w przeglądarce, spróbuj `Super + Shift + Arrow Right`, aby zamienić okna miejscami.

Teraz spróbuj `Super + Shift + T`, aby uruchomić monitor Activity. Pojawi się on jako okno pływające. Możesz je ukafelkować za pomocą `Super + T` (i nacisnąć to ponownie, aby znów stało się pływające). Teraz naciśnij `Super + Shift + F`, aby otworzyć menedżer plików. Będziesz mieć zgrabny układ czterech okien:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Pomiędzy oknami, które chcesz uaktywnić, poruszasz się za pomocą `Super + Arrow`. Spowoduje to przełączenie fokusu i przeniesienie kursora na środek nowej aplikacji. Na krawędzi ekranu przechodzi dalej na monitor po tej stronie.

Jeśli naciśniesz `Super + Shift + 2`, przeniesiesz bieżącą aktywną aplikację na drugi obszar roboczy. `Super + Shift + 1` przenosi ją z powrotem. (A `Super + Shift + Alt + 2` przeniesie bieżącą aktywną aplikację na drugi obszar roboczy bez przełączania się na niego).

Przy więcej niż jednym monitorze każdy monitor ma własne obszary robocze od 1 do 10. `Super + 2` przechodzi do drugiego obszaru roboczego monitora, na którym się znajdujesz, a górny pasek każdego monitora pokazuje jego własne obszary robocze oraz ten, który jest wyświetlany. `Super + Tab` przełącza cyklicznie obszary robocze na monitorze, na którym się znajdujesz. `Super + Shift + Ctrl + Arrows` przenosi okno, w którym się znajdujesz, na monitor we wskazanym kierunku, na wyświetlany przez niego obszar roboczy, a `Super + Shift + Alt + Arrows` przenosi obszar roboczy, na którym się znajdujesz, na monitor we wskazanym kierunku, gdzie zajmuje on ten sam numer, jeśli jest wolny. Monitor zachowuje swoje obszary robocze po odłączeniu: dołączają one do ekranu innego monitora, ponumerowane po tych, które już ma, i wracają pod swoje stare numery, gdy monitor powróci.

Jeśli przytrzymasz `Super` i za pomocą myszy klikniesz okno, będziesz mógł zmienić jego położenie. Jeśli przytrzymasz `Super` i użyjesz prawego przycisku myszy, będziesz mógł swobodnie zmieniać rozmiar okna.

Okno zamykasz za pomocą `Super + W` lub `Super + Q` (a wszystkie okna zamykasz za pomocą `Ctrl + Alt + Delete`).

Możesz także przejść do trybu pełnoekranowego za pomocą `Super + F`, a nawet po prostu do pełnej szerokości (zachowując górny pasek) za pomocą `Super + Alt + F` lub do pełnego ekranu w obrębie okna za pomocą `Super + Ctrl + F` (dobre do YouTube!).

### Układ dwindle a układ scrolling

Domyślny układ Omarchy nazywa się dwindle. Utrzymuje wszystkie okna, które otwierasz na jednym obszarze roboczym, przez cały czas widoczne, nawet jeśli musi je w tym celu zmniejszyć.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Możesz jednak także wybrać przekształcenie obszaru roboczego w układ scrolling, w którym okna są ustawione obok siebie poza widoczną krawędzią ekranu. Pojedynczy obszar roboczy przekształcisz w ten układ za pomocą `Super + L`.

Ponowne naciśnięcie `Super + L` przełącza obszar roboczy w tryb pływający, w którym okna swobodnie się nakładają, a Ty umieszczasz je samodzielnie, a trzecie naciśnięcie przywraca go do dwindle. `Super + Alt + L` przechodzi przez nie w drugą stronę. Okno, które i tak jest pływające — takie, które wypiąłeś za pomocą `Super + T`, lub aplikacja, która zawsze otwiera się jako pływająca — pozostaje pływające, gdy obszar roboczy wraca do kafelkowania. Górny pasek oznacza obszar roboczy, na którym się znajdujesz, jego układem: kwadratem dla dwindle, kołem dla scrolling i trójkątem dla trybu pływającego. Kliknięcie tego oznaczenia także przełącza cyklicznie układ, podobnie jak klawisz ekranu na laptopach, które go mają.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Wybór dotyczy każdego obszaru roboczego z osobna i się utrzymuje. Możesz więc trzymać obszar roboczy 1 w układzie dwindle do przeglądania, a obszar roboczy 2 w układzie scrolling do kodu, i wrócą w ten sposób po ponownym uruchomieniu.

Jeśli chcesz używać układu scrolling jako domyślnego, możesz ustawić to w `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Pływające obszary robocze

Pływający obszar roboczy działa jak tradycyjny pulpit: okna nakładają się na siebie, a Ty sam je przesuwasz i zmieniasz ich rozmiar. Każde okno otrzymuje pasek tytułu w kolorach Twojego motywu, z przyciskami do minimalizacji, maksymalizacji i zamykania. `Super + M` minimalizuje także aktywne okno. Zminimalizowane okno czeka w docku; kliknij jego aplikację, aby je przywrócić. Kliknij okno, aby wysunąć je na pierwszy plan. Zmieniaj jego rozmiar z dowolnej krawędzi lub rogu. Kliknij dwukrotnie pasek tytułu, aby zmaksymalizować okno, zachowując widoczny górny pasek, i ponownie, aby przywrócić jego dawny rozmiar. Chrome i inne przeglądarki oparte na Chromium, Disks i Document Viewer pomijają pasek tytułu i zamiast niego używają własnego nagłówka; `Super + Alt + F` je maksymalizuje, a `Super + M` je minimalizuje.

Pływający obszar roboczy pokazuje także dock, z Twoimi przypiętymi aplikacjami, wszystkim, co jest uruchomione, oraz siatką wszystkich aplikacji za przyciskiem aplikacji, który otwierają także `Super + Alt + Space` i _Apps_ w menu Omarchy. Kliknij aplikację na siatce prawym przyciskiem myszy lub naciśnij `Delete`, aby ją odinstalować. Kliknij aplikację, aby ją otworzyć lub wysunąć jej okno na pierwszy plan; kliknij ponownie, aby przełączać cyklicznie jej okna. Files przywraca okno tylko z obszaru roboczego, na którym się znajdujesz, a w przeciwnym razie otwiera nowe, a Terminal i Agent zawsze uruchamiają kolejne, choć zminimalizowane okno wraca w pierwszej kolejności. Środkowe kliknięcie otwiera nowe okno. Przeciągnij ikonę wzdłuż docka, aby ją przenieść; przeciągnięcie uruchomionej aplikacji pomiędzy pozostałe pozostawia ją tam. Kliknij prawym przyciskiem myszy, aby zachować aplikację w docku, usunąć ją stamtąd lub ją zamknąć. Dock ustępuje miejsca oknu pełnoekranowemu. Kliknij przycisk aplikacji prawym przyciskiem myszy, aby przenieść dock na inną krawędź lub sprawić, by ukrywał się do czasu, aż wskaźnik dotrze do jego krawędzi. Pozycja znajduje się także w _Appearance > Dock > Dock Position_, a polecenia `omarchy dock position left` i `omarchy dock autohide on` ustawiają obie te rzeczy z terminala. Aplikacje, które trzymasz w docku, są wygaszone, gdy nie są uruchomione.

Nowe obszary robocze oraz wszystkie, którym nie nadałeś własnego układu za pomocą `Super + L`, używają układu domyślnego. Zmiana układu domyślnego resetuje do niego każdy obszar roboczy bez okien, natomiast obszar z oknami zachowuje układ, który ma. Okno zminimalizowane do docka nadal liczy się jako okno na obszarze roboczym, który opuściło. Wybierz go w _Appearance > Workspace Layout_: Tiling, Scrolling lub Floating. Polecenie `omarchy hyprland workspace layout default scrolling` ustawia go z terminala.

### Grupowanie okien

Okna można grupować za pomocą `Super + G`. Gdy znajdziesz się w grupie, każde okno, które uruchomisz przy aktywnej grupie, będzie do niej należeć. Pomiędzy tymi zgrupowanymi oknami możesz poruszać się za pomocą `Super + Ctrl + Arrow Left/Right` lub `Super + Alt + 1/2/3/4`, aby przejść bezpośrednio do zgrupowanych okien w kolejności.

Możesz przenieść okno poza grupę za pomocą `Super + Alt + G` lub rozłożyć całą grupę, naciskając ponownie `Super + G`. Na koniec możesz przenosić okna spoza grupy do niej za pomocą `Super + Alt + Arrows`.

### Wypinanie okien

Okno możesz wypiąć z przydzielonego mu obszaru roboczego za pomocą `Super + O`. Spowoduje to przypięcie go jako okna pływającego, które podąża za Tobą na każdy obszar roboczy, na który przejdziesz. Świetne do odtwarzaczy wideo i tym podobnych.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Obszar roboczy scratchpad

Istnieje specjalny, pełnowymiarowy obszar roboczy scratchpad, który nakłada się na obszar roboczy, na którym aktualnie się znajdujesz. Dostęp do tego, co się na nim znajduje, uzyskujesz za pomocą `Super + S`, a okna umieszczasz tam za pomocą `Super + Alt + S`.

Sprawdza się dobrze w przypadku elementów sterujących lub terminala, z którym chcesz szybko wejść w interakcję bez opuszczania bieżącego obszaru roboczego.

### Konsola Quake

Na koniec jest konsola Quake o połowie wysokości, która wysuwa się w dół na obszar roboczy, na którym aktualnie się znajdujesz. Przełączasz ją za pomocą `Super + Grave`, a okno umieszczasz tam za pomocą `Super + Shift + Grave`.

Przy pierwszym otwarciu uruchamia Twojego domyślnego agenta lub prosi o wybranie jednego, jeśli jeszcze go nie wybrałeś. Gdy konsola zawiera jedno okno, wysuwa się jako wyśrodkowany panel zamiast rozciągać się na cały ekran. Umieść na niej drugą aplikację, a wróci do pełnej szerokości, aby obie miały miejsce obok siebie.

Aby przenieść okno poza scratchpad lub konsolę, wyślij je bezpośrednio na inny obszar roboczy za pomocą czegoś w rodzaju `Super + Shift + 1`.

### Trzeba się do tego przyzwyczaić!

Przyzwyczajenie się do takiej nawigacji po pulpicie zajmuje trochę czasu, ale gdy już się przyzwyczaisz, trudno będzie wrócić do tradycyjnego pulpitu obsługiwanego myszą!
