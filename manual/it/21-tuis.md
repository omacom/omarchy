# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) è un'alternativa deliziosa a qualcosa come l'applicazione GitHub Desktop, e gira dentro il terminale.

Puoi eseguirlo direttamente, andando in qualsiasi directory gestita da git ed eseguendo `lazygit`. Oppure puoi eseguirlo dentro Neovim, dove può essere avviato con `Space G G`.

Passi da un riquadro all'altro usando `Tab`. Nel riquadro Files, selezioni i file per lo staging usando `Space`, e poi puoi creare un nuovo commit usando `c`. Puoi vedere tutti i comandi disponibili usando `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) è un bellissimo gestore di risorse che mostra l'utilizzo di memoria, CPU, disco e rete. Elenca anche tutti i processi attivi e ti permette di gestirli.

Omarchy lo chiama Activity, e lo avvii premendo `Super + Shift + T`. Si apre come finestra flottante, che puoi affiancare con `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) è un gestore di workspace per il terminale che ti offre workspace, schede e riquadri, e li mantiene tutti in esecuzione in una sessione persistente da cui puoi scollegarti e a cui puoi tornare più tardi.

Lo avvii (o ti ricolleghi alla tua sessione esistente) con `Super + Ctrl + Return`. Omarchy include una configurazione di Herdr che rispecchia la sua configurazione di Tmux, quindi anche qui il tasto prefisso è `Ctrl + Space`. Puoi sfogliare tutte le scorciatoie da tastiera con `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) mostra informazioni di sistema, come versione del kernel, tempo di attività, tema, CPU, memoria e altro ancora. È il successore del popolare strumento neofetch.

Omarchy lo ha incluso come _About_ nel menu Omarchy (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) è un lettore musicale retrò per il terminale ispirato a Winamp 2.x, completo di stazioni radio integrate per ritmi lo-fi. Avvialo con `Super + Shift + Alt + M`, oppure dal menu Omarchy sotto _Apps_. Premi `?` per l'elenco completo delle scorciatoie da tastiera.

## E Wi-Fi e Bluetooth?

Non troverai TUI per Wi-Fi e Bluetooth — quei compiti spettano alla shell di Omarchy. Fai clic sull'icona Wi-Fi nella barra superiore (o premi `Super + Ctrl + N`) per vedere le reti e connetterti, e fai clic sull'icona Bluetooth (o premi `Super + Ctrl + B`) per associare e connettere i dispositivi. Vedi [rete](35-networking.md) per la storia completa.

## Aggiungere le tue

Qualsiasi programma per terminale può ricevere il trattamento completo da app. Vai su _Install > TUI_ nel menu Omarchy (`Super + Space`), dagli un nome, un comando di avvio, uno stile per la finestra e un'icona, e apparirà nel launcher delle app come qualsiasi altra applicazione. Puoi rimuoverlo di nuovo sotto _Remove > TUI_.
