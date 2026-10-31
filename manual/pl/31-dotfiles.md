# Dotfiles

Omarchy konfiguruje się głównie za pomocą tak zwanych plików dotfiles, które mieszkają w `~/.config`. Uznaje się je za twoje pliki, do twoich zmian. Pliki mieszkające w `/usr/share/omarchy` należą do samego Omarchy i nie majstruj przy nich. Jeśli musisz zmienić cokolwiek w `/usr/share/omarchy`, zamiast tego powinieneś nadpisać tę wartość w `~/.config`.

Najważniejsze pliki konfiguracyjne możesz edytować bezpośrednio z menu Omarchy (`Super + Space`), na przykład _Setup > Keybindings_, _Setup > Input_ i _Setup > Config > [file]_. Gdy zrobisz to w ten sposób, każdy proces, który wymaga ponownego uruchomienia po edycji konfiguracji, zostanie automatycznie uruchomiony ponownie po wyjściu z edytora (domyślnie Neovim — `:wq`, pamiętaj! — ale możesz to zmienić przez _Setup > Defaults > Editor_).

Oto lista najważniejszych plików w `~/.config` i tego, co kontrolują:

| Plik | Przeznaczenie |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Główna konfiguracja Hyprland. Wczytuje domyślne ustawienia Omarchy oraz twoje pliki nadpisujące wymienione poniżej. [Dowiedz się więcej o konfiguracjach Hyprland](https://wiki.hypr.land/Configuring/). |
| `~/.config/hypr/bindings.lua` | Twoje własne przypisania klawiszy i nadpisania ustawień domyślnych. |
| `~/.config/hypr/monitors.lua` | Ustawienia monitora, których nie obejmuje panel monitorów, takie jak obrót, dodatkowe tryby lub pozostawienie monitora wyłączonego. |
| `~/.config/hypr/input.lua` | Kontroluje układ klawiatury, ustawienia myszy i trackpada. |
| `~/.config/hypr/looknfeel.lua` | Kontroluje odstępy, obramowania, animacje i resztę wyglądu. |
| `~/.config/hypr/autostart.lua` | Kontroluje dodatkowe procesy uruchamiane wraz z sesją. |
| `~/.config/omarchy/shell.json` | Kontroluje powłokę Omarchy: położenie paska, układ i widżety, a także wygaszacz ekranu, blokadę i czasy bezczynności. |
| `~/.config/foot/foot.ini` | Kontroluje twój terminal (foot jest domyślny). |
| `~/.XCompose` | Definiuje twoje emoji szybkiego dostępu oraz autouzupełnianie imienia i nazwiska/adresu e-mail. Pamiętaj, aby po wprowadzeniu zmian uruchomić `omarchy-restart-xcompose`. |

Jeśli ostatecznie wprowadzisz dużo zmian, aby dostosować własną konfigurację, dobrym pomysłem jest wykonanie kopii zapasowej wszystkich tych plików dotfiles. [Stow to świetny sposób, aby to zrobić](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Uruchamianie własnych aplikacji wraz z sesją

Jeśli chcesz, aby coś uruchamiało się za każdym razem, gdy się logujesz — demon synchronizacji, aplikacja do czatu, twój własny skrypt — umieść to w `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Dzięki temu polecenie uruchamia się jako część sesji, więc jest porządnie sprzątane po wylogowaniu.

### Uruchamianie skryptów przy zdarzeniach systemowych

Omarchy odpala hooki w kilku momentach, a ty możesz podpiąć do nich własne skrypty. Mieszkają one w `~/.config/omarchy/hooks/<event>.d/`, po jednym katalogu na zdarzenie, a każdy plik wykonywalny w środku uruchamia się, gdy zdarzenie nastąpi:

| Zdarzenie | Kiedy się uruchamia |
| ----- | ------------ |
| `post-boot` | Zaraz po uruchomieniu pulpitu |
| `post-update` | Pod koniec `omarchy update`, po pakietach, migracjach i ponownych uruchomieniach usług, przed aktualizacją narzędzi mise |
| `pre-refresh-pacman` | Po tym, jak `omarchy refresh pacman` ponownie zsynchronizuje konfigurację pakietów, a przed aktualizacją pakietów; przełączenie kanału uruchamia go podczas tego samego kroku odświeżania |
| `theme-set` | Po zmianie motywu (nazwa motywu w `$1`) |
| `font-set` | Po zmianie czcionki (nazwa czcionki w `$1`) |
| `battery-low` | Gdy poziom baterii jest niski (procent w `$1`) |

Hook `pre-refresh-pacman` to miejsce, do którego należą niestandardowe repozytoria lub wiersze `IgnorePkg`, ponieważ uruchamia się przed transakcją pakietów. Oba hooki związane z aktualizacją działają jako twój użytkownik po tym, jak Omarchy wyczyści swoją zapamiętaną autoryzację sudo, więc hook korzystający z `sudo` potrzebuje własnej autoryzacji i może poprosić o twoje hasło.

Każdy z tych katalogów zawiera już plik `.sample` pokazujący kształt hooka — usuń `.sample` z nazwy, aby zaczął działać. Aby zainstalować skrypt napisany gdzie indziej, użyj `omarchy hook install post-boot ~/my-hook`, co skopiuje go na miejsce i uczyni wykonywalnym.

### Dodawanie własnych wpisów menu

Menu Omarchy (`Super + Space`) można rozszerzyć o własne wiersze, edytując `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Wpisy są kluczowane kropkowym id, a to id umieszcza je w drzewie, więc `personal` pojawia się w menu głównym, a `personal.notes` pojawia się wewnątrz niego:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Użyj ponownie istniejącego id, a nadpiszesz ten wiersz zamiast dodawać nowy. Plik jest dostarczany ze wszystkimi dostępnymi polami udokumentowanymi jako komentarze.

### Dodawanie własnych eksportów powłoki, funkcji i aliasów

Omarchy jest dostarczane z garścią ergonomicznych aliasów i pomocnych funkcji, ale bardzo często chce się dodać własne. Zarówno aliasy, funkcje, jak i eksporty powinieneś dodawać w `~/.bashrc`. Ten plik nie zostanie nadpisany podczas aktualizacji. Jeśli chcesz zmienić którekolwiek z domyślnych ustawień Omarchy, możesz je także bezpiecznie dodać tutaj.

### Ustawianie zmiennych środowiskowych dla pulpitu

Eksporty sesji pulpitu należą do `~/.config/uwsm/env.d/`. Pliki te działają przed uruchomieniem pulpitu, więc błąd powłoki może odesłać cię z powrotem na ekran logowania. Podczas ich edycji trzymaj otwarty działający terminal. Aby wyłączyć nadpisanie, przenieś je poza `env.d`. Zobacz [odzyskiwanie logowania](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen), jeśli zmiana uniemożliwia logowanie.

### Zmienianie wewnętrznych plików Omarchy

Słuchaj, to twój komputer. Możesz z nim robić, co chcesz, ale odradzałbym wprowadzanie zmian bezpośrednio w plikach w `/usr/share/omarchy`. Należą one do pakietu pacman Omarchy, więc twoje zmiany zostaną po prostu nadpisane przy następnej aktualizacji. Lepiej po prostu nadpisać wszystkie wartości domyślne, które ci się nie podobają, w folderze `~/.config/*`.

W ten sposób możesz zmienić niemal wszystko, na przykład domyślne przypisania klawiszy. Wystarczy edytować `~/.config/hypr/bindings.lua`, aby, powiedzmy, zastąpić [Obsidian](https://obsidian.md/) przez [Joplin](https://joplinapp.org/) (zainstaluj za pomocą `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` usuwa istniejące przypisanie przed dodaniem jego zamiennika. Przyjmuje te same argumenty co `o.bind`, w tym pomocniki uruchamiania i opcje przypisań. Użyj `o.bind`, aby dodać przypisanie, lub `hl.unbind`, aby usunąć je bez zastępowania.

Jeśli upierasz się przy grzebaniu w wewnętrznych plikach Omarchy, przełącz się na kanał dev przez _Update > Channel > Dev_. To łączy Omarchy z kopią roboczą git kodu źródłowego w `~/omarchy`, którą możesz swobodnie zmieniać do woli. Nikt tu nie będzie ci mówił, co masz robić!

### Resetowanie wszelkich zmian

Jeśli narobisz bałaganu w konfiguracjach, zawsze możesz przywrócić je do wartości domyślnych przez _Update > Config_ w menu Omarchy. Albo uruchamiając `omarchy reinstall configs`, aby zresetować wszystko.
