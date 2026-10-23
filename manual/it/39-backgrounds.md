# Sfondi

Ogni tema viene fornito con la propria serie di sfondi e puoi aggiungerne di tuoi in `~/.config/omarchy/backgrounds/[theme]`. Se vuoi aggiungere un'immagine di sfondo extra, ad esempio, al tema nord, devi solo mettere il file in `~/.config/omarchy/backgrounds/nord`.

Il modo più semplice per farlo è andare in _Installa > Stile > Sfondo_ nel menu di Omarchy. Si aprirà la cartella in cui sono conservati gli sfondi di quel tema. Premi `Super + Shift + F` per avviare un altro file manager, trova il tuo sfondo e copialo. Ora sarà incluso tra gli sfondi tra cui puoi scegliere con `Super + Ctrl + Space`.

Gli sfondi possono essere video oltre che immagini fisse. Metti un file `mp4`, `m4v`, `mov`, `webm`, `mkv` o `avi` nella stessa cartella e comparirà accanto alle immagini. I video vengono riprodotti dal motore per sfondi OWE. Decodifica il video una sola volta per tutti i monitor e riproduce l'audio attraverso l'uscita audio predefinita, e interrompe la riproduzione ogni volta che nulla può vederlo. La schermata di blocco disegna la stessa decodifica, in silenzio, tramite OWE. Uno sfondo video consuma comunque molta più energia di uno fisso.

I temi possono includere una breve introduzione per uno sfondo fisso. Per `backgrounds/road.webp`, il video corrispondente si trova in `backgrounds/intros/road.mp4`. Viene riprodotto automaticamente all'avvio e quando passi a un tema con quello sfondo selezionato, per poi tornare all'immagine fissa. I video introduttivi restano fuori dal selettore degli sfondi e non vanno mai in loop.

Disattivare _Azioni > Aspetto > Animazioni_ disattiva anche le introduzioni degli sfondi. Omarchy lo fa per impostazione predefinita in una macchina virtuale. Il comando `omarchy theme bg intro toggle` può attivare o disattivare le introduzioni separatamente. Aggiornare un tema o scegliere un altro sfondo all'interno dello stesso tema non riproduce un'introduzione.

Puoi trovare un'enorme collezione di sfondi fantastici e curati su https://github.com/dharmx/walls.

Gli sfondi video mantengono un'immagine fissa memorizzata nella cache sulla schermata di blocco mentre la riproduzione è in pausa o non disponibile. Le GIF animate vengono riprodotte sul desktop e mostrano un fotogramma fisso sulla schermata di blocco.
