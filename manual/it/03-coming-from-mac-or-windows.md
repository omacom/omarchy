# Provenire da Mac o Windows

Se hai passato anni su macOS o Windows, le tue dita sanno cento cose che il tuo cervello ha dimenticato di aver mai imparato. Questo capitolo è lo strato di traduzione: dove vanno a finire quegli automatismi in Omarchy. Le funzionalità in sé sono trattate in dettaglio altrove — questa è solo la mappa.

### Super è il centro di tutto

Tutta la memoria muscolare che hai costruito intorno a Cmd o al tasto Windows si trasferisce su un unico tasto: Super. È il tasto Windows su una tastiera PC, ed è l'ancora di quasi ogni scorciatoia in Omarchy.

Il tuo riflesso per Spotlight o Raycast o il menu Start diventa `Super + Space`. Apre il menu di Omarchy, che avvia app, cambia impostazioni, installa software, cattura lo schermo — praticamente tutto. Inizia a digitare per filtrare. `Super + Alt + Space` mostra ogni app in un'unica griglia, come fa Launchpad. Vedi [navigazione](04-navigation.md).

### Non ci sono né dock né icone sul desktop

Niente da cliccare per avviare le cose, nessuna icona da sistemare sul desktop. Le app si avviano con una scorciatoia (`Super + Return` per il terminale, `Super + Shift + Return` per il browser e `Super + K` per un elenco di tutto ciò che è mappato) o dal menu. L'unico elemento persistente dell'interfaccia è [la barra superiore](05-the-top-bar.md), che copre ciò che prima facevano per te la barra dei menu, la barra di sistema e il Centro notifiche — e quasi ogni widget su di essa fa qualcosa con il clic sinistro, destro e centrale.

### Le finestre si posizionano da sole

Il più grande cambio di mentalità: non trascini le finestre in giro né le agganci alle metà dello schermo. Apri una finestra e occupa tutto lo schermo. Ne apri una seconda e se lo dividono. Non devi mai pescare una finestra da sotto un'altra, perché le finestre non si sovrappongono.

Quando ti serve davvero una finestra fluttuante, `Super + T` toglie la finestra attiva dal tiling (e ce la rimette). Ma prima dai al tiling una vera possibilità — è il cuore di tutto. [La navigazione](04-navigation.md) ti guida passo passo.

Gli spazi di lavoro ti sembreranno familiari: sono gli Spazi di macOS o i desktop virtuali di Windows, solo che li userai davvero, perché `Super + 1/2/3/4` salta dritto a uno di essi e `Super + Shift + 1/2/3/4` vi manda la finestra attiva. Nessun ritardo di animazione, solo salti istantanei. Questo significa che potresti non aver nemmeno bisogno di più monitor, se prima eri abituato a usarli.

### Copia e incolla funzionano e basta

Sul Mac avevi Cmd + C ovunque. Su Windows avevi Ctrl + C ovunque — tranne nel terminale, dove uccide il programma. Omarchy ti dà `Super + C`, `Super + X` e `Super + V`, e funzionano ovunque, incluso il terminale. Nessun riflesso separato da imparare per la shell.

Utenti Windows: la vostra cronologia degli appunti di Win + V vive su `Super + Ctrl + V`, e conserva immagini oltre al testo. Vedi [appunti unificati e cronologia](08-unified-clipboard-history.md).

### La tabella di traduzione

| Cerchi | In Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / menu Start | `Super + Space` — il menu di Omarchy |
| AirDrop | LocalSend, tramite `Super + Ctrl + S` — vedi [GUI](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` o `Print Screen` — vedi [screenshot e registrazione](12-screenshots-recording.md) |
| Centro notifiche | Cronologia delle notifiche su `Super + Shift + Alt + ,` |
| Time Machine (per il sistema) | [Snapshot di sistema](47-system-snapshots.md) automatici a ogni aggiornamento |
| App Store / scaricare un programma di installazione | _Installa_ nel menu, o `omarchy pkg add` — vedi [altri pacchetti](29-other-packages.md) |
| Impostazioni di Sistema / Pannello di controllo | _Configurazione_ nel menu, che modifica semplici file di configurazione — vedi [dotfiles](31-dotfiles.md) |

### Alcune cose sono davvero diverse

Molte impostazioni vivono in file di testo che modifichi, non in pannelli in cui clicchi a vuoto. Sembra primitivo, finché non capisci che significa che ogni modifica può essere vista, copiata sulla tua prossima macchina e messa sotto controllo di versione. Il menu _Configurazione_ ti porta dritto al file giusto e riavvia ciò che va riavviato quando hai finito.

Gli aggiornamenti arrivano tramite un unico comando — _Aggiorna > Omarchy_ — che aggiorna Omarchy stesso e ogni pacchetto sul sistema, creando prima uno snapshot. Nessun aggiornatore per singola app che ti tormenta in momenti a caso. Vedi [aggiornamenti](30-updates.md).

Il software arriva da un gestore di pacchetti, non da programmi di installazione scaricati.

E quando chiudi una finestra, l'app si chiude davvero. Non esiste il limbo di macOS in cui il programma continua a girare senza finestre. `Super + W` — o `Super + Q`, se è quella la memoria delle dita con cui sei arrivato — significa sparita.

### Su hardware Mac

Omarchy gira bene sui Mac Intel — vedi [supporto Mac](44-mac-support.md). E la tastiera è gentile con te: Omarchy non rimappa nulla, e Linux tratta il tasto Command come Super, quindi Super si trova proprio dove Cmd è sempre stato. Il tuo pollice non si accorgerà del passaggio.

### Dagli due settimane

Gli automatismi si trasferiscono più in fretta di quanto pensi. Dai una scorsa al capitolo sulle [scorciatoie](07-hotkeys.md) una volta, e ogni volta che ti sfugge un'associazione, premi `Super + K` — te le mostra tutte. È l'unica scorciatoia che devi davvero memorizzare.
