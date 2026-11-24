# Nawigacja

Wszystko w Omarchy odbywa się za pomocą klawiatury — _WSZYSTKO!_ Gdy system uruchamia się po raz pierwszy, dosłownie nic nie zdziałasz samą myszą. Ale możesz nacisnąć `Super + Space`, aby otworzyć Omarchy Menu i stąd zrobisz niemal wszystko.

Ale Omarchy menu wcale nie ma być nawet głównym sposobem obsługi systemu przez większość czasu. Możemy być szybsi! Wszystkie najważniejsze aplikacje są przypisane bezpośrednio do poszczególnych skrótów klawiszowych. Terminal uruchomisz za pomocą `Super + Return`, a przeglądarkę za pomocą `Super + Shift + Return`. Spróbuj zrobić jedno po drugim, a zobaczysz magię kafelkowania Hyprland w akcji:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Następnie możesz nacisnąć `Super + J`, aby ułożyć je jedno na drugim zamiast obok siebie:

 ![navigation-stacked](images/navigation-stacked.webp)

Naciśnij `Super + J` ponownie, aby przywrócić je do pozycji obok siebie. Następnie spróbuj `Super + Shift + Arrow Right` w przeglądarce, aby zamienić okna miejscami.

Teraz spróbuj `Super + Shift + T`, aby uruchomić monitor aktywności Activity. Pojawi się jako pływające okno. Możesz je ustawić w kafelkach za pomocą `Super + T` (i nacisnąć to ponownie, aby znów było pływające). Teraz naciśnij `Super + Shift + F`, aby otworzyć menedżer plików. Będziesz mieć zgrabny układ czterech okien:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Pomiędzy oknami, które chcesz aktywować, nawigujesz za pomocą `Super + Arrow`. Spowoduje to przełączenie fokusu i przesunięcie kursora do środka nowej aplikacji. Na krawędzi ekranu przejdzie dalej na monitor po tej stronie.

Jeśli naciśniesz `Super + Shift + 2`, przeniesiesz bieżącą aktywną aplikację na drugi obszar roboczy. `Super + Shift + 1` przeniesie ją z powrotem. (A `Super + Shift + Alt + 2` przeniesie bieżącą aktywną aplikację na drugi obszar roboczy bez przełączania się na niego).

Przy więcej niż jednym monitorze każdy monitor ma własne obszary robocze od 1 do 10. `Super + 2` przechodzi do drugiego obszaru roboczego monitora, na którym jesteś, a górny pasek każdego monitora pokazuje jego własne obszary robocze i ten, który wyświetla. `Super + Tab` przełącza kolejno obszary robocze na monitorze, na którym jesteś. `Super + Shift + Ctrl + Arrows` przenosi okno, na którym jesteś, na monitor w tym kierunku, na obszar roboczy, który on wyświetla, a `Super + Shift + Alt + Arrows` przenosi obszar roboczy, na którym jesteś, na monitor w tym kierunku, gdzie zajmuje ten sam numer, jeśli jest wolny. Monitor zachowuje swoje obszary robocze, gdy go odłączysz: dołączają one do innego ekranu, ponumerowane po tych, które on już ma, i wracają pod swoje stare numery, gdy monitor powróci.

Jeśli przytrzymasz `Super` i klikniesz myszą na okno, będziesz mógł zmienić jego położenie. Jeśli przytrzymasz `Super` i użyjesz prawego przycisku myszy, możesz swobodnie zmieniać rozmiar okna.

Okno zamkniesz za pomocą `Super + W` lub `Super + Q` (a wszystkie okna zamkniesz za pomocą `Ctrl + Alt + Delete`).

Możesz też przejść do pełnego ekranu za pomocą `Super + F`, a nawet po prostu do pełnej szerokości (zachowując górny pasek) za pomocą `Super + Alt + F`, lub do pełnego ekranu wewnątrz okna za pomocą `Super + Ctrl + F` (dobre dla YouTube!).

