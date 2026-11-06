# Nawigacja

Wszystko w Omarchy dzieje się za pomocą klawiatury — _WSZYSTKO!_ Gdy system uruchamia się po raz pierwszy, dosłownie nic nie zrobisz samą myszą. Ale możesz wcisnąć `Super + Space`, aby odsłonić Menu Omarchy, a stamtąd możesz zrobić niemal wszystko.

Ale menu Omarchy przez większość czasu nie ma być nawet głównym sposobem obsługi systemu. Potrafimy szybciej! Wszystkie najważniejsze aplikacje są przypisane bezpośrednio do pojedynczych skrótów klawiszowych. Terminal uruchamiasz za pomocą `Super + Return`, a przeglądarkę za pomocą `Super + Shift + Return`. Spróbuj zrobić jedno po drugim, a zobaczysz magię kafelkowania Hyprland w akcji:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Możesz następnie wcisnąć `Super + J`, aby ułożyć je jedno na drugim zamiast obok siebie:

 ![navigation-stacked](images/navigation-stacked.webp)

Wciśnij `Super + J` ponownie, aby przywrócić je do pozycji obok siebie. Następnie spróbuj `Super + Shift + Arrow Right` w przeglądarce, aby zamienić okna miejscami.

Teraz spróbuj `Super + Shift + T`, aby uruchomić monitor aktywności. Pojawi się jako okno pływające. Możesz je ułożyć w kafelki za pomocą `Super + T` (i wcisnąć to ponownie, aby znów stało się pływające). Teraz wciśnij `Super + Shift + F`, aby otworzyć menedżer plików. Będziesz mieć zgrabny układ na cztery:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Między oknami, które chcesz aktywować, poruszasz się za pomocą `Super + Arrow`. Przełączy to fokus i przeniesie kursor na środek nowej aplikacji. Na krawędzi ekranu przejdzie dalej na monitor po tej stronie.

Jeśli wciśniesz `Super + Shift + 2`, przeniesiesz bieżącą aktywną aplikację na drugi obszar roboczy. `Super + Shift + 1` przenosi ją z powrotem. (A `Super + Shift + Alt + 2` przeniesie bieżącą aktywną aplikację na drugi obszar roboczy bez przełączania się na niego).

Przy więcej niż jednym monitorze każdy monitor ma własne obszary robocze od 1 do 10. `Super + 2` przechodzi do drugiego obszaru roboczego monitora, na którym jesteś, a górny pasek każdego monitora pokazuje jego własne obszary robocze oraz ten, który wyświetla. `Super + Tab` przełącza cyklicznie obszary robocze na monitorze, na którym jesteś. `Super + Shift + Ctrl + Arrows` przenosi okno, na którym jesteś, na monitor w tym kierunku, na obszar roboczy, który on wyświetla, a `Super + Shift + Alt + Arrows` przenosi obszar roboczy, na którym jesteś, na monitor w tym kierunku, gdzie przyjmuje ten sam numer, jeśli jest wolny. Monitor zachowuje swoje obszary robocze po odłączeniu: dołączają one do obszarów innego ekranu, ponumerowane po tych, które on już ma, i wracają pod swoje stare numery, gdy monitor powraca.

Jeśli przytrzymasz `Super` i klikniesz myszą okno, będziesz mógł zmienić jego położenie. Jeśli przytrzymasz `Super` i użyjesz prawego przycisku myszy, możesz swobodnie zmieniać rozmiar okna.

Okno zamykasz za pomocą `Super + W` lub `Super + Q` (a wszystkie okna zamykasz za pomocą `Ctrl + Alt + Delete`).

Możesz też przejść na pełny ekran za pomocą `Super + F` albo nawet tylko na pełną szerokość (zachowując górny pasek) za pomocą `Super + Alt + F`, albo na pełny ekran wewnątrz okna za pomocą `Super + Ctrl + F` (dobre dla YouTube!).

### Układ dwindle a układ przewijany

Domyślny układ Omarchy nazywa się dwindle. Utrzymuje wszystkie okna otwarte na pojedynczym obszarze roboczym widoczne przez cały czas, nawet jeśli musi je pomniejszyć.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Ale możesz też zdecydować się zamienić obszar roboczy w układ przewijany, w którym okna są ustawione obok siebie, poza widoczną krawędzią ekranu. Pojedynczy obszar roboczy zamieniasz w ten układ za pomocą `Super + L`.

Ponowne wciśnięcie `Super + L` zamienia obszar roboczy w pływający, w którym okna swobodnie się nakładają, a ty ustawiasz je samodzielnie, a trzecie wciśnięcie przywraca go do dwindle. `Super + Alt + L` przechodzi przez nie w drugą stronę. Okno, które i tak pływa — takie, które wysunąłeś za pomocą `Super + T`, albo aplikacja, która zawsze otwiera się jako pływająca — pozostaje pływające, gdy obszar roboczy wraca do kafelkowania. Górny pasek oznacza obszar roboczy, na którym jesteś, jego układem: kwadrat dla dwindle, koło dla przewijanego i trójkąt dla pływającego. Kliknięcie tego znaku również przełącza cyklicznie układ.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Wybór dotyczy każdego obszaru roboczego z osobna i zostaje zachowany. Możesz więc trzymać obszar roboczy 1 na dwindle do przeglądania, a obszar roboczy 2 na przewijanym do kodu, i wrócą w ten sposób po ponownym uruchomieniu.

