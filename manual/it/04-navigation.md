# Navigazione

Tutto in Omarchy avviene tramite la tastiera — _TUTTO!_ Quando il sistema si avvia per la prima volta, letteralmente non puoi fare nulla con il solo mouse. Ma puoi premere `Super + Space` per mostrare il Menu Omarchy e da qui puoi fare praticamente tutto.

Ma il menu Omarchy non è nemmeno pensato per essere il modo principale di usare il sistema per la maggior parte del tempo. Possiamo andare più veloci di così! Tutte le applicazioni più importanti sono associate direttamente a singole scorciatoie. Avvii il terminale con `Super + Return` e un browser con `Super + Shift + Return`. Prova a fare l'una dopo l'altra, e vedrai la magia dell'affiancamento di Hyprland in azione:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Puoi poi premere `Super + J` per impilarle una sopra l'altra invece che affiancate:

 ![navigation-stacked](images/navigation-stacked.webp)

Premi di nuovo `Super + J` per riportarle nelle loro posizioni affiancate. Poi prova `Super + Shift + Arrow Right` mentre sei sul browser per scambiare le finestre.

Ora prova `Super + Shift + T` per avviare il monitor Attività. Apparirà come una finestra fluttuante. Puoi affiancarla usando `Super + T` (e premilo di nuovo per renderla di nuovo fluttuante). Ora premi `Super + Shift + F` per aprire il gestore dei file. Avrai una bella configurazione a quattro:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Ti sposti tra le finestre per scegliere quella attiva con `Super + Arrow`. Questo cambierà il focus e sposterà il cursore al centro della nuova applicazione. Al bordo di uno schermo, continua sul monitor su quel lato.

Se premi `Super + Shift + 2`, sposterai l'applicazione attualmente attiva sul secondo spazio di lavoro. `Super + Shift + 1` la riporta indietro. (E `Super + Shift + Alt + 2` sposterà l'applicazione attualmente attiva sul secondo spazio di lavoro senza passare a esso).

Con più di un monitor, ogni monitor ha i propri spazi di lavoro da 1 a 10. `Super + 2` va al secondo spazio di lavoro del monitor su cui ti trovi, e la barra superiore di ogni monitor mostra i propri spazi di lavoro e quello che sta visualizzando. `Super + Tab` scorre gli spazi di lavoro sul monitor su cui ti trovi. `Super + Shift + Ctrl + Arrows` sposta la finestra su cui ti trovi sul monitor in quella direzione, sullo spazio di lavoro che sta visualizzando, e `Super + Shift + Alt + Arrows` sposta lo spazio di lavoro su cui ti trovi sul monitor in quella direzione, dove prende lo stesso numero se è libero. Un monitor conserva i suoi spazi di lavoro quando lo scolleghi: si uniscono a quelli di un altro schermo, numerati dopo quelli che ha già, e tornano ai loro vecchi numeri quando il monitor ritorna.

Se tieni premuto `Super` e usi il mouse per fare clic su una finestra, potrai riorganizzare dove si trova. Se tieni premuto `Super` e usi il pulsante destro del mouse, puoi ridimensionare liberamente la finestra.

Chiudi una finestra con `Super + W` o `Super + Q` (e chiudi tutte le finestre con `Ctrl + Alt + Delete`).

Puoi anche andare a schermo intero con `Super + F` o anche solo a tutta larghezza (mantenendo la barra superiore) con `Super + Alt + F` o a schermo intero all'interno di una finestra con `Super + Ctrl + F` (ideale per YouTube!).

### Dwindle vs layout a scorrimento

Il layout predefinito di Omarchy si chiama dwindle. Mantiene tutte le finestre che apri su un singolo spazio di lavoro visibili in ogni momento, anche se deve ridurle.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Ma puoi anche scegliere di trasformare uno spazio di lavoro nel layout a scorrimento, dove le finestre sono allineate affiancate, oltre il bordo visibile dello schermo. Trasformi un singolo spazio di lavoro in questo layout tramite `Super + L`.

Premendo di nuovo `Super + L` lo spazio di lavoro diventa fluttuante, dove le finestre si sovrappongono liberamente e le posizioni tu stesso, e una terza pressione lo riporta a dwindle. `Super + Alt + L` li scorre nell'altro verso. Una finestra che fluttua comunque — una che hai estratto con `Super + T`, o un'app che si apre sempre fluttuante — continua a fluttuare quando lo spazio di lavoro torna all'affiancamento. La barra superiore contrassegna lo spazio di lavoro su cui ti trovi con il suo layout: un quadrato per dwindle, un cerchio per lo scorrimento e un triangolo per fluttuante. Anche facendo clic su quel contrassegno si scorre il layout.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

La scelta è per spazio di lavoro, ed è persistente. Quindi puoi mantenere lo spazio di lavoro 1 su dwindle per la navigazione e lo spazio di lavoro 2 a scorrimento per il codice, e torneranno così dopo un riavvio.

