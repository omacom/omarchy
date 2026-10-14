# Nawigacja

Wszystko w Omarchy dzieje się przez klawiaturę — _WSZYSTKO!_ Gdy system uruchamia się po raz pierwszy, dosłownie nic nie zrobisz samą myszą. Ale możesz nacisnąć `Super + Space`, aby wyświetlić menu Omarchy, a stamtąd zrobisz niemal wszystko.

Ale menu Omarchy nie ma nawet być przez większość czasu głównym sposobem obsługi systemu. Możemy działać szybciej! Wszystkie najważniejsze aplikacje są przypisane bezpośrednio do poszczególnych skrótów klawiszowych. Terminal uruchamiasz za pomocą `Super + Return`, a przeglądarkę za pomocą `Super + Shift + Return`. Spróbuj zrobić jedno po drugim, a zobaczysz magię kafelkowania Hyprland w akcji:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Następnie możesz nacisnąć `Super + J`, aby ułożyć je jedno nad drugim zamiast obok siebie:

 ![navigation-stacked](images/navigation-stacked.webp)

Naciśnij `Super + J` ponownie, aby przywrócić je do pozycji obok siebie. Następnie spróbuj `Super + Shift + Arrow Right` w przeglądarce, aby zamienić okna miejscami.

Teraz spróbuj `Super + Ctrl + T`, aby uruchomić monitor aktywności. Pojawi się on jako okno pływające. Możesz je ułożyć w kafelki za pomocą `Super + T` (i nacisnąć to ponownie, aby znów stało się pływające). Teraz naciśnij `Super + Shift + F`, aby otworzyć menedżer plików. Będziesz mieć zgrabny układ na cztery:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Pomiędzy oknami, które mają być aktywne, poruszasz się za pomocą `Super + Arrow`. Spowoduje to przełączenie fokusu i przeniesienie kursora na środek nowej aplikacji.

Jeśli naciśniesz `Super + Shift + 2`, przeniesiesz bieżącą aplikację z fokusem na drugi obszar roboczy. `Super + Shift + 1` przenosi ją z powrotem. (A `Super + Shift + Alt + 2` przeniesie bieżącą aplikację z fokusem na drugi obszar roboczy bez przełączania się na niego).

Jeśli przytrzymasz `Super` i klikniesz okno myszą, będziesz mógł zmienić jego położenie. Jeśli przytrzymasz `Super` i użyjesz prawego przycisku myszy, możesz swobodnie zmieniać rozmiar okna.

Okno zamykasz za pomocą `Super + W` lub `Super + Q` (a wszystkie okna zamykasz za pomocą `Ctrl + Alt + Delete`).

Możesz też przejść na pełny ekran za pomocą `Super + F`, a nawet tylko na pełną szerokość (zachowując górny pasek) za pomocą `Super + Alt + F` lub na pełny ekran wewnątrz okna za pomocą `Super + Ctrl + F` (dobre na YouTube!).

### Dwindle kontra układ scrolling

Domyślny układ Omarchy nazywa się dwindle. Utrzymuje wszystkie okna otwarte na jednym obszarze roboczym widoczne przez cały czas, nawet jeśli musi je zmniejszyć.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Ale możesz też wybrać, aby zamienić obszar roboczy w układ scrolling, w którym okna są ustawione obok siebie, poza widoczną krawędź ekranu. Pojedynczy obszar roboczy zamieniasz w ten układ za pomocą `Super + L`.

Ponowne naciśnięcie `Super + L` zamienia obszar roboczy w pływający, w którym okna swobodnie się nakładają i sam je umieszczasz, a trzecie naciśnięcie przywraca go do dwindle. `Super + Alt + L` przechodzi przez nie w drugą stronę. Okno, które i tak jest pływające — takie, które wyciągnąłeś za pomocą `Super + T`, lub aplikacja, która zawsze otwiera się jako pływająca — pozostaje pływające, gdy obszar roboczy wraca do kafelkowania. Górny pasek oznacza obszar roboczy, na którym jesteś, jego układem: kwadrat dla dwindle, koło dla scrolling i trójkąt dla pływającego. Kliknięcie tego znaku również zmienia układ w cyklu.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Wybór dotyczy każdego obszaru roboczego osobno i zostaje zapamiętany. Możesz więc zostawić obszar roboczy 1 na dwindle do przeglądania, a obszar roboczy 2 na scrolling do kodu, a po restarcie wrócą w ten sposób.

