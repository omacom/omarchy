# Tworzenie własnego motywu

Możesz dodawać własne motywy do `~/.config/omarchy/themes`. Wystarczy, że skopiujesz jeden z istniejących jako bazę (zajrzyj do `/usr/share/omarchy/themes`), a potem dopasujesz go do swoich upodobań. Dopóki twój motyw znajduje się w tym folderze, będzie uwzględniony w menu wyboru motywu.

Głównym plikiem, który musisz dostosować, jest `colors.toml`. Definiuje on zestaw kolorów, który następnie służy do generowania konfiguracji dla terminala (Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, aplikacji Qt, podświetlenia klawiatury, metody wprowadzania, selektora udostępniania ekranu, ikon aplikacji, kilku narzędzi AI (Claude, Pi, Hermes, T3 Code, Herdr) oraz całej powłoki Omarchy (górny pasek, menu, powiadomienia, OSD i ekran blokady).

Możesz też użyć dołączonej aplikacji Aether, aby utworzyć nowy motyw za pomocą przyjemnego interfejsu GUI, w którym pobawisz się kolorami i poszukasz teł. Wystarczy uruchomić ją z siatki aplikacji za pomocą `Super + Alt + Space`.

### Co może zawierać zainstalowany motyw

Motyw, który napiszesz samodzielnie w `~/.config/omarchy/themes`, może zawierać, co tylko chcesz — to twój komputer i twój plik, a Omarchy zastosuje to wszystko.

Motyw, który instalujesz z cudzego repozytorium za pomocą `omarchy theme install`, zachowuje wszystko, co dotyczy kolorów, i traci garstkę plików, które uruchamiałyby kod na twoim komputerze: dowolny plik `.lua`, konfiguracje terminala (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) oraz `vscode.json`. `hyprland.lua` motywu to Lua, którą twój kompozytor uruchamia przy logowaniu, konfiguracja terminala wskazuje program, który twój terminal uruchamia, a `vscode.json` wskazuje rozszerzenie VSCode do zainstalowania. Instalowanie czyjegoś motywu powinno zmieniać wygląd twojego pulpitu, a nigdy to, co on uruchamia.

Cała reszta nadal działa dokładnie tak, jak napisał to autor motywu — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, tła i podglądy są zachowywane. Tylko to, co zostało odrzucone, jest regenerowane na twoim komputerze na podstawie `colors.toml`.

Omarchy rozróżnia je na podstawie tego, czy motyw ma wewnątrz własne repozytorium git, czyli to, co `omarchy theme install` pozostawia po klonowaniu. Dzięki temu motyw, który napisałeś, pozostaje twój, a ten ściągnięty z internetu pozostaje samymi kolorami.

### Tryb jasny

Jeśli tworzysz motyw w trybie jasnym, ustaw `mode = "light"` na górze pliku `colors.toml`. Wtedy zostanie on automatycznie połączony z trybem jasnym dla wszystkich aplikacji. (Stary sposób, polegający na wrzuceniu pustego pliku o nazwie `light.mode` do katalogu głównego motywu, również nadal działa.)

### Ekrany rozruchu i logowania

Ekran, który przy rozruchu prosi o hasło dysku, oraz ekran logowania rysują logo Omarchy w kolorze `accent` twojego motywu na jego tle `background`, z polem hasła w kolorze `foreground` i kolorem `red` dla błędnego hasła. Nie musisz dostarczać niczego dodatkowego na ich potrzeby: Omarchy nie używa już pliku `unlock.png` ani `preview-unlock.png` z motywu. Na komputerach Mac z Apple Silicon ekran hasła dysku zachowuje domyślny wygląd Omarchy niezależnie od motywu.

### Nadawanie motywu aplikacjom, których Omarchy nie obejmuje

Jeśli używasz aplikacji, której nie ma na tej liście, możesz samodzielnie nauczyć Omarchy, jak nadawać jej motyw za pomocą szablonu. Wrzuć plik do `~/.config/omarchy/themed/` nazwany tak jak konfiguracja, którą generuje, plus rozszerzenie `.tpl`, i napisz konfigurację, używając `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}` do `{{ color15 }}` oraz reszty palety jako symboli zastępczych. Za każdym razem, gdy przełączasz motywy, plik jest regenerowany przy użyciu kolorów tego motywu.

W tym folderze znajduje się w pełni okomentowany plik `alacritty.toml.tpl.sample`, z którego możesz kopiować — wymienia on każdą zmienną, której możesz użyć, a także modyfikatory `_strip` i `_rgb` dla aplikacji, które chcą otrzymywać kolory bez znaku `#` lub jako dziesiętne wartości RGB. Twoje szablony mają pierwszeństwo przed własnymi szablonami Omarchy, więc możesz też użyć tego, aby nadpisać sposób nadawania motywu wbudowanej aplikacji.

### Udostępnianie swojego motywu

Jeśli chcesz udostępniać swój motyw, aby inni mogli z niego korzystać, musisz umieścić go na publicznym serwerze git, takim jak GitHub. Wtedy ludzie będą mogli zainstalować go, używając _Install > Style > Theme_ w menu Omarchy, podając ten URL. Zaleca się przestrzeganie konwencji nazewnictwa `omarchy-[themename]-theme`, ponieważ po instalacji motyw będzie poprawnie wyświetlany w menu wyboru motywu jako samo `[themename]`.

Pozostałe `[themename]` staje się nazwą katalogu motywu, więc musi być taką, którą Omarchy będzie mogło bezpiecznie przekazywać dalej: musi zaczynać się od litery, cyfry lub podkreślenia, a reszta może zawierać litery, cyfry, `.`, `_`, `+` i `-`. Wielkie litery zostaną dla ciebie zamienione na małe, ale wszystko inne — spacja, cudzysłów, znak spoza angielskiego alfabetu — zostanie odrzucone podczas instalacji, zamiast stać się nazwą katalogu. Dlatego `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme` i `omarchy-c++-theme` instalują się bez problemu.

Pamiętaj, że gdy motyw zostanie zainstalowany z repozytorium, każdy dostarczony przez niego plik `.lua`, konfiguracja terminala lub plik `vscode.json` zostaną odrzucone, więc nie opieraj motywu na nich.

Możesz dodać swój motyw na [stronie z dodatkowymi motywami](https://omarchy.org/themes/), wysyłając pull request do [repozytorium omarchy-site](https://github.com/omacom-io/omarchy-site).
