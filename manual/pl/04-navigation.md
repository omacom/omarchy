# Nawigacja

Wszystko w Omarchy dzieje się za pomocą klawiatury — _WSZYSTKO!_ Gdy system uruchamia się po raz pierwszy, samą myszą dosłownie nic nie zrobisz. Ale możesz nacisnąć `Super + Space`, aby wyświetlić Menu Omarchy, a stąd możesz zrobić niemal wszystko.

Ale Menu Omarchy przez większość czasu wcale nie ma być głównym sposobem obsługi systemu. Możemy być od tego szybsi! Wszystkie najważniejsze aplikacje są przypisane bezpośrednio do poszczególnych skrótów klawiszowych. Terminal uruchamiasz za pomocą `Super + Return`, a przeglądarkę za pomocą `Super + Shift + Return`. Spróbuj zrobić jedno po drugim, a zobaczysz magię układania kafelkowego Hyprland w akcji:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Następnie możesz nacisnąć `Super + J`, aby ułożyć je jedno na drugim zamiast obok siebie:

 ![navigation-stacked](images/navigation-stacked.webp)

Naciśnij ponownie `Super + J`, aby przywrócić je do pozycji obok siebie. Następnie spróbuj nacisnąć `Super + Shift + Arrow Right`, gdy jesteś w przeglądarce, aby zamienić okna miejscami.

Teraz spróbuj `Super + Shift + T`, aby uruchomić monitor Activity. Pojawi się on jako pływające okno. Możesz umieścić go w układzie kafelkowym za pomocą `Super + T` (i nacisnąć to ponownie, aby znów był pływający). Teraz naciśnij `Super + Shift + F`, aby otworzyć menedżer plików. Będziesz mieć zgrabny układ czterech okien:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Między oknami, które mają być aktywne, poruszasz się za pomocą `Super + Arrow`. Spowoduje to przełączenie fokusu i przeniesienie kursora na środek nowej aplikacji. Przy krawędzi ekranu przechodzi dalej do monitora po tej stronie.

Jeśli naciśniesz `Super + Shift + 2`, przeniesiesz bieżącą aktywną aplikację na drugą przestrzeń roboczą. `Super + Shift + 1` przeniesie ją z powrotem. (A `Super + Shift + Alt + 2` przeniesie bieżącą aktywną aplikację na drugą przestrzeń roboczą bez przełączania się na nią).

Przy więcej niż jednym monitorze każdy monitor ma własne przestrzenie robocze od 1 do 10. `Super + 2` przechodzi do drugiej przestrzeni roboczej monitora, na którym jesteś, a górny pasek każdego monitora pokazuje jego własne przestrzenie robocze oraz tę, którą wyświetla. `Super + Tab` przełącza cyklicznie między przestrzeniami roboczymi monitora, na którym jesteś. `Super + Shift + Ctrl + Arrows` przenosi okno, na którym jesteś, na monitor w tym kierunku, na przestrzeń roboczą, którą on wyświetla, a `Super + Shift + Alt + Arrows` przenosi przestrzeń roboczą, na której jesteś, na monitor w tym kierunku, gdzie przejmuje ona ten sam numer, jeśli jest wolny. Monitor zachowuje swoje przestrzenie robocze po odłączeniu: dołączają one do innego ekranu, ponumerowane po tych, które już ma, i wracają pod swoje stare numery, gdy monitor powróci.

Jeśli przytrzymasz `Super` i użyjesz myszy, aby kliknąć okno, będziesz mógł zmienić jego położenie. Jeśli przytrzymasz `Super` i użyjesz prawego przycisku myszy, możesz swobodnie zmieniać rozmiar okna.

Okno zamykasz za pomocą `Super + W` lub `Super + Q` (a wszystkie okna zamykasz za pomocą `Ctrl + Alt + Delete`).

Możesz też przejść do trybu pełnoekranowego za pomocą `Super + F`, a nawet tylko na pełną szerokość (zachowując górny pasek) za pomocą `Super + Alt + F` lub do trybu pełnoekranowego wewnątrz okna za pomocą `Super + Ctrl + F` (idealne dla YouTube!).

### Układ dwindle a układ scrolling

Domyślny układ Omarchy nazywa się dwindle. Utrzymuje on wszystkie okna otwarte w jednej przestrzeni roboczej widoczne przez cały czas, nawet jeśli musi je w tym celu zmniejszyć.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Ale możesz też zdecydować się na przekształcenie przestrzeni roboczej w układ scrolling, w którym okna są ustawione obok siebie, poza widoczną krawędzią ekranu. Pojedynczą przestrzeń roboczą przekształcasz w ten układ za pomocą `Super + L`.

Ponowne naciśnięcie `Super + L` przekształca przestrzeń roboczą w pływającą, w której okna swobodnie się nakładają, a ty ustawiasz je samodzielnie, a trzecie naciśnięcie przywraca ją do dwindle. `Super + Alt + L` przechodzi przez nie w drugą stronę. Okno, które i tak pływa — takie, które wysunąłeś za pomocą `Super + T`, lub aplikacja, która zawsze otwiera się jako pływająca — pozostaje pływające, gdy przestrzeń robocza wraca do układania kafelkowego. Górny pasek oznacza przestrzeń roboczą, na której jesteś, jej układem: kwadrat dla dwindle, koło dla scrolling i trójkąt dla pływającej. Kliknięcie tego oznaczenia również przełącza cyklicznie układ.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Wybór dotyczy każdej przestrzeni roboczej z osobna i zostaje zachowany. Możesz więc trzymać przestrzeń roboczą 1 w dwindle do przeglądania, a przestrzeń roboczą 2 w scrolling do kodu, a po ponownym uruchomieniu wrócą w takim stanie.

