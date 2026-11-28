# Si véns de Mac o de Windows

Si has passat anys a macOS o Windows, els teus dits saben un centenar de coses que el teu cervell ha oblidat que mai havia après. Aquest capítol és la capa de traducció: on van a parar aquests instints a Omarchy. Les funcions en si es tracten en profunditat en altres llocs — això és només el mapa.

### Super és el centre de tot

Tota la memòria muscular que has construït al voltant de Cmd o de la tecla de Windows es transfereix a una sola tecla: Super. És la tecla de Windows en un teclat de PC, i és l'àncora de gairebé totes les dreceres de teclat a Omarchy.

El teu reflex de Spotlight o Raycast o del menú Inici esdevé `Super + Space`. Això obre el menú d'Omarchy, que llança aplicacions, canvia la configuració, instal·la programari, captura la pantalla — gairebé tot. Comença a escriure per filtrar. `Super + Alt + Space` mostra totes les aplicacions en una sola graella, com fa Launchpad. Vegeu [navegació](04-navigation.md).

### Sense icones a l'escriptori, i el dock no fa nosa

Sense icones per ordenar a l'escriptori, i el dock s'amaga quan un espai de treball té una finestra, fins que empenys el punter fins a la vora de la pantalla que li correspon, la de baix llevat que el moguis (vegeu [navegació](04-navigation.md)). Les aplicacions s'inicien amb una drecera de teclat (`Super + Return` per al terminal, `Super + Shift + Return` per al navegador, i `Super + K` per a una llista de tot el que està assignat) o des del menú. L'única peça persistent de la interfície és [la barra superior](05-the-top-bar.md), que cobreix el que abans feien per tu la barra de menús, la safata del sistema i el Notification Center — i gairebé tots els ginys que hi ha fan alguna cosa amb el clic esquerre, el dret i el central.

### Les finestres es col·loquen soles

El canvi de mentalitat més gran: no arrossegues les finestres pertot ni les ajustes a meitats de pantalla. Obres una finestra i ocupa tota la pantalla. N'obres una segona i es reparteixen la pantalla. Mai no has de pescar una finestra de sota d'una altra, perquè les finestres no se superposen.

Quan realment necessites una finestra flotant, `Super + T` treu la finestra activa del mosaic (i la hi torna a posar). Però dona primer una oportunitat de debò al mosaic — és el cor de tot plegat. [Navegació](04-navigation.md) t'hi guia pas a pas.

Els espais de treball et resultaran familiars: són els Spaces de macOS o els escriptoris virtuals de Windows, excepte que realment els faràs servir, perquè `Super + 1/2/3/4` salta directament a un i `Super + Shift + 1/2/3/4` hi envia la finestra activa. Sense retard d'animació, només salts instantanis. Això vol dir que potser ni tan sols necessitaràs diversos monitors, si hi estaves acostumat abans.

### Copiar i enganxar, senzillament, funciona

Al Mac tenies Cmd + C a tot arreu. A Windows tenies Ctrl + C a tot arreu — excepte al terminal, on mata el programa. Omarchy et dona `Super + C`, `Super + X` i `Super + V`, i funcionen a tot arreu, terminal inclòs. No cal aprendre un reflex a part per a la shell.

Gent de Windows: el vostre historial del porta-retalls de Win + V viu a `Super + Ctrl + V`, i desa imatges a més de text. Vegeu [porta-retalls unificat i historial](08-unified-clipboard-history.md).

### La taula de traducció

| El que busques | A Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / menú Inici | `Super + Space` — el menú d'Omarchy |
| AirDrop | LocalSend, mitjançant `Super + Ctrl + S` — vegeu [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` o `Print Screen` — vegeu [captures de pantalla i gravació](12-screenshots-recording.md) |
| Notification Center | Historial de notificacions a `Super + Shift + Alt + ,` |
| Time Machine (per al sistema) | [instantànies del sistema](47-system-snapshots.md) automàtiques a cada actualització |
| App Store / baixar un instal·lador | _Install_ al menú, o `omarchy pkg add` — vegeu [altres paquets](29-other-packages.md) |
| Configuració del sistema / Tauler de control | _Setup_ al menú, que edita fitxers de configuració simples — vegeu [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, a `Super + Shift + F` — vegeu [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome a `Super + Shift + Return`; tria'n un altre a _Setup > Defaults > Browser_ — vegeu [navegadors](23-browsers.md) |
| Vista prèvia / Fotos | Omaview per a imatges, vídeo i música, Document Viewer per a PDFs — vegeu [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, a `Super + Shift + N`; tria'n un altre a _Setup > Defaults > Editor_ |

### Algunes coses realment són diferents

Molta configuració viu en fitxers de text que edites, no en panells pels quals navegues a clics. Això sembla primitiu fins que t'adones que vol dir que cada retoc es pot veure, copiar a la teva màquina següent i posar sota control de versions. El menú _Setup_ et deixa directament al fitxer correcte i reinicia el que calgui reiniciar quan has acabat.

Les actualitzacions arriben amb una sola ordre — _Update > Omarchy_ — que actualitza el mateix Omarchy i tots els paquets del sistema, fent primer una instantània. Sense actualitzadors per aplicació que et molestin en moments aleatoris. Vegeu [actualitzacions](30-updates.md).

El programari ve d'un gestor de paquets, no d'instal·ladors descarregats.

I quan tanques una finestra, l'aplicació realment es tanca. No hi ha cap llimb de macOS on el programa continua en marxa sense finestres. `Super + W` — o `Super + Q`, si aquesta és la memòria dels dits amb què has arribat — vol dir que ja no hi és.

### En maquinari Mac

Omarchy funciona bé en Macs amb Intel, i en Macs M1, M2 i M3 amb Omarchy for Apple Silicon. Vegeu [compatibilitat amb Mac](44-mac-support.md). I el teclat et tracta bé: Omarchy no reassigna res, i Linux tracta la tecla Command com a Super, de manera que Super queda exactament on sempre hi havia hagut Cmd. El teu polze no notarà el canvi.

### Dona-li dues setmanes

Els instints es transfereixen més ràpid del que et penses. Fes una ullada ràpida al capítol de [dreceres de teclat](07-hotkeys.md) una vegada, i sempre que et quedis en blanc amb una assignació, prem `Super + K` — te les mostra totes. És l'única drecera que realment has de memoritzar.
