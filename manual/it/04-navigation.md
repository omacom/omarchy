# Navigazione

In Omarchy tutto avviene tramite la tastiera — _TUTTO!_ Quando il sistema si avvia per la prima volta, letteralmente non puoi fare nulla con il solo mouse. Ma puoi premere `Super + Space` per far apparire il Menu di Omarchy e da qui puoi fare praticamente tutto.

Ma il menu di Omarchy non è nemmeno pensato per essere il modo principale di usare il sistema per la maggior parte del tempo. Possiamo essere più veloci di così! Tutte le applicazioni più importanti sono associate direttamente a singole scorciatoie da tastiera. Avvii il terminale con `Super + Return` e un browser con `Super + Shift + Return`. Prova a farlo uno dopo l'altro, e vedrai la magia del tiling di Hyprland in azione:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Poi puoi premere `Super + J` per impilarle una sopra l'altra invece che fianco a fianco:

 ![navigation-stacked](images/navigation-stacked.webp)

Premi di nuovo `Super + J` per riportarle nelle loro posizioni fianco a fianco. Poi prova `Super + Shift + Arrow Right` mentre sei nel browser per scambiare le finestre.

Ora prova `Super + Shift + T` per avviare il monitor Activity. Apparirà come una finestra fluttuante. Puoi affiancarla usando `Super + T` (e premilo di nuovo per renderla di nuovo fluttuante). Ora premi `Super + Shift + F` per aprire il gestore dei file. Avrai una bella configurazione a quattro vie:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Ti sposti tra le finestre per scegliere quella da rendere attiva con `Super + Arrow`. Questo cambierà il focus e sposterà il cursore al centro della nuova applicazione. Al bordo di uno schermo, prosegue sul monitor su quel lato.

Se premi `Super + Shift + 2`, sposterai l'applicazione attualmente attiva sul secondo workspace. `Super + Shift + 1` la riporta indietro. (E `Super + Shift + Alt + 2` sposterà l'applicazione attualmente attiva sul secondo workspace senza passare ad esso).

Con più di un monitor, ogni monitor ha i propri workspace da 1 a 10. `Super + 2` va al secondo workspace del monitor su cui ti trovi, e la barra superiore di ogni monitor mostra i suoi workspace e quello che sta visualizzando. `Super + Tab` scorre ciclicamente i workspace del monitor su cui ti trovi. `Super + Shift + Ctrl + Arrows` sposta la finestra su cui ti trovi sul monitor in quella direzione, sul workspace che sta visualizzando, e `Super + Shift + Alt + Arrows` sposta il workspace su cui ti trovi sul monitor in quella direzione, dove assume lo stesso numero se è libero. Un monitor conserva i suoi workspace quando lo scolleghi: si uniscono a quelli di un altro schermo, numerati dopo quelli che ha già, e tornano ai loro vecchi numeri quando il monitor ritorna.

Se tieni premuto `Super` e usi il mouse per fare clic su una finestra, potrai riorganizzare dove si trova. Se tieni premuto `Super` e usi il pulsante destro del mouse, puoi ridimensionare liberamente la finestra.

Chiudi una finestra con `Super + W` o `Super + Q` (e chiudi tutte le finestre con `Ctrl + Alt + Delete`).

Puoi anche passare a schermo intero con `Super + F` o anche solo a larghezza intera (mantenendo la barra superiore) con `Super + Alt + F` o a schermo intero all'interno di una finestra con `Super + Ctrl + F` (ottimo per YouTube!).

### Layout dwindle vs scrolling

Il layout predefinito di Omarchy si chiama dwindle. Mantiene tutte le finestre che apri su un singolo workspace sempre visibili, anche se deve rimpicciolirle.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Ma puoi anche scegliere di trasformare un workspace nel layout scrolling, in cui le finestre sono allineate fianco a fianco, oltre il bordo visibile dello schermo. Trasformi un singolo workspace in questo layout tramite `Super + L`.

Premere di nuovo `Super + L` rende il workspace fluttuante, in cui le finestre si sovrappongono liberamente e le collochi tu stesso, e una terza pressione lo riporta a dwindle. `Super + Alt + L` li scorre nell'altro verso. Una finestra che è comunque fluttuante — una che hai estratto con `Super + T`, o un'app che si apre sempre fluttuante — rimane fluttuante quando il workspace torna al tiling. La barra superiore contrassegna il workspace su cui ti trovi con il suo layout: un quadrato per dwindle, un cerchio per scrolling e un triangolo per fluttuante. Anche fare clic su quel contrassegno scorre ciclicamente il layout.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

La scelta è per workspace, e rimane. Così puoi tenere il workspace 1 su dwindle per la navigazione web e il workspace 2 su scrolling per il codice, e torneranno così dopo un riavvio.

