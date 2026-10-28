# Monitory

Omarchy zakłada, że domyślnie pracujesz na wyświetlaczu klasy retina z obsługą skalowania 2x. Tego potrzebujesz, aby uzyskać te ładne, ostre fonty programistyczne. Właśnie do tego zoptymalizowana jest niemal każda nowa, premiumowa maszyna przenośna z ekranem o wysokiej rozdzielczości. Właśnie na takim wyświetlaczu chciałbyś pracować: 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) albo 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Ale jeśli nie używasz wyświetlacza o PPI wynoszącym 218 lub więcej, będziesz chciał zmienić ustawienia monitora. Na przykład, jeśli masz 27" lub 32" 4K, możesz użyć skalowania ułamkowego, otwierając `~/.config/hypr/monitors.lua` (przez _Setup > Monitors_ w menu Omarchy) i przechodząc na zalecenie dla tej kombinacji:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Jeśli używasz wyświetlacza 1080p lub 1440p, prawdopodobnie będziesz po prostu chciał używać skalowania 1x, więc możesz użyć:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Zmiany w `GDK_SCALE` dotyczą aplikacji uruchomionych po zmianie (a GTK respektuje tylko liczby całkowite, więc trzymaj ją na najbliższej liczbie całkowitej twojej skali monitora). Więc upewnij się, że zamkniesz okna, które po zmianie są za duże (albo zamknij wszystkie okna za pomocą `Ctrl + Alt + Del`!).

Możesz także szybko przechodzić przez główne współczynniki skalowania monitora (1x, 1.25x, 1.6x, 2x, 3x, 4x) za pomocą `Super + /`, aby przejść wyżej, oraz `Super + Alt + /`, aby przejść niżej, albo wybrać jeden z panelu monitora na górnym pasku. Zmieniają one tylko monitor, na którym jesteś skupiony, więc ekran laptopa i wyświetlacz zewnętrzny mogą mieć każdy własną skalę. Wybór jest zapisywany w `~/.config/hypr/monitors.lua` jako reguła `hl.monitor` dla tego monitora, więc przetrwa ponowne uruchomienie i ma pierwszeństwo przed `omarchy_monitor_scale`, która pozostaje skalą dla każdego monitora bez własnej reguły.

### Powiększanie lub pomniejszanie tekstu

Skalowanie monitora zmienia rozmiar wszystkiego. Jeśli chcesz tylko większy lub mniejszy _tekst_, jest do tego jedno pokrętło:

```
omarchy display text size 14
```

Przyjmuje ono rozmiar w pikselach od 9 do 20 i przesuwa powłokę Omarchy, aplikacje GTK i twój terminal razem, więc cały pulpit pozostaje w proporcji. Uruchom je bez argumentu, aby zobaczyć, na czym jesteś, oraz `omarchy display text size reset`, aby wrócić do wartości domyślnej. Foot jest jedynym maruderem: nie ma sposobu na ponowne wczytanie swojej konfiguracji, więc uruchomione terminale zachowują swój stary rozmiar, dopóki nie otworzysz nowego.

### Rozszerzanie i dublowanie ekranów laptopa

Gdy podłączysz zewnętrzny ekran do laptopa, wyświetlacz jest automatycznie rozszerzany. Ale możesz zamiast tego zmienić to na dublowanie za pomocą _Trigger > Hardware_ w menu Omarchy albo `Super + Ctrl + Alt + Delete`. Jest to szczególnie pomocne, jeśli tym zewnętrznym ekranem jest projektor, a chcesz coś pokazać podczas pracy.

Gdy rozszerzasz, zamknięcie pokrywy laptopa automatycznie wyłączy wewnętrzny ekran. Otwarcie pokrywy włączy go z powrotem. Możesz także kontrolować to ręcznie za pomocą _Trigger > Hardware_ w menu Omarchy albo `Super + Ctrl + Delete`.

### Rozmieszczanie wielu ekranów

Hyprland świetnie działa z wieloma ekranami. Przeczytaj więcej o tym, jak je rozmieścić, w [dokumentacji monitorów Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). W Omarchy trafiają one do `~/.config/hypr/monitors.lua` jako wpisy `hl.monitor` — plik jest dostarczany z zakomentowanymi przykładami przypinania konkretnego monitora do rozdzielczości, pozycji i rotacji.

Każdy monitor ma własne obszary robocze od 1 do 10, więc `Super + 1` zawsze oznacza pierwszy obszar roboczy monitora, na którym jesteś. Za kulisami Hyprland nadal numeruje obszary robocze we wszystkich monitorach: twój ekran laptopa (lub pierwszy monitor) otrzymuje 1–10, następny monitor 11–20 i tak dalej, a każdy monitor zachowuje swój blok za każdym razem, gdy go podłączysz. Używaj tych numerów, jeśli piszesz [zasady obszarów roboczych](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) lub zasady okien dla konkretnego monitora, więc obszar roboczy 12 jest drugim obszarem roboczym twojego drugiego monitora. `~/.local/state/omarchy/monitor-workspaces` wymienia, który blok ma każdy monitor.

Klawisze strzałek działają między monitorami, które mają wspólną krawędź w twoim układzie. Ekrany, które stykają się tylko w rogu albo mają między sobą przerwę, nie są sąsiadami, więc aby przejść między nimi, użyj `Ctrl + Alt + Tab`.

| Hotkey | Across monitors |
| --- | --- |
| `Super + Arrow` | Przenosi fokus na monitor po tej stronie, gdy w tym kierunku nie ma już żadnego okna |
| `Super + Shift + Arrow` | Zamienia się z oknem na monitorze po tej stronie |
| `Super + Alt + Arrow` | Przenosi okno do grupy na monitorze po tej stronie |
| `Super + Shift + Ctrl + Arrow` | Przenosi okno na monitor po tej stronie, na obszar roboczy, który on pokazuje |
| `Super + Shift + Alt + Arrow` | Przenosi obszar roboczy na monitor po tej stronie, zachowując jego numer, jeśli jest wolny |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Przenosi fokus na następny lub poprzedni monitor, niezależnie od układu |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Pozostają na monitorze, na którym jesteś |

Możesz także wypróbować [Hyprmon](https://github.com/erans/hyprmon/), jeśli chcesz TUI, które pomoże ci w rozmieszczaniu wielu ekranów.

### Sterowanie jasnością

Jasność monitora jest sterowana dedykowanymi klawiszami funkcyjnymi do zwiększania/zmniejszania jasności. Jeśli podczas naciskania ich przytrzymasz shift, przejdziesz do maksymalnej lub minimalnej jasności. Klawisze sterują wyświetlaczem, na którym jesteś skupiony, więc monitory zewnętrzne, które mówią w DDC/CI, są regulowane w ten sam sposób co ekran laptopa.

### Wyświetlacze Apple

Jeśli używasz wyświetlacza Apple, zwykłe klawisze jasności na klawiaturze również będą automatycznie działać, jeśli jesteś skupiony na wyświetlaczu Apple. Odbywa się to za pomocą polecenia `asdcontrol`.

Zauważ, że jeśli używasz wyświetlacza Apple 6K XDR, możesz zobaczyć ekran widmo na swojej liście `hyprctl monitors`. Możesz to wyłączyć czymś takim jak `hl.monitor({ output = "DP-2", disabled = true })` przez _Setup > Monitors_.

Na maszynach Intel powinieneś podłączać się do wyświetlaczy Apple za pomocą zwykłego kabla Thunderbolt. Na innych maszynach bez Thunderbolt zazwyczaj będziesz musiał użyć [kabla DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N), aby to działało.
