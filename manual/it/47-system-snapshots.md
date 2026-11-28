# Snapshot di sistema

Creiamo snapshot automaticamente a ogni aggiornamento di Omarchy, ma se vuoi crearne uno tuo, puoi usare `omarchy-snapshot create`.

Il modo in cui avvii e ripristini uno snapshot dipende dal boot loader con cui si avvia la tua macchina. Le nuove installazioni UEFI usano systemd-boot; le installazioni più vecchie e le macchine BIOS usano Limine. `omarchy-boot-backend` ti dice quale hai.

## Con systemd-boot

Seleziona _Sistema > Snapshot_ nel menu di Omarchy e scegli lo snapshot da cui vuoi avviare il sistema. La macchina si riavvia una volta in quello snapshot. Oppure tieni premuto Space mentre la macchina si avvia per vedere il menu di avvio, dove ogni snapshot è elencato dal più recente al più vecchio con la sua versione di Omarchy e la data.

Uno snapshot si avvia con un livello temporaneo sopra, quindi puoi usarlo normalmente, ma tutto ciò che modifichi sparisce al riavvio successivo. Per mantenerlo, rendilo il tuo sistema: fai clic sulla notifica che appare quando accedi, seleziona _Sistema > Snapshot > Ripristina questo snapshot_, oppure esegui `omarchy-snapshot restore`. Il ripristino avviene mentre la macchina si riavvia. Il sistema com'era prima rimane nel menu di avvio come _Prima del ripristino_, e `omarchy-snapshot restore backup` lo rimette al suo posto.

Dal terminale:

- `omarchy-snapshot list` elenca gli snapshot da cui puoi avviare il sistema;
- `omarchy-snapshot boot 12` riavvia una volta nello snapshot 12;
- `omarchy-snapshot restore 12` rende lo snapshot 12 il sistema al riavvio successivo, e `omarchy-snapshot restore --cancel` ti fa cambiare idea prima di quel riavvio.

## Con Limine

Per avviare e ripristinare uno snapshot, lo selezioni dal boot loader Limine. Il menu di avvio rimane nascosto per impostazione predefinita, quindi premi un tasto qualsiasi non appena Limine si avvia per mostrarlo.

Da quella schermata, scegli lo snapshot da cui vuoi avviare il sistema in base a data e versione. La versione di Omarchy al momento dello snapshot è visibile nell'angolo in basso a sinistra.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

Quando arrivi dentro, apparirà una notifica che ti avvisa che sei in uno snapshot avviabile e, se fai clic su di essa, avvierà il processo di ripristino. In alternativa, puoi utilizzare `omarchy-snapshot restore`.

 ![snapshots-restore](images/snapshots-restore.webp)

## Cosa copre un ripristino

Un ripristino riporta indietro il tuo filesystem root, ma non la tua `/home`. Quindi funziona per annullare un aggiornamento di sistema fallito, ma non per recuperare file personali persi.

Questo significa anche che la tua directory `~/.config` viene mantenuta così com'è. Quindi, se torni a una versione precedente di una libreria o di un'applicazione che archivia i file di configurazione in un nuovo formato, dovrai sistemare la cosa manualmente.

Lo stesso vale per il registro di Omarchy su quali migrazioni sono già state eseguite: vive nella tua home directory, quindi sopravvive al ripristino. Le migrazioni eseguite dopo la creazione dello snapshot rimangono contrassegnate come completate, anche se le modifiche che hanno apportato al filesystem root sono state annullate, e il prossimo `omarchy update` non le eseguirà di nuovo. Quindi, se aggiorni di nuovo dopo un ripristino e manca ancora qualcosa che un aggiornamento precedente aveva configurato, è probabile che il motivo sia questo.
