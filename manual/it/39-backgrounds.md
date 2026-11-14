# Sfondi

Ogni tema include il proprio set di sfondi e puoi aggiungerne altri tuoi in `~/.config/omarchy/backgrounds/[theme]`. Se vuoi aggiungere un'immagine di sfondo extra, ad esempio al tema nord, ti basta inserire il file in `~/.config/omarchy/backgrounds/nord`.

Puoi farlo nel modo più semplice andando su _Install > Style > Background_ nel Menu di Omarchy. Si aprirà la cartella in cui sono archiviati gli sfondi per quel tema. Premi `Super + Shift + F` per avviare un altro file manager, trova il tuo sfondo e copialo lì. Ora sarà incluso tra gli sfondi tra cui puoi scegliere usando `Super + Ctrl + W`.

Gli sfondi possono essere video oltre che immagini fisse. Inserisci un file `mp4`, `m4v`, `mov`, `webm`, `mkv` o `avi` nella stessa cartella e apparirà insieme alle immagini. I video vengono riprodotti dal motore di sfondi OWE. Decodifica il video una sola volta per tutti i monitor, riproduce il suo audio tramite l'uscita audio predefinita e interrompe la riproduzione ogni volta che nulla può vederlo. Uno sfondo video consuma comunque molta più energia di uno fisso.

I temi possono includere una breve intro per uno sfondo fisso. Per `backgrounds/road.webp`, il video corrispondente si trova in `backgrounds/intros/road.mp4`. Viene riprodotto automaticamente all'avvio, quando passi a un tema con quello sfondo selezionato e quando scegli quello sfondo, poi torna all'immagine fissa. I video intro restano fuori dal selettore degli sfondi e non vanno mai in loop.

Disattivare _Appearance > Animations_ disattiva anche le intro degli sfondi. Omarchy lo fa per impostazione predefinita in una macchina virtuale. Il comando `omarchy theme bg intro toggle` può attivare o disattivare le intro separatamente. L'aggiornamento di un tema non riproduce un'intro.

Puoi trovare una vasta raccolta di fantastici sfondi selezionati in [dharmx/walls](https://github.com/dharmx/walls).

La schermata di blocco mostra un fotogramma fisso di uno sfondo video, allo stesso modo in cui mostra un fotogramma fisso di una GIF animata.
