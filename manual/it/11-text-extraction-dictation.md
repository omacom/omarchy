# Estrazione del testo e dettatura

### Estrazione del testo

Premi `Super + Ctrl + PrtScr` per selezionare una regione sullo schermo per l'estrazione del testo. Il modello OCR open source tesseract convertirà quindi rapidamente quella selezione in testo e la inserirà negli appunti. Poi premi semplicemente `Super + V` per incollare.

Questo è molto utile per catturare indirizzi dai piè di pagina delle immagini o numeri di telefono incorporati nei titoli dei siti web.

 ![text-extraction](images/text-extraction.webp)

### Dettatura

Nelle installazioni nuove, [Superwhisper](https://superwhisper.com/) è il backend di dettatura predefinito, con elaborazione cloud senza download offline di modelli. Scegli Superwhisper, [Voxtype](https://voxtype.io/) o [Hex](https://anoma.ly/hex/) tramite _Setup > Defaults > Dictation_ nel menu di Omarchy. La selezione di un backend lo installa se necessario e lo rende predefinito per la dettatura. Voxtype carica un modello inglese di base che occupa 150MB; cambia il modello con `voxtype setup model` e le altre impostazioni tramite `~/.config/voxtype/config.toml`. Superwhisper apre le sue impostazioni per scegliere l'elaborazione cloud o locale, e OPR mantiene aggiornata l'applicazione. Hex scarica il suo modello vocale sul dispositivo durante la configurazione e viene eseguito come servizio utente `hex.service`; apri la sua finestra dall'icona nella barra di sistema o eseguendo `hex` per cambiare il modello e le altre impostazioni.

Detti tenendo premuto `Right Alt`, oppure attivando e disattivando con `Alt + Space`, e il testo dettato apparirà nell'area di input attiva. Queste scorciatoie usano il backend selezionato. Right Alt avvia la dettatura anche quando viene usato in una combinazione con un modificatore; usa Left Alt per quelle combinazioni. Nei layout di tastiera in cui Right Alt è AltGr, anche quando passi a un layout di questo tipo, tienilo premuto da solo per un momento per dettare; AltGr premuto insieme a un altro tasto continua a digitare il suo carattere. Le installazioni precedenti a quando Alt + Space è diventato l'impostazione predefinita mantengono `F9` per il push-to-talk e `Super + Ctrl + X` per attivare e disattivare, aggiunti a `~/.config/hypr/bindings.lua`, dove quel `Super + Ctrl + X` prende il posto del pannello degli agenti; rimuovili lì per restituire quei tasti alle applicazioni e al pannello.

Le stesse scorciatoie funzionano con ogni backend. Seleziona il tuo backend tramite Setup > Defaults > Dictation. Il programma di installazione del backend lo configura e salva la selezione. Esegui `omarchy default dictation` per vedere quale è selezionato. La selezione viene salvata in `~/.config/omarchy/defaults/dictation`. Le installazioni nuove selezionano Superwhisper automaticamente.

Omarchy carica automaticamente l'integrazione desktop del backend selezionato. Non è necessaria alcuna configurazione di Superwhisper in `~/.config/hypr/`.

Le associazioni personalizzate e gli script possono usare `omarchy dictation start`, `omarchy dictation stop` e `omarchy dictation toggle`. Il backend selezionato gestisce la registrazione e la trascrizione. La selezione di Superwhisper disabilita la sua scorciatoia nativa a pressione prolungata e imposta la sua attivazione e disattivazione nativa su `Ctrl + Alt + Space`, mantenendola separata dai tasti di registrazione di Omarchy. Superwhisper richiede almeno una scorciatoia di registrazione nativa, e la sua scorciatoia di annullamento resta disponibile.

Backend aggiuntivi possono integrarsi senza modificare Omarchy. Fornisci un eseguibile chiamato `omarchy-dictation-<backend>` su PATH che accetti `start`, `stop` e `toggle` e termini rapidamente, con uno stato diverso da zero in caso di errore. Il suo programma di installazione configura il provider e chiama `omarchy-dictation-use <backend>` dopo una configurazione riuscita. Questo arresta il backend precedente e salva la selezione in modo atomico; `stop` deve riuscire quando il provider è inattivo o non disponibile. I nomi dei backend usano lettere minuscole, cifre e trattini. Fornisci `omarchy-install-dictation-<backend>` per la configurazione; `omarchy default dictation <backend>` lo avvia. Aggiungi una voce al menu Defaults tramite un'estensione del menu di Omarchy per chiamare quel selettore. L'integrazione desktop opzionale può risiedere in `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
