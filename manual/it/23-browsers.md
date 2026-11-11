# Browser

Omarchy viene fornito con [Google Chrome](https://www.google.com/chrome/) come browser predefinito. Ha un tema in linea con il resto del sistema, ed è quello che si apre con `Super + Shift + Return` e in cui viene eseguita ogni [app web](25-web-apps.md). Si apre direttamente in una finestra del browser: non c'è nessuna schermata di benvenuto né richiesta di accesso, le statistiche di utilizzo e i rapporti sugli arresti anomali non vengono inviati a Google e le richieste sulla privacy degli annunci sono disattivate. Puoi comunque accedere al tuo account Google dal pulsante del profilo ogni volta che vuoi la sincronizzazione.

Se Chrome non fa per te, non sei costretto a tenerlo. In _Install > Browser_ nel menu di Omarchy troverai [Chromium](https://www.chromium.org/) (la semplice versione open source da cui è realizzato Chrome), Edge, Brave, Brave Origin, Firefox e [Zen](https://zen-browser.app/). Scegline uno e Omarchy lo installerà, configurerà la sua directory dei criteri e vi applicherà il tuo tema attuale.

## Impostarne uno come predefinito

Installare un browser non lo rende predefinito. Una volta che è sulla macchina, vai in _Setup > Defaults > Browser_ e selezionalo: il menu elenca solo i browser effettivamente installati e contrassegna quello predefinito attuale con un segno di spunta.

Dal terminale il comando è:

```bash
omarchy default browser firefox
```

Eseguilo senza argomenti e ti dirà qual è quello predefinito attuale. Questo imposta il gestore XDG, quindi non sono solo i tasti di scelta rapida di Omarchy a seguirlo: qualsiasi cosa apra un link, da un'app di chat a un comando da terminale, andrà al browser che hai scelto.

## Copy URL e Download Video

I browser della famiglia Chromium (Chromium stesso, Chrome, Edge e Brave) sono dotati di due estensioni di Omarchy che escono dal browser e raggiungono il resto del sistema.

**Copy URL** mette l'indirizzo della scheda attuale negli appunti con `Alt + Shift + L`. È più veloce che fare clic sulla barra degli indirizzi e copiare, e poiché passa attraverso gli appunti di sistema invece che quelli del browser, ricevi una notifica di Omarchy che lo conferma e l'URL è immediatamente disponibile nella [cronologia degli appunti](08-unified-clipboard-history.md) e in ogni altra app. C'è anche un pulsante sulla barra degli strumenti, se preferisci fare clic.

**Download Video** acquisisce il video in riproduzione sulla pagina che stai guardando con `Alt + Shift + D`. Passa l'URL a [yt-dlp](https://github.com/yt-dlp/yt-dlp), quindi funziona su molto più che YouTube, e il download finisce in `~/Videos`. L'avanzamento viene mostrato nella stessa visualizzazione su schermo usata per volume e luminosità, aggiornandosi sul posto invece di accumulare notifiche. Imposta `OMARCHY_YTDLP_DIR` se preferisci che i file vadano altrove: consulta le [FAQ](46-faq.md) per sapere dove inserire le variabili d'ambiente.

Entrambe le estensioni comunicano con Omarchy tramite un piccolo host di messaggistica nativa, che viene installato per te insieme al browser. È il componente che permette al video di una pagina web di finire nella tua directory home e a un URL di finire nel tuo gestore degli appunti, cosa che una normale estensione non può fare da sola.

Queste sono solo per la famiglia Chromium. Firefox e Zen non le ricevono.

## Firefox e Zen

Firefox e Zen appartengono a una famiglia diversa, quindi ricevono un trattamento diverso: Omarchy installa un file di criteri per impostazioni predefinite sensate e li passa alla modalità Wayland nativa, che è quella che vuoi per il ridimensionamento frazionario e lo scorrimento fluido con il trackpad.

Non ricevono le estensioni Chromium di cui sopra e non sono personalizzati con il tema di Omarchy, quindi quelle parti dell'esperienza spettano a te configurarle.

## Rimozione di un browser

Qualsiasi di questi browser, Chrome incluso, può essere rimosso di nuovo in _Remove > Browser_. I link andranno quindi a Chrome o Chromium se l'altro è ancora installato.
