# Navegadors

Omarchy inclou [Google Chrome](https://www.google.com/chrome/) com a navegador predeterminat. Està tematitzat per anar a joc amb la resta del sistema, i és el que obre `Super + Shift + Return` (o `Super + Shift + B`), amb `Super + Shift + Alt + B` per a una finestra privada, i on s'executa cada [aplicació web](25-web-apps.md). S'obre directament en una finestra del navegador: no hi ha pantalla de benvinguda ni sol·licitud d'inici de sessió, no s'envien a Google estadístiques d'ús ni informes d'errors, i els avisos de privadesa publicitària estan desactivats. Encara pots iniciar sessió al teu compte de Google des del botó de perfil sempre que vulguis sincronitzar-lo.

Si Chrome no és del teu gust, no hi estàs atrapat. A _Install > Browser_ del menú d'Omarchy hi trobaràs [Chromium](https://www.chromium.org/) (la versió senzilla de codi obert a partir de la qual es fa Chrome), Edge, Brave, Brave Origin, Firefox i [Zen](https://zen-browser.app/) (Edge només en màquines x86). Tria'n un i Omarchy l'instal·la, configura el seu directori de polítiques i hi aplica el teu tema actual.

## Establir-ne un com a predeterminat

Instal·lar un navegador no el promou. Per canviar, vés a _Setup > Defaults > Browser_ i tria'n un. El predeterminat actual està marcat amb una marca de verificació, i triar un navegador que encara no tens l'instal·la primer.

Des del terminal és:

```bash
omarchy default browser firefox
```

Executa'l sense cap argument i et diu el predeterminat actual. Això estableix el gestor XDG, de manera que no són només les tecles de drecera d'Omarchy les que el segueixen — qualsevol cosa que obri un enllaç, des d'una aplicació de xat fins a una ordre de terminal, va al navegador que has triat.

## Copy URL i Download Video

Els navegadors de la família Chromium (el mateix Chromium, Chrome, Edge, Brave i Brave Origin) inclouen tres extensions d'Omarchy: dues que arriben fora del navegador i a la resta del sistema, i una que ordena WhatsApp.

**Copy URL** posa l'adreça de la pestanya actual al porta-retalls amb `Alt + Shift + L`. Això és més ràpid que fer clic a la barra d'adreces i copiar, i com que passa pel porta-retalls del sistema en lloc del del navegador, reps una notificació d'Omarchy que ho confirma i l'URL està disponible immediatament a l'[historial del porta-retalls](08-unified-clipboard-history.md) i a totes les altres aplicacions. També hi ha un botó a la barra d'eines, si prefereixes fer clic.

**Download Video** agafa el vídeo que es reprodueix a la pàgina que estàs mirant amb `Alt + Shift + D`. Passa l'URL a [yt-dlp](https://github.com/yt-dlp/yt-dlp), de manera que funciona en molt més que YouTube, i la descàrrega arriba a `~/Videos`. El progrés apareix al mateix indicador en pantalla que fan servir el volum i la brillantor, s'actualitza al seu lloc en lloc d'apilar notificacions. Estableix `OMARCHY_YTDLP_DIR` si prefereixes que els fitxers vagin a un altre lloc — consulta les [PMF](46-faq.md) per saber on posar les variables d'entorn.

Ambdues extensions es comuniquen amb Omarchy mitjançant un petit amfitrió de missatgeria nativa, que s'instal·la per a tu juntament amb el navegador. Aquesta és la peça que permet que el vídeo d'una pàgina web acabi al teu directori d'inici i que un URL acabi al teu gestor del porta-retalls, cosa que una extensió normal no pot fer per si sola.

**WhatsApp Slim** fa que WhatsApp Web segueixi el teu tema del sistema i plega la seva llista de xats quan la finestra és estreta.

Aquestes són només per a la família Chromium. Firefox i Zen no les reben.

## Firefox i Zen

Firefox i Zen són d'una família diferent, de manera que reben un tractament diferent: Omarchy instal·la un fitxer de polítiques per a uns valors predeterminats sensats i els canvia al mode natiu Wayland, que és el que vols per a l'escalat fraccionari i un desplaçament suau amb el panell tàctil.

No reben les extensions Chromium de dalt, i Omarchy no els tematitza, de manera que aquestes parts de l'experiència les has de configurar tu.

## Tornar a eliminar-ne un

Qualsevol d'aquests navegadors, inclòs Chrome, es pot tornar a treure a _Remove > Browser_. Aleshores els enllaços van a Chrome o Chromium si l'altre encara està instal·lat.
