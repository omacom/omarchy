# Navigazione

In Omarchy tutto avviene tramite la tastiera — _TUTTO!_ Quando il sistema si avvia per la prima volta, letteralmente non puoi fare nulla con il solo mouse. Ma puoi premere `Super + Space` per aprire il Menu di Omarchy e da lì puoi fare praticamente tutto.

Ma il menu di Omarchy non è nemmeno pensato per essere il modo principale di usare il sistema per la maggior parte del tempo. Possiamo andare più veloci di così! Tutte le applicazioni più importanti sono associate direttamente a singole scorciatoie. Avvii il terminale con `Super + Return` e un browser con `Super + Shift + Return`. Prova a farlo uno dopo l'altro e vedrai la magia del tiling di Hyprland in azione:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Puoi quindi premere `Super + J` per impilarle una sopra l'altra invece che affiancate:

 ![navigation-stacked](images/navigation-stacked.webp)

Premi di nuovo `Super + J` per riportarle nelle loro posizioni affiancate. Poi prova `Super + Shift + Arrow Right` mentre sei nel browser per scambiare le finestre.

Ora prova `Super + Shift + T` per avviare il monitor Activity. Apparirà come una finestra flottante. Puoi inserirlo nel tiling con `Super + T` (e premilo di nuovo per renderlo di nuovo flottante). Ora premi `Super + Shift + F` per aprire il file manager. Otterrai una bella configurazione a quattro vie:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Ti sposti tra le finestre per attivare quella desiderata con `Super + Arrow`. Questo sposterà il focus e porterà il cursore al centro della nuova applicazione. Al bordo di uno schermo, passa al monitor su quel lato.

Se premi `Super + Shift + 2`, sposterai l'applicazione attualmente attiva sul secondo spazio di lavoro. `Super + Shift + 1` la riporta indietro. (E `Super + Shift + Alt + 2` sposterà l'applicazione attualmente attiva sul secondo spazio di lavoro senza passare a esso).

Con più di un monitor, ogni monitor ha i propri spazi di lavoro da 1 a 10. `Super + 2` va al secondo spazio di lavoro del monitor su cui ti trovi, e la barra superiore di ogni monitor mostra i propri spazi di lavoro e quello che sta visualizzando. `Super + Tab` scorre gli spazi di lavoro sul monitor su cui ti trovi. `Super + Shift + Ctrl + Arrows` sposta la finestra su cui ti trovi sul monitor in quella direzione, sullo spazio di lavoro che sta mostrando, e `Super + Shift + Alt + Arrows` sposta lo spazio di lavoro su cui ti trovi sul monitor in quella direzione, dove assume lo stesso numero se è libero. Un monitor conserva i suoi spazi di lavoro quando lo scolleghi: si uniscono a quelli di un altro schermo, numerati dopo quelli che ha già, e tornano ai loro vecchi numeri quando il monitor ritorna.

Se tieni premuto `Super` e usi il mouse per fare clic su una finestra, potrai riorganizzare la sua posizione. Se tieni premuto `Super` e usi il pulsante destro del mouse, puoi ridimensionare liberamente la finestra.

Chiudi una finestra con `Super + W` o `Super + Q` (e chiudi tutte le finestre con `Ctrl + Alt + Delete`).

Puoi anche passare a schermo intero con `Super + F` o anche solo a tutta larghezza (mantenendo la barra superiore) con `Super + Alt + F` o a schermo intero all'interno di una finestra con `Super + Ctrl + F` (ottimo per YouTube!).

### Layout dwindle vs layout a scorrimento

Il layout predefinito di Omarchy si chiama dwindle. Mantiene tutte le finestre che apri su un singolo spazio di lavoro sempre visibili, anche se deve ridurle.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Ma puoi anche scegliere di trasformare uno spazio di lavoro nel layout a scorrimento, in cui le finestre sono allineate affiancate, oltre il bordo visibile dello schermo. Trasformi un singolo spazio di lavoro in questo layout con `Super + L`.

Premere di nuovo `Super + L` rende lo spazio di lavoro flottante, in cui le finestre si sovrappongono liberamente e le posizioni tu stesso, e una terza pressione lo riporta a dwindle. `Super + Alt + L` li scorre nell'altro verso. Una finestra che è comunque flottante — una che hai estratto con `Super + T`, o un'app che si apre sempre flottante — resta flottante quando lo spazio di lavoro torna al tiling. La barra superiore contrassegna lo spazio di lavoro su cui ti trovi con il suo layout: un quadrato per dwindle, un cerchio per lo scorrimento e un triangolo per flottante. Anche facendo clic su quel contrassegno si scorre il layout, e lo fa anche il tasto display sui portatili che ne hanno uno.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

La scelta è per spazio di lavoro e resta attiva. Così puoi mantenere lo spazio di lavoro 1 su dwindle per la navigazione e lo spazio di lavoro 2 a scorrimento per il codice, e torneranno così dopo un riavvio.