Jeśli chcesz używać układu przewijanego jako domyślnego, możesz ustawić to w `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Pływające obszary robocze

Pływający obszar roboczy działa jak tradycyjny pulpit: okna się nakładają, a ty samodzielnie je przesuwasz i zmieniasz ich rozmiar. Każde okno otrzymuje pasek tytułu w kolorach twojego motywu, z przyciskami do minimalizowania, maksymalizowania i zamykania. `Super + M` również minimalizuje aktywne okno. Zminimalizowane okno czeka w docku; kliknij jego aplikację, aby je przywrócić. Kliknij okno, aby wysunąć je na przód. Zmieniaj jego rozmiar z dowolnej krawędzi lub rogu. Kliknij dwukrotnie pasek tytułu, aby zmaksymalizować okno przy zachowaniu widocznego górnego paska, i ponownie, aby przywrócić jego dawny rozmiar.

Pływający obszar roboczy pokazuje też dock, z twoimi przypiętymi aplikacjami, wszystkim, co jest uruchomione, oraz siatką każdej aplikacji za przyciskiem aplikacji, który otwierają też `Super + Alt + Space` oraz _Aplikacje_ w menu Omarchy. Kliknij prawym przyciskiem myszy aplikację na siatce lub wciśnij `Delete`, aby ją odinstalować. Kliknij aplikację, aby ją otworzyć albo wysunąć jej okno na przód; kliknij ponownie, aby przełączać cyklicznie jej okna. Kliknięcie środkowym przyciskiem otwiera nowe okno. Przeciągnij ikonę wzdłuż docka, aby ją przenieść; przeciągnięcie uruchomionej aplikacji pomiędzy pozostałe zachowuje ją tam. Kliknij prawym przyciskiem myszy, aby zachować aplikację w docku, usunąć ją stamtąd albo ją zakończyć. Dock ustępuje miejsca oknu pełnoekranowemu. Kliknij prawym przyciskiem myszy przycisk aplikacji, aby przenieść dock na inną krawędź albo sprawić, by ukrywał się, dopóki wskaźnik nie dotrze do jego krawędzi. Pozycja znajduje się też w _Wygląd > Dock > Pozycja docka_, a `omarchy dock position left` oraz `omarchy dock autohide on` ustawiają obie te opcje z terminala. Aplikacje, które trzymasz w docku, są wyblakłe, gdy nie są uruchomione.

Nowe obszary robocze oraz wszystkie, którym nie nadałeś własnego układu za pomocą `Super + L`, używają układu domyślnego. Zmiana domyślnego ustawia na niego każdy obszar roboczy bez okien, natomiast ten z oknami zachowuje układ, który ma. Okno zminimalizowane do docka nadal liczy się jako okno na obszarze roboczym, który opuściło. Wybierasz go w _Wygląd > Układ obszaru roboczego_: Kafelkowy, Przewijany lub Pływający. `omarchy-hyprland-workspace-layout-default scrolling` ustawia go z terminala.

### Grupowanie okien

Okna można grupować za pomocą `Super + G`. Gdy jesteś w grupie, każde okno uruchomione, gdy jest ona aktywna, będzie należeć do grupy. Między tymi zgrupowanymi oknami możesz poruszać się za pomocą `Super + Ctrl + Arrow Left/Right` lub `Super + Alt + 1/2/3/4`, aby przejść bezpośrednio do zgrupowanych okien po kolei.

Możesz przenieść okno poza grupowanie za pomocą `Super + Alt + G` albo rozebrać całą grupę, wciskając ponownie `Super + G`. Na koniec możesz przenieść okna spoza grupy do niej za pomocą `Super + Alt + Arrows`.

### Wysuwanie okien

Możesz wysunąć okno z jego przydziału do obszaru roboczego za pomocą `Super + O`. Przypnie je to jako okno pływające, które podąża za tobą na każdy obszar roboczy, na który przejdziesz. Świetne dla odtwarzaczy wideo i tym podobnych.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Obszar roboczy scratchpad

Jest specjalny pełnowymiarowy obszar roboczy scratchpad, który nakłada się na obszar roboczy, na którym aktualnie jesteś. Dostęp do tego, co się na nim znajduje, uzyskujesz za pomocą `Super + S`, a okna umieszczasz tam za pomocą `Super + Alt + S`.

Sprawdza się dobrze dla elementów sterujących albo terminala, z którym chcesz szybko wejść w interakcję bez opuszczania bieżącego obszaru roboczego.

### Konsola Quake

Wreszcie jest konsola Quake o połowie wysokości, która opada na obszar roboczy, na którym aktualnie jesteś. Przełączasz ją za pomocą `Super + Grave`, a okno umieszczasz tam za pomocą `Super + Shift + Grave`.

Otwiera się z twoim domyślnym agentem gotowym do pracy. Gdy konsola zawiera pojedyncze okno, opada jako wyśrodkowany panel, zamiast rozciągać się na cały ekran. Umieść na niej drugą aplikację, a wróci do pełnej szerokości, aby obie miały miejsce, by siedzieć obok siebie.

Aby przenieść okno ze scratchpada albo konsoli, wyślij je bezpośrednio na inny obszar roboczy czymś takim jak `Super + Shift + 1`.

### Trzeba się trochę przyzwyczaić!

Przyzwyczajenie się do poruszania się po pulpicie w ten sposób zajmuje trochę czasu, ale gdy już to zrobisz, trudno będzie wrócić do tradycyjnego pulpitu obsługiwanego myszą!
