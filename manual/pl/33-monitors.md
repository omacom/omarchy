# Monitory

Omarchy domyślnie zakłada, że korzystasz z wyświetlacza klasy retina obsługującego skalowanie 2x. To właśnie tego potrzebujesz, żeby mieć te przyjemne, ostre fonty programistyczne. To właśnie pod to zoptymalizowane są niemal wszystkie nowe laptopy premium z ekranami o wysokiej rozdzielczości. To właśnie na czymś takim zechcesz pracować na 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) lub 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Ale jeśli nie korzystasz z wyświetlacza o PPI wynoszącym 218 lub więcej, będziesz chciał zmienić ustawienia monitora. Na przykład jeśli masz monitor 4K o przekątnej 27" lub 32", możesz użyć skalowania ułamkowego, otwierając `~/.config/hypr/monitors.lua` (przez _Konfiguracja > Monitory_ w menu Omarchy) i przełączając się na zalecane ustawienia dla takiego zestawu:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Jeśli korzystasz z wyświetlacza 1080p lub 1440p, prawdopodobnie będziesz chciał po prostu użyć skalowania 1x, więc możesz użyć:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Zmiany w `GDK_SCALE` dotyczą aplikacji uruchomionych po wprowadzeniu zmiany (a GTK obsługuje tylko liczby całkowite, więc trzymaj się wartości najbliższej liczbie całkowitej swojego skalowania monitora). Pamiętaj więc, żeby po zmianie zamknąć okna, które są za duże (albo zamknij wszystkie okna za pomocą `Ctrl + Alt + Del`!).

Możesz też szybko przechodzić między głównymi współczynnikami skalowania monitora (1x, 1.25x, 1.6x, 2x, 3x, 4x), używając `Super + /`, żeby przejść wyżej, i `Super + Alt + /`, żeby przejść niżej, albo wybrać jeden z nich z panelu monitora na górnym pasku. Zmiany te dotyczą tylko monitora, na którym znajduje się fokus, więc ekran laptopa i wyświetlacz zewnętrzny mogą mieć każde własne skalowanie. Wybór jest zapisywany w `~/.config/hypr/monitors.lua` jako reguła `hl.monitor` dla danego monitora, więc przetrwa ponowne uruchomienie i ma pierwszeństwo przed `omarchy_monitor_scale`, które pozostaje skalowaniem dla każdego monitora niemającego własnej reguły. Ponieważ `GDK_SCALE` jest jedną wartością dla wszystkich ekranów, zmiany te ustawiają je na podstawie monitora o najniższym skalowaniu, więc aplikacje X11 wychodzą trochę za małe na gęstszym ekranie, zamiast za duże na drugim.

### Powiększanie lub pomniejszanie tekstu

Skalowanie monitora zmienia rozmiar wszystkiego. Jeśli chcesz tylko większy lub mniejszy _tekst_, jest do tego jedno ustawienie:

```
omarchy display text size 14
```

Przyjmuje rozmiar w pikselach od 9 do 20 i przesuwa razem powłokę Omarchy, aplikacje GTK oraz twój terminal, dzięki czemu cały pulpit zachowuje proporcje. Uruchom je bez argumentu, żeby zobaczyć, jak jest obecnie, a `omarchy display text size reset`, żeby wrócić do wartości domyślnej. Foot jest jedynym maruderem: nie ma sposobu na ponowne wczytanie swojej konfiguracji, więc uruchomione terminale zachowują stary rozmiar, dopóki nie otworzysz nowego.

### Rozszerzanie i dublowanie ekranu laptopa

Gdy podłączasz zewnętrzny ekran do laptopa, pulpit jest automatycznie rozszerzany. Możesz jednak zmienić to na dublowanie, używając _Wyzwalacz > Sprzęt_ w menu Omarchy lub `Super + Ctrl + Alt + Delete`. Jest to szczególnie pomocne, gdy tym zewnętrznym ekranem jest projektor, a chcesz coś pokazać podczas pracy.

