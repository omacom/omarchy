# Terminal

[Foot](https://codeberg.org/dnkl/foot) je privzeti terminal za Omarchy. Je hiter, lahek in združljiv celo s starimi računalniki. Vendar ne podpira izvornih zavihkov ali razdelitev.

Če uporabljate Tmux, vas to morda ne moti, če pa ne, kot možnosti v celoti podpiramo tudi _Alacritty_, _Ghostty_ in _Kitty_. Svojo nastavitev izberete pod _Install > Terminal_ v meniju Omarchy.

Nov terminal zaženete s `Super + Return`. (Ta vezava bo samodejno kazala na kateri koli terminal, ki ste ga namestili prek _Install > Terminal_, med nameščenimi terminali pa lahko preklapljate pod _Setup > Defaults > Terminal_.)

## Tmux

Tmux zagotavlja dosleden, programirljiv vmesnik za podokna, okna (ali zavihke) in obnovljive seje ne glede na vaš terminal. Deluje celo na oddaljenih gostiteljih, tako da lahko, ko se prek SSH povezujete na strežnik, uporabite enak pristop.

Novo sejo Tmux v novem terminalu zaženete s `Super + Alt + Return`, in ker je Tmux trajni proces, lahko sejo nadaljujete, tudi če ta terminal zaprete. Samo pritisnite `Ctrl + Space` (tako imenovana predpona), nato `s`, da vidite vse svoje aktivne seje.

Omarchy je dobavljen z ergonomsko optimizirano konfiguracijo Tmuxa, ki se je treba naučiti veliko vezav tipk, zato [priročnik](07-hotkeys.md#tmux) držite pri roki.

## Funkcije postavitve Tmux

Ker je Tmux programirljiv, lahko funkcije uporabljamo za ustvarjanje postavitev. Omarchy je dobavljen s štirimi različnimi funkcijami za običajne razvijalske postavitve.

`tdl [agent]` zažene trojno razdelitev, podobno IDE, z `$EDITOR` na levi, vašim izbranim agentom AI na desni (kot je `c` za opencode ali `cx` za Claude ali `codex` za OpenAI), nato pa terminalom na dnu.

Torej bi `tdl c` zagnal tole (ali samo `ic`):

 ![tmux-tdl](images/tmux-tdl.webp)

Zagnati lahko tudi drugega agenta s `tdl c cx` (opencode + claude) (ali samo `icx`):

 ![tmux-tdl2](images/tmux-tdl2.webp)

Tu je tudi `tds`, ki zažene štiridelni kvadrat z urejevalnikom zgoraj levo, opazovalnikom razlik v živo zgoraj desno, terminalom spodaj levo in opencodeom spodaj desno.

To konfiguracijo postavitve lahko zaženete tudi za vsak podimenik v trenutnem imeniku z `tdlm [agent]`, nato pa navigirate z `alt + 1/2/3/4/5/...`:

 ![tmux-tdlm](images/tmux-tdlm.webp)

Nazadnje lahko zaženete roj agentov z `tsl [panes] [command]`. Tako vam bo `tsl 4 c` dal štiridelno mrežo agentov opencode:

 ![tmux-tsl](images/tmux-tsl.webp)
