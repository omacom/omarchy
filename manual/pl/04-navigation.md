# Nawigacja

Wszystko w Omarchy dzieje się za pomocą klawiatury — _WSZYSTKO!_ Gdy system uruchamia się po raz pierwszy, dosłownie nic nie zrobisz samą myszą. Możesz jednak nacisnąć `Super + Space`, aby wywołać Menu Omarchy, a stąd możesz zrobić niemal wszystko.

Ale Menu Omarchy przez większość czasu wcale nie ma być głównym sposobem obsługi systemu. Możemy być szybsi! Wszystkie najważniejsze aplikacje są przypisane bezpośrednio do poszczególnych skrótów klawiszowych. Terminal uruchamiasz za pomocą `Super + Return`, a przeglądarkę za pomocą `Super + Shift + Return`. Spróbuj zrobić jedno po drugim, a zobaczysz w akcji magię kafelkowego układania okien Hyprland:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Możesz potem nacisnąć `Super + J`, aby ułożyć je jedno na drugim zamiast obok siebie:

 ![navigation-stacked](images/navigation-stacked.webp)

Naciśnij `Super + J` ponownie, aby przywrócić je do pozycji obok siebie. Następnie, będąc w przeglądarce, spróbuj `Super + Shift + Arrow Right`, aby zamienić okna miejscami.

Teraz spróbuj `Super + Shift + T`, aby uruchomić Monitor aktywności. Pojawi się jako okno pływające, z paskiem tytułu, za który możesz je przeciągać, oraz przyciskami do minimalizowania, maksymalizowania i zamykania. Każde pływające okno otrzymuje taki pasek, gdziekolwiek się znajduje. Możesz je ułożyć w kafelki za pomocą `Super + T` (i nacisnąć to ponownie, aby znów stało się pływające). Teraz naciśnij `Super + Shift + F`, aby otworzyć menedżer plików. Będziesz mieć zgrabny układ czterech okien:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Pomiędzy oknami, które mają być aktywne, poruszasz się za pomocą `Super + Arrow`. Spowoduje to przełączenie fokusu i przeniesienie kursora na środek nowej aplikacji. Na krawędzi ekranu przechodzi dalej na monitor po tej stronie.

Jeśli naciśniesz `Super + Shift + 2`, przeniesiesz bieżącą aktywną aplikację na drugi obszar roboczy. `Super + Shift + 1` przenosi ją z powrotem. (A `Super + Shift + Alt + 2` przeniesie bieżącą aktywną aplikację na drugi obszar roboczy bez przełączania się na niego).

Przy więcej niż jednym monitorze każdy monitor ma własne obszary robocze od 1 do 10. `Super + 2` przechodzi do drugiego obszaru roboczego monitora, na którym się znajdujesz, a górny pasek każdego monitora pokazuje jego własne obszary robocze i ten, który aktualnie wyświetla. `Super + Tab` cyklicznie przełącza obszary robocze na monitorze, na którym się znajdujesz. `Super + Shift + Ctrl + Arrows` przenosi okno, na którym się znajdujesz, na monitor w tym kierunku, na obszar roboczy, który on wyświetla, a `Super + Shift + Alt + Arrows` przenosi obszar roboczy, na którym się znajdujesz, na monitor w tym kierunku, gdzie zajmuje ten sam numer, jeśli jest wolny. Monitor zachowuje swoje obszary robocze po odłączeniu: dołączają one do innego ekranu, ponumerowane po tych, które on już ma, i wracają pod swoje stare numery, gdy monitor powróci.

Jeśli przytrzymasz `Super` i klikniesz myszą okno, będziesz mógł zmienić miejsce, w którym się znajduje. Jeśli przytrzymasz `Super` i użyjesz prawego przycisku myszy, możesz swobodnie zmieniać rozmiar okna.

Okno zamykasz za pomocą `Super + W` lub `Super + Q` (a wszystkie okna zamykasz za pomocą `Ctrl + Alt + Delete`).

Możesz też przejść do pełnego ekranu za pomocą `Super + F`, a nawet tylko do pełnej szerokości (zachowując górny pasek) za pomocą `Super + Alt + F` lub do pełnego ekranu w obrębie okna za pomocą `Super + Ctrl + F` (dobre dla YouTube!).

