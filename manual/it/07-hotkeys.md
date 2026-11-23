# Scorciatoie da tastiera

Puoi vedere tutte le principali associazioni di tasti con `Super + K` (associazioni Tmux con `Super + Alt + K` e associazioni Herdr con `Super + Ctrl + K`).

## Come sono organizzate le scorciatoie

Ogni scorciatoia si trova su un piano, definito dai suoi modificatori, e ogni piano ha un solo compito. È questo che impedisce alle scorciatoie di confondersi tra loro, e significa che di solito puoi indovinare dove si trova qualcosa.

| Piano | Cosa contiene | Esempi |
| --- | --- | --- |
| `Super + key` | Il sistema: finestre, workspace, layout e menu principali | `Super + Space` menu Omarchy, `Super + W` chiudi finestra, `Super + F` schermo intero |
| `Super + Shift + key` | App | `Super + Shift + B` browser, `Super + Shift + E` email, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Pannelli e menu di sistema | `Super + Ctrl + A` audio, `Super + Ctrl + N` rete, `Super + Ctrl + C` menu di cattura |
| `Super + Ctrl + Alt + key` | Azioni rapide e avvisi | `Super + Ctrl + Alt + T` mostra ora, `Super + Ctrl + Alt + B` batteria, `Super + Ctrl + Alt + C` screenshot |

Aggiungere `Alt` a una scorciatoia ti dà una variante della stessa cosa, mai qualcosa di estraneo:

- `Super + Shift + B` apre il browser; `Super + Shift + Alt + B` apre una finestra privata
- `Super + Shift + E` apre l'email; `Super + Shift + Alt + E` ne inizia una nuova
- `Super + F` va a schermo intero; `Super + Alt + F` va a larghezza intera
- `Super + Ctrl + C` apre il menu di cattura; `Super + Ctrl + Alt + C` salta il menu e cattura uno screenshot

Quando aggiungi una scorciatoia:

1. Scegli il piano in base a cosa fa, poi scegli il tasto.
2. Non spostare una scorciatoia esistente per fare spazio. Trova un tasto libero sul piano giusto.
3. Usa `Alt` solo per una variante della scorciatoia senza di esso.

Alcune scorciatoie infrangono queste regole perché sono comode. `Shift` con una freccia o `Tab` sposta o inverte invece di aprire un'app, e `Print`, i tasti multimediali, `Alt + Tab` e `Ctrl + Alt + Del` funzionano come ovunque. Sono eccezioni, non modelli da copiare.

Se un'impostazione predefinita non ti va bene (diciamo che vuoi `Super + Shift + S` per gli screenshot come su Windows), riassegnala in `~/.config/hypr/bindings.lua`.

## Navigazione

