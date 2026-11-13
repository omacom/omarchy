# Nawigacja

Wszystko w Omarchy dzieje się za pomocą klawiatury — _WSZYSTKO!_ Gdy system uruchamia się po raz pierwszy, samą myszą dosłownie nic nie zdziałasz. Możesz jednak nacisnąć `Super + Space`, aby otworzyć Menu Omarchy, a stamtąd zrobisz już niemal wszystko.

Ale Menu Omarchy przez większość czasu wcale nie ma być głównym sposobem obsługi systemu. Da się szybciej! Wszystkie najważniejsze aplikacje są przypisane bezpośrednio do osobnych skrótów klawiszowych. Terminal uruchomisz za pomocą `Super + Return`, a przeglądarkę za pomocą `Super + Shift + Return`. Spróbuj zrobić jedno po drugim, a zobaczysz w akcji magię kafelkowania Hyprland:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Możesz potem nacisnąć `Super + J`, aby ułożyć je jedno na drugim zamiast obok siebie:

 ![navigation-stacked](images/navigation-stacked.webp)

Naciśnij `Super + J` ponownie, aby wróciły do położenia obok siebie. Potem, będąc w przeglądarce, spróbuj `Super + Shift + Arrow Right`, aby zamienić okna miejscami.

Teraz spróbuj `Super + Shift + T`, aby uruchomić monitor Activity. Pojawi się jako okno pływające. Możesz je ułożyć w kafelki za pomocą `Super + T` (i nacisnąć to ponownie, aby znów było pływające). Teraz naciśnij `Super + Shift + F`, aby otworzyć menedżer plików. Będziesz mieć zgrabny układ czterech okien:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Między oknami, które chcesz aktywować, poruszasz się za pomocą `Super + Arrow`. Przełączy to fokus i przeniesie kursor na środek nowej aplikacji. Na krawędzi ekranu przejdzie dalej, na monitor po tej stronie.

Jeśli naciśniesz `Super + Shift + 2`, przeniesiesz aktualnie aktywną aplikację na drugi obszar roboczy. `Super + Shift + 1` przenosi ją z powrotem. (A `Super + Shift + Alt + 2` przeniesie aktualnie aktywną aplikację na drugi obszar roboczy bez przełączania się na niego).

Przy więcej niż jednym monitorze każdy monitor ma własne obszary robocze od 1 do 10. `Super + 2` przechodzi do drugiego obszaru roboczego monitora, na którym jesteś, a górny pasek każdego monitora pokazuje jego własne obszary robocze i ten, który aktualnie wyświetla. `Super + Tab` przełącza kolejno obszary robocze na monitorze, na którym jesteś. `Super + Shift + Ctrl + Arrows` przenosi okno, na którym jesteś, na monitor w tym kierunku, na obszar roboczy, który on wyświetla, a `Super + Shift + Alt + Arrows` przenosi obszar roboczy, na którym jesteś, na monitor w tym kierunku, gdzie przyjmuje ten sam numer, jeśli jest wolny. Monitor zachowuje swoje obszary robocze po odłączeniu: dołączają one do obszarów innego ekranu, ponumerowane po tych, które on już ma, i wracają pod swoje stare numery, gdy monitor powróci.

Jeśli przytrzymasz `Super` i klikniesz myszą okno, będziesz mógł zmienić jego położenie. Jeśli przytrzymasz `Super` i użyjesz prawego przycisku myszy, możesz swobodnie zmieniać rozmiar okna.

Okno zamkniesz za pomocą `Super + W` lub `Super + Q` (a wszystkie okna za pomocą `Ctrl + Alt + Delete`).

Możesz też przejść na pełny ekran za pomocą `Super + F`, albo tylko na pełną szerokość (zachowując górny pasek) za pomocą `Super + Alt + F`, albo na pełny ekran w obrębie okna za pomocą `Super + Ctrl + F` (świetne do YouTube!).

### Układ dwindle a układ scrolling

Domyślny układ Omarchy nazywa się dwindle. Utrzymuje wszystkie okna otwarte na jednym obszarze roboczym zawsze widoczne, nawet jeśli musi je w tym celu pomniejszyć.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Możesz jednak także zmienić obszar roboczy w układ scrolling, w którym okna są ustawione obok siebie, poza widoczną krawędzią ekranu. Pojedynczy obszar roboczy przełączysz na ten układ za pomocą `Super + L`.

Ponowne naciśnięcie `Super + L` przełącza obszar roboczy na floating, w którym okna swobodnie na siebie nachodzą, a Ty sam je rozmieszczasz, a trzecie naciśnięcie przywraca dwindle. `Super + Alt + L` przechodzi przez nie w drugą stronę. Okno, które i tak jest pływające — takie, które wyciągnąłeś za pomocą `Super + T`, albo aplikacja, która zawsze otwiera się jako pływająca — pozostaje pływające, gdy obszar roboczy wraca do kafelkowania. Górny pasek oznacza obszar roboczy, na którym jesteś, jego układem: kwadrat dla dwindle, koło dla scrolling i trójkąt dla floating. Kliknięcie tego znaku także przełącza układ kolejno.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Wybór dotyczy każdego obszaru roboczego osobno i zostaje zapamiętany. Możesz więc trzymać obszar roboczy 1 na dwindle do przeglądania, a obszar roboczy 2 na scrolling do kodu, i wrócą w tej postaci po ponownym uruchomieniu.

