# Górny pasek

Pasek biegnący wzdłuż góry ekranu to pasek Omarchy. Nie jest to dokręcony pasek stanu, lecz część powłoki Omarchy — tego samego, długo działającego procesu Quickshell, który rysuje też menu, powiadomienia, wyskakujące okna OSD i ekran blokady. Dlatego doskonale współgra tematycznie ze wszystkim innym i dlatego panel otwiera się natychmiast, zamiast uruchamiać nową aplikację.

To także jedyny element pulpitu, który zawsze jest na ekranie, więc warto wiedzieć, co robią wszystkie te małe glify.

## Co jest na nim domyślnie

Pasek ma trzy sekcje. Po lewej stronie znajduje się logo Omarchy (program uruchamiający menu) oraz wskaźniki obszarów roboczych. Na środku znajdują się wskaźniki stanu, zegar, Elsewhen (zegar światowy), pogoda oraz odznaka aktualizacji Omarchy. Po prawej stronie: zasobnik systemowy, układ klawiatury (gdy skonfigurowano więcej niż jeden układ lub metodę wprowadzania), agenty, bluetooth, sieć, dźwięk, ekran i zasilanie.

Kilka z nich pojawia się tylko wtedy, gdy mają coś do powiedzenia. Układ klawiatury pojawia się tylko wtedy, gdy skonfigurowano więcej niż jeden układ lub metodę wprowadzania. Odznaka aktualizacji pojawia się tylko wtedy, gdy czeka aktualizacja Omarchy.

## Klikanie tu i tam

Niemal każdy widżet robi coś po kliknięciu lewym, prawym i środkowym przyciskiem, a kilka reaguje na przewijanie. To jest ta część, którą ludzie pomijają — prawy i środkowy przycisk to miejsca, w których kryje się wiele dobrego.

| Widżet | Lewy | Prawy | Środkowy / przewijanie |
| --- | --- | --- | --- |
| Menu | Menu Omarchy | Nowy terminal | — |
| Obszary robocze | Skup ten obszar roboczy na tym monitorze | — | Przewijanie: następny/poprzedni obszar roboczy |
| Zegar | Wyskakujące okno kalendarza | Przełącz format etykiety | Środkowy: wybór strefy czasowej |
| Zegar światowy | Panel zegara światowego | Odśwież | Środkowy: odśwież |
| Pogoda | Wyskakujące okno prognozy | Pełna pogoda jako powiadomienie | Środkowy: odśwież |
| Dźwięk | Panel dźwięku | Wycisz | Środkowy: panel · przewijanie: głośność |
| Mikrofon | Wycisz mikrofon | — | Środkowy: panel dźwięku · przewijanie: głośność wejściowa |
| Sieć | Panel sieci | — | — |
| Bluetooth | Panel Bluetooth | Przełącz radio | — |
| Ekran | Panel ekranu | — | Przewijanie: jasność |
| Zasilanie | Panel zasilania | Przełącz procent baterii | — |
| Media | Odtwórz/wstrzymaj | Wyskakujące okno okładki | Środkowy: następny · przewijanie: poprzedni/następny |
| Agenty | Panel agentów | Uruchom swojego agenta | Środkowy: odśwież zużycie |
| Zasobnik | Najedź, aby odsłonić szufladę | Prawy na strzałce w górę, aby zarządzać | — |
| Aktualizacja Omarchy | Uruchom aktualizację | — | — |

Nie wszystko w tej tabeli jest na twoim pasku od razu po wyjęciu z pudełka. Widżet mediów (odtwarzane teraz przez MPRIS, z przewijanym utworem i wykonawcą) oraz widżet mikrofonu są wbudowane, ale domyślnie wyłączone — dodaj je, jeśli ich chcesz, tak jak opisano poniżej.

## Panele

Kliknięcie ikony paska otwiera panel, który jest prawdziwym wyskakującym oknem z suwakami, listami i nawigacją z klawiatury, a nie podpowiedzią. Każdy ma też skrót klawiszowy, więc nigdy nie musisz celować w 16-pikselowy glif:

| Skrót klawiszowy | Panel |
| --- | --- |
| `Super + Ctrl + A` | Dźwięk |
| `Super + Ctrl + N` | Sieć |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Ekran |
| `Super + Ctrl + P` | Zasilanie |
| `Super + Ctrl + Alt + D` | Kalendarz |
| `Super + Ctrl + Alt + E` | Zegar światowy |
| `Super + Ctrl + X` | Agenty |
| `Super + Ctrl + 1-9` | Przełącz n-ty panel w prawej sekcji |