| Scorciatoia | Funzione |
| ----------------------- | --------------------- |
| `Super + Space` | Menu Omarchy (app e tutto il resto) |
| `Super + Alt + Space` | Griglia delle app |
| `Super + Escape` | Menu di sistema (sospendi, riavvia, ecc.) |
| `Super + Ctrl + L` | Blocca computer |
| `Super + W` o `Super + Q` | Chiudi finestra |
| `Ctrl + Alt + Del` | Chiudi tutte le finestre |
| `Super + K` | Mostra tutte le scorciatoie |
| `Super + Alt + K` | Mostra le scorciatoie di tmux |
| `Super + Ctrl + K` | Mostra le scorciatoie di herdr |
| `Super + M` | Riduci a icona la finestra nel dock |
| `Super + T` | Alterna la finestra tra tiling/floating |
| `Super + J` | Alterna la posizione della finestra (orizzontale/verticale) |
| `Super + O` | Attiva/disattiva la finestra a comparsa in sticky'n'floating |
| `Super + L` | Scorri tra i layout dwindle, scrolling e floating |
| `Super + Alt + L` | Scorri tra i layout in ordine inverso |
| `Super + P` | Attiva/disattiva lo stile finestra pseudo (naturale vs estesa) |
| `Super + F` | Vai a schermo intero |
| `Super + Alt + F` | Vai a larghezza intera |
| `Super + Ctrl + F` | Vai a schermo intero dentro la finestra |
| `Super + 1…9/0` | Vai al workspace specifico (0 è 10) sul monitor attivo |
| `Super + Tab` | Vai al workspace successivo sul monitor attivo |
| `Super + Shift + Tab` | Vai al workspace precedente sul monitor attivo |
| `Super + Ctrl + Tab` | Vai al workspace usato in precedenza sul monitor attivo |
| `Super + Shift + 1…9/0` | Sposta la finestra sul workspace sul monitor attivo |
| `Super + Shift + Alt + 1…9/0` | Sposta la finestra sul workspace sul monitor attivo senza seguirla |
| `Super + S` | Attiva/disattiva lo scratchpad completo |
| `Super + Alt + S` | Sposta la finestra nello scratchpad completo |
| `Super + the key above Tab` (grave on US layouts) | Attiva/disattiva la console Quake |
| `Super + Shift + the key above Tab` (grave on US layouts) | Sposta la finestra nella console Quake |
| `Super + Shift + Ctrl + Arrows` | Sposta la finestra sul monitor in quella direzione |
| `Super + Shift + Alt + Arrows` | Sposta il workspace sul monitor in quella direzione |
| `Super + Arrow` | Sposta il focus sulla finestra nella direzione della freccia, passando al monitor su quel lato al bordo dello schermo |
| `Super + Shift + Arrow` | Scambia la finestra con un'altra nella direzione della freccia, inclusa una sul monitor su quel lato |
| `Super + Minus` | Espandi la finestra a sinistra |
| `Super + Equal` | Riduci la finestra a sinistra |
| `Super + Shift + Minus` | Riduci la finestra in alto |
| `Super + Shift + Equal` | Espandi la finestra in basso |
| `Super + Alt + Minus/Equal` | Stesso ridimensionamento a passi più piccoli |
| `Super + Ctrl + Minus/Equal` | Stesso ridimensionamento a passi più grandi |
| `Super + Alt + Home` | Salva la larghezza della finestra |
| `Super + Home` | Ripristina la larghezza salvata della finestra |
| `Super + Left Mouse` | Trascina la finestra |
| `Super + Right Mouse` | Ridimensiona la finestra |
| `Super + Scroll Wheel` | Scorri tra i workspace sul monitor attivo |
| `Super + G` | Attiva/disattiva il raggruppamento delle finestre |
| `Super + Alt + G` | Sposta la finestra fuori dal raggruppamento |
| `Super + Alt + Tab` | Scorri tra le finestre nel raggruppamento |
| `Super + Alt + Shift + Tab` | Scorri indietro tra le finestre nel raggruppamento |
| `Super + Alt + Scroll Wheel` | Scorri tra le finestre nel raggruppamento |
| `Super + Alt + 1/2/3/4/5` | Vai a una finestra specifica nel raggruppamento |
| `Super + Alt + Arrow` | Sposta la finestra nel raggruppamento nella direzione della freccia, inclusa una sul monitor su quel lato |
| `Super + Ctrl + Left/Right` | Spostati tra le finestre dentro un gruppo tiling |
| `Super + Ctrl + Z` | Zoom avanti sullo schermo (ripeti per zoomare di più) |
| `Super + Ctrl + Alt + Z` | Zoom indietro completo dallo schermo |
| `Super + /` | Avanza tra le opzioni di ridimensionamento del monitor |
| `Super + Alt + /` | Vai indietro tra le opzioni di ridimensionamento del monitor |
| `Alt + Tab` | Scorri in avanti tra le finestre sul workspace attivo |
| `Alt + Shift + Tab` | Scorri indietro tra le finestre sul workspace attivo |
| `Ctrl + Alt + Tab` | Scorri il focus in avanti tra i monitor |
| `Ctrl + Alt + Shift + Tab` | Scorri il focus indietro tra i monitor |
| `Super + I` | Cambia lingua di input (con più di un layout o metodo di input) |
| `Super + Shift + I` | Torna alla lingua di input precedente |

Su un touchpad, i gesti con tre e quattro dita cambiano workspace, spostano finestre e aprono il menu e la console Quake; vedi [tastiera, mouse e trackpad](34-keyboard-mouse-trackpad.md) per i gesti.