### Układ dwindle a układ scrolling

Domyślny układ Omarchy nazywa się dwindle. Utrzymuje wszystkie okna otwarte na jednym obszarze roboczym cały czas widoczne, nawet jeśli musi je zmniejszyć.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Ale możesz też zdecydować się na przekształcenie obszaru roboczego w układ scrolling, w którym okna są ustawione obok siebie, poza widoczną krawędzią ekranu. Jeden obszar roboczy przełączysz w ten układ za pomocą `Super + L`.

Ponowne naciśnięcie `Super + L` przełącza obszar roboczy w tryb pływający, w którym okna swobodnie się nakładają i sam je rozmieszczasz, a trzecie naciśnięcie przywraca go do dwindle. `Super + Alt + L` przechodzi przez nie w drugą stronę. Okno, które i tak jest pływające — takie, które wypiąłeś za pomocą `Super + T`, lub aplikacja, która zawsze otwiera się jako pływająca — pozostaje pływające, gdy obszar roboczy wraca do kafelkowania. Górny pasek oznacza obszar roboczy, na którym jesteś, jego układem: kwadrat dla dwindle, okrąg dla scrolling i trójkąt dla trybu pływającego. Kliknięcie tego oznaczenia również przełącza kolejno układ, podobnie jak klawisz ekranu w laptopach, które taki mają.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Wybór dotyczy każdego obszaru roboczego z osobna i jest trwały. Możesz więc trzymać obszar roboczy 1 w dwindle do przeglądania, a obszar roboczy 2 w scrolling do kodu, i wrócą w ten sposób po ponownym uruchomieniu.

