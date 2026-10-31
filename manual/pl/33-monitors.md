# Monitory

Omarchy zakłada, że domyślnie korzystasz z wyświetlacza klasy retina obsługującego skalowanie 2x. Właśnie tego potrzebujesz, żeby mieć te ładne, ostre fonty programistyczne. Właśnie do tego zoptymalizowana jest niemal każda nowa, premiumowa matryca laptopowa o wysokiej rozdzielczości. Właśnie na takim wyświetlaczu chcesz pracować na 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) lub 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Ale jeśli nie korzystasz z wyświetlacza o PPI wynoszącym 218 lub więcej, będziesz chciał zmienić ustawienia monitora. Na przykład, jeśli masz 27" lub 32" 4K, możesz wybrać dla niego skalowanie ułamkowe z panelu monitora na górnym pasku albo ustawić domyślne skalowanie dla każdego monitora, otwierając `~/.config/hypr/monitors.lua` i przełączając się na rekomendację dla tej kombinacji:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Jeśli korzystasz z wyświetlacza 1080p lub 1440p, prawdopodobnie będziesz po prostu chciał użyć skalowania 1x, i tego samego dla aplikacji GTK i X11, więc możesz użyć:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Zmiany w `GDK_SCALE` dotyczą aplikacji uruchomionych po zmianie (a GTK honoruje tylko liczby całkowite, więc trzymaj ją na najbliższej liczbie całkowitej twojej skali monitora). Upewnij się więc, że po zmianie zamkniesz te okna, które masz za duże (albo zamknij wszystkie okna za pomocą `Ctrl + Alt + Del`!).

Możesz też szybko przechodzić przez główne współczynniki skalowania monitora (1x, 1.25x, 1.6x, 2x, 3x, 4x) za pomocą `Super + /`, aby przejść wyżej, i `Super + Alt + /`, aby przejść niżej, albo wybrać jeden z nich z panelu monitora na górnym pasku. Zmieniają one tylko monitor, na którym jesteś skupiony, więc ekran laptopa i wyświetlacz zewnętrzny mogą mieć każdy własną skalę. Panel ustawia też rozdzielczość każdego monitora. Twoje wybory są zapisywane dla tego fizycznego monitora w `~/.local/state/omarchy/monitors/settings`, więc przetrwają ponowne uruchomienie i podążają za monitorem do dowolnego portu lub stacji dokującej, do której zostanie on podłączony następnym razem. Mają one pierwszeństwo przed każdą regułą dla tego samego monitora w `~/.config/hypr/monitors.lua`, którego Omarchy nigdy nie edytuje. Jeśli wolisz ustawiać monitory w całości w tym pliku, dodaj do niego `omarchy_monitor_panel_settings = false`, a zmiany z panelu będą trwały tylko do momentu ponownego załadowania Hyprland. Ponieważ `GDK_SCALE` to jedna wartość dla wszystkich ekranów, wybrana skala ustawia ją na podstawie monitora o najniższej skali, więc aplikacje X11 wychodzą trochę za małe na gęstszym ekranie, zamiast za duże na drugim.

### Powiększanie lub pomniejszanie tekstu

Skalowanie monitora zmienia rozmiar wszystkiego. Jeśli chcesz tylko większy lub mniejszy _tekst_, jest do tego jedno pokrętło:

```
omarchy display text size 14
```

Przyjmuje ono rozmiar w pikselach od 9 do 20 i porusza razem powłoką Omarchy, aplikacjami GTK i twoim terminalem, więc cały pulpit zachowuje proporcje. Uruchom je bez argumentu, aby zobaczyć, gdzie jesteś, i `omarchy display text size reset`, aby wrócić do wartości domyślnej. Foot to jedyny maruder: nie ma sposobu na ponowne załadowanie swojej konfiguracji, więc uruchomione terminale zachowują stary rozmiar, dopóki nie otworzysz nowego.

### Rozszerzanie i dublowanie ekranów laptopa

Gdy podłączysz zewnętrzny ekran do laptopa, wyświetlacz zostanie automatycznie rozszerzony. Ale możesz zmienić to na dublowanie, używając _Trigger > Hardware_ w menu Omarchy lub `Super + Ctrl + Alt + Delete`. Jest to szczególnie pomocne, jeśli ten zewnętrzny ekran to projektor i chcesz coś pokazać, jednocześnie pracując.

