# Monitory

Omarchy domyślnie zakłada, że pracujesz na wyświetlaczu klasy retina z obsługą 2x. Tego właśnie potrzebujesz, żeby mieć te ładne, ostre czcionki programistyczne. Do tego zoptymalizowana jest prawie cała gama nowych laptopów premium z ekranami o wysokiej rozdzielczości. Tego właśnie chciałbyś używać na 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) lub 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Jeśli jednak nie korzystasz z wyświetlacza o PPI wynoszącym 218 lub więcej, będziesz chciał zmienić ustawienia monitora. Na przykład jeśli masz 27" lub 32" 4K, możesz użyć skalowania ułamkowego, otwierając `~/.config/hypr/monitors.lua` (przez _Setup > Monitors_ w menu Omarchy) i przełączając się na zalecenie dla tej kombinacji:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Jeśli korzystasz z wyświetlacza 1080p lub 1440p, prawdopodobnie będziesz chciał po prostu użyć skalowania 1x, więc możesz użyć:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Zmiany w `GDK_SCALE` dotyczą aplikacji uruchomionych po zmianie (a GTK honoruje tylko liczby całkowite, więc trzymaj ją na najbliższej liczbie całkowitej twojej skali monitora). Upewnij się więc, że zamkniesz okna, które po zmianie są za duże (albo zamknij wszystkie okna za pomocą `Ctrl + Alt + Del`!).

Możesz też szybko przechodzić przez główne współczynniki skalowania monitora (1x, 1.25x, 1.6x, 2x, 3x, 4x), używając `Super + /`, żeby pójść wyżej, oraz `Super + Alt + /`, żeby pójść niżej. Przy domyślnej konfiguracji zmiany te przetrwają też ponowne uruchomienie.

### Powiększanie lub pomniejszanie tekstu

Skalowanie monitora zmienia rozmiar wszystkiego. Jeśli chcesz tylko większy lub mniejszy _tekst_, jest do tego jedno pokrętło:

```
omarchy display text size 14
```

Przyjmuje ono rozmiar w pikselach od 9 do 20 i porusza powłoką Omarchy, aplikacjami GTK i twoim terminalem razem, dzięki czemu cały pulpit zachowuje proporcje. Uruchom je bez argumentu, żeby zobaczyć, gdzie jesteś, oraz `omarchy display text size reset`, żeby wrócić do wartości domyślnej. Foot to jedyny maruder: nie ma sposobu na ponowne wczytanie swojej konfiguracji, więc uruchomione terminale zachowują stary rozmiar, dopóki nie otworzysz nowego.

### Rozszerzanie i dublowanie ekranów laptopa

Gdy podłączysz zewnętrzny ekran do laptopa, obraz zostanie automatycznie rozszerzony. Możesz jednak zmienić to na dublowanie, używając _Trigger > Hardware_ w menu Omarchy lub `Super + Ctrl + Alt + Delete`. Jest to szczególnie pomocne, jeśli ten zewnętrzny ekran to projektor, a ty chcesz coś pokazać podczas pracy.

Gdy rozszerzasz obraz, zamknięcie pokrywy laptopa automatycznie wyłączy wewnętrzny ekran. Otwarcie pokrywy włączy go z powrotem. Możesz też sterować tym ręcznie, używając _Trigger > Hardware_ w menu Omarchy lub `Super + Ctrl + Delete`.

### Rozmieszczanie wielu ekranów

Hyprland świetnie działa z wieloma ekranami. Przeczytaj więcej o tym, jak je rozmieścić, w [dokumentacji monitorów Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). W Omarchy trafiają one do `~/.config/hypr/monitors.lua` jako wpisy `hl.monitor` — plik zawiera zakomentowane przykłady przypinania konkretnego monitora do rozdzielczości, pozycji i obrotu.

Każdy monitor ma własne obszary robocze od 1 do 10, więc `Super + 1` zawsze oznacza pierwszy obszar roboczy monitora, na którym jesteś. Za kulisami Hyprland nadal numeruje obszary robocze na wszystkich monitorach: ekran twojego laptopa (lub pierwszy monitor) dostaje 1–10, następny monitor 11–20 i tak dalej, a każdy monitor zachowuje swój blok za każdym razem, gdy go podłączysz. Używaj tych numerów, jeśli piszesz [reguły obszarów roboczych](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) lub reguły okien dla konkretnego monitora, więc obszar roboczy 12 to drugi obszar roboczy twojego drugiego monitora. `~/.local/state/omarchy/monitor-workspaces` pokazuje, który blok ma każdy monitor.

Klawisze strzałek działają między monitorami, które mają wspólną krawędź w twoim układzie. Ekrany, które stykają się tylko w rogu lub między którymi jest przerwa, nie są sąsiadami, więc użyj `Ctrl + Alt + Tab`, żeby się między nimi przemieszczać.

| Hotkey | Między monitorami |
| --- | --- |
| `Super + Arrow` | Przenosi fokus na monitor po tej stronie, gdy w tym kierunku nie ma już żadnego okna |
| `Super + Shift + Arrow` | Zamienia się z oknem na monitorze po tej stronie |
| `Super + Alt + Arrow` | Przenosi okno do grupy na monitorze po tej stronie |
| `Super + Shift + Ctrl + Arrow` | Przenosi okno na monitor po tej stronie, na obszar roboczy, który on pokazuje |
| `Super + Shift + Alt + Arrow` | Przenosi obszar roboczy na monitor po tej stronie, zachowując jego numer, jeśli jest wolny |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Przenosi fokus na następny lub poprzedni monitor, niezależnie od układu |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Pozostają na monitorze, na którym jesteś |

Możesz też sprawdzić [Hyprmon](https://github.com/erans/hyprmon/), jeśli chcesz TUI, które pomoże ci w rozmieszczaniu wielu ekranów.

### Sterowanie jasnością

Jasnością monitora sterują dedykowane klawisze funkcyjne jasności w górę/w dół. Jeśli przytrzymasz shift podczas naciskania tych klawiszy, przejdziesz do maksymalnej lub minimalnej jasności. Klawisze sterują wyświetlaczem, na którym masz fokus, więc monitory zewnętrzne obsługujące DDC/CI są regulowane w ten sam sposób co ekran laptopa.

### Wyświetlacze Apple

Jeśli korzystasz z wyświetlacza Apple, zwykłe klawisze jasności na klawiaturze będą też automatycznie działać, jeśli masz fokus na wyświetlaczu Apple. Odbywa się to za pomocą polecenia `asdcontrol`.

Pamiętaj, że jeśli korzystasz z wyświetlacza Apple 6K XDR, możesz widzieć widmowy ekran na liście `hyprctl monitors`. Możesz go wyłączyć za pomocą czegoś w rodzaju `hl.monitor({ output = "DP-2", disabled = true })` poprzez _Setup > Monitors_.

Na maszynach Intel powinieneś podłączać się do wyświetlaczy Apple zwykłym kablem Thunderbolt. Na innych maszynach bez Thunderbolt zazwyczaj będziesz musiał użyć [kabla DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N), żeby to działało.
