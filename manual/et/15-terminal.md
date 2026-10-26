# Terminal

[Foot](https://codeberg.org/dnkl/foot) on Omarchy vaiketerminal. See on kiire, kergekaaluline ja ühildub isegi vanade arvutitega. See ei toeta aga natiivseid vahelehti ega jagamisi.

Kui kasutad Tmuxi, ei pruugi sellest olenevalt, kuid kui mitte, toetame täielikult ka _Alacritty_, _Ghostty_ ja _Kitty_ valikutena. Vali oma eelistus Omarchy menüüs _Paigalda > Terminal_ alt.

Käivitad uue terminali `Super + Return` abil. (See seos osutab automaatselt sellele, millise terminali oled _Paigalda > Terminal_ kaudu paigaldanud, ja saad paigaldatud terminalide vahel lülituda _Seaded > Vaikimisi > Terminal_ all.)

## Tmux

Tmux pakub järjepidevat, programmeeritavat liidest paanide, akende (ehk vahelehtede) ja taastatavate seansside jaoks olenemata su terminalist. See töötab isegi kaughostidel, nii et kui SSH-d serverisse, saad kasutada sama lähenemist.

Käivitad uue Tmuxi seansi värskes terminalis `Super + Alt + Return` abil ja kuna Tmux on püsiv protsess, saad oma seansi taastada isegi siis, kui selle terminali sulged. Vajuta lihtsalt `Ctrl + Space` (nimetatakse eesliite klahviks), seejärel `s`, et näha kõiki oma aktiivseid seansse.

Omarchy tarnitakse ergonoomiliselt optimeeritud Tmuxi seadistusega, millel on palju klahviseoseid õppimiseks, nii et hoia [spikker käepärast](07-hotkeys.md#tmux).

## Tmuxi paigutusfunktsioonid

Kuna Tmux on programmeeritav, saame kasutada funktsioone paigutuste loomiseks. Omarchy tarnib nelja erineva funktsiooniga levinud arendajapaigutuste jaoks.

`tdl [agent]` käivitab kolmikjagamise IDE-laadse liidese `$EDITOR`-iga vasakul, sinu valitud AI agendiga paremal (nagu `c` opencode'i jaoks või `cx` Claude'i jaoks või `codex` OpenAI jaoks) ja seejärel terminali allosas.

Nii et `tdl c` käivitaks selle (või lihtsalt `ic`):

 ![tmux-tdl](images/tmux-tdl.webp)

Saad käivitada ka teise agendi `tdl c cx` abil (opencode + claude) (või lihtsalt `icx`):

 ![tmux-tdl2](images/tmux-tdl2.webp)

Olemas on ka `tds`, mis käivitab neljapoolse ruudu koos redaktoriga vasakul üleval, reaalajas diffi jälgijaga paremal üleval, terminaliga vasakul all ja opencode'iga paremal all.

Saad käivitada selle paigutusseadistuse ka iga praeguse kataloogi alamkataloogi jaoks `tdlm [agent]` abil, seejärel navigeerida `alt + 1/2/3/4/5/...` abil:

 ![tmux-tdlm](images/tmux-tdlm.webp)

Lõpuks saad käivitada agentide parve `tsl [panes] [command]` abil. Nii et `tsl 4 c` annab sulle neljapoolse ruudustiku opencode'i agente:

 ![tmux-tsl](images/tmux-tsl.webp)
