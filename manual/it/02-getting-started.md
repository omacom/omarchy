# Per iniziare

Omarchy viene installato tramite una ISO. Puoi scegliere tra un'installazione su disco intero, che occupa l'intero disco, o un'installazione nello spazio libero, che mette Omarchy nello spazio non allocato di un disco — è così che fai il dual boot accanto a Windows o a un altro OS (vedi [installazione in dual-boot](50-dual-boot-install.md) — nota che prima dovrai disattivare BitLocker in Windows). In entrambi i casi, l'installazione usa per impostazione predefinita la crittografia completa, e l'opzione su disco intero cancellerà il disco selezionato, quindi assicurati di fare un backup prima di usarne uno esistente!

Su un Mac Apple Silicon, l'installazione avviene invece da macOS, senza ISO né chiavetta USB. Vedi [Omarchy per Apple Silicon](44-mac-support.md#omarchy-for-apple-silicon).

Prima [scarica l'ISO di Omarchy](https://omarchy.org/), mettila su una chiavetta USB (usa [Rufus](https://rufus.ie/) su Windows, [balenaEtcher](https://etcher.balena.io/) su Mac, o [caligula](https://github.com/ifd3f/caligula) su Linux) e avvia dalla chiavetta.

_Devi disattivare Secure Boot e/o TPM nel BIOS. Devi disattivarli per poter installare Omarchy. Sono schemi di sicurezza Microsoft pensati per Windows e per le distribuzioni Linux affiliate a Microsoft._

Poi rispondi alle domande di configurazione e confermale così:

 ![install-config](images/install-config.webp)

Poi seleziona un disco per l'installazione e rilassati a guardare lo spettacolo dell'installazione. Può finire in meno di un minuto sulle macchine moderne più veloci, ma non dovrebbe richiedere più di 5 minuti nemmeno su un computer più vecchio.

 ![install-done](images/install-done.webp)

Ora sei pronto per Omarchy!

### Usa una tastiera cablata o 2.4ghz!

La crittografia completa del disco non ti permetterà di inserire la password da una tastiera Bluetooth all'avvio. Proprio come non puoi usare una tastiera Bluetooth per entrare nel BIOS su un PC. Ti servirà una tastiera che usi un dongle 2.4ghz o un cavo (comunque molto meglio per la latenza!). Personalmente adoro la [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Installazione per un altro proprietario

Se stai preparando una macchina per qualcun altro — un familiare, un nuovo dipendente, un acquirente — non dovresti rispondere alle domande personali al posto suo. Premi `Ctrl + C` nella primissima schermata dell'installer (la selezione della tastiera) e Omarchy proporrà invece di preparare la macchina per un altro proprietario. Il sistema si installa subito, ma tutta la configurazione personale — layout della tastiera, nome utente, password — viene rimandata al primo avvio della macchina. Il disco è comunque crittografato per impostazione predefinita e la password che il nuovo proprietario sceglie a quel primo avvio diventa anche la password di crittografia. (Anche una macchina che hai già usato può essere ceduta senza reinstallazione — vedi [reimpostazione del computer](48-security.md).)

### Installazioni non assistite

L'ISO può anche installarsi completamente da sola — senza tastiera, senza procedura guidata — quando le viene fornita la sua configurazione su un secondo disco. È il modo per trattare Omarchy come immagine di base per VM e flotte di macchine. Vedi [installazioni non assistite](51-unattended-installs.md).

### Installazioni senza crittografia

Omarchy viene installato con la crittografia per impostazione predefinita. È la scelta sicura e responsabile per qualsiasi computer che possa essere perso o rubato. Non vuoi che chiunque abbia accesso al tuo hardware possa accedere ai tuoi dati!

Ma in circostanze speciali, come installazioni remote di Omarchy su computer protetti o installazioni usa e getta senza dati sensibili, potresti voler installare senza crittografia. Puoi premere `Ctrl + C` alla conferma della formattazione del disco per passare a un'installazione senza crittografia.

### Lingua

Omarchy parla 50 lingue — lo stesso insieme di omarchy.org — e l'inglese è la lingua predefinita. Per cambiarla, apri il menu di Omarchy e vai in _Setup > Region > Language_, oppure esegui `omarchy language <code>` in un terminale (`omarchy language list` mostra i codici). Il menu, il desktop e le notifiche di Omarchy cambiano lingua immediatamente, e anche ogni applicazione che apri dopo fa lo stesso. Le app già aperte cambiano lingua quando le riavvii.

Per mantenere la lingua ma scrivere date, orari, numeri, valute, unità e formati carta come fa un'altra regione (inglese con date europee e orologio a 24 ore, per esempio), scegli una regione in _Setup > Region > Formats_, dove ogni scelta mostra un esempio, oppure esegui `omarchy region formats <code>` (`omarchy region formats list` mostra i codici). _Same as language_ torna ai formati propri della lingua. Come un cambio di lingua, riguarda le app che apri dopo.

### Aiuto se sei bloccato

Se rimani bloccato, di solito puoi trovare qualcuno disposto ad aiutarti nel canale _#omarchy-help_ sul [Discord della community](https://omarchy.org/discord).
