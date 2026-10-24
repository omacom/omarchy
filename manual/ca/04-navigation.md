# Navegació

Tot a Omarchy passa per mitjà del teclat — _TOT!_ Quan el sistema arrenca per primera vegada, literalment no pots fer res només amb el ratolí. Però pots prémer `Super + Space` per mostrar el menú d'Omarchy i des d'aquí pots fer pràcticament de tot.

Però el menú d'Omarchy ni tan sols està pensat per ser la manera principal de fer funcionar el sistema la major part del temps. Podem anar més de pressa que això! Totes les aplicacions més importants estan vinculades directament a dreceres de teclat individuals. Inicies el terminal amb `Super + Return` i un navegador amb `Super + Shift + Return`. Prova de fer una cosa després de l'altra i veuràs la màgia de la disposició en mosaic de Hyprland en acció:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Després pots prémer `Super + J` per apilar-les una a sobre de l'altra en lloc de tenir-les de costat:

 ![navigation-stacked](images/navigation-stacked.webp)

Prem `Super + J` de nou per tornar-les a les posicions de costat. Després prova `Super + Shift + Arrow Right` mentre ets al navegador per intercanviar les finestres.

Ara prova `Super + Ctrl + T` per iniciar el monitor d'activitat. Apareixerà com a finestra flotant. Pots posar-lo en mosaic amb `Super + T` (i tornar a prémer-ho perquè torni a ser flotant). Ara prem `Super + Shift + F` per obrir el gestor de fitxers. Tindràs una disposició de quatre ben ordenada:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Et desplaces entre la finestra que vols que estigui activa amb `Super + Arrow`. Això canvia el focus i mou el cursor al centre de l'aplicació nova.

Si prems `Super + Shift + 2`, mouràs l'aplicació que té el focus actualment al segon espai de treball. `Super + Shift + 1` la torna a moure enrere. (I `Super + Shift + Alt + 2` mourà l'aplicació que té el focus actualment al segon espai de treball sense canviar a aquest espai).

Si mantens premuda `Super` i fas servir el ratolí per fer clic en una finestra, podràs reordenar on seu. Si mantens premuda `Super` i fas servir el botó dret del ratolí, pots redimensionar la finestra lliurement.

Tanques una finestra amb `Super + W` o `Super + Q` (i tanques totes les finestres amb `Ctrl + Alt + Delete`).

També pots passar a pantalla completa amb `Super + F` o fins i tot només a amplada completa (mantenint la barra superior) amb `Super + Alt + F` o a pantalla completa dins d'una finestra amb `Super + Ctrl + F` (ideal per a YouTube!).

### Disposició dwindle contra scrolling

La disposició predeterminada d'Omarchy s'anomena dwindle. Manté totes les finestres que obres en un sol espai de treball visibles en tot moment, encara que hagi de reduir-les.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Però també pots triar convertir un espai de treball en la disposició scrolling, on les finestres s'alineen de costat, més enllà de la vora visible de la pantalla. Converteixes un sol espai de treball en aquesta disposició per mitjà de `Super + L`.

Prémer `Super + L` de nou fa que l'espai de treball sigui flotant, on les finestres se superposen lliurement i les col·loques tu mateix, i una tercera pressió el torna a dwindle. `Super + Alt + L` hi passa en l'ordre invers. Una finestra que ja flota de totes maneres — una que has fet sortir amb `Super + T`, o una aplicació que sempre s'obre flotant — continua flotant quan l'espai de treball torna a la disposició en mosaic. La barra superior marca l'espai de treball on ets amb la seva disposició: un quadrat per a dwindle, un cercle per a scrolling i un triangle per a flotant. Fer clic en aquesta marca també recorre les disposicions.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

L'elecció és per espai de treball, i es manté. Així pots mantenir l'espai de treball 1 en dwindle per navegar i l'espai de treball 2 en scrolling per al codi, i tornaran d'aquesta manera després d'un reinici.

