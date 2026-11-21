# Se arrivi da Mac o Windows

Se hai passato anni su macOS o Windows, le tue dita sanno cento cose che il tuo cervello ha dimenticato di aver mai imparato. Questo capitolo è lo strato di traduzione: dove finiscono quegli istinti in Omarchy. Le funzionalità in sé sono trattate in dettaglio altrove — questa è solo la mappa.

### Super è il centro di tutto

Tutta la memoria muscolare che hai costruito intorno a Cmd o al tasto Windows si trasferisce su un unico tasto: Super. È il tasto Windows su una tastiera PC, ed è l'ancora di quasi tutte le scorciatoie in Omarchy.

Il tuo riflesso Spotlight o Raycast o menu Start diventa `Super + Space`. Apre il menu di Omarchy, che avvia app, cambia impostazioni, installa software, cattura lo schermo — praticamente tutto. Inizia a digitare per filtrare. `Super + Alt + Space` mostra tutte le app su un'unica griglia, come fa Launchpad. Vedi [navigazione](04-navigation.md).

### Niente icone sul desktop, e il dock appare solo quando sei in modalità flottante

Niente icone da sistemare sul desktop, e niente dock su un workspace in tiling — il dock appare solo su un workspace flottante (vedi [navigazione](04-navigation.md)). Le app si avviano con una scorciatoia (`Super + Return` per il terminale, `Super + Shift + Return` per il browser e `Super + K` per un elenco di tutto ciò che è mappato) o dal menu. L'unico elemento persistente dell'interfaccia è [la barra superiore](05-the-top-bar.md), che copre ciò che prima facevano per te la barra dei menu, la system tray e il Notification Center — e quasi ogni widget su di essa fa qualcosa con clic sinistro, destro e centrale.

### Le finestre si posizionano da sole

Il cambio di mentalità più grande: non trascini le finestre in giro né le agganci a metà schermo. Apri una finestra e occupa tutto lo schermo. Ne apri una seconda e si dividono lo schermo. Non devi mai pescare una finestra da sotto un'altra, perché le finestre non si sovrappongono.

Quando ti serve davvero una finestra flottante, `Super + T` estrae quella attiva dal tiling (e ce la reinserisce). Ma prima dai al tiling una vera possibilità — è il cuore di tutto. [Navigazione](04-navigation.md) ti guida passo passo.

Gli workspace ti sembreranno familiari: sono gli Spaces di macOS o i desktop virtuali di Windows, solo che li userai davvero, perché `Super + 1/2/3/4` salta direttamente a uno e `Super + Shift + 1/2/3/4` sposta lì la finestra attiva. Nessun ritardo da animazione, solo salti istantanei. Questo significa che potresti non aver nemmeno bisogno di più monitor, se prima eri abituato a usarli.

### Copia e incolla funzionano e basta

Sul Mac avevi Cmd + C ovunque. Su Windows avevi Ctrl + C ovunque — tranne nel terminale, dove uccide il programma. Omarchy ti dà `Super + C`, `Super + X` e `Super + V`, e funzionano ovunque, terminale incluso. Nessun riflesso separato da imparare per la shell.

Utenti Windows: la vostra cronologia degli appunti di Win + V vive su `Super + Ctrl + V`, e conserva anche le immagini oltre al testo. Vedi [appunti unificati e cronologia](08-unified-clipboard-history.md).

### La tabella di traduzione

| Quello che cercavi | In Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / menu Start | `Super + Space` — il menu di Omarchy |
| AirDrop | LocalSend, tramite `Super + Ctrl + S` — vedi [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` o `Print Screen` — vedi [screenshot e registrazione](12-screenshots-recording.md) |
| Notification Center | Cronologia delle notifiche su `Super + Shift + Alt + ,` |
| Time Machine (per il sistema) | [Snapshot di sistema](47-system-snapshots.md) automatici a ogni aggiornamento |
| App Store / scaricare un installer | _Install_ nel menu, oppure `omarchy pkg add` — vedi [altri pacchetti](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ nel menu, che modifica semplici file di configurazione — vedi [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, su `Super + Shift + F` — vedi [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome su `Super + Shift + Return`; scegline un altro in _Setup > Defaults > Browser_ — vedi [browser](23-browsers.md) |
| Preview / Photos | Omaview per immagini, video e musica, Document Viewer per i PDF — vedi [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, su `Super + Shift + N`; scegline un altro in _Setup > Defaults > Editor_ |

### Alcune cose sono davvero diverse

Molte impostazioni vivono in file di testo che modifichi, non in pannelli in cui fai clic. Sembra primitivo finché non capisci che significa che ogni modifica può essere vista, copiata sulla tua prossima macchina e messa sotto controllo di versione. Il menu _Setup_ ti porta dritto al file giusto e riavvia ciò che va riavviato quando hai finito.

Gli aggiornamenti arrivano con un unico comando — _Update > Omarchy_ — che aggiorna Omarchy stesso e ogni pacchetto sul sistema, creando prima uno snapshot. Nessun updater per singola app che ti tormenta a caso. Vedi [aggiornamenti](30-updates.md).

Il software arriva da un package manager, non da installer scaricati.

E quando chiudi una finestra, l'app si chiude davvero. Non c'è il limbo di macOS in cui il programma continua a girare senza finestre. `Super + W` — oppure `Super + Q`, se è quella la memoria nelle tue dita con cui sei arrivato — significa sparita.

### Su hardware Mac

Omarchy gira bene sui Mac Intel — vedi [supporto Mac](44-mac-support.md). E la tastiera ti è amica: Omarchy non rimappa nulla, e Linux tratta il tasto Command come Super, quindi Super si trova proprio dove Cmd è sempre stato. Il tuo pollice non si accorgerà del passaggio.

### Dagli due settimane

Gli istinti si trasferiscono più in fretta di quanto pensi. Dai una scorsa una volta al capitolo sulle [scorciatoie](07-hotkeys.md), e ogni volta che ti sfugge una combinazione, premi `Super + K` — te le mostra tutte. È l'unica scorciatoia che devi davvero memorizzare.
