# Monitory

Omarchy domyślnie zakłada, że działasz na wyświetlaczu klasy retina zdolnym do 2x. To jest to, czego potrzebujesz, aby uzyskać te ładne, ostre czcionki programistyczne. Do tego zoptymalizowane są prawie wszystkie nowe laptopy premium z ekranami o wysokiej rozdzielczości. To jest to, co chciałbyś uruchomić na 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) lub 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Ale jeśli nie używasz wyświetlacza o PPI 218 lub wyższym, będziesz chciał zmienić ustawienia monitora. Na przykład, jeśli masz 27" lub 32" 4K, możesz użyć skalowania ułamkowego, otwierając `~/.config/hypr/monitors.lua` (przez _Ustawienia > Monitory_ w menu Omarchy) i przełączając na zalecenie dla tego połączenia:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Jeśli używasz wyświetlacza 1080p lub 1440p, prawdopodobnie będziesz po prostu chciał użyć skalowania 1x, więc możesz użyć:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Zmiany `GDK_SCALE` dotyczą aplikacji uruchomionych po zmianie (a GTK honoruje tylko liczby całkowite, więc trzymaj je przy najbliższej liczbie całkowitej swojej skali monitora). Więc upewnij się, że zamkniesz okna, które masz i które są po zmianie przerośnięte (lub zamknij wszystkie okna za pomocą `Ctrl + Alt + Del`!).

Możesz również szybko przechodzić przez główne proporcje skalowania monitora (1x, 1.25x, 1.6x, 2x, 3x, 4x), używając `Super + /`, aby przejść wyżej, i `Super + Alt + /`, aby przejść niżej. Jeśli masz domyślną konfigurację, zmiany te przetrwają również po ponownym uruchomieniu.

### Powiększanie lub pomniejszanie tekstu

Skalowanie monitora zmienia rozmiar wszystkiego. Jeśli wszystko, czego chcesz, to większy lub mniejszy _tekst_, istnieje jedno pokrętło do tego:

```
omarchy display text size 14
```

Przyjmuje rozmiar w pikselach między 9 a 20 i przesuwa powłokę Omarchy, aplikacje GTK i twój terminal razem, więc cały pulpit pozostaje w proporcji. Uruchom to bez argumentu, aby zobaczyć, gdzie jesteś, i `omarchy display text size reset`, aby wrócić do domyślnego. Foot jest jedynym maruderem: nie ma sposobu na ponowne załadowanie swojej konfiguracji, więc działające terminale zachowują swój dawny rozmiar, dopóki nie otworzysz nowego.

### Rozszerzanie i dublowanie wyświetlaczy laptopa

Gdy podłączysz zewnętrzny ekran do laptopa, wyświetlacz jest automatycznie rozszerzany. Możesz jednak zmienić to na dublowanie, używając _Akcje > Sprzęt_ w menu Omarchy lub `Super + Ctrl + Alt + Delete`. Jest to szczególnie pomocne, jeśli ten zewnętrzny ekran jest projektorem i chcesz coś pokazać podczas pracy.

Gdy rozszerzasz, zamknięcie pokrywy laptopa automatycznie wyłączy ekran wewnętrzny. Otwarcie pokrywy włączy go ponownie. Możesz również kontrolować to ręcznie, używając _Akcje > Sprzęt_ w menu Omarchy lub `Super + Ctrl + Delete`.

### Rozmieszczanie wielu ekranów

Hyprland działa świetnie z wieloma ekranami. Przeczytaj więcej o tym, jak je rozmieścić, w [dokumentacji monitorów Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Możesz również [powiązać określone obszary robocze z określonymi monitorami](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/). W Omarchy te reguły trafiają do `~/.config/hypr/monitors.lua` jako wpisy `hl.monitor` — plik jest dostarczany z zakomentowanymi przykładami przypinania określonego monitora do rozdzielczości, pozycji i obrotu.

Możesz również sprawdzić [Hyprmon](https://github.com/erans/hyprmon/), jeśli chcesz TUI, które pomoże ci w pozycjonowaniu wielu ekranów.

### Kontrolowanie jasności

Jasność monitora jest kontrolowana przez dedykowane klawisze funkcyjne do zwiększania/zmniejszania jasności. Jeśli przytrzymasz shift podczas naciskania ich, przejdziesz do maksymalnej lub minimalnej jasności. Klawisze kontrolują wyświetlacz, na którym jesteś skupiony, więc monitory zewnętrzne, które mówią DDC/CI, są regulowane w ten sam sposób co ekran laptopa.

### Wyświetlacze Apple

Jeśli używasz wyświetlacza Apple, zwykłe klawisze jasności klawiatury będą również automatycznie działać, jeśli jesteś skupiony na wyświetlaczu Apple. Odbywa się to poprzez polecenie `asdcontrol`.

Zauważ, że jeśli używasz wyświetlacza Apple 6K XDR, możesz zobaczyć ekran widmo na liście `hyprctl monitors`. Możesz to wyłączyć za pomocą czegoś takiego jak `hl.monitor({ output = "DP-2", disabled = true })` przez _Ustawienia > Monitory_.

Na komputerach Intel powinieneś łączyć się z wyświetlaczami Apple za pomocą zwykłego kabla Thunderbolt. Na innych komputerach bez Thunderbolt zwykle będziesz musiał użyć [kabla DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N), aby to działało.
