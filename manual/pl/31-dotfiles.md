# Dotfiles

Omarchy konfiguruje się przede wszystkim za pomocą tak zwanych dotfiles, które znajdują się w `~/.config`. Są one uznawane za twoje pliki, przeznaczone do twoich zmian. Pliki znajdujące się w `/usr/share/omarchy` należą do samego Omarchy i nie powinieneś przy nich grzebać. Jeśli musisz zmienić cokolwiek w `/usr/share/omarchy`, powinieneś zamiast tego nadpisać wartość w `~/.config`.

Kluczowe konfiguracje możesz edytować prosto z menu Omarchy (`Super + Space`), na przykład _Setup > Keybindings_, _Setup > Input_ oraz _Setup > Config > [file]_. Gdy robisz to w ten sposób, każdy proces, który wymaga ponownego uruchomienia po edycji konfiguracji, zostanie automatycznie uruchomiony ponownie po zamknięciu edytora (domyślnie Neovim — `:wq`, pamiętaj! — ale możesz to zmienić przez _Setup > Defaults > Editor_).

Oto lista kluczowych plików w `~/.config` i tego, czym sterują:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Główna konfiguracja Hyprland. Wczytuje domyślne ustawienia Omarchy oraz twoje pliki nadpisujące poniżej. [Dowiedz się więcej o konfiguracjach Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Twoje własne przypisania klawiszy oraz nadpisania wartości domyślnych. |
| `~/.config/hypr/monitors.lua` | Ustawienia monitora, których nie obejmuje panel monitorów, takie jak obrót, dodatkowe tryby lub pozostawienie monitora wyłączonego. |
| `~/.config/hypr/input.lua` | Steruje układem klawiatury, myszą i ustawieniami gładzika. |
| `~/.config/hypr/looknfeel.lua` | Steruje odstępami, ramkami, animacjami i resztą wyglądu. |
| `~/.config/hypr/autostart.lua` | Steruje dodatkowymi procesami uruchamianymi wraz z sesją. |
| `~/.config/omarchy/shell.json` | Steruje powłoką Omarchy: pozycją paska, układem i widżetami, a także czasami wygaszacza ekranu, blokady i bezczynności. |
| `~/.config/foot/foot.ini` | Steruje twoim terminalem (foot jest domyślny). |
| `~/.XCompose` | Definiuje twoje emoji szybkiego dostępu oraz autouzupełnianie imienia i adresu e-mail. Pamiętaj, aby po wprowadzeniu zmian uruchomić `omarchy-restart-xcompose`. |

Jeśli w końcu wprowadzisz wiele zmian, aby dostosować własną konfigurację, dobrym pomysłem jest wykonanie kopii zapasowej wszystkich tych dotfiles. [Stow to świetny sposób, aby to zrobić](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Uruchamianie własnych aplikacji wraz z sesją

Jeśli chcesz, aby coś uruchamiało się za każdym razem, gdy się logujesz — demon synchronizacji, aplikacja czatu, twój własny skrypt — umieść to w `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Uruchamia to polecenie jako część sesji, więc zostanie ono prawidłowo wyczyszczone, gdy wylogujesz się ponownie.

### Uruchamianie skryptów przy zdarzeniach systemowych

Omarchy wywołuje hooki w kilku momentach, a ty możesz podwiesić pod nie własne skrypty. Znajdują się one w `~/.config/omarchy/hooks/<event>.d/`, jeden katalog na zdarzenie, a każdy plik wykonywalny znajdujący się w środku uruchamia się, gdy wystąpi dane zdarzenie:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Zaraz po uruchomieniu pulpitu |
| `post-update` | Pod koniec `omarchy update`, po pakietach, migracjach i ponownych uruchomieniach usług, zanim zostaną zaktualizowane narzędzia mise |
| `pre-refresh-pacman` | Po tym, jak `omarchy refresh pacman` ponownie zsynchronizuje konfigurację pakietów, a zanim zaktualizuje pakiety; przełączenie kanału uruchamia go podczas tego samego kroku odświeżania |
| `theme-set` | Po zmianie motywu (nazwa motywu w `$1`) |
| `font-set` | Po zmianie czcionki (nazwa czcionki w `$1`) |
| `battery-low` | Gdy poziom baterii jest niski (wartość procentowa w `$1`) |

Hook `pre-refresh-pacman` to miejsce, do którego należą niestandardowe repozytoria lub linie `IgnorePkg`, ponieważ uruchamia się przed transakcją pakietów. Oba hooki związane z aktualizacją działają jako twój użytkownik po tym, jak Omarchy wyczyści swoją buforowaną autoryzację sudo, więc hook korzystający z `sudo` potrzebuje własnej autoryzacji i może poprosić cię o hasło.

Każdy z tych katalogów zawiera już plik `.sample` pokazujący kształt hooka — usuń `.sample` z nazwy, aby zaczął działać. Aby zainstalować skrypt, który napisałeś gdzie indziej, użyj `omarchy hook install post-boot ~/my-hook`, co kopiuje go w to miejsce i nadaje mu uprawnienia do wykonywania.

### Dodawanie własnych pozycji menu

Menu Omarchy (`Super + Space`) można rozszerzyć o własne wiersze, edytując `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Pozycje są kluczowane kropkowanym identyfikatorem, a identyfikator jest tym, co umieszcza je w drzewie, więc `personal` pojawia się w menu głównym, a `personal.notes` pojawia się wewnątrz niego:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Użyj ponownie istniejącego identyfikatora, a nadpiszesz ten wiersz zamiast dodawać nowy. Plik jest dostarczany ze wszystkimi dostępnymi polami udokumentowanymi w formie komentarzy.

### Dodawanie własnych eksportów powłoki, funkcji i aliasów

Omarchy jest dostarczane z mnóstwem ergonomicznych aliasów i pomocnych funkcji, ale bardzo często chcesz dodać własne. Zarówno aliasy, funkcje, jak i eksporty powinieneś dodawać w `~/.bashrc`. Ten plik nie zostanie nadpisany podczas aktualizacji. Jeśli chcesz zmienić którekolwiek z domyślnych ustawień Omarchy, możesz również bezpiecznie dodać je tutaj.

### Zmienianie wewnętrznych plików Omarchy

Słuchaj, to twój komputer. Możesz z nim robić, co chcesz, ale odradzałbym wprowadzanie zmian bezpośrednio w plikach w `/usr/share/omarchy`. Należą one do pakietu pacman Omarchy, więc twoje zmiany zostaną po prostu nadpisane przy następnej aktualizacji. Lepiej będzie, jeśli po prostu nadpiszesz wszelkie domyślne wartości, które ci się nie podobają, w folderze `~/.config/*`.

W ten sposób możesz zmienić niemal wszystko, na przykład domyślne przypisania klawiszy. Wystarczy edytować `~/.config/hypr/bindings.lua`, aby, powiedzmy, zastąpić [Obsidian](https://obsidian.md/) przez [Joplin](https://joplinapp.org/) (zainstaluj za pomocą `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` usuwa istniejące przypisanie przed dodaniem jego zamiennika. Przyjmuje te same argumenty co `o.bind`, w tym pomocniki uruchamiania i opcje przypisania. Użyj `o.bind`, aby dodać przypisanie, lub `hl.unbind`, aby usunąć je bez zastępowania.

Jeśli upierasz się przy grzebaniu w wewnętrznych plikach Omarchy, przełącz się na kanał dev przez _Update > Channel > Dev_. Łączy to Omarchy z kopią kodu źródłowego z git w `~/omarchy`, którą możesz swobodnie zmieniać do woli. Nikt tutaj nie będzie ci mówić, co masz robić!

### Resetowanie wszelkich zmian

Jeśli w końcu zrobisz bałagan w konfiguracjach, zawsze możesz przywrócić je do wartości domyślnych przez _Update > Config_ w menu Omarchy. Albo uruchamiając `omarchy reinstall configs`, aby zresetować wszystko.
