# Tworzenie własnego motywu

Możesz dodać własne motywy do `~/.config/omarchy/themes`. Po prostu skopiuj jeden z istniejących jako bazę (zajrzyj do `/usr/share/omarchy/themes`), a potem dostosuj go do woli. Dopóki twój motyw znajduje się w tym folderze, będzie uwzględniony w menu wyboru motywu.

Główny plik, który musisz dostosować, to `colors.toml`. Definiuje on zestaw kolorów, który następnie służy do generowania konfiguracji dla terminala (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, aplikacji Qt, podświetlenia klawiatury, metody wprowadzania, selektora udostępniania ekranu, ikon aplikacji, kilku narzędzi AI (Claude, Pi, Hermes, T3 Code, Herdr) oraz całej powłoki Omarchy (górny pasek, menu, powiadomienia, OSD i ekran blokady).

Możesz też użyć dołączonej aplikacji Aether, aby utworzyć nowy motyw za pomocą przyjemnego interfejsu GUI, który pozwala bawić się kolorami i wyszukiwać tła. Wystarczy uruchomić ją z siatki aplikacji za pomocą `Super + Alt + Space`.

### Co może zawierać zainstalowany motyw

Motyw, który napiszesz samodzielnie w `~/.config/omarchy/themes`, może zawierać, co tylko chcesz — to twój komputer i twój plik, a Omarchy zastosuje wszystko z niego.

Motyw, który instalujesz z cudzego repozytorium za pomocą `omarchy theme install`, zachowuje wszystko, co jest kolorem, i traci garść plików, które uruchamiałyby kod na twoim komputerze: każdy plik `.lua`, konfiguracje terminala (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) oraz `vscode.json`. Plik `hyprland.lua` motywu to Lua, którą twój kompozytor uruchamia przy logowaniu, konfiguracja terminala nazywa program, który uruchamia twój terminal, a `vscode.json` nazywa rozszerzenie VSCode do zainstalowania. Instalowanie czyjegoś motywu powinno zmieniać wygląd twojego pulpitu, nigdy to, co on uruchamia.

Wszystko inne nadal działa dokładnie tak, jak napisał to autor motywu — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, tła i podglądy są zachowywane. Tylko to, co zostało porzucone, jest regenerowane z `colors.toml` na twoim komputerze.

Omarchy rozróżnia te dwa przypadki na podstawie tego, czy motyw ma wewnątrz własne repozytorium git, czyli to, co `omarchy theme install` pozostawia po sobie podczas klonowania. Dzięki temu motyw, który napisałeś, pozostaje twój, a ten pobrany z internetu pozostaje tylko kolorami.

### Tryb jasny

Jeśli tworzysz motyw w trybie jasnym, ustaw `mode = "light"` na górze swojego `colors.toml`. Wtedy będzie on automatycznie łączony z trybem jasnym dla wszystkich aplikacji. (Stary sposób polegający na umieszczeniu pustego pliku o nazwie `light.mode` w katalogu głównym motywu nadal działa.)

### Obraz odblokowania

Motywy dostarczone z obrazami `unlock.png` i `preview-unlock.png` będą wymienione w _Appearance > Unlock_. Twój `unlock.png` powinien najlepiej być przezroczystym png. A obraz podglądu możesz utworzyć za pomocą `omarchy plymouth preview`.

### Nadawanie motywu aplikacjom, których Omarchy nie obejmuje

Jeśli używasz aplikacji, której nie ma na tej liście, możesz samodzielnie nauczyć Omarchy nadawania jej motywu za pomocą szablonu. Umieść plik w `~/.config/omarchy/themed/` nazwany tak jak konfiguracja, którą generuje, plus rozszerzenie `.tpl`, i napisz konfigurację, używając `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` do `{{ color15 }}` oraz reszty palety jako symboli zastępczych. Za każdym razem, gdy przełączysz motywy, plik jest regenerowany przy użyciu kolorów tego motywu.

W tym folderze znajduje się w pełni skomentowany plik `alacritty.toml.tpl.sample`, z którego możesz kopiować — wymienia on każdą zmienną, której możesz użyć, plus modyfikatory `_strip` i `_rgb` dla aplikacji, które chcą swoich kolorów bez `#` lub jako dziesiętne RGB. Twoje szablony mają pierwszeństwo przed własnymi szablonami Omarchy, więc możesz też użyć tego, aby nadpisać sposób nadawania motywu wbudowanej aplikacji.

### Dystrybucja własnego motywu

Jeśli chcesz rozpowszechniać swój motyw, aby inni mogli z niego korzystać, musisz umieścić go na publicznym serwerze git, takim jak GitHub. Wtedy ludzie będą mogli go zainstalować, używając _Install > Style > Theme_ w menu Omarchy, podając ten URL. Zaleca się przestrzeganie konwencji nazewnictwa `omarchy-[themename]-theme`, ponieważ po instalacji motyw będzie poprawnie wyświetlany jako po prostu `[themename]` w menu wyboru motywu.

Ta pozostała część `[themename]` staje się nazwą katalogu motywu, więc musi być taka, którą Omarchy może bezpiecznie przekazywać: musi zaczynać się od litery, cyfry lub znaku podkreślenia, a reszta może zawierać litery, cyfry, `.`, `_`, `+` i `-`. Wielkie litery są dla ciebie zamieniane na małe, ale wszystko inne — spacja, cudzysłów, znak spoza języka angielskiego — jest odrzucane w czasie instalacji, zamiast zostać zamienione w nazwę katalogu. Więc `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` i `omarchy-c++-theme` instalują się bez problemu.

Pamiętaj, że po zainstalowaniu z repozytorium każdy plik `.lua`, konfiguracja terminala lub `vscode.json`, który zawiera, jest porzucany, więc nie buduj motywu wokół nich.

Możesz dodać swój motyw do [strony z dodatkowymi motywami](https://omarchy.org/themes/), wysyłając pull request do [repozytorium omarchy-site](https://github.com/omacom-io/omarchy-site).
