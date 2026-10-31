# Neovim

[Neovim](https://neovim.io/) è una moderna implementazione [dell'editor vi](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) creato da Bill Joy addirittura nel 1976. È un editor modale dove modalità inserimento e modalità comando sono separate, ed è un po' un superpotere una volta imparato anche solo un sottoinsieme dell'incredibilmente profondo insieme di comandi da tastiera. Ma è anche una bella curva di apprendimento!

Se sei totalmente nuovo alla modifica in stile vim, ti consiglio di guardare [la serie Vim As Your Editor di ThePrimeagen](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) su YouTube. Ti insegnerà le basi. Sappi solo che a differenza di editor mainstream più simili tra loro, ti ci vorrà più tempo per raggiungere una competenza di base con vim. Ma una volta fatto, il ritorno è anche maggiore.

Ora, Neovim è praticamente infinitamente configurabile. Se vuoi davvero esagerare, puoi creare la tua configurazione Neovim da zero. C'è un ottimo corso di [Typecraft su come impostare Neovim da zero](https://www.youtube.com/watch?v=zHTeCSVAFNY). E [anche ThePrimeagen ne ha uno](https://www.youtube.com/watch?v=w7i4amO_zaE).

Ma Omarchy viene fornito con una configurazione Neovim completa — il pacchetto `omarchy-nvim` — che è stata amorevolmente messa a punto per mostrare il meglio di ciò che è possibile già pronto all'uso. Senza che tu debba scrivere una singola riga di configurazione! È costruita su [LazyVim](https://www.lazyvim.org/), una distribuzione di plugin e configurazioni Neovim. È fantastica.

## Basi di LazyVim

Come detto, non ho intenzione di insegnarti vim in questa breve introduzione, ma posso mostrarti alcune basi di LazyVim, e come muoverti.

Per prima cosa, Neovim ha l'idea del tasto leader. È fondamentalmente la porta a tutti i comandi. LazyVim l'ha impostato su `Space`. Quindi premilo semplicemente, aspetta un secondo, e vedrai un sacco di opzioni spiegate in linea in questo modo:

Ecco alcuni comandi di base che uso in continuazione:

- `Space Space` - Trova in modo fuzzy qualsiasi file nella cartella corrente.
- `Space S G` - Cerca in tutti i file usando grep con anteprima.
- `Space E` - Attiva/disattiva l'albero file.
- `Ctrl + W W` - Salta dall'albero file all'editor e viceversa.
- `Shift + H` - Spostati a sinistra tra le schede aperte (vim le chiama buffer).
- `Shift + L` - Spostati a destra tra le schede aperte.
- `Space B D` - Chiudi una scheda.
- `Space B O` - Chiudi tutte le altre schede tranne la corrente.
- `Space G G` - Avvia LazyGit in un pannello flottante dalla cartella corrente.
- `Space U W` - Attiva/disattiva ritorno a capo morbido.

Mentre sei nell'albero file (`Space E` per mostrarlo, `Ctrl + W W` per saltarci), puoi aggiungere un nuovo file con `a` o una nuova cartella con `A`. Premi `?` mentre sei nell'albero per vedere tutti i comandi.

Se vuoi imparare il linguaggio vim di base, ho scritto della [sintassi in tre parti](https://world.hey.com/dhh/wonderful-vi-a1d034d3) e di come eseguire quelle mosse combo pazzesche!

Puoi vedere tutti i comandi possibili sulla [pagina Keymaps di LazyVim](https://www.lazyvim.org/keymaps).

## Avviare Neovim

Puoi avviare Neovim usando `Super + Shift + N` (la combinazione avvia il tuo editor predefinito, che è Neovim di serie), ma di solito è più facile guidarlo da terminale navigando nella cartella in cui desideri lavorare e digitando `n`. `n` è l'alias di `nvim`, che userà la cartella presente per aprirsi per impostazione predefinita. Puoi aprire un singolo file con `n myfile.txt`.

## Usare Neovim per modifiche sudo

Se devi modificare file che puoi cambiare solo come superutente, puoi usare neovim con tutti i tuoi plugin configurati eseguendo `sudoedit /etc/sudoers.d/00-sudo-only-file`.
