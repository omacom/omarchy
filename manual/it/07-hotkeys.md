# Scorciatoie da tastiera

Puoi vedere tutte le principali associazioni di tasti con `Super + K` (le associazioni di Tmux con `Super + Alt + K` e quelle di Herdr con `Super + Ctrl + K`).

## Come sono organizzate le scorciatoie

Ogni scorciatoia sta su un piano, definito dai suoi modificatori, e ogni piano ha un compito. È questo che impedisce alle scorciatoie di confondersi tra loro, e significa che di solito puoi indovinare dove si trova qualcosa.

| Piano | Cosa ci sta | Esempi |
| --- | --- | --- |
| `Super + key` | Il sistema: finestre, spazi di lavoro, layout e menu principali | `Super + Space` menu Omarchy, `Super + W` chiudi finestra, `Super + F` schermo intero |
| `Super + Shift + key` | App | `Super + Shift + B` browser, `Super + Shift + E` email, `Super + Shift + N` editor |
| `Super + Ctrl + key` | Pannelli e menu di sistema | `Super + Ctrl + A` audio, `Super + Ctrl + N` rete, `Super + Ctrl + C` menu di cattura |
| `Super + Ctrl + Alt + key` | Azioni rapide e avvisi | `Super + Ctrl + Alt + T` mostra l'ora, `Super + Ctrl + Alt + B` batteria, `Super + Ctrl + Alt + C` schermata |

Aggiungere `Alt` a una scorciatoia ti dà una variante della stessa cosa, mai qualcosa di non correlato:

- `Super + Shift + B` apre il browser; `Super + Shift + Alt + B` apre una finestra privata
- `Super + Shift + E` apre l'email; `Super + Shift + Alt + E` ne inizia una nuova
- `Super + F` va a schermo intero; `Super + Alt + F` va a larghezza intera
- `Super + Ctrl + C` apre il menu di cattura; `Super + Ctrl + Alt + C` salta il menu e fa una schermata

Quando aggiungi una scorciatoia:

1. Scegli il piano in base a cosa fa, poi scegli il tasto.
2. Non spostare una scorciatoia esistente per fare spazio. Trova un tasto libero sul piano giusto.
3. Usa `Alt` solo per una variante della scorciatoia senza di esso.

Alcune scorciatoie infrangono queste regole perché sono comode. `Shift` con una freccia o `Tab` sposta o inverte invece di aprire un'app, e `Print`, i tasti multimediali, `Alt + Tab` e `Ctrl + Alt + Del` funzionano come funzionano ovunque. Sono eccezioni, non modelli da copiare.

Se un'impostazione predefinita non ti va bene (diciamo che vuoi `Super + Shift + S` per le schermate come su Windows), riassegnala in `~/.config/hypr/bindings.lua`.

## Navigazione