Panele nie są tylko odczytami. To miejsca, w których naprawdę robisz daną rzecz:

- **Dźwięk** ma główny suwak głośności, selektor urządzenia wyjściowego i mikser dla poszczególnych aplikacji, dzięki czemu możesz ściszyć tę jedną kartę przeglądarki bez dotykania wszystkiego innego.
- **Sieć** skanuje w poszukiwaniu Wi-Fi, pokazuje siłę sygnału, łączy i pozwala wybrać dostawcę DNS.
- **Bluetooth** wyświetla listę twoich urządzeń wraz z łączeniem/rozłączaniem i poziomami baterii.
- **Zasilanie** pokazuje statystyki baterii, przełącza profile zasilania (pamięta osobny wybór dla baterii i AC) oraz wypisuje trochę informacji o systemie.
- **Ekran** zawiera suwak jasności, rozmiar tekstu, ustawienia wstępne skalowania monitora oraz — gdy masz więcej niż jeden ekran — kontrolki dla poszczególnych monitorów. Zobacz [monitory](33-monitors.md), aby poznać głębszą historię.
- **Zegar** otwiera siatkę miesiąca z numerami tygodni ISO i przechodzeniem między miesiącami.
- **Zegar światowy** przechowuje wiersz dla każdego miasta, wraz z jego pogodą i tym, jak mija jego dzień. Wyszukiwanie znajduje miejscowości, a także strefy czasowe, więc Fort Lauderdale to Fort Lauderdale, a nie New York. Jeśli wiersz na górze podaje niewłaściwe miasto, kliknij go i powiedz, gdzie jesteś; wybierz miejsce w innej strefie czasowej, a zegar systemowy również się tam przeniesie, co jest przydatne podczas podróży. Najedź na miasto i kliknij przycisk osoby, aby powiedzieć, kto tam mieszka — zwykłe imiona lub nazwy użytkowników GitHub poprzedzone `@`, aby przyciągnąć ich twarze.

Każdy panel obsługuje klawiaturę, a także mysz: strzałki poruszają, Return aktywuje, Tab przechodzi do sąsiedniego panelu, a Escape zamyka.

`Super + Ctrl + 1-9` liczy panele od lewej do prawej w prawej sekcji, pomijając zasobnik, ponieważ nie ma on własnego panelu. Dzięki temu numer odpowiada ikonie, na którą byś wskazał.

### Tailscale i Dropbox

Dwa kolejne widżety pojawiają się na pasku dopiero po zainstalowaniu pasującej usługi z **Install → Service** i oba warto znać, ponieważ robią więcej niż tylko raportują stan.

Panel **Tailscale** łączy i rozłącza tailnet, przełącza między kontami i wybiera węzeł wyjściowy (na tej liście pojawiają się zarówno twoje własne maszyny, jak i regiony Mullvad). Przegląda też twoje maszyny — a gdy jedna jest wybrana, `s` wysyła do niej pliki przez Taildrop, co jest najszybszym sposobem przeniesienia pliku na telefon lub inny laptop. `c` kopiuje adres IP maszyny, `n` jej nazwę, a `d` jej pełną nazwę DNS. Na każdym wierszu maszyny jest też przycisk wysyłania, jeśli wolisz klikać. To samo z terminala to `omarchy tailscale send <machine> [file...]`.

Panel **Dropbox** obsługuje logowanie, pokazuje, ile miejsca użyłeś, i wyświetla listę ostatnio zsynchronizowanych plików.

Usunięcie którejkolwiek usługi zdejmuje jej widżet z paska.

## Wskaźniki

Mały klaster na środku to widżet wskaźników. Są to glify stanu dla trybów, które włączyłeś: nie przeszkadzać, światło nocne, zakolejkowane [przypomnienie](09-reminders.md), aktywne nagrywanie ekranu i pozostawanie w stanie czuwania, a także ostrzeżenia, gdy włączone jest sudo bez hasła lub ktoś jest połączony ze zdalną sesją. Rozświetlają się, gdy tryb jest aktywny, a w przeciwnym razie stoją z boku — najedź tuż obok nich, tam, gdzie siedziałyby nieaktywne, aby podejrzeć te. Kliknięcie wskaźnika przełącza ten tryb. Jeszcze jeden jest tylko od stanu: zdalna sesja świeci się na czerwono, gdy ktoś jest połączony z tą maszyną przez gliff.

Jeśli wolisz, aby zawsze były widoczne, ustaw `alwaysShow` na `true` w widżecie. A jeśli zależy ci tylko na niektórych z nich, wymień te, których chcesz, w `items`: `["Dnd", "Reminder", "NightLight"]`. Możesz mieć więcej niż jeden widżet wskaźników, więc różne sekcje mogą pokazywać różne podzbiory.

