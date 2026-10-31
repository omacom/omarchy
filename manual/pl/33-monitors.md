# Monitory

Omarchy domyślnie zakłada, że korzystasz z wyświetlacza klasy Retina z obsługą skalowania 2x. To właśnie tego potrzebujesz, żeby uzyskać te ładne, ostre fonty programistyczne. Właśnie do tego zoptymalizowana jest prawie cała nowa generacja laptopów premium z ekranami o wysokiej rozdzielczości. Właśnie to chcesz uruchomić na 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) lub 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Ale jeśli nie korzystasz z wyświetlacza o PPI 218 lub wyższym, będziesz chciał zmienić ustawienia monitora. Na przykład, jeśli masz 27" lub 32" 4K, możesz wybrać dla niego skalę ułamkową z panelu monitora na górnym pasku albo ustawić domyślną dla każdego monitora, otwierając `~/.config/hypr/monitors.lua` i przełączając się na rekomendację dla tej kombinacji:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Jeśli używasz wyświetlacza 1080p lub 1440p, prawdopodobnie będziesz chciał po prostu użyć skalowania 1x, i to samo dla aplikacji GTK i X11, więc możesz użyć:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Zmiany w `GDK_SCALE` dotyczą aplikacji uruchomionych po zmianie (a GTK honoruje tylko liczby całkowite, więc trzymaj to na najbliższej liczbie całkowitej twojej skali monitora). Więc upewnij się, że zamknąłeś okna, które po zmianie są za duże (albo zamknij wszystkie okna za pomocą `Ctrl + Alt + Del`!).

Możesz też szybko przechodzić przez główne współczynniki skalowania monitora (1x, 1.25x, 1.6x, 2x, 3x, 4x), używając `Super + /`, aby przejść wyżej, i `Super + Alt + /`, aby przejść niżej, albo wybrać jeden z panelu monitora na górnym pasku. Zmieniają one tylko monitor, na którym jesteś skupiony, więc ekran laptopa i wyświetlacz zewnętrzny mogą każdy mieć własną skalę. Panel ustawia też rozdzielczość każdego monitora. Twoje wybory są zapisywane dla tego fizycznego monitora w `~/.local/state/omarchy/monitors/settings`, więc przetrwają ponowne uruchomienie i podążą za monitorem do dowolnego portu lub stacji dokującej, do której podłączysz go następnym razem. Mają pierwszeństwo przed każdą regułą dla tego samego monitora w `~/.config/hypr/monitors.lua`, którego Omarchy nigdy nie edytuje. Ponieważ `GDK_SCALE` jest jedną wartością dla wszystkich ekranów, wybrana skala ustawia ją na podstawie monitora o najniższej skali, więc aplikacje X11 wyjdą trochę za małe na gęstszym ekranie, zamiast za duże na drugim.

### Powiększanie lub pomniejszanie tekstu

Skalowanie monitora zmienia rozmiar wszystkiego. Jeśli wszystko, czego chcesz, to większy lub mniejszy _tekst_, jest do tego jedno pokrętło:

```
omarchy display text size 14
```

Przyjmuje ono rozmiar w pikselach między 9 a 20 i przesuwa powłokę Omarchy, aplikacje GTK i twój terminal razem, więc cały pulpit zachowuje proporcje. Uruchom je bez argumentu, aby zobaczyć, gdzie jesteś, i `omarchy display text size reset`, aby wrócić do wartości domyślnej. Foot to jedyny maruder: nie ma sposobu na przeładowanie swojej konfiguracji, więc uruchomione terminale zachowują swój stary rozmiar, dopóki nie otworzysz nowego.

### Rozszerzanie i klonowanie ekranu laptopa

Gdy podłączasz zewnętrzny ekran do laptopa, wyświetlacz jest automatycznie rozszerzany. Ale możesz zmienić to na klonowanie, używając _Trigger > Hardware_ w menu Omarchy lub `Super + Ctrl + Alt + Delete`. Jest to szczególnie pomocne, jeśli ten zewnętrzny ekran to projektor i chcesz coś pokazać podczas pracy.

Gdy rozszerzasz, zamknięcie pokrywy laptopa automatycznie wyłączy ekran wewnętrzny. Otwarcie pokrywy włączy go z powrotem. Możesz też kontrolować to ręcznie, używając _Trigger > Hardware_ w menu Omarchy lub `Super + Ctrl + Delete`.