| Scorciatoia | Funzione |
| ----------------------- | --------------------- |
| `Super + Space`           | Menu Omarchy (app e tutto il resto)    |
| `Super + Alt + Space` | Griglia delle app |
| `Super + Escape` | Menu di sistema (sospendi, riavvia, ecc.)  |
| `Super + Ctrl + L` | Blocca il computer |
| `Super + W` or `Super + Q` | Chiudi finestra             |
| `Ctrl + Alt + Del` | Chiudi tutte le finestre |
| `Super + K` | Mostra tutte le scorciatoie |
| `Super + Alt + K` | Mostra le scorciatoie di tmux |
| `Super + Ctrl + K` | Mostra le scorciatoie di herdr |
| `Super + M` | Riduci la finestra a icona nel dock |
| `Super + T`               | Alterna la finestra tra tiling/floating             |
| `Super + J` | Alterna la posizione della finestra (orizzontale/verticale) |
| `Super + O`               | Attiva/disattiva lo spostamento della finestra in sticky'n'floating |
| `Super + L`               | Scorri tra i layout dwindle, scrolling e floating |
| `Super + Alt + L`         | Scorri tra i layout al contrario |
| `Super + P`               | Attiva/disattiva lo stile pseudo della finestra (natural v stretch) |
| `Super + F`                 | Vai a schermo intero              |
| `Super + Alt + F`                 | Vai a larghezza intera              |
| `Super + Ctrl + F`                 | Vai a schermo intero dentro la finestra              |
| `Super + 1…9/0`         | Vai allo spazio di lavoro specifico (0 è 10) sul monitor attivo |
| `Super + Tab` | Vai allo spazio di lavoro successivo sul monitor attivo |
| `Super + Shift + Tab` | Vai allo spazio di lavoro precedente sul monitor attivo |
| `Super + Ctrl + Tab` | Vai allo spazio di lavoro precedente sul monitor attivo |
| `Super + Shift + 1…9/0` | Sposta la finestra in uno spazio di lavoro sul monitor attivo |
| `Super + Shift + Alt + 1…9/0` | Sposta la finestra in uno spazio di lavoro sul monitor attivo senza seguirla |
| `Super + S` | Attiva/disattiva lo scratchpad intero |
| `Super + Alt + S` | Sposta la finestra nello scratchpad intero |
| `Super + Grave` | Attiva/disattiva la console Quake |
| `Super + Shift + Grave` | Sposta la finestra nella console Quake |
| `Super + Shift + Ctrl + Arrows` | Sposta la finestra sul monitor in quella direzione |
| `Super + Shift + Alt + Arrows` | Sposta lo spazio di lavoro sul monitor in quella direzione |
| `Super + Arrow`  | Sposta la messa a fuoco sulla finestra nella direzione della freccia, passando al monitor su quel lato al bordo dello schermo |
| `Super + Shift + Arrow`  | Scambia la finestra con un'altra nella direzione della freccia, inclusa una sul monitor su quel lato |
| `Super + Minus` | Espandi la finestra a sinistra |
| `Super + Equal` | Riduci la finestra a sinistra |
| `Super + Shift + Minus` | Riduci la finestra verso l'alto |
| `Super + Shift + Equal` | Espandi la finestra verso il basso |
| `Super + Alt + Minus/Equal` | Stesso ridimensionamento in passi più piccoli |
| `Super + Ctrl + Minus/Equal` | Stesso ridimensionamento in passi più grandi |
| `Super + Alt + Home` | Salva la larghezza della finestra |
| `Super + Home` | Ripristina la larghezza salvata della finestra |
| `Super + Left Mouse` | Trascina la finestra in giro |
| `Super + Right Mouse` | Ridimensiona la finestra |
| `Super + Scroll Wheel` | Scorri tra gli spazi di lavoro sul monitor attivo |
| `Super + G`               | Attiva/disattiva il raggruppamento delle finestre      |
| `Super + Alt + G`               | Sposta la finestra fuori dal raggruppamento      |
| `Super + Alt + Tab`               | Scorri tra le finestre nel raggruppamento      |
| `Super + Alt + Shift + Tab`               | Scorri all'indietro tra le finestre nel raggruppamento      |
| `Super + Alt + Scroll Wheel` | Scorri tra le finestre nel raggruppamento |
| `Super + Alt + 1/2/3/4/5`               | Vai a una finestra specifica nel raggruppamento      |
| `Super + Alt + Arrow`  | Sposta la finestra nel raggruppamento nella direzione della freccia, inclusa una sul monitor su quel lato |
| `Super + Ctrl + Left/Right`  | Spostati tra le finestre dentro un gruppo di tiling |
| `Super + Ctrl + Z` | Ingrandisci lo schermo (ripeti per ingrandire di più) |
| `Super + Ctrl + Alt + Z` | Riduci completamente lo schermo |
| `Super + /` | Avanza tra le opzioni di scalatura del monitor |
| `Super + Alt + /` | Torna indietro tra le opzioni di scalatura del monitor |
| `Alt + Tab` | Scorri in avanti tra le finestre sullo spazio di lavoro attivo |
| `Alt + Shift + Tab` | Scorri all'indietro tra le finestre sullo spazio di lavoro attivo |
| `Ctrl + Alt + Tab`| Scorri in avanti la messa a fuoco tra i monitor |
| `Ctrl + Alt + Shift + Tab`| Scorri all'indietro la messa a fuoco tra i monitor |
| `Super + I` | Cambia lingua di input (con più di un layout o metodo di input) |
| `Super + Shift + I` | Cambia lingua di input al contrario |

