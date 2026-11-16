# Branding

Omarchy ti permette di impostare il logo della tua azienda o un'immagine personale per lo sblocco all'avvio, il salvaschermo e la schermata Informazioni.

### Sblocco all'avvio

Puoi usare `omarchy plymouth preview` per vedere come apparirebbero il tuo logo e i tuoi colori personalizzati. Accetta un colore di sfondo, un colore del testo, un logo png e un percorso per l'immagine di anteprima:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Poi applica la configurazione con `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, che darà anche alla schermata di accesso SDDM gli stessi colori e lo stesso logo. Se vuoi annullare le modifiche, puoi usare `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Salvaschermo

Puoi cambiare il logo usato per il salvaschermo in _Aspetto > Branding > Salvaschermo_. È un logo ASCII, quindi puoi modificare il testo direttamente, ma puoi anche fornirgli un'immagine png o svg e la convertiremo in ASCII. Il risultato è davvero fico.

 ![branding-screensaver](images/branding-screensaver.webp)

In quel menu ci sono tre voci:

- **Modifica testo** apre `~/.config/omarchy/branding/screensaver.txt` nel tuo editor. Digita o incolla quello che vuoi — arte ASCII, il tuo nome, una parolaccia. Salva ed esci, e il salvaschermo si avvia immediatamente così puoi vederlo.
- **Imposta da immagine** apre un selettore di file per un png o svg, lo converte in ASCII e te ne mostra il risultato. I loghi con una silhouette netta funzionano molto meglio delle foto.
- **Ripristina predefinito** rimette il logo di Omarchy.

### Schermata Informazioni

Le stesse tre opzioni si trovano in _Aspetto > Branding > Informazioni_ per la schermata _Informazioni_ che ottieni dal menu di Omarchy, e funzionano in modo identico — il file è `~/.config/omarchy/branding/about.txt`, e la finestra Informazioni compare dopo ogni modifica. L'immagine di Informazioni viene convertita in una dimensione più piccola rispetto a quella del salvaschermo, perché deve stare dentro una finestra invece di riempire lo schermo.

Mentre la finestra è aperta, un riflesso verde attraversa l'immagine ogni pochi secondi e poi la lascia di nuovo immobile. Anche la tua immagine personale lo riceve, purché ogni suo carattere sia largo una sola colonna — e qualsiasi cosa prodotta da _Imposta da immagine_ lo è. Le immagini composte da emoji o caratteri a doppia larghezza restano invece immobili, e lo stesso vale per la schermata se mantieni una configurazione fastfetch tua: in questi casi un logo immobile significa che l'animazione si fa da parte anziché non funzionare, perché far scorrere un riflesso su di esse sposterebbe il resto della riga nella posizione sbagliata.

 ![branding-about](images/branding-about.webp)

### Convertire le immagini da solo

Entrambe le opzioni _Imposta da immagine_ non fanno altro che chiamare `omarchy transcode ascii`, che puoi eseguire direttamente se vuoi controllare la conversione:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Accetta `--width` e `--height` in colonne e righe del terminale, un `--mode` pari a `braille` (il predefinito, e molto più fine) o `block`, una percentuale `--threshold` per decidere quali pixel contano come parte del logo, e `--invert` per quando il tuo logo è chiaro su sfondo scuro. Se una conversione viene fuori come una macchia, di solito è la soglia il parametro da regolare.

### Parole invece di un logo

`omarchy ascii` disegna il testo in Delta Corps Priest 1, il font FIGlet in cui è disegnato lo stesso marchio denominativo di Omarchy, così un salvaschermo può dire qualcosa invece di mostrare un'immagine:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Accetta il testo come argomenti, oppure lo legge da una pipe quando non gliene viene fornito nessuno. Il font contiene solo lettere e spazi — è stato disegnato senza cifre né punteggiatura — quindi qualsiasi altra cosa viene scartata e segnalata su stderr invece di essere inghiottita in silenzio.
