# Navegació

Tot a Omarchy passa pel teclat — TOT! Quan el sistema s'inicia per primera vegada, literalment no pots fer res només amb el ratolí. Però pots prémer `Super + Space` per mostrar el menú d'Omarchy i des d'aquí pots fer pràcticament de tot.

Però el menú d'Omarchy ni tan sols està pensat per ser la manera principal d'utilitzar el sistema la major part del temps. Podem anar més ràpid que això! Totes les aplicacions més importants estan lligades directament a dreceres de teclat individuals. Inicies el terminal amb `Super + Return` i un navegador amb `Super + Shift + Return`. Prova de fer una cosa després de l'altra, i veuràs la màgia del mosaic de Hyprland en acció:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Després pots prémer `Super + J` per apilar-les una sobre l'altra en lloc de posar-les de costat:

 ![navigation-stacked](images/navigation-stacked.webp)

Prem `Super + J` una altra vegada per tornar-les a les seves posicions de costat. Després prova `Super + Shift + Arrow Right` mentre ets al navegador per intercanviar les finestres.

Ara prova `Super + Shift + T` per iniciar el monitor d'activitat. Això apareixerà com una finestra flotant. La pots posar en mosaic amb `Super + T` (i prem-ho una altra vegada per tornar-la a fer flotant). Ara prem `Super + Shift + F` per obrir el gestor de fitxers. Tindràs una configuració ben ordenada de quatre vies:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Navegues entre la finestra que vols que estigui activa amb `Super + Arrow`. Això canviarà el focus i mourà el cursor al centre de la nova aplicació. A la vora d'una pantalla, continua cap al monitor d'aquell costat.

Si prems `Super + Shift + 2`, mouràs l'aplicació enfocada actualment al segon espai de treball. `Super + Shift + 1` la torna a moure. (I `Super + Shift + Alt + 2` mourà l'aplicació enfocada actualment al segon espai de treball sense canviar-hi).

Amb més d'un monitor, cada monitor té els seus propis espais de treball de l'1 al 10. `Super + 2` va al segon espai de treball del monitor on ets, i la barra superior de cada monitor mostra els seus propis espais de treball i el que està mostrant. `Super + Tab` recorre els espais de treball del monitor on ets. `Super + Shift + Ctrl + Arrows` mou la finestra on ets al monitor en aquella direcció, a l'espai de treball que està mostrant, i `Super + Shift + Alt + Arrows` mou l'espai de treball on ets al monitor en aquella direcció, on agafa el mateix número si està lliure. Un monitor conserva els seus espais de treball quan el desconnectes: s'uneixen als d'una altra pantalla, numerats després dels que ja té, i tornen als seus números antics quan el monitor torna.

Si mantens premut `Super` i utilitzes el ratolí per fer clic en una finestra, podràs reorganitzar on se situa. Si mantens `Super` i utilitzes el botó dret del ratolí, pots redimensionar la finestra lliurement.

Tanques una finestra amb `Super + W` o `Super + Q` (i tanques totes les finestres amb `Ctrl + Alt + Delete`).

També pots anar a pantalla completa amb `Super + F` o fins i tot només a amplada completa (mantenint la barra superior) amb `Super + Alt + F` o a pantalla completa dins d'una finestra amb `Super + Ctrl + F` (molt bo per a YouTube!).

### Disposició dwindle vs. de desplaçament

La disposició per defecte d'Omarchy s'anomena dwindle. Manté totes les finestres que obres en un únic espai de treball visibles en tot moment, encara que hagi d'encongir-les.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Però també pots triar convertir un espai de treball en la disposició de desplaçament on les finestres s'alineen de costat, més enllà de la vora visible de la pantalla. Converteixes un únic espai de treball en aquesta disposició mitjançant `Super + L`.

Prémer `Super + L` una altra vegada converteix l'espai de treball en flotant, on les finestres se superposen lliurement i les col·loques tu mateix, i una tercera pulsació el torna a dwindle. `Super + Alt + L` els recorre en l'altra direcció. Una finestra que flota de totes maneres — una que has tret amb `Super + T`, o una aplicació que sempre s'obre flotant — continua flotant quan l'espai de treball torna al mosaic. La barra superior marca l'espai de treball on ets amb la seva disposició: un quadrat per a dwindle, un cercle per al desplaçament i un triangle per a flotant. Fer clic en aquesta marca també recorre la disposició, i també ho fa la tecla de pantalla als ordinadors portàtils que en tenen una.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

L'elecció és per espai de treball, i es manté. Així pots mantenir l'espai de treball 1 en dwindle per navegar i l'espai de treball 2 en desplaçament per al codi, i tornaran així després d'un reinici.