Su un touchpad, gli scorrimenti con tre e quattro dita cambiano spazio di lavoro, spostano finestre e aprono il menu e la console Quake; vedi [tastiera, mouse e trackpad](34-keyboard-mouse-trackpad.md) per i gesti.

Le scorciatoie di ridimensionamento usano i tasti fisici `code:20` e `code:21` (XKB `<AE11>` e `<AE12>`), indipendentemente dai caratteri stampati sulla tastiera. Sulle tastiere US questi tasti sono `-` e `=`; sulle tastiere giapponesi (JIS) sono `-` e `^`; sulle tastiere spagnole sono `'` e `¡`. Su JIS, `Super + ^` è `Super + Equal`, mentre `Super + Shift + -` (che digita `=`) è `Super + Shift + Minus`.

## Controlli di sistema

| Scorciatoia | Funzione |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Pannello audio    |
| `Super + Ctrl + B`           | Pannello Bluetooth    |
| `Super + Ctrl + N`           | Pannello Wi-Fi/rete    |
| `Super + Ctrl + D`           | Pannello display    |
| `Super + Ctrl + P`           | Pannello alimentazione    |
| `Super + Ctrl + X`           | Pannello agenti    |
| `Super + Ctrl + Alt + D`           | Pannello calendario    |
| `Super + Ctrl + Alt + E`           | Pannello orologio mondiale    |
| `Super + Ctrl + 1-9`           | Attiva/disattiva il pannello della barra per posizione    |
| `Super + Ctrl + S` | Menu di condivisione (tramite LocalSend) |
| `Super + Ctrl + C` | Controlli di cattura (schermata/registrazione/selettore) |
| `Super + Ctrl + O` | Menu Attiva/disattiva |
| `Super + Ctrl + H` | Menu hardware |
| `Super + Ctrl + E` | Selettore emoji |
| `Super + Ctrl + .` | Transcodifica media |
| `Super + Shift + Ctrl + A` | Scegli un agente AI |
| `Power` key | Menu di sistema |
| `Super + Shift + Copilot` key | Menu Omarchy |

## Regolazioni

| Scorciatoia | Funzione |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Luminosità massima dello schermo |
| `Shift + Brightness Down` | Luminosità minima dello schermo |
| `Alt + Brightness Up/Down` | Modifiche precise della luminosità dell'1% |
| `Alt + Volume Up/Down` | Modifiche precise del volume dell'1% |
| `Keyboard Brightness Up/Down` | Retroilluminazione della tastiera più luminosa/più debole |
| `Keyboard Backlight` | Scorri tra i livelli di retroilluminazione della tastiera |
| `Ctrl + Brightness Up/Down` | Retroilluminazione della tastiera più luminosa/più debole, su tastiere senza tasti dedicati |
| `Mic Mute` | Silenzia il microfono |
| `Shift + Mute` | Cambia uscita audio |
| `Touchpad Toggle` | Accendi o spegni il touchpad |
| `Display` key | Scorri tra i layout dello spazio di lavoro |
| `Alt + Play` | Traccia successiva |
| `Alt + Shift + Play` | Traccia precedente |

## Avvio delle app

| Scorciatoia | Funzione |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminale    |
| `Super + Alt + Return` | Terminale Tmux |
| `Super + Ctrl + Return` | Herdr (gestore degli agenti) |
| `Super + Shift + Return` or `Super + Shift + B`  | Browser    |
| `Super + Shift + Alt + B`           | Browser (privato/in incognito)    |
| `Super + Shift + F`           | Gestore dei file    |
| `Super + Shift + Alt + F`           | Gestore dei file nella cwd del terminale    |
| `Super + Shift + M`           | Musica (Spotify)    |
| `Super + Shift + Alt + M`           | Musica (cliamp)    |
| `Super + Shift + /`           | Gestore delle password (1password)    |
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

