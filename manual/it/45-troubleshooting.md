# Risoluzione dei problemi

### Ho rotto il mio sistema con un aggiornamento!

Prova prima a [ripristinare il tuo sistema](47-system-snapshots.md) alla versione precedente al tuo aggiornamento recente. Se non funziona, usa `omarchy-debug` per condividere il tuo problema su #omarchy-help nel Discord. E se tutto questo non basta, puoi reinstallare le configurazioni e i pacchetti predefiniti usando `omarchy-reinstall`.

### Perché alcune app sono così grandi sul mio display?

Omarchy presume un display ad alta risoluzione 2x, che richiede di impostare `GDK_SCALE` su 2 in `~/.config/hypr/monitors.lua`. Ma se sei su un display 1x, puoi cambiare `local omarchy_gdk_scale = 2` in 1 (e poi riavviare qualsiasi app sovradimensionata). Vedi [il manuale sui monitor](33-monitors.md).

Per Spotify, puoi usare `Ctrl + Minus` per ridurre l'interfaccia (e `Ctrl + Plus` per ingrandirla).

### Perché tutte le mie combinazioni con il tasto Super hanno smesso di funzionare?

Su alcuni laptop ASUS ROG e TUF, `Fn + Super` è una combinazione facile da premere per sbaglio che attiva/disattiva un blocco firmware del tasto Windows (pensato per il gaming, per non uscire da un gioco per errore). Niente sullo schermo ti avvisa che è successo. Mentre il blocco è attivo, Super non emette assolutamente nulla — quindi ogni scorciatoia di Omarchy che usa Super smette semplicemente di funzionare, e sembra che si sia rotto Hyprland.

Premi `Fn + Super` una volta prima di metterti a scavare in `~/.config/hypr/`, e se questo non fa tornare Super, premilo di nuovo per non lasciare il blocco attivo. Non si tratta del Fn-lock, che cambia solo il comportamento della riga dei tasti F.

### Wi-Fi, Bluetooth, audio o trackpad hanno appena smesso di funzionare

Prima di riavviare, prova a riavviare da solo il sottosistema incriminato. _Update > Hardware_ nel menu di Omarchy include Wi-Fi, Bluetooth, Audio e Trackpad, e ricaricare uno di questi risolve la maggior parte delle situazioni del tipo "funzionava cinque minuti fa" — cuffie Bluetooth che non vogliono ricollegarsi, un trackpad morto dopo una sospensione, l'audio sparito quando hai scollegato un monitor.

### Perché i miei altoparlanti esterni non suonano?

Probabilmente perché non sono impostati come uscita principale. Clicca sull'icona dell'altoparlante sul lato destro della barra, e si aprirà il popup del volume dove puoi scegliere il dispositivo di uscita (e anche mixare i volumi per singola app).

### Gli altoparlanti del mio laptop suonano male

Su alcuni laptop, Omarchy applica automaticamente una regolazione degli altoparlanti che corregge la risposta in frequenza degli altoparlanti integrati. `omarchy audio tuning status` ti dice se ne è attiva una sulla tua macchina, e `omarchy audio tuning off` la disattiva se preferisci sentire gli altoparlanti senza correzioni.

### Perché non riesco ad accedere o a usare sudo con la mia password?

Probabilmente l'hai digitata sbagliata troppe volte e sei stato bloccato fuori. Se sta succedendo nella schermata di blocco, puoi premere `CTRL + ALT + F2` per avviare un nuovo TTY dove puoi accedere come root, poi eseguire `faillock --reset --user [your-username]`. Questo resetterà il blocco, e sei a posto.

### Perché non compaiono le mie richieste di autorizzazione di 1Password per 1Password SSH Agent / CLI?

Questo può succedere per 2 motivi:

Affinché compaia la richiesta di approvazione completa, Settings > Advanced > Use Hardware Acceleration deve essere attivato. _Nota: questo richiede un riavvio per iniziare a funzionare._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Oppure, se non hai avviato 1Password dall'accensione, la richiesta non comparirà.
