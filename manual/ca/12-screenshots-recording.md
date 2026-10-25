# Captures de pantalla i enregistrament

Tot el que pots capturar de la pantalla penja de la tecla Print Screen. Una tecla sola fa una foto, i els modificadors fan un enregistrament, un color o el text dins d'una regió. Si el teu teclat no té cap tecla Print Screen, `Super + Ctrl + Alt + C` fa la mateixa captura de pantalla, i `Super + Ctrl + C` obre tot el conjunt com a menú.

| Drecera | Funció |
| ------ | -------- |
| `Print Screen` | Captura de pantalla |
| `Super + Ctrl + Alt + C` | Captura de pantalla |
| `Alt + Print Screen` | Enregistrament de pantalla (o atura el que està en marxa) |
| `Super + Print Screen` | Selector de color |
| `Super + Ctrl + Print Screen` | Extreu text d'una regió |
| `Super + Ctrl + C` | Menú de captura |
| `Super + Ctrl + .` | Transcodifica una imatge o un vídeo |

## Captures de pantalla

Prem `Print Screen` (o `Super + Ctrl + Alt + C`) i Omasnap captura el monitor enfocat abans que aparegui la seva superposició, de manera que res no es mou sota teu mentre apuntes. Arrossega una regió de forma lliure, fes clic en una finestra per capturar-la o fes clic en un espai obert per capturar tot el monitor. Prem `S` abans de dibuixar per capturar una regió amb desplaçament. Has canviat d'idea? Torna a prémer la mateixa tecla per tancar Omasnap.

Després de seleccionar una àrea, Omasnap desa la captura, la copia al porta-retalls i mostra una vista prèvia durant 10 segons. Fes servir el botó de fixar de la vista prèvia o `Ctrl + P` per mantenir-la a la pantalla, o tria Edit per anotar-la.

L'editor d'anotacions pot dibuixar fletxes, línies, formes, ressaltats, marcadors numerats, text i redaccions segures; retallar o tallar part de la imatge; fer OCR del seu text; i afegir-hi un fons. A l'editor, prem `Enter` per copiar i desar el PNG acabat, `Ctrl + C` per copiar-lo sense desar-lo, o `Ctrl + S` per desar-lo sense copiar-lo.

Les captures de pantalla desades van a parar a `~/Pictures/Screenshots` per defecte, amb un nom com ara `screenshot-2026-08-13_14-22-05-firefox.png`. Defineix `OMASNAP_SCREENSHOT_DIR` per fer servir un altre directori — consulta [les FAQ](46-faq.md) per saber on posar les variables d'entorn de la sessió. Omasnap crea el directori quan desa la primera captura. Defineix `[output] autosave = false` a `~/.config/omasnap/omasnap.conf` per desactivar el desament automàtic.

Des del terminal, `omarchy screenshot` obre la mateixa superposició, i en pots triar el mode inicial: `omarchy capture screenshot region`, `windows`, `fullscreen` o `scroll`. Un segon argument de `copy` o `save` omet la vista prèvia i envia la captura directament a aquella destinació. Per editar abans de la sortida, fes servir `omarchy screenshot --editor=overlay` per a un editor a pantalla completa o `omarchy screenshot --editor=window` per a una finestra separada.

### Controlar el selector des del teclat

Mentre la selecció és oberta, no cal que facis servir el ratolí per a res:

| Tecla | Funció |
| --- | -------- |
| `S` | Alterna el mode de regió amb desplaçament |
| `Super + Arrow keys` | Mou-te entre finestres en el mode de finestra |
| `Return` | Captura la finestra ressaltada |
| `Ctrl + A` | Captura tot el monitor enfocat |
| `R` | Restaura l'última regió dibuixada en aquesta sessió |
| `Esc` | Tanca Omasnap |

Aquestes dreceres només existeixen mentre Omasnap és obert, així que no poden entrar en conflicte amb res de la teva pròpia configuració.

## Enregistrament de pantalla

`Alt + Print Screen` obre _Trigger > Capture > Screenrecord_, que et pregunta què vols a la banda sonora: sense àudio, àudio de l'escriptori, escriptori més micròfon, o escriptori més micròfon més càmera web. Aquesta última opció només apareix si tens realment una càmera connectada. Tria'n una i el selector d'enregistrament d'Omarchy et permet arrossegar una regió o fer clic en una finestra o un monitor.

