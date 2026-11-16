# Navegació

Tot a Omarchy passa pel teclat — _TOT!_ Quan el sistema s'inicia per primera vegada, literalment no pots fer res només amb el ratolí. Però pots prémer `Super + Space` per mostrar el menú d'Omarchy i des d'aquí pots fer pràcticament de tot.

Però el menú d'Omarchy ni tan sols està pensat per ser la manera principal d'operar el sistema la major part del temps. Podem anar més ràpid que això! Totes les aplicacions més importants estan assignades directament a tecles d'accés ràpid individuals. Inicies el terminal amb `Super + Return` i un navegador amb `Super + Shift + Return`. Prova de fer una cosa després de l'altra, i veuràs la màgia del mosaic de Hyprland en acció:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Després pots prémer `Super + J` per apilar-les una sobre l'altra en lloc de costat a costat:

 ![navigation-stacked](images/navigation-stacked.webp)

Prem `Super + J` una altra vegada per tornar-les a les posicions costat a costat. Després prova `Super + Shift + Arrow Right` mentre ets al navegador per intercanviar les finestres.

Ara prova `Super + Shift + T` per iniciar el monitor d'activitat. Apareixerà com a finestra flotant. La pots posar en mosaic amb `Super + T` (i prem-ho una altra vegada per fer-la flotant de nou). Ara prem `Super + Shift + F` per obrir el gestor de fitxers. Tindràs una configuració ben ordenada de quatre finestres:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Navegues entre la finestra que vols que estigui activa amb `Super + Arrow`. Això canviarà el focus i mourà el cursor al centre de la nova aplicació. A la vora d'una pantalla, continua cap al monitor d'aquell costat.

Si prems `Super + Shift + 2`, mouràs l'aplicació enfocada actualment al segon espai de treball. `Super + Shift + 1` la torna a moure enrere. (I `Super + Shift + Alt + 2` mourà l'aplicació enfocada actualment al segon espai de treball sense canviar-hi).

Amb més d'un monitor, cada monitor té els seus propis espais de treball de l'1 al 10. `Super + 2` va al segon espai de treball del monitor on et trobes, i la barra superior de cada monitor mostra els seus propis espais de treball i el que està mostrant. `Super + Tab` recorre en cicle els espais de treball del monitor on et trobes. `Super + Shift + Ctrl + Arrows` mou la finestra on et trobes al monitor en aquella direcció, a l'espai de treball que està mostrant, i `Super + Shift + Alt + Arrows` mou l'espai de treball on et trobes al monitor en aquella direcció, on agafa el mateix número si està lliure. Un monitor conserva els seus espais de treball quan el desconnectes: s'uneixen als d'una altra pantalla, numerats després dels que ja té, i tornen amb els seus números antics quan el monitor torna.

Si mantens premut `Super` i fas servir el ratolí per fer clic en una finestra, podràs reorganitzar on se situa. Si mantens premut `Super` i fas servir el botó dret del ratolí, pots redimensionar la finestra lliurement.

Tanques una finestra amb `Super + W` o `Super + Q` (i tanques totes les finestres amb `Ctrl + Alt + Delete`).

També pots anar a pantalla completa amb `Super + F` o fins i tot només a amplada completa (mantenint la barra superior) amb `Super + Alt + F` o a pantalla completa dins d'una finestra amb `Super + Ctrl + F` (perfecte per a YouTube!).

### Disposició dwindle vs. disposició de desplaçament

La disposició per defecte d'Omarchy s'anomena dwindle. Manté totes les finestres que obres en un sol espai de treball visibles en tot moment, fins i tot si ha de reduir-les.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Però també pots triar convertir un espai de treball en la disposició de desplaçament, on les finestres s'alineen costat a costat, més enllà de la vora visible de la pantalla. Converteixes un sol espai de treball en aquesta disposició mitjançant `Super + L`.

Prémer `Super + L` una altra vegada fa l'espai de treball flotant, on les finestres se superposen lliurement i les col·loques tu mateix, i una tercera pressió el retorna a dwindle. `Super + Alt + L` les recorre en l'ordre invers. Una finestra que de totes maneres flota — una que has fet sortir amb `Super + T`, o una aplicació que sempre s'obre flotant — continua flotant quan l'espai de treball torna al mosaic. La barra superior marca l'espai de treball on et trobes amb la seva disposició: un quadrat per a dwindle, un cercle per a desplaçament i un triangle per a flotant. Fer clic en aquesta marca també canvia la disposició en cicle.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

L'elecció és per espai de treball, i es manté. Així pots mantenir l'espai de treball 1 en dwindle per navegar i l'espai de treball 2 en desplaçament per a codi, i tornaran així després d'un reinici.

