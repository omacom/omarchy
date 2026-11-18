# Górny pasek

Pasek biegnący wzdłuż górnej krawędzi ekranu to pasek Omarchy. Nie jest dokręconym paskiem stanu, lecz częścią powłoki Omarchy, jednego długo działającego procesu Quickshell, który rysuje też menu, powiadomienia, wyskakujące okna OSD i ekran blokady. Dlatego idealnie współgra motywem z całą resztą i dlatego panel otwiera się natychmiast, zamiast uruchamiać nową aplikację.

To także jedyny element pulpitu, który jest zawsze na ekranie, więc warto wiedzieć, co robią wszystkie te małe glify.

## Co jest na nim domyślnie

Pasek ma trzy sekcje. Po lewej siedzi logo Omarchy (program uruchamiający menu) i wskaźniki obszarów roboczych. Na środku masz wskaźniki stanu, zegar, Elsewhen (zegar światowy), pogodę i odznakę aktualizacji Omarchy. Po prawej: zasobnik systemowy, układ klawiatury (gdy skonfigurowano więcej niż jeden), agenci, bluetooth, sieć, dźwięk, wyświetlacz i zasilanie.

Kilka z nich pokazuje się tylko wtedy, gdy ma coś do powiedzenia. Układ klawiatury pojawia się tylko, jeśli skonfigurowano więcej niż jeden układ. Odznaka aktualizacji pojawia się tylko, gdy czeka aktualizacja Omarchy. A ikona agentów pojawia się, gdy Omarchy po raz pierwszy znajdzie na maszynie użycie agentów AI do kodowania (zobacz [AI](17-ai.md)).

## Klikanie

Niemal każdy widżet robi coś po kliknięciu lewym, prawym i środkowym przyciskiem, a kilka reaguje na przewijanie. To jest część, którą ludzie przegapiają — pod prawym i środkowym przyciskiem kryje się wiele dobrych rzeczy.

| Widżet | Lewy | Prawy | Środkowy / przewijanie |
| --- | --- | --- | --- |
| Menu | Menu Omarchy | Nowy terminal | — |
| Obszary robocze | Aktywuj ten obszar roboczy na tym monitorze | — | Przewijanie: następny/poprzedni obszar roboczy |
| Zegar | Wyskakujące okno kalendarza | Przełącz format etykiety | Środkowy: wybór strefy czasowej |
| Pogoda | Wyskakujące okno prognozy | Pełna pogoda jako powiadomienie | Środkowy: odśwież |
| Dźwięk | Panel dźwięku | Wycisz | Środkowy: panel · przewijanie: głośność |
| Mikrofon | Wycisz mikrofon | — | Środkowy: panel dźwięku · przewijanie: głośność wejściowa |
| Sieć | Panel sieci | — | — |
| Bluetooth | Panel Bluetooth | Przełącz radio | — |
| Wyświetlacz | Panel wyświetlacza | — | Przewijanie: jasność |
| Zasilanie | Panel zasilania | Przełącz procent baterii | — |
| Multimedia | Odtwórz/wstrzymaj | Wyskakujące okno okładki | Środkowy: następny · przewijanie: poprzedni/następny |
| Agenci | Panel agentów | Uruchom swojego agenta | Środkowy: następna subskrypcja |
| Zasobnik | Najechanie odsłania szufladę | Prawy przycisk na strzałce: zarządzanie | — |
| Aktualizacja Omarchy | Uruchom aktualizację | — | — |

Nie wszystko z tej tabeli jest od razu na pasku. Widżet multimediów (MPRIS — teraz odtwarzane, z przewijającym się utworem i artystą) oraz widżet mikrofonu są wbudowane, ale domyślnie wyłączone — dodaj je, jeśli ich chcesz, jak opisano poniżej.

## Panele

Kliknięcie ikony paska otwiera panel, czyli porządne wyskakujące okno ze suwakami, listami i nawigacją z klawiatury, a nie podpowiedź. Każdy ma też skrót klawiszowy, więc nigdy nie trzeba celować w 16-pikselowy glif:

| Skrót klawiszowy | Panel |
| --- | --- |
| `Super + Ctrl + A` | Dźwięk |
| `Super + Ctrl + N` | Sieć |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Wyświetlacz |
| `Super + Ctrl + P` | Zasilanie |
| `Super + Ctrl + Alt + D` | Kalendarz |
| `Super + Ctrl + Alt + E` | Zegar światowy |
| `Super + Ctrl + 1-9` | Przełącz n-ty panel w prawej sekcji |

Panele nie są tylko odczytami. To właśnie w nich naprawdę robi się daną rzecz:

- **Dźwięk** ma główny suwak głośności, wybór urządzenia wyjściowego i mikser dla poszczególnych aplikacji, więc można ściszyć tę jedną kartę przeglądarki, nie dotykając całej reszty.
- **Sieć** skanuje w poszukiwaniu Wi-Fi, pokazuje siłę sygnału, łączy i pozwala wybrać dostawcę DNS.
- **Bluetooth** wyświetla listę urządzeń z łączeniem/rozłączaniem i poziomami baterii.
- **Zasilanie** pokazuje statystyki baterii, przełącza profile zasilania (pamięta osobny wybór dla baterii i AC) i podaje trochę informacji o systemie.
- **Wyświetlacz** ma suwak jasności, rozmiar tekstu, gotowe ustawienia skalowania monitora oraz — gdy jest więcej niż jeden ekran — sterowanie dla poszczególnych monitorów. Zobacz [monitory](33-monitors.md), aby poznać szerszy opis.
- **Zegar** otwiera siatkę miesiąca z numerami tygodni ISO i przechodzeniem między miesiącami.
- **Zegar światowy** trzyma po jednym wierszu na miasto, z jego pogodą i tym, jak mija mu dzień. Wyszukiwanie znajduje miejscowości, a także strefy czasowe, więc Fort Lauderdale to Fort Lauderdale, a nie Nowy Jork. Jeśli wiersz u góry podaje niewłaściwe miasto, kliknij go i powiedz, gdzie jesteś; wybierz miejsce w innej strefie czasowej, a zegar systemowy też się tam przeniesie, co przydaje się w podróży. Najedź na miasto i kliknij przycisk osoby, aby powiedzieć, kto tam mieszka — zwykłe imiona lub nazwy użytkownika GitHub poprzedzone `@`, aby zabrać ich twarze ze sobą.

Każdy panel obsługuje klawiaturę równie dobrze jak mysz: strzałki przesuwają, Return aktywuje, Tab przechodzi do sąsiedniego panelu, a Escape zamyka.

`Super + Ctrl + 1-9` liczy panele od lewej do prawej w prawej sekcji, pomijając zasobnik, ponieważ nie ma własnego panelu. Liczba odpowiada więc ikonie, na którą by się wskazało.

### Tailscale i Dropbox

Dwa kolejne widżety pojawiają się na pasku dopiero po zainstalowaniu odpowiedniej usługi z **Instalacja → Usługa** i oba warto znać, ponieważ robią więcej niż tylko zgłaszają stan.

Panel **Tailscale** łączy i rozłącza tailnet, przełącza konta i wybiera węzeł wyjściowy (na tej liście pojawiają się zarówno własne maszyny, jak i regiony Mullvad). Przegląda też maszyny — a przy wybranej maszynie `s` wysyła do niej pliki przez Taildrop, co jest najszybszym sposobem przeniesienia pliku na telefon lub inny laptop. `c` kopiuje adres IP maszyny, `n` jej nazwę, a `d` jej pełną nazwę DNS. Na każdym wierszu maszyny jest też przycisk wysyłania, jeśli wolisz klikać. To samo z terminala to `omarchy tailscale send <machine> [file...]`.

Panel **Dropbox** obsługuje logowanie, pokazuje, ile miejsca wykorzystano, i wyświetla listę ostatnio zsynchronizowanych plików.

Usunięcie którejkolwiek usługi zabiera jej widżet z paska.

## Wskaźniki

Mały klaster na środku to widżet wskaźników. Są to glify stanu dla włączonych trybów: nie przeszkadzać, światło nocne, oczekujące [przypomnienie](09-reminders.md), aktywne nagrywanie ekranu, czuwanie i [dyktowanie](11-text-extraction-dictation.md). Podświetlają się, gdy tryb jest aktywny, a poza tym nie rzucają się w oczy — najedź tuż obok nich, tam, gdzie siedziałyby nieaktywne, aby podejrzeć te pozostałe. Kliknięcie wskaźnika przełącza ten tryb. Jeszcze jeden pełni tylko funkcję stanu: sesja zdalna świeci na czerwono, gdy ktoś jest połączony z tą maszyną przez gliff.

Jeśli mają być zawsze widoczne, ustaw `alwaysShow` na `true` w widżecie. A jeśli zależy Ci tylko na niektórych, wypisz te, których chcesz, w `items`: `["Dnd", "Reminder", "NightLight"]`. Można mieć więcej niż jeden widżet wskaźników, więc różne sekcje mogą pokazywać różne podzbiory.

## Przestawianie paska

Pasek konfiguruje się sam. Nie trzeba otwierać pliku konfiguracyjnego, aby coś przenieść.