### Układ dwindle a układ scrolling

Domyślny układ Omarchy nazywa się dwindle. Utrzymuje on wszystkie okna otwarte na jednym obszarze roboczym zawsze widoczne, nawet jeśli musi je zmniejszyć.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Możesz jednak także zdecydować się przekształcić obszar roboczy w układ scrolling, w którym okna są ustawione obok siebie, poza widoczną krawędzią ekranu. Pojedynczy obszar roboczy przekształcasz w ten układ za pomocą `Super + L`.

Ponowne naciśnięcie `Super + L` zmienia obszar roboczy w pływający, w którym okna swobodnie na siebie nachodzą i sam je umieszczasz, a trzecie naciśnięcie przywraca go do dwindle. `Super + Alt + L` przechodzi przez nie w drugą stronę. Okno, które i tak jest pływające — takie, które wysunąłeś za pomocą `Super + T`, lub aplikacja, która zawsze otwiera się jako pływająca — pozostaje pływające, gdy obszar roboczy wraca do układania kafelkowego. Górny pasek oznacza obszar roboczy, na którym się znajdujesz, jego układem: kwadratem dla dwindle, kołem dla scrolling i trójkątem dla floating. Kliknięcie tego znaku również cyklicznie zmienia układ, podobnie jak klawisz wyświetlania na laptopach, które taki mają.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Wybór dotyczy każdego obszaru roboczego z osobna i jest trwały. Możesz więc zachować obszar roboczy 1 w układzie dwindle do przeglądania, a obszar roboczy 2 w układzie scrolling do kodu, i wrócą one w ten sposób po ponownym uruchomieniu.

