# Branding

Omarchy ti consente di impostare il logo della tua azienda o un'immagine personale sia per il salvaschermo sia per la schermata di informazioni.

### Salvaschermo

Puoi cambiare il logo usato per il salvaschermo in _Aspetto > Branding > Salvaschermo_. È un logo ASCII, quindi puoi modificare il testo direttamente, ma puoi anche fornirgli un'immagine png o svg e la convertiremo in ASCII. Ha un aspetto piuttosto figo.

 ![branding-screensaver](images/branding-screensaver.webp)

In quel menu ci sono tre voci:

- **Modifica testo** apre `~/.config/omarchy/branding/screensaver.txt` nel tuo editor. Digita o incolla quello che vuoi — arte ASCII, il tuo nome, una parolaccia. Salva ed esci e il salvaschermo si avvia immediatamente, così puoi vederlo.
- **Imposta da immagine** apre un selettore di file per un png o svg, lo converte in ASCII e ti mostra il risultato. I loghi con una silhouette netta funzionano molto meglio delle foto.
- **Ripristina predefinito** rimette il logo di Omarchy.

### Schermata di informazioni

Le stesse tre opzioni si trovano in _Aspetto > Branding > Informazioni_ per la schermata _Informazioni_ che ottieni dal menu di Omarchy e funzionano in modo identico — il file è `~/.config/omarchy/branding/about.txt` e la finestra Informazioni si apre dopo ogni modifica. L'arte delle Informazioni viene convertita in una dimensione più piccola rispetto a quella del salvaschermo, poiché deve stare in una finestra invece di riempire il display.

Mentre la finestra è aperta, una banda di luce bianca brillante attraversa l'arte ogni pochi secondi e poi la lascia di nuovo ferma. Anche la tua arte la riceve, purché ogni suo carattere occupi una sola colonna — tutto ciò che produce _Imposta da immagine_ lo fa. L'arte creata con emoji o caratteri a doppia larghezza rimane invece ferma, e lo stesso vale per lo schermo se mantieni una configurazione fastfetch tutta tua: un logo fermo in quei casi significa che l'animazione si fa da parte invece di fallire, poiché far scorrere un riflesso su di essi posizionerebbe il resto della riga nel punto sbagliato.

 ![branding-about](images/branding-about.webp)

### Convertire le immagini da soli

Entrambe le opzioni _Imposta da immagine_ chiamano semplicemente `omarchy transcode ascii`, che puoi eseguire direttamente se vuoi il controllo sulla conversione:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Accetta `--width` e `--height` in colonne e righe del terminale, un `--mode` tra `braille` (quello predefinito, e molto più fine) o `block`, una percentuale `--threshold` per decidere quali pixel contano come parte del logo e `--invert` per quando il tuo logo è chiaro su uno sfondo scuro. Se una conversione risulta una macchia informe, la soglia è di solito il parametro da regolare.

### Parole invece di un logo

`omarchy ascii` disegna il testo in Delta Corps Priest 1, il font FIGlet in cui è disegnato lo stesso wordmark di Omarchy, così un salvaschermo può dire qualcosa invece di mostrare un'immagine:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Accetta il testo come argomenti, oppure lo legge da una pipe quando non ne viene fornito nessuno. Il font contiene solo lettere e spazi — è stato disegnato senza cifre né punteggiatura — quindi qualsiasi altra cosa viene scartata e segnalata su stderr invece di essere inghiottita silenziosamente.