Se desideri usare il layout a scorrimento come predefinito, puoi impostarlo in `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Spazi di lavoro fluttuanti

Uno spazio di lavoro fluttuante funziona come un desktop tradizionale: le finestre si sovrappongono, e le sposti e le ridimensioni tu stesso. Ogni finestra riceve una barra del titolo con i colori del tuo tema, con pulsanti per minimizzare, massimizzare e chiudere. Anche `Super + M` minimizza la finestra attiva. Una finestra minimizzata attende nel dock; fai clic sulla sua app per riportarla. Fai clic su una finestra per portarla in primo piano. Ridimensionala da qualsiasi bordo o angolo. Fai doppio clic su una barra del titolo per massimizzare la finestra mantenendo visibile la barra superiore, e di nuovo per ripristinare le sue vecchie dimensioni.

Uno spazio di lavoro fluttuante mostra anche un dock, con le tue app bloccate, tutto ciò che è in esecuzione e una griglia di ogni app dietro il pulsante delle app, che anche `Super + Alt + Space` e _Apps_ nel menu Omarchy aprono. Fai clic con il pulsante destro su un'app nella griglia, o premi `Delete`, per disinstallarla. Fai clic su un'app per aprirla, o per portare in primo piano la sua finestra; fai di nuovo clic per scorrere le sue finestre. Il clic centrale apre una nuova finestra. Trascina un'icona lungo il dock per spostarla; trascinare un'app in esecuzione tra le altre la mantiene lì. Fai clic con il pulsante destro per mantenere un'app nel dock, rimuoverla o chiuderla. Il dock si toglie di mezzo davanti a una finestra a schermo intero. Fai clic con il pulsante destro sul pulsante delle app per spostare il dock su un altro bordo o farlo nascondere finché il puntatore non raggiunge il suo bordo. La posizione si trova anche in _Aspetto > Dock > Posizione del Dock_, e `omarchy dock position left` e `omarchy dock autohide on` impostano entrambe le cose da un terminale. Le app che mantieni nel dock sono attenuate mentre non sono in esecuzione.

I nuovi spazi di lavoro, e quelli a cui non hai assegnato un layout proprio con `Super + L`, usano il layout predefinito. Cambiare il predefinito reimposta su di esso ogni spazio di lavoro senza finestre, mentre uno con finestre mantiene il layout che ha. Una finestra minimizzata nel dock conta ancora come una finestra sullo spazio di lavoro che ha lasciato. Lo scegli in _Aspetto > Layout dello spazio di lavoro_: Tiling, Scrolling o Floating. `omarchy-hyprland-workspace-layout-default scrolling` lo imposta da un terminale.

### Raggruppare le finestre

Le finestre possono essere raggruppate usando `Super + G`. Una volta che sei in un gruppo, ogni finestra che avvii mentre è attivo apparterrà al gruppo. Puoi spostarti tra queste finestre raggruppate usando `Super + Ctrl + Arrow Left/Right` o `Super + Alt + 1/2/3/4` per andare direttamente alla finestra raggruppata in ordine.

Puoi spostare una finestra fuori dal raggruppamento con `Super + Alt + G` o smontare l'intero gruppo premendo di nuovo `Super + G`. Infine, puoi spostare nel gruppo finestre che ne sono fuori con `Super + Alt + Arrows`.

### Estrarre le finestre

Puoi estrarre una finestra dalla sua assegnazione allo spazio di lavoro con `Super + O`. La bloccherà come una finestra fluttuante che ti segue su qualsiasi spazio di lavoro tu vada. Ottimo per i lettori video e simili.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Spazio di lavoro scratchpad

C'è uno speciale spazio di lavoro scratchpad a dimensione intera che si sovrappone a qualsiasi spazio di lavoro su cui ti trovi attualmente. Accedi a ciò che contiene usando `Super + S`, e vi posizioni le finestre usando `Super + Alt + S`.

Funziona bene per controlli o un terminale con cui vuoi interagire rapidamente senza lasciare lo spazio di lavoro corrente.

### Console Quake

Infine, c'è una console Quake a mezza altezza che scende sopra qualsiasi spazio di lavoro su cui ti trovi attualmente. La attivi e disattivi con `Super + Grave`, e vi posizioni una finestra usando `Super + Shift + Grave`.

Si apre con il tuo agente predefinito pronto all'uso. Mentre la console contiene una singola finestra, scende come un pannello centrato invece di estendersi su tutto lo schermo. Mettici una seconda app e torna alla larghezza intera, così le due hanno spazio per stare affiancate.

Per spostare una finestra fuori dallo scratchpad o dalla console, inviala direttamente a un altro spazio di lavoro con qualcosa come `Super + Shift + 1`.

### Ci vuole un po' per abituarsi!

Ci vuole un po' di tempo per abituarsi a navigare il desktop in questo modo, ma una volta che lo fai, sarà difficile tornare a un'esperienza desktop tradizionale guidata dal mouse!
