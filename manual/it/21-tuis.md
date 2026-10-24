# TUI

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) è una deliziosa alternativa a qualcosa come l'applicazione GitHub Desktop, e gira all'interno del terminale.

Puoi eseguirlo direttamente, andando in una directory qualsiasi gestita da git ed eseguendo `lazygit`. Oppure puoi eseguirlo dentro Neovim, dove si avvia con `Space G G`.

Salti tra i diversi riquadri usando `Tab`. Nel riquadro Files selezioni i file per lo staging usando `Space`, poi puoi creare un nuovo commit usando `c`. Puoi vedere tutti i comandi disponibili usando `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) è un bellissimo gestore di risorse che mostra l'utilizzo di memoria, CPU, disco e rete. Elenca anche tutti i processi attivi e ti permette di gestirli.

Omarchy lo chiama Activity, e lo avvii premendo `Super + Ctrl + T`. Si apre come finestra flottante, che puoi affiancare con `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) è un gestore di spazi di lavoro del terminale che ti offre workspace, schede e riquadri, e li mantiene tutti in esecuzione in una sessione persistente da cui puoi staccarti e a cui puoi tornare in seguito.

Lo avvii (o ti ricolleghi alla sessione esistente) con `Super + Ctrl + Return`. Omarchy include una configurazione Herdr che rispecchia la sua configurazione Tmux, quindi anche qui il tasto prefisso è `Ctrl + Space`. Puoi sfogliare tutte le scorciatoie con `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) mostra informazioni di sistema, come versione del kernel, tempo di attività, tema, CPU, memoria e altro. È il successore del popolare strumento neofetch.

Omarchy lo ha impacchettato come _Info_ nel menu Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) è un lettore musicale da terminale in stile retrò ispirato a Winamp 2.x, completo di stazioni radio integrate per beat lo-fi. Avvialo con `Super + Shift + Alt + M`, oppure dal menu Omarchy in _App_. Premi `?` per l'elenco completo delle scorciatoie.

## E Wi-Fi e Bluetooth?

Non troverai TUI per Wi-Fi e Bluetooth — quei compiti spettano alla shell Omarchy. Fai clic sull'icona Wi-Fi nella barra superiore (oppure premi `Super + Ctrl + W`) per vedere le reti e connetterti, e fai clic sull'icona Bluetooth (oppure premi `Super + Ctrl + B`) per associare e connettere dispositivi. Vedi [rete](35-networking.md) per la storia completa.

## Aggiungere le tue

Qualsiasi programma da terminale può ricevere il trattamento completo da app. Vai in _Installa > TUI_ nel menu Omarchy (`Super + Space`), dagli un nome, un comando di avvio, uno stile di finestra e un'icona, e apparirà nel launcher delle app come qualsiasi altra applicazione. Puoi rimuoverlo di nuovo da _Rimuovi > TUI_.
