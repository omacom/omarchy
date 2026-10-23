# Arrivare da Mac o Windows

Se hai passato anni su macOS o Windows, le tue dita sanno un centinaio di cose che il cervello ha dimenticato di aver mai imparato. Questo capitolo è lo strato di traduzione: dove vanno quegli istinti in Omarchy. Le funzioni vere e proprie sono trattate in profondità altrove — questa è solo la mappa.

### Super è il centro di tutto

Tutta la memoria muscolare che hai costruito attorno a Cmd o al tasto Windows si trasferisce su un solo tasto: Super. È il tasto Windows su una tastiera PC, ed è l'ancora di quasi ogni scorciatoia in Omarchy.

Il tuo riflesso Spotlight o Raycast o menu Start diventa `Super + Space`. Si apre il menu Omarchy, che avvia app, cambia impostazioni, installa software, cattura lo schermo — praticamente tutto. Inizia a digitare per filtrare. `Super + Alt + Space` mostra ogni app su una griglia, come fa Launchpad. Vedi [navigazione](04-navigation.md).

### Non c'è dock e non ci sono icone sul desktop

Nulla da cliccare per avviare le cose, nessuna icona da disporre sul desktop. Le app partono da una scorciatoia (`Super + Return` per il terminale, `Super + Shift + Return` per il browser e `Super + K` per un elenco di tutto ciò che è mappato) o dal menu. L'unico elemento persistente dell'interfaccia è [la barra superiore](05-the-top-bar.md), che copre ciò che prima facevano per te la barra dei menu, l'area di notifica e il Centro Notifiche — e quasi ogni widget su di essa fa qualcosa con clic sinistro, destro e centrale.

### Le finestre si posizionano da sole

Il più grande cambio di mentalità: non trascini le finestre in giro né le agganci a metà schermo. Apri una finestra e occupa l'intero schermo. Ne apri una seconda e se lo dividono. Non peschi mai una finestra da sotto un'altra, perché le finestre non si sovrappongono.

Quando ti serve davvero una finestra flottante, `Super + T` tira fuori quella attiva dall'affiancamento (e la rimette dentro). Ma prima dai all'affiancamento una vera possibilità — è il cuore di tutto. [Navigazione](04-navigation.md) ti guida passo passo.

I workspace ti sembreranno familiari: sono gli Spazi di macOS o i desktop virtuali di Windows, solo che li userai davvero, perché `Super + 1/2/3/4` salta dritto su uno e `Super + Shift + 1/2/3/4` ci manda la finestra attiva. Nessun ritardo di animazione, solo salti istantanei. Questo significa che potresti non aver nemmeno bisogno di più monitor, se prima eri abituato così.

### Copia e incolla funzionano e basta

Sul Mac avevi Cmd + C ovunque. Su Windows avevi Ctrl + C ovunque — tranne nel terminale, dove uccide il programma. Omarchy ti dà `Super + C`, `Super + X` e `Super + V`, e funzionano ovunque, terminale incluso. Nessun riflesso separato da imparare per la shell.

Utenti Windows: la vostra cronologia appunti Win + V vive su `Super + Ctrl + V`, e contiene immagini oltre che testo. Vedi [appunti unificati e cronologia](08-unified-clipboard-history.md).

### La tabella di traduzione

| Cerchi | In Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / menu Start | `Super + Space` — il menu Omarchy |
| AirDrop | LocalSend, tramite `Super + Ctrl + S` — vedi [GUI](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Print Screen` — vedi [schermate e registrazione](12-screenshots-recording.md) |
| Centro Notifiche | Cronologia notifiche su `Super + Shift + Alt + ,` |
| Time Machine (per il sistema) | [Snapshot di sistema](47-system-snapshots.md) automatici a ogni aggiornamento |
| App Store / scaricare un installatore | _Installa_ nel menu, oppure `omarchy pkg add` — vedi [altri pacchetti](29-other-packages.md) |
| Impostazioni di Sistema / Pannello di controllo | _Impostazioni_ nel menu, che modifica semplici file di configurazione — vedi [dotfiles](31-dotfiles.md) |

### Alcune cose sono davvero diverse

Molte impostazioni vivono in file di testo che modifichi, non in pannelli da cliccare. Sembra primitivo finché non capisci che significa che ogni modifica può essere vista, copiata sulla prossima macchina e messa sotto controllo di versione. Il menu _Impostazioni_ ti butta dritto nel file giusto e riavvia ciò che va riavviato quando hai finito.

Gli aggiornamenti arrivano con un solo comando — _Aggiorna > Omarchy_ — che aggiorna Omarchy stessa e ogni pacchetto del sistema, facendo prima uno snapshot. Nessun aggiornatore per-app che ti assilla a caso. Vedi [aggiornamenti](30-updates.md).

Il software viene da un gestore di pacchetti, non da installatori scaricati.

E quando chiudi una finestra, l'app si chiude davvero. Non c'è il limbo di macOS dove il programma continua a girare senza finestre. `Super + W` — o `Super + Q`, se è quella la memoria delle dita con cui sei arrivato — significa sparito.

### Su hardware Mac

Omarchy gira bene sui Mac Intel — vedi [supporto Mac](44-mac-support.md). E la tastiera è gentile con te: Omarchy non rimappa nulla, e Linux tratta il tasto Command come Super, quindi Super sta proprio dove Cmd è sempre stato. Il tuo pollice non si accorgerà del trasloco.

### Dagliela due settimane

Gli istinti si trasferiscono più in fretta di quanto pensi. Scorri una volta il capitolo sulle [scorciatoie](07-hotkeys.md), e ogni volta che hai un vuoto su una combinazione, premi `Super + K` — te le mostra tutte. È l'unica scorciatoia che devi davvero memorizzare.
