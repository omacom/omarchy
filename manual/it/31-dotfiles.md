# Dotfiles

Omarchy si configura principalmente tramite i cosiddetti dotfiles che si trovano in `~/.config`. Quelli sono considerati i tuoi file, da modificare come vuoi. I file che si trovano in `/usr/share/omarchy` appartengono a Omarchy stesso, e non dovresti metterci mano. Se devi modificare qualcosa in `/usr/share/omarchy`, dovresti invece sovrascrivere il valore in `~/.config`.

Le configurazioni principali si possono modificare direttamente dal menu di Omarchy (`Super + Space`), ad esempio _Setup > Keyboard > Keybindings_, _Setup > Input_ e _Setup > Config > [file]_. Quando lo fai in questo modo, qualsiasi processo debba essere riavviato dopo le modifiche alla configurazione lo sarà automaticamente quando chiudi l'editor (Neovim per impostazione predefinita — `:wq`, ricordalo! — ma puoi cambiarlo tramite _Setup > Defaults > Editor_).

Ecco un elenco dei file principali in `~/.config` e di cosa controllano:

| File                  | Scopo              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | La configurazione principale di Hyprland. Carica le impostazioni predefinite di Omarchy più i tuoi file di override qui sotto. [Scopri di più sulle configurazioni di Hyprland](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Le tue scorciatoie da tastiera e gli override di quelle predefinite. |
| `~/.config/hypr/monitors.lua` | Impostazioni dei monitor che il pannello dei monitor non copre, come rotazione, modalità extra o mantenere un monitor spento. |
| `~/.config/hypr/input.lua` | Controlla layout della tastiera, mouse e impostazioni del trackpad. |
| `~/.config/hypr/looknfeel.lua` | Controlla spazi, bordi, animazioni e il resto dell'aspetto. |
| `~/.config/hypr/autostart.lua` | Controlla i processi extra avviati con la sessione. |
| `~/.config/omarchy/shell.json` | Controlla la shell di Omarchy: posizione della barra, layout e widget, più screensaver, blocco e tempi di inattività. |
| `~/.config/foot/foot.ini` | Controlla il tuo terminale (foot è quello predefinito). |
| `~/.XCompose` | Definisce le tue emoji ad accesso rapido e il completamento automatico di nome/email. Assicurati di eseguire `omarchy-restart-xcompose` dopo aver apportato modifiche. |

Se finisci per apportare molte modifiche per personalizzare la tua configurazione, è una buona idea fare il backup di tutti questi dotfiles. [Stow è un ottimo modo per farlo](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### Avviare le tue app con la sessione

Se vuoi che qualcosa venga eseguito ogni volta che accedi — un demone di sincronizzazione, un'app di chat, un tuo script — mettilo in `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

In questo modo il comando viene avviato come parte della sessione, quindi viene terminato correttamente quando ti disconnetti di nuovo.

### Eseguire script in risposta agli eventi di sistema

Omarchy attiva degli hook in una manciata di momenti, e puoi agganciarci i tuoi script. Si trovano in `~/.config/omarchy/hooks/<event>.d/`, una directory per evento, e ogni file lì dentro che non finisce in `.sample` viene eseguito con bash quando si verifica l'evento:

| Evento | Quando viene eseguito |
| ----- | ------------ |
| `post-boot` | Subito dopo l'avvio del desktop |
| `post-update` | Verso la fine di `omarchy update`, dopo pacchetti, migrazioni e riavvii dei servizi, prima che vengano aggiornati gli strumenti mise |
| `pre-refresh-pacman` | Dopo che `omarchy refresh pacman` ha risincronizzato la configurazione dei pacchetti, prima che aggiorni i pacchetti; un cambio di canale lo esegue durante quello stesso passaggio di refresh |
| `theme-set` | Dopo un cambio di tema (nome del tema in `$1`) |
| `font-set` | Dopo un cambio di font (nome del font in `$1`) |
| `battery-low` | Quando la batteria è scarica (percentuale in `$1`) |

L'hook `pre-refresh-pacman` è il posto a cui appartengono repository personalizzati o righe `IgnorePkg`, visto che viene eseguito prima della transazione dei pacchetti. Entrambi vengono eseguiti come il tuo utente. `post-update` viene eseguito mentre l'autorizzazione sudo di `omarchy update` è ancora valida, quindi un hook che usa `sudo` non ti chiederà di nuovo la password; `pre-refresh-pacman` viene eseguito subito dopo che `omarchy refresh pacman` ha usato sudo a sua volta.

Ognuna di quelle directory contiene già un file `.sample` che mostra la forma di un hook — togli `.sample` dal nome per metterlo al lavoro. Per installare uno script che hai scritto altrove, usa `omarchy hook install post-boot ~/my-hook`, che lo copia lì dentro e lo rende eseguibile.

### Aggiungere le tue voci di menu

Il menu di Omarchy (`Super + Space`) può essere esteso con le tue voci modificando `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Le voci sono identificate da un id con punti, ed è l'id a posizionarle nell'albero, quindi `personal` compare nel menu principale e `personal.notes` compare al suo interno:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Riutilizza un id esistente e sovrascrivi quella voce invece di aggiungerne una nuova. Il file viene fornito con tutti i campi disponibili documentati come commenti.

### Aggiungere export, funzioni e alias della shell personalizzati

Omarchy viene fornito con un sacco di alias ergonomici e funzioni utili, ma è molto comune voler aggiungere i propri. Dovresti aggiungere alias, funzioni ed export in `~/.bashrc`. Questo file non verrà sovrascritto con gli aggiornamenti. Se vuoi modificare una qualsiasi delle impostazioni predefinite di Omarchy, puoi anche aggiungerle qui in tutta sicurezza.

### Impostare variabili d'ambiente per il desktop

Gli export della sessione desktop appartengono a `~/.config/uwsm/env.d/`. Questi file vengono eseguiti prima dell'avvio del desktop, quindi un errore della shell può rimandarti alla schermata di accesso. Tieni aperto un terminale funzionante mentre li modifichi. Per disabilitare un override, spostalo fuori da `env.d`. Vedi [ripristino dell'accesso](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen) se una modifica impedisce l'accesso.

### Modificare i file interni di Omarchy

Senti, questo è il tuo computer. Puoi farci quello che vuoi, ma ti sconsiglio di modificare direttamente i file in `/usr/share/omarchy`. Appartengono al pacchetto pacman di Omarchy, quindi le tue modifiche verranno semplicemente sovrascritte al prossimo aggiornamento. Farai meglio a sovrascrivere qualsiasi valore predefinito che non ti piace nella cartella `~/.config/*`.

In questo modo puoi modificare praticamente tutto, come le scorciatoie da tastiera predefinite. Basta modificare `~/.config/hypr/bindings.lua` per, ad esempio, sostituire [Obsidian](https://obsidian.md/) con [Joplin](https://joplinapp.org/) (installalo con `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` rimuove l'associazione esistente prima di aggiungere la sua sostituta. Accetta gli stessi argomenti di `o.bind`, inclusi gli helper di avvio e le opzioni di associazione. Usa `o.bind` per aggiungere un'associazione, oppure `hl.unbind` per rimuoverne una senza sostituirla.

Se insisti a mettere mano ai file interni di Omarchy, passa al canale dev tramite _Update > Channel > Dev_. Questo collega Omarchy a un checkout git del codice sorgente in `~/omarchy`, che sei libero di modificare a tuo piacimento. Qui non c'è nessuno che possa dirti cosa fare!

### Reimpostare qualsiasi modifica

Se finisci per fare un casino con le configurazioni, puoi sempre ripristinarle ai valori predefiniti tramite _Update > Config_ nel menu di Omarchy. Oppure eseguendo `omarchy reinstall configs` per reimpostare tutto.