| Scorciatoia | Funzione |
| ----------------------- | --------------------- |
| `Super + A`           | Seleziona tutto nelle app che supportano `Ctrl + A`    |
| `Super + C`           | Copia    |
| `Super + X`           | Taglia (non nel terminale)    |
| `Super + V`           | Incolla    |
| `Super + Ctrl + V`           | Gestore degli appunti    |

Di solito su Linux serve `Ctrl + Shift + C/V` per fare copia'n'colla nel terminale e `Ctrl + C/V` per farlo ovunque altro. Queste scorciatoie unificate per gli appunti di Omarchy funzionano ovunque.

## Cattura

| Scorciatoia | Funzione |
| ------------------- | ------------------------------ |
| `Print Screen`            | Schermata                      |
| `Super + Ctrl + Alt + C`            | Schermata (la stessa cattura, per le tastiere senza tasto Print Screen) |
| `Super + Ctrl + C` | Menu di cattura |
| `Alt + Print Screen`            | Registrazione schermo                     |
| `Super + Shift + Ctrl + Alt + C` | Registrazione schermo senza audio, saltando il menu (premi di nuovo per fermarla) |
| `Super + Print Screen` | Selettore colore |
| `Super + Ctrl + Print Screen` | Estrazione del testo negli appunti |
| `Super + Alt + [` | Rimpicciolisci la sovrapposizione della webcam durante la registrazione |
| `Super + Alt + ]` | Ingrandisci la sovrapposizione della webcam durante la registrazione |
| `Alt + Shift + L` | Copia l'URL corrente dalla webapp o dal browser |
| `Alt + Shift + D` | Scarica il video sulla pagina corrente in `~/Videos` |
| `Alt + Space` | Avvia/ferma la dettatura (richiede _Configurazione > Predefiniti > Dettatura_) |
| `Right Alt` | Tieni premuto per dettare (richiede _Configurazione > Predefiniti > Dettatura_) |

Con le registrazioni schermo, la scorciatoia chiede prima quale audio vuoi, poi inizia a registrare. Premila di nuovo per fermarla. Vedi [schermate e registrazione](12-screenshots-recording.md) per i dettagli.

Tutte le opzioni di cattura sono accessibili anche sotto _Trigger > Cattura_ nel menu Omarchy (`Super + Space`).

## Notifiche

| Scorciatoia | Funzione |
| ----------------------- | --------------------- |
| `Super + ,` | Intervieni sull'ultima notifica: aprila o premi il suo unico pulsante, scegli tra le sue opzioni, o ignorala quando non ne ha  |
| `Super + Shift + ,` | Ignora tutte le notifiche |
| `Super + Ctrl + ,` | Controlla le notifiche con la tastiera  |
| `Super + Alt + ,` | Ignora l'ultima notifica  |
| `Super + Shift + Alt + ,` | Apri la cronologia delle notifiche  |
| `Super + Ctrl + Alt + ,` | Attiva/disattiva il silenziamento delle notifiche  |

## Stile

