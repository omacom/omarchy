# Supporto Mac

## Omarchy per Apple Silicon

Omarchy per Apple Silicon è una soluzione ufficiale Omacom, rilasciata per la prima volta con Omarchy 4.5. Si installa accanto a macOS e all'avvio del Mac scegli tra i due.

Hai ricevuto un avviso su Omarchy Mac? Vai a [Se arrivi da Omarchy Mac](#coming-from-omarchy-mac).

Funziona su questi Mac:

| Mac | Chip |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

I Mac M4 e più recenti non sono ancora supportati. Il supporto per M4 è in fase di test sul canale edge e arriverà prossimamente. L'installer controlla il tuo Mac prima di modificare qualsiasi cosa.

Su qualsiasi Mac Apple Silicon, compresi M4 e più recenti, puoi eseguire Omarchy in una macchina virtuale con [Try Omarchy](https://github.com/omacom/try-omarchy).

### Cosa ti serve

- macOS 15 Sequoia o versioni successive e un account amministratore
- Spazio libero su disco per Omarchy. L'installer suggerisce una dimensione e ti permette di modificarla.
- Un backup del tuo Mac, alimentazione e una connessione internet. L'installazione scarica diversi gigabyte.

### Installazione

L'installazione si fa da macOS. Installa Omarchy Installer con [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Oppure scarica la versione più recente di Omarchy Installer dalla sua [pagina delle release](https://github.com/omacom/omarchy-mac-installer/releases) e aprila.

L'installer controlla il tuo Mac, ti mostra il piano e fa spazio a Omarchy riducendo la partizione di macOS. macOS resta sul disco e non serve alcuna chiavetta USB. Al termine della prima fase, ti guida nel completamento della configurazione in macOS Recovery: spegni, tieni premuto il pulsante di accensione finché non compare "Loading startup options", scegli Omarchy e segui i passaggi.

Al primo avvio, Omarchy chiede una password che cifra il suo disco. Non esiste una chiave di recupero: se dimentichi la password, i tuoi file Omarchy non potranno essere recuperati.

Per passare in seguito tra Omarchy e macOS, spegni, poi tieni premuto il pulsante di accensione finché non compaiono le opzioni di avvio e scegline una.

### Se arrivi da Omarchy Mac

Omarchy Mac ora fa parte di Omarchy per Apple Silicon e tutti i Mac che lo eseguivano sono supportati. La tua installazione attuale continua a funzionare e i suoi pacchetti di sistema continuano ad aggiornarsi, ma non riceve più aggiornamenti Omarchy. Non c'è una scadenza né un aggiornamento sul posto: fai il backup, rimuovi la vecchia installazione, installi da zero e ripristini. I passaggi da 2 a 5 avvengono in macOS, quindi apri questa pagina sul telefono prima di riavviare.

1. **Fai il backup da Omarchy, fuori dal Mac.** La rimozione della vecchia installazione la cancella e macOS non può leggere il disco Omarchy. Copia la tua cartella home su un'unità esterna o su un altro computer, incluse chiavi SSH e GPG, profili del browser e lavoro di cui non hai ancora fatto il push. Salva l'elenco dei pacchetti con `pacman -Qqe > ~/packages.txt`. Fai il backup anche di macOS, poiché sia la rimozione sia l'installazione ridimensionano il suo disco.
2. **Avvia il Mac in macOS.** Spegni, tieni premuto il pulsante di accensione finché non compaiono le opzioni di avvio e scegli macOS.
3. **Installa Omarchy Installer** come mostrato in [Installazione](#installing).
4. **Rimuovi la vecchia installazione.** Apri Omarchy Installer e scegli Installation > Remove Omarchy. Mostra cosa eliminerà e restituisce lo spazio a macOS. Se non riconosce la tua installazione, si ferma senza modificare il disco. Chiedi aiuto su [Discord](https://discord.gg/tXFUdasqhY) invece di eliminare le partizioni a mano, cosa che può cancellare macOS.
5. **Installa Omarchy per Apple Silicon** con l'installer.
6. **Ripristina i tuoi file.** Riporta le tue impostazioni un pezzo alla volta invece di copiare tutto `~/.config` sopra i nuovi valori predefiniti, poiché le vecchie impostazioni possono sovrascriverli.

### Buono a sapersi

- Sui MacBook M1 e M2, riattiva dalla sospensione aprendo il coperchio o premendo il pulsante di accensione.
- Domande o problemi: chiedi sul nostro [Discord](https://discord.gg/tXFUdasqhY).

Il [README dell'installer](https://github.com/omacom/omarchy-mac-installer#readme) copre i canali di release, l'aggiornamento dell'installer e la rimozione di Omarchy.

## Mac Intel

In un semplice test, siamo riusciti a ottenere un aumento delle prestazioni del 36% su un MacBook Pro del 2019 semplicemente installando Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Installare Omarchy su Mac

Al momento Omarchy supporta solo l'essere l'**unico** sistema operativo installato. Durante l'installazione, l'unità verrà cancellata e MacOS non sarà più avviabile.

Se vuoi, potrai comunque ripristinarlo in seguito tramite Internet Recovery.

Per questa parte, daremo per scontato che tu abbia già consultato [Guida introduttiva](02-getting-started.md) e abbia pronta la chiavetta USB. Se non l'hai fatto, fallo ora.

#### Disabilita Secure Boot

È necessario disabilitare Secure Boot di Apple per avviare la USB avviabile, oltre che il sistema operativo. Per disabilitarlo, fai quanto segue:

1. Spegni il Mac
2. Accendilo e premi _immediatamente_ e tieni premuto Command-R finché non vedi comparire la schermata di caricamento
3. Seleziona il tuo utente e inserisci la password se richiesta
4. Una volta nella schermata di recupero, scegli **Utilities > Startup Security Utility** dalla barra dei menu
5. Inserisci la password quando ti viene chiesto di autenticarti
6. Scegli "No Security" tra le opzioni di Secure Boot
7. Scegli "Allow booting from external or removable media" tra le opzioni di External Boot

#### Avvia l'installazione

1. Inserisci la chiavetta USB
2. Riavvia il Mac e premi _immediatamente_ e tieni premuto Option finché non vedi una schermata con i dispositivi di avvio
3. Seleziona il dispositivo arancione EFI Boot
4. Procedi con l'[installazione come di consueto](02-getting-started.md)

L'installer rileva l'hardware Mac e applica automaticamente le correzioni necessarie: driver e firmware Wi-Fi Broadcom, il driver della fotocamera FaceTime HD sulle macchine con Broadcom 1570 (il suo firmware viene scaricato da Apple una volta che il Mac è online, poiché l'installer funziona offline), il driver della tastiera SPI sui modelli MacBook che ne hanno bisogno e una correzione per la sospensione NVMe per quegli stessi modelli.

### Limitazioni note

I membri della community lavorano costantemente a soluzioni per queste sfide, quindi se per te sono un problema, entra in #omarchy-on-other sul nostro [Discord](https://discord.gg/tXFUdasqhY) e verifica se esistono metodi aggiornati per risolverle.

#### FaceTime HD Camera

Il driver della fotocamera blocca la macchina se è caricato quando il Mac va in ibernazione, quindi viene scaricato prima. Non può essere scaricato mentre un'app tiene aperta la fotocamera, quindi l'ibernazione viene annullata con una notifica che indica il nome dell'app: chiudila e vai di nuovo in ibernazione. Questo include l'ibernazione automatica con batteria critica e suspend-then-hibernate, che viene rifiutata prima della sospensione. La normale sospensione viene rifiutata dal driver stesso mentre la fotocamera è aperta, senza notifica.

Il firmware della fotocamera viene scaricato da Apple, quindi la fotocamera funziona solo dopo che il Mac è stato online. Il download parte all'avvio e viene ritentato ogni 15 minuti finché il problema è la rete; se il file di Apple è cambiato, si ferma e attende un aggiornamento di Omarchy. Se la fotocamera non compare, `journalctl -u facetimehd-firmware-fetcher` spiega perché, `sudo systemctl restart facetimehd-firmware-fetcher` riprova e un riavvio carica il driver se il download è terminato ma la fotocamera ancora non c'è.

#### Dispositivi con chip T1

Il chip Apple T1 è stato introdotto a fine 2016 e usato esclusivamente nei modelli MacBook Pro di prima generazione con Touch Bar.
- MacBook Pro 13 pollici (2016, due porte Thunderbolt 3) – Modello: A1706
- MacBook Pro 13 pollici (2016, quattro porte Thunderbolt 3) – Modello: A1708
- MacBook Pro 15 pollici (2016) – Modello: A1707

#### Problemi noti

- La Touch Bar non funziona
- L'audio non funziona

#### Dispositivi con chip T2

Il chip di sicurezza Apple T2 è stato introdotto nel 2017. Il chip T2 è stato dismesso con la transizione ad Apple silicon (chip serie M) a partire dal 2020.

- iMac Pro (2017) – Modello: A1862
- MacBook Pro 13 pollici (2018, quattro porte Thunderbolt 3) – Modello: A1989
- MacBook Pro 15 pollici (2018) – Modello: A1990
- MacBook Air (Retina, 13 pollici, 2018) – Modello: A1932
- Mac mini (2018) – Modello: A1998
- MacBook Pro 13 pollici (2019, due porte Thunderbolt 3) – Modello: A2159
- MacBook Pro 13 pollici (2019, quattro porte Thunderbolt 3) – Modello: A2178
- MacBook Pro 15 pollici (2019) – Modello: A1990
- iMac (Retina 5K, 27 pollici, 2020) – Modello: A2115 (iMac20,1 e iMac20,2)
- MacBook Pro 13 pollici (2020, due porte Thunderbolt 3) – Modello: A2265
- MacBook Pro 15 pollici (2020) – Modello: A1990

Su questi modelli, l'installer configura automaticamente il kernel `linux-t2` con patch, la configurazione audio T2, il firmware Wi-Fi/Bluetooth Broadcom di Apple e il controllo delle ventole tramite `t2fanrd`. La Touch Bar funziona con il supporto integrato in stile Boot Camp del kernel.

#### iMac Retina 5K (2017)

L'iMac da 27 pollici del 2017 non ha chip T2, quindi l'installer lo configura come gli altri Mac Intel.

- iMac (Retina 5K, 27 pollici, 2017) – Modello: A1419

#### Problemi noti

- Lo schermo non funziona alla sua risoluzione nativa 5120×2880: il pannello è composto da due tile e il driver standard ne accende solo una
- L'audio non funziona
- Il controllo della luminosità non ha effetto
- La sospensione blocca la macchina; solo un ciclo di spegnimento e riaccensione la ripristina

Un patcher della community per questo modello corregge schermo, audio e luminosità: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
