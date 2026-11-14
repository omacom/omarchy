# Navegadors

Omarchy ve amb [Google Chrome](https://www.google.com/chrome/) com a navegador predeterminat. Està tematitzat perquè combini amb la resta del sistema, i és el que obre `Super + Shift + Return` i dins del qual s'executa cada [aplicació web](25-web-apps.md). S'obre directament en una finestra del navegador: no hi ha cap pantalla de benvinguda ni cap sol·licitud d'inici de sessió, no s'envien a Google estadístiques d'ús ni informes d'errors, i els avisos de privadesa dels anuncis estan desactivats. Encara pots iniciar sessió al teu compte de Google des del botó de perfil sempre que vulguis sincronitzar-lo.

Si Chrome no és del teu gust, no hi estàs lligat. A _Instal·la > Navegador_ del menú d'Omarchy trobaràs [Chromium](https://www.chromium.org/) (la versió senzilla i de codi obert a partir de la qual es fa Chrome), Edge, Brave, Brave Origin, Firefox i [Zen](https://zen-browser.app/). Tria'n un i Omarchy l'instal·la, en configura el directori de polítiques i hi aplica el teu tema actual.

## Fer que un sigui el predeterminat

Instal·lar un navegador no el promou. Un cop és a la màquina, ves a _Configuració > Predeterminats > Navegador_ i tria'l: el menú només enumera els navegadors que tens instal·lats de debò, i marca el predeterminat actual amb una marca de verificació.

Des del terminal és:

```bash
omarchy default browser firefox
```

Executa-ho sense cap argument i et dirà quin és el predeterminat actual. Això estableix el gestor XDG, de manera que no són només les tecles d'accés ràpid d'Omarchy les que el segueixen: tot el que obri un enllaç, des d'una aplicació de xat fins a una ordre del terminal, anirà al navegador que hagis triat.

## Copia l'URL i Baixa el vídeo

Els navegadors de la família Chromium (el mateix Chromium, Chrome, Edge i Brave) venen amb dues extensions d'Omarchy que surten del navegador i arriben a la resta del sistema.

**Copia l'URL** posa l'adreça de la pestanya actual al porta-retalls amb `Alt + Shift + L`. És més ràpid que fer clic a la barra d'adreces i copiar, i com que passa pel porta-retalls del sistema en lloc del del navegador, reps una notificació d'Omarchy que t'ho confirma i l'URL està disponible immediatament a l'[historial del porta-retalls](08-unified-clipboard-history.md) i a totes les altres aplicacions. També hi ha un botó a la barra d'eines, si prefereixes fer clic.

**Baixa el vídeo** agafa el vídeo que s'està reproduint a la pàgina que estàs mirant amb `Alt + Shift + D`. Passa l'URL a [yt-dlp](https://github.com/yt-dlp/yt-dlp), així que funciona en molts més llocs que YouTube, i la baixada acaba a `~/Videos`. El progrés es mostra a la mateixa visualització en pantalla que fan servir el volum i la brillantor, i s'actualitza al mateix lloc en lloc d'anar apilant notificacions. Defineix `OMARCHY_YTDLP_DIR` si prefereixes que els fitxers vagin a un altre lloc: consulta les [FAQ](46-faq.md) per saber on posar les variables d'entorn.

Ambdues extensions parlen amb Omarchy a través d'un petit amfitrió de missatgeria natiu, que s'instal·la per a tu juntament amb el navegador. És la peça que permet que el vídeo d'una pàgina web acabi al teu directori d'inici i que un URL acabi al teu gestor del porta-retalls, una cosa que una extensió normal no pot fer per si sola.

Aquestes són només per a la família Chromium. Firefox i Zen no les tenen.

## Firefox i Zen

Firefox i Zen són d'una família diferent, així que reben un tracte diferent: Omarchy instal·la un fitxer de polítiques amb valors predeterminats sensats i els posa en mode Wayland natiu, que és el que vols per a l'escalat fraccionari i un desplaçament suau amb el panell tàctil.

No tenen les extensions de Chromium de dalt, i Omarchy no els tematitza, així que aquestes parts de l'experiència les has de configurar tu.

## Tornar a eliminar-ne un

Qualsevol d'aquests navegadors, Chrome inclòs, es pot tornar a treure a _Elimina > Navegador_. Aleshores els enllaços aniran a Chrome o a Chromium si l'altre encara està instal·lat.