Jeśli chcesz używać układu scrolling jako domyślnego, możesz to ustawić w `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Pływające obszary robocze

Pływający obszar roboczy działa jak tradycyjny pulpit: okna nakładają się na siebie, a ty sam je przesuwasz i zmieniasz ich rozmiar. Każde okno dostaje pasek tytułu w kolorach twojego motywu, z przyciskami do minimalizowania, maksymalizowania i zamykania. `Super + M` również minimalizuje okno z fokusem. Zminimalizowane okno czeka w docku; kliknij jego aplikację, aby je przywrócić. Kliknij okno, aby przenieść je na przód. Zmień jego rozmiar z dowolnej krawędzi lub rogu. Kliknij dwukrotnie pasek tytułu, aby zmaksymalizować okno, zachowując górny pasek w widoku, i ponownie, aby przywrócić jego dawny rozmiar.

Pływający obszar roboczy pokazuje też dock, z twoimi przypiętymi aplikacjami, wszystkim, co jest uruchomione, oraz siatką każdej aplikacji za przyciskiem aplikacji, który otwierają też `Super + Alt + Space` oraz _Apps_ w menu Omarchy. Kliknij prawym przyciskiem aplikację na siatce lub naciśnij `Delete`, aby ją odinstalować. Kliknij aplikację, aby ją otworzyć lub przenieść jej okno na przód; kliknij ponownie, aby przechodzić w cyklu przez jej okna. Kliknięcie środkowym przyciskiem otwiera nowe okno. Przeciągnij ikonę wzdłuż docka, aby ją przenieść; przeciągnięcie uruchomionej aplikacji pomiędzy pozostałe zostawia ją tam. Kliknij prawym przyciskiem, aby zostawić aplikację w docku, usunąć ją z niego lub ją zamknąć. Dock ustępuje miejsca oknu pełnoekranowemu. Kliknij prawym przyciskiem przycisk aplikacji, aby przenieść dock na inną krawędź lub sprawić, by chował się, dopóki wskaźnik nie dotrze do jego krawędzi. Pozycja znajduje się też w _Trigger > Appearance > Dock > Dock Position_, a `omarchy dock position left` i `omarchy dock autohide on` ustawiają obie opcje z terminala. Aplikacje, które trzymasz w docku, są przygaszone, gdy nie są uruchomione.

Nowe obszary robocze oraz wszystkie, którym nie nadałeś własnego układu za pomocą `Super + L`, używają domyślnego układu. Zmiana domyślnego układu resetuje do niego każdy obszar roboczy bez okien, natomiast ten z oknami zachowuje układ, który ma. Okno zminimalizowane do docka nadal liczy się jako okno na obszarze roboczym, który opuściło. Wybierz go w _Trigger > Appearance > Workspace Layout_: Tiling, Scrolling lub Floating. `omarchy-hyprland-workspace-layout-default scrolling` ustawia go z terminala.

### Grupowanie okien

Okna można grupować za pomocą `Super + G`. Gdy już znajdziesz się w grupie, każde okno, które uruchomisz, gdy jest ona aktywna, będzie należało do tej grupy. Możesz poruszać się między tymi pogrupowanymi oknami za pomocą `Super + Ctrl + Arrow Left/Right` lub `Super + Alt + 1/2/3/4`, aby przejść bezpośrednio do pogrupowanego okna w kolejności.

Możesz przenieść okno poza grupowanie za pomocą `Super + Alt + G` lub rozłożyć całą grupę, naciskając ponownie `Super + G`. Na koniec możesz przenieść okna spoza grupy do niej za pomocą `Super + Alt + Arrows`.

### Wyciąganie okien

Możesz wyciągnąć okno z jego przydziału do obszaru roboczego za pomocą `Super + O`. Spowoduje to przypięcie go jako pływającego okna, które podąża za tobą na każdy obszar roboczy, na który przejdziesz. Świetne do odtwarzaczy wideo itp.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Obszar roboczy scratchpad

Na koniec jest specjalny obszar roboczy scratchpad, który opada na obszar roboczy, na którym właśnie jesteś, podobnie jak konsola w Quake. Przełączaj go za pomocą `Super + Grave` lub `Super + S`, a okno umieszczaj tam za pomocą `Super + Shift + Grave` lub `Super + Alt + S`.

Działa szczególnie dobrze dla terminala z uruchomionym agentem lub dla elementów sterujących, z którymi chcesz szybko interagować bez opuszczania bieżącego obszaru roboczego. Aby przenieść okno ze scratchpada, wyślij je bezpośrednio na inny obszar roboczy czymś w rodzaju `Super + Shift + 1`.

Gdy scratchpad zawiera jedno okno, opada jako wyśrodkowany panel, zamiast rozciągać się na cały ekran. Umieść na nim drugą aplikację, a wróci do pełnej szerokości, dzięki czemu obie będą miały miejsce, aby usiąść obok siebie.

### Trzeba się do tego trochę przyzwyczaić!

Przyzwyczajenie się do nawigowania po pulpicie w ten sposób zajmuje chwilę, ale gdy już to zrobisz, trudno będzie wrócić do tradycyjnego pulpitu napędzanego myszą!
