# Veniu de Mac o de Windows

Si heu passat anys amb macOS o Windows, els vostres dits saben un centenar de coses que el vostre cervell ha oblidat haver après mai. Aquest capítol és la capa de traducció: on van aquests instints a Omarchy. Les funcions en si es tracten en profunditat en altres llocs — això només és el mapa.

### Super és el centre de tot

Tota la memòria muscular que heu construït al voltant de Cmd o de la tecla Windows es trasllada a una sola tecla: Super. És la tecla Windows d'un teclat de PC, i és l'ancoratge de gairebé totes les dreceres d'Omarchy.

El vostre reflex de Spotlight, Raycast o del menú Inici esdevé `Super + Space`. Això obre el menú d'Omarchy, que llança aplicacions, canvia la configuració, instal·la programari, captura la pantalla — pràcticament tot. Comenceu a escriure per filtrar. `Super + Alt + Space` mostra totes les aplicacions en una sola graella, com fa Launchpad. Vegeu [navegació](04-navigation.md).

### No hi ha dock ni icones d'escriptori

Res on fer clic per llançar coses, cap icona per organitzar a l'escriptori. Les aplicacions s'inicien amb una drecera (`Super + Return` per al terminal, `Super + Shift + Return` per al navegador i `Super + K` per a una llista de tot el que està assignat) o des del menú. L'única peça persistent de la interfície és [la barra superior](05-the-top-bar.md), que cobreix el que la barra de menús, la safata del sistema i el Centre de notificacions feien per vosaltres abans — i gairebé tots els ginys que hi ha fan alguna cosa amb el clic esquerre, el dret i el del mig.

### Les finestres es col·loquen soles

El canvi de mentalitat més gran: no arrossegueu les finestres ni les ajusteu a mitges pantalles. Obriu una finestra i ocupa tota la pantalla. N'obriu una segona i se la reparteixen. Mai no heu de pescar una finestra de sota d'una altra, perquè les finestres no se superposen.

Quan realment necessiteu una finestra flotant, `Super + T` treu l'activa del mosaic (i n'hi torna). Però doneu primer una oportunitat real al mosaic — és el cor de tot plegat. [Navegació](04-navigation.md) us ho explica pas a pas.

Els espais de treball us resultaran familiars: són els Spaces de macOS o els escriptoris virtuals de Windows, excepte que realment els fareu servir, perquè `Super + 1/2/3/4` salta directament a un i `Super + Shift + 1/2/3/4` hi envia la finestra activa. Sense retard d'animació, només salts instantanis. Això vol dir que potser ni tan sols necessitareu diversos monitors, si és el que fèieu servir abans.

### Copiar i enganxar simplement funciona

Al Mac teníeu Cmd + C a tot arreu. A Windows teníeu Ctrl + C a tot arreu — excepte al terminal, on mata el vostre programa. Omarchy us dona `Super + C`, `Super + X` i `Super + V`, i funcionen a tot arreu, també al terminal. Cap reflex separat per aprendre per al shell.

Gent de Windows: el vostre historial del porta-retalls de Win + V viu a `Super + Ctrl + V`, i conté imatges a més de text. Vegeu [porta-retalls unificat i historial](08-unified-clipboard-history.md).

### La taula de traducció

| El que busqueu | A Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / menú Inici | `Super + Space` — el menú d'Omarchy |
| AirDrop | LocalSend, amb `Super + Ctrl + S` — vegeu [interfícies gràfiques](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Print Screen` — vegeu [captures de pantalla i gravació](12-screenshots-recording.md) |
| Centre de notificacions | Historial de notificacions a `Super + Shift + Alt + ,` |
| Time Machine (per al sistema) | [Instantànies del sistema](47-system-snapshots.md) automàtiques a cada actualització |
| App Store / baixar un instal·lador | _Instal·la_ al menú, o `omarchy pkg add` — vegeu [altres paquets](29-other-packages.md) |
| Configuració del sistema / Tauler de control | _Configuració_ al menú, que edita fitxers de configuració plans — vegeu [dotfiles](31-dotfiles.md) |

### Algunes coses realment són diferents

Molts paràmetres viuen en fitxers de text que editeu, no en panells on feu clic. Això sona primitiu fins que us adoneu que vol dir que cada ajust es pot veure, es pot copiar a la vostra propera màquina i es pot posar sota control de versions. El menú _Configuració_ us porta directament al fitxer correcte i reinicia el que calgui reiniciar quan heu acabat.

Les actualitzacions arriben amb una sola ordre — _Actualitza > Omarchy_ — que actualitza el mateix Omarchy i tots els paquets del sistema, fent primer una instantània. Res d'actualitzadors per aplicació que us molestin a l'atzar. Vegeu [actualitzacions](30-updates.md).

El programari ve d'un gestor de paquets, no d'instal·ladors baixats.

I quan tanqueu una finestra, l'aplicació realment es tanca. No hi ha llimbs de macOS on el programa continua executant-se sense finestres. `Super + W` — o `Super + Q`, si és la memòria dels dits amb què heu arribat — vol dir que se n'ha anat.

### En maquinari Mac

Omarchy funciona bé en Macs Intel — vegeu [compatibilitat amb Mac](44-mac-support.md). I el teclat és amable amb vosaltres: Omarchy no reassigna res, i Linux tracta la tecla Command com a Super, de manera que Super queda exactament on sempre ha estat Cmd. El vostre polze no notarà el canvi.

### Doneu-li dues setmanes

Els instints es transfereixen més ràpid del que us penseu. Feu un cop d'ull al capítol de [dreceres](07-hotkeys.md) una vegada i, sempre que us quedi la ment en blanc amb una assignació, premeu `Super + K` — us les mostra totes. És l'única drecera que realment heu de memoritzar.
