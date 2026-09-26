<!-- upstream: omacom/omarchy@60663faf8764253646f1d6166e864b608d4a0fa1; sha256: bf6bcded2d6cae7d9333f0de57cce2ff40aaa98a6c4d6cfc8b4e580f64fc48b1 -->

# Arrivi da Mac o Windows

Se hai passato anni su macOS o Windows, le tue dita conoscono cento cose che il tuo cervello ha dimenticato di aver mai imparato. Questo capitolo è una sorta di traduzione: dove finiscono quegli istinti in Omarchy. Le funzionalità in sé sono trattate in dettaglio altrove — questa è solo la mappa.

### Super è il centro di tutto

Tutta la memoria muscolare che hai costruito attorno a Cmd o al tasto Windows si trasferisce su un unico tasto: Super. È il tasto Windows su una tastiera per PC, ed è l'ancora di quasi ogni scorciatoia in Omarchy.

Il tuo riflesso da Spotlight, Raycast o menu Start diventa `Super + Space`. Apre il menu di Omarchy, che avvia applicazioni, cambia impostazioni, installa software, cattura lo schermo — praticamente tutto. Inizia a digitare per filtrare. C'è anche un menu dedicato alle sole applicazioni su `Super + Alt + Space`. Vedi [navigazione](04-navigation.md).

### Non ci sono dock né icone sul desktop

Niente da cliccare per avviare le cose, nessuna icona da sistemare sul desktop. Le applicazioni si avviano da una scorciatoia (`Super + Return` per il terminale, `Super + Shift + Return` per il browser e `Super + K` per un elenco di tutto ciò che è mappato) oppure dal menu. L'unico elemento persistente dell'interfaccia è [la barra superiore](05-the-top-bar.md), che fa tutto ciò che prima facevano per te la barra dei menu, l'area di notifica e il Centro notifiche — e quasi ogni widget su di essa fa qualcosa con il clic sinistro, destro e centrale.

### Le finestre si dispongono da sole

Il cambiamento mentale più grande: non trascini le finestre né le agganci a metà schermo. Apri una finestra e occupa tutto lo schermo. Ne apri una seconda e dividono lo schermo. Non peschi mai una finestra da sotto un'altra, perché le finestre non si sovrappongono.

Quando ti serve davvero una finestra flottante, `Super + T` estrae quella attiva dai riquadri (e ce la rimette). Ma prima dai davvero una possibilità ai riquadri: è il cuore di tutto. La [navigazione](04-navigation.md) ti guida attraverso di essa.

I workspace ti sembreranno familiari: sono gli Space di macOS o i desktop virtuali di Windows, solo che li userai davvero, perché `Super + 1/2/3/4` salta direttamente a uno e `Super + Shift + 1/2/3/4` ci manda la finestra attiva. Nessun ritardo di animazione, solo salti istantanei. Questo significa che potresti non aver nemmeno bisogno di più monitor, se eri abituato ad averli.

### Copia e incolla funzionano e basta

Sul Mac avevi Cmd + C ovunque. Su Windows avevi Ctrl + C ovunque — tranne nel terminale, dove incasina il tuo programma. Omarchy ti dà `Super + C`, `Super + X` e `Super + V`, e funzionano ovunque, terminale incluso. Nessun riflesso separato da imparare per la shell.

Per chi viene da Windows: la cronologia degli appunti di Win + V è richiamabile con `Super + Ctrl + V` e funziona anche con le immagini, oltre al testo. Vedi [appunti unificati e cronologia](08-unified-clipboard-history.md).

### La tabella di traduzione

| Cerchi | In Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / menu Start | `Super + Space` — il menu di Omarchy |
| AirDrop | LocalSend, tramite `Super + Ctrl + S` — vedi [GUI](../22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Print Screen` — vedi [screenshot e registrazione](../12-screenshots-recording.md) |
| Centro notifiche | Cronologia delle notifiche su `Super + Shift + Alt + ,` |
| Time Machine (per il sistema) | [Snapshot di sistema](../47-system-snapshots.md) automatici a ogni aggiornamento |
| App Store / scaricare un installer | _Install_ nel menu, oppure `omarchy pkg add` — vedi [altri pacchetti](../29-other-packages.md) |
| Impostazioni di sistema / Pannello di controllo | _Setup_ nel menu, che modifica semplici file di configurazione — vedi [dotfiles](../31-dotfiles.md) |

### Alcune cose sono davvero diverse

Molte impostazioni si trovano in file di testo da modificare, non in pannelli su cui clicchi. Sembra primitivo, finché non capisci che significa che ogni modifica può essere vista, copiata sulla tua prossima macchina e messa sotto controllo di versione. Il menu _Setup_ ti porta dritto al file giusto e riavvia ciò che serve al termine.

Gli aggiornamenti arrivano con un unico comando — _Update > Omarchy_ — che aggiorna Omarchy stesso e ogni pacchetto del sistema, dopo aver creato uno snapshot. Nessun update per singola app che ti assilla a caso. Vedi [aggiornamenti](../30-updates.md).

Il software arriva da un gestore di pacchetti, non da installer scaricati.

E quando chiudi una finestra, l'applicazione esce davvero. Non esiste il limbo di macOS in cui il programma continua a girare senza finestre. `Super + W` — o `Super + Q`, se è la memoria delle dita con cui sei arrivato — significa chiusa per davvero.

### Su hardware Mac

Omarchy gira bene sui Mac Intel — vedi [supporto Mac](../44-mac-support.md). E la tastiera ti è amica: Omarchy non rimappa nulla, e Linux tratta il tasto Command come Super, quindi Super sta proprio dove è sempre stato Cmd. Il tuo pollice non si accorgerà di nulla.

### Dagli due settimane

Gli istinti si trasferiscono più in fretta di quanto pensi. Dai una scorsa una volta al capitolo delle [scorciatoie](07-hotkeys.md) e, ogni volta che te ne dimentichi una, premi `Super + K` — te li mostra tutti. È l'unica scorciatoia che devi davvero memorizzare.
