# Monitory

Omarchy domyślnie zakłada, że korzystasz z wyświetlacza klasy retina obsługującego skalowanie 2x. To właśnie tego potrzebujesz, żeby mieć te ładne, ostre czcionki programistyczne. To właśnie pod to zoptymalizowana jest niemal cała nowa gama laptopów premium z ekranami o wysokiej rozdzielczości. To właśnie tego chcesz używać na 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) albo 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Ale jeśli nie korzystasz z wyświetlacza o PPI wynoszącym 218 lub więcej, będziesz chcieć zmienić ustawienia monitora. Na przykład, jeśli masz monitor 27" lub 32" 4K, możesz wybrać dla niego skalowanie ułamkowe z panelu monitora na górnym pasku albo ustawić domyślną wartość dla każdego monitora, otwierając `~/.config/hypr/monitors.lua` i przechodząc na zalecenie dla tej kombinacji:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Jeśli używasz wyświetlacza 1080p lub 1440p, prawdopodobnie będziesz po prostu chcieć używać skalowania 1x, i to samo dotyczy aplikacji GTK i X11, więc możesz użyć:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Zmiany `GDK_SCALE` dotyczą aplikacji uruchomionych po wprowadzeniu zmiany (a GTK honoruje tylko liczby całkowite, więc utrzymuj ją na poziomie najbliższej liczby całkowitej skali twojego monitora). Upewnij się więc, że po zmianie zamkniesz te otwarte okna, które są za duże (albo zamknij wszystkie okna za pomocą `Ctrl + Alt + Del`!).

Możesz też szybko przechodzić przez główne współczynniki skalowania monitora (1x, 1.25x, 1.6x, 2x, 3x, 4x), używając `Super + /`, aby przejść wyżej, i `Super + Alt + /`, aby przejść niżej, albo wybrać jeden z nich z panelu monitora na górnym pasku. Zmieniają one tylko monitor, na którym masz fokus, więc ekran laptopa i wyświetlacz zewnętrzny mogą każdy mieć własną skalę. Panel ustawia też dla każdego monitora rozdzielczość, częstotliwość odświeżania i rotację. Twoje wybory są zapisywane dla tego fizycznego monitora w `~/.local/state/omarchy/monitors/settings`, więc przetrwają ponowne uruchomienie i podążą za monitorem do dowolnego portu lub stacji dokującej, do której podłączysz go następnym razem. Mają one pierwszeństwo przed każdą regułą dla tego samego monitora w `~/.config/hypr/monitors.lua`, którego Omarchy nigdy nie edytuje. Jeśli wolisz ustawiać monitory w całości w tym pliku, dodaj do niego `omarchy_monitor_panel_settings = false`, a zmiany z panelu będą obowiązywać tylko do momentu ponownego załadowania Hyprland. Ponieważ `GDK_SCALE` to jedna wartość dla wszystkich ekranów, wybrana skala ustawia ją na podstawie monitora o najniższej skali, więc aplikacje X11 wychodzą trochę za małe na gęstszym ekranie, zamiast za duże na tym drugim.

### Powiększanie lub pomniejszanie tekstu

Skalowanie monitora zmienia rozmiar wszystkiego. Jeśli chcesz większy lub mniejszy tylko _tekst_, jest do tego jedno pokrętło:

```
omarchy display text size 14
```

Przyjmuje ono rozmiar w pikselach od 9 do 20 i przesuwa powłokę Omarchy, aplikacje GTK i twój terminal razem, dzięki czemu cały pulpit zachowuje proporcje. Uruchom je bez argumentu, aby zobaczyć, gdzie jesteś, oraz `omarchy display text size reset`, aby wrócić do wartości domyślnej. Foot to jedyny maruder: nie ma sposobu na ponowne załadowanie swojej konfiguracji, więc uruchomione terminale zachowują stary rozmiar, dopóki nie otworzysz nowego.

### Rozszerzanie i klonowanie ekranów laptopa

Gdy podłączysz zewnętrzny ekran do laptopa, wyświetlacz zostanie automatycznie rozszerzony. Ale możesz zmienić to na klonowanie, używając _Trigger > Hardware_ w menu Omarchy albo `Super + Ctrl + Alt + Delete`. Jest to szczególnie pomocne, jeśli ten zewnętrzny ekran to projektor i chcesz coś pokazać, jednocześnie pracując.

