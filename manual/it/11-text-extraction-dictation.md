# Estrazione del testo e dettatura

### Estrazione del testo

Premi `Super + Ctrl + PrtScr` per selezionare un'area sullo schermo per l'estrazione del testo. Il modello OCR open source tesseract convertirà poi rapidamente quella selezione in testo e la inserirà negli appunti. Poi ti basta premere `Super + V` per incollare.

Questo è molto utile per ricavare indirizzi dai piè di pagina delle immagini o numeri di telefono incorporati nei titoli dei siti web.

 ![text-extraction](images/text-extraction.webp)

### Dettatura

Nelle nuove installazioni, [Superwhisper](https://superwhisper.com/) è il backend di dettatura predefinito, con elaborazione cloud senza download di modelli offline. Scegli Superwhisper o [Voxtype](https://voxtype.io/) tramite _Configurazione > Predefiniti > Dettatura_ nel menu di Omarchy. La selezione di un backend lo installa se necessario e lo imposta come predefinito per la dettatura. Voxtype carica un modello inglese di base da 150MB; cambia il modello con `voxtype setup model` e altre impostazioni tramite `~/.config/voxtype/config.toml`. Superwhisper apre le sue impostazioni per scegliere l'elaborazione cloud o locale, e OPR mantiene l'applicazione aggiornata.

Detti tenendo premuto `Right Alt`, oppure attivando e disattivando con `Alt + Space`, e il testo dettato apparirà nell'area di input attiva. Queste scorciatoie usano il backend selezionato. Right Alt avvia la dettatura anche quando viene usato in una combinazione con modificatori; usa Left Alt per quelle combinazioni. Sulle disposizioni di tastiera in cui Right Alt è AltGr, usa `Alt + Space` per mantenere AltGr disponibile per la digitazione. Le installazioni precedenti a quando Alt + Space è diventato l'impostazione predefinita mantengono `F9` per il push-to-talk e `Super + Ctrl + X` per attivare e disattivare, aggiunti a `~/.config/hypr/bindings.lua`; rimuovili da lì per restituire quei tasti alle applicazioni.

Le stesse scorciatoie funzionano con entrambi i backend. Seleziona il tuo backend tramite Configurazione > Predefiniti > Dettatura. Il programma di installazione del backend lo configura e salva la selezione. Esegui `omarchy default dictation` per vedere quale è selezionato. La selezione viene salvata in `~/.config/omarchy/defaults/dictation`. Le nuove installazioni selezionano Superwhisper automaticamente.

Omarchy carica automaticamente l'integrazione desktop del backend selezionato. Non è necessaria alcuna configurazione di Superwhisper in `~/.config/hypr/`.

Associazioni personalizzate e script possono usare `omarchy dictation start`, `omarchy dictation stop` e `omarchy dictation toggle`. Il backend selezionato gestisce la registrazione e la trascrizione. La selezione di Superwhisper disabilita la sua scorciatoia nativa di mantenimento e imposta la sua attivazione e disattivazione nativa su `Ctrl + Alt + Space`, mantenendola separata dai tasti di registrazione di Omarchy. Superwhisper richiede almeno una scorciatoia di registrazione nativa, e la sua scorciatoia di annullamento resta disponibile.

I backend aggiuntivi possono integrarsi senza modificare Omarchy. Fornisci un eseguibile denominato `omarchy-dictation-<backend>` sul PATH che accetti `start`, `stop` e `toggle` e restituisca prontamente il controllo, con uno stato diverso da zero in caso di errore. Il suo programma di installazione configura il provider e chiama `omarchy-dictation-use <backend>` dopo una configurazione riuscita. Questo arresta il backend precedente e salva la selezione in modo atomico; `stop` deve riuscire quando il provider è inattivo o non disponibile. I nomi dei backend usano lettere minuscole, cifre e trattini. Fornisci `omarchy-install-dictation-<backend>` per la configurazione; `omarchy default dictation <backend>` lo avvia. Aggiungi una voce al menu Predefiniti tramite un'estensione del menu di Omarchy per richiamare quel selettore. L'integrazione desktop facoltativa può risiedere in `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
