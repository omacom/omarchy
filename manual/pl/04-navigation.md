# Nawigacja

Wszystko w Omarchy dzieje się z klawiatury — _WSZYSTKO!_ Gdy system uruchamia się po raz pierwszy, dosłownie nic nie zrobisz samą myszą. Możesz jednak nacisnąć `Super + Space`, aby wywołać Menu Omarchy, a stąd zrobisz już niemal wszystko.

Ale menu Omarchy przez większość czasu wcale nie ma być nawet głównym sposobem obsługi systemu. Możemy działać szybciej! Wszystkie najważniejsze aplikacje są powiązane bezpośrednio z pojedynczymi skrótami klawiszowymi. Terminal uruchomisz za pomocą `Super + Return`, a przeglądarkę za pomocą `Super + Shift + Return`. Spróbuj zrobić jedno po drugim, a zobaczysz w akcji magię kafelkowania Hyprland:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Wtedy możesz nacisnąć `Super + J`, aby ułożyć je jedno na drugim zamiast obok siebie:

 ![navigation-stacked](images/navigation-stacked.webp)

Naciśnij `Super + J` ponownie, aby wróciły do położenia obok siebie. Następnie spróbuj `Super + Shift + Arrow Right`, gdy jesteś w przeglądarce, aby zamienić okna miejscami.

Teraz spróbuj `Super + Shift + T`, aby uruchomić monitor Activity. Pojawi się jako pływające okno, z paskiem tytułu, za który możesz je przeciągać, oraz przyciskami do minimalizowania, maksymalizowania i zamykania. Każde pływające okno dostaje taki pasek, gdziekolwiek się znajduje. Możesz je ułożyć w kafelki za pomocą `Super + T` (i nacisnąć to ponownie, aby znów stało się pływające). Teraz naciśnij `Super + Shift + F`, aby otworzyć menedżer plików. Będziesz mieć zgrabny układ czterech okien:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Między oknami, które mają być aktywne, poruszasz się za pomocą `Super + Arrow`. Spowoduje to przeniesienie fokusu i przesunięcie kursora na środek nowej aplikacji. Na krawędzi ekranu przejście jest kontynuowane na monitor znajdujący się po tej stronie.

Jeśli naciśniesz `Super + Shift + 2`, przeniesiesz bieżącą aktywną aplikację na drugi obszar roboczy. `Super + Shift + 1` przenosi ją z powrotem. (A `Super + Shift + Alt + 2` przeniesie bieżącą aktywną aplikację na drugi obszar roboczy, nie przełączając się na niego).

Przy więcej niż jednym monitorze każdy monitor ma własne obszary robocze od 1 do 10. `Super + 2` przechodzi do drugiego obszaru roboczego monitora, na którym jesteś, a górny pasek każdego monitora pokazuje jego własne obszary robocze oraz ten, który aktualnie wyświetla. `Super + Tab` przechodzi cyklicznie przez obszary robocze monitora, na którym jesteś. `Super + Shift + Ctrl + Arrows` przenosi okno, w którym jesteś, na monitor w tym kierunku, na obszar roboczy, który on wyświetla, a `Super + Shift + Alt + Arrows` przenosi obszar roboczy, na którym jesteś, na monitor w tym kierunku, gdzie przyjmuje ten sam numer, jeśli jest wolny. Monitor zachowuje swoje obszary robocze, gdy go odłączysz: dołączają one do obszarów innego ekranu, ponumerowane po tych, które on już ma, i wracają pod swoje stare numery, gdy monitor powróci.

Jeśli przytrzymasz `Super` i klikniesz myszą okno, będziesz mógł zmienić jego położenie. Jeśli przytrzymasz `Super` i użyjesz prawego przycisku myszy, możesz swobodnie zmieniać rozmiar okna.

Okno zamkniesz za pomocą `Super + W` lub `Super + Q` (a wszystkie okna zamkniesz za pomocą `Ctrl + Alt + Delete`).

Możesz też przejść do pełnego ekranu za pomocą `Super + F`, a nawet tylko do pełnej szerokości (zachowując górny pasek) za pomocą `Super + Alt + F`, albo do pełnego ekranu wewnątrz okna za pomocą `Super + Ctrl + F` (dobre do YouTube!).

