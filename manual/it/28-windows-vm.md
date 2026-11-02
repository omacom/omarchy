# VM Windows

Omarchy offre un modo semplice per eseguire Windows tramite una VM Docker. Puoi installarla usando _Installa > Windows_ dal menu Omarchy (`Super + Space`).

La tua macchina ha bisogno della virtualizzazione KVM per questo, cosa che la maggior parte ha — ma a volte è disattivata nel BIOS, e l'installatore te lo dirà se è così. Vorrai anche lo spazio su disco: qualunque cosa tu dia a Windows, più circa 10GB per l'immagine stessa.

L'installatore chiede quanta RAM, quanti core CPU e quanto disco cedere (64GB o più è la soglia sensata), poi un nome utente e una password Windows. Lasciali vuoti e otterrai `docker` / `admin`. Il download richiede un po' — 10-15 minuti sono normali — e puoi seguire l'avanzamento nel browser su `http://127.0.0.1:8006`. Il browser chiede lo stesso nome utente e la stessa password prima di aprire la console.

 ![windows-vm](images/windows-vm.webp)

## Usarla

Una volta installata, avvia _Windows_ dal launcher delle app. Questo avvia la VM se non è già in esecuzione e ti connette via RDP, a schermo intero. Dalle 15-30 secondi a un avvio a freddo.

La sessione RDP trasporta audio, il tuo microfono e appunti condivisi, quindi copiare testo tra Linux e Windows funziona semplicemente. La risoluzione segue la tua finestra e Omarchy trasmette il ridimensionamento del display, così non è un pasticcio sfocato su uno schermo HiDPI.

Quando chiudi la finestra RDP, la VM si spegne automaticamente. Se preferisci lasciarla in esecuzione — diciamo che hai qualcosa che sta lavorando lì dentro — avviala invece con `omarchy windows vm launch --keep-alive`.

Il resto dei comandi è sullo stesso comando:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Condividere file

La directory `~/Windows` nella tua directory home è condivisa automaticamente con la VM. Metti lì i file se vuoi che siano accessibili a Windows. La VM non ha accesso a nessun'altra parte del tuo file system, quindi sei al sicuro da qualsiasi cosa brutta sul lato Windows. Il suo disco virtuale è disponibile su `~/.windows`.

Quei familiari percorsi home restano sui loro file system. Possono anche essere symlink a directory di tua proprietà, cosa utile quando il disco virtuale vive su un'unità più grande. L'installatore misura lo spazio libero sul file system che contiene effettivamente `~/.windows`, non necessariamente il file system che contiene la tua directory home.

Mantieni i percorsi del disco e quelli condivisi come directory separate e non sovrapposte. La rimozione svuota deliberatamente la directory del disco ma preserva la directory condivisa. Immediatamente prima dell'eliminazione, Omarchy esegue un controllo di contenimento limitato e si rifiuta di rimuovere qualsiasi cosa se quel controllo scade o non può provare che i due alberi sono separati.

Prima che la VM si avvii, Omarchy apre e fissa quelle due directory, poi monta con bind-mount gli esatti inode delle directory su ancoraggi privati per utente sotto `/var/lib/omarchy/windows/mounts`. Docker vede solo quegli ancoraggi protetti da root. Questo preserva le posizioni personalizzate del disco impedendo a un altro processo in esecuzione come te di scambiare un percorso controllato prima che il container privilegiato lo consumi. Le directory disco e condivise esistenti vengono ristrette alla modalità `0700` durante la migrazione, così altri account locali non possono sfogliarne il contenuto.

Le porte della VM sono associate solo a localhost, quindi nulla sulla tua rete può raggiungere la macchina Windows. La console web richiede anche il nome utente e la password Windows configurati, impedendo a un altro account locale di pilotare la VM tramite la porta 8006.

## Limiti e licenze

Con questa configurazione non c'è passthrough GPU, quindi non è adatta al gaming o al montaggio video. È un ottimo modo per eseguire Microsoft Office o qualsiasi altra cosa di cui hai assolutamente bisogno.

La versione installata è Windows 11 Pro, non attivata. Avrai bisogno della tua chiave di licenza per usare le funzionalità a pagamento.

Se questo computer è stato fornito con Windows, la chiave OEM è ancora nel firmware anche dopo aver installato Omarchy. Stampala con `omarchy windows key`. Quella chiave è legata a questa macchina — attiverà Windows reinstallato su questo hardware, ma di solito non attiverà la VM.

Puoi cambiare l'allocazione delle risorse in seguito rieseguendo `omarchy-windows-vm install`, che riscrive la configurazione della VM dalle tue risposte. Il file compose stesso ora vive in `/var/lib/omarchy/windows/docker-compose.yml` ed è di proprietà di root — è deliberato, così un processo in esecuzione come te non può riscriverlo e far montare all'avvio privilegiato l'intero disco nel container. Se devi modificarlo manualmente (ad esempio per montare un dispositivo USB), modificalo con `sudo` e vedi tutte le opzioni sul [progetto Dockur Windows](https://github.com/dockur/windows).

Per sbarazzarti di tutto, usa _Rimuovi > Windows_ dal menu Omarchy. Questo elimina il disco della VM e tutti i suoi dati, quindi assicurati prima che tutto ciò a cui tieni sia fuori da `~/Windows`.
