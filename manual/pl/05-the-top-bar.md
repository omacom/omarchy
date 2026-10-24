# Górny pasek

Pasek wzdłuż górnej krawędzi ekranu to pasek Omarchy. Nie jest doczepionym paskiem statusu, lecz częścią powłoki Omarchy — pojedynczego, długo działającego procesu Quickshell, który rysuje też menu, powiadomienia, wyskakujące OSD i ekran blokady. Dlatego doskonale motywuje się z całą resztą pulpitów i dlatego panel otwiera się natychmiast zamiast tworzyć nową aplikację.

To też jedyny fragment pulpitu, który jest zawsze widoczny, więc warto wiedzieć, co robią te wszystkie małe glify.

## Co jest na nim domyślnie

Pasek ma trzy sekcje. Po lewej siedzą logo Omarchy (uruchamiacz menu) oraz wskaźniki obszarów roboczych. Pośrodku dostajesz wskaźniki statusu, zegar, Elsewhen (zegar światowy), pogodę i plakietkę aktualizacji Omarchy. Po prawej: układ klawiatury (gdy skonfigurowany jest więcej niż jeden), zasobnik systemowy, agenci, bluetooth, sieć, dźwięk, ekran i zasilanie.

Kilka z tych elementów pokazuje się tylko, gdy ma coś do powiedzenia. Układ klawiatury pojawia się tylko, gdy skonfigurowałeś więcej niż jeden układ. Plakietka aktualizacji pojawia się tylko, gdy czeka aktualizacja Omarchy. A ikona agentów pojawia się, gdy Omarchy po raz pierwszy znajdzie na maszynie użycie agentów kodujących AI (zob. [AI](17-ai.md)).

## Klikanie

Prawie każdy widget robi coś po kliknięciu lewym, prawym i środkowym przyciskiem, a kilka reaguje na przewijanie. To ta część, którą ludzie przeoczają — prawy i środkowy przycisk to miejsca, gdzie kryje się wiele dobrego.

| Widget | Lewy | Prawy | Środkowy / przewijanie |
| --- | --- | --- | --- |
| Menu | Menu Omarchy | Nowy terminal | — |
| Obszary robocze | Skupienie na tym obszarze | — | Przewijanie: następny/poprzedni obszar roboczy |
| Zegar | Wyskakujący kalendarz | Przełączanie formatu etykiety | Środkowy: wybór strefy czasowej |
| Pogoda | Wyskakująca prognoza | Pełna pogoda jako powiadomienie | Środkowy: odśwież |
| Dźwięk | Panel dźwięku | Wyciszenie | Środkowy: panel · przewijanie: głośność |
| Mikrofon | Wyciszenie mikrofonu | — | Środkowy: panel dźwięku · przewijanie: głośność wejścia |
| Sieć | Panel sieci | — | — |
| Bluetooth | Panel Bluetooth | Przełączanie radia | — |
| Ekran | Panel ekranu | — | Przewijanie: jasność |
| Zasilanie | Panel zasilania | Przełączanie procentu baterii | — |
| Media | Odtwarzaj/pauza | Wyskakująca okładka | Środkowy: następny · przewijanie: poprzedni/następny |
| Agenci | Panel agentów | Uruchomienie swojego agenta | Środkowy: następna subskrypcja |
| Zasobnik | Najazd odsłania szufladę | Prawy na szewronie, żeby zarządzać | — |
| Aktualizacja Omarchy | Uruchomienie aktualizacji | — | — |

Nie wszystko w tej tabeli znajduje się na twoim pasku od razu. Widget mediów (odtwarzane teraz w MPRIS, z przewijanitym tytułem utworu i artystą) oraz widget mikrofonu są oba wbudowane, ale domyślnie wyłączone — dodaj je, jeśli ich chcesz, jak opisano niżej.

## Panele

Kliknięcie ikony na pasku otwiera panel, który jest porządnym wyskakującym oknem z suwakami, listami i nawigacją klawiaturową, a nie podpowiedzią. Każdy ma też skrót, więc nigdy nie musisz celować w glif o szerokości 16 pikseli:

