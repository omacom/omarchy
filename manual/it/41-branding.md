# Branding

Omarchy ti permette di impostare il logo della tua azienda o un'immagine personale per lo sblocco all'avvio, per il salvaschermo e per la schermata About.

### Sblocco all'avvio

Puoi usare `omarchy plymouth preview` per vedere come apparirebbero il tuo logo e i tuoi colori personalizzati. Accetta un colore di sfondo, un colore del testo, un logo png e un percorso per l'immagine di anteprima:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Poi applica la configurazione con `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, che darà anche alla schermata di accesso SDDM gli stessi colori e lo stesso logo. Se vuoi annullare tutto, puoi usare `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Salvaschermo

Puoi cambiare il logo usato per il salvaschermo in _Appearance > Branding > Screensaver_. È un logo ASCII, quindi puoi modificare direttamente il testo, ma puoi anche dargli un'immagine png o svg e la convertiremo in ASCII. Fa davvero un bell'effetto.

 ![branding-screensaver](images/branding-screensaver.webp)

In quel menu ci sono tre voci:

- **Edit Text** apre `~/.config/omarchy/branding/screensaver.txt` nel tuo editor. Digita o incolla quello che vuoi: ASCII art, il tuo nome, una parolaccia. Salva ed esci, e il salvaschermo si avvia immediatamente così puoi vederlo.
- **Set From Image** apre un selettore di file per un png o un svg, lo converte in ASCII e ti mostra il risultato. I loghi con una silhouette netta funzionano molto meglio delle foto.
- **Restore Default** ripristina il logo di Omarchy.

### Schermata About

Le stesse tre opzioni si trovano in _Appearance > Branding > About_ per la schermata _About_ che ottieni dal menu Omarchy, e funzionano in modo identico: il file è `~/.config/omarchy/branding/about.txt`, e la finestra About si apre dopo ogni modifica. La grafica About viene convertita a una dimensione più piccola rispetto a quella del salvaschermo, perché deve stare in una finestra invece di riempire tutto lo schermo.

Mentre la finestra è aperta, ogni pochi secondi una fascia di luce bianca intensa attraversa obliquamente la grafica e poi la lascia di nuovo ferma. Succede anche alla tua grafica, purché ogni suo carattere sia largo una sola colonna, come tutto ciò che produce _Set From Image_. La grafica fatta di emoji o di caratteri a doppia larghezza resta invece ferma, e lo stesso vale per la schermata se tieni una tua configurazione fastfetch: in quei casi, un logo fermo significa che l'animazione si tiene alla larga, non che sta fallendo, perché far scivolare un riflesso su quei caratteri sposterebbe il resto della riga nel posto sbagliato.

 ![branding-about](images/branding-about.webp)

### Convertire le immagini da solo

Entrambe le opzioni _Set From Image_ si limitano a chiamare `omarchy transcode ascii`, che puoi eseguire direttamente se vuoi avere il controllo sulla conversione:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Accetta `--width` e `--height` espressi in colonne e righe del terminale, un `--mode` che può essere `braille` (il predefinito, ed è molto più fine) o `block`, una percentuale `--threshold` per decidere quali pixel contano come parte del logo, e `--invert` per quando il tuo logo è chiaro su uno sfondo scuro. Se una conversione viene fuori come un blob informe, di solito è la soglia il parametro su cui intervenire.

### Parole invece di un logo

`omarchy ascii` disegna il testo in Delta Corps Priest 1, il font FIGlet con cui è disegnato il wordmark stesso di Omarchy, così un salvaschermo può dire qualcosa invece di mostrare un'immagine:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Accetta il testo come argomento, oppure lo legge da una pipe quando non gliene viene passato nessuno. Il font contiene solo lettere e spazi: è stato disegnato senza cifre né segni di punteggiatura, quindi tutto il resto viene scartato e segnalato su stderr invece di essere ingoiato in silenzio.
