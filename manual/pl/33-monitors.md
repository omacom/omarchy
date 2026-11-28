# Monitory

Omarchy domyślnie zakłada, że pracujesz na wyświetlaczu klasy retina obsługującym skalowanie 2x. To właśnie jest potrzebne, aby uzyskać te ładne, ostre fonty programistyczne. To właśnie pod to zoptymalizowane są niemal wszystkie nowe laptopy premium z ekranami o wysokiej rozdzielczości. Właśnie tego chcesz używać z 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) albo 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Ale jeśli nie pracujesz na wyświetlaczu o PPI na poziomie 218 lub wyższym, będziesz chciał zmienić ustawienia monitora. Na przykład, jeśli masz monitor 4K o przekątnej 27" lub 32", możesz wybrać dla niego skalowanie ułamkowe z panelu monitora na górnym pasku albo ustawić wartość domyślną dla każdego monitora, otwierając `~/.config/hypr/monitors.lua` i przechodząc na zalecenie dla tej kombinacji:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Jeśli używasz wyświetlacza 1080p lub 1440p, prawdopodobnie będziesz po prostu chciał używać skalowania 1x, i to samo dotyczy aplikacji GTK i X11, więc możesz użyć:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Zmiany w `GDK_SCALE` dotyczą aplikacji uruchomionych po zmianie (a GTK honoruje tylko liczby całkowite, więc trzymaj ją na najbliższej liczbie całkowitej swojej skali monitora). Upewnij się więc, że zamkniesz okna, które po zmianie są za duże (albo zamknij wszystkie okna za pomocą `Ctrl + Alt + Del`!).

Możesz też szybko przechodzić krok po kroku przez główne współczynniki skalowania monitora (1x, 1.25x, 1.6x, 2x, 3x, 4x) za pomocą `Super + /`, aby przejść wyżej, i `Super + Alt + /`, aby przejść niżej, albo wybrać jeden z panelu monitora na górnym pasku. Zmieniają one tylko monitor, na którym jesteś skupiony, więc ekran laptopa i wyświetlacz zewnętrzny mogą mieć każdy własną skalę. Panel ustawia też dla każdego monitora rozdzielczość, częstotliwość odświeżania i obrót. Twoje wybory są zapisywane dla tego fizycznego monitora w `~/.local/state/omarchy/monitors/settings`, więc przetrwają ponowne uruchomienie i podążą za monitorem do dowolnego portu lub stacji dokującej, do której podłączysz go następnym razem. Mają one pierwszeństwo przed każdą regułą dla tego samego monitora w `~/.config/hypr/monitors.lua`, której Omarchy nigdy nie edytuje. Jeśli wolisz ustawiać monitory w całości w tym pliku, dodaj do niego `omarchy_monitor_panel_settings = false`, a zmiany z panelu będą obowiązywać tylko do momentu ponownego wczytania Hyprland. Ponieważ `GDK_SCALE` to jedna wartość dla wszystkich ekranów, wybrana skala ustawia ją na podstawie monitora o najniższej skali, więc aplikacje X11 wychodzą trochę za małe na gęstszym ekranie, zamiast za duże na tym drugim.

### Powiększanie lub zmniejszanie tekstu

Skalowanie monitora zmienia rozmiar wszystkiego. Jeśli chcesz tylko większy lub mniejszy _tekst_, jest do tego jedno pokrętło:

```
omarchy display text size 14
```

Przyjmuje to rozmiar w pikselach od 9 do 20 i porusza powłoką Omarchy, aplikacjami GTK i twoim terminalem razem, więc cały pulpit zachowuje proporcje. Uruchom to bez argumentu, aby zobaczyć, gdzie jesteś, i `omarchy display text size reset`, aby wrócić do wartości domyślnej. Foot to jedyny maruder: nie ma sposobu na ponowne wczytanie swojej konfiguracji, więc działające terminale zachowują stary rozmiar, dopóki nie otworzysz nowego.

### Rozszerzanie i dublowanie ekranów laptopa

Gdy podłączasz ekran zewnętrzny do laptopa, wyświetlacz jest automatycznie rozszerzany. Ale możesz to zmienić na dublowanie za pomocą _Rozszerz_ | _Duplikuj_ w panelu monitora na górnym pasku, _Trigger > Sprzęt_ w menu Omarchy, albo `Super + Ctrl + Alt + Delete`. Jest to szczególnie pomocne, jeśli ten ekran zewnętrzny to projektor i chcesz coś pokazać podczas pracy.

Gdy rozszerzasz, zamknięcie pokrywy laptopa automatycznie wyłączy ekran wewnętrzny. Otwarcie pokrywy włączy go z powrotem. Możesz też sterować tym ręcznie za pomocą _Trigger > Sprzęt_ w menu Omarchy albo `Super + Ctrl + Delete`.