| Skrót | Panel |
| --- | --- |
| `Super + Ctrl + A` | Dźwięk |
| `Super + Ctrl + W` | Sieć |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Ekran |
| `Super + Ctrl + P` | Zasilanie |
| `Super + Ctrl + Alt + D` | Kalendarz |
| `Super + Ctrl + Alt + E` | Zegar światowy |
| `Super + Ctrl + 1-9` | Przełączenie n-tego panelu w sekcji prawej |

Panele nie są tylko odczytami. To miejsca, w których faktycznie robisz swoją rzecz:

- **Dźwięk** ma główny suwak głośności, wybór urządzenia wyjściowego i mikser per aplikacja, więc możesz ściszyć tę jedną kartę przeglądarki, nie ruszając reszty.
- **Sieć** skanuje w poszukiwaniu Wi-Fi, pokazuje siłę sygnału, łączy i pozwala wybrać dostawcę DNS.
- **Bluetooth** listuje twoje urządzenia z opcjami łączenia/rozłączania i poziomami baterii.
- **Zasilanie** pokazuje statystyki baterii, przełącza profile zasilania (pamięta osobny wybór dla baterii i zasilania sieciowego) i wypisuje trochę informacji o systemie.
- **Ekran** ma suwak jasności, rozmiar tekstu, presety skalowania monitora oraz — gdy masz więcej niż jeden ekran — kontrolki per monitor. Dalszą opowieść znajdziesz w [monitory](33-monitors.md).
- **Zegar** otwiera miesięczną siatkę z numerami tygodni ISO i przełączaniem miesięcy.

Każdy panel obsługuje klawiaturę równie dobrze jak mysz: strzałki przesuwają, Return aktywuje, Tab przechodzi do sąsiedniego panelu, a Escape zamyka.

`Super + Ctrl + 1-9` liczy panele od lewej do prawej w sekcji prawej, pomijając zasobnik, bo nie ma własnego panelu. Numer odpowiada więc ikonie, w którą byś celował.

### Tailscale i Dropbox

Dwa kolejne widgety pojawiają się na pasku dopiero, gdy z **Instaluj → Usługa** zainstalujesz pasującą usługę, i oba warto znać, bo robią więcej niż tylko raportują status.

Panel **Tailscale** łączy i rozłącza tailnet, przełącza konta i wybiera węzeł wyjściowy (zarówno twoje własne maszyny, jak i regiony Mullvad pokazują się na tej liście). Przegląda też twoje maszyny — a gdy jedną wybierzesz, `s` wysyła do niej pliki przez Taildrop, co jest najszybszym sposobem na przeniesienie pliku na telefon lub inny laptop. `c` kopiuje adres IP maszyny, `n` jej nazwę, a `d` jej pełną nazwę DNS. Na każdym wierszu maszyny jest też przycisk wysyłki, jeśli wolisz klikać. To samo z terminala to `omarchy tailscale send <machine> [file...]`.

Panel **Dropbox** obsługuje logowanie, pokazuje, ile miejsca używasz, oraz listuje ostatnio zsynchronizowane pliki.

Usunięcie którejkolwiek usługi zdejmuje jej widget z powrotem z paska.

## Wskaźniki

Mała gromada pośrodku to widget wskaźników. To glify statusu dla trybów, które włączyłeś: nie przeszkadzać, światło nocne, zakolejkowane [przypomnienie](09-reminders.md), aktywne nagrywanie ekranu, nieusypianie oraz [dyktowanie](11-text-extraction-dictation.md). Zapalają się, gdy tryb jest aktywny, a w przeciwnym razie trzymają się z drogi — najedź na lewo od zegara (nad nim na pionowym pasku), żeby zerknąć na nieaktywne. Kliknięcie wskaźnika przełącza ten tryb. Jeszcze jeden jest tylko informacyjny: sesja zdalna świeci się na czerwono, gdy ktoś jest połączony z tą maszyną przez gliff.

Jeśli wolisz, żeby zawsze były widoczne, ustaw `alwaysShow` na `true` na tym widgecie. A jeśli zależy ci tylko na niektórych, wymień te, które chcesz, w `items`: `["Dnd", "Reminder", "NightLight"]`. Możesz mieć więcej niż jeden widget wskaźników, więc różne sekcje mogą pokazywać różne podzbiory.

