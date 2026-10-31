# Installazione in dual boot

Puoi installare Omarchy su una singola partizione accanto a Windows o ad altre installazioni.

Questo metodo di installazione include comunque la crittografia LUKS per la partizione per impostazione predefinita, quindi in pratica non è diverso dall'installazione su intero disco e richiede semplicemente che sul disco sia disponibile spazio libero.

## Liberare spazio su Windows

Per installare accanto a Windows, digita `disk management` nel menu Start e seleziona l'opzione **Crea e formatta le partizioni del disco rigido**.

 ![dual-boot-1](images/dual-boot-1.webp)

Trova la partizione appropriata, fai clic con il pulsante destro del mouse e scegli **Riduci volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Inserisci la quantità di cui vuoi ridurre il volume. Tieni presente che questa sarà la dimensione della tua futura installazione di Omarchy, inclusa la partizione di avvio.

 ![dual-boot-3](images/dual-boot-3.webp)

Quando hai finito, dovresti vedere qualcosa di simile, dove la sezione da 50GB è quella in cui installeremo Omarchy in questo esempio.

 ![dual-boot-4](images/dual-boot-4.webp)

## Installare Omarchy

Il processo di installazione di Omarchy è in pratica lo stesso del solito. Dopo aver selezionato il disco, ti verrà data l'opzione **Installazione nello spazio libero**. Seleziona quell'opzione per evitare di cancellare l'intero disco.

 ![dual-boot-5](images/dual-boot-5.webp)

Conferma che tutto sembri a posto e attendi che l'installazione finisca come al solito. È anche qui che puoi scegliere di installare senza crittografia (non consigliato), proprio come in un'installazione su intero disco.
 ![dual-boot-6](images/dual-boot-6.webp)

## Aggiungere altre installazioni al bootloader

Quando finisci l'installazione di Omarchy, noterai che ora il bootloader predefinito è Limine. Con questo, puoi anche aggiungere a Limine opzioni per le tue altre installazioni, come Windows.

Per aggiungere altri sistemi operativi, esegui `limine-scan` e segui le istruzioni per aggiungere le voci che vuoi alla configurazione di Limine. Il menu di avvio rimane nascosto per impostazione predefinita e avvia Omarchy dopo un secondo. Per scegliere Windows o un'altra voce, premi un tasto qualsiasi non appena Limine si avvia; quando compare il menu, usa i tasti freccia per selezionare una voce e premi Enter. Se Omarchy si avvia prima che tu prema un tasto, riavvia e riprova. Se hai attivato _Setup > Direct Boot_, il firmware salta del tutto Limine, quindi scegli Limine dal menu di avvio del BIOS oppure esegui di nuovo _Setup > Direct Boot_ per rimuovere la voce.

## Bitlocker

È importante notare che questo metodo di installazione non è compatibile con Bitlocker, perché Bitlocker crittografa l'intero disco, non solo la partizione. Se riscontri un errore che indica che Bitlocker è abilitato, avvia Windows, vai su **Impostazioni -> Privacy e sicurezza -> Crittografia dispositivo** e disattiva Bitlocker. La decrittografia del disco potrebbe richiedere un po' di tempo.

 ![dual-boot-7](images/dual-boot-7.webp)
