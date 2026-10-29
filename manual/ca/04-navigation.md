# Navegació

Tot a Omarchy passa pel teclat — _TOT!_ Quan el sistema s'inicia per primera vegada, literalment no pots fer res només amb el ratolí. Però pots prémer `Super + Space` per mostrar el menú d'Omarchy i des d'aquí pots fer pràcticament de tot.

Però el menú d'Omarchy ni tan sols està pensat per ser la manera principal d'utilitzar el sistema la major part del temps. Podem anar més de pressa que això! Totes les aplicacions més importants estan vinculades directament a dreceres de teclat individuals. Inicies el terminal amb `Super + Return` i un navegador amb `Super + Shift + Return`. Prova de fer una cosa rere l'altra i veuràs la màgia del mosaic de Hyprland en acció:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Aleshores pots prémer `Super + J` per apilar-les una sobre l'altra en lloc de posar-les una al costat de l'altra:

 ![navigation-stacked](images/navigation-stacked.webp)

Prem `Super + J` de nou per tornar-les a les seves posicions una al costat de l'altra. Aleshores prova `Super + Shift + Arrow Right` mentre ets al navegador per intercanviar les finestres.

Ara prova `Super + Shift + T` per iniciar el monitor d'activitat. Apareixerà com una finestra flotant. Pots posar-la en mosaic amb `Super + T` (i prémer-ho de nou per tornar-la a fer flotant). Ara prem `Super + Shift + F` per obrir el gestor de fitxers. Tindràs una configuració ben ordenada de quatre elements:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Et desplaces entre les finestres per triar quina vols que estigui activa amb `Super + Arrow`. Això canviarà el focus i mourà el cursor al centre de la nova aplicació. A la vora d'una pantalla, continua cap al monitor d'aquell costat.

Si prems `Super + Shift + 2`, mouràs l'aplicació actualment enfocada al segon espai de treball. `Super + Shift + 1` la torna a moure enrere. (I `Super + Shift + Alt + 2` mourà l'aplicació actualment enfocada al segon espai de treball sense canviar a aquest espai).

Amb més d'un monitor, cada monitor té els seus propis espais de treball de l'1 al 10. `Super + 2` va al segon espai de treball del monitor on et trobes, i la barra superior de cada monitor mostra els seus propis espais de treball i el que està mostrant. `Super + Tab` recorre els espais de treball del monitor on et trobes. `Super + Shift + Ctrl + Arrows` mou la finestra on et trobes al monitor en aquella direcció, a l'espai de treball que aquest està mostrant, i `Super + Shift + Alt + Arrows` mou l'espai de treball on et trobes al monitor en aquella direcció, on pren el mateix número si està lliure. Un monitor conserva els seus espais de treball quan el desconnectes: s'uneixen als d'una altra pantalla, numerats després dels que aquesta ja té, i tornen als seus números antics quan el monitor torna.

Si mantens premuda `Super` i utilitzes el ratolí per fer clic en una finestra, podràs reorganitzar on està situada. Si mantens premuda `Super` i utilitzes el botó dret del ratolí, pots redimensionar la finestra lliurement.

Tanques una finestra amb `Super + W` o `Super + Q` (i tanques totes les finestres amb `Ctrl + Alt + Delete`).

També pots posar-la a pantalla completa amb `Super + F`, o fins i tot només a amplada completa (mantenint la barra superior) amb `Super + Alt + F`, o a pantalla completa dins d'una finestra amb `Super + Ctrl + F` (ideal per a YouTube!).

### Disposició dwindle enfront de la disposició amb desplaçament

La disposició per defecte d'Omarchy s'anomena dwindle. Manté totes les finestres que obres en un únic espai de treball visibles en tot moment, encara que hagi de reduir-les.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Però també pots triar convertir un espai de treball en la disposició amb desplaçament, on les finestres s'alineen una al costat de l'altra, més enllà de la vora visible de la pantalla. Converteixes un únic espai de treball en aquesta disposició mitjançant `Super + L`.

Prémer `Super + L` de nou converteix l'espai de treball en flotant, on les finestres se superposen lliurement i les col·loques tu mateix, i una tercera pressió el torna a dwindle. `Super + Alt + L` les recorre en l'altra direcció. Una finestra que flota de totes maneres —una que has extret amb `Super + T`, o una aplicació que sempre s'obre flotant— continua flotant quan l'espai de treball torna al mosaic. La barra superior marca l'espai de treball on et trobes amb la seva disposició: un quadrat per a dwindle, un cercle per a la disposició amb desplaçament i un triangle per a la flotant. Fer clic en aquesta marca també recorre les disposicions.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

L'elecció és per espai de treball, i es manté. Així, pots mantenir l'espai de treball 1 en dwindle per navegar i l'espai de treball 2 en la disposició amb desplaçament per al codi, i tornaran d'aquesta manera després d'un reinici.

