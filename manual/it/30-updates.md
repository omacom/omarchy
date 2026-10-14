# Aggiornamenti

Omarchy e i tuoi pacchetti sono mantenuti aggiornati tramite _Aggiorna > Omarchy_ nel menu Omarchy (`Super + Space`).

Omarchy stesso è installato come normali pacchetti pacman dal [Repository pacchetti Omarchy](https://github.com/omacom-io/omarchy-pkgs), quindi un aggiornamento installa [l'ultima versione di Omarchy](https://github.com/omacom/omarchy/releases), esegue eventuali migrazioni in sospeso per sincronizzare il tuo sistema con l'ultima versione e aggiorna tutti i pacchetti di sistema dal [Mirror Arch di Omarchy](https://github.com/omacom-io/omarchy-mirror) e dall'[AUR](https://aur.archlinux.org/) (se hai installato pacchetti AUR).

Quando vengono pubblicate nuove versioni, un'icona a freccia circolare apparirà a destra dell'orologio. Fai clic su di essa e il processo di aggiornamento inizierà.

![update-available](images/update-available.webp)

### Quattro canali

Omarchy è aggiornato lungo quattro canali: stabile, RC, edge e dev. Le nuove installazioni partono dal canale stabile, che segue le [versioni ufficiali](https://github.com/omacom/omarchy/releases/), oltre al [mirror Arch stabile di Omarchy](https://github.com/omacom-io/omarchy-mirror) che è indietro di un mese rispetto all'ultima versione, così possiamo intercettare eventuali nuove incompatibilità che richiedono modifiche alla configurazione prima che causino problemi alle persone.

Ma se vuoi aiutare a individuare quei potenziali problemi, puoi usare il canale edge. Questo manterrà i tuoi pacchetti Omarchy allineati alle ultime build di sviluppo e ti permetterà di aggiornare agli ultimi pacchetti Arch non appena sono disponibili. Dovresti farlo solo se hai esperienza con Linux e sai come recuperare un sistema che ha problemi.

Prima di qualsiasi nuova versione principale, faremo la convalida finale usando il canale RC. Se sei interessato ad aiutare con la rifinitura finale, vieni a trovarci in #omarchy-release-candidates su Discord.

Infine, c'è il canale dev, che collega Omarchy direttamente a un checkout git del codice sorgente in `~/omarchy`, combinato con i pacchetti edge. Dovresti usare questo canale solo se sei un utente Linux esperto, lavori direttamente su Omarchy e sei disposto a tollerare rotture.

Puoi passare da un canale all'altro usando _Aggiorna > Canale_ dal menu Omarchy (oppure `omarchy-channel-set` nel terminale).

### Aggiornamenti del firmware

I tuoi pacchetti non sono l'unica cosa che diventa obsoleta. Molti portatili e periferiche distribuiscono firmware BIOS, SSD e dock tramite il Linux Vendor Firmware Service, e _Aggiorna > Firmware_ nel menu Omarchy recupererà e installerà tutto ciò che il tuo hardware ha in attesa. Installa `fwupd` la prima volta che lo esegui. Molto firmware può essere scritto solo durante un riavvio, quindi non sorprenderti se te ne verrà chiesto uno.

### Avviso sugli aggiornamenti diretti pacman/yay

Se hai già familiarità con Arch, potresti essere tentato di eseguire semplicemente `pacman -Syu` o `yay -Syu` da solo, ma se lo fai perderai snapshot, migrazioni e aggiornamenti di configurazione che Omarchy esegue insieme ai nuovi pacchetti. Ecco perché Omarchy fermerà effettivamente un aggiornamento di sistema diretto e ti indicherà invece `omarchy update`. (Se sai davvero cosa stai facendo, la protezione ti dirà come aggirarla per una singola transazione.)

### Ripristinare aggiornamenti difettosi

Se mai avessi un problema dopo aver fatto un aggiornamento, puoi ripristinare il tuo sistema allo snapshot scattato prima dell'aggiornamento. Riavvia semplicemente e scegli nel menu di avvio lo snapshot di prima che iniziassi l'aggiornamento.

![bootloader](images/bootloader.webp)

Se in qualche modo i tuoi file di configurazione sono stati corrotti, puoi anche eseguire una reinstallazione di Omarchy usando `omarchy reinstall` nel terminale. Questo reinstallerò tutti i pacchetti Omarchy predefiniti, ti metterà su stabile e farà il downgrade di eventuali pacchetti troppo nuovi, e reimposterà tutti i file di configurazione. Nota che così facendo tutte le modifiche alla configurazione utente rispetto ai predefiniti di Omarchy verranno sovrascritte!
