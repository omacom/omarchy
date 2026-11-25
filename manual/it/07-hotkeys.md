# Tasti di scelta rapida

Puoi vedere tutte le principali combinazioni di tasti con `Super + K` (combinazioni Tmux con `Super + Alt + K` e combinazioni Herdr con `Super + Ctrl + K`).

## Come sono organizzati i tasti di scelta rapida

Ogni tasto di scelta rapida si trova su un piano, definito dai suoi modificatori, e ogni piano ha un solo compito. È questo che impedisce ai tasti di scelta rapida di confondersi tra loro, e significa che di solito puoi indovinare dove si trova qualcosa.

| Piano | Cosa contiene | Esempi |
| --- | --- | --- |
| `Super + key` | Il sistema: finestre, spazi di lavoro, layout e menu principali | `Super + Space` menu Omarchy, `Super + W` chiudi finestra, `Super + F` schermo intero |
| `Super + Shift + key` | App | `Super + Shift + B` browser, `Super + Shift + E` email, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Pannelli e menu di sistema | `Super + Ctrl + A` audio, `Super + Ctrl + N` rete, `Super + Ctrl + C` menu di acquisizione |
| `Super + Ctrl + Alt + key` | Azioni rapide e avvisi | `Super + Ctrl + Alt + T` mostra ora, `Super + Ctrl + Alt + B` batteria, `Super + Ctrl + Alt + C` schermata |

Aggiungere `Alt` a un tasto di scelta rapida ti dà una variante della stessa cosa, mai qualcosa di scollegato:

- `Super + Shift + B` apre il browser; `Super + Shift + Alt + B` apre una finestra privata
- `Super + Shift + E` apre l'email; `Super + Shift + Alt + E` ne avvia una nuova
- `Super + F` va a schermo intero; `Super + Alt + F` va a larghezza intera
- `Super + Ctrl + C` apre il menu di acquisizione; `Super + Ctrl + Alt + C` salta il menu e acquisisce una schermata

Quando aggiungi un tasto di scelta rapida:

1. Scegli il piano in base a cosa fa, poi scegli il tasto.
2. Non spostare un tasto di scelta rapida esistente per fare spazio. Trova un tasto libero sul piano giusto.
3. Usa `Alt` solo per una variante del tasto di scelta rapida senza di esso.

Alcuni tasti di scelta rapida infrangono queste regole perché sono comodi. `Shift` con una freccia o `Tab` sposta o inverte invece di aprire un'app, e `Print`, i tasti multimediali, `Alt + Tab` e `Ctrl + Alt + Del` funzionano come ovunque. Sono eccezioni, non modelli da copiare.

Se un'impostazione predefinita non ti va bene (diciamo che vuoi `Super + Shift + S` per le schermate come su Windows), riassegnala in `~/.config/hypr/bindings.lua`.

## Navigazione

