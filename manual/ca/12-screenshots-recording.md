# Captures de pantalla i gravació

Tot el que pots capturar de la pantalla penja de la tecla Print Screen. Una tecla sola fa una foto, i els modificadors fan una gravació, agafen un color o el text de dins d'una regió. Si el teu teclat no té cap tecla Print Screen, `Super + Ctrl + Alt + C` fa la mateixa captura de pantalla, i `Super + Ctrl + C` obre tot el conjunt com a menú.

| Tecla de drecera | Funció |
| ------ | -------- |
| `Print Screen` | Captura de pantalla |
| `Super + Ctrl + Alt + C` | Captura de pantalla |
| `Alt + Print Screen` | Gravació de pantalla (o atura la que està en marxa) |
| `Super + Print Screen` | Selector de color |
| `Super + Ctrl + Print Screen` | Extreu el text d'una regió |
| `Super + Ctrl + C` | Menú de captura |
| `Super + Ctrl + .` | Transcodifica una imatge o un vídeo |

## Captures de pantalla

Prem `Print Screen` (o `Super + Ctrl + Alt + C`) i Omasnap captura el monitor amb el focus abans que aparegui la seva superposició, perquè res es mogui sota teu mentre apuntes. Arrossega una regió lliure, fes clic en una finestra per capturar-la o fes clic en un espai buit per capturar tot el monitor. Prem `S` abans de dibuixar per capturar una regió amb desplaçament. Has canviat d'idea? Prem la mateixa tecla una altra vegada per tancar Omasnap.

Després de seleccionar una àrea, Omasnap desa la captura, la copia al porta-retalls i mostra una notificació amb la seva miniatura, com fa una gravació de pantalla desada. Tria Obre per veure la captura desada al teu visualitzador d'imatges, o Edita per anotar-la.

L'editor d'anotacions pot dibuixar fletxes, línies, formes, ressaltats, marcadors numerats, text i redaccions segures; retallar o tallar part de la imatge; extreure'n el text amb OCR; i afegir-hi un fons. A l'editor, prem `Enter` per copiar i desar el PNG acabat, `Ctrl + C` per copiar-lo sense desar-lo, o `Ctrl + S` per desar-lo sense copiar-lo.

Les captures desades van a `~/Pictures/Screenshots` per defecte, amb un nom com ara `screenshot-2026-08-13_14-22-05-firefox.png`. Defineix `OMASNAP_SCREENSHOT_DIR` per fer servir un altre directori — consulta [les preguntes freqüents](46-faq.md) per saber on posar les variables d'entorn de la sessió. Omasnap crea el directori quan desa la primera captura. Defineix `[output] autosave = false` a `~/.config/omasnap/omasnap.conf` per desactivar el desament automàtic; aleshores les captures només es copien i es mostren en una vista prèvia durant 10 segons que pots mantenir a la pantalla amb el seu botó de fixació o amb `Ctrl + P`.

Des del terminal, `omarchy screenshot` obre la mateixa superposició, i en pots triar el mode inicial: `omarchy capture screenshot region`, `windows`, `fullscreen` o `scroll`. Un segon argument de `copy` o `save` envia la captura directament a aquesta destinació. Per editar abans de la sortida, fes servir `omarchy screenshot --editor=overlay` per a un editor a pantalla completa o `omarchy screenshot --editor=window` per a una finestra separada.

### Controlar el selector amb el teclat

Mentre la selecció està oberta, no cal que facis servir el ratolí per a res:

| Tecla | Funció |
| --- | -------- |
| `S` | Activa o desactiva el mode de regió amb desplaçament |
| `Super + Arrow keys` | Mou-te entre finestres en mode Finestra |
| `Return` | Captura la finestra ressaltada |
| `Ctrl + A` | Captura tot el monitor amb el focus |
| `R` | Restaura l'última regió dibuixada en aquesta sessió |
| `Esc` | Tanca Omasnap |

Aquestes assignacions només existeixen mentre Omasnap està obert, de manera que no poden entrar en conflicte amb res de la teva pròpia configuració.

## Gravació de pantalla

`Alt + Print Screen` obre _Trigger > Capture > Screenrecord_, que et demana què vols a la banda sonora: sense àudio, àudio de l'escriptori, escriptori més micròfon, o escriptori més micròfon més càmera web. Aquesta última opció només apareix si realment tens una càmera connectada. Tria'n una i el selector de gravació d'Omarchy et deixa arrossegar una regió o fer clic en una finestra o un monitor.

