# Per iniziare

Omarchy si installa usando una ISO. Puoi scegliere tra un'installazione su intero disco, che occupa l'intera unità, o un'installazione nello spazio libero, che colloca Omarchy nello spazio non allocato su un'unità — è così che fai il dual boot accanto a Windows o a un altro OS (vedi [installazione in dual boot](50-dual-boot-install.md) — nota che prima dovrai disattivare BitLocker in Windows). In entrambi i casi, l'installazione usa per impostazione predefinita la crittografia completa, e l'opzione su intero disco cancellerà l'unità selezionata, quindi assicurati di fare un backup prima di usarne una esistente!

[Scarica la ISO di Omarchy](https://omarchy.org/) prima, mettila su una chiavetta USB (usa [Rufus](https://rufus.ie/) su Windows, [balenaEtcher](https://etcher.balena.io/) su Mac, o [caligula](https://github.com/ifd3f/caligula) su Linux), e avviala dalla chiavetta.

_Devi disattivare Secure Boot e/o TPM nel BIOS. Devi disattivarli per poter installare Omarchy. Sono schemi di sicurezza Microsoft pensati per Windows e per le distribuzioni Linux affiliate a Microsoft._

Poi rispondi alle domande di configurazione, e confermale così:

 ![install-config](images/install-config.webp)

Poi seleziona un'unità per l'installazione, e rilassati a guardare lo spettacolo dell'installazione. Può concludersi in meno di un minuto sulle macchine moderne più veloci, ma non dovrebbe richiedere più di 5 minuti nemmeno su un computer più vecchio.

 ![install-done](images/install-done.webp)

Ora sei pronto per Omarchy!

### Usa una tastiera cablata o a 2.4ghz!

La crittografia dell'intero disco non ti permetterà di inserire la password da una tastiera Bluetooth all'avvio. Proprio come non puoi usare una tastiera Bluetooth per entrare nel BIOS su un PC. Ti servirà una tastiera che usi un dongle a 2.4ghz o un cavo (che comunque è molto meglio per la latenza!). Personalmente adoro la [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Installazione per un altro proprietario

Se stai preparando una macchina per qualcun altro — un familiare, un nuovo dipendente, un acquirente — non dovresti rispondere alle domande personali al posto suo. Premi `Ctrl + C` nella primissima schermata dell'installer (la selezione della tastiera), e Omarchy proporrà di preparare la macchina per un altro proprietario. Il sistema si installa subito, ma tutta la configurazione personale — layout della tastiera, nome utente, password — è rimandata al primo avvio della macchina. L'unità è comunque crittografata per impostazione predefinita, e la password che il nuovo proprietario sceglie a quel primo avvio diventa anche la password di crittografia. (Anche una macchina che hai già usato può essere ceduta senza reinstallare — vedi [reimpostare il computer](48-security.md).)

### Installazioni non presidiate

La ISO può anche installarsi completamente da sola — senza tastiera, senza procedura guidata — quando le viene fornita la sua configurazione su una seconda unità. È il modo per trattare Omarchy come immagine di base per VM e macchine di una flotta. Vedi [installazioni non presidiate](51-unattended-installs.md).

### Installazioni senza crittografia

Omarchy si installa con la crittografia per impostazione predefinita. È la scelta sicura e responsabile per qualsiasi computer che possa essere perso o rubato. Non vuoi che chiunque abbia accesso al tuo hardware possa accedere ai tuoi dati!

Ma in circostanze speciali, come installazioni remote di Omarchy su computer protetti o per installazioni usa e getta senza dati sensibili, potresti voler installare senza crittografia. Puoi premere `Ctrl + C` alla conferma della formattazione del disco per passare a un'installazione senza crittografia.

### Lingua

Omarchy parla 50 lingue — lo stesso set di omarchy.org — e l'inglese è l'impostazione predefinita. Per cambiarla, apri il menu di Omarchy e vai su _Setup > Region > Language_, oppure esegui `omarchy language <code>` in un terminale (`omarchy language list` mostra i codici). Il menu, il desktop e le notifiche di Omarchy cambiano lingua immediatamente, e anche ogni applicazione che apri successivamente fa lo stesso. Le app già aperte cambiano quando le riavvii.

Per mantenere la lingua ma scrivere date, orari, numeri, denaro, unità e formati di carta come fa un'altra regione (inglese con date europee e orologio a 24 ore, per esempio), scegli una regione sotto _Setup > Region > Formats_, dove ogni scelta mostra un esempio, oppure esegui `omarchy region formats <code>` (`omarchy region formats list` mostra i codici). _Same as language_ torna ai formati propri della lingua. Come un cambio di lingua, ha effetto sulle app che apri successivamente.

### Aiuto se sei bloccato

Se rimani bloccato, di solito trovi qualcuno disposto ad aiutarti nel canale _#omarchy-help_ su [Discord della community](https://omarchy.org/discord).
