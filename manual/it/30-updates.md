# Aggiornamenti

Omarchy e i tuoi pacchetti vengono mantenuti aggiornati tramite _Aggiorna > Omarchy_ nel menu di Omarchy (`Super + Space`).

Omarchy stesso è installato come normali pacchetti pacman dal [Repository dei pacchetti Omarchy](https://github.com/omacom-io/omarchy-pkgs), quindi un aggiornamento installa [l'ultima release di Omarchy](https://github.com/omacom/omarchy/releases), esegue eventuali migrazioni in sospeso per sincronizzare il sistema con la versione più recente e aggiorna tutti i pacchetti di sistema dal [Mirror Arch di Omarchy](https://github.com/omacom-io/omarchy-mirror) e da [AUR](https://aur.archlinux.org/) (se hai installato pacchetti AUR).

Quando vengono pubblicate nuove release, a destra dell'orologio apparirà un'icona con una freccia circolare. Cliccala e il processo di aggiornamento avrà inizio.

![update-available](images/update-available.webp)

### Quattro canali

Omarchy viene aggiornato attraverso quattro canali: stable, RC, edge e dev. Le nuove installazioni partono dal canale stable, che segue le [release ufficiali](https://github.com/omacom/omarchy/releases/), così come il [mirror Arch stabile di Omarchy](https://github.com/omacom-io/omarchy-mirror) che resta un mese indietro rispetto alla versione più recente, in modo da poter individuare eventuali nuove incompatibilità che richiedono modifiche alla configurazione prima che causino problemi alle persone.

Ma se vuoi aiutarci a individuare quei potenziali problemi, puoi usare il canale edge. In questo modo i tuoi pacchetti Omarchy seguiranno le ultime build di sviluppo e potrai aggiornare ai pacchetti Arch più recenti non appena saranno disponibili. Dovresti farlo solo se hai esperienza con Linux e sai come recuperare un sistema che ha problemi.

Prima di ogni nuova release principale, faremo la validazione finale usando il canale RC. Se ti interessa aiutare con gli ultimi ritocchi, vieni a trovarci in #omarchy-release-candidates su Discord.

Infine, c'è il canale dev, che collega Omarchy direttamente a un checkout git del codice sorgente in `~/omarchy`, combinato con i pacchetti edge. Dovresti usare questo canale solo se sei un utente Linux esperto, lavori direttamente su Omarchy e sei disposto a tollerare rotture.

Puoi passare da un canale all'altro usando _Aggiorna > Canale_ dal menu di Omarchy (oppure `omarchy-channel-set` nel terminale).

### Cambiare kernel

Omarchy avvia il proprio kernel `linux-omarchy`, ma puoi tenere installati altri kernel accanto ad esso, come il kernel `linux` standard di Arch o una build sperimentale che stai testando. Quando ne è presente più di uno, _Aggiorna > Kernel_ nel menu di Omarchy li elenca con un segno di spunta accanto a quello che viene avviato per impostazione predefinita. Scegline un altro, inserisci la password una volta e verrà avviato dopo il prossimo riavvio. Gli altri kernel restano nel menu di avvio, quindi puoi comunque sceglierne uno manualmente se il nuovo predefinito ti crea problemi. Nel terminale, usa `omarchy-kernel` per vedere quello predefinito attuale, `omarchy-kernel list` per vedere cosa è installato e `omarchy-kernel set <kernel>` per cambiare.

### Aggiornamenti del firmware

I pacchetti non sono l'unica cosa che diventa obsoleta. Molti laptop e periferiche distribuiscono firmware per BIOS, SSD e dock tramite il Linux Vendor Firmware Service, e _Aggiorna > Firmware_ nel menu di Omarchy scaricherà e installerà tutto ciò che è in attesa per il tuo hardware. Alla prima esecuzione installerà `fwupd`. Molti firmware possono essere scritti solo durante un riavvio, quindi non sorprenderti se te ne viene chiesto uno.

### Avviso sugli aggiornamenti diretti con pacman/yay

Se hai già familiarità con Arch, potresti essere tentato di eseguire semplicemente `pacman -Syu` o `yay -Syu` da solo, ma se lo fai perderai lo snapshot, le migrazioni e gli aggiornamenti di configurazione che Omarchy esegue insieme ai nuovi pacchetti. Ecco perché Omarchy bloccherà effettivamente un aggiornamento diretto del sistema e ti indirizzerà invece a `omarchy update`. (Se sai davvero cosa stai facendo, la protezione ti dirà come aggirarla per una singola transazione.)

### Tornare indietro dopo un aggiornamento andato male

Se mai dovessi avere un problema dopo aver eseguito un aggiornamento, puoi riportare il sistema allo snapshot creato prima dell'aggiornamento. Riavvia semplicemente e scegli nel menu di avvio lo snapshot precedente all'inizio dell'aggiornamento.

![bootloader](images/bootloader.webp)

Se in qualche modo i tuoi file di configurazione sono stati danneggiati, puoi anche eseguire una reinstallazione di Omarchy usando `omarchy reinstall` nel terminale. Questo reinstallerà tutti i pacchetti predefiniti di Omarchy, ti porterà su stable, effettuerà il downgrade di eventuali pacchetti troppo recenti e ripristinerà tutti i file di configurazione. Nota che facendo questo tutte le modifiche di configurazione utente apportate ai valori predefiniti di Omarchy verranno sovrascritte!