Gdy rozszerzasz, zamknięcie pokrywy laptopa automatycznie wyłączy ekran wewnętrzny. Otwarcie pokrywy włączy go z powrotem. Możesz też sterować tym ręcznie, używając _Trigger > Hardware_ w menu Omarchy lub `Super + Ctrl + Delete`.

### Układanie wielu ekranów

Hyprland świetnie działa z wieloma ekranami. Panel monitora na górnym pasku rysuje je tam, gdzie się znajdują: przeciągnij jeden do boku drugiego, aby przenieść go tam, a układ zostanie zapisany wraz z pozostałymi ustawieniami każdego monitora. W przypadku wszystkiego, czego panel nie obejmuje, przeczytaj więcej o tym, jak je układać, w [dokumentacji monitorów Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). W Omarchy trafiają one do `~/.config/hypr/monitors.lua` jako wpisy `hl.monitor` — plik jest dostarczany ze skomentowanymi przykładami przypinania konkretnego monitora do rozdzielczości, pozycji i rotacji.

Każdy monitor ma własne obszary robocze od 1 do 10, więc `Super + 1` zawsze oznacza pierwszy obszar roboczy monitora, na którym jesteś. Za kulisami Hyprland nadal numeruje obszary robocze na wszystkich monitorach: twój ekran laptopa (lub pierwszy monitor) dostaje 1–10, następny monitor 11–20 i tak dalej, a każdy monitor zachowuje swój blok za każdym razem, gdy go podłączysz. Używaj tych liczb, jeśli piszesz [zasady obszarów roboczych](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) lub zasady okien dla konkretnego monitora, więc obszar roboczy 12 to drugi obszar roboczy twojego drugiego monitora. `~/.local/state/omarchy/monitors/workspaces` wymienia, który blok ma każdy monitor.

Klawisze strzałek działają na monitorach, które w twoim układzie mają wspólną krawędź. Ekrany, które stykają się tylko w rogu albo mają między sobą przerwę, nie są sąsiadami, więc użyj `Ctrl + Alt + Tab`, aby się między nimi przemieszczać.

| Skrót klawiszowy | Między monitorami |
| --- | --- |
| `Super + Arrow` | Przenosi fokus na monitor po tej stronie, gdy w tym kierunku nie ma już żadnego okna |
| `Super + Shift + Arrow` | Zamienia się z oknem na monitorze po tej stronie |
| `Super + Alt + Arrow` | Przenosi okno do grupy na monitorze po tej stronie |
| `Super + Shift + Ctrl + Arrow` | Przenosi okno na monitor po tej stronie, na obszar roboczy, który on pokazuje |
| `Super + Shift + Alt + Arrow` | Przenosi obszar roboczy na monitor po tej stronie, zachowując jego numer, jeśli jest wolny |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Przenosi fokus na następny lub poprzedni monitor, niezależnie od układu |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Pozostają na monitorze, na którym jesteś |

Możesz też sprawdzić [Hyprmon](https://github.com/erans/hyprmon/), jeśli chcesz TUI, który pomoże ci w pozycjonowaniu wielu ekranów.

### Sterowanie jasnością

Jasność monitora jest sterowana dedykowanymi klawiszami funkcyjnymi jasności w górę/w dół. Jeśli przytrzymasz shift podczas naciskania tych klawiszy, przejdziesz do maksymalnej lub minimalnej jasności. Klawisze sterują wyświetlaczem, na którym jesteś skupiony, więc monitory zewnętrzne obsługujące DDC/CI są regulowane w ten sam sposób co ekran laptopa.

### Wyświetlacze Apple

Jeśli korzystasz z wyświetlacza Apple, zwykłe klawisze jasności na klawiaturze również będą automatycznie działać, jeśli jesteś skupiony na wyświetlaczu Apple. Odbywa się to za pośrednictwem polecenia `asdcontrol`.

Zauważ, że jeśli korzystasz z wyświetlacza Apple 6K XDR, możesz zobaczyć widmowy ekran na liście `hyprctl monitors`. Możesz to wyłączyć za pomocą czegoś takiego jak `hl.monitor({ output = "DP-2", disabled = true })` w `~/.config/hypr/monitors.lua`.

Na komputerach Intel powinieneś podłączać się do wyświetlaczy Apple za pomocą zwykłego kabla Thunderbolt. Na innych komputerach bez Thunderbolt zazwyczaj będziesz musiał użyć [kabla DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N), aby to działało.
