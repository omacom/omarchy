# Navigazione

Tutto in Omarchy avviene tramite la tastiera — _TUTTO!_ Quando il sistema si avvia per la prima volta, letteralmente non puoi fare nulla con il solo mouse. Ma puoi premere `Super + Space` per aprire il Menu di Omarchy e da lì puoi fare praticamente tutto.

Ma il menu di Omarchy non è nemmeno pensato per essere il modo principale di usare il sistema la maggior parte del tempo. Possiamo fare più in fretta! Tutte le applicazioni più importanti sono assegnate direttamente a singoli tasti di scelta rapida. Avvii il terminale con `Super + Return` e un browser con `Super + Shift + Return`. Prova a farlo uno dopo l'altro e vedrai la magia del tiling di Hyprland in azione:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Puoi poi premere `Super + J` per impilarle una sopra l'altra invece che affiancate:

 ![navigation-stacked](images/navigation-stacked.webp)

Premi di nuovo `Super + J` per riportarle nelle loro posizioni affiancate. Poi prova `Super + Shift + Arrow Right` mentre sei sul browser per scambiare le finestre.

Ora prova `Super + Ctrl + T` per avviare il monitor delle attività. Apparirà come una finestra fluttuante. Puoi affiancarla usando `Super + T` (e premilo di nuovo per renderla di nuovo fluttuante). Ora premi `Super + Shift + F` per aprire il gestore dei file. Avrai una bella disposizione a quattro:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Ti sposti tra le finestre per scegliere quella che vuoi rendere attiva con `Super + Arrow`. Questo cambierà il focus e sposterà il cursore al centro della nuova applicazione.

Se premi `Super + Shift + 2`, sposterai l'applicazione attualmente attiva sul secondo workspace. `Super + Shift + 1` la riporta indietro. (E `Super + Shift + Alt + 2` sposterà l'applicazione attualmente attiva sul secondo workspace senza passare a esso).

Se tieni premuto `Super` e usi il mouse per fare clic su una finestra, potrai riorganizzare la sua posizione. Se tieni premuto `Super` e usi il pulsante destro del mouse, puoi ridimensionare liberamente la finestra.

Chiudi una finestra con `Super + W` o `Super + Q` (e chiudi tutte le finestre con `Ctrl + Alt + Delete`).

Puoi anche andare a schermo intero con `Super + F` o persino solo a tutta larghezza (mantenendo la barra superiore) con `Super + Alt + F` o a schermo intero all'interno di una finestra con `Super + Ctrl + F` (ottimo per YouTube!).

### Dwindle vs layout scorrevole

Il layout predefinito di Omarchy si chiama dwindle. Mantiene tutte le finestre che apri su un singolo workspace sempre visibili, anche se deve rimpicciolirle.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Ma puoi anche scegliere di trasformare un workspace nel layout scorrevole, in cui le finestre sono allineate una accanto all'altra, oltre il bordo visibile dello schermo. Trasformi un singolo workspace in questo layout tramite `Super + L`.

Premendo di nuovo `Super + L` il workspace diventa fluttuante, in cui le finestre si sovrappongono liberamente e le posizioni tu, e una terza pressione lo riporta a dwindle. `Super + Alt + L` li percorre nell'altro senso. Una finestra che è comunque fluttuante — una che hai estratto con `Super + T`, o un'app che si apre sempre fluttuante — resta fluttuante quando il workspace torna al tiling. La barra superiore contrassegna il workspace su cui ti trovi con il suo layout: un quadrato per dwindle, un cerchio per lo scorrevole e un triangolo per il fluttuante. Anche fare clic su quel segno fa scorrere i layout.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

La scelta è per workspace, e rimane. Così puoi tenere il workspace 1 su dwindle per navigare e il workspace 2 sullo scorrevole per il codice, e torneranno così dopo un riavvio.

