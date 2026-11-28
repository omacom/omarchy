# Navegació

Tot a Omarchy passa pel teclat — _TOT!_ Quan el sistema s'inicia per primera vegada, literalment no pots fer res només amb el ratolí. Però pots prémer `Super + Space` per mostrar el menú d'Omarchy i des d'aquí pots fer pràcticament de tot.

Però el menú d'Omarchy ni tan sols està pensat per ser la manera principal de fer servir el sistema la major part del temps. Podem anar més ràpid que això! Totes les aplicacions més importants estan vinculades directament a dreceres de teclat individuals. Inicies el terminal amb `Super + Return` i un navegador amb `Super + Shift + Return`. Prova de fer una cosa rere l'altra, i veuràs la màgia del mosaic de Hyprland en acció:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Després pots prémer `Super + J` per apilar-les una sobre l'altra en lloc de posar-les una al costat de l'altra:

 ![navigation-stacked](images/navigation-stacked.webp)

Prem `Super + J` de nou per tornar-les a les posicions una al costat de l'altra. Després prova `Super + Shift + Arrow Right` mentre ets al navegador per intercanviar les finestres.

Ara prova `Super + Shift + T` per iniciar el monitor d'activitat. Apareixerà com una finestra flotant, amb una barra de títol per arrossegar-la i botons per minimitzar-la, maximitzar-la i tancar-la. Totes les finestres flotants en tenen una, sigui on sigui. Pots posar-la en mosaic amb `Super + T` (i prémer-ho de nou per tornar-la flotant). Ara prem `Super + Shift + F` per obrir el gestor de fitxers. Tindràs una configuració ben ordenada de quatre finestres:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Navegues entre les finestres per activar la que vols amb `Super + Arrow`. Això canviarà el focus i mourà el cursor al centre de la nova aplicació. A la vora d'una pantalla, continua fins al monitor d'aquell costat.

Si prems `Super + Shift + 2`, mouràs l'aplicació que té el focus actualment al segon espai de treball. `Super + Shift + 1` la torna a moure. (I `Super + Shift + Alt + 2` mourà l'aplicació que té el focus actualment al segon espai de treball sense canviar-hi).

Amb més d'un monitor, cada monitor té els seus propis espais de treball de l'1 al 10. `Super + 2` va al segon espai de treball del monitor on ets, i la barra superior de cada monitor mostra els seus propis espais de treball i el que està mostrant. `Super + Tab` recorre els espais de treball del monitor on ets. `Super + Shift + Ctrl + Arrows` mou la finestra on ets al monitor en aquella direcció, a l'espai de treball que està mostrant, i `Super + Shift + Alt + Arrows` mou l'espai de treball on ets al monitor en aquella direcció, on agafa el mateix número si està lliure. Un monitor conserva els seus espais de treball quan el desconnectes: s'uneixen als d'una altra pantalla, numerats després dels que ja té, i tornen als seus números antics quan el monitor torna.

Si mantens premut `Super` i fas servir el ratolí per fer clic en una finestra, podràs reorganitzar on està situada. Si mantens premut `Super` i fas servir el botó dret del ratolí, pots redimensionar la finestra lliurement.

Tanques una finestra amb `Super + W` o `Super + Q` (i tanques totes les finestres amb `Ctrl + Alt + Delete`).

També pots passar a pantalla completa amb `Super + F` o fins i tot només a tota l'amplada (mantenint la barra superior) amb `Super + Alt + F` o a pantalla completa dins d'una finestra amb `Super + Ctrl + F` (ideal per a YouTube!).

### Disposició dwindle vs. de desplaçament

La disposició per defecte d'Omarchy s'anomena dwindle. Manté totes les finestres que obres en un únic espai de treball visibles en tot moment, encara que hagi de reduir-les.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Però també pots triar convertir un espai de treball en la disposició de desplaçament, on les finestres s'alineen una al costat de l'altra, més enllà de la vora visible de la pantalla. Converteixes un únic espai de treball en aquesta disposició amb `Super + L`.

Prémer `Super + L` de nou fa que l'espai de treball sigui flotant, on les finestres se superposen lliurement i les col·loques tu mateix, i una tercera pulsació el torna a dwindle. `Super + Alt + L` les recorre en l'altre sentit. Una finestra que flota de totes maneres — una que has fet emergir amb `Super + T`, o una aplicació que sempre s'obre flotant — continua flotant quan l'espai de treball torna al mosaic. La barra superior marca l'espai de treball on ets amb la seva disposició: un quadrat per a dwindle, un cercle per a la de desplaçament i un triangle per a la flotant. Fer clic en aquesta marca també recorre les disposicions, i també ho fa la tecla de pantalla dels portàtils que en tenen una.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

L'elecció és per espai de treball, i es manté. Així pots mantenir l'espai de treball 1 en dwindle per navegar i l'espai de treball 2 en la de desplaçament per programar, i tornaran així després d'un reinici.