| Tasto di scelta rapida                  | Funzione              |
| ----------------------- | --------------------- |
| `Super + Space`           | Menu Omarchy (app e tutto il resto)    |
| `Super + Alt + Space` | Griglia delle app |
| `Super + Escape` | Menu di sistema (sospendi, riavvia, ecc.)  |
| `Super + Ctrl + L` | Blocca computer |
| `Super + W` or `Super + Q` | Chiudi finestra             |
| `Ctrl + Alt + Del` | Chiudi tutte le finestre |
| `Super + K` | Mostra tutti i tasti di scelta rapida |
| `Super + Alt + K` | Mostra i tasti di scelta rapida di tmux |
| `Super + Ctrl + K` | Mostra i tasti di scelta rapida di herdr |
| `Super + M` | Riduci finestra nel dock |
| `Super + T`               | Commuta la finestra tra affiancata e flottante             |
| `Super + J` | Commuta posizione finestra (orizzontale/verticale) |
| `Super + O`               | Commuta la finestra a comparsa in sticky'n'floating |
| `Super + L`               | Passa in rassegna i layout dwindle, scrolling e floating |
| `Super + Alt + L`         | Passa in rassegna i layout in ordine inverso |
| `Super + P`               | Commuta stile finestra pseudo (naturale vs allungato) |
| `Super + F`                 | Vai a schermo intero              |
| `Super + Alt + F`                 | Vai a larghezza intera              |
| `Super + Ctrl + F`                 | Vai a schermo intero dentro la finestra              |
| `Super + 1…9/0`         | Vai allo spazio di lavoro specifico (0 è 10) sul monitor attivo |
| `Super + Tab` | Vai allo spazio di lavoro successivo sul monitor attivo |
| `Super + Shift + Tab` | Vai allo spazio di lavoro precedente sul monitor attivo |
| `Super + Ctrl + Tab` | Vai allo spazio di lavoro visitato in precedenza sul monitor attivo |
| `Super + Shift + 1…9/0` | Sposta finestra nello spazio di lavoro sul monitor attivo |
| `Super + Shift + Alt + 1…9/0` | Sposta finestra nello spazio di lavoro sul monitor attivo senza seguirla |
| `Super + S` | Attiva/disattiva scratchpad intero |
| `Super + Alt + S` | Sposta finestra nello scratchpad intero |
| `Super + the key above Tab` (grave on US layouts) | Attiva/disattiva console Quake |
| `Super + Shift + the key above Tab` (grave on US layouts) | Sposta finestra nella console Quake |
| `Super + Shift + Ctrl + Arrows` | Sposta finestra sul monitor in quella direzione |
| `Super + Shift + Alt + Arrows` | Sposta spazio di lavoro sul monitor in quella direzione |
| `Super + Arrow`  | Sposta il focus sulla finestra nella direzione della freccia, passando al monitor su quel lato al bordo dello schermo |
| `Super + Shift + Arrow`  | Scambia finestra con un'altra nella direzione della freccia, inclusa una sul monitor su quel lato |
| `Super + Minus` | Espandi finestra a sinistra |
| `Super + Equal` | Riduci finestra a sinistra |
| `Super + Shift + Minus` | Riduci finestra verso l'alto |
| `Super + Shift + Equal` | Espandi finestra verso il basso |
| `Super + Alt + Minus/Equal` | Stesso ridimensionamento a passi più piccoli |
| `Super + Ctrl + Minus/Equal` | Stesso ridimensionamento a passi più grandi |
| `Super + Alt + Home` | Salva larghezza finestra |
| `Super + Home` | Ripristina larghezza finestra salvata |
| `Super + Left Mouse` | Trascina finestra |
| `Super + Right Mouse` | Ridimensiona finestra |
| `Super + Scroll Wheel` | Scorri gli spazi di lavoro sul monitor attivo |
| `Super + G`               | Attiva/disattiva raggruppamento finestre      |
| `Super + Alt + G`               | Sposta finestra fuori dal raggruppamento      |
| `Super + Alt + Tab`               | Passa in rassegna le finestre nel raggruppamento      |
| `Super + Alt + Shift + Tab`               | Passa in rassegna all'indietro le finestre nel raggruppamento      |
| `Super + Alt + Scroll Wheel` | Passa in rassegna le finestre nel raggruppamento |
| `Super + Alt + 1/2/3/4/5`               | Vai alla finestra specifica nel raggruppamento      |
| `Super + Alt + Arrow`  | Sposta finestra nel raggruppamento nella direzione della freccia, inclusa una sul monitor su quel lato |
| `Super + Ctrl + Left/Right`  | Spostati tra le finestre dentro un gruppo affiancato |
| `Super + Ctrl + Z` | Ingrandisci sullo schermo (ripeti per ingrandire ancora) |
| `Super + Ctrl + Alt + Z` | Riduci completamente lo zoom dallo schermo |
| `Super + /` | Avanza tra le opzioni di ridimensionamento del monitor |
| `Super + Alt + /` | Indietreggia tra le opzioni di ridimensionamento del monitor |
| `Alt + Tab` | Passa in avanti tra le finestre nello spazio di lavoro attivo |
| `Alt + Shift + Tab` | Passa all'indietro tra le finestre nello spazio di lavoro attivo |
| `Ctrl + Alt + Tab`| Passa in avanti il focus tra i monitor |
| `Ctrl + Alt + Shift + Tab`| Passa all'indietro il focus tra i monitor |
| `Super + I` | Cambia lingua di input (con più di un layout o metodo di input) |
| `Super + Shift + I` | Torna alla lingua di input precedente |

