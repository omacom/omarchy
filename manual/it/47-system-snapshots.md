# Snapshot di sistema

Creiamo snapshot automaticamente a ogni aggiornamento di Omarchy, ma se vuoi crearne uno tuo, puoi usare `omarchy-snapshot create`.

Per avviare e ripristinare uno snapshot, lo selezioni dal boot loader Limine. (Se al momento avvii direttamente alla schermata di decrittazione di Omarchy, dovrai prima selezionare Limine come opzione di avvio tramite il BIOS).

Da quella schermata, scegli lo snapshot da cui vuoi avviare in base alla data e alla versione. La versione di Omarchy al momento dello snapshot è visibile nell'angolo in basso a sinistra.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Quando arrivi all'interno, apparirà una notifica che ti avvisa che sei in uno snapshot avviabile e, se la clicchi, avvierà il processo di ripristino. In alternativa, puoi utilizzare `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Questo ripristinerà il filesystem root, ma non `/home`. Quindi funziona per annullare un aggiornamento di sistema non riuscito, ma non per recuperare file personali persi.

Questo significa anche che la directory `~/.config` viene mantenuta così com'è. Quindi, se stai tornando a una versione precedente di una libreria o di un'applicazione che memorizza i file di configurazione in un nuovo formato, dovrai sistemare la cosa manualmente.

Lo stesso vale per il registro di Omarchy delle migrazioni già eseguite: si trova nella tua home directory, quindi sopravvive al ripristino. Le migrazioni eseguite dopo la creazione dello snapshot restano contrassegnate come completate, anche se le modifiche apportate al filesystem root sono state annullate, e il prossimo `omarchy update` non le eseguirà di nuovo. Quindi, se aggiorni di nuovo dopo un ripristino e manca ancora qualcosa che un aggiornamento precedente aveva configurato, è probabilmente questo il motivo.

_Nota: questa funzionalità è disponibile solo sulle installazioni che utilizzano il boot loader Limine, che è l'impostazione predefinita da Omarchy 2.0. Non è disponibile se usi GRUB o systemd-boot._

### Saltare il menu di avvio

Se non tocchi mai il menu di avvio e vuoi semplicemente che la macchina vada dritta alla schermata di decrittazione, esegui _Setup > Direct Boot_ nel menu di Omarchy. Questo aggiunge una voce EFI che punta direttamente a Omarchy, così il firmware lo avvia senza fermarsi a Limine.

Il compromesso è quello menzionato all'inizio: con l'avvio diretto attivato, per accedere a uno snapshot devi prima selezionare Limine dal menu di avvio del BIOS. Esegui di nuovo _Setup > Direct Boot_ per rimuovere la voce e tornare ad avviare tramite Limine. Alcuni firmware non gradiscono le voci EFI personalizzate, quindi la configurazione si rifiuta di essere eseguita su firmware American Megatrends e Apple.
