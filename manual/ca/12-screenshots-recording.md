# Captures de pantalla i enregistrament

Tot el que pots agafar de la pantalla penja de la tecla Print Screen. Una tecla sola fa una foto, i els modificadors fan un enregistrament, agafen un color o el text dins d'una regió. Si el teu teclat no té cap tecla Print Screen, `Super + Ctrl + Alt + C` fa la mateixa captura de pantalla, i `Super + Ctrl + C` obre tot el conjunt com a menú.

| Hotkey | Funció |
| ------ | -------- |
| `Print Screen` | Captura de pantalla |
| `Super + Ctrl + Alt + C` | Captura de pantalla |
| `Alt + Print Screen` | Enregistrament de pantalla (o atura el que està en marxa) |
| `Super + Print Screen` | Selector de color |
| `Super + Ctrl + Print Screen` | Extreu text d'una regió |
| `Super + Ctrl + C` | Menú de captura |
| `Super + Ctrl + .` | Transcodifica una imatge o un vídeo |

## Captures de pantalla

Prem `Print Screen` (o `Super + Ctrl + Alt + C`) i Omasnap captura el monitor enfocat abans que aparegui la seva capa superposada, de manera que res no es mou sota teu mentre apuntes. Arrossega una regió de forma lliure, fes clic en una finestra per capturar-la o fes clic en un espai obert per capturar tot el monitor. Prem `S` abans de dibuixar per capturar una regió amb desplaçament. Has canviat d'idea? Prem la mateixa tecla una altra vegada per tancar Omasnap.

Després de seleccionar una àrea, Omasnap desa la captura, la copia al porta-retalls i mostra una notificació amb la seva miniatura, com fa un enregistrament de pantalla desat. Tria Open per veure la captura desada al teu visualitzador d'imatges, o Edit per anotar-la.

L'editor d'anotacions pot dibuixar fletxes, línies, formes, ressaltats, marcadors numerats, text i redaccions segures; retallar o tallar part de la imatge; aplicar OCR al seu text; i afegir-hi un fons. A l'editor, prem `Enter` per copiar i desar el PNG final, `Ctrl + C` per copiar-lo sense desar-lo, o `Ctrl + S` per desar-lo sense copiar-lo.

Les captures de pantalla desades van a parar a `~/Pictures/Screenshots` per defecte, amb un nom com ara `screenshot-2026-08-13_14-22-05-firefox.png`. Defineix `OMASNAP_SCREENSHOT_DIR` per fer servir un altre directori: consulta [les preguntes freqüents](46-faq.md) per saber on posar les variables d'entorn de la sessió. Omasnap crea el directori quan desa la primera captura. Defineix `[output] autosave = false` a `~/.config/omasnap/omasnap.conf` per desactivar el desament automàtic; aleshores les captures només es copien, i es mostren en una vista prèvia durant 10 segons que pots mantenir en pantalla amb el seu botó de fixació o amb `Ctrl + P`.

Des del terminal, `omarchy screenshot` obre la mateixa capa superposada, i pots triar-ne el mode inicial: `omarchy capture screenshot region`, `windows`, `fullscreen` o `scroll`. Un segon argument de `copy` o `save` envia la captura directament a aquesta destinació. Per editar-la abans de la sortida, fes servir `omarchy screenshot --editor=overlay` per a un editor a pantalla completa o `omarchy screenshot --editor=window` per a una finestra separada.

### Com controlar el selector des del teclat

Mentre la selecció és oberta, no cal que facis servir el ratolí per a res:

| Key | Funció |
| --- | -------- |
| `S` | Activa o desactiva el mode de regió amb desplaçament |
| `Super + Arrow keys` | Mou-te entre finestres en el mode Window |
| `Return` | Captura la finestra ressaltada |
| `Ctrl + A` | Captura tot el monitor enfocat |
| `R` | Restaura l'última regió dibuixada en aquesta sessió |
| `Esc` | Tanca Omasnap |

Aquestes assignacions només existeixen mentre Omasnap és obert, així que no poden entrar en conflicte amb res de la teva pròpia configuració.

## Enregistrament de pantalla

`Alt + Print Screen` obre _Trigger > Capture > Screenrecord_, que et demana què vols a la banda sonora: sense àudio, àudio de l'escriptori, escriptori més micròfon, o escriptori més micròfon més càmera web. Aquesta última opció només apareix si realment tens una càmera connectada. Tria'n una i el selector d'enregistrament d'Omarchy et deixa arrossegar una regió o fer clic en una finestra o un monitor.

