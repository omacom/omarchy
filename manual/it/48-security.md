# Sicurezza

Omarchy prende la sicurezza estremamente sul serio. Questo vuole essere un sistema operativo che puoi usare per fare _Lavoro Vero_ nel _Mondo Reale_. Dove perdere un laptop non può trasformarsi in un'emergenza di sicurezza. Ecco cosa facciamo:

1. *La crittografia completa del disco è obbligatoria*: Questo è il passo più importante per proteggere fisicamente i tuoi dati. Se il computer viene perso o rubato, i dati sono completamente crittografati usando il LUKS standard (Linux Unified Key Setup).
2. *Il firewall è abilitato per impostazione predefinita*: Tutto il traffico in entrata è bloccato per impostazione predefinita, tranne la porta 53317 per [LocalSend](https://localsend.org/). Persino ssh è disattivato finché non lo attivi tramite _Setup > Security > SSHD_, che apre la porta 22 (con limitazione della frequenza contro gli attacchi brute force) come parte della configurazione. Blocchiamo persino l'accesso a Docker usando la configurazione [ufw-docker](https://github.com/chaifeng/ufw-docker) per impedire che i tuoi container vengano esposti accidentalmente al mondo.
3. *Arch ha sempre gli aggiornamenti più recenti*: Arch, la distribuzione sottostante su cui è costruito Omarchy, è una distribuzione rolling. Questo significa che qualsiasi vulnerabilità di sicurezza scoperta e corretta in qualsiasi pacchetto diventa rapidamente disponibile per l'installazione usando `omarchy-update`. In questo modo esegui sempre le versioni più recenti e più sicure di tutto.
4. *Omarchy mantiene i propri pacchetti e il proprio mirror*: Omarchy si affida per impostazione predefinita solo ai pacchetti dei repository core/extra/multilib di Arch e al proprio Omarchy Package Repository. Puoi installare software direttamente da AUR, ma l'installazione base non lo fa — solo alcune installazioni opzionali, come i browser di terze parti, attingono da AUR.
5. *Cloudflare ci protegge dai DDoS*: L'infrastruttura di distribuzione di Omarchy — le ISO, i pacchetti Omarchy, il mirror di Arch — è protetta dietro il formidabile scudo anti-DDoS di Cloudflare e ospitata sulla loro CDN. Questo garantisce una disponibilità eccellente.

## Cambiare le tue password

Hai due password in un'installazione crittografata: quella che sblocca il disco all'avvio e quella con cui accedi e usi `sudo`. La configurazione le imposta uguali. Entrambe possono essere cambiate in _Update > Password_ nel menu di Omarchy — _Drive Encryption_ per la prima, _User_ per la seconda. Per cambiare la password del disco devi prima inserire quella attuale, quindi tienila a portata di mano. Se una modifica viene interrotta, esegui di nuovo _Drive Encryption_: ti chiederà la password che sblocca il disco in questo momento e completerà la modifica.

## Cedere una macchina che hai già usato

Se stai cedendo la tua macchina a qualcun altro, non devi reinstallarla. Esegui _Setup > Reset Computer_ nel menu di Omarchy, digita `reset` per confermare e riavvia. Questo cancella ogni account utente e tutto ciò che si trova in `/home`, elimina tutti i pacchetti e le modifiche al sistema che hai apportato dall'installazione e cancella l'identità della macchina — connessioni di rete, chiavi host e tutto il resto. Al riavvio comparirà la procedura guidata di configurazione del primo avvio, pronta perché il nuovo proprietario inserisca il proprio nome, la propria password e la propria password di crittografia.

Funziona ripristinando l'istantanea di base che il programma di installazione crea, quindi è disponibile solo sulle macchine installate dall'ISO di Omarchy. E su un disco senza crittografia, un reset è una cancellazione, non una cancellazione sicura, quindi se i dati erano sensibili, fai invece un'installazione pulita.

## Sudo senza password

A volte vuoi che `sudo` smetta di chiedere, il più delle volte quando un agente AI sta svolgendo per te un lungo lavoro di sistema. _Setup > Security > Passwordless Sudo_ chiede per quanto tempo consentire l'accesso: **15 minuti**, **1 ora**, **1 giorno** o **In modo permanente**. Un'icona di avviso rossa compare accanto agli altri indicatori della barra dei menu mentre l'accesso è attivo. Fai clic su di essa o esegui di nuovo il comando per disattivare l'accesso. Puoi anche passare un tuo numero di minuti (da 1 a 1440) con `omarchy-sudo-passwordless 30`, o usare `omarchy-sudo-passwordless permanent`.

L'accesso a tempo scade automaticamente, anche subito dopo la ripresa da una sospensione che ha superato la scadenza. Il riavvio del computer lo termina in anticipo. L'accesso permanente sopravvive ai riavvii e rimane abilitato finché non lo disabiliti.

L'aggiornamento o la rimozione del pacchetto delle impostazioni di Omarchy termina qualsiasi concessione temporanea prima che cambi il relativo supporto alla scadenza. Se il comando segnala un errore di autorizzazione o di pulizia, risolvilo prima di provare ad abilitare un'altra concessione; un errore non significa che l'accesso senza password sia inattivo.

Sii lucido su questo punto: mentre è attivo, qualsiasi cosa in esecuzione come il tuo utente può fare qualsiasi cosa come root senza che le venga chiesto nulla. È esattamente lo scopo, ed è anche esattamente il rischio.

## Chiavi di firma

La chiave pubblica per tutte le firme delle ISO e per il pacchetto del repository di Omarchy è `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifica su openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Anche il pacchetto `omarchy/omarchy-keyring` la contiene e verrà usato per distribuire senza problemi eventuali aggiornamenti futuri.

Puoi trovare la firma di qualsiasi release ISO aggiungendo `.sig` al suo URL, come `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
