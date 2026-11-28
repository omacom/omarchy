# Navegació

Tot a Omarchy passa pel teclat — _TOT!_ Quan el sistema s'inicia per primera vegada, literalment no pots fer res només amb el ratolí. Però pots prémer `Super + Space` per revelar el menú d'Omarchy i des d'aquí pots fer pràcticament de tot.

Però el menú d'Omarchy ni tan sols està pensat per ser la manera principal d'operar el sistema la major part del temps. Podem anar més ràpid que això! Totes les aplicacions més importants estan assignades directament a tecles d'accés ràpid individuals. Inicies el terminal amb `Super + Return` i un navegador amb `Super + Shift + Return`. Prova de fer una cosa després de l'altra, i veuràs en acció la màgia del mosaic de Hyprland:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Pots prémer llavors `Super + J` per apilar-les una damunt de l'altra en comptes de costat a costat:

 ![navigation-stacked](images/navigation-stacked.webp)

Prem `Super + J` de nou per tornar-les a les seves posicions costat a costat. Després prova `Super + Shift + Arrow Right` mentre ets al navegador per intercanviar les finestres.

Ara prova `Super + Shift + T` per iniciar el monitor Activity. Això apareixerà com una finestra flotant, amb una barra de títol per arrossegar-la i botons per minimitzar-la, maximitzar-la i tancar-la. Cada finestra flotant en rep una, sigui on sigui. Pots posar-la en mosaic amb `Super + T` (i prémer-ho de nou perquè torni a ser flotant). Ara prem `Super + Shift + F` per obrir el gestor de fitxers. Tindràs una configuració ben ordenada de quatre vies:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Et desplaces entre la finestra que vols que sigui activa amb `Super + Arrow`. Això canviarà el focus i mourà el cursor al centre de la nova aplicació. A la vora d'una pantalla, continua cap al monitor d'aquell costat.

Si prems `Super + Shift + 2`, mouràs l'aplicació activa actual al segon espai de treball. `Super + Shift + 1` la torna a moure enrere. (I `Super + Shift + Alt + 2` mourà l'aplicació activa actual al segon espai de treball sense canviar a aquest).

Amb més d'un monitor, cada monitor té els seus propis espais de treball de l'1 al 10. `Super + 2` va al segon espai de treball del monitor on ets, i la barra superior de cada monitor mostra els seus propis espais de treball i el que està mostrant. `Super + Tab` recorre en cicle els espais de treball del monitor on ets. `Super + Shift + Ctrl + Arrows` mou la finestra on ets al monitor en aquella direcció, a l'espai de treball que està mostrant, i `Super + Shift + Alt + Arrows` mou l'espai de treball on ets cap al monitor en aquella direcció, on agafa el mateix número si està lliure. Un monitor conserva els seus espais de treball quan el desconnectes: s'uneixen als d'una altra pantalla, numerats després dels que ja té, i tornen als seus números antics quan el monitor torna.

Si mantens premut `Super` i utilitzes el ratolí per fer clic en una finestra, podràs reorganitzar on se situa. Si mantens premut `Super` i utilitzes el botó dret del ratolí, pots redimensionar lliurement la finestra.

Tanques una finestra amb `Super + W` o `Super + Q` (i tanques totes les finestres amb `Ctrl + Alt + Delete`).

També pots anar a pantalla completa amb `Super + F` o fins i tot només a tota l'amplada (mantenint la barra superior) amb `Super + Alt + F` o a pantalla completa dins d'una finestra amb `Super + Ctrl + F` (ideal per a YouTube!).

### Disposició dwindle vs. de desplaçament

La disposició per defecte d'Omarchy s'anomena dwindle. Manté totes les finestres que obres en un únic espai de treball visibles en tot moment, encara que hagi de reduir-les.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Però també pots triar convertir un espai de treball en la disposició de desplaçament, on les finestres s'alineen costat a costat, més enllà de la vora visible de la pantalla. Converteixes un únic espai de treball en aquesta disposició amb `Super + L`.

Prémer `Super + L` de nou converteix l'espai de treball en flotant, on les finestres se superposen lliurement i les col·loques tu mateix, i una tercera pulsació el torna a dwindle. `Super + Alt + L` les recorre en l'altre sentit. Una finestra que flota de totes maneres — una que has tret amb `Super + T`, o una aplicació que sempre s'obre flotant — continua flotant quan l'espai de treball torna al mosaic. La barra superior marca l'espai de treball on ets amb la seva disposició: un quadrat per a dwindle, un cercle per a desplaçament i un triangle per a flotant. Fer clic en aquesta marca també recorre la disposició en cicle, i també ho fa la tecla de pantalla als portàtils que en tenen una.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

L'elecció és per espai de treball, i es manté. Així pots mantenir l'espai de treball 1 en dwindle per navegar i l'espai de treball 2 en desplaçament per al codi, i tornaran així després d'un reinici.