L'enregistrament funciona amb gpu-screen-recorder, que codifica a la GPU a 60fps i recorre a la CPU si no li queda més remei. El resultat és un MP4 a `~/Videos`, amb el nom `screenrecording-2026-08-13_14-22-05.mp4`. Defineix `OMARCHY_SCREENRECORD_DIR` per canviar-ho, però tingues en compte que, a diferència del directori de captures de pantalla, aquest ja ha d'existir, o l'enregistrament es negarà a començar.

Mentre enregistres, apareix un petit indicador a la barra. Fes-hi clic per aturar. També pots aturar amb `Alt + Print Screen` una altra vegada, o amb l'entrada _Stop Screenrecording_ dins de _Trigger > Capture > Screenrecord_, que només apareix mentre realment s'està enregistrant alguna cosa.

En aturar, fa una mica d'endreça abans de lliurar-te el fitxer: es retalla el primer fotograma i, si hi ha àudio, es normalitza a -14 LUFS amb l'espetec de captura de PipeWire del principi ben silenciat. Després apareix una notificació amb una miniatura de l'enregistrament. Fes-hi clic per reproduir el fitxer a mpv.

### La capa superposada de la càmera web

Quan enregistres amb una càmera web, la càmera apareix com una finestra vertical fixada i retallada a l'angle inferior dret del que estiguis enregistrant. Si queda a sobre d'alguna cosa que necessites, canvia'n la mida sobre la marxa:

| Hotkey | Funció |
| ------ | -------- |
| `Super + Alt + [` | Fes la capa superposada de la càmera web més petita |
| `Super + Alt + ]` | Fes la capa superposada de la càmera web més gran |

Hi ha tres mides —petita, mitjana i gran— i les dreceres passen d'una a l'altra. La mitjana és la predeterminada. Són proporcionals a l'enregistrament, així que la càmera ocupa la mateixa part del fotograma tant si enregistres un monitor de 1080p com un de 6K. I si has enregistrat una regió en lloc d'una pantalla sencera, la capa superposada s'ancora a l'angle d'aquesta regió en lloc del del monitor, així que es queda dins de la presa.

També pots cridar-ho directament amb `omarchy-capture-webcam-resize small`, o `reset` per tornar a la mida mitjana.

## Text, codis QR i colors

`Super + Ctrl + Print Screen` selecciona una regió i n'aplica l'OCR al porta-retalls. Això s'explica com cal a [Extracció de text i dictat](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ fa el mateix truc amb els codis QR. Selecciona la regió amb el codi i el valor descodificat va al porta-retalls. Només busca codis QR: el contingut dens de pantalla té el costum de donar falsos positius com a codi de barres en cas contrari. Val la pena saber-ho: el valor descodificat va al porta-retalls i enlloc més. No s'imprimeix, no és a la notificació i es marca com a sensible perquè no es quedi a l'[historial del porta-retalls](08-unified-clipboard-history.md). Els codis QR solen dur secrets —la URI `otpauth://` que hi ha darrere d'un codi de configuració de 2FA, per exemple— i no vols això en un registre. Enganxar continua funcionant perfectament.

`Super + Print Screen` (o _Trigger > Capture > Color_) converteix el cursor en un comptagotes. Fes clic en qualsevol cosa de la pantalla i el color anirà a parar al porta-retalls. Prem la drecera una altra vegada per sortir-ne sense triar res.

## Transcodificació abans de compartir

Un enregistrament de pantalla en 4K o un HEIC en brut del teu telèfon sovint és massa gran per enviar-lo sense més. `Super + Ctrl + .` (o _Trigger > Transcode_) ho soluciona. T'ofereix un selector de fitxers amb cerca difusa sobre `~/Pictures` i `~/Videos`, i després et demana un format i una mida.

Les imatges passen a jpg o png en qualitat alta, mitjana o baixa, que limiten l'amplada a 3160, 2160 i 1080 píxels. Els vídeos passen a mp4 o a un gif animat a 4k, 1080p o 720p. El fitxer convertit s'escriu al costat de l'original amb la resolució al nom —`demo-1080p.mp4`— i la ruta es copia al porta-retalls com a URI de fitxer, així que pots enganxar-la directament en una aplicació que accepti fitxers arrossegats.

També funciona des del terminal, si ja saps què vols: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. També hi ha `omarchy transcode ascii`, que converteix una imatge en art ASCII: aquest serveix sobretot per a la [imatge de marca](41-branding.md).

## Com enviar-ho en algun lloc

Un cop tens el fitxer, `Super + Ctrl + S` obre el menú Share i l'envia a un altre dispositiu de la teva xarxa mitjançant LocalSend. Consulta [GUIs](22-guis.md) per a això.
