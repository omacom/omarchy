# Screenshot e registrazione

Tutto ciò che puoi catturare dallo schermo dipende dal tasto Print Screen. Un tasto da solo scatta una foto, e i modificatori ottengono una registrazione, un colore, o il testo dentro una regione. Se la tua tastiera non ha affatto un tasto Print Screen, `Super + Ctrl + Alt + C` scatta lo stesso screenshot, e `Super + Ctrl + C` apre l'intero set come menu.

| Scorciatoia | Funzione |
| ------ | -------- |
| `Print Screen` | Screenshot |
| `Super + Ctrl + Alt + C` | Screenshot |
| `Alt + Print Screen` | Registrazione schermo (o interrompi quella in corso) |
| `Super + Print Screen` | Selettore colore |
| `Super + Ctrl + Print Screen` | Estrai il testo da una regione |
| `Super + Ctrl + C` | Menu di cattura |
| `Super + Ctrl + .` | Transcodifica un'immagine o un video |

## Screenshot

Premi `Print Screen` (o `Super + Ctrl + Alt + C`) e Omasnap cattura il monitor attivo prima che appaia il suo overlay, così niente si sposta sotto di te mentre prendi la mira. Trascina una regione a mano libera, fai clic su una finestra per catturarla, o fai clic su uno spazio vuoto per catturare l'intero monitor. Premi `S` prima di disegnare per catturare una regione a scorrimento. Hai cambiato idea? Premi di nuovo lo stesso tasto per chiudere Omasnap.

Dopo aver selezionato un'area, Omasnap salva la cattura, la copia negli appunti e mostra una notifica con la sua miniatura, come fa una registrazione schermo salvata. Scegli Open per vedere lo scatto salvato nel tuo visualizzatore di immagini, o Edit per annotarlo.

L'editor di annotazioni può disegnare frecce, linee, forme, evidenziazioni, indicatori numerati, testo e oscuramenti sicuri; ritagliare o tagliare via parte dell'immagine; estrarne il testo con OCR; e aggiungere uno sfondo. Nell'editor, premi `Enter` per copiare e salvare il PNG finito, `Ctrl + C` per copiarlo senza salvarlo, o `Ctrl + S` per salvarlo senza copiarlo.

Gli screenshot salvati finiscono in `~/Pictures/Screenshots` per impostazione predefinita, con un nome come `screenshot-2026-08-13_14-22-05-firefox.png`. Imposta `OMASNAP_SCREENSHOT_DIR` per usare un'altra directory — vedi [la FAQ](46-faq.md) per dove mettere le variabili d'ambiente della sessione. Omasnap crea la directory quando salva il primo scatto. Imposta `[output] autosave = false` in `~/.config/omasnap/omasnap.conf` per disattivare il salvataggio automatico; le catture vengono allora solo copiate, e mostrate in un'anteprima per 10 secondi che puoi tenere sullo schermo con il suo pulsante di blocco o `Ctrl + P`.

Dal terminale, `omarchy screenshot` apre lo stesso overlay, e puoi sceglierne la modalità iniziale: `omarchy capture screenshot region`, `windows`, `fullscreen`, o `scroll`. Un secondo argomento `copy` o `save` invia lo scatto direttamente a quella destinazione. Per modificare prima dell'output, usa `omarchy screenshot --editor=overlay` per un editor a schermo intero o `omarchy screenshot --editor=window` per una finestra separata.

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

Queste combinazioni esistono solo mentre Omasnap è aperto, quindi non possono entrare in conflitto con niente nella tua configurazione.

## Registrazione schermo

`Alt + Print Screen` apre _Trigger > Capture > Screenrecord_, che ti chiede cosa vuoi nella colonna sonora: nessun audio, audio del desktop, desktop più microfono, o desktop più microfono più webcam. Quest'ultima opzione appare solo se hai davvero una fotocamera collegata. Scegline una e il selettore di registrazione di Omarchy ti permette di trascinare una regione o fare clic su una finestra o un monitor.

La registrazione gira su gpu-screen-recorder, che codifica sulla GPU a 60fps e ripiega sulla CPU se deve. Il risultato è un MP4 in `~/Videos`, chiamato `screenrecording-2026-08-13_14-22-05.mp4`. Imposta `OMARCHY_SCREENRECORD_DIR` per cambiarla — ma nota che, a differenza della directory degli screenshot, questa deve esistere già, altrimenti la registrazione si rifiuta di partire.

