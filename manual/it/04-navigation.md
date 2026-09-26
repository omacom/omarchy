<!-- upstream: omacom/omarchy@60663faf8764253646f1d6166e864b608d4a0fa1; sha256: ae64946aad2752f77980b663bc865c2d9d7e329d2a05a81549287e091abd482f -->

# Navigazione

In Omarchy tutto avviene tramite la tastiera — _TUTTO!_ Al primo avvio del sistema, letteralmente non puoi fare nulla solo con il mouse. Ma puoi premere `Super + Space` per rivelare il menu di Omarchy e da qui fare praticamente tutto.

Eppure il menu di Omarchy non è nemmeno pensato per essere il modo principale di usare il sistema la maggior parte del tempo. Possiamo essere più veloci! Tutte le applicazioni più importanti sono legate direttamente a singole scorciatoie. Avvii il terminale con `Super + Return` e un browser con `Super + Shift + Return`. Prova a fare uno dopo l'altro e vedrai la magia dei riquadri di Hyprland in azione:

 ![Browser e terminale](../images/navigation-browser-terminal.webp)

Puoi poi premere `Super + J` per impilarli uno sopra l'altro invece che affiancati:

 ![Finestre impilate](../images/navigation-stacked.webp)

Premi di nuovo `Super + J` per riportarli nelle posizioni affiancate. Poi prova `Super + Shift + Freccia destra` mentre sei sul browser per scambiare le finestre.

Ora prova `Super + Ctrl + T` per avviare il monitor delle attività. Apparirà come finestra flottante. Puoi fissarla con `Super + T` (e premere di nuovo per renderla di nuovo flottante). Ora premi `Super + Shift + F` per aprire il gestore dei file. Avrai una bella disposizione a quattro:

 ![Riquadri a quattro finestre](../images/navigation-fourway-tiling.webp)

Ti sposti tra le finestre e scegli quella attiva con `Super + Freccia`. Questo cambia il focus e sposta il cursore al centro della nuova applicazione.

Se premi `Super + Shift + 2`, sposterai l'applicazione attualmente a fuoco sul secondo workspace. `Super + Shift + 1` la riporta indietro. (E `Super + Shift + Alt + 2` sposterà l'applicazione a fuoco sul secondo workspace senza passare ad esso).

Se tieni premuto `Super` e clicchi con il mouse su una finestra, potrai riorganizzarne la posizione. Se tieni premuto `Super` e usi il tasto destro del mouse, puoi ridimensionare liberamente la finestra.

Chiudi una finestra con `Super + W` o `Super + Q` (e chiudi tutte le finestre con `Ctrl + Alt + Delete`).

Puoi anche andare a schermo intero con `Super + F` o anche solo a larghezza piena (mantenendo la barra superiore) con `Super + Alt + F`, oppure a schermo intero dentro una finestra con `Super + Ctrl + F` (ottimo per YouTube!).

### Layout dwindle vs scrolling

Il layout predefinito di Omarchy si chiama dwindle. Mantiene tutte le finestre che apri su un singolo workspace visibili in ogni momento, anche se deve rimpicciolirle.

 ![Layout dwindle](../images/navigation-dwindle-layout.webp)

Ma puoi anche scegliere di trasformare un workspace nel layout scrolling, in cui le finestre sono allineate fianco a fianco, oltre il bordo visibile del display. Trasformi un singolo workspace in questo layout con `Super + L`.

 ![Layout scrolling](../images/navigation-scrolling-layout.webp)

La scelta è per workspace e rimane. Quindi puoi tenere il workspace 1 su dwindle per il browsing e il workspace 2 su scrolling per il codice, e torneranno così anche dopo un riavvio. (Lo stesso interruttore è in _Trigger > Toggle > Workspace Layout_ nel menu di Omarchy).

Se vuoi usare il layout scrolling come predefinito, puoi impostarlo in `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Raggruppare le finestre

Le finestre possono essere raggruppate con `Super + G`. Una volta che sei in un gruppo, ogni finestra che avvii mentre è attivo apparterrà al gruppo. Puoi spostarti tra queste finestre raggruppate con `Super + Ctrl + Freccia sinistra/destra` o con `Super + Alt + 1/2/3/4` per andare direttamente alla finestra raggruppata in ordine.

Puoi far uscire una finestra dal gruppo con `Super + Alt + G` oppure disfare l'intero gruppo premendo di nuovo `Super + G`. Infine, puoi spostare finestre esterne al gruppo dentro di esso con `Super + Alt + Frecce`.

### Far "poppare" le finestre

Puoi estrarre una finestra dalla sua allocazione di workspace con `Super + O`. La fisserà come finestra flottante che ti segue su qualunque workspace tu vada. Ottimo per i lettori video e simili.

 ![Finestra estratta e flottante](../images/navigation-popped-window.webp)

### Workspace scratchpad

Infine, c'è uno speciale workspace scratchpad che scende sopra qualunque workspace tu stia usando, più o meno come una console di Quake. Attivalo con `Super + Grave` o `Super + S`, e colloca lì una finestra con `Super + Shift + Grave` o `Super + Alt + S`.

Funziona particolarmente bene per un terminale che esegue un agente, o per controlli con cui vuoi interagire rapidamente senza lasciare il workspace corrente. Per spostare una finestra fuori dallo scratchpad, mandala direttamente su un altro workspace con qualcosa come `Super + Shift + 1`.

Mentre lo scratchpad contiene una sola finestra, scende come pannello centrato invece di occupare tutta la larghezza dello schermo. Metti una seconda applicazione e torna a tutta larghezza, così le due hanno spazio per stare fianco a fianco.

### Ci vuole un po' per abituarsi!

Ci vuole un po' per abituarsi a navigare il desktop in questo modo, ma una volta che ci riesci sarà difficile tornare a una tradizionale esperienza desktop guidata dal mouse!
