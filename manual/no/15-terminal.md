# Terminal

[Foot](https://codeberg.org/dnkl/foot) er standardterminalen for Omarchy. Den er rask, lett og kompatibel med selv gamle datamaskiner. Den støtter imidlertid ikke innebygde faner eller delinger.

Hvis du bruker Tmux, plager det deg kanskje ikke, men hvis ikke, støtter vi _Alacritty_, _Ghostty_ og _Kitty_ fullt ut som alternativer også. Velg din preferanse under _Installer > Terminal_ i Omarchy-menyen.

Du starter en ny terminal med `Super + Return`. (Denne bindingen peker automatisk på den terminalen du har installert via _Installer > Terminal_, og du kan bytte mellom installerte terminaler under _Oppsett > Standarder > Terminal_.)

## Tmux

Tmux gir et konsekvent, programmerbart grensesnitt for ruter, vinduer (aka faner) og gjenopptakbare økter uavhengig av terminalen din. Den fungerer til og med på eksterne verter, så når du SSH-er inn på en server, kan du bruke samme tilnærming.

Du starter en ny Tmux-økt i en fersk terminal med `Super + Alt + Return`, og fordi Tmux er en vedvarende prosess, kan du gjenoppta økten din selv om du lukker den terminalen. Trykk bare `Ctrl + Space` (kalt prefikstasten) og deretter `s` for å se alle de aktive øktene dine.

Omarchy leveres med en ergonomisk optimalisert Tmux-konfigurasjon, som har mange tastebindinger å lære, så hold [juksearket tilgjengelig](07-hotkeys.md#tmux).

## Tmux-layoutfunksjoner

Fordi Tmux er programmerbar, kan vi bruke funksjoner til å lage layouter. Omarchy leveres med fire ulike funksjoner for vanlige utviklerlayouter.

`tdl [agent]` starter et tredelt IDE-lignende grensesnitt med `$EDITOR` til venstre, den valgte AI-agenten til høyre (som `c` for opencode eller `cx` for Claude eller `codex` for OpenAI), og deretter en terminal nederst.

Så `tdl c` starter dette (eller bare `ic`):

 ![tmux-tdl](images/tmux-tdl.webp)

Du kan også starte en annen agent med `tdl c cx` (opencode + claude) (eller bare `icx`):

 ![tmux-tdl2](images/tmux-tdl2.webp)

Det finnes også `tds`, som starter en firedelt firkant med editoren øverst til venstre, en levende diff-overvåker øverst til høyre, en terminal nederst til venstre, og opencode nederst til høyre.

Du kan også starte denne layoutkonfigurasjonen for hver undermappe i gjeldende mappe med `tdlm [agent]`, og deretter navigere med `alt + 1/2/3/4/5/...`:

 ![tmux-tdlm](images/tmux-tdlm.webp)

Til slutt kan du starte en sverm av agenter med `tsl [panes] [command]`. Så `tsl 4 c` gir deg et firedelt rutenett av opencode-agenter:

 ![tmux-tsl](images/tmux-tsl.webp)
