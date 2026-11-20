# Aggiornamenti

Omarchy e i tuoi pacchetti vengono mantenuti aggiornati tramite _Update > Omarchy_ nel menu di Omarchy (`Super + Space`).

Omarchy stesso è installato come normali pacchetti pacman dal [repository dei pacchetti di Omarchy](https://github.com/omacom-io/omarchy-pkgs), quindi un aggiornamento installa [l'ultima release di Omarchy](https://github.com/omacom/omarchy/releases), esegue eventuali migrazioni in sospeso per sincronizzare il tuo sistema con l'ultima versione e aggiorna tutti i pacchetti di sistema dal [mirror Arch di Omarchy](https://github.com/omacom-io/omarchy-mirror) e da [AUR](https://aur.archlinux.org/) (se hai installato pacchetti AUR).

Quando vengono pubblicate nuove release, un'icona con una freccia circolare apparirà a destra del tuo orologio. Cliccala e il processo di aggiornamento si avvierà.

![update-available](images/update-available.webp)

### Quattro canali

Omarchy viene aggiornato attraverso quattro canali: stable, RC, edge e dev. Le nuove installazioni partono dal canale stable, che segue le [release ufficiali](https://github.com/omacom/omarchy/releases/), così come il [mirror Arch stabile di Omarchy](https://github.com/omacom-io/omarchy-mirror) che resta un mese indietro rispetto all'ultima versione, in modo da poter intercettare eventuali nuove incompatibilità che richiedono modifiche alla configurazione prima che causino problemi alle persone.

Ma se vuoi aiutare a individuare quei potenziali problemi, puoi usare il canale edge. In questo modo i tuoi pacchetti Omarchy seguiranno le ultime build di sviluppo e potrai aggiornare agli ultimi pacchetti Arch non appena sono disponibili. Dovresti farlo solo se hai esperienza con Linux e sai come ripristinare un sistema che ha problemi.

Prima di ogni nuova major release, faremo la validazione finale usando il canale RC. Se ti interessa aiutare con gli ultimi ritocchi, vieni a trovarci in #omarchy-release-candidates su Discord.

Infine, c'è il canale dev, che collega Omarchy direttamente a un checkout git del codice sorgente in `~/omarchy`, combinato con i pacchetti edge. Dovresti usare questo canale solo se sei un utente Linux esperto, lavori direttamente su Omarchy e sei disposto a tollerare rotture.

Puoi passare da un canale all'altro usando _Update > Channel_ dal menu di Omarchy (oppure `omarchy-channel-set` nel terminale).

### Cambiare kernel

Omarchy si avvia con il proprio kernel `linux-omarchy`, ma puoi tenerne altri installati accanto, come il kernel `linux` standard di Arch o una build sperimentale che stai testando. Quando ce n'è più di uno, _Update > Kernel_ nel menu di Omarchy li elenca con una spunta accanto a quello che si avvia per impostazione predefinita. Scegline un altro, inserisci la password una volta, e si avvierà dopo il prossimo riavvio. Gli altri kernel restano nel menu di avvio, così puoi comunque sceglierne uno manualmente se il nuovo predefinito ti dà problemi. Nel terminale, usa `omarchy-kernel` per vedere il predefinito attuale, `omarchy-kernel list` per vedere cosa è installato e `omarchy-kernel set <kernel>` per cambiare.

### Aggiornamenti firmware

I tuoi pacchetti non sono l'unica cosa che diventa obsoleta. Molti laptop e periferiche distribuiscono firmware per BIOS, SSD e dock tramite il Linux Vendor Firmware Service, e _Update > Firmware_ nel menu di Omarchy recupererà e installerà tutto ciò che è in attesa per il tuo hardware. La prima volta che lo esegui installa `fwupd`. Molti firmware possono essere scritti solo durante un riavvio, quindi non sorprenderti se te ne viene chiesto uno.

Quando devi modificare un'impostazione nel BIOS stesso, tieni premuto `Alt` nel menu di sistema (`Super + Escape`) e _Reboot_ si trasforma in _Reboot to BIOS_, che riavvia direttamente nella configurazione del firmware senza dover beccare il tasto giusto all'avvio. Dal terminale, è `omarchy system firmware`.

### Avviso sugli aggiornamenti diretti con pacman/yay

Se hai già familiarità con Arch, potresti essere tentato di eseguire semplicemente `pacman -Syu` o `yay -Syu` da solo, ma se lo fai perderai lo snapshot, le migrazioni e gli aggiornamenti di configurazione che Omarchy esegue insieme ai nuovi pacchetti. Ecco perché Omarchy bloccherà effettivamente un aggiornamento diretto del sistema e ti indirizzerà invece a `omarchy update`. (Se sai davvero cosa stai facendo, la protezione ti dirà come aggirarla per una singola transazione.)

### Annullare aggiornamenti andati male

Se hai mai un problema dopo aver effettuato un aggiornamento, puoi riportare il sistema allo snapshot creato prima dell'aggiornamento. Riavvia semplicemente e scegli nel menu di avvio lo snapshot precedente all'inizio dell'aggiornamento.

![bootloader](images/bootloader.webp)

Se in qualche modo i tuoi file di configurazione sono stati danneggiati, puoi anche eseguire una reinstallazione di Omarchy usando `omarchy reinstall` nel terminale. Questo reinstallerà tutti i pacchetti predefiniti di Omarchy, ti riporterà su stable ed effettuerà il downgrade di eventuali pacchetti troppo nuovi, e reimposterà tutti i file di configurazione. Nota che così facendo tutte le modifiche che hai apportato alla configurazione utente rispetto ai valori predefiniti di Omarchy verranno sovrascritte!