Si vols utilitzar la disposició de desplaçament com a predeterminada, pots definir-ho a `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Espais de treball flotants

Un espai de treball flotant funciona com un escriptori tradicional: les finestres se superposen, i les mous i les redimensiones tu mateix. Cada finestra rep una barra de títol amb els colors del teu tema, amb botons per minimitzar, maximitzar i tancar. `Super + M` també minimitza la finestra activa. Una finestra minimitzada espera al dock; fes clic a la seva aplicació per recuperar-la. Fes clic en una finestra per portar-la al davant. Redimensiona-la des de qualsevol vora o cantonada. Fes doble clic en una barra de títol per maximitzar la finestra mantenint la barra superior visible, i de nou per recuperar la seva mida antiga. Chrome i altres navegadors basats en Chromium, Disks i Document Viewer ometen la barra de títol i utilitzen en canvi la seva pròpia capçalera; `Super + Alt + F` els maximitza, i `Super + M` els minimitza.

Cada espai de treball té un dock, amb les teves aplicacions fixades, tot el que s'està executant, i una quadrícula de totes les aplicacions darrere del botó d'aplicacions, que `Super + Alt + Space` i _Aplicacions_ al menú d'Omarchy també obren. Fes clic dret en una aplicació de la quadrícula, o prem `Delete`, per desinstal·lar-la. Fes clic en una aplicació per obrir-la, o per portar la seva finestra al davant; fes clic de nou per recórrer en cicle les seves finestres. Files només recupera una finestra de l'espai de treball on ets i en cas contrari n'obre una de nova, i Terminal i Agent sempre n'inicien una altra, tot i que una finestra minimitzada torna primer. El clic central obre una finestra nova. Arrossega una icona al llarg del dock per moure-la; arrossegar una aplicació en execució entre les altres la hi manté. Fes clic dret per mantenir una aplicació al dock, treure-la'n o tancar-la. El dock es manté visible mentre un espai de treball és buit, i una vegada que l'espai de treball té una finestra s'amaga fins que el punter arriba a la seva vora. Una finestra a pantalla completa l'amaga del tot. Arrossega el botó d'aplicacions cap a una altra vora de la pantalla per moure-hi el dock. Fes-hi clic dret per a _Posició_, per triar una vora, i _Disposició_, per definir la disposició per defecte com fa _Aparença > Disposició de l'espai de treball_. La posició també és a _Aparença > Dock > Posició del dock_, i `omarchy dock position left` la defineix des d'un terminal. Les aplicacions que mantens al dock apareixen esvaïdes mentre no s'estan executant. Per limitar el dock als espais de treball flotants, utilitza _Aparença > Dock > Dock només en flotants_ o `omarchy dock tiling off`.

Els espais de treball nous, i qualsevol al qual no hagis donat una disposició pròpia amb `Super + L`, utilitzen la disposició per defecte. Canviar la predeterminada restableix a aquesta tots els espais de treball sense finestres, mentre que un que hi té finestres manté la disposició que té. Una finestra minimitzada al dock encara compta com una finestra a l'espai de treball que ha deixat. Tria-la a _Aparença > Disposició de l'espai de treball_: Mosaic, Desplaçament o Flotant. `omarchy hyprland workspace layout default scrolling` la defineix des d'un terminal.

### Agrupació de finestres

Les finestres es poden agrupar amb `Super + G`. Una vegada que ets en un grup, cada finestra que iniciïs mentre aquest estigui actiu pertanyerà al grup. Pots desplaçar-te entre aquestes finestres agrupades amb `Super + Ctrl + Arrow Left/Right` o `Super + Alt + 1/2/3/4` per anar directament a les finestres agrupades en ordre.

Pots moure una finestra fora de l'agrupació amb `Super + Alt + G` o desmuntar tot el grup prement `Super + G` de nou. Finalment, pots moure finestres de fora del grup a dins amb `Super + Alt + Arrows`.

### Extracció de finestres

Pots extreure una finestra de la seva assignació d'espai de treball amb `Super + O`. Això la fixarà com una finestra flotant que et segueix a qualsevol espai de treball on vagis. Ideal per a reproductors de vídeo i similars.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Espai de treball scratchpad

Hi ha un espai de treball scratchpad especial de mida completa que se superposa a qualsevol espai de treball on siguis actualment. Accedeixes al que hi ha amb `Super + S`, i hi col·loques finestres amb `Super + Alt + S`.

Funciona bé per a controls o un terminal amb què vols interactuar ràpidament sense deixar l'espai de treball actual.

### Consola Quake

Finalment, hi ha una consola Quake de mitja alçada que cau desplegada sobre qualsevol espai de treball on siguis actualment. Activa-la i desactiva-la amb `Super + the key above Tab` (accent greu en les distribucions dels EUA), i col·loca-hi una finestra amb `Super + Shift + the key above Tab`.

La primera vegada que s'obre, inicia el teu agent per defecte, o et demana que en triïs un si encara no n'has triat cap. Mentre la consola conté una única finestra, cau com un panell centrat en comptes d'estendre's per tota la pantalla. Posa-hi una segona aplicació i torna a tota l'amplada, perquè les dues tinguin espai per estar costat a costat.

Per moure una finestra fora tant del scratchpad com de la consola, envia-la directament a un altre espai de treball amb alguna cosa com `Super + Shift + 1`.

### Cal acostumar-s'hi!

Cal una mica de temps per acostumar-se a navegar per l'escriptori així, però una vegada que ho fas, serà difícil tornar a una experiència d'escriptori tradicional guiada pel ratolí!