### Dwindle a układ scrolling

Domyślny układ Omarchy nazywa się dwindle. Utrzymuje wszystkie okna, które otworzysz na jednym obszarze roboczym, widoczne przez cały czas, nawet jeśli musi je zmniejszyć.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Możesz jednak zmienić obszar roboczy w układ scrolling, w którym okna są ustawione jedno obok drugiego, poza widoczną krawędzią ekranu. Pojedynczy obszar roboczy przełączysz w ten układ za pomocą `Super + L`.

Ponowne naciśnięcie `Super + L` zmienia obszar roboczy w pływający, w którym okna swobodnie na siebie nachodzą i sam je rozmieszczasz, a trzecie naciśnięcie przywraca układ dwindle. `Super + Alt + L` przechodzi przez nie w drugą stronę. Okno, które i tak jest pływające — takie, które wypiąłeś za pomocą `Super + T`, albo aplikacja, która zawsze otwiera się jako pływająca — pozostaje pływające, gdy obszar roboczy wraca do kafelkowania. Górny pasek oznacza obszar roboczy, na którym jesteś, jego układem: kwadrat dla dwindle, koło dla scrolling i trójkąt dla układu pływającego. Kliknięcie tego oznaczenia również przechodzi cyklicznie między układami, tak samo jak klawisz wyświetlania na laptopach, które taki mają.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Wybór dotyczy każdego obszaru roboczego z osobna i zostaje zapamiętany. Możesz więc zachować obszar roboczy 1 w układzie dwindle do przeglądania, a obszar roboczy 2 w układzie scrolling do kodu, i wrócą w takim stanie po ponownym uruchomieniu.

