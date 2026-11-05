# Navegadors

Omarchy ve amb [Chromium](https://www.chromium.org/) com a navegador per defecte. És la versió senzilla de codi obert, amb un tema que combina amb la resta del sistema, i és el que obre `Super + Shift + Return` i dins del qual s'executa cada [aplicació web](25-web-apps.md).

Si Chromium no és del teu gust, no hi estàs pas obligat. A _Instal·la > Navegador_ al menú d'Omarchy hi trobaràs Chrome, Edge, Brave, Brave Origin, Firefox i [Zen](https://zen-browser.app/). Tria'n un i Omarchy l'instal·la, li configura el directori de polítiques i li aplica el teu tema actual.

## Fer que un sigui el per defecte

Instal·lar un navegador no el promociona. Un cop sigui a la màquina, ves a _Configuració > Per defecte > Navegador_ i tria'l: el menú només llista els navegadors que tens instal·lats de debò i marca l'actual per defecte amb una marca.

Des del terminal és:

```bash
omarchy default browser firefox
```

Executa'l sense cap argument i et dirà quin és l'actual per defecte. Això defineix el gestor XDG, de manera que no són només les dreceres d'Omarchy les que el segueixen: qualsevol cosa que obri un enllaç, d'una aplicació de xat a una ordre de terminal, va al navegador que has triat.

## Copia l'URL i descarrega el vídeo

Els navegadors de la família Chromium (el mateix Chromium, Chrome, Edge i Brave) venen amb dues extensions d'Omarchy que surten del navegador i arriben a la resta del sistema.

**Copy URL** posa l'adreça de la pestanya actual al porta-retalls amb `Alt + Shift + L`. Això és més ràpid que fer clic a la barra d'adreces i copiar, i com que passa pel porta-retalls del sistema en lloc del del navegador, reps una notificació d'Omarchy que ho confirma i l'URL està disponible immediatament a l'[historial del porta-retalls](08-unified-clipboard-history.md) i a totes les altres aplicacions. També hi ha un botó a la barra d'eines, si prefereixes fer clic.

**Download Video** agafa el vídeo que es reprodueix a la pàgina que estàs mirant amb `Alt + Shift + D`. Passa l'URL a [yt-dlp](https://github.com/yt-dlp/yt-dlp), de manera que funciona en moltíssims llocs més que YouTube, i la descàrrega acaba a `~/Videos`. El progrés apareix a la mateixa indicació en pantalla que fan servir el volum i la brillantor, actualitzant-se al mateix lloc en lloc d'apilar notificacions. Defineix `OMARCHY_YTDLP_DIR` si prefereixes que els fitxers vagin a un altre lloc: consulta les [preguntes freqüents](46-faq.md) per saber on posar les variables d'entorn.

Totes dues extensions parlen amb Omarchy mitjançant un petit host de missatgeria natiua, que s'instal·la juntament amb el navegador. Aquesta és la peça que permet que el vídeo d'una pàgina web acabi al teu directori personal i que un URL acabi al gestor del porta-retalls, cosa que una extensió normal no pot fer tota sola.

Aquestes són només per a la família Chromium. Firefox i Zen no les tenen.

## Firefox i Zen

Firefox i Zen són una família diferent, de manera que reben un tracte diferent: Omarchy instal·la un fitxer de polítiques per a valors per defecte sensats i els posa en mode Wayland natiu, que és el que vols per a l'escala fraccionària i un desplaçament suau amb el panell tàctil.

No tenen les extensions de Chromium de més amunt, i Omarchy no els aplica cap tema, de manera que aquestes parts de l'experiència les has de configurar tu.

## Eliminar-ne un altre cop

Tot el que hagis instal·lat aquí es pot tornar a treure a _Elimina > Navegador_. Chromium no és en aquella llista: forma part del sistema base.
