# Browser

Omarchy viene fornito con [Google Chrome](https://www.google.com/chrome/) come browser predefinito. È tematizzato per abbinarsi al resto del tuo sistema, ed è quello che si apre con `Super + Shift + Return` (o `Super + Shift + B`), con `Super + Shift + Alt + B` per una finestra privata, e quello dentro cui gira ogni [app web](25-web-apps.md). Si apre direttamente in una finestra del browser: non c'è nessuna schermata di benvenuto né richiesta di accesso, le statistiche di utilizzo e i rapporti sugli arresti anomali non vengono inviati a Google, e i prompt sulla privacy degli annunci sono disattivati. Puoi comunque accedere al tuo account Google dal pulsante del profilo ogni volta che vuoi la sincronizzazione.

Se Chrome non fa per te, non sei costretto a tenertelo. In _Install > Browser_ nel menu di Omarchy troverai [Chromium](https://www.chromium.org/) (la semplice build open source da cui è fatto Chrome), Edge, Brave, Brave Origin, Firefox, [Zen](https://zen-browser.app/) e [Ladybird](https://ladybird.org/) (Edge solo su macchine x86). Scegline uno e Omarchy lo installa, configura la sua directory dei criteri e vi applica il tuo tema corrente.

## Impostarne uno come predefinito

Installare un browser non lo promuove. Per cambiarlo, vai su _Setup > Defaults > Browser_ e scegline uno. Quello predefinito corrente è contrassegnato da un segno di spunta, e scegliere un browser che non hai ancora lo installa prima.

Dal terminale è:

```bash
omarchy default browser firefox
```

Eseguilo senza argomenti e ti dice qual è quello predefinito corrente. Questo imposta il gestore XDG, quindi non sono solo i tasti di scelta rapida di Omarchy a seguire — qualsiasi cosa apra un link, da un'app di chat a un comando da terminale, va al browser che hai scelto.

## Copy URL e Download Video

I browser della famiglia Chromium (Chromium stesso, Chrome, Edge, Brave e Brave Origin) sono dotati di tre estensioni Omarchy: due che escono dal browser e raggiungono il resto del tuo sistema, e una che mette ordine in WhatsApp.

**Copy URL** mette l'indirizzo della scheda corrente nei tuoi appunti con `Alt + Shift + L`. È più veloce che fare clic nella barra degli indirizzi e copiare, e poiché passa attraverso gli appunti di sistema invece di quelli del browser, ricevi una notifica di Omarchy che lo conferma e l'URL è immediatamente disponibile nella [cronologia degli appunti](08-unified-clipboard-history.md) e in ogni altra app. C'è anche un pulsante nella barra degli strumenti, se preferisci fare clic.

**Download Video** cattura il video in riproduzione sulla pagina che stai guardando con `Alt + Shift + D`. Passa l'URL a [yt-dlp](https://github.com/yt-dlp/yt-dlp), quindi funziona su molto più che YouTube, e il download finisce in `~/Videos`. L'avanzamento viene mostrato nello stesso display su schermo usato da volume e luminosità, aggiornandosi sul posto invece di accumulare notifiche. Imposta `OMARCHY_YTDLP_DIR` se preferisci che i file vadano da un'altra parte — vedi le [FAQ](46-faq.md) per sapere dove mettere le variabili di ambiente.

Entrambe le estensioni comunicano con Omarchy attraverso un piccolo host di messaggistica nativa, che viene installato per te insieme al browser. È quel pezzo che permette al video di una pagina web di finire nella tua directory home e a un URL di finire nel tuo gestore degli appunti, cosa che un'estensione normale non può fare da sola.

**WhatsApp Slim** fa in modo che WhatsApp Web segua il tema del tuo sistema e comprime l'elenco delle chat quando la finestra è stretta.

Queste sono solo per la famiglia Chromium. Firefox e Zen non le ricevono.

## Firefox e Zen

Firefox e Zen sono una famiglia diversa, quindi ricevono un trattamento diverso: Omarchy installa un file di criteri per impostazioni predefinite sensate e li passa alla modalità Wayland nativa, che è quello che vuoi per il ridimensionamento frazionario e lo scorrimento fluido con il trackpad.

Non ricevono le estensioni Chromium qui sopra, e non sono tematizzati da Omarchy, quindi quelle parti dell'esperienza sta a te configurarle.

## Ladybird

Ladybird è un browser scritto da zero, con un suo motore invece di quello di Chromium o di Firefox. È ancora in alpha, quindi aspettati siti che non funzionano ancora, e Omarchy lo installa così com'è: nessuna estensione, nessun tema, nessun criterio. Non ha nemmeno una finestra privata, quindi `Super + Shift + Alt + B` lo apre con un profilo temporaneo che viene eliminato quando lo chiudi. [Le app web](25-web-apps.md) continuano a girare in Chrome o Chromium.

## Rimuoverne uno di nuovo

Qualsiasi di questi browser, Chrome incluso, può essere rimosso di nuovo in _Remove > Browser_. I link andranno quindi a Chrome o Chromium se l'altro è ancora installato.
