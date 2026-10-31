# Terminalul

[Foot](https://codeberg.org/dnkl/foot) este terminalul implicit pentru Omarchy. Este rapid, ușor și compatibil chiar și cu calculatoare vechi. Totuși, nu acceptă file native sau divizări.

Dacă folosești Tmux, s-ar putea să nu-ți pese, dar, dacă nu, acceptăm pe deplin și _Alacritty_, _Ghostty_ și _Kitty_ ca opțiuni. Alege-ți preferința sub _Instalează > Terminal_ în meniul Omarchy.

Pornești un terminal nou folosind `Super + Return`. (Această mapare va indica automat orice terminal ai instalat prin _Instalează > Terminal_, și poți comuta între terminalele instalate sub _Configurare > Implicite > Terminal_.)

## Tmux

Tmux oferă o interfață consecventă și programabilă pentru panouri, ferestre (numite și file) și sesiuni care pot fi reluate, indiferent de terminalul tău. Funcționează chiar și pe gazde la distanță, astfel încât, atunci când te conectezi prin SSH la un server, poți folosi aceeași abordare.

Pornești o sesiune Tmux nouă într-un terminal proaspăt folosind `Super + Alt + Return`, și, deoarece Tmux este un proces persistent, îți poți relua sesiunea chiar dacă închizi acel terminal. Apasă doar `Ctrl + Space` (numită tasta prefix), apoi `s` ca să vezi toate sesiunile tale active.

Omarchy vine cu o configurație Tmux optimizată ergonomic, care are multe mapări de învățat, așa că păstrează [fișa de ajutor la îndemână](07-hotkeys.md#tmux).

## Funcții de aranjare Tmux

Deoarece Tmux este programabil, putem folosi funcții ca să creăm aranjări. Omarchy vine cu patru funcții diferite pentru aranjări comune de dezvoltator.

`tdl [agent]` pornește o interfață asemănătoare unui IDE, împărțită în trei, cu `$EDITOR` în stânga, agentul tău AI ales în dreapta (cum ar fi `c` pentru opencode sau `cx` pentru Claude sau `codex` pentru OpenAI) și apoi un terminal în partea de jos.

Astfel, `tdl c` ar porni aceasta (sau doar `ic`):

 ![tmux-tdl](images/tmux-tdl.webp)

Poți porni și un al doilea agent cu `tdl c cx` (opencode + claude) (sau doar `icx`):

 ![tmux-tdl2](images/tmux-tdl2.webp)

Există și `tds`, care pornește un pătrat în patru, cu editorul în stânga sus, un observator de diferențe în timp real în dreapta sus, un terminal în stânga jos și opencode în dreapta jos.

Poți porni și această configurație de aranjare pentru fiecare subdirector din directorul curent folosind `tdlm [agent]`, apoi navighezi folosind `alt + 1/2/3/4/5/...`:

 ![tmux-tdlm](images/tmux-tdlm.webp)

În final, poți porni un roi de agenți folosind `tsl [panes] [command]`. Astfel, `tsl 4 c` îți va da o grilă în patru de agenți opencode:

 ![tmux-tsl](images/tmux-tsl.webp)
