# Screenshot e registrazione

Tutto ciò che puoi catturare dallo schermo dipende dal tasto Print Screen. Un tasto da solo fa una foto, e i modificatori fanno una registrazione, un colore o il testo dentro una regione. Se la tua tastiera non ha affatto un tasto Print Screen, `Super + Ctrl + Alt + C` fa lo stesso screenshot, e `Super + Ctrl + C` apre l'intero set come menu.

| Hotkey | Funzione |
| ------ | -------- |
| `Print Screen` | Screenshot |
| `Super + Ctrl + Alt + C` | Screenshot |
| `Alt + Print Screen` | Screenrecord (o ferma quella in corso) |
| `Super + Print Screen` | Selettore colore |
| `Super + Ctrl + Print Screen` | Estrai testo da una regione |
| `Super + Ctrl + C` | Menu di cattura |
| `Super + Ctrl + .` | Transcodifica un'immagine o un video |

## Screenshots

Premi `Print Screen` (o `Super + Ctrl + Alt + C`) e Omasnap cattura il monitor attivo prima che appaia il suo overlay, così nulla si sposta sotto di te mentre prendi la mira. Trascina una regione a mano libera, fai clic su una finestra per catturarla, o fai clic su uno spazio vuoto per catturare l'intero monitor. Premi `S` prima di disegnare per catturare una regione a scorrimento. Hai cambiato idea? Premi di nuovo lo stesso tasto per chiudere Omasnap.

Dopo aver selezionato un'area, Omasnap salva la cattura, la copia negli appunti e mostra una notifica con la sua miniatura, come fa una registrazione dello schermo salvata. Scegli Open per visualizzare lo scatto salvato nel tuo visualizzatore di immagini, o Edit per annotarlo.

L'editor di annotazioni può disegnare frecce, linee, forme, evidenziazioni, marcatori numerati, testo e redazioni sicure; ritagliare o tagliare via parte dell'immagine; eseguire l'OCR del suo testo; e aggiungere uno sfondo. Nell'editor, premi `Enter` per copiare e salvare il PNG finito, `Ctrl + C` per copiarlo senza salvarlo, o `Ctrl + S` per salvarlo senza copiarlo.

Gli screenshot salvati finiscono in `~/Pictures/Screenshots` per impostazione predefinita, con un nome come `screenshot-2026-08-13_14-22-05-firefox.png`. Imposta `OMASNAP_SCREENSHOT_DIR` per usare un'altra directory — vedi [le FAQ](46-faq.md) per dove mettere le variabili d'ambiente della sessione. Omasnap crea la directory quando salva il primo scatto. Imposta `[output] autosave = false` in `~/.config/omasnap/omasnap.conf` per disattivare il salvataggio automatico; le catture vengono allora solo copiate, e mostrate in un'anteprima per 7 secondi che puoi mantenere sullo schermo con il suo pulsante di blocco o `Ctrl + P`.

Dal terminale, `omarchy screenshot` apre lo stesso overlay, e puoi scegliere la sua modalità iniziale: `omarchy capture screenshot region`, `windows`, `fullscreen`, o `scroll`. Un secondo argomento `copy` o `save` invia lo scatto direttamente a quella destinazione. Per modificare prima dell'output, usa `omarchy screenshot --editor=overlay` per un editor a schermo intero o `omarchy screenshot --editor=window` per una finestra separata.

### Guidare il selettore dalla tastiera

Mentre la selezione è attiva, non devi usare affatto il mouse:

| Tasto | Funzione |
| --- | -------- |
| `S` | Attiva/disattiva la modalità regione a scorrimento |
| `Super + Arrow keys` | Spostati tra le finestre in modalità Window |
| `Return` | Cattura la finestra evidenziata |
| `Ctrl + A` | Cattura l'intero monitor attivo |
| `R` | Ripristina l'ultima regione disegnata in questa sessione |
| `Esc` | Chiudi Omasnap |

Queste associazioni esistono solo mentre Omasnap è aperto, quindi non possono entrare in conflitto con nulla nella tua configurazione.

## Registrazione dello schermo

`Alt + Print Screen` apre _Trigger > Capture > Screenrecord_, che chiede cosa vuoi nella colonna sonora: nessun audio, audio del desktop, desktop più microfono, o desktop più microfono più webcam. Quest'ultima appare solo se hai effettivamente una fotocamera collegata. Scegline una e il selettore di registrazione di Omarchy ti consente di trascinare una regione o fare clic su una finestra o un monitor.

