# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) è una deliziosa alternativa a qualcosa come l'applicazione GitHub Desktop, e funziona all'interno del terminale.

Puoi eseguirlo direttamente, andando in una qualsiasi directory gestita da git ed eseguendo `lazygit`. Oppure puoi eseguirlo all'interno di Neovim, dove può essere avviato con `Space G G`.

Passi da un riquadro all'altro usando `Tab`. Nel riquadro Files, selezioni i file per lo staging usando `Space`, e poi puoi creare un nuovo commit usando `c`. Puoi vedere tutti i comandi disponibili usando `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) è un bellissimo gestore di risorse che mostra l'uso di memoria, CPU, disco e rete. Elenca anche tutti i processi attivi e ti permette di gestirli.

Omarchy lo chiama Activity Monitor, e lo avvii dal launcher delle applicazioni o premendo `Super + Shift + T`. Si apre come una finestra mobile, che puoi inserire nel layout a finestre affiancate con `Super + T`.

## Herdr

[Herdr](https://herdr.dev) è un gestore di spazi di lavoro per il terminale che ti offre spazi di lavoro, schede e riquadri, e li mantiene tutti in esecuzione in una sessione persistente da cui puoi scollegarti e a cui puoi tornare in seguito.

Lo avvii (o ti ricolleghi alla tua sessione esistente) dal launcher delle applicazioni o con `Super + Ctrl + Return`. Omarchy include una configurazione di Herdr che rispecchia la sua configurazione di Tmux, quindi anche qui il tasto prefisso è `Ctrl + Space`. Puoi sfogliare tutte le associazioni di tasti con `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) mostra informazioni di sistema, come versione del kernel, tempo di attività, tema, CPU, memoria e altro ancora. È il successore del popolare strumento neofetch.

Omarchy lo ha inserito come _Sistema > Informazioni_ nel menu di Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) è un lettore musicale retrò per terminale ispirato a Winamp 2.x, completo di stazioni radio integrate per ritmi lo-fi. Avvialo con `Super + Shift + Alt + M`, o dal menu di Omarchy sotto _App_. Premi `?` per l'elenco completo delle associazioni di tasti.

## E per quanto riguarda Wi-Fi e Bluetooth?

Non troverai TUI per Wi-Fi e Bluetooth — quei compiti spettano alla shell di Omarchy. Clicca sull'icona Wi-Fi nella barra superiore (o premi `Super + Ctrl + N`) per vedere le reti e connetterti, e clicca sull'icona Bluetooth (o premi `Super + Ctrl + B`) per abbinare e connettere dispositivi. Vedi [rete](35-networking.md) per la storia completa.

## Aggiungere le proprie

Qualsiasi programma per terminale può ricevere il trattamento completo da applicazione. Vai su _Installa > TUI_ nel menu di Omarchy (`Super + Space`), dagli un nome, un comando di avvio, uno stile di finestra e un'icona, e apparirà nel launcher delle applicazioni come qualsiasi altra applicazione. Puoi rimuoverlo di nuovo sotto _Rimuovi > TUI_.