## Przestawianie paska

Pasek konfiguruje się sam. Nie musisz otwierać pliku konfiguracyjnego, żeby coś przenieść.

Chwyć pusty obszar paska w pobliżu środka i przeciągnij go ku innej krawędzi ekranu, a pasek tam się przeniesie — lewa, prawa, górna i dolna działają wszystkie, a każdy widget się do tego dopasowuje (paski pionowe wracają do kompaktowych form tylko z ikonami). Kliknięcie i przytrzymanie zaczyna to samo przeciąganie. Kliknij dwukrotnie lewym przyciskiem tę samą pustą przestrzeń, żeby jako tło paska przechodzić od przezroczystego przez szklane do kryjącego. I przeciągnij każdy widget, żeby zmienić jego kolejność albo wrzucić go do innej sekcji.

Widget, który chcesz mieć pod ręką, ale nie zawsze na widoku, może trafić do szuflady zasobnika: przeciągnij go na zasobnik, a szuflada otworzy się, żeby go przyjąć. Siedzi tam za ikonami aplikacji, pokazuje się zawsze, gdy pokazuje się szuflada, i utrzymuje ją otwartą, dopóki jego panel jest otwarty. Przeciągnij go z powrotem na pasek, żeby go przywrócić.

Jeśli wolisz wybrać z menu, **Akcje → Wygląd → Pasek menu** ma położenie, a **Tło paska** wybiera, jak pasek jest rysowany: **Kryjący pasek**, **Szklany pasek** (prześwitujący, z rozmyciem tego, co jest za nim) albo **Przezroczysty pasek**.

Te same rzeczy mają polecenia, co jest potrzebne przy konfiguracji przez [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.clock --section center --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Aby dodać lub usunąć widget w całości, użyj poleceń wtyczek. `omarchy plugin list` wypisuje każdy widget znany powłoce wraz z jego identyfikatorem, a potem:

```bash
omarchy plugin enable omarchy.media --section center
omarchy plugin disable omarchy.weather
```

## Ukrywanie paska

`Super + Shift + Space` wyłącza pasek i włącza go z powrotem bez zabijania powłoki — panele i skróty działają dalej, po prostu odzyskujesz piksele. Jest to też w menu pod **Akcje → Wygląd → Pasek menu → Ukryj pasek**.

## Plik konfiguracyjny

Wszystko to przechowywane jest w `~/.config/omarchy/shell.json` pod kluczem `bar`. Oto przycięta wersja:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "centerAnchor": "omarchy.clock",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Każdy widget jest jednym wpisem w jednej z trzech tablic układu, a jego ustawienia siedzą w tym wpisie inline — nie ma osobnego pliku ustawień ani podobiektu `config`. `format` zegara, `formatAlt` (na co przechodzi prawy klik) i `verticalFormat` mieszkają tam wprost na `{ "id": "omarchy.clock" }`.

`centerAnchor` nazywa ten jeden widget środkowy, który jest przypinany do dokładnego środka ekranu, a pozostałe go flankują. Tak zegar pozostaje martwo pośrodku, nawet gdy pogoda i plakietka aktualizacji przychodzą i odchodzą. Ustaw go na pusty ciąg, a lista środkowa wyśrodkowuje się po prostu jako grupa.

Jedna zasada warta przyswojenia: **gdy masz już własny `shell.json`, jest on kanoniczny**. Dopóki niczego nie dostosujesz, powłoka czyta domyślny plik Omarchy. W chwili, gdy przeciągniesz widget, uruchomisz `omarchy bar` albo sam wyedytujesz plik, staje się on twój — nie ma głębokiego łączenia, więc nowe domyślne widgety z przyszłych wydań Omarchy nie pojawią się na twoim pasku automatycznie. `omarchy bar defaults` przywraca dostarczany układ, kiedy tylko chcesz czyste płótno.

Ten sam plik trzyma też twoje czasy bezczynności na poziomie głównym, poza kluczem `bar`: `idle.screensaver` i `idle.lock`, oba w sekundach od przejścia w stan bezczynności. Domyślny wygaszacz włącza się więc po 150 sekundach, a blokada po 300.
