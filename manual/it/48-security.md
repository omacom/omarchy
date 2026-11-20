# Sicurezza

Omarchy prende la sicurezza estremamente sul serio. Questo vuole essere un sistema operativo che puoi usare per fare _Lavoro Vero_ nel _Mondo Reale_. Dove perdere un laptop non può trasformarsi in un'emergenza di sicurezza. Ecco quindi cosa facciamo:

1. *La crittografia completa del disco è attiva per impostazione predefinita*: questo è il passo più importante per garantire la protezione fisica dei tuoi dati. Se il tuo computer viene perso o rubato, i dati sono completamente crittografati utilizzando il LUKS (Linux Unified Key Setup) standard. Il programma di installazione ti consente di rinunciarvi per le macchine usa e getta (vedi [Guida introduttiva](02-getting-started.md)); un'installazione senza crittografia non ha nessuna di queste protezioni, e chiunque abbia in mano il disco può leggerlo.
2. *Il firewall è abilitato per impostazione predefinita*: tutto il traffico in entrata è bloccato per impostazione predefinita, con poche eccezioni: la porta 53317 per [LocalSend](https://localsend.org/); le query DNS al resolver del computer stesso all'indirizzo del bridge Docker (172.17.0.1), accettate dagli intervalli di indirizzi privati che Docker assegna ai suoi container; e il DNS multicast (porta 5353), che consente a stampanti e altri dispositivi sulla tua rete di trovarsi tra loro e annuncia anche lì il nome del tuo computer. Oltre a queste, il firewall mantiene le autorizzazioni standard di UFW per il ping, per ottenere un indirizzo dal tuo router (DHCP) e per il rilevamento UPnP. Persino ssh è disattivato finché non lo attivi tramite _Configurazione > Sicurezza > SSHD_, che apre la porta 22 (con limitazione della frequenza contro gli attacchi di forza bruta) come parte della configurazione. Blocchiamo persino l'accesso a Docker utilizzando la configurazione [ufw-docker](https://github.com/chaifeng/ufw-docker) per impedire che i tuoi container vengano accidentalmente esposti al mondo.
3. *Arch ha sempre gli aggiornamenti più recenti*: Arch, la distro sottostante su cui è costruito Omarchy, è una distribuzione rolling. Questo significa che qualsiasi vulnerabilità di sicurezza scoperta e corretta in qualsiasi pacchetto è rapidamente disponibile per l'installazione utilizzando `omarchy-update`. In questo modo esegui sempre le versioni più recenti e più sicure di tutto.
4. *Omarchy mantiene i propri pacchetti e il proprio mirror*: per impostazione predefinita Omarchy si affida solo a pacchetti dai repository core/extra/multilib di Arch stessa e dal proprio Omarchy Package Repository. Puoi installare software direttamente da AUR, ma l'installazione di base non lo fa — solo alcune installazioni facoltative, come i browser di terze parti, attingono da AUR.
5. *Cloudflare ci protegge dagli attacchi DDoS*: l'infrastruttura di distribuzione di Omarchy — le ISO, i pacchetti Omarchy, il mirror di Arch — è protetta dietro il formidabile scudo anti-DDoS di Cloudflare e ospitata sulla loro CDN. Questo offre una disponibilità eccellente.

## Cambiare le password

Su un'installazione crittografata hai due password: quella che sblocca il disco all'avvio e quella con cui accedi e usi `sudo`. La configurazione le rende uguali. Entrambe possono essere cambiate in _Aggiornamento > Password_ nel menu Omarchy — _Crittografia del disco_ per la prima, _Utente_ per la seconda. Cambiare la password del disco richiede prima quella attuale, quindi tienila a portata di mano. Se una modifica viene interrotta, esegui di nuovo _Crittografia del disco_: chiede la password che sblocca il disco adesso e completa la modifica.

## Cedere una macchina che hai già usato

Se stai consegnando la tua macchina a qualcun altro, non devi reinstallarla. Esegui _Rimuovi > Ripristino di fabbrica_ nel menu Omarchy, digita `reset` per confermare e riavvia. Questo cancella ogni account utente e tutto ciò che si trova in `/home`, elimina tutti i pacchetti e le modifiche al sistema che hai apportato dall'installazione e cancella l'identità della macchina — connessioni di rete, chiavi host e tutto il resto. Ciò che si riavvia è la procedura di configurazione guidata del primo avvio, pronta affinché il nuovo proprietario inserisca il proprio nome, la propria password e la password di crittografia.

Funziona ripristinando l'istantanea di base acquisita dal programma di installazione, quindi è disponibile solo su macchine installate dall'ISO di Omarchy. E su un disco senza crittografia, un ripristino è un'eliminazione piuttosto che una cancellazione sicura, quindi se i dati erano sensibili, fai invece un'installazione pulita.

## Sudo senza password

A volte vuoi che `sudo` smetta di chiedere, il più delle volte quando un agente AI sta svolgendo per te un lungo tratto di lavoro sul sistema. _Configurazione > Sicurezza > Sudo senza password_ chiede per quanto tempo consentire l'accesso: **15 minuti**, **1 ora**, **1 giorno** oppure **In modo permanente**. Un'icona di avviso rossa appare accanto agli altri indicatori della barra dei menu mentre l'accesso è attivo. Fai clic su di essa o esegui di nuovo il comando per disattivare l'accesso. Puoi anche passare un tuo numero di minuti (da 1 a 1440) con `omarchy-sudo-passwordless 30`, oppure usare `omarchy-sudo-passwordless permanent`.

L'accesso a tempo scade automaticamente, anche subito dopo la ripresa da una sospensione che ha superato la scadenza. Riavviare il computer lo termina in anticipo. L'accesso permanente sopravvive ai riavvii e resta attivo finché non lo disabiliti.

L'aggiornamento o la rimozione del pacchetto delle impostazioni di Omarchy termina qualsiasi concessione temporanea prima che cambi il suo supporto alla scadenza. Se il comando segnala un errore di autorizzazione o di pulizia, risolvilo prima di provare a abilitare un'altra concessione; un errore non significa che l'accesso senza password sia inattivo.

Sii lucido su questo punto: mentre è attivo, qualsiasi cosa in esecuzione come tuo utente può fare qualsiasi cosa come root senza che venga chiesto nulla. È proprio questo lo scopo, ed è anche proprio questo il rischio.

## Chiavi di firma

La chiave pubblica per tutte le firme delle ISO e per i pacchetti del repository Omarchy è `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifica su openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Anche il pacchetto `omarchy/omarchy-keyring` la contiene e verrà usato per distribuire senza intoppi eventuali aggiornamenti.

Puoi trovare la firma per qualsiasi versione ISO aggiungendo `.sig` al suo URL, come `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
