# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) è una deliziosa alternativa a qualcosa come l'applicazione GitHub Desktop e funziona all'interno del terminale.

Puoi eseguirlo direttamente, andando in una qualsiasi directory gestita da git ed eseguendo `lazygit`. Oppure puoi eseguirlo all'interno di Neovim, dove può essere avviato con `Space G G`.

Passi da un riquadro all'altro usando `Tab`. Nel riquadro Files, selezioni i file per lo staging usando `Space`, poi puoi creare un nuovo commit usando `c`. Puoi vedere tutti i comandi disponibili usando `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) è un bellissimo gestore di risorse che mostra l'utilizzo di memoria, CPU, disco e rete. Elenca anche tutti i processi attivi e ti permette di gestirli.

Omarchy lo chiama Activity Monitor e lo avvii dal launcher delle applicazioni o premendo `Super + Shift + T`. Si apre come finestra fluttuante, che puoi affiancare alle altre con `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) è un gestore di spazi di lavoro da terminale che ti offre workspace, schede e riquadri, e li mantiene tutti in esecuzione in una sessione persistente da cui puoi scollegarti per tornarci in seguito.

Lo avvii (o ti ricolleghi alla tua sessione esistente) dal launcher delle applicazioni o con `Super + Ctrl + Return`. Omarchy fornisce una configurazione di Herdr che rispecchia la sua configurazione di Tmux, quindi anche qui il tasto prefisso è `Ctrl + Space`. Puoi consultare tutte le scorciatoie da tastiera con `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) mostra informazioni di sistema, come versione del kernel, tempo di attività, tema, CPU, memoria e altro ancora. È il successore del popolare strumento neofetch.

Omarchy lo ha incluso come _About_ nel menu Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) è un lettore musicale da terminale in stile retrò ispirato a Winamp 2.x, completo di stazioni radio integrate per beat lo-fi. Avvialo con `Super + Shift + Alt + M`, oppure dal menu Omarchy sotto _Apps_. Premi `?` per l'elenco completo delle scorciatoie da tastiera.

## Che dire di Wi-Fi e Bluetooth?

Non troverai TUI per Wi-Fi e Bluetooth — quei compiti spettano alla shell di Omarchy. Fai clic sull'icona del Wi-Fi nella barra superiore (o premi `Super + Ctrl + N`) per vedere le reti e connetterti, e fai clic sull'icona Bluetooth (o premi `Super + Ctrl + B`) per abbinare e collegare dispositivi. Vedi [rete](35-networking.md) per il quadro completo.

## Aggiungere le tue

Qualsiasi programma da terminale può ricevere lo stesso trattamento di un'app a tutti gli effetti. Vai su _Install > TUI_ nel menu Omarchy (`Super + Space`), dagli un nome, un comando di avvio, uno stile per la finestra e un'icona, e comparirà nel launcher delle applicazioni come qualsiasi altra applicazione. Puoi rimuoverlo di nuovo da _Remove > TUI_.