L'enregistrament funciona amb gpu-screen-recorder, que codifica a la GPU a 60fps i recorre a la CPU si no li queda més remei. El resultat és un MP4 a `~/Videos`, amb el nom `screenrecording-2026-08-13_14-22-05.mp4`. Defineix `OMARCHY_SCREENRECORD_DIR` per canviar-ho — però tingues en compte que, a diferència del directori de captures de pantalla, aquest ha d'existir prèviament, o l'enregistrament es negarà a començar.

Mentre enregistres, apareix un petit indicador a la barra. Fes-hi clic per aturar. També pots aturar amb `Alt + Print Screen` de nou, o amb l'entrada _Stop Screenrecording_ a _Trigger > Capture > Screenrecord_, que només apareix mentre realment s'està enregistrant alguna cosa.

Aturar fa una mica d'ordre abans de lliurar-te el fitxer: es retalla el primer fotograma, i si hi ha àudio es normalitza a -14 LUFS amb l'espetec de captura de PipeWire del principi totalment silenciat. Després apareix una notificació amb una miniatura de l'enregistrament. Fes-hi clic per reproduir el fitxer a mpv.

### La superposició de la càmera web

Quan enregistres amb una càmera web, la càmera apareix com una finestra de retrat fixada i retallada a la cantonada inferior dreta del que estiguis enregistrant. Si queda a sobre d'alguna cosa que necessites, redimensiona-la sobre la marxa:

| Drecera | Funció |
| ------ | -------- |
| `Super + Alt + [` | Fes més petita la superposició de la càmera web |
| `Super + Alt + ]` | Fes més gran la superposició de la càmera web |

Hi ha tres mides — petita, mitjana i gran — i les dreceres passen d'una a l'altra. La mitjana és la predeterminada. Són proporcionals a l'enregistrament, de manera que la càmera ocupa la mateixa part del fotograma tant si enregistres un monitor de 1080p com un de 6K. I si has enregistrat una regió en lloc d'una pantalla sencera, la superposició s'ancora a la cantonada d'aquella regió en lloc de la del monitor, així que es queda dins de la presa.

També pots cridar-la directament amb `omarchy-capture-webcam-resize small`, o `reset` per tornar a la mitjana.

## Text, codis QR i colors

`Super + Ctrl + Print Screen` selecciona una regió i en fa OCR al porta-retalls. Això es tracta com cal a [Extracció de text i dictat](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ fa el mateix truc amb els codis QR. Selecciona la regió amb el codi a dins, i el valor descodificat va al porta-retalls. Només busca codis QR — el contingut dens de la pantalla té el costum de donar falsos positius com a codi de barres en cas contrari. Val la pena saber-ho: el valor descodificat va al porta-retalls i enlloc més. No s'imprimeix, no és a la notificació i està marcat com a sensible perquè no es quedi a l'[historial del porta-retalls](08-unified-clipboard-history.md). Els codis QR solen portar secrets — l'URI `otpauth://` darrere d'un codi de configuració 2FA, per exemple — i no vols això en un registre. Enganxar continua funcionant bé.

`Super + Print Screen` (o _Trigger > Capture > Color_) converteix el cursor en un comptagotes. Fes clic en qualsevol cosa de la pantalla i el color va a parar al porta-retalls. Torna a prémer la drecera per sortir sense triar-ne cap.

## Transcodificar abans de compartir

Un enregistrament de pantalla en 4K o un HEIC en brut del teu telèfon sovint és massa gran per enviar-lo sense més. `Super + Ctrl + .` (o _Trigger > Transcode_) ho soluciona. T'ofereix un selector de fitxers difús sobre `~/Pictures` i `~/Videos`, i després et demana un format i una mida.

Les imatges van a jpg o png en alta, mitjana o baixa, que limiten l'amplada a 3160, 2160 i 1080 píxels. Els vídeos van a mp4 o a un gif animat en 4k, 1080p o 720p. El fitxer convertit s'escriu al costat de l'original amb la resolució al nom — `demo-1080p.mp4` — i el camí es copia al porta-retalls com a URI de fitxer, de manera que el pots enganxar directament en una aplicació que accepti fitxers deixats anar.

També funciona des del terminal, si ja saps què vols: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. També hi ha `omarchy transcode ascii`, que converteix una imatge en art ASCII — aquest és sobretot per a [la marca](41-branding.md).

## Enviar-ho en algun lloc

Un cop tens el fitxer, `Super + Ctrl + S` obre el menú Share i l'envia a un altre dispositiu de la teva xarxa mitjançant LocalSend. Consulta [GUIs](22-guis.md) per a això.
