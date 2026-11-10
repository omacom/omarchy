# Browser

Omarchy include [Chromium](https://www.chromium.org/) come browser predefinito. È la build open source semplice, con il tema abbinato al resto del sistema, ed è ciò che apre `Super + Shift + Return` e ciò dentro cui gira ogni [app web](25-web-apps.md).

Se Chromium non è di tuo gusto, non sei costretto a tenerlo. In _Installa > Browser_ nel menu Omarchy troverai Chrome, Edge, Brave, Brave Origin, Firefox e [Zen](https://zen-browser.app/). Scegline uno e Omarchy lo installerà, configurerà la sua directory dei criteri e applicherà il tuo tema corrente.

## Impostarne uno come predefinito

Installare un browser non lo promuove. Una volta che è sulla macchina, vai in _Impostazioni > Predefiniti > Browser_ e sceglilo — il menu elenca solo i browser che hai effettivamente installato e contrassegna quello predefinito corrente con un segno di spunta.

Dal terminale è:

```bash
omarchy default browser firefox
```

Eseguilo senza argomenti e ti dirà il predefinito corrente. Questo imposta il gestore XDG, quindi non sono solo le scorciatoie di Omarchy a seguirlo — qualsiasi cosa apra un link, da un'app di chat a un comando del terminale, va al browser che hai scelto.

## Copy URL e Download Video

I browser della famiglia Chromium (Chromium stesso, Chrome, Edge e Brave) includono due estensioni Omarchy che escono dal browser e raggiungono il resto del tuo sistema.

**Copy URL** mette l'indirizzo della scheda corrente negli appunti con `Alt + Shift + L`. È più veloce che fare clic nella barra degli indirizzi e copiare, e poiché passa dagli appunti di sistema anziché da quelli del browser, ricevi una notifica Omarchy di conferma e l'URL è immediatamente disponibile nella [cronologia appunti](08-unified-clipboard-history.md) e in ogni altra app. C'è anche un pulsante nella barra degli strumenti, se preferisci fare clic.

**Download Video** cattura il video in riproduzione sulla pagina che stai guardando con `Alt + Shift + D`. Passa l'URL a [yt-dlp](https://github.com/yt-dlp/yt-dlp), quindi funziona su molto più che YouTube, e il download finisce in `~/Videos`. L'avanzamento appare nello stesso display su schermo usato da volume e luminosità, aggiornandosi sul posto anziché accumulare notifiche. Imposta `OMARCHY_YTDLP_DIR` se preferisci che i file vadano altrove — vedi le [FAQ](46-faq.md) per sapere dove mettere le variabili d'ambiente.

Entrambe le estensioni parlano con Omarchy tramite un piccolo host di messaggistica nativa, che viene installato per te insieme al browser. È il pezzo che permette al video di una pagina web di finire nella tua directory home e a un URL di finire nel gestore degli appunti, cosa che un'estensione normale non può fare da sola.

Queste sono solo per la famiglia Chromium. Firefox e Zen non le ricevono.

## Firefox e Zen

Firefox e Zen appartengono a una famiglia diversa, quindi ricevono un trattamento diverso: Omarchy installa un file di criteri per impostazioni predefinite sensate e li passa alla modalità Wayland nativa, che è ciò che vuoi per il ridimensionamento frazionario e lo scorrimento fluido del trackpad.

Non ricevono le estensioni Chromium qui sopra e non sono tematizzati da Omarchy, quindi quelle parti dell'esperienza spetta a te configurarle.

## Rimuoverne uno

Tutto ciò che hai installato qui può essere rimosso da _Rimuovi > Browser_. Chromium non è in quell'elenco — fa parte del sistema di base.