Su un touchpad, gli swipe con tre e quattro dita cambiano spazio di lavoro, spostano finestre e aprono il menu e la console Quake; vedi [tastiera, mouse e trackpad](34-keyboard-mouse-trackpad.md) per i gesti.

Il ridimensionamento usa i due tasti a destra dello 0, qualunque cosa la tua tastiera vi stampi sopra: `-` e `=` sulle tastiere US, `+` e `´` su quelle danesi e svedesi, `+` e `\` su quelle norvegesi, `ß` e `´` su quelle tedesche, `'` e `¡` su quelle spagnole, e `-` e `^` su quelle giapponesi (JIS). `Super + K` li elenca come li stampa la tua tastiera. Su JIS, `Super + ^` è `Super + Equal`, mentre `Super + Shift + -` (che digita `=`) è `Super + Shift + Minus`. Il ridimensionamento del monitor e il gestore di password usano `/`; sui layout che digitano `/` solo con Shift, come la maggior parte di quelli europei, usano invece il tasto a sinistra dello Shift destro (`-` su danese e tedesco).

## Controlli di sistema

| Tasto di scelta rapida                  | Funzione              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Pannello audio    |
| `Super + Ctrl + B`           | Pannello Bluetooth    |
| `Super + Ctrl + N`           | Pannello Wi-Fi/rete    |
| `Super + Ctrl + D`           | Pannello schermo    |
| `Super + Ctrl + P`           | Pannello alimentazione    |
| `Super + Ctrl + X`           | Pannello agenti    |
| `Super + Ctrl + Alt + D`           | Pannello calendario    |
| `Super + Ctrl + Alt + E`           | Pannello orologio mondiale    |
| `Super + Ctrl + 1-9`           | Attiva/disattiva pannello della barra per posizione    |
| `Super + Ctrl + S` | Menu di condivisione (tramite LocalSend) |
| `Super + Ctrl + C` | Controlli di acquisizione (schermata/registrazione/selettore) |
| `Super + Ctrl + O` | Attiva/disattiva menu |
| `Super + Ctrl + H` | Menu hardware |
| `Super + Ctrl + E` | Selettore emoji |
| `Super + Ctrl + .` | Transcodifica media |
| `Super + Shift + Ctrl + A` | Avvia il tuo agente predefinito |
| `Power` key | Menu di sistema |
| `Super + Shift + Copilot` key | Menu Omarchy |

## Regolazioni

| Tasto di scelta rapida                  | Funzione              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Luminosità massima dello schermo |
| `Shift + Brightness Down` | Luminosità minima dello schermo |
| `Alt + Brightness Up/Down` | Modifiche precise della luminosità dell'1% |
| `Alt + Volume Up/Down` | Modifiche precise del volume dell'1% |
| `Keyboard Brightness Up/Down` | Retroilluminazione tastiera più luminosa/più tenue |
| `Keyboard Backlight` | Passa in rassegna i livelli di retroilluminazione della tastiera |
| `Ctrl + Brightness Up/Down` | Retroilluminazione tastiera più luminosa/più tenue, sulle tastiere senza tasti dedicati |
| `Mic Mute` | Silenzia il microfono |
| `Shift + Mute` | Cambia uscita audio |
| `Touchpad Toggle` | Accendi o spegni il touchpad |
| `Display` key | Passa in rassegna il layout dello spazio di lavoro |
| `Alt + Play` | Brano successivo |
| `Alt + Shift + Play` | Brano precedente |

## Avvio delle app

