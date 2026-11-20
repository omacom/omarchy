# Sfondi

Ogni tema viene fornito con il proprio set di sfondi, e puoi aggiungerne altri tuoi in `~/.config/omarchy/backgrounds/[theme]`. Se vuoi aggiungere un'immagine di sfondo extra, ad esempio, al tema nord, basta mettere il file in `~/.config/omarchy/backgrounds/nord`.

Puoi farlo nel modo più semplice andando su _Install > Style > Background_ nel Menu Omarchy. Si aprirà la cartella in cui sono salvati gli sfondi di quel tema. Premi `Super + Shift + F` per avviare un altro file manager, trova il tuo sfondo e copialo lì.  Ora sarà incluso tra gli sfondi tra cui puoi scegliere usando `Super + Ctrl + W`.

Gli sfondi possono essere video oltre che immagini statiche. Metti un file `mp4`, `m4v`, `mov`, `webm`, `mkv` o `avi` nella stessa cartella e apparirà insieme alle immagini. I video vengono riprodotti dal motore di sfondi OWE. Decodifica il video una volta sola per tutti i monitor, riproduce il suo audio tramite l'uscita audio predefinita e interrompe la riproduzione ogni volta che niente può vederlo. Uno sfondo video consuma comunque molta più energia di uno statico.

I temi possono includere una breve intro per uno sfondo statico. Per `backgrounds/road.webp`, il video corrispondente si trova in `backgrounds/intros/road.mp4`. Viene riprodotto automaticamente all'avvio, quando passi a un tema con quello sfondo selezionato e quando scegli quello sfondo, poi torna all'immagine statica. I video intro restano fuori dal selettore degli sfondi e non vanno mai in loop.

Disattivare _Appearance > Animations_ disattiva anche le intro degli sfondi. Omarchy lo fa per impostazione predefinita in una macchina virtuale. Il comando `omarchy theme bg intro toggle` può attivare o disattivare le intro separatamente. L'aggiornamento di un tema non riproduce un'intro.

Un'immagine statica può avere anche un loop, una versione tranquilla della stessa immagine che continua a muoversi, in `backgrounds/loops/road.mp4`. Viene riprodotto al posto dell'immagine statica, dopo la sua intro se ne ha una, e si interrompe quando le animazioni sono disattivate. A batteria viene mostrata invece l'immagine statica, e il loop torna appena colleghi l'alimentazione. I loop restano fuori dal selettore degli sfondi.

Puoi trovare un'enorme raccolta di sfondi curati e fighi in [dharmx/walls](https://github.com/dharmx/walls).

La schermata di blocco mostra un fotogramma fermo di uno sfondo video, allo stesso modo in cui mostra un fotogramma fermo di una GIF animata.
