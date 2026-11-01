# Navegació

Tot a Omarchy passa pel teclat — _TOT!_ Quan el sistema s'inicia per primera vegada, literalment no pots fer res només amb el ratolí. Però pots prémer `Super + Space` per mostrar el menú d'Omarchy i des d'aquí pots fer pràcticament de tot.

Però el menú d'Omarchy ni tan sols està pensat per ser la manera principal de fer servir el sistema la major part del temps. Podem anar més ràpid que això! Totes les aplicacions més importants estan vinculades directament a dreceres de teclat individuals. Inicies el terminal amb `Super + Return` i un navegador amb `Super + Shift + Return`. Prova de fer-ne un darrere l'altre i veuràs la màgia del mosaic de Hyprland en acció:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Després pots prémer `Super + J` per apilar-les una sobre l'altra en comptes de costat a costat:

 ![navigation-stacked](images/navigation-stacked.webp)

Prem `Super + J` una altra vegada per tornar-les a les posicions costat a costat. Després prova `Super + Shift + Arrow Right` mentre ets al navegador per intercanviar les finestres.

Ara prova `Super + Shift + T` per iniciar el monitor d'activitat. Aquell apareixerà com una finestra flotant. Pots posar-lo en mosaic amb `Super + T` (i prémer-ho una altra vegada per tornar-lo flotant). Ara prem `Super + Shift + F` per obrir el gestor de fitxers. Tindràs una configuració ben ordenada de quatre finestres:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Navegues entre les finestres per activar la que vols amb `Super + Arrow`. Això canviarà el focus i mourà el cursor al centre de la nova aplicació. A la vora d'una pantalla, continua cap al monitor d'aquell costat.

Si prems `Super + Shift + 2`, mouràs l'aplicació que té el focus actualment al segon espai de treball. `Super + Shift + 1` la torna a moure enrere. (I `Super + Shift + Alt + 2` mourà l'aplicació que té el focus actualment al segon espai de treball sense canviar-hi).

Amb més d'un monitor, cada monitor té els seus propis espais de treball de l'1 al 10. `Super + 2` va al segon espai de treball del monitor on ets, i la barra superior de cada monitor mostra els seus propis espais de treball i el que està mostrant. `Super + Tab` passa cíclicament pels espais de treball del monitor on ets. `Super + Shift + Ctrl + Arrows` mou la finestra on ets al monitor en aquella direcció, a l'espai de treball que està mostrant, i `Super + Shift + Alt + Arrows` mou l'espai de treball on ets al monitor en aquella direcció, on pren el mateix número si està lliure. Un monitor conserva els seus espais de treball quan el desconnectes: s'uneixen als d'una altra pantalla, numerats després dels que aquesta ja té, i tornen als seus números antics quan el monitor torna.

Si mantens premut `Super` i fas servir el ratolí per fer clic en una finestra, podràs reordenar on està situada. Si mantens premut `Super` i fas servir el botó dret del ratolí, pots redimensionar la finestra lliurement.

Tanques una finestra amb `Super + W` o `Super + Q` (i tanques totes les finestres amb `Ctrl + Alt + Delete`).

També pots posar-ho a pantalla completa amb `Super + F` o fins i tot només a tota l'amplada (mantenint la barra superior) amb `Super + Alt + F` o a pantalla completa dins d'una finestra amb `Super + Ctrl + F` (ideal per a YouTube!).

### Dwindle contra disposició amb desplaçament

La disposició predeterminada d'Omarchy s'anomena dwindle. Manté totes les finestres que obres en un sol espai de treball visibles en tot moment, encara que hagi de reduir-les.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Però també pots triar convertir un espai de treball en la disposició amb desplaçament, on les finestres s'alineen costat a costat, més enllà de la vora visible de la pantalla. Converteixes un sol espai de treball en aquesta disposició amb `Super + L`.

Prémer `Super + L` una altra vegada fa que l'espai de treball sigui flotant, on les finestres se superposen lliurement i les col·loques tu mateix, i una tercera pulsació el torna a dwindle. `Super + Alt + L` hi passa en l'ordre invers. Una finestra que ja flota de totes maneres — una que has fet sortir amb `Super + T`, o una aplicació que sempre s'obre flotant — continua flotant quan l'espai de treball torna al mosaic. La barra superior marca l'espai de treball on ets amb la seva disposició: un quadrat per a dwindle, un cercle per a la disposició amb desplaçament i un triangle per a la flotant. Fer clic en aquella marca també fa passar cíclicament per les disposicions.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

La tria és per espai de treball i es manté. Així pots mantenir l'espai de treball 1 en dwindle per navegar i l'espai de treball 2 en disposició amb desplaçament per programar, i tornaran així després d'un reinici.