Si vols utilitzar la disposició amb desplaçament com a disposició per defecte, pots configurar-ho a `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Espais de treball flotants

Un espai de treball flotant funciona com un escriptori tradicional: les finestres se superposen, i les mous i en canvies la mida tu mateix. Cada finestra rep una barra de títol amb els colors del teu tema, amb botons per minimitzar, maximitzar i tancar. `Super + M` també minimitza la finestra enfocada. Una finestra minimitzada espera al dock; fes clic a la seva aplicació per recuperar-la. Fes clic en una finestra per portar-la al davant. Redimensiona-la des de qualsevol vora o cantonada. Fes doble clic en una barra de títol per maximitzar la finestra mentre mantens la barra superior a la vista, i de nou per recuperar la seva mida antiga.

Un espai de treball flotant també mostra un dock, amb les aplicacions fixades, tot el que s'està executant i una quadrícula de totes les aplicacions darrere del botó d'aplicacions, que `Super + Alt + Space` i _Aplicacions_ al menú d'Omarchy també obren. Fes clic amb el botó dret en una aplicació de la quadrícula, o prem `Delete`, per desinstal·lar-la. Fes clic en una aplicació per obrir-la, o per portar la seva finestra al davant; fes clic de nou per recórrer les seves finestres. El clic central obre una finestra nova. Arrossega una icona al llarg del dock per moure-la; arrossegar una aplicació en execució entre les altres la manté allà. Fes clic amb el botó dret per mantenir una aplicació al dock, treure-la'n o sortir-ne. El dock s'aparta del camí d'una finestra a pantalla completa. Fes clic amb el botó dret al botó d'aplicacions per moure el dock a una altra vora o fer que s'amagui fins que el punter arribi a la seva vora. La posició també es troba a _Aparença > Dock > Posició del Dock_, i `omarchy dock position left` i `omarchy dock autohide on` configuren totes dues coses des d'un terminal. Les aplicacions que mantens al dock apareixen esvaïdes mentre no s'estan executant.

Els espais de treball nous, i qualsevol al qual no hagis donat una disposició pròpia amb `Super + L`, utilitzen la disposició per defecte. Canviar la disposició per defecte restableix a aquesta disposició tots els espais de treball sense finestres, mentre que un espai amb finestres conserva la disposició que té. Una finestra minimitzada al dock continua comptant com una finestra a l'espai de treball que ha deixat. Tria-la a _Aparença > Disposició de l'espai de treball_: En mosaic, Amb desplaçament o Flotant. `omarchy-hyprland-workspace-layout-default scrolling` la configura des d'un terminal.

### Agrupació de finestres

Les finestres es poden agrupar mitjançant `Super + G`. Un cop siguis en un grup, cada finestra que iniciïs mentre aquest estigui actiu pertanyerà al grup. Pots moure't entre aquestes finestres agrupades mitjançant `Super + Ctrl + Arrow Left/Right` o `Super + Alt + 1/2/3/4` per anar directament a una finestra agrupada en ordre.

Pots moure una finestra fora de l'agrupació amb `Super + Alt + G` o desmuntar tot el grup prement `Super + G` de nou. Finalment, pots moure finestres de fora del grup a dins seu amb `Super + Alt + Arrows`.

### Extracció de finestres

Pots extreure una finestra de la seva assignació d'espai de treball amb `Super + O`. Això la fixarà com una finestra flotant que et segueix a qualsevol espai de treball on vagis. Ideal per a reproductors de vídeo i similars.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Espai de treball scratchpad

Hi ha un espai de treball scratchpad especial de mida completa que se superposa a qualsevol espai de treball on et trobis actualment. Accedeixes al que hi ha mitjançant `Super + S`, i hi col·loques finestres mitjançant `Super + Alt + S`.

Funciona bé per a controls o un terminal amb què vols interactuar ràpidament sense deixar l'espai de treball actual.

### Consola Quake

Finalment, hi ha una consola Quake de mitja alçada que cau sobre qualsevol espai de treball on et trobis actualment. Activa-la i desactiva-la amb `Super + Grave`, i col·loca-hi una finestra mitjançant `Super + Shift + Grave`.

S'obre amb el teu agent per defecte a punt per funcionar. Mentre la consola conté una única finestra, cau com un panell centrat en lloc d'abastar tota la pantalla. Posa-hi una segona aplicació i torna a l'amplada completa, de manera que totes dues tenen espai per estar una al costat de l'altra.

Per moure una finestra fora del scratchpad o de la consola, envia-la directament a un altre espai de treball amb alguna cosa com `Super + Shift + 1`.

### Cal acostumar-s'hi!

Cal una mica de temps per acostumar-se a navegar per l'escriptori d'aquesta manera, però un cop ho fas, serà difícil tornar a una experiència d'escriptori tradicional controlada amb el ratolí!