Si vols fer servir la disposició de desplaçament com a predeterminada, pots configurar-ho a `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Espais de treball flotants

Un espai de treball flotant funciona com un escriptori tradicional: les finestres se superposen, i les mous i en canvies la mida tu mateix. Cada finestra rep una barra de títol amb els colors del teu tema, amb botons per minimitzar, maximitzar i tancar. `Super + M` també minimitza la finestra enfocada. Una finestra minimitzada espera al dock; fes clic a la seva aplicació per fer-la tornar. Fes clic en una finestra per portar-la al davant. Redimensiona-la des de qualsevol vora o cantonada. Fes doble clic en una barra de títol per maximitzar la finestra mantenint la barra superior a la vista, i una altra vegada per recuperar la seva mida antiga. Chrome i altres navegadors basats en Chromium, Disks i Document Viewer se salten la barra de títol i fan servir la seva pròpia capçalera; `Super + Alt + F` els maximitza, i `Super + M` els minimitza.

Un espai de treball flotant també mostra un dock, amb les teves aplicacions fixades, tot el que s'està executant, i una graella de totes les aplicacions darrere del botó d'aplicacions, que `Super + Alt + Space` i _Apps_ al menú d'Omarchy també obren. Fes clic amb el botó dret en una aplicació de la graella, o prem `Delete`, per desinstal·lar-la. Fes clic en una aplicació per obrir-la, o per portar la seva finestra al davant; fes clic una altra vegada per recórrer en cicle les seves finestres. Files només fa tornar una finestra de l'espai de treball on et trobes i, en cas contrari, n'obre una de nova, i Terminal i Agent sempre n'inicien una altra, tot i que una finestra minimitzada torna primer. El clic central obre una finestra nova. Arrossega una icona al llarg del dock per moure-la; arrossegar una aplicació en execució entre les altres la manté allà. Fes clic amb el botó dret per mantenir una aplicació al dock, treure-la'n o sortir-ne. El dock s'aparta davant d'una finestra a pantalla completa. Fes clic amb el botó dret al botó d'aplicacions per moure el dock a una altra vora o fer que s'amagui fins que el punter arribi a la seva vora. La posició també es troba a _Appearance > Dock > Dock Position_, i `omarchy dock position left` i `omarchy dock autohide on` configuren totes dues coses des d'un terminal. Les aplicacions que mantens al dock apareixen esvaïdes mentre no s'estan executant.

Els espais de treball nous, i qualsevol al qual no hagis donat una disposició pròpia amb `Super + L`, fan servir la disposició per defecte. Canviar la predeterminada restableix tots els espais de treball sense finestres a aquesta, mentre que un que té finestres manté la disposició que té. Una finestra minimitzada al dock continua comptant com a finestra de l'espai de treball que va deixar. Tria-la a _Appearance > Workspace Layout_: Tiling, Scrolling o Floating. `omarchy-hyprland-workspace-layout-default scrolling` la configura des d'un terminal.

### Agrupació de finestres

Les finestres es poden agrupar amb `Super + G`. Una vegada que ets en un grup, totes les finestres que iniciïs mentre aquest estigui actiu pertanyeran al grup. Pots moure't entre aquestes finestres agrupades amb `Super + Ctrl + Arrow Left/Right` o `Super + Alt + 1/2/3/4` per anar directament a les finestres agrupades en ordre.

Pots moure una finestra fora de l'agrupació amb `Super + Alt + G` o desmuntar tot el grup prement `Super + G` una altra vegada. Finalment, pots moure finestres de fora del grup cap a dins amb `Super + Alt + Arrows`.

### Fer sortir les finestres

Pots fer sortir una finestra de la seva assignació d'espai de treball amb `Super + O`. Això la fixarà com a finestra flotant que et segueix a qualsevol espai de treball on vagis. Perfecte per a reproductors de vídeo i similars.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Espai de treball de borrador

Hi ha un espai de treball de borrador especial de mida completa que se superposa a l'espai de treball on et trobes actualment. Accedeixes al que hi ha amb `Super + S`, i hi col·loques finestres amb `Super + Alt + S`.

Funciona bé per a controls o un terminal amb què vols interactuar ràpidament sense abandonar l'espai de treball actual.

### Consola Quake

Finalment, hi ha una consola Quake de mitja alçada que cau desplegant-se sobre l'espai de treball on et trobes actualment. Activa-la i desactiva-la amb `Super + Grave`, i col·loca-hi una finestra amb `Super + Shift + Grave`.

S'obre amb el teu agent per defecte a punt per començar. Mentre la consola conté una sola finestra, cau com a panell centrat en lloc d'abastar tota la pantalla. Col·loca-hi una segona aplicació i torna a l'amplada completa, perquè les dues tinguin espai per situar-se costat a costat.

Per moure una finestra fora tant del borrador com de la consola, envia-la directament a un altre espai de treball amb alguna cosa com `Super + Shift + 1`.

### Cal acostumar-s'hi una mica!

Triga una mica a acostumar-se a navegar pel teu escriptori així, però una vegada que ho fas, serà difícil tornar a una experiència d'escriptori tradicional controlada amb el ratolí!
