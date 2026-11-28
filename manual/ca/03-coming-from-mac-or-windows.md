# Venint de Mac o Windows

Si has passat anys a macOS o Windows, els teus dits saben un centenar de coses que el teu cervell ha oblidat que mai va aprendre. Aquest capítol és la capa de traducció: on van a parar aquests instints a Omarchy. Les funcions en si es tracten en profunditat en altres llocs — això és només el mapa.

### Super és el centre de tot

Tota la memòria muscular que has construït al voltant de Cmd o la tecla Windows es transfereix a una sola tecla: Super. És la tecla Windows d'un teclat de PC, i és l'àncora de gairebé totes les dreceres de teclat d'Omarchy.

El teu reflex de Spotlight, Raycast o el menú Start esdevé `Super + Space`. Això obre el menú d'Omarchy, que llança aplicacions, canvia la configuració, instal·la programari, captura la pantalla — pràcticament de tot. Comença a escriure per filtrar. `Super + Alt + Space` mostra totes les aplicacions en una sola graella, com fa Launchpad. Vegeu [navegació](04-navigation.md).

### Sense icones a l'escriptori, i el dock no fa nosa

Sense icones per ordenar a l'escriptori, i el dock s'amaga quan un espai de treball té una finestra, fins que empenys el punter fins a la seva vora de la pantalla, la de la dreta llevat que el moguis (vegeu [navegació](04-navigation.md)). Les aplicacions s'inicien amb una drecera de teclat (`Super + Return` per al terminal, `Super + Shift + Return` per al navegador, i `Super + K` per a una llista de tot el que hi ha assignat) o des del menú. L'única peça persistent de la interfície és [la barra superior](05-the-top-bar.md), que cobreix el que abans feien per tu la barra de menú, la safata del sistema i Notification Center — i gairebé tots els ginys que té fan alguna cosa amb el clic esquerre, dret i central.

### Les finestres es col·loquen soles

El canvi de mentalitat més gran: no arrossegues finestres d'un lloc a l'altre ni les acobles a meitats de la pantalla. Obres una finestra i ocupa tota la pantalla. N'obres una segona i se la reparteixen. Mai no has de pescar una finestra de sota d'una altra, perquè les finestres no se solapen.

Quan de debò necessites una finestra flotant, `Super + T` treu la finestra activa de la disposició en mosaic (i la hi torna). Però dona primer una oportunitat real al mosaic — és el cor de tot plegat. [Navegació](04-navigation.md) t'hi guia pas a pas.

Els espais de treball et resultaran familiars: són els Spaces de macOS o els escriptoris virtuals de Windows, amb la diferència que aquests sí que els faràs servir, perquè `Super + 1/2/3/4` salta directament a un i `Super + Shift + 1/2/3/4` hi envia la finestra activa. Sense retard d'animació, només salts instantanis. Això vol dir que potser ni tan sols necessitaràs diversos monitors, si és que hi estaves acostumat abans.

### Copiar i enganxar simplement funciona

Al Mac tenies Cmd + C a tot arreu. A Windows tenies Ctrl + C a tot arreu — excepte al terminal, on mata el programa. Omarchy et dona `Super + C`, `Super + X` i `Super + V`, i funcionen a tot arreu, terminal inclòs. Cap reflex separat per aprendre per a la shell.

Gent de Windows: el vostre historial del porta-retalls de Win + V viu a `Super + Ctrl + V`, i guarda imatges a més de text. Vegeu [porta-retalls i historial unificats](08-unified-clipboard-history.md).

### La taula de traducció

| El que busques | A Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — el menú d'Omarchy |
| AirDrop | LocalSend, via `Super + Ctrl + S` — vegeu [interfícies gràfiques](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` o `Print Screen` — vegeu [captures de pantalla i enregistrament](12-screenshots-recording.md) |
| Notification Center | Historial de notificacions a `Super + Shift + Alt + ,` |
| Time Machine (per al sistema) | [instantànies del sistema](47-system-snapshots.md) automàtiques a cada actualització |
| App Store / baixar un instal·lador | _Install_ al menú, o `omarchy pkg add` — vegeu [altres paquets](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ al menú, que edita fitxers de configuració plans — vegeu [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, a `Super + Shift + F` — vegeu [interfícies gràfiques](22-guis.md) |
| Safari / Edge | Google Chrome a `Super + Shift + Return`; tria'n un altre a _Setup > Defaults > Browser_ — vegeu [navegadors](23-browsers.md) |
| Preview / Photos | Omaview per a imatges, vídeo i música, Document Viewer per a PDF — vegeu [interfícies gràfiques](22-guis.md) |
| TextEdit / Notepad | Plain, a `Super + Shift + N`; tria'n un altre a _Setup > Defaults > Editor_ |

### Algunes coses sí que són diferents

Molts ajustos viuen en fitxers de text que edites, no en panells on fas clic. Sembla primitiu fins que t'adones que això vol dir que cada retoc es pot veure, copiar a la teva propera màquina i posar sota control de versions. El menú _Setup_ et porta directament al fitxer adequat i reinicia el que calgui reiniciar quan has acabat.

Les actualitzacions arriben amb una sola ordre — _Update > Omarchy_ — que actualitza Omarchy mateix i tots els paquets del sistema, fent primer una instantània. Sense actualitzadors individuals d'aplicacions que et molestin quan menys t'ho esperes. Vegeu [actualitzacions](30-updates.md).

El programari ve d'un gestor de paquets, no d'instal·ladors baixats.

I quan tanques una finestra, l'aplicació realment es tanca. No hi ha el llimb de macOS on el programa continua en marxa sense cap finestra. `Super + W` — o `Super + Q`, si aquesta és la memòria dels dits amb què has arribat — vol dir que ha desaparegut.

### En maquinari Mac

Omarchy funciona bé en Macs amb Intel, i en Macs M1, M2 i M3 amb Omarchy for Apple Silicon. Vegeu [compatibilitat amb Mac](44-mac-support.md). I el teclat et tracta bé: Omarchy no reassigna res, i Linux tracta la tecla Command com a Super, així que Super queda just on sempre hi havia hagut Cmd. El teu polze no notarà el canvi.

### Dona-li dues setmanes

Els instints es transfereixen més ràpid del que et penses. Fes una ullada ràpida al capítol de [dreceres de teclat](07-hotkeys.md) una vegada, i sempre que et quedis en blanc amb una assignació, prem `Super + K` — te les mostra totes. Aquesta és l'única drecera que realment t'has de memoritzar.
