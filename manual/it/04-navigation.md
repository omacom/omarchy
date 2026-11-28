# Navigazione

Tutto in Omarchy avviene tramite la tastiera — _TUTTO!_ Quando il sistema si avvia per la prima volta, con il solo mouse non riesci letteralmente a fare nulla. Ma puoi premere `Super + Space` per aprire il menu di Omarchy e da lì puoi fare praticamente tutto.

Ma il menu di Omarchy non è nemmeno pensato per essere il modo principale di usare il sistema per la maggior parte del tempo. Possiamo fare ancora più in fretta! Tutte le applicazioni più importanti sono associate direttamente a singole scorciatoie. Avvii il terminale con `Super + Return` e un browser con `Super + Shift + Return`. Prova a farlo uno dopo l'altro e vedrai in azione la magia dell'affiancamento di Hyprland:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Puoi poi premere `Super + J` per impilarle una sopra l'altra invece che affiancate:

 ![navigation-stacked](images/navigation-stacked.webp)

Premi di nuovo `Super + J` per riportarle affiancate. Poi prova `Super + Shift + Arrow Right` mentre sei nel browser per scambiare le finestre.

Ora prova `Super + Shift + T` per avviare il monitor delle attività. Comparirà come finestra fluttuante, con una barra del titolo da cui trascinarla e pulsanti per ridurla a icona, ingrandirla e chiuderla. Ogni finestra fluttuante ne ha una, ovunque si trovi. Puoi affiancarla con `Super + T` (e premere di nuovo per renderla di nuovo fluttuante). Ora premi `Super + Shift + F` per aprire il file manager. Avrai una bella configurazione a quattro:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Ti sposti tra le finestre per attivare quella che vuoi con `Super + Arrow`. Questo cambierà il focus e sposterà il cursore al centro della nuova applicazione. Al bordo di uno schermo, prosegue sul monitor su quel lato.

Se premi `Super + Shift + 2`, sposterai l'applicazione attualmente attiva sulla seconda area di lavoro. `Super + Shift + 1` la riporta indietro. (E `Super + Shift + Alt + 2` sposterà l'applicazione attualmente attiva sulla seconda area di lavoro senza passare a essa).

Con più di un monitor, ogni monitor ha le proprie aree di lavoro da 1 a 10. `Super + 2` va alla seconda area di lavoro del monitor su cui ti trovi e la barra superiore di ogni monitor mostra le proprie aree di lavoro e quella che sta visualizzando. `Super + Tab` scorre le aree di lavoro sul monitor su cui ti trovi. `Super + Shift + Ctrl + Arrows` sposta la finestra su cui ti trovi sul monitor in quella direzione, sull'area di lavoro che sta mostrando, e `Super + Shift + Alt + Arrows` sposta l'area di lavoro su cui ti trovi sul monitor in quella direzione, dove assume lo stesso numero se è libero. Un monitor conserva le sue aree di lavoro quando lo scolleghi: si uniscono a quelle di un altro schermo, numerate dopo quelle che ha già, e tornano ai vecchi numeri quando il monitor ritorna.

Se tieni premuto `Super` e usi il mouse per fare clic su una finestra, potrai riorganizzarne la posizione. Se tieni premuto `Super` e usi il pulsante destro del mouse, puoi ridimensionare liberamente la finestra.

Chiudi una finestra con `Super + W` o `Super + Q` (e chiudi tutte le finestre con `Ctrl + Alt + Delete`).

Puoi anche passare a schermo intero con `Super + F` o persino solo a tutta larghezza (mantenendo la barra superiore) con `Super + Alt + F` oppure a schermo intero all'interno di una finestra con `Super + Ctrl + F` (ottimo per YouTube!).

### Layout dwindle vs a scorrimento

Il layout predefinito di Omarchy si chiama dwindle. Mantiene tutte le finestre che apri su una singola area di lavoro sempre visibili, anche se deve rimpicciolirle.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Ma puoi anche scegliere di trasformare un'area di lavoro nel layout a scorrimento, in cui le finestre sono allineate fianco a fianco, oltre il bordo visibile dello schermo. Trasformi una singola area di lavoro in questo layout con `Super + L`.

Premendo di nuovo `Super + L` l'area di lavoro diventa fluttuante, in cui le finestre si sovrappongono liberamente e le posizioni tu stesso, e una terza pressione la riporta a dwindle. `Super + Alt + L` le scorre nell'altro verso. Una finestra che è comunque fluttuante — una che hai estratto con `Super + T`, o un'app che si apre sempre fluttuante — resta fluttuante quando l'area di lavoro torna all'affiancamento. La barra superiore contrassegna l'area di lavoro su cui ti trovi con il suo layout: un quadrato per dwindle, un cerchio per lo scorrimento e un triangolo per fluttuante. Anche facendo clic su quel contrassegno si scorre il layout, e lo stesso fa il tasto display sui laptop che ne hanno uno.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

La scelta è per area di lavoro e rimane. Così puoi tenere l'area di lavoro 1 su dwindle per navigare e l'area di lavoro 2 a scorrimento per il codice, e torneranno così dopo un riavvio.

