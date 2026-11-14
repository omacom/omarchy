# Tworzenie własnego motywu

Możesz dodać własne motywy do `~/.config/omarchy/themes`. Po prostu skopiuj jeden z istniejących jako bazę (zajrzyj do `/usr/share/omarchy/themes`), a potem dostosuj go do woli. Dopóki twój motyw znajduje się w tym folderze, będzie uwzględniony w menu wyboru motywu.

Głównym plikiem, który musisz dostosować, jest `colors.toml`. Definiuje on zestaw kolorów, który jest następnie używany do generowania konfiguracji dla terminala (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian oraz całej powłoki Omarchy (górny pasek, menu, powiadomienia, OSD i ekran blokady).

Możesz też użyć dołączonej aplikacji Aether, aby utworzyć nowy motyw za pomocą przyjemnego interfejsu GUI, w którym pobawisz się kolorami i wyszukasz tła. Po prostu uruchom ją z siatki aplikacji za pomocą `Super + Alt + Space`.

### Co może zawierać zainstalowany motyw

Motyw, który napiszesz samodzielnie w `~/.config/omarchy/themes`, może zawierać, co tylko chcesz — to twój komputer i twój plik, a Omarchy zastosuje to wszystko.

Motyw, który instalujesz z cudzego repozytorium za pomocą `omarchy theme install`, zachowuje wszystko, co jest kolorem, i traci garść plików, które uruchamiałyby kod na twoim komputerze: każdy plik `.lua`, konfiguracje terminala (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) oraz `vscode.json`. Plik `hyprland.lua` motywu to Lua, którą twój compositor uruchamia przy logowaniu, konfiguracja terminala wskazuje program, który twój terminal uruchamia, a `vscode.json` wskazuje rozszerzenie VSCode do zainstalowania. Zainstalowanie czyjegoś motywu powinno zmienić to, jak wygląda twój pulpit, a nigdy to, co on uruchamia.

Cała reszta nadal działa dokładnie tak, jak napisał to autor motywu — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, tła i podglądy są zachowywane. Tylko to, co zostało porzucone, jest regenerowane z `colors.toml` na twoim komputerze.

Omarchy rozróżnia te dwa przypadki na podstawie tego, czy motyw ma wewnątrz własne repozytorium git, a to właśnie zostawia po sobie `omarchy theme install`, gdy klonuje. Więc motyw, który napisałeś, pozostaje twój, a motyw pobrany z internetu pozostaje samymi kolorami.

### Tryb jasny

Jeśli tworzysz motyw z trybem jasnym, ustaw `mode = "light"` na górze pliku `colors.toml`. Wtedy zostanie on automatycznie sparowany z trybem jasnym dla wszystkich aplikacji. (Stary sposób polegający na wrzuceniu pustego pliku o nazwie `light.mode` do katalogu głównego motywu też nadal działa.)

### Obraz odblokowania

Motywy dostarczone z obrazami `unlock.png` i `preview-unlock.png` będą wymienione w sekcji _Wygląd > Odblokowanie_. Twój `unlock.png` powinien być najlepiej przezroczystym plikiem png. A obraz podglądu możesz utworzyć za pomocą `omarchy plymouth preview`.

### Motywy dla aplikacji, których Omarchy nie obejmuje

Jeśli używasz aplikacji, której nie ma na tej liście, możesz samodzielnie nauczyć Omarchy, jak stosować do niej motyw, za pomocą szablonu. Wrzuć plik do `~/.config/omarchy/themed/` nazwany tak jak konfiguracja, którą generuje, plus rozszerzenie `.tpl`, i napisz konfigurację z `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` do `{{ color15 }}` oraz resztą palety jako symbolami zastępczymi. Za każdym razem, gdy przełączysz motywy, plik jest regenerowany z kolorami tego motywu.

W tym folderze znajduje się w pełni skomentowany plik `alacritty.toml.tpl.sample`, z którego możesz kopiować — wymienia każdą zmienną, której możesz użyć, a także modyfikatory `_strip` i `_rgb` dla aplikacji, które chcą swoich kolorów bez `#` lub jako dziesiętne RGB. Twoje szablony mają pierwszeństwo przed własnymi szablonami Omarchy, więc możesz też użyć tego, aby nadpisać sposób, w jaki wbudowana aplikacja otrzymuje motyw.

### Dystrybucja twojego motywu

Jeśli chcesz dystrybuować swój motyw, aby inni mogli go używać, musisz umieścić go na publicznym serwerze git, takim jak GitHub. Wtedy ludzie będą mogli zainstalować go za pomocą _Zainstaluj > Styl > Motyw_ w menu Omarchy, używając tego adresu URL. Zaleca się przestrzeganie konwencji nazewnictwa `omarchy-[themename]-theme`, ponieważ po instalacji motyw będzie poprawnie wyświetlany w menu wyboru motywu jako po prostu `[themename]`.

Ta pozostała część `[themename]` staje się nazwą katalogu motywu, więc musi być taką, którą Omarchy może bezpiecznie przekazywać dalej: musi zaczynać się od litery, cyfry lub znaku podkreślenia, a reszta może zawierać litery, cyfry, `.`, `_`, `+` i `-`. Wielkie litery są dla ciebie zamieniane na małe, ale wszystko inne — spacja, cudzysłów, znak spoza języka angielskiego — jest odrzucane podczas instalacji, zamiast zostać zamienione w nazwę katalogu. Więc `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` i `omarchy-c++-theme` wszystkie instalują się bez problemu.

Pamiętaj, że po zainstalowaniu z repozytorium każdy dostarczony przez niego plik `.lua`, konfiguracja terminala lub `vscode.json` zostaną porzucone, więc nie buduj motywu wokół nich.

Możesz sprawić, że twój motyw zostanie dodany do [strony z dodatkowymi motywami](https://omarchy.org/themes/), wysyłając pull request do [repozytorium omarchy-site](https://github.com/omacom-io/omarchy-site).
