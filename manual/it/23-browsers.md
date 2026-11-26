# Browser

Omarchy include [Google Chrome](https://www.google.com/chrome/) come browser predefinito. Ha un tema coordinato con il resto del sistema, ed è quello che si apre con `Super + Shift + Return` (o `Super + Shift + B`), con `Super + Shift + Alt + B` per una finestra privata, e quello dentro cui gira ogni [app web](25-web-apps.md). Si apre direttamente con una finestra del browser: non c'è nessuna schermata di benvenuto né richiesta di accesso, le statistiche di utilizzo e i rapporti sugli arresti anomali non vengono inviati a Google e i messaggi sulla privacy degli annunci sono disattivati. Puoi comunque accedere al tuo account Google dal pulsante del profilo ogni volta che vuoi la sincronizzazione.

Se Chrome non fa per te, non sei obbligato a tenertelo. In _Installa > Browser_ nel menu di Omarchy trovi [Chromium](https://www.chromium.org/) (la semplice build open source da cui è realizzato Chrome), Edge, Brave, Brave Origin, Firefox e [Zen](https://zen-browser.app/) (Edge solo su macchine x86). Scegline uno e Omarchy lo installa, configura la sua directory dei criteri e vi applica il tuo tema attuale.

## Impostarne uno come predefinito

Installare un browser non lo rende predefinito. Per cambiarlo, vai in _Configurazione > Predefiniti > Browser_ e scegline uno. Il predefinito attuale è contrassegnato da un segno di spunta e, se scegli un browser che non hai ancora, viene prima installato.

Dal terminale è così:

```bash
omarchy default browser firefox
```

Eseguilo senza argomenti e ti indica il predefinito attuale. Imposta il gestore XDG, quindi non sono solo le scorciatoie di Omarchy a seguirlo: tutto ciò che apre un link, da un'app di chat a un comando da terminale, va al browser che hai scelto.

## Copia URL e Scarica video

I browser della famiglia Chromium (Chromium stesso, Chrome, Edge, Brave e Brave Origin) includono tre estensioni di Omarchy: due che escono dal browser e arrivano al resto del sistema e una che mette ordine in WhatsApp.

**Copy URL** mette l'indirizzo della scheda attuale negli appunti con `Alt + Shift + L`. È più veloce che fare clic nella barra degli indirizzi e copiare e, poiché passa dagli appunti di sistema anziché da quelli del browser, ricevi una notifica di Omarchy che lo conferma e l'URL è subito disponibile nella [cronologia degli appunti](08-unified-clipboard-history.md) e in ogni altra app. C'è anche un pulsante sulla barra degli strumenti, se preferisci fare clic.

**Download Video** cattura il video in riproduzione sulla pagina che stai guardando con `Alt + Shift + D`. Passa l'URL a [yt-dlp](https://github.com/yt-dlp/yt-dlp), quindi funziona su molto più che YouTube, e il download finisce in `~/Videos`. L'avanzamento compare nello stesso display su schermo usato per volume e luminosità, aggiornandosi sul posto anziché accumulare notifiche. Imposta `OMARCHY_YTDLP_DIR` se preferisci che i file vadano altrove: vedi le [FAQ](46-faq.md) per dove inserire le variabili d'ambiente.

Entrambe le estensioni comunicano con Omarchy tramite un piccolo host di messaggistica nativa, che viene installato per te insieme al browser. È il pezzo che permette al video di una pagina web di finire nella tua directory home e a un URL di finire nel tuo gestore degli appunti, cosa che una normale estensione non può fare da sola.

**WhatsApp Slim** fa in modo che WhatsApp Web segua il tema del sistema e comprime l'elenco delle chat quando la finestra è stretta.

Queste sono solo per la famiglia Chromium. Firefox e Zen non le ricevono.

## Firefox e Zen

Firefox e Zen appartengono a una famiglia diversa, quindi ricevono un trattamento diverso: Omarchy installa un file di criteri per impostazioni predefinite sensate e li passa alla modalità Wayland nativa, che è quello che vuoi per il ridimensionamento frazionario e lo scorrimento fluido con il trackpad.

Non ricevono le estensioni Chromium di cui sopra e non vengono tematizzati da Omarchy, quindi quelle parti dell'esperienza sta a te configurarle.

## Rimuoverne uno

Ognuno di questi browser, Chrome incluso, può essere rimosso di nuovo da _Rimuovi > Browser_. I link andranno quindi a Chrome o Chromium, se l'altro è ancora installato.