Jeśli chcesz używać układu scrolling jako domyślnego, możesz ustawić to w `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Pływające obszary robocze

Pływający obszar roboczy działa jak tradycyjny pulpit: okna nachodzą na siebie, a Ty sam je przesuwasz i zmieniasz ich rozmiar. Każde okno dostaje pasek tytułu w kolorach Twojego motywu, z przyciskami do minimalizowania, maksymalizowania i zamykania. `Super + M` również minimalizuje aktywne okno. Zminimalizowane okno czeka w docku; kliknij jego aplikację, aby je przywrócić. Kliknij okno, aby wysunąć je na pierwszy plan. Zmieniaj jego rozmiar od dowolnej krawędzi lub rogu. Kliknij dwukrotnie pasek tytułu, aby zmaksymalizować okno, zachowując górny pasek w widoku, i ponownie, aby przywrócić jego dawny rozmiar. Chrome i inne przeglądarki oparte na Chromium, Disks oraz Document Viewer pomijają pasek tytułu i zamiast niego używają własnego nagłówka; `Super + Alt + F` je maksymalizuje, a `Super + M` je minimalizuje.

Każdy obszar roboczy ma dock, z Twoimi przypiętymi aplikacjami, wszystkim, co jest uruchomione, oraz siatką wszystkich aplikacji ukrytą za przyciskiem aplikacji, którą otwierają również `Super + Alt + Space` oraz _Apps_ w menu Omarchy. Kliknij aplikację prawym przyciskiem myszy na siatce lub naciśnij `Delete`, aby ją odinstalować. Kliknij aplikację, aby ją otworzyć albo wysunąć jej okno na pierwszy plan; kliknij ponownie, aby przechodzić cyklicznie przez jej okna. Files przywraca tylko okno z obszaru roboczego, na którym jesteś, a w przeciwnym razie otwiera nowe, a Terminal i Agent zawsze uruchamiają kolejne, choć zminimalizowane okno najpierw wraca. Kliknięcie środkowym przyciskiem myszy otwiera nowe okno. Przeciągnij ikonę wzdłuż docka, aby ją przesunąć; przeciągnięcie uruchomionej aplikacji pomiędzy pozostałe zachowuje ją tam. Kliknij prawym przyciskiem myszy, aby zachować aplikację w docku, usunąć ją stamtąd lub ją zamknąć. Dock pozostaje widoczny, gdy obszar roboczy jest pusty, a gdy obszar roboczy ma okno, ukrywa się, dopóki wskaźnik nie dotrze do jego krawędzi. Okno pełnoekranowe ukrywa go całkowicie. Przeciągnij przycisk aplikacji w stronę innej krawędzi ekranu, aby przenieść tam dock. Kliknij go prawym przyciskiem myszy, aby uzyskać _Position_, czyli wybrać krawędź, oraz _Layout_, czyli ustawić domyślny układ w taki sam sposób, jak robi to _Appearance > Workspace Layout_. Położenie znajduje się również w _Appearance > Dock > Dock Position_, a `omarchy dock position left` ustawia je z terminala. Aplikacje, które trzymasz w docku, są wyblakłe, gdy nie są uruchomione. Aby ograniczyć dock do pływających obszarów roboczych, użyj _Appearance > Dock > Dock Only on Floating_ lub `omarchy dock tiling off`.

Nowe obszary robocze oraz wszystkie, którym nie nadałeś własnego układu za pomocą `Super + L`, używają domyślnego układu. Zmiana domyślnego układu resetuje do niego każdy obszar roboczy bez okien, natomiast obszar z oknami zachowuje układ, który ma. Okno zminimalizowane do docka nadal liczy się jako okno na obszarze roboczym, który opuściło. Wybierz go w _Appearance > Workspace Layout_: Tiling, Scrolling lub Floating. `omarchy hyprland workspace layout default scrolling` ustawia go z terminala.

### Grupowanie okien

Okna można grupować za pomocą `Super + G`. Gdy już jesteś w grupie, każde okno, które uruchomisz, gdy jest ona aktywna, będzie należeć do grupy. Pomiędzy tymi zgrupowanymi oknami możesz poruszać się za pomocą `Super + Ctrl + Arrow Left/Right` lub `Super + Alt + 1/2/3/4`, aby przejść bezpośrednio do zgrupowanych okien w kolejności.

Okno możesz przenieść poza grupę za pomocą `Super + Alt + G` lub rozmontować całą grupę, naciskając ponownie `Super + G`. Na koniec możesz przenieść okna spoza grupy do niej za pomocą `Super + Alt + Arrows`.

### Wypinanie okien

Okno możesz wypiąć z jego przydziału do obszaru roboczego za pomocą `Super + O`. Spowoduje to przypięcie go jako pływającego okna, które podąża za Tobą na każdy obszar roboczy, na który przejdziesz. Świetne dla odtwarzaczy wideo i tym podobnych.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Obszar roboczy scratchpad

Istnieje specjalny, pełnowymiarowy obszar roboczy scratchpad, który nakłada się na obszar roboczy, na którym aktualnie jesteś. Dostęp do tego, co się na nim znajduje, uzyskujesz za pomocą `Super + S`, a okna umieszczasz tam za pomocą `Super + Alt + S`.

Dobrze sprawdza się do elementów sterujących lub terminala, z którym chcesz szybko wejść w interakcję, nie opuszczając bieżącego obszaru roboczego.

### Konsola Quake

Na koniec istnieje konsola Quake o połowie wysokości, która opuszcza się nad obszarem roboczym, na którym aktualnie jesteś. Przełączysz ją za pomocą `Super + the key above Tab` (grave w układach US), a okno umieścisz tam za pomocą `Super + Shift + the key above Tab`.

Gdy otworzy się po raz pierwszy, uruchamia Twojego domyślnego agenta lub prosi o wybranie jednego, jeśli jeszcze żadnego nie wybrałeś. Gdy konsola zawiera jedno okno, opuszcza się jako wyśrodkowany panel, a nie rozciąga na cały ekran. Umieść w niej drugą aplikację, a wróci do pełnej szerokości, aby obie miały miejsce obok siebie.

Aby przenieść okno ze scratchpada lub konsoli, wyślij je bezpośrednio na inny obszar roboczy, na przykład za pomocą `Super + Shift + 1`.

### Trzeba się przyzwyczaić!

Trochę potrwa, zanim przyzwyczaisz się do poruszania się po pulpicie w ten sposób, ale gdy już to zrobisz, trudno będzie Ci wrócić do tradycyjnego pulpitu obsługiwanego myszą!
