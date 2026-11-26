# Neovim

[Neovim](https://neovim.io/) è una moderna implementazione de [l'editor vi](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) creato da Bill Joy nel lontano 1976. È un editor modale in cui la modalità di inserimento e la modalità comando sono separate, ed è un po' un superpotere una volta che impari anche solo una parte del set di comandi da tastiera incredibilmente vasto. Ma la curva di apprendimento è anche piuttosto ripida!

Se sei completamente nuovo all'editing in stile vim, ti consiglio di dare un'occhiata alla [serie Vim As Your Editor di ThePrimeagen](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) su YouTube. Ti insegnerà le basi. Sappi solo che, a differenza degli editor mainstream più convenzionali, ti ci vorrà più tempo per acquisire una padronanza di base di vim. Ma una volta che ci riuscirai, anche la ricompensa sarà maggiore.

Ora, Neovim è praticamente configurabile all'infinito. Se vuoi davvero esagerare, puoi creare la tua configurazione di Neovim da zero. C'è un ottimo [corso di Typecraft su come configurare Neovim da zero](https://www.youtube.com/watch?v=zHTeCSVAFNY). E [anche ThePrimeagen ne ha uno](https://www.youtube.com/watch?v=w7i4amO_zaE).

Ma Omarchy include una configurazione completa di Neovim — il pacchetto `omarchy-nvim` — curata con amore per mostrare il meglio di ciò che è possibile ottenere fin da subito. Senza che tu debba scrivere una sola riga di configurazione! È basata su [LazyVim](https://www.lazyvim.org/), una distribuzione di plugin e configurazioni per Neovim. È fantastica.

## Nozioni di base di LazyVim

Come detto, non ti insegnerò vim in questa breve introduzione, ma posso mostrarti alcune nozioni di base di LazyVim e come muoverti.

Innanzitutto, Neovim ha il concetto di leader key. È fondamentalmente la porta d'accesso a tutti i comandi. LazyVim l'ha impostata su `Space`. Quindi premi semplicemente quel tasto, aspetta un secondo e vedrai un sacco di opzioni spiegate inline in questo modo:

Ecco alcuni comandi di base che uso in continuazione:

- `Space Space` - Trova con ricerca fuzzy qualsiasi file nella directory corrente.
- `Space S G` - Cerca in tutti i file usando grep con un'anteprima.
- `Space E` - Mostra/nascondi l'albero dei file.
- `Ctrl + W W` - Passa dall'albero dei file all'editor e viceversa.
- `Shift + H` - Spostati a sinistra tra le schede aperte (vim le chiama buffer).
- `Shift + L` - Spostati a destra tra le schede aperte.
- `Space B D` - Chiudi una scheda.
- `Space B O` - Chiudi tutte le altre schede tranne quella corrente.
- `Space G G` - Avvia LazyGit in un riquadro flottante dalla directory corrente.
- `Space U W` - Attiva/disattiva il soft wrap.

Mentre sei nell'albero dei file (`Space E` per mostrarlo, `Ctrl + W W` per spostarti lì), puoi aggiungere un nuovo file con `a` o una nuova directory con `A`. Premi `?` mentre sei nell'albero per vedere tutti i comandi.

Se vuoi imparare il linguaggio di base di vim, ho scritto della [sintassi in tre parti](https://world.hey.com/dhh/wonderful-vi-a1d034d3) e di come eseguire quelle incredibili combo!

Puoi vedere tutti i comandi possibili sulla [pagina Keymaps di LazyVim](https://www.lazyvim.org/keymaps).

## Avviare Neovim

`Super + Shift + N` avvia il tuo editor predefinito, che nelle nuove installazioni è Plain; scegli Neovim in _Setup > Defaults > Editor_ per far avviare Neovim al suo posto. Ma di solito è più facile usarlo dal terminale, spostandoti nella directory in cui vuoi lavorare e digitando `n`. `n` è l'alias di `nvim`, che per impostazione predefinita si aprirà nella directory corrente. Puoi aprire un singolo file con `n myfile.txt`.

## Usare Neovim per le modifiche con sudo

Se devi modificare file che puoi cambiare solo come super user, esegui `sudoedit /etc/sudoers.d/00-sudo-only-file`. Apre il tuo editor predefinito, quindi imposta Neovim in _Setup > Defaults > Editor_ se lo vuoi lì con tutti i tuoi plugin.
