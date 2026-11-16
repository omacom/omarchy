# Rozwiązywanie problemów

### Zepsułem system aktualizacją!

Najpierw spróbuj [przywrócić system](47-system-snapshots.md) do wersji sprzed ostatniej aktualizacji. Jeśli to nie zadziała, użyj `omarchy-debug`, aby podzielić się swoim problemem na #omarchy-help na Discord. A jeśli to wszystko zawiedzie, możesz ponownie zainstalować domyślne konfiguracje i pakiety za pomocą `omarchy-reinstall`.

### Dlaczego niektóre aplikacje są tak duże na moim ekranie?

Omarchy zakłada wyświetlacz o wysokiej rozdzielczości w skali 2x, więc ustawia `GDK_SCALE` na 2, dopóki nie wybierzesz skali w panelu monitora. Jeśli masz wyświetlacz 1x, a aplikacje GTK lub X11 wychodzą za duże, wybierz dla niego 1x w panelu monitora albo dodaj `hl.env("GDK_SCALE", "1")` do `~/.config/hypr/monitors.lua` (a potem uruchom ponownie każdą aplikację, która jest za duża). Zobacz [podręcznik dotyczący monitorów](33-monitors.md).

W Spotify możesz użyć `Ctrl + Minus`, aby zmniejszyć interfejs (oraz `Ctrl + Plus`, aby go powiększyć).

### Dlaczego wszystkie moje skróty z klawiszem Super przestały działać?

Na niektórych laptopach ASUS ROG i TUF `Fn + Super` to łatwy do przeoczenia skrót, który przełącza blokadę klawisza Windows na poziomie firmware (przeznaczoną do gier, żebyś przypadkiem nie wyszedł z gry). Nic na ekranie nie informuje, że to się stało. Gdy blokada jest włączona, Super nie emituje absolutnie nic — więc każdy skrót Omarchy używający Super po prostu przestaje działać i wygląda to tak, jakby zepsuł się Hyprland.

Naciśnij `Fn + Super` raz, zanim zaczniesz grzebać w `~/.config/hypr/`, a jeśli to nie przywróci Super, naciśnij to ponownie, żeby nie zostawić włączonej blokady. To nie jest Fn-lock, który zmienia tylko działanie rzędu klawiszy F.

### Moje Wi-Fi, Bluetooth, audio albo trackpad właśnie przestało działać

Zanim zrestartujesz komputer, spróbuj zrestartować sam sprawiający problemy podsystem. _Update > Hardware_ w menu Omarchy zawiera Wi-Fi, Bluetooth, Audio i Trackpad, a ponowne załadowanie jednego z nich rozwiązuje większość sytuacji typu „działało pięć minut temu” — zestaw słuchawkowy Bluetooth, który nie chce się ponownie połączyć, trackpad, który przestał działać po uśpieniu, dźwięk, który zniknął po odłączeniu monitora.

### Dlaczego moje głośniki zewnętrzne nie grają?

Prawdopodobnie dlatego, że nie są ustawione jako główne wyjście. Kliknij ikonę głośnika po prawej stronie paska, a otworzy się wyskakujące okno głośności, w którym możesz wybrać urządzenie wyjściowe (i miksować głośność poszczególnych aplikacji).

### Głośniki w moim laptopie brzmią nie tak, jak powinny

Na niektórych laptopach Omarchy automatycznie stosuje strojenie głośników, które koryguje charakterystykę częstotliwościową wbudowanych głośników. `omarchy audio tuning status` powie Ci, czy jest ono aktywne na Twojej maszynie, a `omarchy audio tuning off` je wyłączy, jeśli wolisz słyszeć głośniki bez korekty.

### Dlaczego nie mogę zalogować się ani użyć sudo swoim hasłem?

Prawdopodobnie wpisałeś je źle zbyt wiele razy i zostałeś zablokowany. Jeśli dzieje się to na ekranie blokady, możesz nacisnąć `CTRL + ALT + F2`, aby uruchomić nowe TTY, w którym zalogujesz się jako root, a następnie uruchomisz `faillock --reset --user [your-username]`. To zresetuje blokadę i możesz działać dalej.

### Hasło jest akceptowane, ale wracam do ekranu logowania

Uszkodzony plik środowiska sesji może uniemożliwić uruchomienie pulpitu, nawet gdy hasło jest poprawne. Warto to sprawdzić zwłaszcza po edycji `~/.config/uwsm/env.d/`.

Naciśnij `Ctrl + Alt + F2`, zaloguj się swoją zwykłą nazwą użytkownika i hasłem oraz sprawdź dziennik użytkownika z bieżącego uruchomienia:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Szukaj błędu wskazującego jeden z Twoich plików środowiska, np. `bad substitution`, tuż przed komunikatem, że nie znaleziono znacznika wyjścia env. Przenieś ten plik poza `env.d`, zanim spróbujesz zalogować się ponownie. Na przykład, jeśli błąd wskazuje `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM pomija plik z błędem składni, ale błąd krytyczny, który ujawnia się dopiero podczas działania pliku, taki jak `bad substitution`, nadal może uniemożliwić uruchomienie pulpitu. Przywrócenie migawki systemu nie naprawi tych plików, ponieważ `/home` nie jest przywracane.

Gdy już będziesz mógł się zalogować, napraw zapisaną kopię, zanim przeniesiesz ją z powrotem. `sh -n` wyłapuje błędy składni bez uruchamiania pliku, ale nie wyłapie każdego błędu, który występuje podczas jego wczytywania. Podczas testowania zmian trzymaj otwarty działający terminal.

### Dlaczego nie pojawiają się moje monity autoryzacji 1Password dla 1Password SSH Agent / CLI?

Może się to zdarzać z 2 powodów:

Aby pojawiał się rozbudowany monit zatwierdzania, opcja Settings > Advanced > Use Hardware Acceleration musi być włączona. _Uwaga: wymaga to ponownego uruchomienia, aby zaczęło działać._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Albo jeśli nie uruchomiłeś 1Password od czasu uruchomienia komputera, monit się nie pojawi.
