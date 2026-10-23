# Marchio personalizzato

Omarchy ti permette di impostare il logo della tua azienda o un'immagine personale per lo sblocco all'avvio, il salvaschermo e la schermata Info.

### Sblocco all'avvio

Puoi usare `omarchy plymouth preview` per vedere come apparirebbero il tuo logo e i tuoi colori personalizzati. Accetta un colore di sfondo, un colore del testo, un logo in formato png e un percorso per l'immagine di anteprima:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Poi applica la configurazione con `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, che darà anche alla schermata di accesso SDDM gli stessi colori e lo stesso logo. Se vuoi tornare indietro, puoi usare `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Salvaschermo

Puoi cambiare il logo usato per il salvaschermo in _Stile > Salvaschermo_. È un logo ASCII, quindi puoi modificarne il testo direttamente, ma puoi anche dargli un'immagine png o svg e noi la convertiremo in ASCII. Ha un aspetto davvero fantastico.

 ![branding-screensaver](images/branding-screensaver.webp)

In quel menu ci sono tre voci:

- **Modifica testo** apre `~/.config/omarchy/branding/screensaver.txt` nel tuo editor. Scrivi o incolla quello che vuoi: ASCII art, il tuo nome, una parolaccia. Salva ed esci, e il salvaschermo si avvia subito così puoi vederlo.
- **Da immagine** apre un selettore di file per un png o svg, lo converte in ASCII e ti mostra il risultato. I loghi con una sagoma netta funzionano molto meglio delle foto.
- **Ripristina predefinito** rimette a posto il logo di Omarchy.

### Schermata Info

Le stesse tre opzioni si trovano in _Stile > Info_ per la schermata _Info_ che ottieni dal menu di Omarchy e funzionano allo stesso identico modo: il file è `~/.config/omarchy/branding/about.txt` e la finestra Info compare dopo ogni modifica. L'arte Info viene convertita a una dimensione più piccola di quella del salvaschermo, visto che deve stare in una finestra invece di riempire lo schermo.

Mentre la finestra è aperta, ogni pochi secondi un riflesso verde attraversa l'arte e poi la lascia di nuovo ferma. Lo riceve anche la tua arte personale, purché ogni suo carattere sia largo una sola colonna: tutto ciò che produce _Da immagine_ lo è. L'arte costruita con emoji o caratteri a doppia larghezza resta invece ferma, e lo stesso vale per lo schermo se mantieni una tua configurazione fastfetch: in quei casi un logo fermo significa che l'animazione si tiene alla larga invece di fallire, perché far scorrere un riflesso su di esse farebbe finire il resto della riga nel posto sbagliato.

 ![branding-about](images/branding-about.webp)

### Converti le immagini da solo

Entrambe le opzioni _Da immagine_ non fanno altro che chiamare `omarchy transcode ascii`, che puoi eseguire direttamente se vuoi il controllo sulla conversione:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Accetta `--width` e `--height` in colonne e righe del terminale, un `--mode` tra `braille` (l'impostazione predefinita, e molto più fine) o `block`, una percentuale `--threshold` per decidere quali pixel contano come parte del logo e `--invert` per quando il tuo logo è chiaro su sfondo scuro. Se una conversione viene fuori come una macchia, di solito è la soglia la manopola da girare.

### Parole invece di un logo

`omarchy ascii` disegna il testo in Delta Corps Priest 1, il carattere FIGlet in cui è disegnato lo stesso marchio verbale di Omarchy, così un salvaschermo può dire qualcosa invece di mostrare un'immagine:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Accetta il testo come argomenti oppure lo legge da una pipe quando non gliene viene dato nessuno. Il carattere contiene solo lettere e spazi — è stato disegnato senza cifre né punteggiatura — quindi tutto il resto viene scartato e segnalato su stderr invece di essere ingoiato in silenzio.