La registrazione gira su gpu-screen-recorder, che codifica sulla GPU a 60fps e ripiega sulla CPU se deve; sulle GPU che non supporta, come quelle di Apple Silicon, Omarchy registra invece con wf-recorder. Il risultato è un MP4 in `~/Videos`, chiamato `screenrecording-2026-08-13_14-22-05.mp4`. Imposta `OMARCHY_SCREENRECORD_DIR` per cambiarlo — ma nota che, a differenza della directory degli screenshot, questa deve esistere già, altrimenti la registrazione si rifiuta di partire.

Mentre registri, un piccolo indicatore appare nella barra. Fai clic su di esso per fermarla. Puoi anche fermarla di nuovo con `Alt + Print Screen`, o con la voce _Stop Screenrecording_ sotto _Trigger > Capture > Screenrecord_, che appare solo mentre qualcosa sta effettivamente registrando.

Fermarla fa un po' di pulizia prima di consegnarti il file: il primo fotogramma viene tagliato, e se c'è audio viene normalizzato a -14 LUFS con il pop di cattura di PipeWire proprio all'inizio silenziato. Poi appare una notifica con una miniatura dalla registrazione. Scegli _Open_ per riprodurre il file in Omaview, o _Cut_ per tagliarlo in Omacut.

### L'overlay della webcam

Quando registri con una webcam, la fotocamera appare come una finestra ritratto bloccata e ritagliata nell'angolo in basso a destra di qualsiasi cosa tu stia registrando. Se sta sopra qualcosa che ti serve, ridimensionala al volo:

| Hotkey | Funzione |
| ------ | -------- |
| `Super + Alt + [` | Rendi l'overlay della webcam più piccolo |
| `Super + Alt + ]` | Rendi l'overlay della webcam più grande |

Ci sono tre dimensioni — piccola, media e grande — e i tasti di scelta rapida passano da una all'altra. La media è quella predefinita. Sono proporzionali alla registrazione, quindi la fotocamera occupa la stessa quota del fotogramma sia che tu registri un monitor 1080p sia uno 6K. E se hai registrato una regione anziché un intero display, l'overlay si ancora all'angolo di quella regione anziché a quello del monitor, così resta dentro lo scatto.

Puoi anche chiamarlo direttamente con `omarchy-capture-webcam-resize small`, o `reset` per tornare alla media.

## Testo, codici QR e colori

`Super + Ctrl + Print Screen` seleziona una regione e ne esegue l'OCR negli appunti. Questo è trattato come si deve in [Estrazione del testo e dettatura](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ fa lo stesso trucco per i codici QR. Seleziona la regione con il codice dentro, e il valore decodificato va negli appunti. Cerca solo codici QR — i contenuti densi dello schermo hanno l'abitudine di dare falsi positivi come codice a barre altrimenti. Vale la pena saperlo: il valore decodificato va negli appunti e da nessun'altra parte. Non viene stampato, non è nella notifica, ed è contrassegnato come sensibile così non resta nella [cronologia degli appunti](08-unified-clipboard-history.md). I codici QR portano abitualmente segreti — l'URI `otpauth://` dietro un codice di configurazione 2FA, per esempio — e non vuoi quello in un log. Incollare funziona comunque bene.

`Super + Print Screen` (o _Trigger > Capture > Color_) trasforma il cursore in un contagocce. Fai clic su qualsiasi cosa sullo schermo e il colore finisce negli appunti. Premi di nuovo il tasto di scelta rapida per uscire senza scegliere.

## Transcodifica prima di condividere

Una registrazione dello schermo 4K o un HEIC grezzo dal tuo telefono è spesso troppo grande da inviare e basta. `Super + Ctrl + .` (o _Trigger > Transcode_) risolve la cosa. Ti offre un selettore di file fuzzy su `~/Pictures` e `~/Videos`, poi chiede un formato e una dimensione.

Le immagini vanno in jpg o png ad alta, media o bassa, che limitano la larghezza a 3160, 2160 e 1080 pixel. I video vanno in mp4 o in una gif animata a 4k, 1080p o 720p. Il file convertito viene scritto accanto all'originale con la risoluzione nel nome — `demo-1080p.mp4` — e il percorso viene copiato negli appunti come URI di file, così puoi incollarlo direttamente in un'app che accetta file trascinati.

Funziona anche dal terminale, se sai già cosa vuoi: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. C'è anche `omarchy transcode ascii`, che trasforma un'immagine in arte ASCII — quello è soprattutto per il [branding](41-branding.md).

## Inviarlo da qualche parte

Una volta che hai il file, `Super + Ctrl + S` apre il menu Share e lo invia a un altro dispositivo sulla tua rete tramite LocalSend. Vedi [GUIs](22-guis.md) per quello.