### Rozmieszczanie wielu ekranów

Hyprland działa świetnie z wieloma ekranami. Panel monitora na górnym pasku rysuje je tam, gdzie się znajdują: przeciągnij jeden do boku drugiego, aby przenieść go tam, a układ jest zapisywany wraz z pozostałymi ustawieniami każdego monitora. W przypadku wszystkiego, czego panel nie obejmuje, przeczytaj więcej o tym, jak je rozmieścić, w [dokumentacji monitorów Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). W Omarchy trafiają one do `~/.config/hypr/monitors.lua` jako wpisy `hl.monitor` — plik jest dostarczany z zakomentowanymi przykładami przypinania konkretnego monitora do rozdzielczości, pozycji i rotacji.

Każdy monitor ma własne obszary robocze od 1 do 10, więc `Super + 1` zawsze oznacza pierwszy obszar roboczy monitora, na którym jesteś. Za kulisami Hyprland nadal numeruje obszary robocze na wszystkich monitorach: ekran twojego laptopa (lub pierwszy monitor) dostaje 1–10, następny monitor 11–20 i tak dalej, a każdy monitor zachowuje swój blok za każdym razem, gdy go podłączasz. Używaj tych numerów, jeśli piszesz [zasady obszarów roboczych](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) lub zasady okien dla konkretnego monitora, więc obszar roboczy 12 to drugi obszar roboczy twojego drugiego monitora. `~/.local/state/omarchy/monitors/workspaces` wymienia, który blok ma każdy monitor.

Klawisze strzałek działają między monitorami, które współdzielą krawędź w twoim układzie. Ekrany, które stykają się tylko rogiem lub mają między sobą przerwę, nie są sąsiadami, więc użyj `Ctrl + Alt + Tab`, aby się między nimi przemieszczać.

| Skrót klawiszowy | Między monitorami |
| --- | --- |
| `Super + Arrow` | Przenosi fokus na monitor po tej stronie, gdy w tym kierunku nie ma już żadnego okna |
| `Super + Shift + Arrow` | Zamienia się z oknem na monitorze po tej stronie |
| `Super + Alt + Arrow` | Przenosi okno do grupy na monitorze po tej stronie |
| `Super + Shift + Ctrl + Arrow` | Przenosi okno na monitor po tej stronie, na obszar roboczy, który on pokazuje |
| `Super + Shift + Alt + Arrow` | Przenosi obszar roboczy na monitor po tej stronie, zachowując jego numer, jeśli jest wolny |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Przenosi fokus na następny lub poprzedni monitor, niezależnie od układu |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Pozostają na monitorze, na którym jesteś |

Możesz też sprawdzić [Hyprmon](https://github.com/erans/hyprmon/), jeśli chcesz TUI, które pomoże Ci w pozycjonowaniu wielu ekranów.

### Sterowanie jasnością

Jasność monitora jest kontrolowana dedykowanymi klawiszami funkcyjnymi do zwiększania/zmniejszania jasności. Jeśli przytrzymasz Shift podczas naciskania tych klawiszy, przejdziesz do maksymalnej lub minimalnej jasności. Klawisze kontrolują wyświetlacz, na którym jesteś skupiony, więc monitory zewnętrzne, które mówią w DDC/CI, są regulowane w ten sam sposób co ekran laptopa.

### Monitory Apple

Jeśli używasz wyświetlacza Apple, zwykłe klawisze jasności na klawiaturze będą również automatycznie działać, jeśli jesteś skupiony na wyświetlaczu Apple. Odbywa się to za pomocą polecenia `asdcontrol`.

Zauważ, że jeśli używasz wyświetlacza Apple 6K XDR, możesz zobaczyć widmowy ekran na swojej liście `hyprctl monitors`. Możesz to wyłączyć czymś takim jak `hl.monitor({ output = "DP-2", disabled = true })` w `~/.config/hypr/monitors.lua`.

Na maszynach Intel powinieneś podłączać się do wyświetlaczy Apple przy użyciu zwykłego kabla Thunderbolt. Na innych maszynach bez Thunderbolt zazwyczaj będziesz musiał użyć [DP + USB-A -> USB-C cable](https://www.amazon.com/dp/B0BNX7MS6N), aby to działało.
