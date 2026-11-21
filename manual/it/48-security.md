# Sicurezza

Omarchy prende la sicurezza estremamente sul serio. Questo è pensato per essere un sistema operativo che puoi usare per fare _Lavoro Vero_ nel _Mondo Reale_. Dove perdere un laptop non può trasformarsi in un'emergenza di sicurezza. Ecco quindi cosa facciamo:

1. *La crittografia completa del disco è attiva per impostazione predefinita*: questo è il passo più importante per garantire la protezione fisica dei tuoi dati. Se il computer viene perso o rubato, i dati sono completamente crittografati usando LUKS (Linux Unified Key Setup) standard. Il programma di installazione ti permette di rinunciarvi per le macchine usa e getta (vedi [Per iniziare](02-getting-started.md)); un'installazione senza crittografia non ha nessuna di queste protezioni, e chiunque abbia in mano il disco può leggerlo.
2. *Il firewall è attivo per impostazione predefinita*: tutto il traffico in entrata è bloccato per impostazione predefinita, con poche eccezioni: la porta 53317 per [LocalSend](https://localsend.org/); le query DNS al resolver del computer stesso all'indirizzo bridge di Docker (172.17.0.1), accettate dagli intervalli di indirizzi privati che Docker assegna ai suoi container; e il DNS multicast (porta 5353), che permette a stampanti e altri dispositivi sulla tua rete di trovarsi tra loro e annuncia anche lì il nome del tuo computer. In aggiunta a queste, il firewall mantiene le autorizzazioni standard di UFW per ping, ottenere un indirizzo dal tuo router (DHCP) e il rilevamento UPnP. Persino ssh è disattivato finché non lo attivi tramite _Impostazioni > Sicurezza > SSHD_, che autorizza la tua chiave SSH, disattiva gli accessi con password e solo allora apre la porta 22 (con limitazione della frequenza contro gli attacchi di forza bruta). Blocchiamo persino l'accesso a Docker usando la configurazione [ufw-docker](https://github.com/chaifeng/ufw-docker) per impedire che i tuoi container vengano accidentalmente esposti al mondo.
3. *Arch ha sempre gli aggiornamenti più recenti*: Arch, la distribuzione sottostante su cui è costruito Omarchy, è una distribuzione rolling. Questo significa che qualsiasi vulnerabilità di sicurezza scoperta e corretta in qualsiasi pacchetto diventa rapidamente disponibile per l'installazione usando `omarchy-update`. In questo modo usi sempre le versioni più recenti e più sicure di tutto.
4. *Omarchy mantiene i propri pacchetti e il proprio mirror*: per impostazione predefinita, Omarchy si affida solo ai pacchetti dei repository core/extra/multilib di Arch (quelli di Arch Linux ARM sulle macchine ARM, più Asahi ALARM su Apple Silicon) e al proprio Omarchy Package Repository. Puoi installare software direttamente da AUR, ma l'installazione di base non lo fa: solo poche installazioni opzionali, come i browser di terze parti, attingono da AUR.
5. *Cloudflare ci protegge dai DDoS*: l'infrastruttura di distribuzione di Omarchy — le ISO, i pacchetti Omarchy, il mirror di Arch — è protetta dietro il formidabile scudo anti-DDoS di Cloudflare e ospitata sulla loro CDN. Questo garantisce una disponibilità eccellente.

## Cambiare le tue password

Hai due password su un'installazione crittografata: quella che sblocca il disco all'avvio, e quella con cui accedi e usi `sudo`. La configurazione le imposta uguali. Entrambe possono essere cambiate in _Aggiorna > Password_ nel menu di Omarchy — _Crittografia del disco_ per la prima, _Utente_ per la seconda. Per cambiare la password del disco devi prima inserire quella attuale, quindi tienila a portata di mano. Se una modifica viene interrotta, esegui di nuovo _Crittografia del disco_: ti chiederà la password che sblocca il disco ora e completerà la modifica.

## Cedere una macchina che hai già usato

Se stai consegnando la tua macchina a qualcun altro, non devi reinstallarla. Esegui _Rimuovi > Ripristino alle impostazioni di fabbrica_ nel menu di Omarchy, digita `reset` per confermare, inserisci la password di crittografia del disco se ti viene chiesto, e riavvia. Questo cancella ogni account utente e tutto ciò che si trova in `/home`, elimina tutti i pacchetti e le modifiche di sistema che hai apportato dopo l'installazione, e cancella l'identità della macchina — connessioni di rete, chiavi host e tutto il resto. Quello che si avvia è la procedura guidata di configurazione del primo avvio, pronta perché il nuovo proprietario inserisca il proprio nome, la propria password e la propria password di crittografia.

Funziona ripristinando lo snapshot di base che il programma di installazione crea, quindi è disponibile solo sulle macchine installate dall'ISO di Omarchy. E su un disco senza crittografia, un ripristino è una cancellazione anziché una cancellazione sicura, quindi se i dati erano sensibili, fai invece un'installazione pulita.

## Sudo senza password

A volte vuoi che `sudo` smetta di chiedere, più spesso quando un agente IA sta facendo per te un lungo tratto di lavoro di sistema. _Impostazioni > Sicurezza > Sudo senza password_ chiede per quanto tempo consentire l'accesso: **15 minuti**, **1 ora**, **1 giorno**, o **in modo permanente**. Un'icona di avviso rossa appare accanto agli altri indicatori della barra dei menu mentre l'accesso è attivo. Fai clic su di essa o esegui di nuovo il comando per disattivare l'accesso. Puoi anche passare un tuo numero di minuti (da 1 a 1440) con `omarchy-sudo-passwordless 30`, oppure usare `omarchy-sudo-passwordless permanent`.

L'accesso a tempo scade automaticamente, anche immediatamente dopo la ripresa da una sospensione che ha superato la scadenza. Riavviare il computer lo termina in anticipo. L'accesso permanente sopravvive ai riavvii e resta attivo finché non lo disattivi.

L'aggiornamento o la rimozione del pacchetto delle impostazioni di Omarchy termina qualsiasi concessione temporanea prima che cambi il supporto alla sua scadenza. Se il comando segnala un errore di autorizzazione o di pulizia, risolvilo prima di provare ad abilitare un'altra concessione; un errore non significa che l'accesso senza password sia inattivo.

Sii lucido su questo punto: mentre è attivo, qualsiasi cosa in esecuzione come il tuo utente può fare qualsiasi cosa come root senza che le venga chiesto nulla. È proprio questo il punto, ed è anche proprio questo il rischio.

## Chiavi di firma

La chiave pubblica per tutte le firme ISO e per i pacchetti del repository Omarchy è `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifica su openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Anche il pacchetto `omarchy/omarchy-keyring` la contiene e verrà usato per distribuire senza problemi qualsiasi potenziale aggiornamento.

Puoi trovare la firma di qualsiasi versione ISO aggiungendo `.sig` al suo URL, come `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