Si vols fer servir la disposició scrolling com a predeterminada, pots definir-ho a `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Espais de treball flotants

Un espai de treball flotant funciona com un escriptori tradicional: les finestres se superposen, i les mous i les dimensionis tu mateix. Cada finestra rep una barra de títol amb els colors del teu tema, amb botons per minimitzar, maximitzar i tancar. `Super + M` també minimitza la finestra que té el focus. Una finestra minimitzada espera al dock; fes clic a la seva aplicació per tornar-la. Fes clic en una finestra per portar-la al davant. Redimensiona-la des de qualsevol vora o cantonada. Fes doble clic en una barra de títol per maximitzar la finestra mantenint la barra superior a la vista, i de nou per recuperar la seva mida antiga.

Un espai de treball flotant també mostra un dock, amb les teves aplicacions fixades, tot el que s'està executant i una graella de totes les aplicacions darrere del botó d'aplicacions, que `Super + Alt + Space` i _Apps_ al menú d'Omarchy també obren. Fes clic amb el botó dret en una aplicació de la graella, o prem `Delete`, per desinstal·lar-la. Fes clic en una aplicació per obrir-la, o per portar la seva finestra al davant; torna a fer clic per recórrer les seves finestres. El clic amb el botó del mig obre una finestra nova. Arrossega una icona al llarg del dock per moure-la; arrossegar una aplicació en execució entre les altres la manté allà. Fes clic amb el botó dret per mantenir una aplicació al dock, treure-la'n o tancar-la. El dock s' aparta del camí d'una finestra a pantalla completa. Fes clic amb el botó dret al botó d'aplicacions per moure el dock a una altra vora o perquè s'oculti fins que el punter arribi a la seva vora. La posició també és a _Trigger > Appearance > Dock > Dock Position_, i `omarchy dock position left` i `omarchy dock autohide on` defineixen totes dues coses des d'un terminal. Les aplicacions que mantens al dock apareixen atenuades mentre no s'estan executant.

Els espais de treball nous, i qualsevol a què no hagis donat una disposició pròpia amb `Super + L`, fan servir la disposició predeterminada. Canviar la predeterminada restableix a aquesta disposició tots els espais de treball sense finestres, mentre que un que té finestres manté la disposició que té. Una finestra minimitzada al dock continua comptant com a finestra de l'espai de treball que va deixar. Tria-la a _Trigger > Appearance > Workspace Layout_: Tiling, Scrolling o Floating. `omarchy-hyprland-workspace-layout-default scrolling` la defineix des d'un terminal.

### Agrupar finestres

Les finestres es poden agrupar amb `Super + G`. Un cop ets en un grup, totes les finestres que iniciïs mentre aquest està actiu pertanyeran al grup. Pots moure't entre aquestes finestres agrupades amb `Super + Ctrl + Arrow Left/Right` o `Super + Alt + 1/2/3/4` per anar directament a la finestra agrupada en ordre.

Pots moure una finestra fora de l'agrupació amb `Super + Alt + G` o desfer tot el grup prement `Super + G` de nou. Finalment, pots moure finestres de fora del grup cap a dins amb `Super + Alt + Arrows`.

### Fer sortir finestres

Pots fer sortir una finestra de l'assignació del seu espai de treball amb `Super + O`. Això la fixarà com a finestra flotant que et segueix a qualsevol espai de treball on vagis. Ideal per a reproductors de vídeo i similars.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Espai de treball scratchpad

Finalment, hi ha un espai de treball especial scratchpad que cau sobre qualsevol espai de treball on siguis actualment, molt semblant a una consola Quake. Activa'l i desactiva'l amb `Super + Grave` o `Super + S`, i col·loca-hi una finestra amb `Super + Shift + Grave` o `Super + Alt + S`.

Funciona especialment bé per a un terminal que executa un agent, o per a controls amb què vols interactuar ràpidament sense deixar l'espai de treball actual. Per moure una finestra fora del scratchpad, envia-la directament a un altre espai de treball amb alguna cosa com `Super + Shift + 1`.

Mentre el scratchpad conté una sola finestra, cau com un tauler centrat en lloc d'estendre's per la pantalla. Posa-hi una segona aplicació i torna a l'amplada completa, perquè totes dues tinguin espai per seure de costat.

### Costa una mica acostumar-s'hi!

Costa una mica acostumar-se a navegar pel teu escriptori d'aquesta manera, però un cop ho facis, et costarà tornar a una experiència d'escriptori tradicional impulsada pel ratolí!