Il ridimensionamento usa i due tasti a destra dello 0, qualunque cosa la tua tastiera vi stampi sopra: `-` e `=` sulle tastiere US, `+` e `´` su quelle danesi e svedesi, `+` e `\` su quella norvegese, `ß` e `´` su quella tedesca, `'` e `¡` su quella spagnola e `-` e `^` su quella giapponese (JIS). `Super + K` li elenca come li stampa la tua tastiera. Su JIS, `Super + ^` è `Super + Equal`, mentre `Super + Shift + -` (che digita `=`) è `Super + Shift + Minus`. Il ridimensionamento del monitor e il gestore password usano `/`; sui layout che digitano `/` solo con Shift, come la maggior parte di quelli europei, usano invece il tasto a sinistra dello Shift destro (`-` su danese e tedesca).

## Controlli di sistema

| Scorciatoia | Funzione |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Pannello audio |
| `Super + Ctrl + B` | Pannello Bluetooth |
| `Super + Ctrl + N` | Pannello Wi-Fi/rete |
| `Super + Ctrl + D` | Pannello schermo |
| `Super + Ctrl + P` | Pannello alimentazione |
| `Super + Ctrl + X` | Pannello agenti |
| `Super + Ctrl + Alt + D` | Pannello calendario |
| `Super + Ctrl + Alt + E` | Pannello orologio mondiale |
| `Super + Ctrl + 1-9` | Attiva/disattiva il pannello della barra per posizione |
| `Super + Ctrl + S` | Menu di condivisione (tramite LocalSend) |
| `Super + Ctrl + C` | Controlli di cattura (screenshot/-registrazione/selettore) |
| `Super + Ctrl + O` | Attiva/disattiva menu |
| `Super + Ctrl + H` | Menu hardware |
| `Super + Ctrl + E` | Selettore emoji |
| `Super + Ctrl + .` | Transcodifica media |
| `Super + Shift + Ctrl + A` | Avvia il tuo agente predefinito |
| `Power` key | Menu di sistema |
| `Super + Shift + Copilot` key | Menu Omarchy |

## Regolazioni

| Scorciatoia | Funzione |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Luminosità massima dello schermo |
| `Shift + Brightness Down` | Luminosità minima dello schermo |
| `Alt + Brightness Up/Down` | Cambiamenti precisi di luminosità dell'1% |
| `Alt + Volume Up/Down` | Cambiamenti precisi di volume dell'1% |
| `Keyboard Brightness Up/Down` | Retroilluminazione della tastiera più luminosa/più tenue |
| `Keyboard Backlight` | Scorri tra i livelli di retroilluminazione della tastiera |
| `Ctrl + Brightness Up/Down` | Retroilluminazione della tastiera più luminosa/più tenue, sulle tastiere senza tasti dedicati |
| `Mic Mute` | Silenzia il microfono |
| `Shift + Mute` | Cambia uscita audio |
| `Touchpad Toggle` | Attiva o disattiva il touchpad |
| `Display` key | Scorri tra i layout del workspace |
| `Alt + Play` | Traccia successiva |
| `Alt + Shift + Play` | Traccia precedente |

## Avvio delle app

