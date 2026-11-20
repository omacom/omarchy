# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) è una deliziosa alternativa a qualcosa come l'applicazione GitHub Desktop, e funziona dentro il terminale.

Puoi eseguirlo direttamente, andando in una qualsiasi directory gestita da git ed eseguendo `lazygit`. Oppure puoi eseguirlo dentro Neovim, dove può essere avviato con `Space G G`.

Passi da un riquadro all'altro usando `Tab`. Nel riquadro Files, selezioni i file da mettere in staging usando `Space`, e poi puoi creare un nuovo commit usando `c`. Puoi vedere tutti i comandi disponibili usando `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) è un bellissimo gestore di risorse che mostra l'utilizzo di memoria, CPU, disco e rete. Elenca anche tutti i processi attivi e ti permette di gestirli.

Omarchy lo chiama Activity Monitor, e lo avvii dal launcher delle applicazioni o premendo `Super + Shift + T`. Si apre come finestra flottante, che puoi affiancare alle altre con `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) è un gestore di spazi di lavoro per terminale che ti offre spazi di lavoro, schede e riquadri, e li mantiene tutti in esecuzione in una sessione persistente da cui puoi scollegarti e a cui puoi tornare in seguito.

Lo avvii (o ti ricolleghi alla tua sessione esistente) dal launcher delle applicazioni o con `Super + Ctrl + Return`. Omarchy include una configurazione di Herdr che rispecchia la sua configurazione di Tmux, quindi anche qui il tasto prefisso è `Ctrl + Space`. Puoi sfogliare tutte le scorciatoie da tastiera con `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) mostra le informazioni di sistema, come versione del kernel, tempo di attività, tema, CPU, memoria e altro ancora. È il successore del popolare strumento neofetch.

Omarchy lo ha inserito come _Sistema > Informazioni_ nel menu di Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) è un lettore musicale da terminale in stile retrò ispirato a Winamp 2.x, completo di stazioni radio integrate per i ritmi lo-fi. Avvialo con `Super + Shift + Alt + M`, o dal menu di Omarchy sotto _App_. Premi `?` per l'elenco completo delle scorciatoie da tastiera.

## E per Wi-Fi e Bluetooth?

Non troverai TUI per Wi-Fi e Bluetooth — quei compiti spettano alla shell di Omarchy. Fai clic sull'icona Wi-Fi nella barra superiore (o premi `Super + Ctrl + N`) per vedere le reti e connetterti, e fai clic sull'icona Bluetooth (o premi `Super + Ctrl + B`) per associare e connettere i dispositivi. Vedi [rete](35-networking.md) per la storia completa.

## Aggiungere le tue

Qualsiasi programma da terminale può ricevere il trattamento completo da applicazione. Vai su _Installa > TUI_ nel menu di Omarchy (`Super + Space`), dagli un nome, un comando di avvio, uno stile di finestra e un'icona, e apparirà nel launcher delle applicazioni come qualsiasi altra applicazione. Puoi rimuoverlo di nuovo sotto _Rimuovi > TUI_.
