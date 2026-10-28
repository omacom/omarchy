# Terminal

[Foot](https://codeberg.org/dnkl/foot) jest domyślnym terminalem dla Omarchy. Jest szybki, lekki i zgodny nawet ze starymi komputerami. Nie obsługuje jednak natywnych kart ani podziałów.

Jeśli używasz Tmux, może ci to nie przeszkadzać, ale jeśli nie, w pełni obsługujemy też _Alacritty_, _Ghostty_ i _Kitty_ jako opcje. Wybierz swoją preferencję pod _Instaluj > Terminal_ w menu Omarchy.

Nowy terminal uruchamiasz przez `Super + Return`. (To przypisanie automatycznie wskaże terminal, który zainstalowałeś przez _Instaluj > Terminal_, a między zainstalowanymi terminalami przełączysz się pod _Ustawienia > Domyślne > Terminal_.)

## Tmux

Tmux zapewnia spójny, programowalny interfejs do paneli, okien (czyli kart) i wznawialnych sesji niezależnie od twojego terminala. Działa nawet na zdalnych hostach, więc gdy SSH-ujesz się na serwer, możesz używać tego samego podejścia.

Nową sesję Tmux w świeżym terminalu uruchamiasz przez `Super + Alt + Return`, a ponieważ Tmux jest procesem trwałym, możesz wznowić sesję nawet po zamknięciu tamtego terminala. Po prostu naciśnij `Ctrl + Space` (zwany klawiszem prefiksu), a potem `s`, żeby zobaczyć wszystkie aktywne sesje.

Omarchy jest dostarczany z ergonomicznie zoptymalizowaną konfiguracją Tmux, która ma wiele przypisań klawiszy do nauczenia się, więc miej [ściągę pod ręką](07-hotkeys.md#tmux).

## Funkcje układów Tmux

Ponieważ Tmux jest programowalny, możemy używać funkcji do tworzenia układów. Omarchy zawiera cztery różne funkcje dla typowych układów deweloperskich.

`tdl [agent]` uruchamia trzyczęściowy, podobny do IDE interfejs z `$EDITOR` po lewej, wybranym agentem AI po prawej (jak `c` dla opencode, `cx` dla Claude albo `codex` dla OpenAI), a następnie terminal na dole.

Tak więc `tdl c` uruchomiłoby to (albo po prostu `ic`):

 ![tmux-tdl](images/tmux-tdl.webp)

Możesz też uruchomić drugiego agenta przez `tdl c cx` (opencode + claude) (albo po prostu `icx`):

 ![tmux-tdl2](images/tmux-tdl2.webp)

Jest też `tds`, który uruchamia kwadrat na cztery części, z edytorem w lewym górnym rogu, obserwatorem różnic na żywo w prawym górnym rogu, terminalem w lewym dolnym rogu i opencode w prawym dolnym rogu.

Możesz też uruchomić tę konfigurację układu dla każdego podkatalogu w bieżącym katalogu, używając `tdlm [agent]`, a następnie poruszać się przez `alt + 1/2/3/4/5/...`:

 ![tmux-tdlm](images/tmux-tdlm.webp)

Na koniec możesz uruchomić rój agentów przez `tsl [panes] [command]`. Tak więc `tsl 4 c` da ci siatkę czterech agentów opencode:

 ![tmux-tsl](images/tmux-tsl.webp)
