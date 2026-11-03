# Rete

La rete in Omarchy è gestita da NetworkManager e la controlli dall'icona della rete nella [barra superiore](05-the-top-bar.md) o con `Super + Ctrl + N`.

Quel pannello cerca le reti Wi-Fi, mostra la potenza del segnale e si connette. Per Ethernet non serve assolutamente nulla: colleghi il cavo e funziona. Se preferisci restare nel terminale, `nmtui` ti offre gli stessi controlli e c'è anche un gruppo di comandi `omarchy network`.

## Condividere il tuo Wi-Fi

Invece di leggere ad alta voce una password lunga, avvia _Configurazione > Rete > Codice QR_ mentre sei connesso al Wi-Fi. Così sullo schermo compare un codice QR che qualsiasi fotocamera del telefono può scansionare per connettersi. È una di quelle cose che userai più spesso di quanto ti aspetti, una volta che sai che c'è.

Se ti serve proprio la password stessa, `omarchy network password <interface>` la stampa.

## DNS

Omarchy usa qualsiasi DNS la tua rete fornisca tramite DHCP. Puoi sostituirlo per l'intera macchina in _Configurazione > Rete > DNS_, dove Cloudflare e Google sono a un clic di distanza. Scegli _Personalizzato_ per inserire i tuoi server.

Dal terminale, `omarchy dns` stampa il provider attuale e `omarchy dns Cloudflare` ne imposta uno.

## Fissare la banda Wi-Fi

Se il tuo router mette 2.4GHz, 5GHz e 6GHz sotto lo stesso nome di rete, il tuo portatile a volte si aggrappa a quella lenta. `omarchy network band` mostra su quale banda sei e `omarchy network band 5` la fissa. Usa `auto` per lasciare che scelga di nuovo.

Questo fissa la banda anziché uno specifico punto di accesso, quindi continui a passare normalmente da un AP all'altro.

## Quanto è veloce?

_Attivazione > Test di velocità > Test di velocità della rete_ misura la tua effettiva velocità in download e upload con una coppia di quadranti. Dal terminale è `omarchy network speedtest down` oppure `up`. Misura rispetto al servizio di Omarchy e conteggia solo i suoi trasferimenti di test. Altri download possono competere per la larghezza di banda, ma non vengono aggiunti al risultato del test di velocità. (Accanto, in quel menu, c'è un test di velocità del disco, se stai misurando l'altro collo di bottiglia.)

## Il firewall

Il firewall è attivo per impostazione predefinita e blocca tutto il traffico in entrata, con un'eccezione: la porta 53317, così [LocalSend](22-guis.md) funziona subito senza configurazioni.

SSH è disattivato finché non lo attivi con _Configurazione > Sicurezza > SSHD_, che avvia il demone, apre la porta 22 con limitazione della frequenza contro gli attacchi a forza bruta e autorizza una chiave. Anche Docker è blindato, così i container non possono esporsi accidentalmente al mondo. Vedi [sicurezza](48-security.md) per tutta la storia.

## Tailscale

[Tailscale](https://tailscale.com/) è una VPN mesh che rende semplice e sicuro raggiungere tutti i tuoi computer e server tramite internet. Installala con _Installa > Servizio > Tailscale_.

Questo ti dà un pannello Tailscale nella barra, che connette e disconnette la tailnet, cambia account e sceglie un nodo di uscita: nell'elenco compaiono sia le tue macchine sia le regioni Mullvad. Sfoglia anche le tue macchine ed è lì che vive Taildrop: seleziona una macchina e premi `s` per inviarle file, oppure `c`, `n` e `d` per copiarne l'IP, il nome o il nome DNS completo. L'equivalente da terminale è `omarchy tailscale send <machine> [file...]` e i file inviati a te finiscono automaticamente in `~/Downloads`. La notifica che annuncia un arrivo resta finché non la apri con un clic o non la ignori, così un file che arriva mentre sei lontano dalla macchina è ancora lì ad aspettare una tua azione quando torni.

Installandola viene aggiunta anche un'app web per la console di amministrazione di Tailscale.

## Quando smette di funzionare

Prima di riavviare, prova a riavviare da solo il pezzo che dà problemi. _Aggiorna > Hardware_ ha Wi-Fi, Bluetooth, Audio e Trackpad e ricaricarne uno risolve la maggior parte delle situazioni del tipo "funzionava cinque minuti fa". Vedi [risoluzione dei problemi](45-troubleshooting.md).
