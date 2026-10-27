# Installazione in dual boot

Puoi installare Omarchy su una singola partizione accanto a Windows o ad altre installazioni.

Anche questo metodo di installazione include per impostazione predefinita la crittografia LUKS per la partizione, quindi in pratica non è diverso dall'intero disco e richiede semplicemente che ci sia spazio libero disponibile sul disco.

## Fare spazio su Windows

Per installare accanto a Windows, digita `disk management` nel menu Start e seleziona l'opzione **Create and format hard disk partitions**.

 ![dual-boot-1](images/dual-boot-1.webp)

Trova la partizione appropriata, fai clic con il tasto destro e scegli **Shrink Volume**.

![dual-boot-2](images/dual-boot-2.webp)

 Inserisci la quantità di cui vuoi ridurre il volume. Nota che questa sarà la dimensione della tua futura installazione di Omarchy, partizione di avvio inclusa.

 ![dual-boot-3](images/dual-boot-3.webp)

Quando hai finito, dovresti vedere qualcosa del genere, dove in questo esempio la sezione da 50GB è dove installeremo Omarchy.

 ![dual-boot-4](images/dual-boot-4.webp)

## Installare Omarchy

Il processo di installazione di Omarchy è in pratica lo stesso del solito. Dopo aver selezionato il disco, ti verrà data l'opzione **Free space install**. Seleziona quell'opzione per evitare di cancellare l'intero disco.

 ![dual-boot-5](images/dual-boot-5.webp)

Conferma che tutto sembri a posto e aspetta che l'installazione finisca come al solito. È anche qui che potresti scegliere di installare senza crittografia (non consigliato), proprio come in un'installazione su intero disco.
 ![dual-boot-6](images/dual-boot-6.webp)

## Aggiungere altre installazioni al bootloader

Quando finisci l'installazione di Omarchy, noterai che ora il bootloader predefinito è Limine. Con questo, puoi anche aggiungere a Limine opzioni per le tue altre installazioni, come Windows.

Per farlo, esegui `limine-scan` e segui le richieste per aggiungere alla configurazione di Limine le voci che desideri. Poi, quando avvii, vedrai le tue normali opzioni per Omarchy, oltre a Windows Boot Manager o altre.

## Bitlocker

È importante notare che questo metodo di installazione non è compatibile con Bitlocker, perché crittografa l'intero disco, non solo la partizione. Se incontri un errore che dice che Bitlocker è attivo, avvia Windows, vai in **Settings -> Privacy & Security -> Device encryption** e disattiva Bitlocker. Decrittografare il disco potrebbe richiedere un po' di tempo.

 ![dual-boot-7](images/dual-boot-7.webp)