| Scorciatoia | Funzione |
| ----------------------- | --------------------- |
| `Super + Return` | Terminale |
| `Super + Alt + Return` | Terminale Tmux |
| `Super + Ctrl + Return` | Herdr (gestore agenti) |
| `Super + Shift + Return` o `Super + Shift + B` | Browser |
| `Super + Shift + Alt + B` | Browser (privata/in incognito) |
| `Super + Shift + F` | Gestore file |
| `Super + Shift + Alt + F` | Gestore file nella cwd del terminale |
| `Super + Shift + M` | Musica (Spotify) |
| `Super + Shift + Alt + M` | Musica (cliamp) |
| `Super + Shift + /` | Gestore password (1password) |
| `Super + Shift + Q` o `Calculator` key | Calcolatrice (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, una volta installato) |
| `Super + Shift + T` | Attività (btop) |
| `Super + Shift + N` | Editor (Plain, o quello predefinito che hai scelto) |
| `Super + Shift + C` | Calendario ([HEY](https://hey.com/)) |
| `Super + Shift + E` | Email ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Nuova email ([HEY](https://hey.com/)) |
| `Super + Shift + A` | Il tuo agente predefinito, o ChatGPT finché non ne scegli uno |
| `Super + Shift + Alt + A` | IA (Grok) |
| `Super + Shift + G` | Messenger (Signal) |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | Messenger (WhatsApp) |
| `Super + Shift + Ctrl + G` | Messenger (Google) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | Scrittura (Omawrite) |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X (nuovo post) |
| `Super + Shift + Y` | YouTube |

Cambia/aggiungi associazioni in `~/.config/hypr/bindings.lua`.

## Appunti universali

| Scorciatoia | Funzione |
| ----------------------- | --------------------- |
| `Super + A` | Seleziona tutto nelle app che supportano `Ctrl + A` |
| `Super + C` | Copia |
| `Super + X` | Taglia (non nel terminale) |
| `Super + V` | Incolla |
| `Super + Ctrl + V` | Gestore appunti |

Di solito su Linux serve `Ctrl + Shift + C/V` per copiare e incollare nel terminale e `Ctrl + C/V` per farlo ovunque. Queste scorciatoie unificate per gli appunti di Omarchy funzionano ovunque.

## Cattura

| Scorciatoia | Funzione |
| ------------------- | ------------------------------ |
| `Print Screen` | Screenshot |
| `Super + Ctrl + Alt + C` | Screenshot (la stessa cattura, per tastiere senza tasto Print Screen) |
| `Super + Ctrl + C` | Menu di cattura |
| `Alt + Print Screen` | Registrazione schermo |
| `Super + Shift + Ctrl + Alt + C` | Registrazione schermo senza audio, saltando il menu (premi di nuovo per interromperla) |
| `Super + Print Screen` | Selettore colore |
| `Super + Ctrl + Print Screen` | Estrazione del testo negli appunti |
| `Super + Alt + [` | Riduci la sovrapposizione webcam durante la registrazione |
| `Super + Alt + ]` | Ingrandisci la sovrapposizione webcam durante la registrazione |
| `Alt + Shift + L` | Copia l'URL corrente da webapp o browser |
| `Alt + Shift + D` | Scarica il video sulla pagina corrente in `~/Videos` |
| `Alt + Space` | Avvia/interrompi la dettatura (richiede _Configurazione > Predefiniti > Dettatura_) |
| `Right Alt` | Tieni premuto per dettare (richiede _Configurazione > Predefiniti > Dettatura_) |

Con le registrazioni schermo, la scorciatoia chiede prima quale audio vuoi, poi avvia la registrazione. Premila di nuovo per interromperla. Vedi [screenshot e registrazione](12-screenshots-recording.md) per i dettagli.

Tutte le opzioni di cattura sono accessibili anche sotto _Attiva > Cattura_ nel menu Omarchy (`Super + Space`).

## Notifiche

| Scorciatoia | Funzione |
| ----------------------- | --------------------- |
| `Super + ,` | Agisci sull'ultima notifica: aprila o premi il suo unico pulsante, scegli tra le sue opzioni o ignorala quando non ne ha |
| `Super + Shift + ,` | Ignora tutte le notifiche |
| `Super + Ctrl + ,` | Controlla le notifiche con la tastiera |
| `Super + Alt + ,` | Ignora l'ultima notifica |
| `Super + Shift + Alt + ,` | Apri la cronologia delle notifiche |
| `Super + Ctrl + Alt + ,` | Attiva/disattiva il silenziamento delle notifiche |

## Stile

| Scorciatoia | Funzione |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Scegli un nuovo tema (anche `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Scegli lo sfondo del tema (anche `Super + Ctrl + Space`) |
| `Super + Backspace` | Attiva/disattiva la trasparenza su una finestra |
| `Super + Ctrl + Backspace` | Attiva/disattiva le proporzioni quadrate a singola finestra |

Le immagini di sfondo aggiuntive si trovano in `~/.config/omarchy/backgrounds/<theme name>`. Disponibile anche tramite _Installa > Stile > Sfondo_ nel menu Omarchy.

Tutte le opzioni di stile sono accessibili anche sotto _Aspetto_ nel menu Omarchy (`Super + Space`).

## Attivazioni

| Scorciatoia | Funzione |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Attiva/disattiva il blocco in inattività |
| `Super + Ctrl + Delete` | Attiva/disattiva lo schermo del laptop |
| `Super + Ctrl + Alt + Delete` | Attiva/disattiva la duplicazione dello schermo del laptop |
| `Super + Shift + Space` | Attiva/disattiva la barra superiore |
| `Shift + Mute` | Passa alla prossima uscita audio |
| `Shift + Play` | Passa alla prossima sorgente multimediale |
| `Super + Shift + Backspace` | Attiva/disattiva gli spazi tra le finestre |
| `Super + Ctrl + Alt + F` | Attiva/disattiva il desktop a schermo intero (barra superiore + spazi tra le finestre) |

## Promemoria

| Scorciatoia | Funzione |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Imposta un promemoria |
| `Super + Ctrl + Alt + R` | Vedi tutti i promemoria |
| `Super + Ctrl + Shift + R` | Cancella tutti i promemoria |

## Avvisi

| Scorciatoia | Funzione |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Mostra l'ora come notifica |
| `Super + Ctrl + Alt + B` | Mostra la batteria come notifica |
| `Super + Ctrl + Alt + W` | Attiva/disattiva il meteo come notifica |

## Tmux

Il tasto prefisso è `Ctrl + Space` (`Ctrl + B` funziona anche). Puoi cambiare queste associazioni in `~/.config/tmux/tmux.conf`.

### Pannelli

| Scorciatoia | Funzione |
| ----------------------- | --------------------- |
| `Prefix + v` | Dividi il pannello a fianco (verticale) |
| `Prefix + h` | Dividi il pannello sotto (orizzontale) |
| `Prefix + x` | Termina pannello |
| `Prefix + z` | Attiva/disattiva lo zoom del pannello (schermo intero) |
| `Alt + Enter` | Dividi il pannello sotto (senza prefisso) |
| `Alt + Shift + Enter` | Dividi il pannello a fianco (senza prefisso) |
| `Alt + Escape` | Termina pannello (senza prefisso) |
| `Ctrl + Alt + Arrows` | Spostati tra i pannelli |
| `Ctrl + Alt + Shift + Arrows` | Ridimensiona i pannelli |

### Finestre

| Scorciatoia | Funzione |
| ----------------------- | --------------------- |
| `Prefix + c` | Nuova finestra |
| `Prefix + k` | Termina finestra |
| `Prefix + r` | Rinomina finestra |
| `Alt + 1-9` | Vai alla finestra specifica |
| `Alt + Arrow Left/Right` | Spostati tra le finestre |
| `Alt + Shift + Arrow Left/Right` | Sposta la finestra a sinistra/destra |

### Sessioni

| Scorciatoia | Funzione |
| ----------------------- | --------------------- |
| `Prefix + C` | Nuova sessione |
| `Prefix + K` | Termina sessione |
| `Prefix + R` | Rinomina sessione |
| `Prefix + N` | Sessione successiva |
| `Prefix + P` | Sessione precedente |
| `Alt + Arrow Up/Down` | Spostati tra le sessioni |
| `Prefix + s` | Elenca le sessioni |
| `Prefix + d` | Scollegati dalla sessione |

### Modalità copia (stile vi)

| Scorciatoia | Funzione |
| ----------------------- | --------------------- |
| `Prefix + [` | Entra in modalità copia |
| `v` | Inizia la selezione (in modalità copia) |
| `y` | Copia la selezione (in modalità copia) |

### Generale

| Scorciatoia | Funzione |
| ----------------------- | --------------------- |
| `Prefix + q` | Ricarica la configurazione |
| `Prefix + ?` | Mostra le associazioni di tasti Tmux |
| `Prefix + :` | Prompt dei comandi |

### Funzioni layout Tmux

Queste funzioni devono essere eseguite dentro una sessione Tmux.

| Comando | Funzione |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Crea un layout di sviluppo con editor, IA e terminale |
| `tdlm <ai> [<second_ai>]` | Crea un layout di sviluppo per sottodirectory |
| `tsl <count> <command>` | Crea un layout swarm a più pannelli |

## Terminale Ghostty

Il terminale Ghostty si installa usando _Installa > Terminale_ tramite il menu Omarchy.

| Scorciatoia | Funzione |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nuova divisione sotto |
| `Ctrl + Shift + O` | Nuova divisione a fianco |
| `Ctrl + Alt + Arrows` | Spostati tra le divisioni |
| `Super + Ctrl + Shift + Arrows` | Ridimensiona la divisione di 10 righe |
| `Super + Ctrl + Shift + Alt + Arrows` | Ridimensiona la divisione di 100 righe |
| `Ctrl + Shift + T` | Nuova scheda |
| `Ctrl + Shift + Arrows` | Spostati tra le schede |
| `Alt + Numbers` | Vai alla scheda specifica |
| `Shift + Pg Up/Down` | Scorri la cronologia |
| `Ctrl + Left mouse` | Apri il link nel browser |

## Gestore file

| Scorciatoia | Funzione |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Vai al percorso |
| `Space` | Anteprima file (le frecce navigano) |
| `Alt + Up` | Vai su alla cartella superiore |

## Neovim (con lazyvim)

### Navigazione

| Scorciatoia | Funzione |
| ------------------------ | ------------------------------- |
| `Space` | Mostra le opzioni comando |
| `Space Space` | Apri il file tramite ricerca fuzzy |
| `Space E` | Attiva/disattiva la barra laterale |
| `Space G G` | Mostra i controlli git |
| `Space S G` | Cerca il contenuto del file |
| `Ctrl + W W` | Salta tra barra laterale ed editor |
| `Ctrl + Left/right arrow` | Cambia la dimensione della barra laterale |
| `Shift + H` | Vai alla scheda file a sinistra |
| `Shift + L` | Vai alla scheda file a destra |
| `Space B D` | Chiudi la scheda file |

### Nella barra laterale

| Scorciatoia | Funzione |
| ------------------------ | ------------------------------- |
| `A` | Aggiungi un nuovo file nella dir superiore |
| `Shift + A` | Aggiungi una nuova subdir nella dir superiore |
| `D` | Elimina il file/dir evidenziato |
| `M` | Sposta il file/dir evidenziato |
| `R` | Rinomina il file/dir evidenziato |
| `?` | Mostra l'aiuto per tutti i comandi |

[Vedi tutte le scorciatoie da tastiera di Neovim configurate da LazyVim](https://www.lazyvim.org/keymaps).

## Emoji rapide

Puoi usare `Super + Ctrl + E` per mostrare un selettore emoji completo che metterà la selezione negli appunti, oppure puoi usare queste opzioni di accesso rapido.

| Scorciatoia | EM | Indizio |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | sorriso |
| `Shift + CapsLock M C` | 😂 | pianto |
| `Shift + CapsLock M L` | 😍 | amore |
| `Shift + CapsLock M V` | ✌️ | vittoria |
| `Shift + CapsLock M H` | ❤️ | cuore |
| `Shift + CapsLock M Y` | 👍 | sì |
| `Shift + CapsLock M N` | 👎 | no |
| `Shift + CapsLock M F` | 🖕 | fanculo |
| `Shift + CapsLock M W` | 🤞 | desiderio |
| `Shift + CapsLock M R` | 🤘 | rock |
| `Shift + CapsLock M K` | 😘 | bacio |
| `Shift + CapsLock M E` | 🙄 | occhi al cielo |
| `Shift + CapsLock M I` | 😉 | occhiolino |
| `Shift + CapsLock M P` | 🙏 | prega |
| `Shift + CapsLock M D` | 🤤 | sbava |
| `Shift + CapsLock M M` | 💰 | soldi |
| `Shift + CapsLock M X` | 🎉 | festeggia |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | brindisi |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | saluto |
| `Shift + CapsLock M A` |💪 | braccio |
| `Shift + CapsLock M B` |🤯 | che esplode |

## Completamenti rapidi

| Scorciatoia | Completamento |
| ------------ | ---------- |
| `Shift + CapsLock Space Space` | — (trattino lungo) |
| `Shift + CapsLock Space N` | Il tuo nome (come inserito durante la configurazione) |
| `Shift + CapsLock Space E` | La tua email (come inserita durante la configurazione) |

Puoi aggiungerne altri di tuoi modificando `~/.XCompose`, poi eseguendo `omarchy restart xcompose` nel terminale per far rilevare le modifiche.