Mentre registri, nella barra appare un piccolo indicatore. Fai clic su di esso per fermarti. Puoi anche fermarti di nuovo con `Alt + Print Screen`, o con la voce _Stop Screenrecording_ sotto _Trigger > Capture > Screenrecord_, che appare solo mentre qualcosa sta davvero registrando.

L'arresto fa un po' di pulizia prima di consegnarti il file: il primo fotogramma viene tagliato e, se c'è audio, viene normalizzato a -14 LUFS con lo schiocco di cattura di PipeWire all'inizio silenziato. Poi appare una notifica con una miniatura della registrazione. Fai clic su di essa per riprodurre il file in Omaview.

### L'overlay della webcam

Quando registri con una webcam, la fotocamera appare come una finestra verticale fissata e ritagliata nell'angolo in basso a destra di ciò che stai registrando. Se sta sopra qualcosa che ti serve, ridimensionala al volo:

| Scorciatoia | Funzione |
| ------ | -------- |
| `Super + Alt + [` | Rendi l'overlay della webcam più piccolo |
| `Super + Alt + ]` | Rendi l'overlay della webcam più grande |

Ci sono tre dimensioni — piccola, media e grande — e le scorciatoie passano da una all'altra. Media è l'impostazione predefinita. Sono proporzionali alla registrazione, quindi la fotocamera occupa la stessa quota del fotogramma sia che tu registri un monitor 1080p sia uno 6K. E se hai registrato una regione invece di un intero display, l'overlay si ancora all'angolo di quella regione invece che a quello del monitor, così resta dentro lo scatto.

Puoi anche chiamarlo direttamente con `omarchy-capture-webcam-resize small`, o `reset` per tornare a media.

## Testo, codici QR e colori

`Super + Ctrl + Print Screen` seleziona una regione e ne estrae il testo con OCR negli appunti. Questo è trattato come si deve in [Estrazione del testo e dettatura](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ fa lo stesso trucco per i codici QR. Seleziona la regione con il codice dentro, e il valore decodificato va negli appunti. Cerca solo codici QR — i contenuti densi sullo schermo hanno la brutta abitudine di risultare altrimenti come falsi positivi da codice a barre. Vale la pena saperlo: il valore decodificato va negli appunti e da nessun'altra parte. Non viene stampato, non è nella notifica, ed è contrassegnato come sensibile così non resta nella [cronologia degli appunti](08-unified-clipboard-history.md). I codici QR trasportano abitualmente segreti — l'URI `otpauth://` dietro un codice di configurazione 2FA, per esempio — e non vuoi una cosa del genere in un log. Incollare funziona comunque bene.

`Super + Print Screen` (o _Trigger > Capture > Color_) trasforma il cursore in un contagocce. Fai clic su qualsiasi cosa sullo schermo e il colore finisce negli appunti. Premi di nuovo la scorciatoia per uscire senza scegliere.

## Transcodifica prima di condividere

Una registrazione schermo 4K o un HEIC grezzo dal telefono è spesso troppo grande da inviare così com'è. `Super + Ctrl + .` (o _Trigger > Transcode_) risolve il problema. Ti offre un selettore di file fuzzy su `~/Pictures` e `~/Videos`, poi ti chiede un formato e una dimensione.

Le immagini vanno in jpg o png a qualità alta, media o bassa, che limitano la larghezza a 3160, 2160 e 1080 pixel. I video vanno in mp4 o in una gif animata a 4k, 1080p o 720p. Il file convertito viene scritto accanto all'originale con la risoluzione nel nome — `demo-1080p.mp4` — e il percorso viene copiato negli appunti come URI di file, così puoi incollarlo direttamente in un'app che accetta file trascinati.

Funziona anche dal terminale, se sai già cosa vuoi: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. C'è anche `omarchy transcode ascii`, che trasforma un'immagine in arte ASCII — quello serve soprattutto per il [branding](41-branding.md).

## Inviarlo da qualche parte

Una volta che hai il file, `Super + Ctrl + S` apre il menu Share e lo invia a un altro dispositivo sulla tua rete tramite LocalSend. Vedi [GUIs](22-guis.md) per questo.