Se desideri usare il layout scrolling come predefinito, puoi impostarlo in `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Workspace fluttuanti

Un workspace fluttuante funziona come un desktop tradizionale: le finestre si sovrappongono, e le sposti e le ridimensioni tu stesso. Ogni finestra riceve una barra del titolo nei colori del tuo tema, con pulsanti per minimizzare, massimizzare e chiudere. Anche `Super + M` minimizza la finestra attiva. Una finestra minimizzata aspetta nel dock; fai clic sulla sua app per riportarla indietro. Fai clic su una finestra per portarla in primo piano. Ridimensionala da qualsiasi bordo o angolo. Fai doppio clic su una barra del titolo per massimizzare la finestra mantenendo visibile la barra superiore, e di nuovo per ripristinare le sue vecchie dimensioni. Chrome e altri browser basati su Chromium, Disks e Document Viewer saltano la barra del titolo e usano invece la propria intestazione; `Super + Alt + F` li massimizza, e `Super + M` li minimizza.

Un workspace fluttuante mostra anche un dock, con le tue app bloccate, tutto ciò che è in esecuzione e una griglia di tutte le app dietro il pulsante delle app, che anche `Super + Alt + Space` e _Apps_ nel menu di Omarchy aprono. Fai clic con il pulsante destro su un'app nella griglia, o premi `Delete`, per disinstallarla. Fai clic su un'app per aprirla, o per portare in primo piano la sua finestra; fai di nuovo clic per scorrere ciclicamente le sue finestre. Il clic con il pulsante centrale apre una nuova finestra. Trascina un'icona lungo il dock per spostarla; trascinare un'app in esecuzione tra le altre la mantiene lì. Fai clic con il pulsante destro per mantenere un'app nel dock, rimuoverla o chiuderla. Il dock si toglie di mezzo davanti a una finestra a schermo intero. Fai clic con il pulsante destro sul pulsante delle app per spostare il dock su un altro bordo o farlo nascondere finché il puntatore non raggiunge il suo bordo. La posizione si trova anche in _Appearance > Dock > Dock Position_, e `omarchy dock position left` e `omarchy dock autohide on` impostano entrambe le cose da un terminale. Le app che mantieni nel dock sono sbiadite mentre non sono in esecuzione.

I nuovi workspace, e tutti quelli a cui non hai assegnato un layout proprio con `Super + L`, usano il layout predefinito. Cambiare il layout predefinito lo reimposta per tutti i workspace senza finestre, mentre uno con finestre sopra mantiene il layout che ha. Una finestra minimizzata nel dock conta ancora come una finestra sul workspace che ha lasciato. Sceglilo in _Appearance > Workspace Layout_: Tiling, Scrolling o Floating. `omarchy-hyprland-workspace-layout-default scrolling` lo imposta da un terminale.

### Raggruppare le finestre

Le finestre possono essere raggruppate usando `Super + G`. Una volta che sei in un gruppo, ogni finestra che avvii mentre è attivo apparterrà al gruppo. Puoi spostarti tra queste finestre raggruppate usando `Super + Ctrl + Arrow Left/Right` o `Super + Alt + 1/2/3/4` per andare direttamente alle finestre raggruppate in ordine.

Puoi spostare una finestra fuori dal gruppo con `Super + Alt + G` o smontare l'intero gruppo premendo di nuovo `Super + G`. Infine, puoi spostare dentro il gruppo finestre che ne sono fuori con `Super + Alt + Arrows`.

### Estrarre le finestre

Puoi estrarre una finestra dalla sua assegnazione al workspace con `Super + O`. La bloccherà così come finestra fluttuante che ti segue su qualsiasi workspace tu vada. Ottimo per i lettori video e simili.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Workspace scratchpad

Esiste uno speciale workspace scratchpad a dimensione intera che si sovrappone a qualsiasi workspace su cui ti trovi al momento. Accedi a ciò che contiene usando `Super + S`, e collochi lì le finestre usando `Super + Alt + S`.

Funziona bene per controlli o un terminale con cui vuoi interagire rapidamente senza lasciare il workspace corrente.

### Console Quake

Infine, c'è una console Quake a mezza altezza che scende sopra qualsiasi workspace su cui ti trovi al momento. Attivala e disattivala con `Super + Grave`, e collocha lì una finestra usando `Super + Shift + Grave`.

Si apre con il tuo agent predefinito pronto all'uso. Mentre la console contiene una singola finestra, scende come un pannello centrato invece di estendersi su tutto lo schermo. Metti una seconda app su di essa e torna a larghezza intera, così le due hanno spazio per stare fianco a fianco.

Per spostare una finestra fuori dallo scratchpad o dalla console, inviala direttamente a un altro workspace con qualcosa come `Super + Shift + 1`.

### Ci vuole un po' per abituarsi!

Ci vuole un po' di tempo per abituarsi a navigare il desktop in questo modo, ma una volta che lo fai, sarà difficile tornare a un'esperienza desktop tradizionale guidata dal mouse!
