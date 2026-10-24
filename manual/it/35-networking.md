# Rete

In Omarchy la rete è gestita da NetworkManager e la controlli dall'icona di rete nella [barra superiore](05-the-top-bar.md) o con `Super + Ctrl + W`.

Quel pannello cerca le reti Wi-Fi, mostra la potenza del segnale e si connette. Ethernet non richiede nulla: colleghi il cavo e funziona. Se preferisci restare nel terminale, `nmtui` ti dà gli stessi controlli, e c'è anche un gruppo di comandi `omarchy network`.

## Condividere il Wi-Fi

Invece di dettare una password lunga a voce, apri _Impostazioni > Rete > Codice QR_ mentre sei connesso al Wi-Fi. Comparirà un codice QR sullo schermo che qualsiasi fotocamera del telefono può scansionare per connettersi. È una di quelle cose che userai più spesso di quanto immagini, una volta scoperto che esiste.

Se ti serve proprio la password, `omarchy network password <interface>` la stampa.

## DNS

Omarchy usa qualsiasi DNS la tua rete fornisca tramite DHCP. Puoi sostituirlo per l'intera macchina in _Impostazioni > Rete > DNS_, dove Cloudflare e Google sono a un clic di distanza. Scegli _Personalizzato_ per inserire i tuoi server.

Dal terminale, `omarchy dns` stampa il provider attuale e `omarchy dns Cloudflare` ne imposta uno.

## Bloccare la banda Wi-Fi

Se il tuo router mette 2,4GHz, 5GHz e 6GHz sullo stesso nome di rete, il portatile a volte si aggrappa a quella lenta. `omarchy network band` mostra su quale banda sei e `omarchy network band 5` la blocca. Usa `auto` per lasciargli di nuovo la scelta.

Questo blocca la banda, non un access point specifico, quindi continui a spostarti tra gli AP normalmente.

## Quanto va veloce?

_Azioni > Test velocità > Test velocità rete_ misura la tua velocità reale in download e upload con un paio di quadranti. Dal terminale è `omarchy network speedtest down` oppure `up`. (Nello stesso menu, accanto, c'è anche un test di velocità del disco, se vuoi misurare l'altro collo di bottiglia.)

## Il firewall

Il firewall è attivo per impostazione predefinita e blocca tutto il traffico in entrata, con un'eccezione: la porta 53317, così [LocalSend](22-guis.md) funziona subito.

SSH è disattivato finché non lo attivi con _Impostazioni > Sicurezza > SSHD_, che avvia il demone, apre la porta 22 con limitazione della frequenza contro gli attacchi brute force e autorizza una chiave. Anche Docker è blindato, così i container non possono esporsi accidentalmente al mondo. Vedi [sicurezza](48-security.md) per tutta la storia.

## Tailscale

[Tailscale](https://tailscale.com/) è una VPN mesh che rende semplice e sicuro raggiungere tutti i tuoi computer e server via internet. Installala con _Installa > Servizio > Tailscale_.

Questo ti dà un pannello Tailscale nella barra, che collega e scollega la tailnet, cambia account e sceglie un exit node: nella lista compaiono sia le tue macchine sia le regioni Mullvad. Sfoglia anche le tue macchine, ed è lì che vive Taildrop: seleziona una macchina e premi `s` per inviarle file, oppure `c`, `n` e `d` per copiarne l'IP, il nome o il nome DNS completo. L'equivalente da terminale è `omarchy tailscale send <machine> [file...]`, e i file che ti vengono inviati finiscono automaticamente in `~/Downloads`. La notifica che annuncia un arrivo resta finché non fai clic per aprirla o la chiudi, così un file arrivato mentre eri lontano dalla macchina è ancora lì ad aspettarti quando torni.

L'installazione aggiunge anche una web app per la console di amministrazione di Tailscale.

## Quando smette di funzionare

Prima di riavviare, prova a riavviare da solo il pezzo che dà problemi. _Aggiorna > Hardware_ ha Wi-Fi, Bluetooth, Audio e Trackpad, e ricaricare uno di questi risolve la maggior parte delle situazioni "cinque minuti fa funzionava". Vedi [risoluzione dei problemi](45-troubleshooting.md).