## Przestawianie paska

Pasek konfiguruje się sam. Nie musisz otwierać pliku konfiguracyjnego, aby przesuwać rzeczy.

Chwyć pusty fragment paska wokół środka i przeciągnij go w stronę innej krawędzi ekranu, a pasek się tam przeniesie — lewa, prawa, górna lub dolna strona działają, a każdy widżet się dostosowuje (pionowe paski przechodzą w kompaktowe formy składające się tylko z ikon). Kliknięcie i przytrzymanie rozpoczyna to samo przeciąganie. Kliknij dwukrotnie lewym przyciskiem tę samą pustą przestrzeń, aby przełączać tło paska z przezroczystego na szklane i nieprzezroczyste. Przeciągnij też dowolny widżet, aby zmienić jego kolejność lub wrzucić go do innej sekcji; pozostałe widżety rozsuwają się, aby zrobić miejsce tam, gdzie wyląduje.

Środek paska to pudełko: cokolwiek w nim jest, pozostaje wyśrodkowane jako jedna grupa, a widżety po obu jego stronach zwisają z jego krawędzi. Podczas przeciągania widżetu pudełko pokazuje się jako obrys lub linia w poprzek paska, gdy jest puste, i możesz upuścić do niego lub obok niego. Gdy upuszczenie wylądowałoby w pudełku, pudełko rośnie, aby przyjąć widżet.

Widżet, który chcesz mieć pod ręką, ale nie zawsze w widoku, może trafić do szuflady zasobnika: przeciągnij go na zasobnik, a szuflada otworzy się, aby go przyjąć. Zasiada tam po ikonach aplikacji, pojawia się za każdym razem, gdy pojawia się szuflada, i utrzymuje swoją szufladę otwartą, gdy jego panel jest podniesiony. Przeciągnij go z powrotem na pasek, aby go tam przywrócić.

Jeśli wolisz wybierać z menu, **Appearance → Menu Bar** ma pozycję, a **Bar Background** wybiera, jak pasek jest rysowany: **Opaque Bar**, **Glassy Bar** (przezroczysty, z rozmytym tym, co za nim) lub **Clear Bar**.

Te same rzeczy mają polecenia, a to właśnie jest to, czego chcesz do konfiguracji [dotfiles](31-dotfiles.md):

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

`Super + Shift + Space` przełącza pasek w stan wyłączony i z powrotem włączony bez zabijania powłoki — panele i skróty klawiszowe nadal działają, po prostu odzyskujesz piksele. Jest to także w menu pod **Appearance → Menu Bar → Hide Bar**.

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

Każdy widżet jest jednym wpisem w jednej z pięciu tablic układu, a jego ustawienia znajdują się bezpośrednio w tym wpisie — nie ma osobnego pliku ustawień ani podobiektu `config`. `format`, `formatAlt` (to, na co przełącza prawy przycisk) oraz `verticalFormat` zegara znajdują się właśnie tam, w `{ "id": "omarchy.clock" }`.

`center` to pudełko na środku paska: wszystko w nim jest wyśrodkowane na ekranie jako jedna grupa. `centerBegin` i `centerEnd` zwisają z obu stron pudełka, dzięki czemu zegar pozostaje dokładnie na środku, nawet gdy pogoda i odznaka aktualizacji pojawiają się i znikają. Umieść w `center` więcej niż jeden widżet, a będą wyśrodkowane razem; zostaw je puste, a `centerBegin` i `centerEnd` spotkają się na środku paska.

Jedna reguła warta przyswojenia: **gdy masz już własny `shell.json`, jest on kanoniczny**. Dopóki niczego nie dostosujesz, powłoka odczytuje domyślny plik Omarchy. W chwili, gdy przeciągniesz widżet, uruchomisz `omarchy bar` lub sam wyedytujesz plik, jest on twój — nie ma głębokiego scalania, więc nowe domyślne widżety w przyszłych wydaniach Omarchy nie pojawią się automatycznie na twoim pasku. `omarchy bar defaults` przywraca dostarczony układ, kiedykolwiek chcesz mieć czystą kartę.

Ten sam plik przechowuje także twoje czasy bezczynności na najwyższym poziomie, poza kluczem `bar`: `idle.screensaver` i `idle.lock`, oba w sekundach od chwili przejścia w stan bezczynności. Domyślny wygaszacz ekranu włącza się więc po 150 sekundach, a blokada po 300.
