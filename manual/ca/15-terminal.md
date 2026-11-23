# Terminal

[Foot](https://codeberg.org/dnkl/foot) és el terminal per defecte d'Omarchy. És ràpid, lleuger i compatible fins i tot amb ordinadors vells. Tanmateix, no admet pestanyes ni divisions natives.

Si feu servir Tmux, potser no us importa, però si no, també admetem completament _Alacritty_, _Ghostty_ i _Kitty_ com a opcions. Trieu la vostra preferència a _Instal·la > Terminal_ al menú d'Omarchy.

Inicieu un terminal nou amb `Super + Return`. (Aquesta assignació apuntarà automàticament al terminal que hàgiu instal·lat mitjançant _Instal·la > Terminal_, i podeu canviar entre els terminals instal·lats a _Configuració > Per defecte > Terminal_.)

## Tmux

Tmux proporciona una interfície coherent i programable per a panells, finestres (és a dir, pestanyes) i sessions que es poden reprendre independentment del vostre terminal. Fins i tot funciona en amfitrions remots, de manera que quan feu SSH a un servidor, podeu fer servir el mateix enfocament.

Inicieu una sessió nova de Tmux en un terminal nou amb `Super + Alt + Return` i, com que Tmux és un procés persistent, podeu reprendre la vostra sessió fins i tot si tanqueu aquest terminal. Només heu de prémer `Ctrl + Space` (anomenada tecla de prefix) i després `s` per veure totes les vostres sessions actives.

Omarchy ve amb una configuració de Tmux optimitzada ergonòmicament, que té moltes dreceres per aprendre, així que tingueu [el full de referència a mà](07-hotkeys.md#tmux).

## Funcions de disposició de Tmux

Com que Tmux és programable, podem fer servir funcions per crear disposicions. Omarchy ve amb quatre funcions diferents per a disposicions habituals de desenvolupador.

`tdl [agent]` inicia una interfície dividida en tres semblant a un IDE amb el `$EDITOR` a l'esquerra, l'agent d'IA que heu triat a la dreta (com `c` per a opencode, `cx` per a Claude o `codex` per a OpenAI) i després un terminal a la part inferior.

Així `tdl c` iniciaria això (o simplement `ic`):

 ![tmux-tdl](images/tmux-tdl.webp)

També podeu iniciar un segon agent amb `tdl c cx` (opencode + claude) (o simplement `icx`):

 ![tmux-tdl2](images/tmux-tdl2.webp)

També hi ha `tds`, que inicia un quadrat de quatre amb l'editor a dalt a l'esquerra, un observador de diferències en directe a dalt a la dreta, un terminal a baix a l'esquerra i opencode a baix a la dreta.

També podeu iniciar aquesta configuració de disposició per a cada subdirectori del directori actual amb `tdlm [agent]`, i després navegar amb `alt + 1/2/3/4/5/...`:

 ![tmux-tdlm](images/tmux-tdlm.webp)

Finalment, podeu iniciar un eixam d'agents amb `tsl [panes] [command]`. Així `tsl 4 c` us donarà una graella de quatre agents opencode:

 ![tmux-tsl](images/tmux-tsl.webp)
