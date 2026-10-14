# Tworzenie własnego motywu

Własne motywy możesz dodawać do `~/.config/omarchy/themes`. Po prostu skopiuj jeden z istniejących jako bazę (zajrzyj do `/usr/share/omarchy/themes`), a potem dostosowuj do woli. O ile twój motyw jest w tym folderze, będzie dostępny w menu wyboru motywu.

Głównym plikiem, który musisz dostosować, jest `colors.toml`. Definiuje on zestaw kolorów, który jest potem używany do generowania konfiguracji dla terminala (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian i całej powłoki Omarchy (pasek menu, menu, powiadomienia, OSD i ekran blokady).

Możesz też użyć dołączonej aplikacji Aether, aby utworzyć nowy motyw, używając przyjemnego interfejsu graficznego do bawienia się kolorami i szukania teł. Po prostu uruchom ją z siatki aplikacji skrótem `Super + Alt + Space`.

### Co może zawierać zainstalowany motyw

Motyw, który sam napiszesz w `~/.config/omarchy/themes`, może zawierać, co chcesz — to twój komputer i twój plik, a Omarchy stosuje to wszystko.

Motyw, który instalujesz z cudzego repozytorium poleceniem `omarchy theme install`, zachowuje wszystko, co jest kolorem, a traci tę garść plików, które uruchamiałyby kod na twoim komputerze: każdy plik `.lua`, konfiguracje terminala (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) oraz `vscode.json`. Plik `hyprland.lua` motywu to Lua, którą twój kompozytor uruchamia przy logowaniu, konfiguracja terminala nazywa program, który twój terminal startuje, a `vscode.json` nazywa rozszerzenie VSCode do zainstalowania. Instalacja cudzego motywu powinna zmieniać to, jak wygląda twój pulpit, a nigdy to, co on uruchamia.

Wszystko inne nadal działa dokładnie tak, jak napisał to autor motywu — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, tła i podglądy są zachowywane. Tylko to, co odrzucono, jest regenerowane z `colors.toml` na twoim komputerze.

Omarchy rozróżnia te dwa przypadki po tym, czy motyw ma wewnątrz własne repozytorium git, czyli to, co zostawia po sobie `omarchy theme install`, gdy klonuje. Motyw, który sam napisałeś, pozostaje więc twój, a ten ściągnięty z internetu pozostaje kolorami.

### Tryb jasny

Jeśli tworzysz motyw trybu jasnego, ustaw `mode = "light"` na górze swojego `colors.toml`. Wtedy zostanie automatycznie sparowany z trybem jasnym dla wszystkich aplikacji. (Stary sposób polegający na wrzuceniu pustego pliku o nazwie `light.mode` do katalogu głównego motywu też nadal działa).

### Kolory ikon

Jeśli chcesz dopasować kolorystycznie ikony menedżera plików do swojego motywu, dodaj plik o nazwie `icons.theme` z nazwą zestawu ikon, którego chcesz użyć. Domyślnie dostępne opcje to: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Obraz odblokowywania

Motywy dostarczone z obrazami `unlock.png` i `preview-unlock.png` będą wymienione w _Styl > Odblokuj_. Twój `unlock.png` powinien być najlepiej przezroczystym plikiem png. A obraz podglądu możesz utworzyć poleceniem `omarchy plymouth preview`.

### Motywy dla aplikacji, których Omarchy nie obejmuje

Jeśli używasz aplikacji, której nie ma na tej liście, możesz sam nauczyć Omarchy, jak stosować do niej motyw, za pomocą szablonu. Umieść plik w `~/.config/omarchy/themed/` nazwany tak jak konfiguracja, którą generuje, plus rozszerzenie `.tpl`, i napisz konfigurację z `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` do `{{ color15 }}` oraz resztą palety jako symbolami zastępczymi. Za każdym razem, gdy przełączysz motyw, plik jest regenerowany kolorami tego motywu.

W tym folderze jest w pełni skomentowany plik `alacritty.toml.tpl.sample`, z którego możesz kopiować — wymienia każdą zmienną, której możesz użyć, oraz modyfikatory `_strip` i `_rgb` dla aplikacji, które chcą swoich kolorów bez `#` albo jako dziesiętnych wartości RGB. Twoje szablony mają pierwszeństwo przed szablonami Omarchy, więc możesz też użyć tego, aby nadpisać sposób, w jaki motyw jest stosowany do wbudowanej aplikacji.

### Dystrybucja własnego motywu

Jeśli chcesz dystrybuować swój motyw, aby inni mogli go używać, musisz umieścić go na publicznym serwerze git, takim jak GitHub. Wtedy ludzie będą mogli go zainstalować przez _Instaluj > Styl > Motyw_ w menu Omarchy, używając tego adresu URL. Zaleca się przestrzeganie konwencji nazewnictwa `omarchy-[themename]-theme`, bo motyw po zainstalowaniu będzie poprawnie pokazywany w menu wyboru motywu jako po prostu `[themename]`.

Ten pozostały `[themename]` staje się nazwą katalogu motywu, więc musi być taką, którą Omarchy może bezpiecznie przekazywać dalej: musi zaczynać się od litery, cyfry albo podkreślenia, a reszta może zawierać litery, cyfry, `.`, `_`, `+` i `-`. Wielkie litery są zamieniane na małe za ciebie, ale wszystko inne — spacja, cudzysłów, znak spoza alfabetu angielskiego — jest odrzucane w chwili instalacji, zamiast zamieniać się w nazwę katalogu. Więc `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` i `omarchy-c++-theme` instalują się bez problemu.

Pamiętaj, że po zainstalowaniu z repozytorium każdy dostarczony przez motyw plik `.lua`, konfiguracja terminala albo `vscode.json` jest odrzucany, więc nie buduj motywu wokół nich.

Swój motyw możesz dodać do [strony z dodatkowymi motywami](https://omarchy.org/themes/), wysyłając pull request do [repozytorium omarchy-site](https://github.com/omacom-io/omarchy-site).