Gdy używasz rozszerzania, zamknięcie pokrywy laptopa automatycznie wyłączy wewnętrzny ekran. Otwarcie pokrywy włączy go z powrotem. Możesz też sterować tym ręcznie, używając _Trigger > Hardware_ w menu Omarchy albo `Super + Ctrl + Delete`.

### Rozmieszczanie wielu ekranów

Hyprland świetnie działa z wieloma ekranami. Panel monitora na górnym pasku rysuje je tam, gdzie się znajdują: przeciągnij jeden do boku drugiego, aby przenieść go tam, a układ zostanie zapisany wraz z pozostałymi ustawieniami każdego monitora. W sprawie wszystkiego, czego panel nie obejmuje, przeczytaj więcej o tym, jak je rozmieścić, w [dokumentacji monitorów Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). W Omarchy trafiają one do `~/.config/hypr/monitors.lua` jako wpisy `hl.monitor` — plik jest dostarczany z zakomentowanymi przykładami dotyczącymi wyłączania monitora, trybów, których panel nie oferuje, koloru 10-bitowego oraz zmiennej częstotliwości odświeżania.

Każdy monitor ma własne obszary robocze od 1 do 10, więc `Super + 1` zawsze oznacza pierwszy obszar roboczy monitora, na którym jesteś. Za kulisami Hyprland nadal numeruje obszary robocze we wszystkich monitorach: ekran twojego laptopa (albo pierwszy monitor) dostaje 1–10, następny monitor 11–20 i tak dalej, a każdy monitor zachowuje swój blok za każdym razem, gdy go podłączysz. Używaj tych liczb, jeśli piszesz [reguły obszarów roboczych](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) albo reguły okien dla konkretnego monitora, więc obszar roboczy 12 to drugi obszar roboczy twojego drugiego monitora. `~/.local/state/omarchy/monitors/workspaces` wymienia, który blok ma każdy monitor.

Klawisze strzałek działają między monitorami, które w twoim układzie mają wspólną krawędź. Ekrany, które stykają się tylko w rogu albo między którymi jest przerwa, nie są sąsiadami, więc użyj `Ctrl + Alt + Tab`, aby przejść między nimi.

| Skrót klawiszowy | Między monitorami |
| --- | --- |
| `Super + Arrow` | Przenosi fokus na monitor po tej stronie, gdy w tym kierunku nie ma już żadnego okna |
| `Super + Shift + Arrow` | Zamienia się z oknem na monitorze po tej stronie |
| `Super + Alt + Arrow` | Przenosi okno do grupy na monitorze po tej stronie |
| `Super + Shift + Ctrl + Arrow` | Przenosi okno na monitor po tej stronie, na obszar roboczy, który on pokazuje |
| `Super + Shift + Alt + Arrow` | Przenosi obszar roboczy na monitor po tej stronie, zachowując jego numer, jeśli jest wolny |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Przenosi fokus na następny lub poprzedni monitor, niezależnie od układu |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Pozostają na monitorze, na którym jesteś |

Możesz też sprawdzić [Hyprmon](https://github.com/erans/hyprmon/), jeśli chcesz TUI, które pomoże ci w pozycjonowaniu wielu ekranów.

### Sterowanie jasnością

Jasnością monitora sterują dedykowane klawisze funkcyjne zwiększania/zmniejszania jasności. Jeśli podczas naciskania tych klawiszy przytrzymasz shift, przejdziesz do maksymalnej lub minimalnej jasności. Klawisze sterują wyświetlaczem, na którym masz fokus, więc monitory zewnętrzne obsługujące DDC/CI są regulowane w ten sam sposób co ekran laptopa.

### Wyświetlacze Apple

Jeśli używasz wyświetlacza Apple, zwykłe klawisze jasności na klawiaturze również będą automatycznie działać, jeśli masz fokus na wyświetlaczu Apple. Odbywa się to za pomocą polecenia `asdcontrol`.

Zauważ, że jeśli używasz wyświetlacza Apple 6K XDR, na liście `hyprctl monitors` możesz zobaczyć ekran widmo. Możesz to wyłączyć czymś takim jak `hl.monitor({ output = "DP-2", disabled = true })` w `~/.config/hypr/monitors.lua`.

Na maszynach Intel powinieneś podłączać się do wyświetlaczy Apple za pomocą zwykłego kabla Thunderbolt. Na innych maszynach bez Thunderbolt zazwyczaj będziesz musiał użyć [kabla DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N), aby to działało.