Se desideri usare il layout scorrevole come predefinito, puoi impostarlo in `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Workspace fluttuanti

Un workspace fluttuante funziona come un desktop tradizionale: le finestre si sovrappongono, e le sposti e le dimensioni tu. Ogni finestra riceve una barra del titolo nei colori del tuo tema, con pulsanti per minimizzare, massimizzare e chiudere. Anche `Super + M` minimizza la finestra attiva. Una finestra minimizzata aspetta nel dock; fai clic sulla sua app per riportarla. Fai clic su una finestra per portarla in primo piano. Ridimensionala da qualsiasi bordo o angolo. Fai doppio clic su una barra del titolo per massimizzare la finestra mantenendo visibile la barra superiore, e di nuovo per riottenere le sue vecchie dimensioni.

Un workspace fluttuante mostra anche un dock, con le tue app fissate, tutto ciò che è in esecuzione e una griglia di ogni app dietro il pulsante delle app, che aprono anche `Super + Alt + Space` e _Apps_ nel menu di Omarchy. Fai clic con il pulsante destro su un'app nella griglia, o premi `Delete`, per disinstallarla. Fai clic su un'app per aprirla, o per portare in primo piano la sua finestra; fai di nuovo clic per scorrere le sue finestre. Il clic centrale apre una nuova finestra. Trascina un'icona lungo il dock per spostarla; trascinare un'app in esecuzione in mezzo alle altre la mantiene lì. Fai clic con il pulsante destro per mantenere un'app nel dock, toglierla o chiuderla. Il dock si toglie di mezzo davanti a una finestra a schermo intero. Fai clic con il pulsante destro sul pulsante delle app per spostare il dock su un altro bordo o farlo nascondere finché il puntatore non raggiunge il suo bordo. La posizione si trova anche in _Trigger > Appearance > Dock > Dock Position_, e `omarchy dock position left` e `omarchy dock autohide on` impostano entrambe le cose da un terminale. Le app che mantieni nel dock sono sbiadite mentre non sono in esecuzione.

I nuovi workspace, e tutti quelli a cui non hai dato un layout proprio con `Super + L`, usano il layout predefinito. Cambiare il predefinito reimposta su di esso ogni workspace senza finestre, mentre uno con finestre su di esso mantiene il layout che ha. Una finestra minimizzata nel dock conta ancora come una finestra sul workspace che ha lasciato. Sceglilo in _Trigger > Appearance > Workspace Layout_: Tiling, Scrolling o Floating. `omarchy-hyprland-workspace-layout-default scrolling` lo imposta da un terminale.

### Raggruppare le finestre

Le finestre possono essere raggruppate usando `Super + G`. Una volta che sei in un gruppo, ogni finestra che avvii mentre è attivo apparterrà al gruppo. Puoi spostarti tra queste finestre raggruppate usando `Super + Ctrl + Arrow Left/Right` o `Super + Alt + 1/2/3/4` per andare direttamente alla finestra raggruppata in ordine.

Puoi spostare una finestra fuori dal raggruppamento con `Super + Alt + G` o smontare l'intero gruppo premendo di nuovo `Super + G`. Infine, puoi spostare le finestre fuori dal gruppo al suo interno con `Super + Alt + Arrows`.

### Estrarre le finestre

Puoi estrarre una finestra dalla sua assegnazione al workspace con `Super + O`. Questo la fisserà come una finestra fluttuante che ti segue in qualsiasi workspace tu vada. Ottimo per i riproduttori video e simili.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Workspace scratchpad

Infine, c'è uno speciale workspace scratchpad che scende sopra qualsiasi workspace su cui ti trovi attualmente, proprio come una console di Quake. Attivalo e disattivalo con `Super + Grave` o `Super + S`, e posiziona lì una finestra usando `Super + Shift + Grave` o `Super + Alt + S`.

Funziona particolarmente bene per un terminale che esegue un agent, o per controlli con cui vuoi interagire rapidamente senza lasciare il workspace attuale. Per spostare una finestra fuori dallo scratchpad, inviala direttamente a un altro workspace con qualcosa come `Super + Shift + 1`.

Mentre lo scratchpad contiene una singola finestra, scende come un pannello centrato invece di estendersi su tutto lo schermo. Mettici una seconda app e torna a tutta larghezza, così le due hanno spazio per stare affiancate.

### Ci vuole un po' per abituarsi!

Ci vuole un po' di tempo per abituarsi a navigare sul desktop in questo modo, ma una volta che lo fai, sarà difficile tornare a un'esperienza desktop tradizionale guidata dal mouse!
