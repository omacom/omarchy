# Górny pasek

Pasek wzdłuż górnej krawędzi ekranu to pasek Omarchy. Nie jest przykręconym paskiem stanu, lecz częścią powłoki Omarchy, tego jednego, długotrwałego procesu Quickshell, który rysuje też menu, powiadomienia, wyskakujące okna OSD i ekran blokady. Dlatego idealnie współgra motywem z całą resztą i dlatego panel otwiera się natychmiast, zamiast uruchamiać nową aplikację.

To także jedyny element pulpitu, który jest zawsze na ekranie, więc warto wiedzieć, co robią te wszystkie małe glify.

## Co znajduje się na nim domyślnie

Pasek ma trzy sekcje. Po lewej stronie znajduje się logo Omarchy (program uruchamiający menu) oraz wskaźniki obszarów roboczych. Na środku znajdują się wskaźniki stanu, zegar, Elsewhen (zegar światowy), pogoda oraz odznaka aktualizacji Omarchy. Po prawej stronie: zasobnik systemowy, układ klawiatury (gdy skonfigurowano więcej niż jeden), agenci, bluetooth, sieć, dźwięk, ekran oraz zasilanie.

Kilka z tych elementów pojawia się tylko wtedy, gdy mają coś do powiedzenia. Układ klawiatury pojawia się tylko wtedy, gdy skonfigurowano więcej niż jeden układ. Odznaka aktualizacji pojawia się tylko wtedy, gdy oczekuje aktualizacja Omarchy. Natomiast ikona agentów pojawia się po raz pierwszy, gdy Omarchy znajdzie na maszynie użycie agentów kodujących AI (zobacz [AI](17-ai.md)).

## Klikanie

Prawie każdy widżet robi coś po kliknięciu lewym, prawym i środkowym przyciskiem, a kilka reaguje na przewijanie. To jest część, którą ludzie pomijają — prawy i środkowy przycisk to miejsca, w których kryje się wiele dobrych rzeczy.

| Widget | Left | Right | Middle / scroll |
| --- | --- | --- | --- |
| Menu | Menu Omarchy | Nowy terminal | — |
| Workspaces | Przejdź do tego obszaru roboczego na tym monitorze | — | Przewijanie: następny/poprzedni obszar roboczy |
| Clock | Wyskakujące okno kalendarza | Przełącz format etykiety | Środkowy: wybór strefy czasowej |
| Weather | Wyskakujące okno prognozy | Pełna pogoda jako powiadomienie | Środkowy: odśwież |
| Audio | Panel dźwięku | Wycisz | Środkowy: panel · przewijanie: głośność |
| Microphone | Wycisz mikrofon | — | Środkowy: panel dźwięku · przewijanie: głośność wejściowa |
| Network | Panel sieci | — | — |
| Bluetooth | Panel Bluetooth | Przełącz radio | — |
| Display | Panel ekranu | — | Przewijanie: jasność |
| Power | Panel zasilania | Przełącz procent baterii | — |
| Media | Odtwórz/wstrzymaj | Wyskakujące okno okładki | Środkowy: następny · przewijanie: poprzedni/następny |
| Agents | Panel agentów | Uruchom swojego agenta | Środkowy: następna subskrypcja |
| Tray | Najedź, aby odsłonić szufladę | Prawy przycisk na strzałce, aby zarządzać | — |
| Omarchy update | Uruchom aktualizację | — | — |

Nie wszystko z tej tabeli znajduje się na pasku od razu po instalacji. Widżet multimediów (MPRIS now-playing, z przewijającym się utworem i artystą) oraz widżet mikrofonu są wbudowane, ale domyślnie wyłączone — dodaj je, jeśli ich chcesz, w sposób opisany poniżej.

## Panele

Kliknięcie ikony na pasku otwiera panel, który jest prawdziwym wyskakującym oknem ze suwakami, listami i nawigacją z klawiatury, a nie podpowiedzią. Każdy z nich ma także skrót klawiszowy, więc nigdy nie musisz celować w 16-pikselowy glif:

| Hotkey | Panel |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + N` | Network |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Display |
| `Super + Ctrl + P` | Power |
| `Super + Ctrl + Alt + D` | Calendar |
| `Super + Ctrl + Alt + E` | World clock |
| `Super + Ctrl + 1-9` | Przełącz n-ty panel w prawej sekcji |

Panele nie są tylko odczytami. To miejsca, w których naprawdę robisz daną rzecz:

- **Audio** ma główny suwak głośności, wybór urządzenia wyjściowego oraz mikser dla poszczególnych aplikacji, dzięki czemu możesz ściszyć tę jedną kartę przeglądarki bez dotykania całej reszty.
- **Network** skanuje w poszukiwaniu Wi-Fi, pokazuje siłę sygnału, łączy oraz pozwala wybrać dostawcę DNS.
- **Bluetooth** wyświetla listę urządzeń wraz z łączeniem/rozłączaniem oraz poziomami baterii.
- **Power** pokazuje statystyki baterii, przełącza profile zasilania (pamięta oddzielny wybór dla baterii i AC) oraz wyświetla pewne informacje o systemie.
- **Display** zawiera suwak jasności, rozmiar tekstu, ustawienia wstępne skalowania monitora oraz — gdy masz więcej niż jeden ekran — elementy sterujące dla poszczególnych monitorów. Zobacz [monitory](33-monitors.md), aby poznać głębszą historię.
- **Clock** otwiera siatkę miesiąca z numerami tygodni ISO oraz przechodzeniem między miesiącami.
- **World clock** utrzymuje jeden wiersz dla każdego miasta, wraz z jego pogodą oraz tym, jak mija jego dzień. Wyszukiwanie znajduje miejscowości, a także strefy czasowe, więc Fort Lauderdale to Fort Lauderdale, a nie New York. Jeśli wiersz u góry podaje niewłaściwe miasto, kliknij go i powiedz, gdzie jesteś; wybierz miejsce w innej strefie czasowej, a zegar systemowy również tam się przeniesie, co jest przydatne w podróży. Najedź na miasto i kliknij przycisk osoby, aby powiedzieć, kto tam mieszka — zwykłe imiona lub nazwy użytkownika GitHub poprzedzone `@`, aby przyciągnąć wraz z nimi ich twarze.

Każdy panel obsługuje klawiaturę, a także mysz: strzałki poruszają, Return aktywuje, Tab przechodzi do sąsiedniego panelu, a Escape zamyka.

`Super + Ctrl + 1-9` liczy panele od lewej do prawej w prawej sekcji, pomijając zasobnik, ponieważ nie ma on własnego panelu. Dzięki temu numer odpowiada ikonie, na którą byś wskazał.

### Tailscale i Dropbox

Dwa kolejne widżety pojawiają się na pasku dopiero po zainstalowaniu odpowiadającej im usługi z **Install → Service** i oba warto znać, ponieważ robią więcej niż tylko zgłaszają stan.

Panel **Tailscale** łączy i rozłącza tailnet, przełącza między kontami oraz wybiera węzeł wyjściowy (na tej liście pojawiają się zarówno twoje własne maszyny, jak i regiony Mullvad). Przegląda też twoje maszyny — a po wybraniu jednej z nich `s` wysyła do niej pliki przez Taildrop, co jest najszybszym sposobem przeniesienia pliku na telefon lub inny laptop. `c` kopiuje adres IP maszyny, `n` jej nazwę, a `d` jej pełną nazwę DNS. Na każdym wierszu maszyny znajduje się też przycisk wysyłania, jeśli wolisz klikać. To samo z terminala to `omarchy tailscale send <machine> [file...]`.

Panel **Dropbox** obsługuje logowanie, pokazuje, ile miejsca wykorzystano, oraz wyświetla listę ostatnio zsynchronizowanych plików.

Usunięcie którejkolwiek usługi zdejmuje jej widżet z powrotem z paska.

## Wskaźniki

Mała grupa na środku to widżet wskaźników. Są to glify stanu dla włączonych trybów: nie przeszkadzać, światło nocne, oczekujące [przypomnienie](09-reminders.md), aktywne nagrywanie ekranu, nie usypiaj oraz [dyktowanie](11-text-extraction-dictation.md). Podświetlają się, gdy tryb jest aktywny, a poza tym nie przeszkadzają — najedź w dowolnym miejscu na pasek, aby podejrzeć nieaktywne. Kliknięcie wskaźnika przełącza dany tryb. Jeszcze jeden pełni wyłącznie funkcję stanu: sesja zdalna świeci na czerwono, gdy ktoś jest połączony z tą maszyną przez gliff.

Jeśli wolisz, aby były zawsze widoczne, ustaw `alwaysShow` na `true` w widżecie. A jeśli zależy ci tylko na niektórych z nich, wymień te, które chcesz, w `items`: `["Dnd", "Reminder", "NightLight"]`. Możesz mieć więcej niż jeden widżet wskaźników, dzięki czemu różne sekcje mogą pokazywać różne podzbiory.

## Przestawianie paska

Pasek konfiguruje się sam. Nie musisz otwierać pliku konfiguracyjnego, aby przenieść rzeczy.

Chwyć pusty fragment paska wokół środka i przeciągnij go w kierunku innej krawędzi ekranu, a pasek tam się przeniesie — działają lewa, prawa, górna i dolna krawędź, a każdy widżet się dostosowuje (pionowe paski powracają do kompaktowych form opartych wyłącznie na ikonach). Kliknięcie i przytrzymanie rozpoczyna to samo przeciąganie. Dwukrotne kliknięcie lewym przyciskiem tego samego pustego miejsca przełącza tło paska, przechodząc od przezroczystego przez szkliste do nieprzezroczystego. Natomiast przeciągnij dowolny widżet, aby zmienić jego kolejność lub wrzucić go do innej sekcji; pozostałe widżety rozsuwają się, aby zrobić miejsce tam, gdzie wyląduje.

Środek paska to pudełko: wszystko, co się w nim znajduje, pozostaje wyśrodkowane jako jedna grupa, a widżety po obu jego stronach zwisają z jego krawędzi. Podczas przeciągania widżetu pudełko pokazuje się jako obrys albo jako linia w poprzek paska, gdy jest puste, i możesz upuścić do niego lub obok niego. Gdy upuszczenie wylądowałoby w pudełku, pudełko rośnie, aby przyjąć widżet.

Widżet, który chcesz mieć pod ręką, ale nie zawsze w widoku, może trafić do szuflady zasobnika: przeciągnij go na zasobnik, a szuflada otworzy się, aby go przyjąć. Siedzi tam za ikonami aplikacji, pojawia się za każdym razem, gdy pojawia się szuflada, i utrzymuje swoją szufladę otwartą, gdy jego panel jest otwarty. Przeciągnij go z powrotem na pasek, aby go tam zwrócić.

Jeśli wolisz wybierać z menu, **Appearance → Menu Bar** zawiera pozycję, a **Bar Background** wybiera sposób rysowania paska: **Opaque Bar**, **Glassy Bar** (przezroczysty, z rozmyciem tego, co znajduje się za nim) lub **Clear Bar**.

Te same rzeczy mają polecenia, co jest tym, czego chcesz w konfiguracji [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Aby całkowicie dodać lub usunąć widżet, użyj poleceń wtyczek. `omarchy plugin list` wypisuje każdy widżet znany powłoce wraz z jego identyfikatorem, a potem:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Ukrywanie paska

`Super + Shift + Space` wyłącza pasek i włącza go z powrotem bez zabijania powłoki — panele i skróty klawiszowe nadal działają, po prostu odzyskujesz piksele. Znajduje się to także w menu w **Appearance → Menu Bar → Hide Bar**.

## Plik konfiguracyjny

Wszystko jest przechowywane w `~/.config/omarchy/shell.json`, pod kluczem `bar`. Oto przycięta wersja:

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

Każdy widżet to jeden wpis w jednej z pięciu tablic układu, a jego ustawienia znajdują się bezpośrednio w tym wpisie — nie ma oddzielnego pliku ustawień ani podobiektu `config`. `format`, `formatAlt` (to, do czego przechodzi kliknięcie prawym przyciskiem) oraz `verticalFormat` zegara znajdują się właśnie tam, w `{ "id": "omarchy.clock" }`.

`center` to pudełko na środku paska: wszystko, co się w nim znajduje, jest wyśrodkowane na ekranie jako jedna grupa. `centerBegin` i `centerEnd` zwisają po obu stronach pudełka, dzięki czemu zegar pozostaje dokładnie na środku, nawet gdy pogoda i odznaka aktualizacji pojawiają się i znikają. Umieść więcej niż jeden widżet w `center`, a zostaną wyśrodkowane razem; pozostaw je puste, a `centerBegin` i `centerEnd` spotkają się na środku paska.

Jedna zasada, którą warto sobie przyswoić: **gdy masz własny `shell.json`, jest on kanoniczny**. Dopóki niczego nie dostosujesz, powłoka odczytuje domyślny plik Omarchy. W momencie, gdy przeciągniesz widżet, uruchomisz `omarchy bar` lub sam edytujesz plik, należy on do ciebie — nie ma głębokiego łączenia, więc nowe domyślne widżety w przyszłych wydaniach Omarchy nie pojawią się automatycznie na twoim pasku. `omarchy bar defaults` przywraca dostarczony układ, kiedykolwiek chcesz mieć czystą kartę.

Ten sam plik przechowuje także czasy bezczynności na najwyższym poziomie, poza kluczem `bar`: `idle.screensaver` oraz `idle.lock`, oba w sekundach od przejścia w stan bezczynności. Domyślny wygaszacz ekranu włącza się więc po 150 sekundach, a blokada po 300.
