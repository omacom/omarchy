# Terminale

[Foot](https://codeberg.org/dnkl/foot) è il terminale predefinito di Omarchy. È veloce, leggero e compatibile anche con computer vecchi. Non supporta però schede o divisioni native.

Se usi Tmux, potrebbe non importarti, ma in caso contrario supportiamo completamente anche _Alacritty_, _Ghostty_ e _Kitty_ come opzioni. Scegli la tua preferenza sotto _Installa > Terminale_ nel menu Omarchy.

Avvii un nuovo terminale usando `Super + Return`. (Questa combinazione punterà automaticamente a qualsiasi Terminale tu abbia installato tramite _Installa > Terminale_, e puoi passare tra i terminali installati sotto _Impostazioni > Predefiniti > Terminale_.)

## Tmux

Tmux fornisce un'interfaccia coerente e programmabile per pannelli, finestre (dette anche schede) e sessioni riprendibili indipendentemente dal terminale. Funziona persino su host remoti, così quando sei in SSH su un server, puoi usare lo stesso approccio.

Avvii una nuova sessione Tmux in un terminale nuovo usando `Super + Alt + Return`, e poiché Tmux è un processo persistente, puoi riprendere la sessione anche se chiudi quel terminale. Premi semplicemente `Ctrl + Space` (chiamato tasto prefisso) poi `s` per vedere tutte le sessioni attive.

Omarchy viene fornito con una configurazione Tmux ottimizzata ergonomicamente, che ha molte combinazioni da imparare, quindi tieni [il foglio riassuntivo a portata di mano](07-hotkeys.md#tmux).

## Funzioni layout Tmux

Poiché Tmux è programmabile, possiamo usare le funzioni per creare layout. Omarchy viene fornito con quattro funzioni diverse per layout di sviluppo comuni.

`tdl [agent]` avvia un'interfaccia in stile IDE divisa in tre con `$EDITOR` a sinistra, l'agente AI scelto a destra (come `c` per opencode o `cx` per Claude o `codex` per OpenAI), e poi un terminale in basso.

Quindi `tdl c` avvierebbe questo (o semplicemente `ic`):

 ![tmux-tdl](images/tmux-tdl.webp)

Puoi anche avviare un secondo agente con `tdl c cx` (opencode + claude) (o semplicemente `icx`):

 ![tmux-tdl2](images/tmux-tdl2.webp)

C'è anche `tds`, che avvia un quadrato a quattro con l'editor in alto a sinistra, un osservatore diff in diretta in alto a destra, un terminale in basso a sinistra e opencode in basso a destra.

Puoi anche avviare questa configurazione di layout per ogni sottocartella nella cartella corrente usando `tdlm [agent]`, poi navigare usando `alt + 1/2/3/4/5/...`:

 ![tmux-tdlm](images/tmux-tdlm.webp)

Infine, puoi avviare uno sciame di agenti usando `tsl [panes] [command]`. Quindi `tsl 4 c` ti darà una griglia a quattro di agenti opencode:

 ![tmux-tsl](images/tmux-tsl.webp)
