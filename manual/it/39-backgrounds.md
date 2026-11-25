# Sfondi

Ogni tema viene fornito con il proprio set di sfondi, e puoi aggiungerne altri tuoi in `~/.config/omarchy/backgrounds/[theme]`. Se vuoi aggiungere un'immagine di sfondo extra, ad esempio, al tema nord, basta mettere il file in `~/.config/omarchy/backgrounds/nord`.

Puoi farlo nel modo più semplice andando su _Install > Style > Background_ nel Menu Omarchy. Si aprirà la cartella in cui sono memorizzati gli sfondi per quel tema. Premi `Super + Shift + F` per avviare un altro file manager, trova il tuo sfondo, copialo lì. Ora sarà incluso tra le scelte di sfondi tra cui puoi selezionare usando `Super + Ctrl + W`.

Un tema senza sfondi propri ne ottiene uno disegnato dai suoi colori: il logo Omarchy nel colore d'accento del tema sul suo colore di sfondo. Aggiungi i tuoi per sostituirlo.

Gli sfondi possono essere anche video oltre che immagini fisse. Inserisci un file `mp4`, `m4v`, `mov`, `webm`, `mkv` o `avi` nella stessa cartella e apparirà accanto alle immagini. I video vengono riprodotti dal motore di sfondi OWE. Decodifica il video una volta per tutti i monitor e riproduce il suo audio attraverso l'uscita audio predefinita, e interrompe la riproduzione ogni volta che nulla può vederlo. Uno sfondo video costa comunque molta più energia di uno fisso.

I temi possono includere una breve intro per uno sfondo fisso. Per `backgrounds/road.webp`, il video corrispondente si trova in `backgrounds/intros/road.mp4`. Viene riprodotto automaticamente all'avvio, quando passi a un tema con quello sfondo selezionato e quando scegli quello sfondo, poi torna all'immagine fissa. I video intro restano fuori dal selettore degli sfondi e non vanno mai in loop.

Scegliere _Appearance > Animations Off_ disattiva anche le intro degli sfondi. Omarchy lo fa per impostazione predefinita in una virtual machine. Il comando `omarchy theme bg intro toggle` può attivare e disattivare le intro separatamente. Aggiornare un tema non riproduce un'intro.

Un'immagine fissa può anche avere un loop, una versione silenziosa della stessa immagine che continua a muoversi, in `backgrounds/loops/road.mp4`. Viene riprodotto al posto dell'immagine fissa, dopo la sua intro se ne ha una, e si interrompe quando le animazioni sono disattivate. A batteria, viene mostrata invece l'immagine fissa, e il loop torna non appena colleghi l'alimentazione. I loop restano fuori dal selettore degli sfondi.

Puoi trovare un'enorme raccolta di sfondi curati e fighi in [dharmx/walls](https://github.com/dharmx/walls).

La schermata di blocco mostra un fotogramma fisso di uno sfondo video, allo stesso modo in cui mostra un fotogramma fisso di una GIF animata.
