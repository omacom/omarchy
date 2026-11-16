# Nawigacja

Wszystko w Omarchy odbywa się za pomocą klawiatury — _WSZYSTKO!_ Po pierwszym uruchomieniu systemu dosłownie nic nie zrobisz samą myszą. Ale możesz nacisnąć `Super + Space`, aby wyświetlić Menu Omarchy, a stąd zrobisz niemal wszystko.

Ale menu Omarchy przez większość czasu nie ma być nawet głównym sposobem obsługi systemu. Możemy działać szybciej niż tak! Wszystkie najważniejsze aplikacje są przypisane bezpośrednio do osobnych skrótów klawiszowych. Terminal uruchomisz za pomocą `Super + Return`, a przeglądarkę za pomocą `Super + Shift + Return`. Spróbuj zrobić jedno po drugim, a zobaczysz w akcji magię kafelkowania Hyprland:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Następnie możesz nacisnąć `Super + J`, aby ułożyć je jedno na drugim zamiast obok siebie:

 ![navigation-stacked](images/navigation-stacked.webp)

Naciśnij `Super + J` ponownie, aby wrócić do ich położenia obok siebie. Następnie, będąc w przeglądarce, spróbuj `Super + Shift + Arrow Right`, aby zamienić okna miejscami.

Teraz spróbuj `Super + Shift + T`, aby uruchomić monitor Activity. Pojawi się on jako pływające okno. Możesz go ułożyć w kafelki za pomocą `Super + T` (i nacisnąć to ponownie, aby znów było pływające). Teraz naciśnij `Super + Shift + F`, aby otworzyć menedżer plików. Będziesz mieć zgrabny układ czterech okien:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Pomiędzy oknami, które chcesz aktywować, poruszasz się za pomocą `Super + Arrow`. To przełączy fokus i przeniesie kursor na środek nowej aplikacji. Na krawędzi ekranu przejdzie dalej, na monitor po tej stronie.

Jeśli naciśniesz `Super + Shift + 2`, przeniesiesz bieżącą aktywną aplikację na drugi obszar roboczy. `Super + Shift + 1` przeniesie ją z powrotem. (A `Super + Shift + Alt + 2` przeniesie bieżącą aktywną aplikację na drugi obszar roboczy bez przełączania się na niego).

Przy więcej niż jednym monitorze każdy monitor ma własne obszary robocze od 1 do 10. `Super + 2` przechodzi do drugiego obszaru roboczego monitora, na którym jesteś, a górny pasek każdego monitora pokazuje jego własne obszary robocze oraz ten, który jest na nim wyświetlany. `Super + Tab` przełącza cyklicznie obszary robocze na monitorze, na którym jesteś. `Super + Shift + Ctrl + Arrows` przenosi okno, w którym jesteś, na monitor w tym kierunku, na obszar roboczy, który on pokazuje, a `Super + Shift + Alt + Arrows` przenosi obszar roboczy, na którym jesteś, na monitor w tym kierunku, gdzie przyjmuje ten sam numer, jeśli jest wolny. Monitor zachowuje swoje obszary robocze po odłączeniu: dołączają one do obszarów innego ekranu, ponumerowane po tych, które on już ma, i wracają pod swoje stare numery, gdy monitor powróci.

Jeśli przytrzymasz `Super` i klikniesz myszą okno, będziesz mógł zmienić miejsce, w którym się znajduje. Jeśli przytrzymasz `Super` i użyjesz prawego przycisku myszy, możesz dowolnie zmieniać rozmiar okna.

Okno zamkniesz za pomocą `Super + W` lub `Super + Q` (a wszystkie okna zamkniesz za pomocą `Ctrl + Alt + Delete`).

Możesz też przejść na pełny ekran za pomocą `Super + F`, a nawet tylko na pełną szerokość (z zachowaniem górnego paska) za pomocą `Super + Alt + F` lub na pełny ekran wewnątrz okna za pomocą `Super + Ctrl + F` (świetne na YouTube!).

### Dwindle a układ scrolling

Domyślny układ Omarchy nazywa się dwindle. Utrzymuje on wszystkie okna otwarte na jednym obszarze roboczym zawsze widoczne, nawet jeśli musi je zmniejszyć.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Ale możesz też zamienić obszar roboczy w układ scrolling, w którym okna są ustawione jedno obok drugiego, poza widoczną krawędzią ekranu. Pojedynczy obszar roboczy przełączysz na ten układ za pomocą `Super + L`.

Ponowne naciśnięcie `Super + L` zamienia obszar roboczy w pływający, w którym okna swobodnie na siebie nachodzą, a ty ustawiasz je samodzielnie, a trzecie naciśnięcie przywraca dwindle. `Super + Alt + L` przechodzi przez nie w drugą stronę. Okno, które i tak jest pływające — takie, które wysunąłeś za pomocą `Super + T`, albo aplikacja, która zawsze otwiera się jako pływająca — pozostaje pływające, gdy obszar roboczy wraca do kafelkowania. Górny pasek oznacza obszar roboczy, na którym jesteś, jego układem: kwadrat dla dwindle, koło dla scrolling i trójkąt dla pływającego. Kliknięcie tego oznaczenia także przełącza układ cyklicznie.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Wybór dotyczy każdego obszaru roboczego osobno i zostaje zachowany. Możesz więc trzymać obszar roboczy 1 na dwindle do przeglądania, a obszar roboczy 2 na scrolling do kodu, i wrócą w takim stanie po ponownym uruchomieniu.

