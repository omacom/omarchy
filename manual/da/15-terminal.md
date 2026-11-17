# Terminal

[Foot](https://codeberg.org/dnkl/foot) er standardterminalen for Omarchy. Den er hurtig, let og kompatibel med selv gamle computere. Den understøtter dog ikke indbyggede faner eller delinger.

Hvis du bruger Tmux, har du måske ikke noget imod det, men hvis ikke, understøtter vi også fuldt ud _Alacritty_, _Ghostty_ og _Kitty_ som valgmuligheder. Vælg din præference under _Installer > Terminal_ i Omarchy-menuen.

Du starter en ny terminal med `Super + Return`. (Denne binding peger automatisk på den terminal, du har installeret via _Installer > Terminal_, og du kan skifte mellem installerede terminaler under _Opsætning > Standarder > Terminal_.)

## Tmux

Tmux giver en konsekvent, programmerbar grænseflade til paneler, vinduer (også kaldet faner) og genoptagelige sessioner uanset din terminal. Den virker endda på eksterne værter, så når du SSH'er ind på en server, kan du bruge den samme tilgang.

Du starter en ny Tmux-session i en frisk terminal med `Super + Alt + Return`, og fordi Tmux er en vedvarende proces, kan du genoptage din session, selvom du lukker den terminal. Tryk bare på `Ctrl + Space` (kaldet præfiksnøglen) og derefter `s` for at se alle dine aktive sessioner.

Omarchy leveres med en ergonomisk optimeret Tmux-konfiguration, som har mange tastebindinger at lære, så hav [snydearket ved hånden](07-hotkeys.md#tmux).

## Tmux-layoutfunktioner

Fordi Tmux er programmerbar, kan vi bruge funktioner til at oprette layouts. Omarchy leveres med fire forskellige funktioner til almindelige udviklerlayouts.

`tdl [agent]` starter en tredelt IDE-lignende grænseflade med `$EDITOR` til venstre, din valgte AI-agent til højre (som `c` til opencode eller `cx` til Claude eller `codex` til OpenAI) og derefter en terminal nederst.

Så `tdl c` ville starte dette (eller bare `ic`):

 ![tmux-tdl](images/tmux-tdl.webp)

Du kan også starte en anden agent med `tdl c cx` (opencode + claude) (eller bare `icx`):

 ![tmux-tdl2](images/tmux-tdl2.webp)

Der er også `tds`, som starter en firedelt firkant med editoren øverst til venstre, en live diff-overvåger øverst til højre, en terminal nederst til venstre og opencode nederst til højre.

Du kan også starte denne layoutkonfiguration for hver undermappe i den aktuelle mappe med `tdlm [agent]` og derefter navigere med `alt + 1/2/3/4/5/...`:

 ![tmux-tdlm](images/tmux-tdlm.webp)

Endelig kan du starte en sværm af agenter med `tsl [panes] [command]`. Så `tsl 4 c` giver dig et firedelt gitter af opencode-agenter:

 ![tmux-tsl](images/tmux-tsl.webp)
