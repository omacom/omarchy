# Supporto Mac

Omarchy ha il supporto integrato per i **Mac Intel**. Al momento ci sono un paio di limitazioni note, ma finché ne sei consapevole e ti vanno bene, puoi dare nuova vita ai tuoi vecchi Mac installando Omarchy.

Nota che al momento l'installazione su un Mac serie M non è supportata direttamente. Puoi scoprire di più sullo stato della questione in #omarchy-on-other nel nostro [Discord](https://discord.gg/tXFUdasqhY).

In un semplice test, siamo riusciti a ottenere un guadagno prestazionale del 36% su un MacBook Pro del 2019 semplicemente installando Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Installare Omarchy su Mac

Al momento Omarchy supporta solo l'installazione come **unico** sistema operativo. Durante l'installazione, il disco verrà cancellato e MacOS non sarà più avviabile.

Potrai comunque ripristinarlo in seguito tramite Internet Recovery, se lo desideri.

Ai fini di questa parte, daremo per scontato che tu abbia già letto [Guida introduttiva](02-getting-started.md) e abbia pronta la tua chiavetta USB. Se non l'hai fatto, fallo ora.

#### Disabilita Secure Boot

È necessario disabilitare il Secure Boot di Apple per avviare la chiavetta USB avviabile, così come il sistema operativo. Per disabilitarlo, procedi così:

1. Spegni il Mac
2. Accendilo e premi _immediatamente_ tenendo premuto Command-R finché non vedi comparire la schermata di caricamento
3. Seleziona il tuo utente e inserisci la password se richiesto
4. Una volta nella schermata di recupero, scegli **Utilities > Startup Security Utility** dalla barra dei menu
5. Inserisci la password quando ti viene chiesto di autenticarti
6. Scegli "No Security" dalle opzioni di Secure Boot
7. Scegli "Allow booting from external or removable media" dalle opzioni di External Boot

#### Avvia l'installazione

1. Inserisci la chiavetta USB
2. Riavvia il Mac e premi _immediatamente_ tenendo premuto Option finché non vedi una schermata di dispositivi di avvio
3. Seleziona il dispositivo arancione EFI Boot
4. Procedi con l'[installazione come al solito](02-getting-started.md)

Il programma di installazione rileva l'hardware Mac e applica automaticamente le correzioni necessarie: driver e firmware Wi-Fi Broadcom, il driver della tastiera SPI sui modelli MacBook che ne hanno bisogno e una correzione per la sospensione NVMe per quegli stessi modelli.

### Limitazioni note

I membri della community lavorano costantemente a soluzioni per queste sfide, quindi se per te sono problematiche, unisciti a #omarchy-on-other nel nostro [Discord](https://discord.gg/tXFUdasqhY) e guarda se ci sono metodi aggiornati per risolverle.

#### Dispositivi con chip T1

Il chip Apple T1 è stato introdotto alla fine del 2016 ed è stato usato esclusivamente nei modelli MacBook Pro di prima generazione con Touch Bar.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Problemi noti

- La Touch Bar non funziona
- L'audio non funziona

#### Dispositivi con chip T2

Il chip di sicurezza Apple T2 è stato introdotto nel 2017. Il chip T2 è stato dismesso con il passaggio ad Apple silicon (chip serie M) a partire dal 2020.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-inch (2018, four Thunderbolt 3 ports) – Model: A1989
- MacBook Pro 15-inch (2018) – Model: A1990
- MacBook Air (Retina, 13-inch, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-inch (2019, two Thunderbolt 3 ports) – Model: A2159
- MacBook Pro 13-inch (2019, four Thunderbolt 3 ports) – Model: A2178
- MacBook Pro 15-inch (2019) – Model: A1990
- iMac (Retina 5K, 27-inch, 2020) – Model: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13-inch (2020, two Thunderbolt 3 ports) – Model: A2265
- MacBook Pro 15-inch (2020) – Model: A1990

Su questi modelli, il programma di installazione configura automaticamente il kernel `linux-t2` con patch, la configurazione audio T2, il firmware Wi-Fi/Bluetooth Broadcom di Apple e il controllo delle ventole tramite `t2fanrd`. La Touch Bar funziona con il supporto integrato in stile Boot Camp del kernel.
