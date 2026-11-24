# Rozwiązywanie problemów

### Zepsułem system aktualizacją!

Najpierw spróbuj [przywrócić system](47-system-snapshots.md) do wersji sprzed ostatniej aktualizacji. Jeśli to nie zadziała, użyj `omarchy-debug`, aby podzielić się swoim problemem na #omarchy-help na Discordzie. A jeśli wszystko inne zawiedzie, możesz ponownie zainstalować domyślne konfiguracje i pakiety za pomocą `omarchy-reinstall`.

### Dlaczego niektóre aplikacje są tak duże na moim ekranie?

Omarchy zakłada ekran o wysokiej rozdzielczości ze skalowaniem 2x, więc ustawia `GDK_SCALE` na 2, dopóki nie wybierzesz skali w panelu monitora. Jeśli masz ekran 1x, a aplikacje GTK lub X11 wychodzą za duże, wybierz dla niego 1x w panelu monitora albo dodaj `hl.env("GDK_SCALE", "1")` do `~/.config/hypr/monitors.lua` (a potem uruchom ponownie każdą aplikację, która jest za duża). Zobacz [podręcznik o monitorach](33-monitors.md).

W Spotify możesz użyć `Ctrl + Minus`, aby zmniejszyć interfejs (oraz `Ctrl + Plus`, aby go powiększyć).

### Dlaczego wszystkie moje skróty z klawiszem Super przestały działać?

Na niektórych laptopach ASUS ROG i TUF `Fn + Super` to łatwy do przeoczenia skrót, który przełącza blokadę klawisza Windows w oprogramowaniu układowym (przeznaczoną do gier, żeby nie wyjść z gry przez przypadek). Nic na ekranie nie informuje Cię, że to się stało. Gdy blokada jest włączona, Super nie wysyła absolutnie nic — więc każdy skrót Omarchy, który używa Super, po prostu przestaje działać i wygląda to tak, jakby zepsuł się Hyprland.

Naciśnij `Fn + Super` raz, zanim zaczniesz grzebać w `~/.config/hypr/`, a jeśli to nie przywróci Super, naciśnij to ponownie, żeby nie zostawić włączonej blokady. To nie jest blokada Fn, która zmienia jedynie działanie rzędu klawiszy funkcyjnych.

### Moje Wi-Fi, Bluetooth, dźwięk lub trackpad właśnie przestały działać

Zanim uruchomisz komputer ponownie, spróbuj zrestartować sam wadliwy podsystem. _Update > Hardware_ w menu Omarchy zawiera Wi-Fi, Bluetooth, Audio i Trackpad, a ponowne załadowanie jednego z nich rozwiązuje większość sytuacji typu „działało pięć minut temu” — zestaw słuchawkowy Bluetooth, który nie chce się ponownie połączyć, trackpad, który przestał działać po uśpieniu, dźwięk, który zniknął, gdy odłączyłeś monitor.

### Dlaczego moje głośniki zewnętrzne nie grają?

Prawdopodobnie dlatego, że nie są ustawione jako główne wyjście. Kliknij ikonę głośnika po prawej stronie paska, a otworzy się wyskakujące okno głośności, w którym możesz wybrać urządzenie wyjściowe (i miksować też głośność poszczególnych aplikacji).

### Głośniki mojego laptopa brzmią dziwnie

Na niektórych laptopach Omarchy automatycznie stosuje strojenie głośników, które koryguje charakterystykę częstotliwościową wbudowanych głośników. `omarchy audio tuning status` powie Ci, czy jakieś strojenie jest aktywne na Twojej maszynie, a `omarchy audio tuning off` wyłączy je, jeśli wolisz słyszeć głośniki w surowej postaci.

### Dlaczego nie mogę zalogować się ani użyć sudo moim hasłem?

Prawdopodobnie wpisałeś je źle dziesięć razy i zostałeś zablokowany. Blokada znika sama po dwóch minutach. Jeśli nie możesz czekać, a dzieje się to na ekranie blokady, możesz nacisnąć `CTRL + ALT + F2`, aby uruchomić nowy TTY, w którym możesz zalogować się jako root, a następnie uruchomić `faillock --reset --user [your-username]`. To zresetuje blokadę i możesz działać dalej.

### Moje hasło jest akceptowane, ale wracam do ekranu logowania

Uszkodzony plik środowiska sesji może uniemożliwić uruchomienie pulpitu, nawet gdy Twoje hasło jest poprawne. Warto to sprawdzić zwłaszcza po edycji `~/.config/uwsm/env.d/`.

Naciśnij `Ctrl + Alt + F2`, zaloguj się swoją normalną nazwą użytkownika i hasłem oraz sprawdź dziennik użytkownika z bieżącego uruchomienia:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Poszukaj błędu wskazującego jeden z Twoich plików środowiska, na przykład `bad substitution`, tuż przed komunikatem, że nie znaleziono znacznika wyjścia środowiska. Przenieś ten plik poza `env.d`, zanim spróbujesz zalogować się ponownie. Na przykład, jeśli błąd wskazuje `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM pomija plik z błędem składni, ale błąd krytyczny, który pojawia się dopiero podczas działania pliku, jak `bad substitution`, nadal może uniemożliwić uruchomienie pulpitu. Przywrócenie migawki systemu nie naprawia tych plików, ponieważ `/home` nie jest przywracane.

Gdy już będziesz mógł się zalogować, napraw zapisaną kopię, zanim przeniesiesz ją z powrotem. `sh -n` wyłapuje błędy składni bez uruchamiania pliku, ale nie wyłapie każdego błędu, który występuje, gdy plik jest wczytywany. Podczas testowania zmian trzymaj otwarte działające okno terminala.

### Dlaczego nie pojawiają się moje monity autoryzacji 1Password dla 1Password SSH Agent / CLI?

Może się to zdarzyć z 2 powodów:

Aby pojawił się rozbudowany monit zatwierdzenia, opcja Settings > Advanced > Use Hardware Acceleration musi być włączona. _Uwaga: wymaga to ponownego uruchomienia komputera, aby zaczęło działać._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Albo jeśli nie uruchomiłeś 1Password od czasu uruchomienia komputera, monit się nie pojawi.
