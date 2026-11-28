# Dotfiles

Omarchy jest konfigurowane głównie za pośrednictwem tak zwanych plików dotfiles, które znajdują się w `~/.config`. Są one uznawane za Twoje pliki, przeznaczone do Twoich zmian. Pliki znajdujące się w `/usr/share/omarchy` należą do samego Omarchy i nie powinieneś przy nich grzebać. Jeśli musisz zmienić cokolwiek w `/usr/share/omarchy`, powinieneś zamiast tego nadpisać wartość w `~/.config`.

Kluczowe pliki konfiguracyjne można edytować bezpośrednio z menu Omarchy (`Super + Space`), na przykład _Setup > Keyboard > Keybindings_, _Setup > Input_ oraz _Setup > Config > [file]_. Gdy robisz to w ten sposób, każdy proces, który wymaga ponownego uruchomienia po edycji konfiguracji, zostanie automatycznie uruchomiony ponownie po zamknięciu edytora (domyślnie Neovim — `:wq`, pamiętaj! — ale możesz to zmienić w _Setup > Defaults > Editor_).

Oto lista kluczowych plików w `~/.config` i tego, czym sterują:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Główny plik konfiguracyjny Hyprland. Wczytuje domyślne ustawienia Omarchy oraz Twoje pliki nadpisujące wymienione poniżej. [Dowiedz się więcej o konfiguracji Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Twoje własne przypisania klawiszy oraz nadpisania wartości domyślnych. |
| `~/.config/hypr/monitors.lua` | Ustawienia monitora, których nie obejmuje panel monitorów, takie jak obrót, dodatkowe tryby lub pozostawienie monitora wyłączonego. |
| `~/.config/hypr/input.lua` | Steruje układem klawiatury, ustawieniami myszy i gładzika. |
| `~/.config/hypr/looknfeel.lua` | Steruje odstępami, obramowaniami, animacjami i resztą wyglądu. |
| `~/.config/hypr/autostart.lua` | Steruje dodatkowymi procesami uruchamianymi wraz z sesją. |
| `~/.config/omarchy/shell.json` | Steruje powłoką Omarchy: pozycją paska, układem i widżetami, a także czasami wygaszacza ekranu, blokady i bezczynności. |
| `~/.config/foot/foot.ini` | Steruje Twoim terminalem (foot jest domyślny). |
| `~/.XCompose` | Definiuje szybki dostęp do emoji oraz autouzupełnianie imienia i nazwiska oraz adresu e-mail. Pamiętaj, aby po wprowadzeniu zmian uruchomić `omarchy-restart-xcompose`. |

Jeśli wprowadzisz wiele zmian, aby dostosować własną konfigurację, warto wykonać kopię zapasową wszystkich tych plików dotfiles. [Stow to świetny sposób, aby to zrobić](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Uruchamianie własnych aplikacji wraz z sesją

Jeśli chcesz, aby coś uruchamiało się przy każdym logowaniu — demon synchronizacji, aplikacja czatu, Twój własny skrypt — umieść to w `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Uruchamia to polecenie jako część sesji, więc zostanie ono prawidłowo wyczyszczone po ponownym wylogowaniu.

### Uruchamianie skryptów przy zdarzeniach systemowych

Omarchy uruchamia hooki w kilku momentach, a Ty możesz podpiąć do nich własne skrypty. Znajdują się one w `~/.config/omarchy/hooks/<event>.d/`, jeden katalog na każde zdarzenie, a każdy plik w tym katalogu, którego nazwa nie kończy się na `.sample`, jest uruchamiany za pomocą bash, gdy wystąpi dane zdarzenie:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Zaraz po uruchomieniu pulpitu |
| `post-update` | Pod koniec `omarchy update`, po pakietach, migracjach i ponownym uruchomieniu usług, przed aktualizacją narzędzi mise |
| `pre-refresh-pacman` | Po ponownej synchronizacji konfiguracji pakietów przez `omarchy refresh pacman`, przed aktualizacją pakietów; przełączenie kanału uruchamia go podczas tego samego kroku odświeżania |
| `theme-set` | Po zmianie motywu (nazwa motywu w `$1`) |
| `font-set` | Po zmianie czcionki (nazwa czcionki w `$1`) |
| `battery-low` | Gdy poziom baterii jest niski (wartość procentowa w `$1`) |

Hook `pre-refresh-pacman` to miejsce, w którym powinny znajdować się niestandardowe repozytoria lub linie `IgnorePkg`, ponieważ jest uruchamiany przed transakcją pakietów. Oba działają jako Twój użytkownik. `post-update` działa, gdy autoryzacja sudo dla `omarchy update` jest jeszcze świeża, więc hook używający `sudo` nie poprosi Cię ponownie o hasło; `pre-refresh-pacman` działa zaraz po tym, jak `omarchy refresh pacman` samo użyło sudo.

Każdy z tych katalogów zawiera już plik `.sample` pokazujący kształt hooka — usuń `.sample` z nazwy, aby zaczął działać. Aby zainstalować skrypt napisany w innym miejscu, użyj `omarchy hook install post-boot ~/my-hook`, co skopiuje go tam i uczyni wykonywalnym.

### Dodawanie własnych wpisów menu

Menu Omarchy (`Super + Space`) można rozszerzyć o własne wiersze, edytując `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Wpisy są identyfikowane za pomocą kropkowego identyfikatora, a to właśnie identyfikator umieszcza je w drzewie, więc `personal` pojawia się w menu głównym, a `personal.notes` pojawia się wewnątrz niego:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Ponowne użycie istniejącego identyfikatora sprawi, że nadpiszesz ten wiersz zamiast dodać nowy. Plik jest dostarczany ze wszystkimi dostępnymi polami udokumentowanymi w formie komentarzy.

### Dodawanie własnych eksportów powłoki, funkcji i aliasów

Omarchy jest dostarczane z wieloma ergonomicznymi aliasami i pomocnymi funkcjami, ale bardzo często chcesz dodać własne. Zarówno aliasy, funkcje, jak i eksporty powinieneś dodawać w `~/.bashrc`. Ten plik nie zostanie nadpisany podczas aktualizacji. Jeśli chcesz zmienić którekolwiek z domyślnych ustawień Omarchy, możesz je również bezpiecznie dodać tutaj.

### Ustawianie zmiennych środowiskowych dla pulpitu

Eksporty sesji pulpitu należą do `~/.config/uwsm/env.d/`. Pliki te są uruchamiane przed startem pulpitu, więc błąd powłoki może odesłać Cię z powrotem do ekranu logowania. Podczas ich edycji miej otwarty działający terminal. Aby wyłączyć nadpisanie, przenieś je poza `env.d`. Zobacz [odzyskiwanie logowania](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen), jeśli zmiana uniemożliwia logowanie.

### Zmienianie wewnętrznych plików Omarchy

Słuchaj, to Twój komputer. Możesz z nim robić, co tylko chcesz, ale odradzałbym wprowadzanie zmian bezpośrednio w plikach w `/usr/share/omarchy`. Należą one do pakietu pacman Omarchy, więc Twoje zmiany zostaną po prostu nadpisane przy następnej aktualizacji. Lepiej po prostu nadpisać wszelkie wartości domyślne, które Ci się nie podobają, w folderze `~/.config/*`.

W ten sposób możesz zmienić niemal wszystko, na przykład domyślne przypisania klawiszy. Wystarczy edytować `~/.config/hypr/bindings.lua`, aby, powiedzmy, zastąpić [Obsidian](https://obsidian.md/) przez [Joplin](https://joplinapp.org/) (zainstaluj za pomocą `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` usuwa istniejące przypisanie przed dodaniem jego zamiennika. Przyjmuje te same argumenty co `o.bind`, w tym pomocniki uruchamiania i opcje przypisań. Użyj `o.bind`, aby dodać przypisanie, lub `hl.unbind`, aby usunąć je bez zastępowania.

Jeśli upierasz się przy grzebaniu w wewnętrznych plikach Omarchy, przełącz się na kanał dev za pomocą _Update > Channel > Dev_. Spowoduje to powiązanie Omarchy z kopią git kodu źródłowego w `~/omarchy`, którą możesz zmieniać do woli. Nikt tu nie będzie Ci mówił, co masz robić!

### Resetowanie wszelkich zmian

Jeśli narobisz bałaganu w konfiguracjach, zawsze możesz przywrócić je do wartości domyślnych za pomocą _Update > Config_ w menu Omarchy. Albo uruchamiając `omarchy reinstall configs`, aby zresetować wszystko.
