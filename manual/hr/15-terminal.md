# Terminal

[Foot](https://codeberg.org/dnkl/foot) zadani je terminal za Omarchy. Brz je, lagan i kompatibilan čak i sa starim računalima. Međutim, ne podržava izvorne kartice ni podjele.

Ako koristite Tmux, možda vam to ne smeta, ali ako ne, u potpunosti podržavamo i _Alacritty_, _Ghostty_ i _Kitty_ kao opcije. Odaberite svoju prednost pod _Instaliraj > Terminal_ u Omarchy izborniku.

Novi terminal pokrećete prečacom `Super + Return`. (Ta će poveznica automatski upućivati na koji god Terminal instalirali putem _Instaliraj > Terminal_, a između instaliranih terminala možete se prebacivati pod _Postavke > Zadane postavke > Terminal_.)

## Tmux

Tmux pruža dosljedno, programljivo sučelje za okna, prozore (odnosno kartice) i sesije koje se mogu nastaviti bez obzira na vaš terminal. Radi čak i na udaljenim računalima, pa kada se SSH-om spajate na poslužitelj, možete koristiti isti pristup.

Novu Tmux sesiju u svježem terminalu pokrećete prečacom `Super + Alt + Return`, a budući da je Tmux trajan proces, svoju sesiju možete nastaviti čak i ako zatvorite taj terminal. Samo pritisnite `Ctrl + Space` (naziva se prefiksna tipka), a zatim `s` da vidite sve svoje aktivne sesije.

Omarchy dolazi s ergonomski optimiziranom konfiguracijom Tmuxa, koja ima mnogo poveznica tipki za naučiti, pa [popis prečaca držite pri ruci](07-hotkeys.md#tmux).

## Funkcije rasporeda Tmuxa

Budući da je Tmux programljiv, možemo koristiti funkcije za stvaranje rasporeda. Omarchy dolazi s četiri različite funkcije za uobičajene razvojne rasporede.

`tdl [agent]` pokreće trostruko podijeljeno sučelje slično IDE-u s `$EDITOR` na lijevoj strani, vašim odabranim AI agentom na desnoj strani (poput `c` za opencode ili `cx` za Claude ili `codex` za OpenAI), a zatim terminalom na dnu.

Dakle `tdl c` pokrenulo bi ovo (ili samo `ic`):

 ![tmux-tdl](images/tmux-tdl.webp)

Možete pokrenuti i drugoga agenta s `tdl c cx` (opencode + claude) (ili samo `icx`):

 ![tmux-tdl2](images/tmux-tdl2.webp)

Tu je i `tds`, koji pokreće četverostruki kvadrat s uređivačem gore lijevo, preglednikom razlika uživo gore desno, terminalom dolje lijevo i opencodeom dolje desno.

Tu konfiguraciju rasporeda možete pokrenuti i za svaki poddirektorij u trenutačnome direktoriju pomoću `tdlm [agent]`, a zatim se kretati pomoću `alt + 1/2/3/4/5/...`:

 ![tmux-tdlm](images/tmux-tdlm.webp)

Na kraju, roj agenata možete pokrenuti pomoću `tsl [panes] [command]`. Dakle `tsl 4 c` dat će vam četverostruku mrežu opencode agenata:

 ![tmux-tsl](images/tmux-tsl.webp)