Chwyć pusty fragment paska wokół środka i przeciągnij go w stronę innej krawędzi ekranu, a pasek się tam przeniesie — lewa, prawa, górna i dolna działają, a każdy widżet się dostosowuje (pionowe paski wracają do kompaktowych form samych ikon). Kliknięcie i przytrzymanie rozpoczyna to samo przeciąganie. Kliknij dwukrotnie lewym przyciskiem to samo puste miejsce, aby przełączać tło paska od przezroczystego przez szkliste po nieprzezroczyste. I przeciągnij dowolny widżet, aby zmienić jego kolejność lub przerzucić go do innej sekcji; pozostałe widżety rozsuwają się, aby zrobić miejsce tam, gdzie wyląduje.

Środek paska to pudełko: wszystko, co w nim jest, pozostaje wyśrodkowane jako jedna grupa, a widżety po obu jego stronach zwisają z jego krawędzi. Gdy przeciągasz widżet, pudełko pokazuje się jako obrys lub linia w poprzek paska, gdy jest puste, i można upuścić do niego lub obok niego. Gdy upuszczenie wylądowałoby w pudełku, pudełko powiększa się, aby przyjąć widżet.

Widżet, który ma być pod ręką, ale nie zawsze na widoku, może trafić do szuflady zasobnika: przeciągnij go na zasobnik, a szuflada otworzy się, aby go przyjąć. Siedzi tam za ikonami aplikacji, pokazuje się zawsze, gdy pokazuje się szuflada, i utrzymuje swoją szufladę otwartą, gdy jego panel jest otwarty. Przeciągnij go z powrotem na pasek, aby go przywrócić.

Jeśli wolisz wybrać z menu, **Wygląd → Pasek menu** ma pozycję, a **Tło paska** wybiera, jak pasek jest rysowany: **Nieprzezroczysty pasek**, **Szklisty pasek** (przezroczysty, z rozmyciem tego, co jest za nim) lub **Przezroczysty pasek**.

Te same rzeczy mają polecenia, czego właśnie trzeba przy konfiguracji [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Aby całkowicie dodać lub usunąć widżet, użyj poleceń wtyczek. `omarchy plugin list` wypisuje każdy widżet, który powłoka zna, wraz z jego id, a następnie:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Ukrywanie paska

`Super + Shift + Space` wyłącza pasek i włącza go z powrotem, nie zabijając powłoki — panele i skróty klawiszowe nadal działają, po prostu odzyskujesz piksele. Jest to także w menu pod **Wygląd → Pasek menu → Ukryj pasek**.

## Plik konfiguracyjny

Wszystko to jest przechowywane w `~/.config/omarchy/shell.json`, pod kluczem `bar`. Oto przycięta wersja:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "centerBegin": [{ "id": "omarchy.indicators" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "centerEnd": [{ "id": "omarchy.weather" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Każdy widżet to jeden wpis w jednej z pięciu tablic układu, a jego ustawienia znajdują się bezpośrednio w tym wpisie — nie ma osobnego pliku ustawień ani podobiektu `config`. `format`, `formatAlt` (to, do czego przechodzi prawy przycisk) i `verticalFormat` zegara znajdują się właśnie tam, w `{ "id": "omarchy.clock" }`.

`center` to pudełko na środku paska: wszystko w nim jest wyśrodkowane na ekranie jako jedna grupa. `centerBegin` i `centerEnd` zwisają po obu stronach pudełka, dzięki czemu zegar pozostaje dokładnie na środku, nawet gdy pogoda i odznaka aktualizacji pojawiają się i znikają. Umieść więcej niż jeden widżet w `center`, a będą wyśrodkowane razem; zostaw je puste, a `centerBegin` i `centerEnd` spotkają się na środku paska.

Jedna zasada, którą warto przyswoić: **gdy jest własny `shell.json`, jest on kanoniczny**. Dopóki niczego nie zmienisz, powłoka odczytuje domyślny plik Omarchy. W chwili, gdy przeciągniesz widżet, uruchomisz `omarchy bar` lub samodzielnie wyedytujesz plik, należy on do Ciebie — nie ma głębokiego scalania, więc nowe domyślne widżety w przyszłych wydaniach Omarchy nie pojawią się na Twoim pasku automatycznie. `omarchy bar defaults` przywraca dostarczony układ zawsze, gdy chcesz mieć czystą kartę.

Ten sam plik przechowuje też czasy bezczynności na najwyższym poziomie, poza kluczem `bar`: `idle.screensaver` i `idle.lock`, oba w sekundach od przejścia w stan bezczynności. Domyślny wygaszacz ekranu uruchamia się więc po 150 sekundach, a blokada po 300.