Gdy korzystasz z rozszerzania, zamknięcie pokrywy laptopa automatycznie wyłączy wewnętrzny ekran. Otwarcie pokrywy włączy go z powrotem. Możesz też sterować tym ręcznie, używając _Wyzwalacz > Sprzęt_ w menu Omarchy lub `Super + Ctrl + Delete`.

### Rozmieszczanie wielu ekranów

Hyprland świetnie działa z wieloma ekranami. Więcej o tym, jak je rozmieścić, przeczytasz w [dokumentacji monitorów Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). W Omarchy trafiają one do `~/.config/hypr/monitors.lua` jako wpisy `hl.monitor` — plik zawiera zakomentowane przykłady przypinania konkretnego monitora do rozdzielczości, pozycji i obrotu.

Każdy monitor ma własne obszary robocze od 1 do 10, więc `Super + 1` zawsze oznacza pierwszy obszar roboczy monitora, na którym jesteś. Pod spodem Hyprland nadal numeruje obszary robocze na wszystkich monitorach: ekran laptopa (lub pierwszy monitor) dostaje 1–10, następny monitor 11–20 i tak dalej, a każdy monitor zachowuje swój blok przy każdym podłączeniu. Używaj tych numerów, jeśli piszesz [reguły obszarów roboczych](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) lub reguły okien dla konkretnego monitora, więc obszar roboczy 12 jest drugim obszarem roboczym twojego drugiego monitora. `~/.local/state/omarchy/monitor-workspaces` pokazuje, który blok ma każdy monitor.

Klawisze strzałek działają między monitorami, które mają wspólną krawędź w twoim układzie. Ekrany, które stykają się tylko rogiem albo między którymi jest przerwa, nie są sąsiadami, więc używaj `Ctrl + Alt + Tab`, żeby się między nimi przemieszczać.

| Skrót klawiszowy | Między monitorami |
| --- | --- |
| `Super + Arrow` | Przenosi fokus na monitor po tej stronie, gdy w tym kierunku nie ma już żadnego okna |
| `Super + Shift + Arrow` | Zamienia się z oknem na monitorze po tej stronie |
| `Super + Alt + Arrow` | Przenosi okno do grupy na monitorze po tej stronie |
| `Super + Shift + Ctrl + Arrow` | Przenosi okno na monitor po tej stronie, na obszar roboczy, który on wyświetla |
| `Super + Shift + Alt + Arrow` | Przenosi obszar roboczy na monitor po tej stronie, zachowując jego numer, jeśli jest wolny |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Przenosi fokus na następny lub poprzedni monitor, niezależnie od układu |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Pozostają na monitorze, na którym jesteś |

Możesz też sprawdzić [Hyprmon](https://github.com/erans/hyprmon/), jeśli chcesz TUI, które pomoże ci w rozmieszczaniu wielu ekranów.

### Regulacja jasności

Jasnością monitora sterują dedykowane klawisze funkcyjne do zwiększania i zmniejszania jasności. Jeśli przytrzymasz Shift podczas naciskania tych klawiszy, przejdziesz do maksymalnej lub minimalnej jasności. Klawisze sterują wyświetlaczem, na którym znajduje się fokus, więc monitory zewnętrzne komunikujące się przez DDC/CI są regulowane w ten sam sposób co ekran laptopa.

### Monitory Apple

Jeśli korzystasz z monitora Apple, zwykłe klawisze jasności na klawiaturze również będą działać automatycznie, o ile fokus znajduje się na monitorze Apple. Odbywa się to za pomocą polecenia `asdcontrol`.

Pamiętaj, że jeśli korzystasz z monitora Apple 6K XDR, na liście `hyprctl monitors` możesz zobaczyć widmowy ekran. Możesz go wyłączyć czymś takim jak `hl.monitor({ output = "DP-2", disabled = true })` przez _Konfiguracja > Monitory_.

W maszynach z procesorem Intel powinieneś podłączać monitory Apple zwykłym kablem Thunderbolt. W innych maszynach bez Thunderbolt zazwyczaj będziesz musiał użyć [kabla DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N), żeby to zadziałało.
