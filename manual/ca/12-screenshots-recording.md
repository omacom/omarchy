# Captures de pantalla i gravació

Tot el que podeu agafar de la pantalla penja de la tecla Print Screen. Una sola tecla fa una foto, i els modificadors fan una gravació, un color o el text dins d'una regió. Si el vostre teclat no té tecla Print Screen, `Super + Ctrl + C` obre el mateix conjunt com a menú.

| Drecera | Funció |
| ------ | -------- |
| `Print Screen` | Captura de pantalla |
| `Alt + Print Screen` | Gravació de pantalla (o atura la que s'està executant) |
| `Super + Print Screen` | Selector de color |
| `Super + Ctrl + Print Screen` | Extreu text d'una regió |
| `Super + Ctrl + C` | Menú de captura |
| `Super + Ctrl + .` | Transcodifica una imatge o un vídeo |

## Captures de pantalla

Premeu `Print Screen` i Omasnap captura el monitor enfocat abans que aparegui la seva superposició, de manera que res es mou sota vostre mentre apunteu. Arrossegueu una regió lliure, feu clic en una finestra per capturar-la, o feu clic en un espai obert per capturar tot el monitor. Premeu `S` abans de dibuixar per capturar una regió amb desplaçament. Heu canviat d'idea? Torneu a prémer `Print Screen` per descartar Omasnap.

Després de seleccionar una àrea, Omasnap desa la captura, la copia al porta-retalls i mostra una previsualització durant 10 segons. Feu servir el botó de fixar de la previsualització o `Ctrl + P` per mantenir-la a la pantalla, o trieu Edita per anotar-la.

L'editor d'anotacions pot dibuixar fletxes, línies, formes, ressaltats, marcadors numerats, text i redaccions segures; retallar o tallar part de la imatge; aplicar OCR al seu text; i afegir-hi un fons. A l'editor, premeu `Enter` per copiar i desar el PNG acabat, `Ctrl + C` per copiar-lo sense desar-lo, o `Ctrl + S` per desar-lo sense copiar-lo.

Les captures de pantalla desades van a `~/Pictures/Screenshots` per defecte, amb un nom com `screenshot-2026-08-13_14-22-05-firefox.png`. Definiu `OMASNAP_SCREENSHOT_DIR` per fer servir un altre directori — vegeu [les preguntes freqüents](46-faq.md) per saber on posar les variables d'entorn de la sessió. Omasnap crea el directori quan desa la primera captura. Definiu `[output] autosave = false` a `~/.config/omasnap/omasnap.conf` per desactivar el desament automàtic.

Des del terminal, `omarchy screenshot` obre la mateixa superposició, i en podeu triar el mode inicial: `omarchy capture screenshot region`, `windows`, `fullscreen` o `scroll`. Un segon argument de `copy` o `save` omet la previsualització i envia la captura directament a aquesta destinació. Per editar abans de la sortida, feu servir `omarchy screenshot --editor=overlay` per a un editor a pantalla completa o `omarchy screenshot --editor=window` per a una finestra separada.

### Conduir el selector des del teclat

Mentre la selecció és visible, no heu de fer servir el ratolí en absolut:

| Tecla | Funció |
| --- | -------- |
| `S` | Commuta el mode de regió amb desplaçament |
| `Super + Arrow keys` | Mou-te entre finestres en mode Finestra |
| `Return` | Captura la finestra ressaltada |
| `Ctrl + A` | Captura tot el monitor enfocat |
| `R` | Restaura la darrera regió dibuixada en aquesta sessió |
| `Esc` | Descarta Omasnap |

Aquestes assignacions només existeixen mentre Omasnap és obert, de manera que no poden topar amb res de la vostra configuració.

## Gravació de pantalla

`Alt + Print Screen` obre _Activa > Captura > Grava la pantalla_, que pregunta què voleu a la banda sonora: sense àudio, àudio d'escriptori, escriptori més micròfon, o escriptori més micròfon més webcam. Aquesta darrera només apareix si realment teniu una càmera connectada. Trieu-ne una i el selector de gravació d'Omarchy us permet arrossegar una regió o fer clic en una finestra o un monitor.

La gravació funciona amb gpu-screen-recorder, que codifica a la GPU a 60 fps i recorre a la CPU si cal. El resultat és un MP4 a `~/Videos`, anomenat `screenrecording-2026-08-13_14-22-05.mp4`. Definiu `OMARCHY_SCREENRECORD_DIR` per canviar-ho — però tingueu en compte que, a diferència del directori de captures de pantalla, aquest ha d'existir ja, o la gravació es nega a començar.

Mentre graveu, un petit indicador apareix a la barra. Feu-hi clic per aturar-ho. També podeu aturar-ho amb `Alt + Print Screen` de nou, o amb l'entrada _Atura la gravació_ a _Activa > Captura > Grava la pantalla_, que només apareix mentre realment s'està gravant alguna cosa.

Aturar-ho fa una mica d'ordre abans de lliurar-vos el fitxer: es retalla el primer fotograma i, si hi ha àudio, es normalitza a -14 LUFS amb el clic de captura de PipeWire del començament silenciat. Després apareix una notificació amb una miniatura de la gravació. Feu-hi clic per reproduir el fitxer a mpv.

### La superposició de la webcam

Quan graveu amb una webcam, la càmera apareix com una finestra de retrat fixada i retallada a la cantonada inferior dreta del que esteu gravant. Si és damunt d'una cosa que necessiteu, redimensioneu-la sobre la marxa:

| Drecera | Funció |
| ------ | -------- |
| `Super + Alt + [` | Fes més petita la superposició de la webcam |
| `Super + Alt + ]` | Fes més gran la superposició de la webcam |

Hi ha tres mides — petita, mitjana i gran — i les dreceres hi passen d'una a l'altra. La mitjana és la predeterminada. Són proporcionals a la gravació, de manera que la càmera ocupa la mateixa part del fotograma tant si graveu un monitor de 1080p com un de 6K. I si heu gravat una regió en lloc de tota una pantalla, la superposició s'ancora a la cantonada d'aquesta regió en lloc de la del monitor, de manera que es manté dins de la presa.

També la podeu cridar directament amb `omarchy-capture-webcam-resize small`, o `reset` per tornar a la mitjana.

## Text, codis QR i colors

`Super + Ctrl + Print Screen` selecciona una regió i li aplica OCR al porta-retalls. Això es tracta com cal a [Extracció de text i dictat](11-text-extraction-dictation.md).

_Activa > Captura > Codi QR_ fa el mateix truc per als codis QR. Seleccioneu la regió amb el codi i el valor descodificat va al porta-retalls. Només busca codis QR — el contingut dens de la pantalla té el costum de donar falsos positius com a codi de barres altrament. Val la pena saber-ho: el valor descodificat va al porta-retalls i enlloc més. No s'imprimeix, no és a la notificació i es marca com a sensible perquè no es quedi a l'[historial del porta-retalls](08-unified-clipboard-history.md). Els codis QR porten secrets habitualment — l'URI `otpauth://` darrere d'un codi de configuració 2FA, per exemple — i no voleu això en un registre. Enganxar continua funcionant bé.

`Super + Print Screen` (o _Activa > Captura > Color_) converteix el cursor en un comptagotes. Feu clic en qualsevol cosa de la pantalla i el color va al porta-retalls. Torneu a prémer la drecera per sortir-ne sense triar res.

## Transcodificar abans de compartir

Una gravació de pantalla en 4K o un HEIC en brut del telèfon sovint és massa gran per enviar-lo sense més. `Super + Ctrl + .` (o _Activa > Transcodifica_) ho soluciona. Us ofereix un selector de fitxers difús sobre `~/Pictures` i `~/Videos` i després demana un format i una mida.

Les imatges van a jpg o png a alta, mitjana o baixa, que limiten l'amplada a 3160, 2160 i 1080 píxels. Els vídeos van a mp4 o a un gif animat a 4k, 1080p o 720p. El fitxer convertit s'escriu al costat de l'original amb la resolució al nom — `demo-1080p.mp4` — i la ruta es copia al porta-retalls com a URI de fitxer, de manera que el podeu enganxar directament en una aplicació que accepti fitxers arrossegats.

També funciona des del terminal, si ja sabeu què voleu: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. També hi ha `omarchy transcode ascii`, que converteix una imatge en art ASCII — aquesta és sobretot per a la [marca](41-branding.md).

## Enviar-ho en algun lloc

Un cop teniu el fitxer, `Super + Ctrl + S` obre el menú Comparteix i l'envia a un altre dispositiu de la vostra xarxa mitjançant LocalSend. Vegeu [interfícies gràfiques](22-guis.md) per a això.