Jeśli chcesz używać układu scrolling jako domyślnego, możesz ustawić to w `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Pływające przestrzenie robocze

Pływająca przestrzeń robocza działa jak tradycyjny pulpit: okna nakładają się na siebie, a ty sam je przesuwasz i zmieniasz ich rozmiar. Każde okno otrzymuje pasek tytułu w kolorach twojego motywu, z przyciskami do minimalizacji, maksymalizacji i zamykania. `Super + M` również minimalizuje aktywne okno. Zminimalizowane okno czeka w docku; kliknij jego aplikację, aby je przywrócić. Kliknij okno, aby wysunąć je na pierwszy plan. Zmieniaj jego rozmiar z dowolnej krawędzi lub rogu. Kliknij dwukrotnie pasek tytułu, aby zmaksymalizować okno, zachowując górny pasek w polu widzenia, i ponownie, aby przywrócić jego dawny rozmiar.

Pływająca przestrzeń robocza pokazuje też dock, z przypiętymi aplikacjami, wszystkim, co jest uruchomione, oraz siatką wszystkich aplikacji za przyciskiem aplikacji, który otwierają też `Super + Alt + Space` oraz _Aplikacje_ w Menu Omarchy. Kliknij aplikację na siatce prawym przyciskiem myszy lub naciśnij `Delete`, aby ją odinstalować. Kliknij aplikację, aby ją otworzyć lub wysunąć jej okno na pierwszy plan; kliknij ponownie, aby przełączać cyklicznie między jej oknami. Kliknięcie środkowym przyciskiem myszy otwiera nowe okno. Przeciągnij ikonę wzdłuż docka, aby ją przesunąć; przeciągnięcie uruchomionej aplikacji pomiędzy pozostałe pozostawia ją tam. Kliknij prawym przyciskiem myszy, aby zachować aplikację w docku, usunąć ją z niego lub ją zamknąć. Dock ustępuje miejsca oknu pełnoekranowemu. Kliknij przycisk aplikacji prawym przyciskiem myszy, aby przenieść dock na inną krawędź lub sprawić, by ukrywał się, dopóki wskaźnik nie dotrze do jego krawędzi. Pozycja znajduje się też w _Wygląd > Dock > Pozycja docka_, a `omarchy dock position left` oraz `omarchy dock autohide on` ustawiają obie opcje z terminala. Aplikacje, które trzymasz w docku, są przygaszone, gdy nie są uruchomione.

Nowe przestrzenie robocze oraz każda, której nie nadałeś własnego układu za pomocą `Super + L`, używają układu domyślnego. Zmiana układu domyślnego resetuje do niego każdą przestrzeń roboczą bez okien, natomiast przestrzeń z oknami zachowuje układ, który ma. Okno zminimalizowane do docka nadal liczy się jako okno w przestrzeni roboczej, którą opuściło. Wybierz go w _Wygląd > Układ przestrzeni roboczej_: Kafelkowy, Scrolling lub Pływający. `omarchy-hyprland-workspace-layout-default scrolling` ustawia go z terminala.

### Grupowanie okien

Okna można grupować za pomocą `Super + G`. Gdy jesteś w grupie, każde okno uruchomione, gdy jest ona aktywna, będzie należeć do grupy. Między zgrupowanymi oknami możesz przechodzić za pomocą `Super + Ctrl + Arrow Left/Right` lub `Super + Alt + 1/2/3/4`, aby przejść bezpośrednio do zgrupowanego okna w kolejności.

Możesz przenieść okno poza grupę za pomocą `Super + Alt + G` lub rozmontować całą grupę, naciskając ponownie `Super + G`. Wreszcie możesz przenosić okna spoza grupy do niej za pomocą `Super + Alt + Arrows`.

### Wypinanie okien

Możesz wypiąć okno z przydziału do przestrzeni roboczej za pomocą `Super + O`. Przypnie je to jako pływające okno, które podąża za tobą na każdą przestrzeń roboczą, na którą przejdziesz. Idealne dla odtwarzaczy wideo i podobnych rzeczy.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Przestrzeń robocza scratchpad

Istnieje specjalna, pełnowymiarowa przestrzeń robocza scratchpad, która nakłada się na dowolną przestrzeń roboczą, na której aktualnie jesteś. Dostęp do tego, co się na niej znajduje, uzyskujesz za pomocą `Super + S`, a okna umieszczasz tam za pomocą `Super + Alt + S`.

Sprawdza się dobrze dla elementów sterujących lub terminala, z którym chcesz szybko wejść w interakcję, nie opuszczając bieżącej przestrzeni roboczej.

### Konsola Quake

Wreszcie jest konsola Quake o połowie wysokości, która wysuwa się w dół na dowolną przestrzeń roboczą, na której aktualnie jesteś. Przełączasz ją za pomocą `Super + Grave`, a okno umieszczasz tam za pomocą `Super + Shift + Grave`.

Otwiera się z twoim domyślnym agentem gotowym do pracy. Gdy konsola zawiera jedno okno, wysuwa się w dół jako wyśrodkowany panel, zamiast rozciągać się na cały ekran. Umieść na niej drugą aplikację, a wróci do pełnej szerokości, aby obie miały miejsce, by znajdować się obok siebie.

Aby przenieść okno poza scratchpad lub konsolę, wyślij je bezpośrednio do innej przestrzeni roboczej za pomocą czegoś w rodzaju `Super + Shift + 1`.

### Trzeba się do tego przyzwyczaić!

Przyzwyczajenie się do takiego poruszania się po pulpicie zajmuje trochę czasu, ale gdy już to zrobisz, trudno będzie wrócić do tradycyjnego pulpitu obsługiwanego myszą!
