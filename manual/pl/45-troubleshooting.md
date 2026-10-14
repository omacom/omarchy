# Rozwiązywanie problemów

### Zepsułem system aktualizacją!

Najpierw spróbuj [wycofać system](47-system-snapshots.md) do wersji sprzed ostatniej aktualizacji. Jeśli to nie zadziała, użyj `omarchy-debug`, aby podzielić się swoim problemem na kanale #omarchy-help na Discordzie. A jeśli to wszystko zawiedzie, możesz ponownie zainstalować domyślne konfiguracje i pakiety poleceniem `omarchy-reinstall`.

### Dlaczego niektóre aplikacje są tak duże na moim wyświetlaczu?

Omarchy zakłada wyświetlacz o wysokiej rozdzielczości 2x, co wymaga ustawienia `GDK_SCALE` na 2 w `~/.config/hypr/monitors.lua`. Ale jeśli masz wyświetlacz 1x, możesz zmienić `local omarchy_gdk_scale = 2` na 1 (a potem zrestartować każdą zbyt dużą aplikację). Zobacz [podręcznik o monitorach](33-monitors.md).

W przypadku Spotify możesz użyć `Ctrl + Minus`, aby zmniejszyć interfejs (a `Ctrl + Plus`, aby go powiększyć).

### Moje Wi-Fi, Bluetooth, dźwięk albo gładzik właśnie przestały działać

Zanim zrestartujesz komputer, spróbuj zrestartować sam sprawiający problemy podsystem. _Aktualizuj > Sprzęt_ w menu Omarchy ma Wi-Fi, Bluetooth, Dźwięk i Gładzik, a ponowne załadowanie jednego z nich rozwiązuje większość sytuacji typu „przecież pięć minut temu działało” — słuchawki Bluetooth, które nie chcą się ponownie połączyć, gładzik, który przestał działać po wstrzymaniu, dźwięk, który zniknął po odłączeniu monitora.

### Dlaczego moje zewnętrzne głośniki nie grają?

Prawdopodobnie dlatego, że nie są ustawione jako główne wyjście. Kliknij ikonę głośnika po prawej stronie paska, a otworzy się wyskakujące okienko głośności, w którym możesz wybrać urządzenie wyjściowe (i miksować też głośność poszczególnych aplikacji).

### Głośniki mojego laptopa brzmią źle

Na niektórych laptopach Omarchy automatycznie stosuje strojenie głośników, które koryguje charakterystykę częstotliwościową wbudowanych głośników. `omarchy audio tuning status` mówi ci, czy jakieś jest aktywne na twoim komputerze, a `omarchy audio tuning off` je wyłącza, jeśli wolisz słyszeć głośniki bez korekcji.

### Dlaczego nie mogę zalogować się ani użyć sudo swoim hasłem?

Prawdopodobnie wpisałeś je źle zbyt wiele razy i zostałeś zablokowany. Jeśli dzieje się to na ekranie blokady, możesz nacisnąć `CTRL + ALT + F2`, aby uruchomić nowy TTY, w którym zalogujesz się jako root, a potem uruchomisz `faillock --reset --user [your-username]`. To zresetuje blokadę i możesz działać dalej.

### Dlaczego monity autoryzacji 1Password dla 1Password SSH Agent / CLI się nie pojawiają?

Może się to dziać z 2 powodów:

Aby pojawił się rozbudowany monit zatwierdzenia, w Settings > Advanced > Use Hardware Acceleration musi być włączona. _Uwaga: wymaga to restartu, aby zaczęło działać._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Albo jeśli nie uruchomiłeś 1Password od czasu rozruchu, monit się nie pojawi.
