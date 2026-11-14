# Risoluzione dei problemi

### Ho rotto il sistema con un aggiornamento!

Prima prova a [ripristinare il sistema](47-system-snapshots.md) alla versione precedente al tuo aggiornamento recente. Se non funziona, usa `omarchy-debug` per condividere il tuo problema su #omarchy-help in Discord. E se tutto questo fallisce, puoi reinstallare le configurazioni e i pacchetti predefiniti usando `omarchy-reinstall`.

### Perché alcune app sono così grandi sul mio display?

Omarchy presume un display ad alta risoluzione 2x, quindi imposta `GDK_SCALE` a 2 finché non scegli una scala nel pannello del monitor. Se sei su un display 1x e le app GTK o X11 risultano sovradimensionate, scegli 1x per esso nel pannello del monitor, oppure aggiungi `hl.env("GDK_SCALE", "1")` a `~/.config/hypr/monitors.lua` (e poi riavvia qualsiasi app sovradimensionata). Vedi [il manuale sui monitor](33-monitors.md).

Per Spotify, puoi usare `Ctrl + Minus` per rimpicciolire l'interfaccia (e `Ctrl + Plus` per ingrandirla).

### Perché tutte le mie scorciatoie con Super hanno smesso di funzionare?

Su alcuni laptop ASUS ROG e TUF, `Fn + Super` è una combinazione facile da premere per sbaglio che attiva e disattiva un blocco firmware del tasto Windows (pensato per il gaming, così non esci da un gioco per errore). Niente sullo schermo ti avvisa che è successo. Mentre il blocco è attivo, Super non emette assolutamente nulla — quindi ogni scorciatoia di Omarchy che usa Super smette semplicemente di funzionare, e sembra che si sia rotto Hyprland.

Premi `Fn + Super` una volta prima di andare a scavare in `~/.config/hypr/`, e se questo non fa tornare Super, premilo di nuovo così non lasci il blocco attivo. Non si tratta del Fn-lock, che cambia solo il comportamento della fila dei tasti F.

### Il mio Wi-Fi, Bluetooth, audio o trackpad ha appena smesso di funzionare

Prima di riavviare, prova a riavviare da solo il sottosistema incriminato. _Update > Hardware_ nel menu di Omarchy ha Wi-Fi, Bluetooth, Audio e Trackpad, e ricaricare uno di questi risolve la maggior parte delle situazioni "funzionava cinque minuti fa" — cuffie Bluetooth che non vogliono ricollegarsi, un trackpad morto dopo una sospensione, l'audio sparito quando hai scollegato un monitor.

### Perché i miei altoparlanti esterni non riproducono nulla?

Probabilmente perché non sono impostati come uscita principale. Clicca sull'icona dell'altoparlante sul lato destro della barra, e si aprirà il popup del volume dove puoi scegliere il dispositivo di uscita (e anche regolare i volumi per singola app).

### Gli altoparlanti del mio laptop suonano male

Su alcuni laptop, Omarchy applica automaticamente una regolazione degli altoparlanti che corregge la risposta in frequenza degli altoparlanti integrati. `omarchy audio tuning status` ti dice se ne è attiva una sulla tua macchina, e `omarchy audio tuning off` la disattiva se preferisci sentire gli altoparlanti senza correzioni.

### Perché non riesco ad accedere o a usare sudo con la mia password?

Probabilmente l'hai digitata sbagliata troppe volte e sei stato bloccato. Se succede nella schermata di blocco, puoi premere `CTRL + ALT + F2` per avviare una nuova TTY dove puoi accedere come root, poi eseguire `faillock --reset --user [your-username]`. Questo azzererà il blocco, e sei a posto.

### La mia password viene accettata, ma torno alla schermata di accesso

Un file di ambiente della sessione danneggiato può impedire l'avvio del desktop anche quando la password è corretta. Vale soprattutto la pena controllarlo dopo aver modificato `~/.config/uwsm/env.d/`.

Premi `Ctrl + Alt + F2`, accedi con il tuo normale nome utente e password, e ispeziona il journal utente dell'avvio corrente:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Cerca un errore che nomina uno dei tuoi file di ambiente, come `bad substitution`, subito prima di un messaggio che indica che il marcatore di output dell'ambiente non è stato trovato. Sposta quel file fuori da `env.d` prima di provare ad accedere di nuovo. Per esempio, se l'errore nomina `99-custom`:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM salta un file con un errore di sintassi, ma un errore fatale che si manifesta solo mentre il file viene eseguito, come `bad substitution`, può comunque impedire l'avvio del desktop. Un ripristino da snapshot di sistema non ripara questi file, perché `/home` non viene ripristinata.

Una volta che riesci ad accedere, correggi la copia salvata prima di rimetterla al suo posto. `sh -n` intercetta gli errori di sintassi senza eseguire il file, ma non può intercettare ogni errore che si verifica quando viene caricato. Tieni aperto un terminale funzionante mentre testi le modifiche.

### Perché non appaiono i prompt di autorizzazione di 1Password per 1Password SSH Agent / CLI?

Questo può succedere per 2 motivi:

Affinché appaia il prompt di approvazione completo, Settings > Advanced > Use Hardware Acceleration deve essere attivato. _Nota: questo richiede un riavvio per iniziare a funzionare._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Oppure, se non hai avviato 1Password dall'accensione, il prompt non apparirà.