Se desideri usare il layout a scorrimento come predefinito, puoi impostarlo in `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Aree di lavoro fluttuanti

Un'area di lavoro fluttuante funziona come un desktop tradizionale: le finestre si sovrappongono e le sposti e ridimensioni tu stesso. Ogni finestra riceve una barra del titolo nei colori del tuo tema, con pulsanti per ridurre a icona, ingrandire e chiudere. Anche `Super + M` riduce a icona la finestra attiva. Una finestra ridotta a icona aspetta nel dock; fai clic sulla sua app per riportarla. Fai clic su una finestra per portarla in primo piano. Ridimensionala da qualsiasi bordo o angolo. Fai doppio clic su una barra del titolo per ingrandire la finestra mantenendo visibile la barra superiore, e di nuovo per ripristinarne le vecchie dimensioni. Chrome e gli altri browser basati su Chromium, Disks e Document Viewer saltano la barra del titolo e usano invece la propria intestazione; `Super + Alt + F` li ingrandisce e `Super + M` li riduce a icona.

Ogni area di lavoro ha un dock, con le tue app bloccate, tutto ciò che è in esecuzione e una griglia di ogni app dietro il pulsante delle app, che anche `Super + Alt + Space` e _App_ nel menu di Omarchy aprono. Fai clic con il pulsante destro su un'app nella griglia, o premi `Delete`, per disinstallarla. Fai clic su un'app per aprirla o per portare in primo piano la sua finestra; fai di nuovo clic per scorrere le sue finestre. Files riporta solo una finestra dall'area di lavoro su cui ti trovi e altrimenti ne apre una nuova, e Terminal e Agent ne avviano sempre un'altra, anche se prima torna una finestra ridotta a icona. Il clic centrale apre una nuova finestra. Trascina un'icona lungo il dock per spostarla; trascinare un'app in esecuzione in mezzo alle altre la mantiene lì. Fai clic con il pulsante destro per mantenere un'app nel dock, toglierla o chiuderla. Il dock resta visibile mentre un'area di lavoro è vuota e, una volta che l'area di lavoro ha una finestra, si nasconde finché il puntatore non raggiunge il suo bordo. Una finestra a schermo intero lo nasconde del tutto. Trascina il pulsante delle app verso un altro bordo dello schermo per spostare lì il dock. Fai clic con il pulsante destro su di esso per _Posizione_, per scegliere un bordo, e _Layout_, per impostare il layout predefinito come fa _Aspetto > Layout area di lavoro_. La posizione si trova anche in _Aspetto > Dock > Posizione del dock_ e `omarchy dock position left` la imposta da un terminale. Le app che mantieni nel dock sono sbiadite mentre non sono in esecuzione. Per limitare il dock alle aree di lavoro fluttuanti, usa _Aspetto > Dock > Dock solo su fluttuanti_ o `omarchy dock tiling off`.

Le nuove aree di lavoro, e qualsiasi area a cui non hai assegnato un layout proprio con `Super + L`, usano il layout predefinito. Cambiare il predefinito lo applica a ogni area di lavoro senza finestre, mentre una con finestre mantiene il layout che ha. Una finestra ridotta a icona nel dock conta ancora come finestra sull'area di lavoro che ha lasciato. Sceglilo in _Aspetto > Layout area di lavoro_: Affiancamento, Scorrimento o Fluttuante. `omarchy hyprland workspace layout default scrolling` lo imposta da un terminale.

### Raggruppare le finestre

Le finestre possono essere raggruppate con `Super + G`. Una volta che sei in un gruppo, ogni finestra che avvii mentre è attivo apparterrà al gruppo. Puoi spostarti tra queste finestre raggruppate con `Super + Ctrl + Arrow Left/Right` o `Super + Alt + 1/2/3/4` per andare direttamente alle finestre raggruppate in ordine.

Puoi spostare una finestra fuori dal raggruppamento con `Super + Alt + G` o smontare l'intero gruppo premendo di nuovo `Super + G`. Infine, puoi spostare nel gruppo finestre che ne sono fuori con `Super + Alt + Arrows`.

### Estrarre le finestre

Puoi estrarre una finestra dalla sua assegnazione all'area di lavoro con `Super + O`. Questo la fisserà come finestra fluttuante che ti segue in qualsiasi area di lavoro tu vada. Ottimo per i lettori video e simili.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Area di lavoro scratchpad

C'è una speciale area di lavoro scratchpad a dimensione intera che si sovrappone a qualsiasi area di lavoro su cui ti trovi attualmente. Accedi a ciò che contiene con `Super + S` e posizioni lì le finestre con `Super + Alt + S`.

Funziona bene per controlli o un terminale con cui vuoi interagire rapidamente senza lasciare l'area di lavoro corrente.

### Console Quake

Infine, c'è una console Quake a mezza altezza che scende sopra qualsiasi area di lavoro su cui ti trovi attualmente. Attivala e disattivala con `Super + the key above Tab` (l'accento grave sui layout US) e posiziona lì una finestra con `Super + Shift + the key above Tab`.

La prima volta che si apre, avvia il tuo agent predefinito o ti chiede di sceglierne uno se non ne hai ancora scelto uno. Mentre la console contiene una singola finestra, scende come pannello centrato invece di estendersi su tutto lo schermo. Mettici una seconda app e torna a tutta larghezza, così le due hanno spazio per stare affiancate.

Per spostare una finestra fuori dallo scratchpad o dalla console, inviala direttamente a un'altra area di lavoro con qualcosa come `Super + Shift + 1`.

### Bisogna farci l'abitudine!

Ci vuole un po' per abituarsi a navigare il desktop in questo modo, ma una volta che ci riesci, sarà difficile tornare a un'esperienza desktop tradizionale guidata dal mouse!