| Tasto di scelta rapida                  | Funzione              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminale    |
| `Super + Alt + Return` | Terminale Tmux |
| `Super + Ctrl + Return` | Herdr (gestore di agenti) |
| `Super + Shift + Return` or `Super + Shift + B`  | Browser    |
| `Super + Shift + Alt + B`           | Browser (privata/in incognito)    |
| `Super + Shift + F`           | Gestore dei file    |
| `Super + Shift + Alt + F`           | Gestore dei file nella cwd del terminale    |
| `Super + Shift + M`           | Musica (Spotify)    |
| `Super + Shift + Alt + M`           | Musica (cliamp)    |
| `Super + Shift + /`           | Gestore di password (1password)    |
| `Super + Shift + Q` or `Calculator` key  | Calcolatrice (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, una volta installato)    |
| `Super + Shift + T`           | Attività (btop)    |
| `Super + Shift + N`           | Editor (Plain, o quello predefinito che hai scelto)  |
| `Super + Shift + C`           | Calendario ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | Email ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Nuova email ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | AI (ChatGPT)  |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Messenger (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Messenger (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Messenger (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Scrittura (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X (nuovo post) |
| `Super + Shift + Y`           | YouTube |

Cambia/aggiungi associazioni in `~/.config/hypr/bindings.lua`.

## Appunti universali

| Tasto di scelta rapida                  | Funzione              |
| ----------------------- | --------------------- |
| `Super + A`           | Seleziona tutto nelle app che supportano `Ctrl + A`    |
| `Super + C`           | Copia    |
| `Super + X`           | Taglia (non nel terminale)    |
| `Super + V`           | Incolla    |
| `Super + Ctrl + V`           | Gestore degli appunti    |

Di solito su Linux, ti serve `Ctrl + Shift + C/V` per copiare e incollare nel terminale e `Ctrl + C/V` per farlo ovunque altro. Questi tasti di scelta rapida unificati per gli appunti di Omarchy funzionano ovunque.

## Acquisizione

| Tasto di scelta rapida              | Funzione                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Schermata                      |
| `Super + Ctrl + Alt + C`            | Schermata (la stessa acquisizione, per le tastiere senza tasto Print Screen) |
| `Super + Ctrl + C` | Menu di acquisizione |
| `Alt + Print Screen`            | Registrazione schermo                     |
| `Super + Shift + Ctrl + Alt + C` | Registrazione schermo senza audio, saltando il menu (premi di nuovo per fermarla) |
| `Super + Print Screen` | Selettore colore |
| `Super + Ctrl + Print Screen` | Estrazione testo negli appunti |
| `Super + Alt + [` | Rendi più piccola la sovrapposizione webcam durante la registrazione |
| `Super + Alt + ]` | Rendi più grande la sovrapposizione webcam durante la registrazione |
| `Alt + Shift + L` | Copia l'URL corrente dalla webapp o dal browser |
| `Alt + Shift + D` | Scarica il video sulla pagina corrente in `~/Videos` |
| `Alt + Space` | Avvia/ferma la dettatura (richiede _Setup > Defaults > Dictation_) |
| `Right Alt` | Tieni premuto per dettare (richiede _Setup > Defaults > Dictation_) |

Con le registrazioni schermo, il tasto di scelta rapida chiede prima quale audio vuoi, poi avvia la registrazione. Premilo di nuovo per fermarla. Vedi [schermate e registrazione](12-screenshots-recording.md) per i dettagli.

Tutte le opzioni di acquisizione sono accessibili anche sotto _Trigger > Capture_ nel menu Omarchy (`Super + Space`).

## Notifiche

| Tasto di scelta rapida                  | Funzione              |
| ----------------------- | --------------------- |
| `Super + ,` | Agisci sull'ultima notifica: aprila o premi il suo unico pulsante, scegli tra le sue opzioni, o ignorala quando non ne ha  |
| `Super + Shift + ,` | Ignora tutte le notifiche |
| `Super + Ctrl + ,` | Controlla le notifiche con la tastiera  |
| `Super + Alt + ,` | Ignora l'ultima notifica  |
| `Super + Shift + Alt + ,` | Apri la cronologia delle notifiche  |
| `Super + Ctrl + Alt + ,` | Attiva/disattiva il silenziamento delle notifiche  |

## Stile

| Tasto di scelta rapida                  | Funzione              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Scegli un nuovo tema (anche `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Scegli lo sfondo del tema (anche `Super + Ctrl + Space`) |
| `Super + Backspace` | Attiva/disattiva la trasparenza su una finestra |
| `Super + Ctrl + Backspace` | Attiva/disattiva l'aspetto quadrato a finestra singola |

Le immagini di sfondo aggiuntive si trovano in `~/.config/omarchy/backgrounds/<theme name>`. Disponibile anche tramite _Install > Style > Background_ nel menu Omarchy.

Tutte le opzioni di stile sono accessibili anche sotto _Appearance_ nel menu Omarchy (`Super + Space`).

## Interruttori

| Tasto di scelta rapida                  | Funzione              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Attiva/disattiva il blocco in caso di inattività |
| `Super + Ctrl + Delete` | Accendi/spegni lo schermo del portatile |
| `Super + Ctrl + Alt + Delete` | Attiva/disattiva la duplicazione dello schermo del portatile |
| `Super + Shift + Space` | Attiva/disattiva la barra superiore  |
| `Shift + Mute` | Passa alla prossima uscita audio |
| `Shift + Play` | Passa alla prossima sorgente multimediale |
| `Super + Shift + Backspace` | Attiva/disattiva gli spazi tra le finestre |
| `Super + Ctrl + Alt + F` | Attiva/disattiva il desktop a schermo intero (barra superiore + spazi tra le finestre) |

## Promemoria

| Tasto di scelta rapida                  | Funzione              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Imposta un promemoria  |
| `Super + Ctrl + Alt + R` | Vedi tutti i promemoria  |
| `Super + Ctrl + Shift + R` | Cancella tutti i promemoria  |

## Avvisi

| Tasto di scelta rapida                  | Funzione              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Mostra l'ora come notifica  |
| `Super + Ctrl + Alt + B` | Mostra la batteria come notifica  |
| `Super + Ctrl + Alt + W` | Attiva/disattiva il meteo come notifica  |

## Tmux

Il tasto prefisso è `Ctrl + Space` (funziona anche `Ctrl + B`). Puoi cambiare queste associazioni in `~/.config/tmux/tmux.conf`.

### Riquadri

| Tasto di scelta rapida                  | Funzione              |
| ----------------------- | --------------------- |
| `Prefix + v` | Dividi riquadro a fianco (verticale) |
| `Prefix + h` | Dividi riquadro sotto (orizzontale) |
| `Prefix + x` | Termina riquadro |
| `Prefix + z` | Attiva/disattiva zoom riquadro (schermo intero) |
| `Alt + Enter` | Dividi riquadro sotto (senza prefisso) |
| `Alt + Shift + Enter` | Dividi riquadro a fianco (senza prefisso) |
| `Alt + Escape` | Termina riquadro (senza prefisso) |
| `Ctrl + Alt + Arrows` | Spostati tra i riquadri |
| `Ctrl + Alt + Shift + Arrows` | Ridimensiona i riquadri |

### Finestre

| Tasto di scelta rapida                  | Funzione              |
| ----------------------- | --------------------- |
| `Prefix + c` | Nuova finestra |
| `Prefix + k` | Termina finestra |
| `Prefix + r` | Rinomina finestra |
| `Alt + 1-9` | Vai alla finestra specifica |
| `Alt + Arrow Left/Right` | Spostati tra le finestre |
| `Alt + Shift + Arrow Left/Right` | Sposta finestra a sinistra/destra |

### Sessioni

| Tasto di scelta rapida                  | Funzione              |
| ----------------------- | --------------------- |
| `Prefix + C` | Nuova sessione |
| `Prefix + K` | Termina sessione |
| `Prefix + R` | Rinomina sessione |
| `Prefix + N` | Sessione successiva |
| `Prefix + P` | Sessione precedente |
| `Alt + Arrow Up/Down` | Spostati tra le sessioni |
| `Prefix + s` | Elenca sessioni |
| `Prefix + d` | Scollegati dalla sessione |

### Modalità copia (stile vi)

| Tasto di scelta rapida                  | Funzione              |
| ----------------------- | --------------------- |
| `Prefix + [` | Entra in modalità copia |
| `v` | Inizia selezione (in modalità copia) |
| `y` | Copia selezione (in modalità copia) |

### Generale

| Tasto di scelta rapida                  | Funzione              |
| ----------------------- | --------------------- |
| `Prefix + q` | Ricarica configurazione |
| `Prefix + ?` | Mostra le associazioni di tasti Tmux |
| `Prefix + :` | Prompt dei comandi |

### Funzioni di layout Tmux

Queste funzioni devono essere eseguite dentro una sessione Tmux.

| Comando | Funzione |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Crea layout di sviluppo con editor, AI e terminale |
| `tdlm <ai> [<second_ai>]` | Crea layout di sviluppo per sottodirectory |
| `tsl <count> <command>` | Crea layout swarm multiriquadro |

## Terminale Ghostty

Il terminale Ghostty si installa usando _Install > Terminal_ tramite il menu Omarchy.

| Tasto di scelta rapida                  | Funzione              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nuova divisione sotto |
| `Ctrl + Shift + O` | Nuova divisione a fianco |
| `Ctrl + Alt + Arrows` | Spostati tra le divisioni |
| `Super + Ctrl + Shift + Arrows` | Ridimensiona divisione di 10 righe |
| `Super + Ctrl + Shift + Alt + Arrows` | Ridimensiona divisione di 100 righe |
| `Ctrl + Shift + T` | Nuova scheda  |
| `Ctrl + Shift + Arrows` | Spostati tra le schede |
| `Alt + Numbers` | Vai alla scheda specifica |
| `Shift + Pg Up/Down` | Scorri la cronologia |
| `Ctrl + Left mouse` | Apri collegamento nel browser |

## Gestore dei file

| Tasto di scelta rapida              | Funzione                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Vai al percorso                     |
| `Space`               | Anteprima file (le frecce navigano) |
| `Alt + Up`       | Vai su alla cartella superiore        |

## Neovim (w/ lazyvim)

### Navigazione

| Tasto di scelta rapida                   | Funzione                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Mostra opzioni comando            |
| `Space Space`              | Apri file tramite ricerca fuzzy      |
| `Space E`                  | Attiva/disattiva barra laterale                  |
| `Space G G`                | Mostra controlli git               |
| `Space S G`                | Cerca contenuto del file             |
| `Ctrl + W W`               | Salta tra barra laterale ed editor |
| `Ctrl + Left/right arrow`  | Cambia dimensione della barra laterale          |
| `Shift + H`                      | Vai alla scheda file di sinistra             |
| `Shift + L`                      | Vai alla scheda file di destra            |
| `Space B D`                | Chiudi scheda file                  |

### Mentre sei nella barra laterale

| Tasto di scelta rapida                   | Funzione                        |
| ------------------------ | ------------------------------- |
| `A`                        | Aggiungi nuovo file nella directory superiore      |
| `Shift + A`                | Aggiungi nuova sottodirectory nella directory superiore    |
| `D`                        | Elimina file/dir evidenziato     |
| `M`                        | Sposta file/dir evidenziato       |
| `R`                        | Rinomina file/dir evidenziato     |
| `?`                        | Mostra aiuto per tutti i comandi      |

[Vedi tutti i tasti di scelta rapida Neovim configurati da LazyVim](https://www.lazyvim.org/keymaps).

## Emoji rapide

Puoi usare `Super + Ctrl + E` per mostrare un selettore emoji completo che metterà la selezione negli appunti, oppure puoi usare queste opzioni di accesso rapido.

| Tasto di scelta rapida       | EM | Indizio       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | smile      |
| `Shift + CapsLock M C` | 😂 | cry        |
| `Shift + CapsLock M L` | 😍 | love       |
| `Shift + CapsLock M V` | ✌️ | victory    |
| `Shift + CapsLock M H` | ❤️ | heart      |
| `Shift + CapsLock M Y` | 👍 | yes        |
| `Shift + CapsLock M N` | 👎 | no         |
| `Shift + CapsLock M F` | 🖕 | fuck       |
| `Shift + CapsLock M W` | 🤞 | wish       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | kiss       |
| `Shift + CapsLock M E` | 🙄 | eyeroll    |
| `Shift + CapsLock M I` | 😉 | wink       |
| `Shift + CapsLock M P` | 🙏 | pray |
| `Shift + CapsLock M D` | 🤤 | drool      |
| `Shift + CapsLock M M` | 💰 | money      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | toast      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | greeting |
| `Shift + CapsLock M A` |💪 | arm |
| `Shift + CapsLock M B` |🤯 | blowing |

## Completamenti rapidi

| Tasto di scelta rapida       | Completamento       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Il tuo nome (come inserito durante la configurazione)  |
| `Shift + CapsLock Space E` | La tua email (come inserita durante la configurazione)  |

Puoi aggiungerne altri tuoi modificando `~/.XCompose`, poi eseguendo `omarchy restart xcompose` nel terminale per far rilevare le modifiche.
