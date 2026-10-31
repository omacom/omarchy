# Risoluzione dei problemi

### Ho rotto il sistema con un aggiornamento!

Prima prova a [ripristinare il sistema](47-system-snapshots.md) alla versione precedente al tuo aggiornamento recente. Se non funziona, usa `omarchy-debug` per condividere il tuo problema su #omarchy-help nel Discord. E se anche questo fallisce, puoi reinstallare le configurazioni e i pacchetti predefiniti usando `omarchy-reinstall`.

### Perché alcune app sono così grandi sul mio schermo?

Omarchy presuppone uno schermo ad alta risoluzione 2x, quindi imposta `GDK_SCALE` su 2 finché non scegli un fattore di scala nel pannello del monitor. Se hai uno schermo 1x e le app GTK o X11 risultano sovradimensionate, scegli 1x per esso nel pannello del monitor, oppure aggiungi `hl.env("GDK_SCALE", "1")` a `~/.config/hypr/monitors.lua` (e poi riavvia qualsiasi app sovradimensionata). Vedi [il manuale sui monitor](33-monitors.md).

Per Spotify, puoi usare `Ctrl + Minus` per rimpicciolire l'interfaccia (e `Ctrl + Plus` per ingrandirla).

### Perché tutte le mie scorciatoie con Super hanno smesso di funzionare?

Su alcuni portatili ASUS ROG e TUF, `Fn + Super` è una combinazione facile da premere per sbaglio che attiva/disattiva un blocco firmware del tasto Windows (pensato per il gaming, così non esci da una partita per errore). Niente sullo schermo ti avvisa che è successo. Con il blocco attivo, Super non emette proprio nulla — quindi ogni scorciatoia di Omarchy che usa Super smette semplicemente di funzionare, e sembra che si sia rotto Hyprland.

Premi `Fn + Super` una volta prima di andare a scavare in `~/.config/hypr/`, e se questo non fa tornare Super, premilo di nuovo per non lasciare il blocco attivo. Non è l'Fn-lock, che cambia solo il comportamento della fila dei tasti F.

### Wi-Fi, Bluetooth, audio o trackpad hanno appena smesso di funzionare

Prima di riavviare, prova a riavviare da solo il sottosistema incriminato. _Update > Hardware_ nel menu di Omarchy include Wi-Fi, Bluetooth, Audio e Trackpad, e ricaricarne uno risolve la maggior parte delle situazioni del tipo "funzionava cinque minuti fa" — cuffie Bluetooth che non vogliono ricollegarsi, un trackpad morto dopo una sospensione, l'audio sparito quando hai scollegato un monitor.

### Perché i miei altoparlanti esterni non riproducono nulla?

Probabilmente perché non sono impostati come uscita principale. Fai clic sull'icona dell'altoparlante sul lato destro della barra: si aprirà il popup del volume, dove puoi scegliere il dispositivo di uscita (e regolare anche i volumi per singola app).

### Gli altoparlanti del mio portatile suonano male

Su alcuni portatili, Omarchy applica automaticamente una regolazione degli altoparlanti che corregge la risposta in frequenza degli altoparlanti integrati. `omarchy audio tuning status` ti dice se ne è attiva una sulla tua macchina, e `omarchy audio tuning off` la disattiva se preferisci sentire gli altoparlanti senza correzioni.

### Perché non riesco ad accedere o usare sudo con la mia password?

Probabilmente l'hai digitata male troppe volte e sei stato bloccato fuori. Se succede nella schermata di blocco, puoi premere `CTRL + ALT + F2` per avviare una nuova TTY dove puoi accedere come root, poi eseguire `faillock --reset --user [your-username]`. Così resetterai il blocco e sarai a posto.

### Perché non compaiono le richieste di autorizzazione di 1Password per 1Password SSH Agent / CLI?

Può succedere per 2 motivi:

Affinché compaia la richiesta di approvazione completa, Settings > Advanced > Use Hardware Acceleration deve essere attivato. _Nota: richiede un riavvio per iniziare a funzionare._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Oppure, se non hai avviato 1Password dall'accensione, la richiesta non comparirà.
