<!-- upstream: omacom/omarchy@60663faf8764253646f1d6166e864b608d4a0fa1; sha256: d9d6dc93725d49442539acd46252b10bb616b644e777d1eeb473423abd90870c -->

# Per iniziare

Omarchy si installa tramite un'ISO. Puoi scegliere tra un'installazione su disco intero, che occupa l'intera unità, oppure un'installazione nello spazio libero, che colloca Omarchy nello spazio non allocato di un'unità: è così che si fa il dual boot con Windows o un altro sistema operativo (vedi [installazione in dual boot](../50-dual-boot-install.md) — nota che prima devi disattivare BitLocker in Windows). In entrambi i casi l'installazione è cifrata per impostazione predefinita, e l'opzione su disco intero cancella l'unità selezionata, quindi fai un backup prima di usarne una esistente!

[Scarica l'ISO di Omarchy](https://omarchy.org/) innanzitutto, mettila su una chiavetta USB (usa [balenaEtcher](https://etcher.balena.io/) su Mac/Windows o [caligula](https://github.com/ifd3f/caligula) su Linux), e avvia dal supporto.

_Devi disattivare Secure Boot e/o TPM nel BIOS. Per poter installare Omarchy devi disattivarli. Sono schemi di sicurezza Microsoft pensati per Windows e per le distribuzioni Linux affiliate a Microsoft._

Poi rispondi alle domande di configurazione e confermale così:

 ![Configurazione dell'installazione](../images/install-config.webp)

Seleziona quindi un'unità per l'installazione e goditi lo spettacolo. Sulle macchine moderne più veloci può concludersi in meno di un minuto, ma non dovrebbe richiedere più di 5 minuti nemmeno su un computer più vecchio.

 ![Installazione completata](../images/install-done.webp)

Ora sei pronto per Omarchy!

### Usa una tastiera cablata o con dongle a 2,4 GHz!

La cifratura del disco intero non permette di inserire la password da una tastiera Bluetooth all'avvio. Proprio come non puoi usare una tastiera Bluetooth per entrare nel BIOS di un PC. Ti serve una tastiera con dongle a 2,4 GHz o con cavo (che per la latenza è comunque molto meglio!). Personalmente adoro la [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Installare per un altro proprietario

Se stai preparando una macchina per qualcun altro — un familiare, un nuovo dipendente, un cliente — non dovresti rispondere alle domande personali al posto suo. Premi `Ctrl + C` sulla primissima schermata dell'installer (la selezione della tastiera) e Omarchy ti offrirà di preparare la macchina per un altro proprietario. Il sistema si installa subito, ma tutta la configurazione personale — layout della tastiera, nome utente, password — viene rinviata al primo avvio. L'unità resta cifrata per impostazione predefinita, e la password scelta dal nuovo proprietario a quel primo avvio diventa anche la password di cifratura. (Anche una macchina che hai già usato può essere ceduta senza reinstallare: vedi [ripristinare il computer](../48-security.md).)

### Installazioni non presidiate

L'ISO può anche installarsi completamente da sola — niente tastiera, niente procedura guidata — se le viene fornita la configurazione su una seconda unità. È il modo per usare Omarchy come immagine di base per VM e macchine in flotta. Vedi [installazioni non presidiate](../51-unattended-installs.md).

### Installazioni senza cifratura

Omarchy si installa con la cifratura attiva per impostazione predefinita. È la scelta sicura e responsabile per qualsiasi computer che possa essere smarrito o rubato. Non vuoi che chiunque abbia accesso al tuo hardware possa ottenere i tuoi dati!

Ma in circostanze speciali, come installazioni remote di Omarchy su computer protetti o per installazioni usa e getta senza dati sensibili, potresti voler installare senza cifratura. Puoi premere `Ctrl + C` sulla conferma della formattazione del disco per passare a un'installazione senza cifratura.

### Aiuto se ti blocchi

Se ti blocchi, di solito puoi trovare qualcuno disposto ad aiutarti nel canale _#omarchy-help_ sul [Discord della community](https://omarchy.org/discord).
