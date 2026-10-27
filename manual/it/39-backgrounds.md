# Sfondi

Ogni tema viene fornito con il suo set di sfondi, e puoi aggiungerne altri tuoi in `~/.config/omarchy/backgrounds/[theme]`. Se vuoi aggiungere un'immagine di sfondo extra, diciamo, al tema nord, metti semplicemente il file in `~/.config/omarchy/backgrounds/nord`.

Puoi farlo nel modo più semplice andando su _Installa > Stile > Sfondo_ nel Menu di Omarchy. Si aprirà la cartella in cui sono archiviati gli sfondi di quel tema. Premi `Super + Shift + F` per avviare un altro file manager, trova il tuo sfondo e copialo lì dentro. Ora sarà incluso tra gli sfondi tra cui puoi scegliere usando `Super + Ctrl + W`.

Gli sfondi possono essere video oltre che immagini fisse. Metti un file `mp4`, `m4v`, `mov`, `webm`, `mkv` o `avi` nella stessa cartella e apparirà accanto alle immagini. I video vengono riprodotti dal motore di sfondi OWE. Decodifica il video una sola volta per tutti i monitor, ne riproduce l'audio attraverso l'uscita audio predefinita e interrompe la riproduzione ogni volta che niente può vederlo. Uno sfondo video consuma comunque molta più energia di uno fisso.

I temi possono includere una breve intro per uno sfondo fisso. Per `backgrounds/road.webp`, il video corrispondente si trova in `backgrounds/intros/road.mp4`. Viene riprodotto automaticamente all'avvio e quando passi a un tema con quello sfondo selezionato, poi torna all'immagine fissa. I video intro restano fuori dal selettore degli sfondi e non vanno mai in loop.

Disattivare _Aspetto > Animazioni_ disattiva anche le intro degli sfondi. Omarchy lo fa per impostazione predefinita in una macchina virtuale. Il comando `omarchy theme bg intro toggle` può attivare e disattivare le intro separatamente. Aggiornare un tema o scegliere un altro sfondo all'interno dello stesso tema non riproduce un'intro.

Puoi trovare un'enorme collezione di sfondi fighi e curati in [dharmx/walls](https://github.com/dharmx/walls).

La schermata di blocco mostra un fotogramma fisso di uno sfondo video, allo stesso modo in cui mostra un fotogramma fisso di una GIF animata.
