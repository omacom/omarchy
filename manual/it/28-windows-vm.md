# Windows VM

Omarchy offre un modo semplice per eseguire Windows tramite una VM Docker su macchine x86_64. Puoi installarla usando _Installa > Windows_ dal menu di Omarchy (`Super + Space`).

La tua macchina ha bisogno della virtualizzazione KVM per farlo, e la maggior parte ce l'ha — ma a volte è disattivata nel BIOS, e il programma di installazione ti avviserà se è il tuo caso. Ti servirà anche spazio su disco: tutto quello che dai a Windows, più circa 10GB per l'immagine stessa.

Il programma di installazione ti chiede quanta RAM, quanti core CPU e quanto disco assegnare (64GB o più è il minimo sensato), poi un nome utente e una password per Windows. Lasciali vuoti e otterrai `docker` / `admin`. Il download richiede un po' di tempo — 10-15 minuti sono normali — e puoi seguirne l'avanzamento nel browser all'indirizzo `http://127.0.0.1:8006`. Il browser ti chiede lo stesso nome utente e la stessa password prima di aprire la console.

 ![windows-vm](images/windows-vm.webp)

## Come usarla

Una volta installata, avvia _Windows_ dal launcher delle app. Questo avvia la VM se non è già in esecuzione e ti collega tramite RDP, a schermo intero. Dalle 15-30 secondi per un avvio a freddo.

La sessione RDP trasporta l'audio, il tuo microfono e degli appunti condivisi, quindi copiare testo tra Linux e Windows funziona e basta. La risoluzione segue la tua finestra, e Omarchy trasmette il fattore di scala del tuo display, quindi non è un pasticcio sfocato su uno schermo HiDPI.

Quando chiudi la finestra RDP, la VM si spegne automaticamente. Se preferisci lasciarla in esecuzione — diciamo che hai qualcosa che sta lavorando lì dentro — avviala invece con `omarchy windows vm launch --keep-alive`.

Gli altri controlli sono sullo stesso comando:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Condivisione dei file

La directory `~/Windows` nella tua home directory è condivisa automaticamente con la VM. Metti lì i file se vuoi che siano accessibili a Windows. La VM non ha accesso a nessun'altra parte del tuo filesystem, quindi sei al sicuro da qualsiasi cosa brutta sul lato Windows. Il suo disco virtuale è disponibile in `~/.windows`.

Quei familiari percorsi home restano sui propri filesystem. Possono anche essere symlink a directory di tua proprietà, il che è utile quando il disco virtuale si trova su un'unità più grande. Il programma di installazione misura lo spazio libero sul filesystem che contiene effettivamente `~/.windows`, non necessariamente il filesystem che contiene la tua home directory.

Mantieni il disco e i percorsi condivisi come directory separate e non sovrapposte. La rimozione svuota deliberatamente la directory del disco ma preserva la directory condivisa. Subito prima della cancellazione, Omarchy esegue un controllo di contenimento limitato nel tempo e si rifiuta di rimuovere qualsiasi cosa se quel controllo va in timeout o non può dimostrare che i due alberi sono separati.

Prima che la VM si avvii, Omarchy apre e fissa quelle due directory, poi monta in bind gli esatti inode delle directory su ancoraggi privati per utente sotto `/var/lib/omarchy/windows/mounts`. Docker vede solo quegli ancoraggi protetti da root. Questo preserva le posizioni personalizzate del disco impedendo al contempo a un altro processo in esecuzione come te di scambiare un percorso controllato prima che il contenitore privilegiato lo utilizzi. Le directory esistenti del disco e condivise vengono ristrette alla modalità `0700` durante la migrazione, in modo che altri account locali non possano sfogliarne il contenuto.

Le porte della VM sono legate solo a localhost, quindi nulla sulla tua rete può raggiungere la macchina Windows. La console web richiede inoltre il nome utente e la password Windows configurati, impedendo a un altro account locale di pilotare la VM tramite la porta 8006.

## Limiti e licenza

Con questa configurazione non c'è passthrough della GPU, quindi non è adatta al gaming o al montaggio video. È un ottimo modo per eseguire Microsoft Office o qualsiasi altra cosa tu debba assolutamente avere.

La versione installata è Windows 11 Pro, non attivata. Ti servirà una tua chiave di licenza per usare le funzionalità bloccate.

Se questo computer è stato fornito con Windows, la chiave OEM è ancora nel firmware anche dopo l'installazione di Omarchy. Stampala con `omarchy windows key`. Quella chiave è legata a questa macchina — attiverà Windows reinstallato su questo hardware, ma di solito non attiverà la VM.

Puoi modificare l'allocazione delle risorse in seguito eseguendo `omarchy windows vm install` in un terminale, che riscrive la configurazione della VM a partire dalle tue risposte. Il file compose ora si trova in `/var/lib/omarchy/windows/docker-compose.yml` ed è di proprietà di root — è deliberato, così un processo in esecuzione come te non può riscriverlo e far montare al bring-up privilegiato il tuo intero disco nel contenitore. Se hai bisogno di modificarlo a mano (per esempio per montare un dispositivo USB), modificalo con `sudo` e vedi tutte le opzioni sul [progetto Dockur Windows](https://github.com/dockur/windows).

Per sbarazzarti di tutto, usa _Rimuovi > Windows_ dal menu di Omarchy. Questo cancella il disco della VM in `~/.windows` e tutto ciò che è installato dentro Windows, quindi copia prima fuori dalla VM tutto ciò che ti serve. La tua cartella condivisa `~/Windows` viene lasciata in pace.
