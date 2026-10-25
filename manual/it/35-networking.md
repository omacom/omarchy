# Rete

La rete in Omarchy è gestita da NetworkManager, e la controlli dall'icona di rete nella [barra superiore](05-the-top-bar.md) o con `Super + Ctrl + N`.

Quel pannello cerca le reti Wi-Fi, mostra l'intensità del segnale e si connette. Per Ethernet non serve assolutamente nulla — colleghi il cavo e funziona. Se preferisci restare nel terminale, `nmtui` ti offre gli stessi controlli, e c'è anche un gruppo di comandi `omarchy network`.

## Condividere il tuo Wi-Fi

Invece di leggere ad alta voce una lunga password, avvia _Setup > Network > QR Code_ mentre sei connesso al Wi-Fi. Così viene mostrato sullo schermo un QR code che qualsiasi fotocamera di un telefono può scansionare per connettersi. È una di quelle cose che userai più spesso di quanto ti aspetti, una volta che sai che c'è.

Se ti serve davvero la password stessa, `omarchy network password <interface>` la stampa.

## DNS

Omarchy usa qualsiasi DNS la tua rete fornisca tramite DHCP. Puoi sostituirlo per l'intera macchina in _Setup > Network > DNS_, dove Cloudflare e Google sono a un clic di distanza. Scegli _Custom_ per inserire i tuoi server.

Dal terminale, `omarchy dns` stampa il provider attuale e `omarchy dns Cloudflare` ne imposta uno.

## Fissare la banda Wi-Fi

Se il tuo router mette 2.4GHz, 5GHz e 6GHz sotto lo stesso nome di rete, il tuo laptop a volte si aggrappa a quella lenta. `omarchy network band` mostra su quale banda sei, e `omarchy network band 5` la fissa. Usa `auto` per lasciare che scelga di nuovo da solo.

Questo fissa la banda, non un access point specifico, quindi continui a passare da un AP all'altro normalmente.

## Quanto è veloce?

_Trigger > Speed Test > Network Speed Test_ misura la tua effettiva velocità in download e in upload con una coppia di quadranti. Dal terminale è `omarchy network speedtest down` oppure `up`. (Accanto, in quel menu, c'è un test della velocità del disco, se stai misurando l'altro collo di bottiglia.)

## Il firewall

Il firewall è attivo per impostazione predefinita e blocca tutto il traffico in entrata, con un'eccezione: la porta 53317, così [LocalSend](22-guis.md) funziona subito, senza bisogno di configurazione.

SSH è disattivato finché non lo attivi con _Setup > Security > SSHD_, che avvia il demone, apre la porta 22 con limitazione della frequenza contro gli attacchi brute force e autorizza una chiave. Anche Docker è blindato, così i container non possono esporsi accidentalmente al mondo. Vedi [sicurezza](48-security.md) per tutta la storia.

## Tailscale

[Tailscale](https://tailscale.com/) è una VPN mesh che rende semplice e sicuro raggiungere tutti i tuoi computer e server via internet. Installala con _Install > Service > Tailscale_.

Questo ti dà un pannello Tailscale nella barra, che connette e disconnette la tailnet, cambia account e sceglie un exit node — nella lista compaiono sia le tue macchine sia le regioni Mullvad. Permette anche di esplorare le tue macchine, ed è lì che si trova Taildrop: seleziona una macchina e premi `s` per inviarle file, oppure `c`, `n` e `d` per copiare il suo IP, il suo nome o il suo nome DNS completo. L'equivalente da terminale è `omarchy tailscale send <machine> [file...]`, e i file inviati a te finiscono automaticamente in `~/Downloads`. La notifica che annuncia un arrivo resta lì finché non fai clic per aprirla o non la chiudi, così un file che arriva mentre sei lontano dalla macchina è ancora lì ad aspettarti quando torni.

Installarla aggiunge anche una web app per la console di amministrazione di Tailscale.

## Quando smette di funzionare

Prima di riavviare, prova a riavviare da solo il pezzo che dà problemi. _Update > Hardware_ ha Wi-Fi, Bluetooth, Audio e Trackpad, e ricaricare uno di questi risolve la maggior parte delle situazioni del tipo "funzionava cinque minuti fa". Vedi [risoluzione dei problemi](45-troubleshooting.md).