Jeśli chcesz używać układu scrolling jako domyślnego, możesz ustawić to w `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Pływające obszary robocze

Pływający obszar roboczy działa jak tradycyjny pulpit: okna nachodzą na siebie, a ty sam je przesuwasz i zmieniasz ich rozmiar. Każde okno otrzymuje pasek tytułu w kolorach twojego motywu, z przyciskami do minimalizowania, maksymalizowania i zamykania. `Super + M` minimalizuje także aktywne okno. Zminimalizowane okno czeka w doku; kliknij jego aplikację, aby je przywrócić. Kliknij okno, aby wysunąć je na wierzch. Zmieniaj jego rozmiar od dowolnej krawędzi lub dowolnego rogu. Kliknij dwukrotnie pasek tytułu, aby zmaksymalizować okno przy zachowaniu widocznego górnego paska, i ponownie, aby przywrócić jego dawny rozmiar. Chrome i inne przeglądarki oparte na Chromium, Disks i Document Viewer pomijają pasek tytułu i używają zamiast niego własnego nagłówka; `Super + Alt + F` je maksymalizuje, a `Super + M` je minimalizuje.

Każdy obszar roboczy ma dok, z twoimi przypiętymi aplikacjami, wszystkim, co jest uruchomione, oraz siatką wszystkich aplikacji za przyciskiem aplikacji, który otwierają także `Super + Alt + Space` i _Apps_ w Menu Omarchy. Kliknij aplikację na siatce prawym przyciskiem myszy lub naciśnij `Delete`, aby ją odinstalować. Kliknij aplikację, aby ją otworzyć lub wysunąć jej okno na wierzch; kliknij ponownie, aby cyklicznie przechodzić przez jej okna. Files przywraca jedynie okno z obszaru roboczego, na którym się znajdujesz, a w przeciwnym razie otwiera nowe, natomiast Terminal i Agent zawsze uruchamiają kolejne, choć zminimalizowane okno wraca najpierw. Kliknięcie środkowym przyciskiem myszy otwiera nowe okno. Przeciągnij ikonę wzdłuż doku, aby ją przenieść; przeciągnięcie uruchomionej aplikacji pomiędzy pozostałe pozostawia ją tam. Kliknij prawym przyciskiem myszy, aby zachować aplikację w doku, usunąć ją stamtąd lub ją zamknąć. Dok pozostaje widoczny, gdy obszar roboczy jest pusty, a gdy tylko obszar roboczy ma okno, ukrywa się, aż wskaźnik dotrze do jego krawędzi. Okno pełnoekranowe ukrywa go całkowicie. Przeciągnij przycisk aplikacji w stronę innej krawędzi ekranu, aby przenieść tam dok. Kliknij go prawym przyciskiem myszy, aby wybrać _Position_, by wybrać krawędź, _Layout_, by ustawić domyślny układ tak, jak robi to _Appearance > Workspace Layout_, oraz _Visibility_, by dok był zawsze włączony, pierwsza aplikacja go ukrywała lub był zawsze ukryty. `omarchy dock visibility always` ustawia to z terminala. Położenie znajduje się także w _Appearance > Dock > Dock Position_, a `omarchy dock position left` ustawia je z terminala. Aplikacje, które trzymasz w doku, są przygaszone, gdy nie są uruchomione. Aby ograniczyć dok do pływających obszarów roboczych, użyj _Appearance > Dock > Dock Only on Floating_ lub `omarchy dock tiling off`.

Nowe obszary robocze oraz wszystkie, którym nie nadałeś własnego układu za pomocą `Super + L`, używają układu domyślnego. Zmiana układu domyślnego resetuje do niego każdy obszar roboczy bez okien, natomiast ten z oknami zachowuje układ, który ma. Okno zminimalizowane do doku nadal liczy się jako okno na obszarze roboczym, który opuściło. Wybierz go w _Appearance > Workspace Layout_: Tiling, Scrolling lub Floating. `omarchy hyprland workspace layout default scrolling` ustawia to z terminala.

### Grupowanie okien

Okna można grupować za pomocą `Super + G`. Gdy już jesteś w grupie, każde okno uruchomione, gdy jest ona aktywna, będzie należeć do grupy. Pomiędzy tymi zgrupowanymi oknami możesz poruszać się za pomocą `Super + Ctrl + Arrow Left/Right` lub `Super + Alt + 1/2/3/4`, aby przejść bezpośrednio do zgrupowanych okien w kolejności.

Okno możesz przenieść poza grupę za pomocą `Super + Alt + G` lub rozmontować całą grupę, naciskając ponownie `Super + G`. Wreszcie, okna spoza grupy możesz przenieść do niej za pomocą `Super + Alt + Arrows`.

### Wysuwanie okien

Możesz wysunąć okno poza jego przydział do obszaru roboczego za pomocą `Super + O`. Przypnie je to jako pływające okno, które podąża za tobą na każdy obszar roboczy, na który przejdziesz. Świetne dla odtwarzaczy wideo i podobnych.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Obszar roboczy scratchpad

Istnieje specjalny obszar roboczy scratchpad o pełnym rozmiarze, który nakłada się na obszar roboczy, na którym aktualnie się znajdujesz. Dostęp do tego, co się na nim znajduje, uzyskujesz za pomocą `Super + S`, a okna umieszczasz tam za pomocą `Super + Alt + S`.

Dobrze sprawdza się dla elementów sterowania lub terminala, z którym chcesz szybko wejść w interakcję bez opuszczania bieżącego obszaru roboczego.

### Konsola Quake

Wreszcie istnieje konsola Quake o połowie wysokości, która wysuwa się w dół na obszar roboczy, na którym aktualnie się znajdujesz. Przełączasz ją za pomocą `Super + the key above Tab` (grave w układach US), a okno umieszczasz tam za pomocą `Super + Shift + the key above Tab`.

Za pierwszym razem, gdy się otwiera, uruchamia twojego domyślnego agenta lub prosi cię o wybranie jednego, jeśli jeszcze go nie wybrałeś. Gdy konsola zawiera jedno okno, wysuwa się w dół jako wyśrodkowany panel, zamiast obejmować cały ekran. Umieść na niej drugą aplikację, a wróci do pełnej szerokości, aby obie miały miejsce obok siebie.

Aby przenieść okno z obszaru scratchpad lub z konsoli, wyślij je bezpośrednio na inny obszar roboczy za pomocą czegoś takiego jak `Super + Shift + 1`.

### Trzeba się trochę przyzwyczaić!

Przyzwyczajenie się do takiego poruszania się po pulpicie zajmuje trochę czasu, ale gdy już to zrobisz, trudno będzie wrócić do tradycyjnego pulpitu obsługiwanego myszą!