| Scorciatoia | Funzione |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Scegli un nuovo tema (anche `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Scegli lo sfondo del tema (anche `Super + Ctrl + Space`) |
| `Super + Backspace` | Attiva/disattiva la trasparenza su una finestra |
| `Super + Ctrl + Backspace` | Attiva/disattiva l'aspetto quadrato per la singola finestra |

Le immagini di sfondo extra si trovano in `~/.config/omarchy/backgrounds/<theme name>`. Disponibili anche tramite _Installa > Stile > Sfondo_ nel menu Omarchy.

Tutte le opzioni di stile sono accessibili anche sotto _Aspetto_ nel menu Omarchy (`Super + Space`).

## Interruttori

| Scorciatoia | Funzione |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Attiva/disattiva il blocco quando inattivo |
| `Super + Ctrl + Delete` | Attiva/disattiva il display del laptop |
| `Super + Ctrl + Alt + Delete` | Attiva/disattiva la duplicazione del display del laptop |
| `Super + Shift + Space` | Attiva/disattiva la barra superiore  |
| `Shift + Mute` | Passa alla prossima uscita audio |
| `Shift + Play` | Passa alla prossima sorgente multimediale |
| `Super + Shift + Backspace` | Attiva/disattiva gli spazi tra le finestre |
| `Super + Ctrl + Alt + F` | Attiva/disattiva il desktop a schermo intero (barra superiore + spazi tra le finestre) |

## Promemoria

| Scorciatoia | Funzione |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Imposta un promemoria  |
| `Super + Ctrl + Alt + R` | Vedi tutti i promemoria  |
| `Super + Ctrl + Shift + R` | Cancella tutti i promemoria  |

## Avvisi

| Scorciatoia | Funzione |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Mostra l'ora come notifica  |
| `Super + Ctrl + Alt + B` | Mostra la batteria come notifica  |
| `Super + Ctrl + Alt + W` | Attiva/disattiva il meteo come notifica  |

## Tmux

Il tasto prefisso è `Ctrl + Space` (funziona anche `Ctrl + B`). Puoi cambiare queste associazioni in `~/.config/tmux/tmux.conf`.

### Riquadri

| Scorciatoia | Funzione |
| ----------------------- | --------------------- |
| `Prefix + v` | Dividi il riquadro a fianco (verticale) |
| `Prefix + h` | Dividi il riquadro sotto (orizzontale) |
| `Prefix + x` | Termina il riquadro |
| `Prefix + z` | Attiva/disattiva lo zoom del riquadro (schermo intero) |
| `Alt + Enter` | Dividi il riquadro sotto (senza prefisso) |
| `Alt + Shift + Enter` | Dividi il riquadro a fianco (senza prefisso) |
| `Alt + Escape` | Termina il riquadro (senza prefisso) |
| `Ctrl + Alt + Arrows` | Spostati tra i riquadri |
| `Ctrl + Alt + Shift + Arrows` | Ridimensiona i riquadri |

### Finestre

| Scorciatoia | Funzione |
| ----------------------- | --------------------- |
| `Prefix + c` | Nuova finestra |
| `Prefix + k` | Termina la finestra |
| `Prefix + r` | Rinomina la finestra |
| `Alt + 1-9` | Vai a una finestra specifica |
| `Alt + Arrow Left/Right` | Spostati tra le finestre |
| `Alt + Shift + Arrow Left/Right` | Sposta la finestra a sinistra/destra |

### Sessioni

| Scorciatoia | Funzione |
| ----------------------- | --------------------- |
| `Prefix + C` | Nuova sessione |
| `Prefix + K` | Termina la sessione |
| `Prefix + R` | Rinomina la sessione |
| `Prefix + N` | Sessione successiva |
| `Prefix + P` | Sessione precedente |
| `Alt + Arrow Up/Down` | Spostati tra le sessioni |
| `Prefix + s` | Elenca le sessioni |
| `Prefix + d` | Distaccati dalla sessione |

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
| `Prefix + ?` | Mostra le associazioni di tasti di Tmux |
| `Prefix + :` | Prompt dei comandi |

### Funzioni di layout di Tmux

Queste funzioni devono essere eseguite dentro una sessione Tmux.

| Comando | Funzione |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Crea un layout di sviluppo con editor, AI e terminale |
| `tdlm <ai> [<second_ai>]` | Crea un layout di sviluppo per sottodirectory |
| `tsl <count> <command>` | Crea un layout swarm multi-riquadro |

## Terminale Ghostty

Il terminale Ghostty si installa usando _Installa > Terminale_ tramite il menu Omarchy.

| Scorciatoia | Funzione |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Nuova divisione sotto |
| `Ctrl + Shift + O` | Nuova divisione a fianco |
| `Ctrl + Alt + Arrows` | Spostati tra le divisioni |
| `Super + Ctrl + Shift + Arrows` | Ridimensiona la divisione di 10 righe |
| `Super + Ctrl + Shift + Alt + Arrows` | Ridimensiona la divisione di 100 righe |
| `Ctrl + Shift + T` | Nuova scheda  |
| `Ctrl + Shift + Arrows` | Spostati tra le schede |
| `Alt + Numbers` | Vai a una scheda specifica |
| `Shift + Pg Up/Down` | Scorri la cronologia |
| `Ctrl + Left mouse` | Apri il link nel browser |

## Gestore dei file

| Scorciatoia | Funzione |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Vai al percorso                     |
| `Space`               | Anteprima del file (le frecce navigano) |
| `Alt + Up`       | Vai su alla cartella superiore        |

## Neovim (con lazyvim)

### Navigazione

| Scorciatoia | Funzione |
| ------------------------ | ------------------------------- |
| `Space`                    | Mostra le opzioni dei comandi            |
| `Space Space`              | Apri un file tramite ricerca fuzzy      |
| `Space E`                  | Attiva/disattiva la barra laterale                  |
| `Space G G`                | Mostra i controlli git               |
| `Space S G`                | Cerca nel contenuto dei file             |
| `Ctrl + W W`               | Salta tra la barra laterale e l'editor |
| `Ctrl + Left/right arrow`  | Cambia la dimensione della barra laterale          |
| `Shift + H`                      | Vai alla scheda file di sinistra             |
| `Shift + L`                      | Vai alla scheda file di destra            |
| `Space B D`                | Chiudi la scheda file                  |

### Mentre sei nella barra laterale

| Scorciatoia | Funzione |
| ------------------------ | ------------------------------- |
| `A`                        | Aggiungi un nuovo file nella directory superiore      |
| `Shift + A`                | Aggiungi una nuova sottodirectory nella directory superiore    |
| `D`                        | Elimina il file/la directory evidenziati     |
| `M`                        | Sposta il file/la directory evidenziati       |
| `R`                        | Rinomina il file/la directory evidenziati     |
| `?`                        | Mostra l'aiuto per tutti i comandi      |

[Vedi tutte le scorciatoie di Neovim configurate da LazyVim](https://www.lazyvim.org/keymaps).

## Emoji rapide

Puoi usare `Super + Ctrl + E` per mostrare un selettore emoji completo che metterà la selezione negli appunti, oppure puoi usare queste opzioni di accesso rapido.

| Scorciatoia | EM | Indizio |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | sorriso      |
| `Shift + CapsLock M C` | 😂 | pianto        |
| `Shift + CapsLock M L` | 😍 | amore       |
| `Shift + CapsLock M V` | ✌️ | vittoria    |
| `Shift + CapsLock M H` | ❤️ | cuore      |
| `Shift + CapsLock M Y` | 👍 | sì        |
| `Shift + CapsLock M N` | 👎 | no         |
| `Shift + CapsLock M F` | 🖕 | vaffanculo       |
| `Shift + CapsLock M W` | 🤞 | desiderio       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | bacio       |
| `Shift + CapsLock M E` | 🙄 | occhi al cielo    |
| `Shift + CapsLock M I` | 😉 | occhiolino       |
| `Shift + CapsLock M P` | 🙏 | preghiera |
| `Shift + CapsLock M D` | 🤤 | sbavare      |
| `Shift + CapsLock M M` | 💰 | soldi      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | brindisi      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | saluto |
| `Shift + CapsLock M A` |💪 | braccio |
| `Shift + CapsLock M B` |🤯 | esplosione |

## Completamenti rapidi

| Scorciatoia | Completamento |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | Il tuo nome (come inserito durante la configurazione)  |
| `Shift + CapsLock Space E` | La tua email (come inserita durante la configurazione)  |

Puoi aggiungerne altri tuoi modificando `~/.XCompose`, poi eseguendo `omarchy restart xcompose` nel terminale perché le modifiche vengano rilevate.
