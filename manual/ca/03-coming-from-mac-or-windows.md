# Si véns de Mac o Windows

Si has passat anys a macOS o Windows, els teus dits saben cent coses que el teu cervell ha oblidat que mai va aprendre. Aquest capítol és la capa de traducció: on van a parar aquests instints a Omarchy. Les funcions en si es tracten en profunditat en altres llocs — això només és el mapa.

### Super és el centre de tot

Tota la memòria muscular que has construït al voltant de Cmd o de la tecla Windows es transfereix a una sola tecla: Super. És la tecla Windows en un teclat de PC, i és l'àncora de gairebé totes les tecles d'accés ràpid d'Omarchy.

El teu reflex d'Spotlight, de Raycast o del menú Inici esdevé `Super + Space`. Això obre el menú d'Omarchy, que llança aplicacions, canvia ajustos, instal·la programari, captura la pantalla — pràcticament de tot. Comença a escriure per filtrar. `Super + Alt + Space` mostra totes les aplicacions en una sola graella, com fa Launchpad. Consulta [navegació](04-navigation.md).

### No hi ha dock ni icones d'escriptori

Res on fer clic per llançar coses, cap icona per organitzar a l'escriptori. Les aplicacions s'inicien amb una tecla d'accés ràpid (`Super + Return` per al terminal, `Super + Shift + Return` per al navegador, i `Super + K` per a una llista de tot el que està assignat) o des del menú. L'única peça persistent de la interfície és [la barra superior](05-the-top-bar.md), que cobreix el que abans feien per tu la barra de menús, la safata del sistema i el Centre de notificacions — i gairebé tots els ginys que hi ha fan alguna cosa amb el clic esquerre, dret i del mig.

### Les finestres es col·loquen soles

El canvi de mentalitat més gran: no arrossegues les finestres amunt i avall ni les ajustes a meitats de pantalla. Obres una finestra i ocupa tota la pantalla. N'obres una segona i es divideixen la pantalla. Mai no has de pescar una finestra de sota d'una altra, perquè les finestres no se superposen.

Quan de debò necessites una finestra flotant, `Super + T` treu la finestra activa de la disposició en mosaic (i la hi torna). Però dona primer una oportunitat real al mosaic — és el cor de tot plegat. [La navegació](04-navigation.md) t'hi guia pas a pas.

Els espais de treball et resultaran familiars: són els Spaces de macOS o els escriptoris virtuals de Windows, excepte que realment els faràs servir, perquè `Super + 1/2/3/4` salta directament a un i `Super + Shift + 1/2/3/4` hi envia la finestra activa. Sense retard d'animació, només salts instantanis. Això vol dir que potser ni tan sols necessitaràs diversos monitors, si hi estaves acostumat abans.

### Copiar i enganxar simplement funcionen

Al Mac tenies Cmd + C a tot arreu. A Windows tenies Ctrl + C a tot arreu — excepte al terminal, on mata el programa. Omarchy et dona `Super + C`, `Super + X` i `Super + V`, i funcionen a tot arreu, inclòs el terminal. Cap reflex separat per aprendre per a la shell.

Gent de Windows: el vostre historial del porta-retalls de Win + V viu a `Super + Ctrl + V`, i guarda imatges a més de text. Consulta [porta-retalls i historial unificats](08-unified-clipboard-history.md).

### La taula de traducció

| El que busques | A Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / menú Inici | `Super + Space` — el menú d'Omarchy |
| AirDrop | LocalSend, mitjançant `Super + Ctrl + S` — consulta [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` o `Print Screen` — consulta [captures de pantalla i gravació](12-screenshots-recording.md) |
| Centre de notificacions | Historial de notificacions a `Super + Shift + Alt + ,` |
| Time Machine (per al sistema) | [Instantànies del sistema](47-system-snapshots.md) automàtiques a cada actualització |
| App Store / descarregar un instal·lador | _Instal·la_ al menú, o `omarchy pkg add` — consulta [altres paquets](29-other-packages.md) |
| Ajustos del sistema / Tauler de control | _Configuració_ al menú, que edita fitxers de configuració de text pla — consulta [dotfiles](31-dotfiles.md) |

### Algunes coses realment són diferents

Molts ajustos viuen en fitxers de text que edites, no en panells on fas clic. Això sembla primitiu fins que t'adones que vol dir que cada retoc es pot veure, copiar a la teva màquina següent i posar sota control de versions. El menú _Configuració_ et deixa directament al fitxer correcte i reinicia el que calgui reiniciar quan has acabat.

Les actualitzacions arriben amb una sola ordre — _Actualitza > Omarchy_ — que actualitza el mateix Omarchy i tots els paquets del sistema, fent primer una instantània. Cap actualitzador per aplicació que et molesti en moments aleatoris. Consulta [actualitzacions](30-updates.md).

El programari ve d'un gestor de paquets, no d'instal·ladors descarregats.

I quan tanques una finestra, l'aplicació realment es tanca. No hi ha cap limbe de macOS on el programa continua funcionant sense finestres. `Super + W` — o `Super + Q`, si és aquesta la memòria dels dits amb què has arribat — vol dir que ha desaparegut.

### En maquinari Mac

Omarchy funciona bé en Macs amb Intel — consulta [compatibilitat amb Mac](44-mac-support.md). I el teclat et tracta bé: Omarchy no reassigna res, i Linux tracta la tecla Command com a Super, així que Super és exactament on sempre hi havia Cmd. El teu polze no notarà el canvi.

### Dona-li dues setmanes

Els instints es transfereixen més ràpid del que et penses. Fes un cop d'ull al capítol de [tecles d'accés ràpid](07-hotkeys.md) una vegada, i sempre que et quedis en blanc amb una assignació, prem `Super + K` — te les mostra totes. És l'única tecla d'accés ràpid que realment has de memoritzar.
