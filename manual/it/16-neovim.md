# Neovim

[Neovim](https://neovim.io/) è una moderna implementazione [dell'editor vi](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) creato da Bill Joy addirittura nel 1976. È un editor modale dove modalità inserimento e modalità comando sono separate, e una volta imparata anche solo una parte del suo vastissimo repertorio di comandi da tastiera diventa una specie di superpotere. Ma è anche una bella curva di apprendimento!

Se non hai mai usato un editor in stile vim, ti consiglio di guardare [la serie Vim As Your Editor di ThePrimeagen](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) su YouTube. Ti insegnerà le basi. Sappi solo che a differenza di editor mainstream più simili tra loro, ti ci vorrà più tempo per raggiungere una competenza di base con vim. Ma una volta lì, la ricompensa è ancora più grande.

Ora, Neovim è praticamente configurabile all'infinito. Se vuoi davvero esagerare, puoi creare la tua configurazione di Neovim da zero. C'è un ottimo [corso di Typecraft su come configurare Neovim da zero](https://www.youtube.com/watch?v=zHTeCSVAFNY). E [anche ThePrimeagen ne ha uno](https://www.youtube.com/watch?v=w7i4amO_zaE).

Ma Omarchy include una configurazione completa di Neovim — il pacchetto `omarchy-nvim` — curata con amore per mostrare il meglio di ciò che è possibile ottenere fin da subito. Senza che tu debba scrivere una sola riga di configurazione! È basata su [LazyVim](https://www.lazyvim.org/), una distribuzione di plugin e configurazioni per Neovim. È fantastica.

## Nozioni di base di LazyVim

Come detto, non ti insegnerò vim in questa breve introduzione, ma posso mostrarti alcune nozioni di base di LazyVim e come muoverti.

Per prima cosa, Neovim ha l'idea del tasto leader. È fondamentalmente la porta a tutti i comandi. LazyVim l'ha impostato su `Space`. Premilo, aspetta un secondo e vedrai un sacco di opzioni spiegate in linea in questo modo:

Ecco alcuni comandi di base che uso in continuazione:

- `Space Space` - Trova con ricerca fuzzy qualsiasi file nella directory corrente.
- `Space S G` - Cerca in tutti i file usando grep con un'anteprima.
- `Space E` - Mostra/nascondi l'albero dei file.
- `Ctrl + W W` - Passa dall'albero dei file all'editor e viceversa.
- `Shift + H` - Spostati a sinistra tra le schede aperte (vim le chiama buffer).
- `Shift + L` - Spostati a destra tra le schede aperte.
- `Space B D` - Chiudi una scheda.
- `Space B O` - Chiudi tutte le altre schede tranne quella corrente.
- `Space G G` - Avvia LazyGit in un pannello fluttuante dalla directory corrente.
- `Space U W` - Attiva/disattiva il soft wrap.

Mentre sei nell'albero dei file (`Space E` per mostrarlo, `Ctrl + W W` per spostarti lì), puoi aggiungere un nuovo file con `a` o una nuova directory con `A`. Premi `?` mentre sei nell'albero per vedere tutti i comandi.

Se vuoi imparare il linguaggio di base di vim, ho scritto della [sintassi in tre parti](https://world.hey.com/dhh/wonderful-vi-a1d034d3) e di come eseguire quelle incredibili combo!

Puoi vedere tutti i comandi possibili sulla [pagina Keymaps di LazyVim](https://www.lazyvim.org/keymaps).

## Avviare Neovim

`Super + Shift + N` avvia il tuo editor predefinito, che nelle nuove installazioni è Plain; scegli Neovim in _Impostazioni > Predefiniti > Editor_ per far avviare Neovim al suo posto. Ma di solito è più comodo avviarlo dal terminale: vai nella directory in cui vuoi lavorare e digita `n`. `n` è l'alias di `nvim` e, per impostazione predefinita, apre la directory in cui ti trovi. Puoi aprire un singolo file con `n myfile.txt`.

## Usare Neovim per le modifiche con sudo

Se devi modificare file che puoi cambiare solo come super user, esegui `sudoedit /etc/sudoers.d/00-sudo-only-file`. Apre il tuo editor predefinito, quindi imposta Neovim in _Impostazioni > Predefiniti > Editor_ se lo vuoi lì con tutti i tuoi plugin.
