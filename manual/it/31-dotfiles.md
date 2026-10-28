# Dotfiles

Omarchy è configurato principalmente tramite i cosiddetti dotfiles che vivono in `~/.config`. Quelli sono considerati i tuoi file per le tue modifiche. I file che vivono in `/usr/share/omarchy` appartengono a Omarchy stessa, e non dovresti metterci le mani. Se devi cambiare qualcosa in `/usr/share/omarchy`, dovresti invece sovrascrivere il valore in `~/.config`.

Le configurazioni chiave possono essere modificate direttamente dal menu Omarchy (`Super + Space`), come _Impostazioni > Monitor_, _Impostazioni > Scorciatoie_, _Impostazioni > Input_ e _Impostazioni > Configurazione > [file]_. Quando lo fai in questo modo, qualsiasi processo che necessita di un riavvio dopo le modifiche alla configurazione lo farà automaticamente dopo che avrai chiuso l'editor (Neovim per impostazione predefinita — `:wq`, ricorda! — ma puoi cambiarlo tramite _Impostazioni > Predefiniti > Editor_).

Ecco un elenco dei file chiave in `~/.config` e cosa controllano:

| File                  | Scopo              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | La configurazione principale di Hyprland. Carica i predefiniti di Omarchy più i tuoi file di override qui sotto. [Scopri di più sulle configurazioni Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Le tue scorciatoie personali e gli override dei predefiniti. |
| `~/.config/hypr/monitors.lua` | Controlla i tuoi monitor, la risoluzione e la posizione. |
| `~/.config/hypr/input.lua` | Controlla il layout della tastiera, il mouse e le impostazioni del trackpad. |
| `~/.config/hypr/looknfeel.lua` | Controlla spazi, bordi, animazioni e il resto dell'aspetto. |
| `~/.config/hypr/autostart.lua` | Controlla i processi extra avviati con la sessione. |
| `~/.config/omarchy/shell.json` | Controlla la shell Omarchy: posizione della barra, layout e widget, oltre a salvaschermo, blocco e tempi di inattività. |
| `~/.config/foot/foot.ini` | Controlla il tuo terminale (foot è il predefinito). |
| `~/.XCompose` | Definisce le tue emoji ad accesso rapido e il completamento automatico di nome/email. Assicurati di eseguire `omarchy-restart-xcompose` dopo aver apportato modifiche. |

Se finisci per fare molte modifiche per personalizzare la tua configurazione, è una buona idea fare il backup di tutti questi dotfiles. [Stow è un ottimo modo per farlo](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Avviare le tue app con la sessione

Se vuoi che qualcosa venga eseguito ogni volta che accedi — un daemon di sincronizzazione, un'app di chat, un tuo script — mettilo in `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

Questo avvia il comando come parte della sessione, così viene ripulito correttamente quando ti disconnetti di nuovo.

### Eseguire script sugli eventi di sistema

Omarchy attiva hook in una manciata di momenti, e puoi agganciare i tuoi script ad essi. Vivono in `~/.config/omarchy/hooks/<event>.d/`, una directory per evento, e ogni file eseguibile lì dentro viene eseguito quando si verifica l'evento:

| Evento | Quando viene eseguito |
| ----- | ------------ |
| `post-boot` | Subito dopo l'avvio del desktop |
| `post-update` | Verso la fine di `omarchy update`, dopo pacchetti, migrazioni e riavvii dei servizi, prima che gli strumenti mise vengano aggiornati |
| `pre-refresh-pacman` | Dopo che `omarchy refresh pacman` risincronizza la configurazione dei pacchetti, prima che aggiorni i pacchetti; un cambio di canale lo esegue durante quella stessa fase di refresh |
| `theme-set` | Dopo un cambio di tema (nome del tema in `$1`) |
| `font-set` | Dopo un cambio di carattere (nome del carattere in `$1`) |
| `battery-low` | Quando la batteria si scarica (percentuale in `$1`) |

L'hook `pre-refresh-pacman` è dove appartengono repository personalizzati o righe `IgnorePkg`, poiché viene eseguito prima della transazione dei pacchetti. Entrambi gli hook relativi agli aggiornamenti vengono eseguiti come il tuo utente dopo che Omarchy cancella la sua autorizzazione sudo memorizzata nella cache, quindi un hook che usa `sudo` ha bisogno della propria autorizzazione e potrebbe chiederti la password.

Ognuna di quelle directory contiene già un file `.sample` che mostra la forma di un hook — togli `.sample` dal nome per metterlo al lavoro. Per installare uno script che hai scritto altrove, usa `omarchy hook install post-boot ~/my-hook`, che lo copia dentro e lo rende eseguibile.

### Aggiungere le tue voci di menu

Il menu Omarchy (`Super + Space`) può essere esteso con le tue righe modificando `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Le voci sono indicizzate da un id con punti, ed è l'id a posizionarle nell'albero, quindi `personal` appare nel menu radice e `personal.notes` appare al suo interno:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Riutilizza un id esistente e sovrascriverai quella riga invece di aggiungerne una nuova. Il file viene fornito con tutti i campi disponibili documentati come commenti.

### Aggiungere le tue esportazioni, funzioni e alias della shell

Omarchy include una serie di alias ergonomici e funzioni utili, ma è molto comune voler aggiungere i propri. Dovresti aggiungere alias, funzioni ed esportazioni in `~/.bashrc`. Questo file non verrà sovrascritto dagli aggiornamenti. Se vuoi cambiare uno qualsiasi dei predefiniti di Omarchy, puoi anche aggiungerli in sicurezza qui.

### Modificare i file interni di Omarchy

Guarda, questo è il tuo computer. Puoi farci quello che vuoi, ma ti sconsiglio di apportare modifiche direttamente ai file in `/usr/share/omarchy`. Appartengono al pacchetto pacman di Omarchy, quindi le tue modifiche verranno semplicemente sovrascritte al prossimo aggiornamento. Faresti meglio a sovrascrivere invece qualsiasi valore predefinito che non ti piace nella cartella `~/.config/*`.

Puoi cambiare quasi tutto in questo modo, come le scorciatoie predefinite. Modifica semplicemente `~/.config/hypr/bindings.lua` per, diciamo, sostituire [Obsidian](https://obsidian.md/) con [Joplin](https://joplinapp.org/) (installa con `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` rimuove l'associazione esistente prima di aggiungere la sua sostituzione. Accetta gli stessi argomenti di `o.bind`, inclusi helper di avvio e opzioni di associazione. Usa `o.bind` per aggiungere un'associazione, oppure `hl.unbind` per rimuoverne una senza sostituirla.

Se insisti a smanettare sui file interni di Omarchy, passa al canale dev tramite _Aggiorna > Canale > Dev_. Questo collega Omarchy a un checkout git del codice sorgente in `~/omarchy`, che sei libero di cambiare a tuo piacimento. Non c'è nessuno qui a dirti cosa fare!

### Reimpostare qualsiasi modifica

Se finisci per fare un pasticcio con le configurazioni, puoi sempre ripristinarle ai predefiniti tramite _Aggiorna > Configurazione_ nel menu Omarchy. Oppure eseguendo `omarchy reinstall configs` per reimpostare tutto.
