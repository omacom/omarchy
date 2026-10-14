# Sicurezza

Omarchy prende la sicurezza estremamente sul serio. Deve essere un sistema operativo che puoi usare per fare _Lavoro Vero_ nel _Mondo Reale_. Dove perdere un portatile non può portare a un'emergenza di sicurezza. Ecco quindi cosa facciamo:

1. *La crittografia completa del disco è obbligatoria*: questo è il passaggio più importante per proteggere fisicamente i tuoi dati. Se il computer viene perso o rubato, i dati sono completamente crittografati usando il LUKS standard (Linux Unified Key Setup).
2. *Il firewall è attivo per impostazione predefinita*: tutto il traffico in entrata è bloccato per impostazione predefinita, tranne la porta 53317 per [LocalSend](https://localsend.org/). Persino ssh è disattivato finché non lo attivi tramite _Impostazioni > Sicurezza > SSHD_, che apre la porta 22 (con limitazione della frequenza contro gli attacchi brute force) come parte della configurazione. Blindiamo persino l'accesso a Docker usando la configurazione [ufw-docker](https://github.com/chaifeng/ufw-docker) per impedire che i tuoi container vengano accidentalmente esposti al mondo.
3. *Arch ha sempre gli ultimi aggiornamenti*: Arch, la distribuzione sottostante su cui è costruito Omarchy, è una distribuzione rolling. Questo significa che qualsiasi vulnerabilità di sicurezza scoperta e corretta in qualsiasi pacchetto diventa rapidamente disponibile per l'installazione usando `omarchy-update`. In questo modo esegui sempre le versioni più recenti e sicure di tutto.
4. *Omarchy mantiene pacchetti e mirror propri*: per impostazione predefinita, Omarchy si affida solo ai pacchetti dei repository core/extra/multilib di Arch e al proprio Omarchy Package Repository. Puoi installare software direttamente da AUR, ma l'installazione di base non lo fa: solo alcune installazioni opzionali, come i browser di terze parti, attingono da AUR.
5. *Cloudflare ci protegge dai DDoS*: tutta l'infrastruttura di distribuzione di Omarchy — le ISO, i pacchetti Omarchy, il mirror Arch — è protetta dietro il formidabile scudo anti-DDoS di Cloudflare e ospitata sulla sua CDN. Questo garantisce una disponibilità eccellente.

## Cambiare le password

Su un'installazione crittografata hai due password: quella che sblocca il disco all'avvio e quella con cui accedi e usi `sudo`. La configurazione iniziale le rende uguali. Entrambe possono essere cambiate in _Aggiorna > Password_ nel menu di Omarchy: _Crittografia disco_ per la prima, _Utente_ per la seconda. Cambiare la password del disco chiede prima quella attuale, quindi tienila a portata di mano. Se un cambiamento viene interrotto, apri di nuovo _Crittografia disco_: chiederà la password che sblocca il disco adesso e completerà il cambiamento.

## Passare a qualcun altro una macchina già usata

Se stai consegnando la tua macchina a qualcun altro, non devi reinstallarla. Apri _Impostazioni > Reimposta computer_ nel menu di Omarchy, digita `reset` per confermare e riavvia. Questo cancella ogni account utente e tutto ciò che è in `/home`, butta via tutti i pacchetti e le modifiche di sistema che hai fatto dall'installazione e cancella l'identità della macchina: connessioni di rete, chiavi host e tutto il resto. Ciò che si riavvia è la procedura guidata di configurazione del primo avvio, pronta perché il nuovo proprietario inserisca il proprio nome, la propria password e la propria password di crittografia.

Funziona ripristinando lo snapshot di base che il programma di installazione crea, quindi è disponibile solo sulle macchine installate dall'ISO di Omarchy. E su un disco senza crittografia, una reimpostazione è una cancellazione piuttosto che una cancellazione sicura, quindi se i dati erano sensibili, fai invece un'installazione pulita.

## Sudo senza password

A volte vuoi che `sudo` smetta di chiedere, più spesso quando un agente IA sta facendo per te un lungo tratto di lavoro di sistema. _Impostazioni > Sicurezza > Sudo senza password_ chiede per quanto tempo consentire l'accesso: **15 minuti**, **1 ora**, **1 giorno** o **Permanentemente**. Accanto agli altri indicatori della barra dei menu compare un'icona di avviso rossa mentre l'accesso è attivo. Fai clic su di essa o esegui di nuovo il comando per disattivare l'accesso. Puoi anche passare un tuo numero di minuti (da 1 a 1440) con `omarchy-sudo-passwordless 30`, oppure usare `omarchy-sudo-passwordless permanent`.

L'accesso a tempo scade automaticamente, anche subito dopo la ripresa da una sospensione che ha superato la scadenza. Riavviare il computer lo interrompe in anticipo. L'accesso permanente sopravvive ai riavvii e resta attivo finché non lo disattivi.

Aggiornare o rimuovere il pacchetto delle impostazioni di Omarchy interrompe qualsiasi concessione temporanea prima che cambi il suo supporto alla scadenza. Se il comando segnala un errore di autorizzazione o di pulizia, risolvilo prima di provare ad attivare un'altra concessione; un errore non significa che l'accesso senza password sia inattivo.

Sii lucido su questo punto: mentre è attivo, qualsiasi cosa eseguita come il tuo utente può fare qualsiasi cosa come root senza che le venga chiesto. È esattamente lo scopo, ed è anche esattamente il rischio.

## Chiavi di firma

La chiave pubblica per tutte le firme ISO e i pacchetti del repository Omarchy è `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([verifica su openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Anche il pacchetto `omarchy/omarchy-keyring` la contiene e verrà usato per distribuire senza intoppi eventuali aggiornamenti.

Puoi trovare la firma per qualsiasi rilascio ISO aggiungendo .sig all'URL. Come https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
