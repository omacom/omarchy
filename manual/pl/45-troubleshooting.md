# Rozwiązywanie problemów

### Zepsułem system aktualizacją!

Najpierw spróbuj [przywrócić system](47-system-snapshots.md) do wersji sprzed ostatniej aktualizacji. Jeśli to nie zadziała, użyj `omarchy-debug`, aby podzielić się swoim problemem na kanale #omarchy-help na Discordzie. A jeśli wszystko inne zawiedzie, możesz ponownie zainstalować domyślne konfiguracje i pakiety za pomocą `omarchy-reinstall`.

### Dlaczego niektóre aplikacje są tak duże na moim ekranie?

Omarchy zakłada wyświetlacz o wysokiej rozdzielczości ze skalowaniem 2x, co wymaga ustawienia `GDK_SCALE` na 2 w `~/.config/hypr/monitors.lua`. Ale jeśli masz wyświetlacz 1x, możesz zmienić `local omarchy_gdk_scale = 2` na 1 (a następnie ponownie uruchomić każdą aplikację, która jest za duża). Zobacz [podręcznik dotyczący monitorów](33-monitors.md).

W Spotify możesz użyć `Ctrl + Minus`, aby zmniejszyć interfejs (i `Ctrl + Plus`, aby go powiększyć).

### Dlaczego wszystkie moje skróty z klawiszem Super przestały działać?

Na niektórych laptopach ASUS ROG i TUF `Fn + Super` to łatwa do przeoczenia kombinacja, która przełącza wbudowaną w firmware blokadę klawisza Windows (przeznaczoną do gier, żebyś przypadkiem nie wyszedł z gry). Nic na ekranie nie informuje Cię, że to się stało. Gdy blokada jest włączona, Super nie wysyła absolutnie nic — więc każdy skrót Omarchy, który używa Super, po prostu przestaje działać i wygląda to tak, jakby zepsuł się Hyprland.

Naciśnij `Fn + Super` raz, zanim zaczniesz grzebać w `~/.config/hypr/`, a jeśli to nie przywróci Super, naciśnij tę kombinację ponownie, żeby nie zostawić włączonej blokady. To nie jest Fn-lock, który zmienia tylko działanie rzędu klawiszy F.

### Moje Wi-Fi, Bluetooth, audio lub trackpad właśnie przestało działać

Zanim ponownie uruchomisz komputer, spróbuj osobno zrestartować wadliwy podsystem. _Update > Hardware_ w menu Omarchy zawiera Wi-Fi, Bluetooth, Audio i Trackpad, a ponowne załadowanie jednego z nich rozwiązuje większość sytuacji typu „działało jeszcze pięć minut temu” — słuchawki Bluetooth, które nie chcą się ponownie połączyć, trackpad, który przestał działać po uśpieniu, dźwięk, który zniknął, gdy odłączyłeś monitor.

### Dlaczego moje głośniki zewnętrzne nie grają?

Prawdopodobnie dlatego, że nie są ustawione jako główne wyjście. Kliknij ikonę głośnika po prawej stronie paska, a otworzy się wyskakujące okno głośności, w którym możesz wybrać urządzenie wyjściowe (i miksować też głośność poszczególnych aplikacji).

### Głośniki mojego laptopa brzmią dziwnie

Na niektórych laptopach Omarchy automatycznie stosuje dostrojenie głośników, które koryguje charakterystykę częstotliwościową wbudowanych głośników. `omarchy audio tuning status` powie Ci, czy takie dostrojenie jest aktywne na Twojej maszynie, a `omarchy audio tuning off` wyłączy je, jeśli wolisz słyszeć głośniki w surowym brzmieniu.

### Dlaczego nie mogę się zalogować ani użyć sudo przy użyciu mojego hasła?

Prawdopodobnie wpisałeś je błędnie zbyt wiele razy i zostałeś zablokowany. Jeśli dzieje się to na ekranie blokady, możesz nacisnąć `CTRL + ALT + F2`, aby uruchomić nowy TTY, w którym możesz zalogować się jako root, a następnie uruchomić `faillock --reset --user [your-username]`. To zresetuje blokadę i możesz działać dalej.

### Dlaczego nie pojawiają się monity autoryzacji 1Password dla 1Password SSH Agent / CLI?

Może się to zdarzać z 2 powodów:

Aby pojawił się rozbudowany monit zatwierdzania, opcja Settings > Advanced > Use Hardware Acceleration musi być włączona. _Uwaga: aby zaczęło to działać, wymagane jest ponowne uruchomienie._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Lub jeśli nie uruchomiłeś 1Password od czasu uruchomienia komputera, monit się nie pojawi.
