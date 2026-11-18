# Dotfiles

Omarchy si configura principalmente tramite i cosiddetti dotfile che si trovano in `~/.config`. Quelli sono considerati file tuoi, per le tue modifiche. I file che si trovano in `/usr/share/omarchy` appartengono a Omarchy stesso, e non dovresti metterci mano. Se devi cambiare qualcosa in `/usr/share/omarchy`, dovresti invece sovrascrivere il valore in `~/.config`.

Le configurazioni principali possono essere modificate direttamente dal menu di Omarchy (`Super + Space`), come _Setup > Keyboard > Keybindings_, _Setup > Input_ e _Setup > Config > [file]_. Quando lo fai in questo modo, qualsiasi processo che deve essere riavviato dopo le modifiche alla configurazione lo sarà automaticamente dopo che avrai chiuso l'editor (Neovim per impostazione predefinita — `:wq`, ricordalo! — ma puoi cambiarlo tramite _Setup > Defaults > Editor_).

Ecco un elenco dei file principali in `~/.config` e di cosa controllano:

| File                  | Scopo              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | La configurazione principale di Hyprland. Carica i valori predefiniti di Omarchy più i tuoi file di override qui sotto. [Scopri di più sulle configurazioni di Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Le tue associazioni di tasti e gli override di quelle predefinite. |
| `~/.config/hypr/monitors.lua` | Le impostazioni del monitor che il pannello del monitor non copre, come la rotazione, le modalità extra o il mantenimento di un monitor spento. |
| `~/.config/hypr/input.lua` | Controlla il layout della tastiera, il mouse e le impostazioni del trackpad. |
| `~/.config/hypr/looknfeel.lua` | Controlla spazi, bordi, animazioni e il resto dell'aspetto. |
| `~/.config/hypr/autostart.lua` | Controlla i processi extra avviati con la sessione. |
| `~/.config/omarchy/shell.json` | Controlla la shell di Omarchy: posizione della barra, layout e widget, più i tempi di screensaver, blocco e inattività. |
| `~/.config/foot/foot.ini` | Controlla il tuo terminale (foot è quello predefinito). |
| `~/.XCompose` | Definisce le tue emoji ad accesso rapido e il completamento automatico di nome/email. Assicurati di eseguire `omarchy-restart-xcompose` dopo aver apportato modifiche. |

Se finisci per apportare molte modifiche per personalizzare la tua configurazione, è una buona idea fare il backup di tutti questi dotfile. [Stow è un ottimo modo per farlo](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Avviare le tue app con la sessione

Se vuoi che qualcosa venga eseguito ogni volta che accedi — un demone di sincronizzazione, un'app di chat, un tuo script — mettilo in `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

In questo modo il comando viene avviato come parte della sessione, quindi viene ripulito correttamente quando ti disconnetti di nuovo.

### Eseguire script in risposta agli eventi di sistema

Omarchy attiva degli hook in una manciata di momenti, e puoi agganciarci i tuoi script. Si trovano in `~/.config/omarchy/hooks/<event>.d/`, una directory per evento, e ogni file eseguibile al suo interno viene eseguito quando si verifica l'evento:

| Evento | Quando viene eseguito |
| ----- | ------------ |
| `post-boot` | Subito dopo l'avvio del desktop |
| `post-update` | Verso la fine di `omarchy update`, dopo pacchetti, migrazioni e riavvii dei servizi, prima che vengano aggiornati gli strumenti mise |
| `pre-refresh-pacman` | Dopo che `omarchy refresh pacman` ha risincronizzato la configurazione dei pacchetti, prima che aggiorni i pacchetti; un cambio di canale lo esegue durante la stessa fase di refresh |
| `theme-set` | Dopo un cambio di tema (nome del tema in `$1`) |
| `font-set` | Dopo un cambio di font (nome del font in `$1`) |
| `battery-low` | Quando la batteria si sta scaricando (percentuale in `$1`) |

L'hook `pre-refresh-pacman` è il posto a cui appartengono i repository personalizzati o le righe `IgnorePkg`, poiché viene eseguito prima della transazione dei pacchetti. Entrambi gli hook relativi agli aggiornamenti vengono eseguiti con il tuo utente dopo che Omarchy ha cancellato la sua autorizzazione sudo memorizzata nella cache, quindi un hook che usa `sudo` ha bisogno di una propria autorizzazione e potrebbe chiederti la password.

Ognuna di queste directory contiene già un file `.sample` che mostra la forma di un hook — togli `.sample` dal nome per metterlo al lavoro. Per installare uno script che hai scritto altrove, usa `omarchy hook install post-boot ~/my-hook`, che lo copia dentro e lo rende eseguibile.

### Aggiungere le tue voci di menu

Il menu di Omarchy (`Super + Space`) può essere esteso con le tue righe modificando `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Le voci sono identificate da un id con punti, ed è l'id a posizionarle nell'albero, quindi `personal` compare nel menu principale e `personal.notes` compare al suo interno:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Riutilizza un id esistente e sovrascriverai quella riga invece di aggiungerne una nuova. Il file viene fornito con tutti i campi disponibili documentati come commenti.

### Aggiungere i tuoi export della shell, funzioni e alias

Omarchy viene fornito con un sacco di alias ergonomici e funzioni utili, ma è molto comune voler aggiungere i tuoi. Dovresti aggiungere alias, funzioni ed export in `~/.bashrc`. Questo file non verrà sovrascritto durante gli aggiornamenti. Se vuoi cambiare uno qualsiasi dei valori predefiniti di Omarchy, puoi aggiungerli in sicurezza anche qui.

### Impostare le variabili d'ambiente per il desktop

Gli export della sessione desktop appartengono a `~/.config/uwsm/env.d/`. Questi file vengono eseguiti prima dell'avvio del desktop, quindi un errore della shell può rimandarti alla schermata di accesso. Tieni aperto un terminale funzionante mentre li modifichi. Per disabilitare un override, spostalo fuori da `env.d`. Vedi [ripristino dell'accesso](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) se una modifica impedisce l'accesso.

### Modificare i file interni di Omarchy

Senti, questo è il tuo computer. Puoi farci quello che vuoi, ma ti sconsiglio di apportare modifiche direttamente ai file in `/usr/share/omarchy`. Appartengono al pacchetto pacman di Omarchy, quindi le tue modifiche verranno semplicemente sovrascritte al prossimo aggiornamento. Farai meglio a sovrascrivere semplicemente qualsiasi valore predefinito che non ti piace nella cartella `~/.config/*`.

Puoi cambiare praticamente tutto in questo modo, come le associazioni di tasti predefinite. Basta modificare `~/.config/hypr/bindings.lua` per, diciamo, sostituire [Obsidian](https://obsidian.md/) con [Joplin](https://joplinapp.org/) (installa con `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` rimuove l'associazione esistente prima di aggiungere quella sostitutiva. Accetta gli stessi argomenti di `o.bind`, inclusi gli helper di avvio e le opzioni di associazione. Usa `o.bind` per aggiungere un'associazione, o `hl.unbind` per rimuoverne una senza sostituirla.

Se insisti a mettere mano ai file interni di Omarchy, passa al canale dev tramite _Update > Channel > Dev_. In questo modo Omarchy viene collegato a un checkout git del codice sorgente in `~/omarchy`, che sei libero di modificare a tuo piacimento. Qui non c'è nessuno che venga a dirti cosa fare!

### Reimpostare qualsiasi modifica

Se finisci per fare un pasticcio con le configurazioni, puoi sempre ripristinarle ai valori predefiniti tramite _Update > Config_ nel menu di Omarchy. Oppure eseguendo `omarchy reinstall configs` per reimpostare tutto.
