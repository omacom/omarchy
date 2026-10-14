# Estrazione testo e dettatura

### Estrazione testo

Premi `Super + Ctrl + PrtScr` per selezionare una regione sullo schermo per l'estrazione del testo. Il modello OCR open source tesseract convertirà poi rapidamente quella selezione in testo e la metterà negli appunti. Poi premi semplicemente `Super + V` per incollare.

È molto utile per afferrare indirizzi dai piè di pagina delle immagini o numeri di telefono incorporati nei titoli dei siti web.

 ![text-extraction](images/text-extraction.webp)

### Dettatura

Sulle installazioni nuove, [Superwhisper](https://superwhisper.com/) è il backend di dettatura predefinito, con elaborazione cloud senza download di modelli offline. Scegli Superwhisper o [Voxtype](https://voxtype.io/) tramite _Impostazioni > Predefiniti > Dettatura_ nel menu Omarchy. Selezionare un backend lo installa se necessario e lo rende predefinito per la dettatura. Voxtype carica un modello inglese di base che occupa 150 MB; cambia il modello con `voxtype setup model` e altre impostazioni tramite `~/.config/voxtype/config.toml`. Superwhisper apre le sue impostazioni per scegliere elaborazione cloud o locale, e OPR mantiene aggiornata l'applicazione.

Detti tenendo premuto `Right Alt` o `F9`, oppure attivando/disattivando con `Super + Ctrl + X`, e il testo dettato apparirà nell'area di input focalizzata. Queste scorciatoie usano il backend selezionato. Right Alt avvia anche la dettatura quando è usato in una combinazione con modificatore; usa Left Alt per quelle combinazioni. Sui layout tastiera dove Right Alt è AltGr, usa `F9` per mantenere AltGr disponibile per digitare.

Le stesse scorciatoie funzionano con entrambi i backend. Seleziona il backend tramite Impostazioni > Predefiniti > Dettatura. L'installatore del backend lo configura e salva la selezione. Esegui `omarchy default dictation` per vedere quale è selezionato. La selezione è salvata in `~/.config/omarchy/defaults/dictation`. Le installazioni nuove selezionano automaticamente Superwhisper.

Omarchy carica automaticamente l'integrazione desktop del backend selezionato. Nessuna configurazione Superwhisper è necessaria in `~/.config/hypr/`.

Combinazioni e script personalizzati possono usare `omarchy dictation start`, `omarchy dictation stop` e `omarchy dictation toggle`. Il backend selezionato gestisce la registrazione e la trascrizione. Selezionare Superwhisper disabilita la sua scorciatoia nativa a pressione prolungata e imposta il suo attiva/disattiva nativo su `Alt + Space`, mantenendolo separato dai tasti di registrazione di Omarchy. Superwhisper richiede almeno una scorciatoia di registrazione nativa, e la sua scorciatoia di annullamento resta disponibile.

Backend aggiuntivi possono integrarsi senza modificare Omarchy. Fornisci un eseguibile chiamato `omarchy-dictation-<backend>` sul PATH che accetti `start`, `stop` e `toggle` e ritorni prontamente, con uno stato diverso da zero in caso di errore. Il suo installatore configura il provider e chiama `omarchy-dictation-use <backend>` dopo una configurazione riuscita. Questo ferma il backend precedente e salva la selezione in modo atomico; `stop` deve riuscire quando il provider è inattivo o non disponibile. I nomi backend usano lettere minuscole, cifre e trattini. Fornisci `omarchy-install-dictation-<backend>` per la configurazione; `omarchy default dictation <backend>` lo avvia. Aggiungi una voce al menu Predefiniti tramite un'estensione del menu Omarchy per chiamare quel selettore. L'integrazione desktop opzionale può vivere in `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