Jeśli chcesz używać układu scrolling jako domyślnego, możesz ustawić to w `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Pływające obszary robocze

Pływający obszar roboczy działa jak tradycyjny pulpit: okna się nakładają, a Ty sam je przesuwasz i zmieniasz ich rozmiar. Każde okno otrzymuje pasek tytułu w kolorach Twojego motywu, z przyciskami do minimalizacji, maksymalizacji i zamykania. `Super + M` minimalizuje również aktywne okno. Zminimalizowane okno czeka w docku; kliknij jego aplikację, aby je przywrócić. Kliknij okno, aby wysunąć je na pierwszy plan. Zmień jego rozmiar z dowolnej krawędzi lub rogu. Kliknij dwukrotnie pasek tytułu, aby zmaksymalizować okno, zachowując widoczny górny pasek, i ponownie, aby przywrócić jego dawny rozmiar. Chrome i inne przeglądarki oparte na Chromium, Disks i Document Viewer pomijają pasek tytułu i zamiast niego używają własnego nagłówka; `Super + Alt + F` je maksymalizuje, a `Super + M` je minimalizuje.

Pływający obszar roboczy pokazuje również dock, z przypiętymi aplikacjami, wszystkim, co jest uruchomione, oraz siatką wszystkich aplikacji za przyciskiem aplikacji, który otwierają również `Super + Alt + Space` i _Apps_ w Omarchy menu. Kliknij aplikację na siatce prawym przyciskiem myszy lub naciśnij `Delete`, aby ją odinstalować. Kliknij aplikację, aby ją otworzyć lub wysunąć jej okno na pierwszy plan; kliknij ponownie, aby przechodzić kolejno przez jej okna. Files przywraca okno tylko z obszaru roboczego, na którym jesteś, a w przeciwnym razie otwiera nowe, a Terminal i Agent zawsze uruchamiają kolejne, choć zminimalizowane okno wraca najpierw. Kliknięcie środkowym przyciskiem otwiera nowe okno. Przeciągnij ikonę wzdłuż docka, aby ją przesunąć; przeciągnięcie uruchomionej aplikacji pomiędzy pozostałe pozostawia ją tam. Kliknij prawym przyciskiem, aby zachować aplikację w docku, usunąć ją stamtąd lub ją zakończyć. Dock ustępuje miejsca oknu pełnoekranowemu. Kliknij przycisk aplikacji prawym przyciskiem myszy, aby przenieść dock na inną krawędź lub sprawić, by ukrywał się, dopóki wskaźnik nie dotrze do jego krawędzi. Pozycja znajduje się również w _Appearance > Dock > Dock Position_, a `omarchy dock position left` i `omarchy dock autohide on` ustawiają obie te rzeczy z terminala. Aplikacje, które trzymasz w docku, są przygaszone, gdy nie są uruchomione.

Nowe obszary robocze oraz wszystkie, którym nie nadałeś własnego układu za pomocą `Super + L`, używają domyślnego układu. Zmiana domyślnego układu resetuje do niego każdy obszar roboczy bez okien, natomiast ten z oknami zachowuje układ, który ma. Okno zminimalizowane do docka nadal liczy się jako okno na obszarze roboczym, który opuściło. Wybierz go w _Appearance > Workspace Layout_: Tiling, Scrolling lub Floating. `omarchy hyprland workspace layout default scrolling` ustawia go z terminala.

### Grupowanie okien

Okna można grupować za pomocą `Super + G`. Gdy już jesteś w grupie, każde okno, które uruchomisz, gdy jest ona aktywna, będzie należeć do grupy. Pomiędzy tymi zgrupowanymi oknami możesz poruszać się za pomocą `Super + Ctrl + Arrow Left/Right` lub `Super + Alt + 1/2/3/4`, aby przejść bezpośrednio do zgrupowanych okien w kolejności.

Możesz przenieść okno poza grupowanie za pomocą `Super + Alt + G` lub rozmontować całą grupę, naciskając ponownie `Super + G`. Wreszcie, możesz przenieść okna spoza grupy do niej za pomocą `Super + Alt + Arrows`.

### Wypinanie okien

Możesz wypiąć okno z przypisania do obszaru roboczego za pomocą `Super + O`. Spowoduje to przypięcie go jako pływającego okna, które podąża za Tobą na każdy obszar roboczy, na który przejdziesz. Świetne dla odtwarzaczy wideo i tym podobnych.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Obszar roboczy scratchpad

Istnieje specjalny pełnowymiarowy obszar roboczy scratchpad, który nakłada się na obszar roboczy, na którym aktualnie jesteś. Dostęp do tego, co się na nim znajduje, uzyskasz za pomocą `Super + S`, a okna umieścisz tam za pomocą `Super + Alt + S`.

Sprawdza się dobrze dla elementów sterujących lub terminala, z którymi chcesz szybko wejść w interakcję bez opuszczania bieżącego obszaru roboczego.

### Konsola Quake

Wreszcie, istnieje konsola Quake o połowie wysokości, która opada na obszar roboczy, na którym aktualnie jesteś. Przełączysz ją za pomocą `Super + the key above Tab` (grave w układach US), a okno umieścisz tam za pomocą `Super + Shift + the key above Tab`.

Gdy otwiera się po raz pierwszy, uruchamia Twojego domyślnego agenta lub prosi Cię o wybranie jednego, jeśli jeszcze go nie wybrałeś. Gdy konsola zawiera jedno okno, opada jako panel wyśrodkowany, zamiast rozciągać się na cały ekran. Umieść na niej drugą aplikację, a wróci do pełnej szerokości, aby obie miały miejsce usiąść obok siebie.

Aby przenieść okno ze scratchpada lub konsoli, wyślij je bezpośrednio na inny obszar roboczy za pomocą czegoś takiego jak `Super + Shift + 1`.

### Trzeba się trochę przyzwyczaić!

Przyzwyczajenie się do nawigacji po pulpicie w ten sposób zajmuje trochę czasu, ale gdy już to zrobisz, trudno będzie wrócić do tradycyjnego pulpitu obsługiwanego myszą!
