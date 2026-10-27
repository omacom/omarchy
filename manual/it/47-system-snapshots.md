# Snapshot di sistema

Creiamo snapshot automaticamente a ogni aggiornamento di Omarchy, ma se vuoi crearne uno tuo, puoi usare `omarchy-snapshot create`.

Per avviare e ripristinare uno snapshot, lo selezioni dal bootloader Limine. (Se al momento avvii direttamente nella schermata di decrittazione di Omarchy, dovrai prima selezionare Limine come opzione di avvio tramite il BIOS.)

Da quella schermata, scegli lo snapshot in cui vuoi avviarti in base a data e versione. La versione di Omarchy al momento dello snapshot si vede nell'angolo in basso a sinistra.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Quando arrivi dentro, comparirà una notifica che ti avvisa che sei in uno snapshot avviabile e, se ci fai clic sopra, avvierà il processo di ripristino. In alternativa, puoi usare `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

Questo ripristinerà il filesystem root, ma non la tua `/home`. Quindi funziona per annullare un aggiornamento di sistema andato male, ma non per recuperare file personali persi.

Questo significa anche che la tua directory `~/.config` viene mantenuta così com'è. Quindi, se stai tornando a una versione precedente di una libreria o applicazione che memorizza i file di configurazione in un nuovo formato, dovrai sistemare la questione manualmente.

_Nota: questa funzione è disponibile solo sulle installazioni che usano il bootloader Limine, che è l'impostazione predefinita da Omarchy 2.0. Non è disponibile se usi GRUB o systemd-boot._

### Saltare il menu di avvio

Se non tocchi mai il menu di avvio e vuoi semplicemente che la macchina vada dritta alla schermata di decrittazione, apri _Impostazioni > Avvio diretto_ nel menu di Omarchy. Questo aggiunge una voce EFI che punta direttamente a Omarchy, così il firmware lo avvia senza fermarsi a Limine.

Il compromesso è quello menzionato all'inizio: con l'avvio diretto attivo, arrivare a uno snapshot significa prima scegliere Limine dal menu di avvio del BIOS. Apri di nuovo _Impostazioni > Avvio diretto_ per rimuovere la voce e tornare ad avviarti tramite Limine. Alcuni firmware non gradiscono le voci EFI personalizzate, quindi la configurazione si rifiuta di eseguirsi su firmware American Megatrends e Apple.