Si vols utilitzar la disposició de desplaçament com a per defecte, pots configurar-ho a `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Espais de treball flotants

Un espai de treball flotant funciona com un escriptori tradicional: les finestres se superposen, i les mous i en canvies la mida tu mateix. Cada finestra rep una barra de títol amb els colors del teu tema, amb botons per minimitzar, maximitzar i tancar. `Super + M` també minimitza la finestra enfocada. Una finestra minimitzada espera al dock; fes clic a la seva aplicació per recuperar-la. Fes clic en una finestra per portar-la al davant. Redimensiona-la des de qualsevol vora o cantonada. Fes doble clic en una barra de títol per maximitzar la finestra mantenint la barra superior a la vista, i una altra vegada per recuperar la seva mida antiga. Chrome i altres navegadors basats en Chromium, Disks i Document Viewer ometen la barra de títol i utilitzen la seva pròpia capçalera en lloc d'això; `Super + Alt + F` els maximitza, i `Super + M` els minimitza.

Un espai de treball flotant també mostra un dock, amb les teves aplicacions fixades, tot el que s'està executant, i una quadrícula de totes les aplicacions darrere del botó d'aplicacions, que `Super + Alt + Space` i _Apps_ al menú d'Omarchy també obren. Fes clic amb el botó dret en una aplicació de la quadrícula, o prem `Delete`, per desinstal·lar-la. Fes clic en una aplicació per obrir-la, o per portar la seva finestra al davant; fes clic una altra vegada per recórrer les seves finestres. Files només recupera una finestra de l'espai de treball on ets i altrament n'obre una de nova, i Terminal i Agent sempre n'inicien una altra, tot i que una finestra minimitzada torna primer. El clic central obre una finestra nova. Arrossega una icona al llarg del dock per moure-la; arrossegar una aplicació en execució entre les altres la manté allà. Fes clic amb el botó dret per mantenir una aplicació al dock, treure-la'n o sortir-ne. El dock s'aparta del camí d'una finestra a pantalla completa. Fes clic amb el botó dret al botó d'aplicacions per moure el dock a una altra vora o fer que s'amagui fins que el punter arribi a la seva vora. La posició també és a _Appearance > Dock > Dock Position_, i `omarchy dock position left` i `omarchy dock autohide on` configuren totes dues coses des d'un terminal. Les aplicacions que mantens al dock estan atenuades mentre no s'estan executant.

Els espais de treball nous, i qualsevol al qual no hagis donat una disposició pròpia amb `Super + L`, utilitzen la disposició per defecte. Canviar la per defecte restableix a ella tots els espais de treball sense finestres, mentre que un amb finestres manté la disposició que té. Una finestra minimitzada al dock continua comptant com una finestra a l'espai de treball que va deixar. Tria-la a _Appearance > Workspace Layout_: Tiling, Scrolling o Floating. `omarchy hyprland workspace layout default scrolling` ho configura des d'un terminal.

### Agrupar finestres

Les finestres es poden agrupar amb `Super + G`. Una vegada que ets en un grup, totes les finestres que iniciïs mentre aquest estigui actiu pertanyeran al grup. Pots moure't entre aquestes finestres agrupades amb `Super + Ctrl + Arrow Left/Right` o `Super + Alt + 1/2/3/4` per anar directament a les finestres agrupades en ordre.

Pots moure una finestra fora de l'agrupació amb `Super + Alt + G` o desmuntar tot el grup prement `Super + G` una altra vegada. Finalment, pots moure finestres de fora del grup cap a dins amb `Super + Alt + Arrows`.

### Treure finestres

Pots fer saltar una finestra fora de la seva assignació d'espai de treball amb `Super + O`. Això la fixarà com una finestra flotant que et segueix a qualsevol espai de treball on vagis. Perfecte per a reproductors de vídeo i similars.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Espai de treball scratchpad

Hi ha un espai de treball scratchpad especial de mida completa que se superposa a qualsevol espai de treball on siguis actualment. Accedeixes al que hi ha amb `Super + S`, i hi col·loques finestres amb `Super + Alt + S`.

Funciona bé per a controls o un terminal amb el qual vols interactuar ràpidament sense deixar l'espai de treball actual.

### Consola Quake

Finalment, hi ha una consola Quake de mitja alçada que cau sobre qualsevol espai de treball on siguis actualment. Activa-la i desactiva-la amb `Super + the key above Tab` (accent greu en les distribucions dels EUA), i col·loca-hi una finestra amb `Super + Shift + the key above Tab`.

La primera vegada que s'obre, inicia el teu agent per defecte, o et demana que en triïs un si encara no n'has triat cap. Mentre la consola conté una única finestra, baixa com un panell centrat en lloc d'estendre's per tota la pantalla. Posa-hi una segona aplicació i torna a l'amplada completa, perquè totes dues tinguin espai per estar de costat.

Per moure una finestra fora del scratchpad o de la consola, envia-la directament a un altre espai de treball amb alguna cosa com `Super + Shift + 1`.

### Cal una mica d'acostumar-s'hi!

Cal una mica de temps per acostumar-se a navegar per l'escriptori així, però una vegada que ho fas, serà difícil tornar a una experiència d'escriptori tradicional controlada amb el ratolí!
