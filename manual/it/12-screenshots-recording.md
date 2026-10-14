# Schermate e registrazione

Tutto ciò che puoi afferrare dallo schermo dipende dal tasto Print Screen. Un tasto da solo scatta una foto, e i modificatori catturano una registrazione, un colore o il testo dentro una regione. Se la tua tastiera non ha affatto un tasto Print Screen, `Super + Ctrl + C` apre lo stesso insieme come menu.

| Scorciatoia | Funzione |
| ------ | -------- |
| `Print Screen` | Schermata |
| `Alt + Print Screen` | Registra schermo (o ferma quella in corso) |
| `Super + Print Screen` | Selettore colore |
| `Super + Ctrl + Print Screen` | Estrai testo da una regione |
| `Super + Ctrl + C` | Menu Cattura |
| `Super + Ctrl + .` | Converti un'immagine o un video |

## Schermate

Premi `Print Screen` e Omasnap cattura il monitor focalizzato prima che appaia il suo overlay, così nulla si sposta sotto di te mentre miri. Trascina una regione a forma libera, clicca una finestra per catturarla o clicca spazio aperto per catturare l'intero monitor. Premi `S` prima di disegnare per catturare una regione a scorrimento. Hai cambiato idea? Premi di nuovo `Print Screen` per chiudere Omasnap.

Dopo aver selezionato un'area, Omasnap salva la cattura, la copia negli appunti e mostra un'anteprima per 10 secondi. Usa il pulsante segnaposto dell'anteprima o `Ctrl + P` per mantenerla sullo schermo, oppure scegli Modifica per annotarla.

L'editor di annotazioni può disegnare frecce, linee, forme, evidenziazioni, marcatori numerati, testo e oscuramenti sicuri; ritagliare o tagliare parte dell'immagine; fare OCR del suo testo; e aggiungere uno sfondo. Nell'editor, premi `Enter` per copiare e salvare il PNG finito, `Ctrl + C` per copiarlo senza salvare o `Ctrl + S` per salvarlo senza copiare.

Le schermate salvate finiscono in `~/Pictures/Screenshots` per impostazione predefinita, con un nome come `screenshot-2026-08-13_14-22-05-firefox.png`. Imposta `OMASNAP_SCREENSHOT_DIR` per usare un'altra cartella — vedi [le FAQ](46-faq.md) per dove mettere le variabili d'ambiente di sessione. Omasnap crea la cartella quando salva il primo scatto. Imposta `[output] autosave = false` in `~/.config/omasnap/omasnap.conf` per disabilitare il salvataggio automatico.

Da terminale, `omarchy screenshot` apre lo stesso overlay, e puoi scegliere la sua modalità iniziale: `omarchy capture screenshot region`, `windows`, `fullscreen` o `scroll`. Un secondo argomento `copy` o `save` salta l'anteprima e manda lo scatto dritto a quella destinazione. Per modificare prima dell'output, usa `omarchy screenshot --editor=overlay` per un editor a schermo intero o `omarchy screenshot --editor=window` per una finestra separata.

### Guidare il selettore da tastiera

Mentre la selezione è aperta, non devi affatto usare il mouse:

| Tasto | Funzione |
| --- | -------- |
| `S` | Attiva/disattiva modalità regione a scorrimento |
| `Super + Arrow keys` | Spostati tra le finestre in modalità Finestra |
| `Return` | Cattura la finestra evidenziata |
| `Ctrl + A` | Cattura l'intero monitor focalizzato |
| `R` | Ripristina l'ultima regione disegnata in questa sessione |
| `Esc` | Chiudi Omasnap |

Queste combinazioni esistono solo mentre Omasnap è aperto, quindi non possono collide con nulla nella tua configurazione.

## Registrazione schermo

`Alt + Print Screen` apre _Azioni > Cattura > Registra schermo_, che chiede cosa vuoi nella colonna sonora: nessun audio, audio desktop, desktop più microfono o desktop più microfono più webcam. Quest'ultima compare solo se hai davvero una fotocamera collegata. Scegline una e il selettore di registrazione di Omarchy ti permette di trascinare una regione o cliccare una finestra o un monitor.

