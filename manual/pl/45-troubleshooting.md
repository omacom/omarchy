# Rozwiązywanie problemów

### Aktualizacja zepsuła mi system!

Najpierw spróbuj [przywrócić system](47-system-snapshots.md) do wersji sprzed ostatniej aktualizacji. Jeśli to nie zadziała, użyj `omarchy-debug`, aby podzielić się swoim problemem na kanale #omarchy-help na Discordzie. A jeśli wszystko inne zawiedzie, możesz ponownie zainstalować domyślne konfiguracje i pakiety za pomocą `omarchy-reinstall`.

### Dlaczego niektóre aplikacje są tak duże na moim ekranie?

Omarchy zakłada ekran o wysokiej rozdzielczości w skali 2x, więc ustawia `GDK_SCALE` na 2, dopóki nie wybierzesz skali w panelu monitora. Jeśli masz ekran 1x, a aplikacje GTK lub X11 wychodzą za duże, wybierz dla niego 1x w panelu monitora albo dodaj `hl.env("GDK_SCALE", "1")` do `~/.config/hypr/monitors.lua` (a potem uruchom ponownie każdą aplikację, która jest za duża). Zobacz [rozdział podręcznika o monitorach](33-monitors.md).

W przypadku Spotify możesz użyć `Ctrl + Minus`, aby zmniejszyć interfejs (oraz `Ctrl + Plus`, aby go powiększyć).

### Dlaczego wszystkie moje skróty z klawiszem Super przestały działać?

Na niektórych laptopach ASUS ROG i TUF `Fn + Super` to łatwa do przeoczenia kombinacja, która przełącza sprzętową blokadę klawisza Windows (przeznaczoną do gier, żeby przez przypadek nie wyjść z gry). Nic na ekranie nie informuje, że to się stało. Gdy blokada jest włączona, Super nie emituje absolutnie nic — więc każdy skrót Omarchy używający Super po prostu przestaje działać i wygląda to tak, jakby zepsuł się Hyprland.

Naciśnij raz `Fn + Super`, zanim zaczniesz grzebać w `~/.config/hypr/`, a jeśli to nie przywróci Super, naciśnij tę kombinację ponownie, aby nie zostawić włączonej blokady. To nie jest Fn-lock, który zmienia jedynie działanie rzędu klawiszy funkcyjnych.

### Sieć Wi-Fi, Bluetooth, dźwięk lub touchpad właśnie przestały mi działać

Zanim uruchomisz system ponownie, spróbuj zrestartować tylko wadliwy podsystem. W menu Omarchy pozycja _Aktualizacja > Sprzęt_ zawiera Wi-Fi, Bluetooth, Dźwięk i Touchpad, a ponowne załadowanie jednego z nich rozwiązuje większość sytuacji typu „działało pięć minut temu” — zestaw słuchawkowy Bluetooth, który nie chce się ponownie połączyć, touchpad, który przestał działać po uśpieniu, dźwięk, który zniknął po odłączeniu monitora.

### Dlaczego moje głośniki zewnętrzne nie odtwarzają dźwięku?

Prawdopodobnie dlatego, że nie zostały ustawione jako główne wyjście. Kliknij ikonę głośnika po prawej stronie paska, a otworzy się wyskakujące okno głośności, w którym możesz wybrać urządzenie wyjściowe (i regulować głośność dla poszczególnych aplikacji).

### Głośniki mojego laptopa brzmią dziwnie

Na niektórych laptopach Omarchy automatycznie stosuje korekcję głośników, która poprawia pasmo przenoszenia wbudowanych głośników. Polecenie `omarchy audio tuning status` powie Ci, czy taka korekcja jest aktywna na Twojej maszynie, a `omarchy audio tuning off` wyłączy ją, jeśli wolisz słyszeć surowy dźwięk głośników.

### Dlaczego nie mogę zalogować się ani używać sudo przy użyciu swojego hasła?

Prawdopodobnie zbyt wiele razy wpisano błędne hasło i dostęp został zablokowany. Jeśli dzieje się to na ekranie blokady, możesz nacisnąć `CTRL + ALT + F2`, aby uruchomić nowy TTY, w którym zalogujesz się jako root, a następnie uruchomisz `faillock --reset --user [your-username]`. Spowoduje to usunięcie blokady i wszystko wróci do działania.

### Dlaczego nie pojawiają się monity autoryzacji 1Password dla 1Password SSH Agent / CLI?

Może się to zdarzyć z 2 powodów:

Aby pojawił się rozbudowany monit o zatwierdzenie, opcja Ustawienia > Zaawansowane > Używaj akceleracji sprzętowej musi być włączona. _Uwaga: Aby zaczęło to działać, wymagane jest ponowne uruchomienie._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Albo jeśli od uruchomienia systemu nie uruchomisz jeszcze 1Password, monit się nie pojawi.