Gdy laptop jest podłączony do zasilania, zamknięcie pokrywy nigdy go nie usypia, więc laptop w stacji dokującej pozostaje obudzony, nawet jeśli ekran zewnętrzny na chwilę się rozłączy. Przy braku podłączonego ekranu zewnętrznego zamknięcie pokrywy przy zasilaniu tylko go blokuje. Na baterii zamknięcie pokrywy jak zwykle usypia.

### Rozmieszczanie wielu ekranów

Hyprland świetnie działa z wieloma ekranami. Panel monitora na górnym pasku rysuje je tam, gdzie się znajdują: przeciągnij jeden do boku drugiego, aby przenieść go tam, a układ jest zapisywany razem z pozostałymi ustawieniami każdego monitora. Wszystko, czego panel nie obejmuje, znajdziesz w [dokumentacji monitorów Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). W Omarchy trafiają one do `~/.config/hypr/monitors.lua` jako wpisy `hl.monitor` — plik jest dostarczany ze skomentowanymi przykładami dotyczącymi pozostawiania monitora wyłączonego, trybów, których panel nie oferuje, koloru 10-bitowego i zmiennej częstotliwości odświeżania.

Każdy monitor ma własne przestrzenie robocze od 1 do 10, więc `Super + 1` zawsze oznacza pierwszą przestrzeń roboczą monitora, na którym jesteś. Za kulisami Hyprland nadal numeruje przestrzenie robocze we wszystkich monitorach: ekran laptopa (albo pierwszy monitor) otrzymuje 1–10, następny monitor 11–20 i tak dalej, a każdy monitor zachowuje swój blok za każdym razem, gdy go podłączasz. Używaj tych numerów, jeśli piszesz [reguły przestrzeni roboczych](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) lub reguły okien dla konkretnego monitora, więc przestrzeń robocza 12 to druga przestrzeń robocza twojego drugiego monitora. `~/.local/state/omarchy/monitors/workspaces` wypisuje, który blok ma każdy monitor.

Klawisze strzałek działają między monitorami, które mają wspólną krawędź w twoim układzie. Ekrany, które stykają się tylko w rogu albo mają między sobą przerwę, nie są sąsiadami, więc używaj `Ctrl + Alt + Tab`, aby przemieszczać się między nimi.

| Skrót klawiszowy | Między monitorami |
| --- | --- |
| `Super + Arrow` | Przenosi fokus na monitor po tej stronie, gdy nie ma już okna w tym kierunku |
| `Super + Shift + Arrow` | Zamienia się z oknem na monitorze po tej stronie |
| `Super + Alt + Arrow` | Przenosi okno do grupy na monitorze po tej stronie |
| `Super + Shift + Ctrl + Arrow` | Przenosi okno na monitor po tej stronie, na przestrzeń roboczą, którą on pokazuje |
| `Super + Shift + Alt + Arrow` | Przenosi przestrzeń roboczą na monitor po tej stronie, zachowując jej numer, jeśli jest wolny |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Przenosi fokus na następny lub poprzedni monitor, niezależnie od układu |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Pozostają na monitorze, na którym jesteś |

Możesz też sprawdzić [Hyprmon](https://github.com/erans/hyprmon/), jeśli chcesz TUI, które pomoże ci w pozycjonowaniu wielu ekranów.

### Sterowanie jasnością

Jasność monitora jest sterowana dedykowanymi klawiszami funkcyjnymi jasności w górę/w dół. Jeśli przytrzymasz Shift podczas naciskania ich, przejdziesz do maksymalnej lub minimalnej jasności. Klawisze sterują wyświetlaczem, na którym jesteś skupiony, więc monitory zewnętrzne obsługujące DDC/CI są regulowane w ten sam sposób co ekran laptopa.

### Wyświetlacze Apple

Jeśli używasz wyświetlacza Apple, zwykłe klawisze jasności na klawiaturze będą też działać automatycznie, jeśli jesteś skupiony na wyświetlaczu Apple. Odbywa się to za pomocą polecenia `asdcontrol`.

Zauważ, że jeśli używasz wyświetlacza Apple 6K XDR, możesz zobaczyć fantomowy ekran na liście `hyprctl monitors`. Możesz to wyłączyć czymś takim jak `hl.monitor({ output = "DP-2", disabled = true })` w `~/.config/hypr/monitors.lua`.

Na komputerach Intel powinieneś podłączać się do wyświetlaczy Apple za pomocą zwykłego kabla Thunderbolt. Na innych komputerach bez Thunderbolt zwykle będziesz musiał użyć [kabla DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N), aby to działało.
