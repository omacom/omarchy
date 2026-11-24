# Snapshot di sistema

Creiamo snapshot automaticamente a ogni aggiornamento di Omarchy, ma se vuoi crearne uno tuo, puoi usare `omarchy-snapshot create`.

Per avviare e ripristinare uno snapshot, lo selezioni dal boot loader Limine. Il menu di avvio resta nascosto per impostazione predefinita, quindi premi un tasto qualsiasi non appena Limine si avvia per farlo comparire.

Da quella schermata, scegli lo snapshot da avviare in base alla data e alla versione. La versione di Omarchy al momento dello snapshot è visibile nell'angolo in basso a sinistra.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Una volta dentro, comparirà una notifica per avvisarti che ti trovi in uno snapshot avviabile e, se ci fai clic sopra, avvierà il processo di ripristino. In alternativa, puoi utilizzare `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Questo ripristinerà il tuo filesystem root, ma non la tua `/home`. Quindi funziona per annullare un aggiornamento di sistema non riuscito, ma non per recuperare file personali persi.

Questo significa anche che la tua directory `~/.config` viene mantenuta così com'è. Quindi, se torni a una versione precedente di una libreria o di un'applicazione che salva i file di configurazione in un nuovo formato, dovrai sistemare la cosa manualmente.

Lo stesso vale per il registro di Omarchy stesso delle migrazioni già eseguite: si trova nella tua directory home, quindi sopravvive al ripristino. Le migrazioni eseguite dopo la creazione dello snapshot restano contrassegnate come completate, anche se le modifiche che hanno apportato al filesystem root sono state annullate, e il prossimo `omarchy update` non le eseguirà di nuovo. Quindi, se aggiorni di nuovo dopo un ripristino e manca ancora qualcosa che un aggiornamento precedente aveva configurato, è probabile che sia questo il motivo.

_Nota: questa funzionalità è disponibile solo sulle installazioni che utilizzano il boot loader Limine, che è il predefinito da Omarchy 2.0. Non è disponibile se usi GRUB o systemd-boot._