La gravació funciona amb gpu-screen-recorder, que codifica a la GPU a 60fps i recorre a la CPU si no li queda cap altre remei. El resultat és un MP4 a `~/Videos`, amb un nom com ara `screenrecording-2026-08-13_14-22-05.mp4`. Defineix `OMARCHY_SCREENRECORD_DIR` per canviar-ho — però tingues en compte que, a diferència del directori de captures de pantalla, aquest ja ha d'existir, o la gravació es nega a començar.

Mentre graves, apareix un petit indicador a la barra. Fes-hi clic per aturar-la. També la pots aturar amb `Alt + Print Screen` una altra vegada, o amb l'entrada _Stop Screenrecording_ de _Trigger > Capture > Screenrecord_, que només apareix mentre realment s'està gravant alguna cosa.

En aturar-la es fa una mica de neteja abans de lliurar-te el fitxer: es retalla el primer fotograma i, si hi ha àudio, es normalitza a -14 LUFS i se silencia l'espetec de captura de PipeWire del principi de tot. Després apareix una notificació amb una miniatura de la gravació. Fes-hi clic per reproduir el fitxer a Omaview.

### La superposició de la càmera web

Quan graves amb una càmera web, la càmera apareix com una finestra vertical retallada i fixada a l'angle inferior dret del que estiguis gravant. Si et tapa alguna cosa que necessites, canvia-li la mida sobre la marxa:

| Tecla de drecera | Funció |
| ------ | -------- |
| `Super + Alt + [` | Fes més petita la superposició de la càmera web |
| `Super + Alt + ]` | Fes més gran la superposició de la càmera web |

Hi ha tres mides — petita, mitjana i gran — i les tecles de drecera passen d'una a l'altra. La mitjana és la predeterminada. Són proporcionals a la gravació, de manera que la càmera ocupa la mateixa part del fotograma tant si graves un monitor de 1080p com un de 6K. I si has gravat una regió en lloc de tota una pantalla, la superposició s'ancora a l'angle d'aquesta regió en lloc del del monitor, perquè es quedi dins de la captura.

També la pots cridar directament amb `omarchy-capture-webcam-resize small`, o `reset` per tornar a la mitjana.

## Text, codis QR i colors

`Super + Ctrl + Print Screen` selecciona una regió i n'extreu el text amb OCR al porta-retalls. Això s'explica com cal a [Extracció de text i dictat](11-text-extraction-dictation.md).

_Trigger > Capture > QR Code_ fa el mateix truc amb els codis QR. Selecciona la regió que té el codi i el valor descodificat anirà al porta-retalls. Només busca codis QR — el contingut dens de la pantalla tendeix a donar falsos positius com a codi de barres en cas contrari. Val la pena saber-ho: el valor descodificat va al porta-retalls i enlloc més. No s'imprimeix, no és a la notificació i està marcat com a sensible perquè no es quedi a l'[historial del porta-retalls](08-unified-clipboard-history.md). Els codis QR solen portar secrets — la URI `otpauth://` que hi ha darrere d'un codi de configuració de 2FA, per exemple — i no vols que això acabi en un registre. Enganxar continua funcionant sense problemes.

`Super + Print Screen` (o _Trigger > Capture > Color_) converteix el cursor en un comptagotes. Fes clic a qualsevol cosa de la pantalla i el color anirà al porta-retalls. Prem la tecla de drecera una altra vegada per sortir-ne sense triar res.

## Transcodificació abans de compartir

Una gravació de pantalla en 4K o un HEIC en brut del teu telèfon sovint són massa grans per enviar-los sense més. `Super + Ctrl + .` (o _Trigger > Transcode_) ho soluciona. T'ofereix un selector de fitxers amb cerca difusa sobre `~/Pictures` i `~/Videos`, i després et demana un format i una mida.

Les imatges van a jpg o png en qualitat alta, mitjana o baixa, que limiten l'amplada a 3160, 2160 i 1080 píxels. Els vídeos van a mp4 o a un gif animat en 4k, 1080p o 720p. El fitxer convertit s'escriu al costat de l'original amb la resolució al nom — `demo-1080p.mp4` — i el camí es copia al porta-retalls com a URI de fitxer, perquè el puguis enganxar directament en una aplicació que accepti fitxers arrossegats.

També funciona des del terminal, si ja saps què vols: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. També hi ha `omarchy transcode ascii`, que converteix una imatge en art ASCII — aquest és sobretot per a [la imatge de marca](41-branding.md).

## Enviar-ho a algun lloc

Quan ja tens el fitxer, `Super + Ctrl + S` obre el menú Share i l'envia a un altre dispositiu de la teva xarxa via LocalSend. Consulta [GUIs](22-guis.md) per a això.
