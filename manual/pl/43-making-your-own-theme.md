# Tworzenie własnego motywu

Możesz dodać własne motywy do `~/.config/omarchy/themes`. Wystarczy skopiować jeden z istniejących jako bazę (zajrzyj do `/usr/share/omarchy/themes`), a potem dopasować go do swoich upodobań. Dopóki twój motyw znajduje się w tym folderze, będzie uwzględniony w menu wyboru motywu.

Głównym plikiem, który musisz dostosować, jest `colors.toml`. Definiuje on zestaw kolorów, który następnie służy do generowania konfiguracji dla terminala (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian oraz całej powłoki Omarchy (górny pasek, menu, powiadomienia, OSD i ekran blokady).

Możesz też użyć dołączonej aplikacji Aether, aby utworzyć nowy motyw za pomocą przyjemnego interfejsu GUI, pobawić się kolorami i wyszukać tła. Wystarczy uruchomić ją z siatki aplikacji za pomocą `Super + Alt + Space`.

### Co może zawierać zainstalowany motyw

Motyw, który sam napiszesz w `~/.config/omarchy/themes`, może zawierać, co tylko chcesz — to twój komputer i twój plik, a Omarchy zastosuje to wszystko.

Motyw, który instalujesz z cudzego repozytorium za pomocą `omarchy theme install`, zachowuje wszystko, co dotyczy kolorów, a traci garść plików, które uruchamiałyby kod na twoim komputerze: każdy plik `.lua`, konfiguracje terminala (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) oraz `vscode.json`. Plik `hyprland.lua` motywu to Lua, który twój kompozytor uruchamia przy logowaniu, konfiguracja terminala wskazuje program, który twój terminal uruchamia, a `vscode.json` wskazuje rozszerzenie VSCode do zainstalowania. Instalowanie czyjegoś motywu powinno zmieniać wygląd twojego pulpitu, nigdy to, co on uruchamia.

Wszystko inne nadal działa dokładnie tak, jak napisał to autor motywu — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, tła i podglądy są zachowywane. Tylko to, co zostało odrzucone, jest generowane na nowo z `colors.toml` na twoim komputerze.

Omarchy rozróżnia te dwa przypadki po tym, czy motyw ma wewnątrz własne repozytorium git, czyli to, co `omarchy theme install` zostawia po sklonowaniu. Dzięki temu motyw, który sam napisałeś, pozostaje twój, a ten ściągnięty z internetu pozostaje tylko kolorami.

### Tryb jasny

Jeśli tworzysz motyw w trybie jasnym, ustaw `mode = "light"` na górze swojego `colors.toml`. Wtedy zostanie on automatycznie sparowany z trybem jasnym dla wszystkich aplikacji. (Stary sposób, polegający na umieszczeniu pustego pliku o nazwie `light.mode` w katalogu głównym motywu, nadal też działa.)

### Kolory ikon

Jeśli chcesz dopasować kolory ikon menedżera plików do swojego motywu, dodaj plik o nazwie `icons.theme` z nazwą zestawu ikon, którego chcesz użyć. Domyślnie dostępne opcje to: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Obraz odblokowania

Motywy dostarczone z obrazami `unlock.png` i `preview-unlock.png` będą wymienione w sekcji _Wygląd > Odblokowanie_. Twój plik `unlock.png` powinien być najlepiej przezroczystym plikiem png. A obraz podglądu możesz utworzyć za pomocą `omarchy plymouth preview`.

### Motywy dla aplikacji, których Omarchy nie obejmuje

Jeśli używasz aplikacji, której nie ma na tej liście, możesz sam nauczyć Omarchy, jak stosować do niej motyw, za pomocą szablonu. Umieść plik w `~/.config/omarchy/themed/` nazwany tak jak konfiguracja, którą generuje, plus rozszerzenie `.tpl`, i napisz konfigurację, używając `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` do `{{ color15 }}` oraz pozostałej części palety jako symboli zastępczych. Przy każdej zmianie motywu plik jest generowany na nowo z kolorami tego motywu.

W tym folderze znajduje się w pełni skomentowany plik `alacritty.toml.tpl.sample`, z którego możesz kopiować — zawiera on listę wszystkich zmiennych, których możesz użyć, a także modyfikatory `_strip` i `_rgb` dla aplikacji, które chcą otrzymywać kolory bez `#` lub jako dziesiętne RGB. Twoje szablony mają pierwszeństwo przed szablonami Omarchy, więc możesz w ten sposób również zastąpić sposób stosowania motywu do wbudowanej aplikacji.

### Udostępnianie motywu

Jeśli chcesz udostępnić swój motyw, aby inni mogli z niego korzystać, musisz umieścić go na publicznym serwerze git, takim jak GitHub. Wtedy inni będą mogli zainstalować go za pomocą _Instalacja > Styl > Motyw_ w menu Omarchy, używając tego adresu URL. Zaleca się stosowanie konwencji nazewnictwa `omarchy-[themename]-theme`, ponieważ po instalacji motyw będzie poprawnie wyświetlany w menu wyboru motywu jako samo `[themename]`.

To pozostałe `[themename]` staje się nazwą katalogu motywu, więc musi to być nazwa, którą Omarchy może bezpiecznie przekazywać dalej: musi zaczynać się od litery, cyfry lub podkreślenia, a reszta może zawierać litery, cyfry, `.`, `_`, `+` i `-`. Wielkie litery są dla ciebie zamieniane na małe, ale wszystko inne — spacja, cudzysłów, znak spoza języka angielskiego — jest odrzucane podczas instalacji, zamiast zostać zamienione w nazwę katalogu. Tak więc `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` i `omarchy-c++-theme` instalują się bez problemu.

Pamiętaj, że po zainstalowaniu z repozytorium każdy dołączony do niego plik `.lua`, konfiguracja terminala lub `vscode.json` jest odrzucany, więc nie buduj motywu wokół nich.

Możesz dodać swój motyw do [strony z dodatkowymi motywami](https://omarchy.org/themes/), wysyłając pull request do [repozytorium omarchy-site](https://github.com/omacom-io/omarchy-site).