Si vols fer servir la disposició amb desplaçament com a predeterminada, pots configurar-ho a `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Espais de treball flotants

Un espai de treball flotant funciona com un escriptori tradicional: les finestres se superposen i les mous i en canvies la mida tu mateix. Cada finestra rep una barra de títol amb els colors del teu tema, amb botons per minimitzar, maximitzar i tancar. `Super + M` també minimitza la finestra que té el focus. Una finestra minimitzada espera al dock; fes clic a la seva aplicació per recuperar-la. Fes clic en una finestra per portar-la al davant. Redimensiona-la des de qualsevol vora o cantonada. Fes doble clic en una barra de títol per maximitzar la finestra mantenint la barra superior visible, i una altra vegada per recuperar la seva mida antiga.

Un espai de treball flotant també mostra un dock, amb les teves aplicacions fixades, tot el que s'està executant i una graella de totes les aplicacions darrere del botó d'aplicacions, que `Super + Alt + Space` i _Apps_ al menú d'Omarchy també obren. Fes clic dret en una aplicació de la graella, o prem `Delete`, per desinstal·lar-la. Fes clic en una aplicació per obrir-la, o per portar la seva finestra al davant; fes clic una altra vegada per passar cíclicament per les seves finestres. Fes clic amb el botó del mig per obrir una finestra nova. Arrossega una icona al llarg del dock per moure-la; arrossegar una aplicació en execució entre les altres la manté allà. Fes clic dret per mantenir una aplicació al dock, treure-la'n o sortir-ne. El dock s'aparta davant d'una finestra a pantalla completa. Fes clic dret al botó d'aplicacions per moure el dock a una altra vora o fer que s'amagui fins que el punter arribi a la seva vora. La posició també és a _Appearance > Dock > Dock Position_, i `omarchy dock position left` i `omarchy dock autohide on` configuren totes dues coses des d'un terminal. Les aplicacions que mantens al dock apareixen esvaïdes mentre no s'estan executant.

Els espais de treball nous, i qualsevol al qual no hagis donat una disposició pròpia amb `Super + L`, fan servir la disposició predeterminada. Canviar la predeterminada restableix a aquesta tots els espais de treball sense finestres, mentre que un que té finestres manté la disposició que té. Una finestra minimitzada al dock continua comptant com una finestra a l'espai de treball que ha deixat. Tria-ho a _Appearance > Workspace Layout_: Tiling, Scrolling o Floating. `omarchy-hyprland-workspace-layout-default scrolling` ho configura des d'un terminal.

### Agrupar finestres

Les finestres es poden agrupar amb `Super + G`. Un cop ets en un grup, cada finestra que iniciïs mentre aquell estigui actiu pertanyerà al grup. Pots moure't entre aquestes finestres agrupades amb `Super + Ctrl + Arrow Left/Right` o `Super + Alt + 1/2/3/4` per anar directament a les finestres agrupades en ordre.

Pots moure una finestra fora de l'agrupació amb `Super + Alt + G` o desfer tot el grup prement `Super + G` una altra vegada. Finalment, pots moure finestres de fora del grup cap a dins amb `Super + Alt + Arrows`.

### Extreure finestres

Pots extreure una finestra de la seva assignació d'espai de treball amb `Super + O`. Això la fixarà com una finestra flotant que et segueix a qualsevol espai de treball on vagis. Ideal per a reproductors de vídeo i coses semblants.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Espai de treball scratchpad

Hi ha un espai de treball scratchpad especial de mida completa que se superposa a qualsevol espai de treball on siguis actualment. Accedeixes al que hi ha amb `Super + S`, i hi poses finestres amb `Super + Alt + S`.

Funciona bé per a controls o un terminal amb què vols interactuar ràpidament sense deixar l'espai de treball actual.

### Consola Quake

Finalment, hi ha una consola Quake de mitja alçada que cau per sobre de qualsevol espai de treball on siguis actualment. Activa-la i desactiva-la amb `Super + Grave`, i posa-hi una finestra amb `Super + Shift + Grave`.

S'obre amb el teu agent predeterminat a punt per funcionar. Mentre la consola conté una sola finestra, cau com un panell centrat en comptes d'ocupar tota l'amplada de la pantalla. Posa-hi una segona aplicació i torna a l'amplada completa, perquè les dues tinguin espai per estar costat a costat.

Per moure una finestra fora del scratchpad o de la consola, envia-la directament a un altre espai de treball amb alguna cosa com `Super + Shift + 1`.

### Cal acostumar-s'hi una mica!

Cal una mica de temps per acostumar-se a navegar pel teu escriptori així, però un cop ho facis, et costarà tornar a una experiència d'escriptori tradicional guiada pel ratolí!