Si vols fer servir la disposició de desplaçament com a predeterminada, ho pots configurar a `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Espais de treball flotants

Un espai de treball flotant funciona com un escriptori tradicional: les finestres se superposen, i les mous i les redimensiones tu mateix. Cada finestra rep una barra de títol amb els colors del teu tema, amb botons per minimitzar, maximitzar i tancar. `Super + M` també minimitza la finestra que té el focus. Una finestra minimitzada espera al dock; fes clic a la seva aplicació per recuperar-la. Fes clic en una finestra per portar-la al davant. Redimensiona-la des de qualsevol vora o cantonada. Fes doble clic en una barra de títol per maximitzar la finestra mantenint la barra superior visible, i de nou per recuperar la seva mida antiga. Chrome i altres navegadors basats en Chromium, Disks i Document Viewer ometen la barra de títol i fan servir la seva pròpia capçalera; `Super + Alt + F` els maximitza, i `Super + M` els minimitza.

Cada espai de treball té un dock, amb les teves aplicacions fixades, tot el que s'està executant i una graella amb totes les aplicacions darrere del botó d'aplicacions, que `Super + Alt + Space` i _Apps_ al menú d'Omarchy també obren. Fes clic amb el botó dret en una aplicació de la graella, o prem `Delete`, per desinstal·lar-la. Fes clic en una aplicació per obrir-la, o per portar la seva finestra al davant; fes clic de nou per recórrer les seves finestres. Files només recupera una finestra de l'espai de treball on ets i, si no, n'obre una de nova, i Terminal i Agent sempre n'inicien una altra, tot i que una finestra minimitzada torna primer. El clic amb el botó central obre una finestra nova. Arrossega una icona al llarg del dock per moure-la; arrossegar una aplicació en execució entre les altres la manté allà. Fes clic amb el botó dret per mantenir una aplicació al dock, treure-la'n o tancar-la. El dock es manté visible mentre un espai de treball és buit, i un cop l'espai de treball té una finestra s'amaga fins que el punter arriba a la seva vora. Una finestra a pantalla completa l'amaga del tot. Arrossega el botó d'aplicacions cap a una altra vora de la pantalla per moure el dock allà. Fes-hi clic amb el botó dret per a _Position_, per triar una vora, _Layout_, per establir la disposició per defecte com fa _Appearance > Workspace Layout_, i _Visibility_, per mantenir el dock sempre visible, fer que la primera aplicació l'amagui, o mantenir-lo sempre amagat. `omarchy dock visibility always` ho estableix des d'un terminal. La posició també és a _Appearance > Dock > Dock Position_, i `omarchy dock position left` l'estableix des d'un terminal. Les aplicacions que mantens al dock apareixen atenuades mentre no s'estan executant. Per limitar el dock als espais de treball flotants, fes servir _Appearance > Dock > Dock Only on Floating_ o `omarchy dock tiling off`.

Els espais de treball nous, i qualsevol al qual no hagis donat una disposició pròpia amb `Super + L`, fan servir la disposició per defecte. Canviar la predeterminada restableix a aquesta tots els espais de treball sense finestres, mentre que un que té finestres manté la disposició que té. Una finestra minimitzada al dock encara compta com una finestra de l'espai de treball que va deixar. Tria-la a _Appearance > Workspace Layout_: Tiling, Scrolling o Floating. `omarchy hyprland workspace layout default scrolling` ho estableix des d'un terminal.

### Agrupació de finestres

Les finestres es poden agrupar amb `Super + G`. Un cop ets en un grup, totes les finestres que iniciïs mentre aquest estigui actiu pertanyeran al grup. Pots moure't entre aquestes finestres agrupades amb `Super + Ctrl + Arrow Left/Right` o `Super + Alt + 1/2/3/4` per anar directament a les finestres agrupades en ordre.

Pots treure una finestra de l'agrupació amb `Super + Alt + G` o desfer tot el grup prement `Super + G` de nou. Finalment, pots moure finestres de fora del grup cap a dins amb `Super + Alt + Arrows`.

### Fer emergir finestres

Pots fer emergir una finestra fora de la seva assignació d'espai de treball amb `Super + O`. Això la fixarà com una finestra flotant que et segueix a qualsevol espai de treball on vagis. Perfecte per a reproductors de vídeo i similars.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Espai de treball scratchpad

Hi ha un espai de treball scratchpad especial de mida completa que se superposa a l'espai de treball on ets actualment. Accedeixes al que hi ha amb `Super + S`, i hi col·loques finestres amb `Super + Alt + S`.

Funciona bé per a controls o un terminal amb el qual vols interactuar ràpidament sense sortir de l'espai de treball actual.

### Consola Quake

Finalment, hi ha una consola Quake de mitja alçada que cau sobre l'espai de treball on ets actualment. Activa-la i desactiva-la amb `Super + the key above Tab` (accent greu en les distribucions dels EUA), i col·loca-hi una finestra amb `Super + Shift + the key above Tab`.

La primera vegada que s'obre, inicia el teu agent per defecte, o et demana que en triïs un si encara no n'has triat cap. Mentre la consola conté una sola finestra, cau com un panell centrat en lloc d'ocupar tota la pantalla. Posa-hi una segona aplicació i torna a tota l'amplada, perquè les dues tinguin espai per estar una al costat de l'altra.

Per moure una finestra fora del scratchpad o de la consola, envia-la directament a un altre espai de treball amb una cosa com `Super + Shift + 1`.

### Cal acostumar-s'hi!

Cal una mica de temps per acostumar-se a navegar per l'escriptori així, però un cop ho facis, et costarà tornar a una experiència d'escriptori tradicional controlada amb el ratolí!
