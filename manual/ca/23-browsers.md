# Navegadors

Omarchy inclou [Google Chrome](https://www.google.com/chrome/) com a navegador predeterminat. Està tematitzat perquè coincideixi amb la resta del teu sistema, i és el que obre `Super + Shift + Return` (o `Super + Shift + B`), amb `Super + Shift + Alt + B` per a una finestra privada, i on s'executa cada [aplicació web](25-web-apps.md). S'obre directament en una finestra del navegador: no hi ha pantalla de benvinguda ni sol·licitud d'inici de sessió, les estadístiques d'ús i els informes d'errors no s'envien a Google, i les sol·licituds de privadesa publicitària estan desactivades. Tot i així, pots iniciar sessió al teu compte de Google des del botó de perfil sempre que vulguis la sincronització.

Si Chrome no és del teu gust, no hi estàs lligat. A _Instal·la > Navegador_ del menú d'Omarchy hi trobaràs [Chromium](https://www.chromium.org/) (la versió oberta i sense extres a partir de la qual es fa Chrome), Edge, Brave, Brave Origin, Firefox, [Zen](https://zen-browser.app/) i [Ladybird](https://ladybird.org/) (Edge només en màquines x86). Tria'n un i Omarchy l'instal·la, en configura el directori de polítiques i hi aplica el teu tema actual.

## Fer que un sigui el predeterminat

Instal·lar un navegador no el promou. Per canviar-lo, ves a _Configuració > Valors predeterminats > Navegador_ i tria'n un. El predeterminat actual està marcat amb una marca de verificació, i triar un navegador que encara no tens l'instal·la primer.

Des del terminal és:

```bash
omarchy default browser firefox
```

Executa-la sense cap argument i et dirà quin és el predeterminat actual. Això estableix el gestor XDG, de manera que no són només les dreceres de teclat d'Omarchy les que el segueixen: tot el que obri un enllaç, des d'una aplicació de xat fins a una ordre del terminal, anirà al navegador que hagis triat.

## Copia l'URL i Baixa el vídeo

Els navegadors de la família Chromium (el mateix Chromium, Chrome, Edge, Brave i Brave Origin) inclouen tres extensions d'Omarchy: dues que surten del navegador i arriben a la resta del teu sistema, i una que ordena WhatsApp.

**Copy URL** posa l'adreça de la pestanya actual al porta-retalls amb `Alt + Shift + L`. Això és més ràpid que fer clic a la barra d'adreces i copiar, i com que passa pel porta-retalls del sistema en lloc del del navegador, reps una notificació d'Omarchy que ho confirma i l'URL està disponible immediatament a l'[historial del porta-retalls](08-unified-clipboard-history.md) i a qualsevol altra aplicació. També hi ha un botó a la barra d'eines, si prefereixes fer clic.

**Download Video** agafa el vídeo que s'està reproduint a la pàgina que estàs mirant amb `Alt + Shift + D`. Passa l'URL a [yt-dlp](https://github.com/yt-dlp/yt-dlp), de manera que funciona en molts més llocs que YouTube, i la baixada acaba a `~/Videos`. El progrés es mostra a la mateixa visualització en pantalla que fan servir el volum i la brillantor, actualitzant-se al mateix lloc en lloc d'acumular notificacions. Defineix `OMARCHY_YTDLP_DIR` si prefereixes que els fitxers vagin a un altre lloc: consulta les [FAQ](46-faq.md) per saber on posar les variables d'entorn.

Totes dues extensions parlen amb Omarchy a través d'un petit amfitrió de missatgeria nativa, que s'instal·la per a tu juntament amb el navegador. Aquesta és la peça que permet que el vídeo d'una pàgina web acabi al teu directori personal i que un URL acabi al teu gestor del porta-retalls, una cosa que una extensió normal no pot fer per si sola.

**WhatsApp Slim** fa que WhatsApp Web segueixi el tema del teu sistema i col·lapsa la seva llista de xats quan la finestra és estreta.

Aquestes són només per a la família Chromium. Firefox i Zen no les reben.

## Firefox i Zen

Firefox i Zen són una família diferent, de manera que reben un tractament diferent: Omarchy instal·la un fitxer de polítiques per a uns valors predeterminats assenyats i els canvia al mode Wayland natiu, que és el que vols per a l'escalat fraccionari i un desplaçament suau amb el panell tàctil.

No reben les extensions de Chromium anteriors, i Omarchy no els tematitza, de manera que aquestes parts de l'experiència les has de configurar tu.

## Ladybird

Ladybird és un navegador escrit des de zero, amb el seu propi motor en lloc del de Chromium o del de Firefox. Encara està en alfa, així que espera't llocs que encara no funcionen, i Omarchy l'instal·la tal com ve: sense extensions, sense tema, sense polítiques. Tampoc no té finestra privada, de manera que `Super + Shift + Alt + B` l'obre amb un perfil temporal que s'elimina quan el tanques. Les [aplicacions web](25-web-apps.md) continuen executant-se a Chrome o Chromium.

## Tornar a eliminar-ne un

Qualsevol d'aquests navegadors, Chrome inclòs, es pot tornar a treure des de _Elimina > Navegador_. Aleshores, els enllaços aniran a Chrome o a Chromium si l'altre encara està instal·lat.