Jeśli chcesz używać układu scrolling jako domyślnego, możesz ustawić to w `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Pływające obszary robocze

Pływający obszar roboczy działa jak tradycyjny pulpit: okna nachodzą na siebie, a ty samodzielnie je przesuwasz i zmieniasz ich rozmiar. Każde okno otrzymuje pasek tytułu w kolorach twojego motywu, z przyciskami do minimalizowania, maksymalizowania i zamykania. `Super + M` również minimalizuje aktywne okno. Zminimalizowane okno czeka w docku; kliknij jego aplikację, aby je przywrócić. Kliknij okno, aby wysunąć je na wierzch. Zmieniaj jego rozmiar od dowolnej krawędzi lub rogu. Kliknij dwukrotnie pasek tytułu, aby zmaksymalizować okno przy zachowaniu widocznego górnego paska, i ponownie, aby przywrócić jego poprzedni rozmiar. Chrome i inne przeglądarki oparte na Chromium, Disks oraz Document Viewer pomijają pasek tytułu i używają zamiast tego własnego nagłówka; `Super + Alt + F` je maksymalizuje, a `Super + M` je minimalizuje.

Pływający obszar roboczy pokazuje też dock z twoimi przypiętymi aplikacjami, wszystkim, co jest uruchomione, oraz siatką wszystkich aplikacji za przyciskiem aplikacji, którą otwierają też `Super + Alt + Space` i _Aplikacje_ w menu Omarchy. Kliknij aplikację na siatce prawym przyciskiem myszy lub naciśnij `Delete`, aby ją odinstalować. Kliknij aplikację, aby ją otworzyć albo wysunąć jej okno na wierzch; kliknij ponownie, aby przechodzić cyklicznie między jej oknami. Files przywraca tylko okno z obszaru roboczego, na którym jesteś, a w przeciwnym razie otwiera nowe, a Terminal i Agent zawsze uruchamiają kolejne, choć zminimalizowane okno wraca najpierw. Kliknięcie środkowym przyciskiem myszy otwiera nowe okno. Przeciągnij ikonę wzdłuż docka, aby ją przenieść; przeciągnięcie uruchomionej aplikacji pomiędzy pozostałe zostawia ją tam. Kliknij prawym przyciskiem myszy, aby zachować aplikację w docku, usunąć ją stamtąd lub ją zamknąć. Dock ustępuje miejsca oknu pełnoekranowemu. Kliknij przycisk aplikacji prawym przyciskiem myszy, aby przenieść dock na inną krawędź albo sprawić, by ukrywał się, dopóki wskaźnik nie dotrze do jego krawędzi. Pozycja znajduje się też w _Wygląd > Dock > Pozycja docka_, a `omarchy dock position left` i `omarchy dock autohide on` ustawiają obie te rzeczy z terminala. Aplikacje, które trzymasz w docku, są przygaszone, gdy nie są uruchomione.

Nowe obszary robocze oraz wszystkie, którym nie nadałeś własnego układu za pomocą `Super + L`, używają układu domyślnego. Zmiana układu domyślnego resetuje do niego każdy obszar roboczy bez okien, natomiast obszar z oknami zachowuje układ, który ma. Okno zminimalizowane do docka nadal liczy się jako okno na obszarze roboczym, który opuściło. Wybierzesz go w _Wygląd > Układ obszaru roboczego_: Kafelkowy, Przewijany lub Pływający. `omarchy-hyprland-workspace-layout-default scrolling` ustawia go z terminala.

### Grupowanie okien

Okna można grupować za pomocą `Super + G`. Gdy jesteś w grupie, każde okno uruchomione w czasie, gdy jest ona aktywna, będzie należeć do grupy. Pomiędzy tymi zgrupowanymi oknami możesz poruszać się za pomocą `Super + Ctrl + Arrow Left/Right` lub `Super + Alt + 1/2/3/4`, aby przechodzić bezpośrednio do zgrupowanych okien w kolejności.

Możesz przenieść okno poza grupę za pomocą `Super + Alt + G` albo rozłożyć całą grupę, naciskając ponownie `Super + G`. Na koniec możesz przenosić okna spoza grupy do niej za pomocą `Super + Alt + Arrows`.

### Wypinanie okien

Możesz wypiąć okno z przypisania do obszaru roboczego za pomocą `Super + O`. To przypnie je jako pływające okno, które podąża za tobą na każdy obszar roboczy, na który przejdziesz. Świetne dla odtwarzaczy wideo i tym podobnych.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Obszar roboczy scratchpad

Istnieje specjalny, pełnowymiarowy obszar roboczy scratchpad, który nakłada się na obszar roboczy, na którym obecnie jesteś. Dostęp do tego, co się na nim znajduje, uzyskasz za pomocą `Super + S`, a okna umieścisz tam za pomocą `Super + Alt + S`.

Dobrze sprawdza się dla elementów sterujących lub terminala, z których chcesz szybko skorzystać bez opuszczania bieżącego obszaru roboczego.

### Konsola Quake

Na koniec jest konsola Quake o połowie wysokości, która wysuwa się w dół nad obszar roboczy, na którym obecnie jesteś. Przełączysz ją za pomocą `Super + Grave`, a okno umieścisz tam za pomocą `Super + Shift + Grave`.

Otwiera się z twoim domyślnym agentem gotowym do pracy. Gdy konsola zawiera jedno okno, wysuwa się jako wyśrodkowany panel, zamiast rozciągać się przez cały ekran. Umieść na niej drugą aplikację, a wróci do pełnej szerokości, aby obie miały miejsce obok siebie.

Aby przenieść okno ze scratchpada lub z konsoli, wyślij je bezpośrednio na inny obszar roboczy, na przykład za pomocą `Super + Shift + 1`.

### Trzeba się do tego przyzwyczaić!

Przyzwyczajenie się do takiej nawigacji po pulpicie zajmuje trochę czasu, ale gdy już się przyzwyczaisz, trudno będzie wrócić do tradycyjnego pulpitu obsługiwanego myszą!