Se desideri usare il layout a scorrimento come predefinito, puoi impostarlo in `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Spazi di lavoro flottanti

Uno spazio di lavoro flottante funziona come un desktop tradizionale: le finestre si sovrappongono e le sposti e ridimensioni tu stesso. Ogni finestra riceve una barra del titolo nei colori del tuo tema, con pulsanti per minimizzare, massimizzare e chiudere. Anche `Super + M` minimizza la finestra attiva. Una finestra minimizzata attende nel dock; fai clic sulla sua app per riportarla indietro. Fai clic su una finestra per portarla in primo piano. Ridimensionala da qualsiasi bordo o angolo. Fai doppio clic su una barra del titolo per massimizzare la finestra mantenendo visibile la barra superiore, e di nuovo per ripristinare le sue vecchie dimensioni. Chrome e altri browser basati su Chromium, Disks e Document Viewer saltano la barra del titolo e usano invece la propria intestazione; `Super + Alt + F` li massimizza e `Super + M` li minimizza.

Uno spazio di lavoro flottante mostra anche un dock, con le tue app fissate, tutto ciò che è in esecuzione e una griglia di ogni app dietro il pulsante delle app, che anche `Super + Alt + Space` e _Apps_ nel menu di Omarchy aprono. Fai clic con il pulsante destro su un'app nella griglia, o premi `Delete`, per disinstallarla. Fai clic su un'app per aprirla, o per portare in primo piano la sua finestra; fai di nuovo clic per scorrere le sue finestre. Files riporta indietro una finestra solo dallo spazio di lavoro su cui ti trovi e altrimenti ne apre una nuova, e Terminal e Agent ne avviano sempre un'altra, anche se una finestra minimizzata viene ripristinata per prima. Il clic centrale apre una nuova finestra. Trascina un'icona lungo il dock per spostarla; trascinare un'app in esecuzione tra le altre la mantiene lì. Fai clic con il pulsante destro per mantenere un'app nel dock, rimuoverla o chiuderla. Il dock si toglie di mezzo davanti a una finestra a schermo intero. Fai clic con il pulsante destro sul pulsante delle app per spostare il dock su un altro bordo o farlo nascondere finché il puntatore non raggiunge il suo bordo. La posizione si trova anche in _Appearance > Dock > Dock Position_, e `omarchy dock position left` e `omarchy dock autohide on` impostano entrambe le cose da un terminale. Le app che mantieni nel dock sono sbiadite mentre non sono in esecuzione.

I nuovi spazi di lavoro, e tutti quelli a cui non hai assegnato un layout proprio con `Super + L`, usano il layout predefinito. Cambiare il layout predefinito reimposta su di esso ogni spazio di lavoro senza finestre, mentre uno con finestre mantiene il layout che ha. Una finestra minimizzata nel dock conta ancora come una finestra sullo spazio di lavoro che ha lasciato. Sceglilo in _Appearance > Workspace Layout_: Tiling, Scrolling o Floating. `omarchy hyprland workspace layout default scrolling` lo imposta da un terminale.

### Raggruppare le finestre

Le finestre possono essere raggruppate con `Super + G`. Una volta che sei in un gruppo, ogni finestra che avvii mentre è attivo apparterrà al gruppo. Puoi spostarti tra queste finestre raggruppate con `Super + Ctrl + Arrow Left/Right` o `Super + Alt + 1/2/3/4` per andare direttamente alle finestre raggruppate in ordine.

Puoi spostare una finestra fuori dal raggruppamento con `Super + Alt + G` o smontare l'intero gruppo premendo di nuovo `Super + G`. Infine, puoi spostare le finestre fuori dal gruppo al suo interno con `Super + Alt + Arrows`.

### Estrarre le finestre

Puoi estrarre una finestra dalla sua assegnazione allo spazio di lavoro con `Super + O`. Questo la fisserà come una finestra flottante che ti segue in qualsiasi spazio di lavoro tu vada. Ottimo per i lettori video e simili.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Spazio di lavoro scratchpad

Esiste uno speciale spazio di lavoro scratchpad a dimensione intera che si sovrappone a qualsiasi spazio di lavoro tu stia usando. Accedi a ciò che contiene con `Super + S`, e collochi le finestre lì con `Super + Alt + S`.

Funziona bene per controlli o un terminale con cui vuoi interagire rapidamente senza lasciare lo spazio di lavoro corrente.

### Console Quake

Infine, c'è una console Quake a mezza altezza che scende sopra qualsiasi spazio di lavoro tu stia usando. Attivala e disattivala con `Super + the key above Tab` (accento grave sui layout US), e colloca una finestra lì con `Super + Shift + the key above Tab`.

La prima volta che si apre, avvia il tuo agent predefinito, o ti chiede di sceglierne uno se non ne hai ancora scelto uno. Mentre la console contiene una singola finestra, scende come un pannello centrato invece di estendersi su tutto lo schermo. Metti una seconda app su di essa e torna a tutta larghezza, così le due hanno spazio per stare affiancate.

Per spostare una finestra fuori dallo scratchpad o dalla console, inviala direttamente a un altro spazio di lavoro con qualcosa come `Super + Shift + 1`.

### Ci vuole un po' per abituarsi!

Ci vuole un po' di tempo per abituarsi a navigare il desktop in questo modo, ma una volta che lo fai, sarà difficile tornare a un'esperienza desktop tradizionale guidata dal mouse!