Jeśli chcesz używać układu scrolling jako domyślnego, możesz ustawić to w `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Pływające obszary robocze

Pływający obszar roboczy działa jak tradycyjny pulpit: okna nachodzą na siebie, a Ty sam je przesuwasz i zmieniasz ich rozmiar. Każde okno dostaje pasek tytułowy w kolorach Twojego motywu, z przyciskami do minimalizowania, maksymalizowania i zamykania. `Super + M` także minimalizuje aktywne okno. Zminimalizowane okno czeka w docku; kliknij jego aplikację, aby je przywrócić. Kliknij okno, aby wysunąć je na przód. Zmieniaj jego rozmiar od dowolnej krawędzi lub rogu. Kliknij dwukrotnie pasek tytułowy, aby zmaksymalizować okno przy zachowaniu widocznego górnego paska, i ponownie, aby odzyskać jego stary rozmiar. Chrome i inne przeglądarki oparte na Chromium, Disks i Document Viewer pomijają pasek tytułowy i zamiast tego używają własnego nagłówka; `Super + Alt + F` je maksymalizuje, a `Super + M` je minimalizuje.

Pływający obszar roboczy pokazuje także dock, z Twoimi przypiętymi aplikacjami, wszystkim, co jest uruchomione, oraz siatką wszystkich aplikacji za przyciskiem aplikacji, którą otwierają także `Super + Alt + Space` oraz _Apps_ w menu Omarchy. Kliknij aplikację na siatce prawym przyciskiem myszy albo naciśnij `Delete`, aby ją odinstalować. Kliknij aplikację, aby ją otworzyć albo wysunąć jej okno na przód; kliknij ponownie, aby przechodzić kolejno przez jej okna. Kliknięcie środkowym przyciskiem otwiera nowe okno. Przeciągnij ikonę wzdłuż docka, aby ją przenieść; przeciągnięcie uruchomionej aplikacji pomiędzy pozostałe zostawi ją tam. Kliknij prawym przyciskiem myszy, aby zostawić aplikację w docku, usunąć ją stamtąd albo ją zakończyć. Dock usuwa się z drogi oknu pełnoekranowemu. Kliknij przycisk aplikacji prawym przyciskiem myszy, aby przenieść dock na inną krawędź albo ustawić jego ukrywanie, dopóki wskaźnik nie dotrze do jego krawędzi. Położenie znajduje się także w _Appearance > Dock > Dock Position_, a `omarchy dock position left` i `omarchy dock autohide on` ustawiają jedno i drugie z terminala. Aplikacje, które trzymasz w docku, są wyblakłe, gdy nie są uruchomione.

Nowe obszary robocze oraz te, którym nie nadałeś własnego układu za pomocą `Super + L`, używają układu domyślnego. Zmiana układu domyślnego ustawia na niego każdy obszar roboczy bez okien, natomiast ten z oknami zachowuje układ, który ma. Okno zminimalizowane do docka nadal liczy się jako okno na obszarze roboczym, który opuściło. Wybierzesz go w _Appearance > Workspace Layout_: Tiling, Scrolling lub Floating. `omarchy-hyprland-workspace-layout-default scrolling` ustawia go z terminala.

### Grupowanie okien

Okna można grupować za pomocą `Super + G`. Gdy jesteś w grupie, każde okno uruchomione, gdy jest ona aktywna, będzie należeć do tej grupy. Między tymi zgrupowanymi oknami możesz poruszać się za pomocą `Super + Ctrl + Arrow Left/Right` lub `Super + Alt + 1/2/3/4`, aby przechodzić bezpośrednio do zgrupowanych okien po kolei.

Okno możesz przenieść poza grupę za pomocą `Super + Alt + G` albo rozłożyć całą grupę, naciskając ponownie `Super + G`. Wreszcie możesz przenosić do niej okna spoza grupy za pomocą `Super + Alt + Arrows`.

### Wyciąganie okien

Okno możesz wyciągnąć z przypisania do obszaru roboczego za pomocą `Super + O`. Przypnie je to jako okno pływające, które podąża za Tobą na każdy obszar roboczy, na który przejdziesz. Świetne do odtwarzaczy wideo i tym podobnych.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Obszar roboczy scratchpad

Istnieje specjalny, pełnowymiarowy obszar roboczy scratchpad, który nakłada się na obszar roboczy, na którym aktualnie jesteś. Dostęp do tego, co się na nim znajduje, uzyskasz za pomocą `Super + S`, a okna umieszczasz tam za pomocą `Super + Alt + S`.

Dobrze sprawdza się do elementów sterujących albo terminala, z którym chcesz szybko wejść w interakcję bez opuszczania bieżącego obszaru roboczego.

### Konsola Quake

Wreszcie istnieje konsola Quake o połowie wysokości, która opuszcza się ponad obszar roboczy, na którym aktualnie jesteś. Przełączysz ją za pomocą `Super + Grave`, a okno umieścisz tam za pomocą `Super + Shift + Grave`.

Otwiera się z Twoim domyślnym agentem gotowym do pracy. Dopóki konsola zawiera jedno okno, opuszcza się jako wyśrodkowany panel, a nie na całą szerokość ekranu. Umieść na niej drugą aplikację, a wróci do pełnej szerokości, dzięki czemu obie mają miejsce, aby stać obok siebie.

Aby przenieść okno ze scratchpada albo konsoli, wyślij je bezpośrednio na inny obszar roboczy za pomocą czegoś w rodzaju `Super + Shift + 1`.

### Trzeba się przyzwyczaić!

Przyzwyczajenie się do takiego poruszania się po pulpicie zajmuje trochę czasu, ale gdy już Ci się uda, trudno będzie wrócić do tradycyjnego pulpitu obsługiwanego myszą!