La registrazione gira su gpu-screen-recorder, che codifica sulla GPU a 60 fps e ripiega sulla CPU se deve. Il risultato è un MP4 in `~/Videos`, chiamato `screenrecording-2026-08-13_14-22-05.mp4`. Imposta `OMARCHY_SCREENRECORD_DIR` per cambiarlo — ma nota che a differenza della cartella schermate, questa deve esistere già, altrimenti la registrazione rifiuta di partire.

Mentre registri, un piccolo indicatore compare nella barra. Cliccalo per fermare. Puoi anche fermare con `Alt + Print Screen` di nuovo, o con la voce _Ferma registrazione_ sotto _Azioni > Cattura > Registra schermo_, che compare solo mentre qualcosa sta effettivamente registrando.

Fermare fa un po' di pulizia prima di consegnarti il file: il primo fotogramma viene tagliato, e se c'è audio viene normalizzato a -14 LUFS con lo schiocco di cattura PipeWire proprio all'inizio silenziato. Poi appare una notifica con una miniatura dalla registrazione. Cliccala per riprodurre il file in mpv.

### L'overlay webcam

Quando registri con una webcam, la fotocamera appare come una finestra ritratto fissata e ritagliata nell'angolo in basso a destra di ciò che stai registrando. Se sta sopra qualcosa che ti serve, ridimensionala al volo:

| Scorciatoia | Funzione |
| ------ | -------- |
| `Super + Alt + [` | Rendi più piccolo l'overlay webcam |
| `Super + Alt + ]` | Rendi più grande l'overlay webcam |

Ci sono tre dimensioni — piccola, media e grande — e le scorciatoie fanno un passo tra di esse. Media è la predefinita. Sono proporzionali alla registrazione, quindi la fotocamera occupa la stessa quota dell'inquadratura sia che tu stia registrando un monitor 1080p o uno 6K. E se hai registrato una regione invece di un intero display, l'overlay si ancora all'angolo di quella regione invece che a quello del monitor, così resta dentro lo scatto.

Puoi anche chiamarlo direttamente con `omarchy-capture-webcam-resize small`, o `reset` per tornare a medio.

## Testo, codici QR e colori

`Super + Ctrl + Print Screen` seleziona una regione e ne fa OCR negli appunti. Questo è trattato come si deve in [Estrazione testo e dettatura](11-text-extraction-dictation.md).

_Azioni > Cattura > Codice QR_ fa lo stesso trucco per i codici QR. Seleziona la regione col codice dentro, e il valore decodificato va negli appunti. Cerca solo codici QR — i contenuti schermo densi hanno l'abitudine di dare falsi positivi come codice a barre altrimenti. Vale la pena sapere: il valore decodificato va negli appunti e da nessun'altra parte. Non viene stampato, non è nella notifica, ed è segnato come sensibile così non resta in giro nella [cronologia appunti](08-unified-clipboard-history.md). I codici QR trasportano abitualmente segreti — l'URI `otpauth://` dietro un codice di configurazione 2FA, per esempio — e non vuoi quello in un log. Incollare funziona comunque bene.

`Super + Print Screen` (o _Azioni > Cattura > Colore_) trasforma il cursore in un contagocce. Clicca qualsiasi cosa sullo schermo e il colore finisce negli appunti. Premi di nuovo la scorciatoia per uscire senza scegliere.

## Conversione prima di condividere

Una registrazione schermo 4K o un HEIC grezzo dal telefono è spesso troppo grande da inviare così. `Super + Ctrl + .` (o _Azioni > Converti_) sistema la cosa. Ti offre un selettore file fuzzy su `~/Pictures` e `~/Videos`, poi chiede un formato e una dimensione.

Le immagini vanno in jpg o png ad alta, media o bassa, che limitano la larghezza a 3160, 2160 e 1080 pixel. I video vanno in mp4 o una gif animata a 4k, 1080p o 720p. Il file convertito viene scritto accanto all'originale con la risoluzione nel nome — `demo-1080p.mp4` — e il percorso viene copiato negli appunti come URI file, così puoi incollarlo direttamente in un'app che accetta trascinamenti di file.

Funziona anche da terminale, se sai già cosa vuoi: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. C'è anche `omarchy transcode ascii`, che trasforma un'immagine in arte ASCII — quello serve soprattutto per il [branding](41-branding.md).

## Inviarlo da qualche parte

Una volta che hai il file, `Super + Ctrl + S` apre il menu Condividi e lo invia a un altro dispositivo sulla tua rete tramite LocalSend. Vedi [GUI](22-guis.md) per questo.
