# Si véns de Mac o Windows

Si fa anys que ets a macOS o Windows, els teus dits saben un centenar de coses que el teu cervell ha oblidat que mai va aprendre. Aquest capítol és la capa de traducció: on van a parar aquests instints a Omarchy. Les funcions en si es tracten en profunditat en altres llocs — això és només el mapa.

### Super és el centre de tot

Tota la memòria muscular que has construït al voltant de Cmd o de la tecla de Windows es trasllada a una sola tecla: Super. És la tecla de Windows en un teclat de PC, i és l'àncora de gairebé totes les dreceres de teclat d'Omarchy.

El teu reflex de Spotlight, Raycast o del menú d'inici es converteix en `Super + Space`. Això obre el menú d'Omarchy, que llança aplicacions, canvia la configuració, instal·la programari, captura la pantalla — pràcticament tot. Comença a escriure per filtrar. `Super + Alt + Space` mostra totes les aplicacions en una sola graella, com fa Launchpad. Vegeu [navegació](04-navigation.md).

### Sense icones d'escriptori, i el dock només apareix quan sures

No hi ha icones per ordenar a l'escriptori, ni dock en un espai de treball en mosaic — el dock només apareix en un espai de treball flotant (vegeu [navegació](04-navigation.md)). Les aplicacions s'inicien amb una drecera de teclat (`Super + Return` per al terminal, `Super + Shift + Return` per al navegador, i `Super + K` per a una llista de tot el que està assignat) o des del menú. L'única peça persistent de la interfície d'usuari és [la barra superior](05-the-top-bar.md), que cobreix el que abans feien per a tu la barra de menús, la safata del sistema i el Notification Center — i gairebé tots els ginys que hi ha fan alguna cosa amb el clic esquerre, dret i central.

### Les finestres es col·loquen soles

El canvi de mentalitat més gran: no arrossegues les finestres ni les ajustes a meitats de pantalla. Obres una finestra i ocupa tota la pantalla. N'obres una segona i es parteixen la pantalla. Mai no has de pescar una finestra de sota d'una altra, perquè les finestres no se superposen.

Quan realment necessites una finestra flotant, `Super + T` treu la finestra activa del mosaic (i la hi torna a posar). Però dona primer una oportunitat real al mosaic — és el cor de tot plegat. [Navegació](04-navigation.md) t'hi guia pas a pas.

Els espais de treball et resultaran familiars: són com els Spaces de macOS o els escriptoris virtuals de Windows, excepte que aquests sí que els faràs servir, perquè `Super + 1/2/3/4` salta directament a un i `Super + Shift + 1/2/3/4` hi envia la finestra activa. Sense retard d'animació, només salts instantanis. Això significa que potser ni tan sols necessitaràs diversos monitors, si és que hi estaves acostumat abans.

### Copiar i enganxar funcionen sense més

Al Mac tenies Cmd + C a tot arreu. A Windows tenies Ctrl + C a tot arreu — excepte al terminal, on mata el programa. Omarchy et dona `Super + C`, `Super + X` i `Super + V`, i funcionen a tot arreu, inclòs el terminal. No cal aprendre un reflex a part per a la shell.

Gent de Windows: el vostre historial del porta-retalls de Win + V viu a `Super + Ctrl + V`, i conserva imatges a més de text. Vegeu [porta-retalls unificat i historial](08-unified-clipboard-history.md).

### La taula de traducció

| El que busques | A Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / menú d'inici | `Super + Space` — el menú d'Omarchy |
| AirDrop | LocalSend, mitjançant `Super + Ctrl + S` — vegeu [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` o `Print Screen` — vegeu [captures de pantalla i gravació](12-screenshots-recording.md) |
| Notification Center | Historial de notificacions a `Super + Shift + Alt + ,` |
| Time Machine (per al sistema) | [Instantànies del sistema](47-system-snapshots.md) automàtiques a cada actualització |
| App Store / baixar un instal·lador | _Install_ al menú, o `omarchy pkg add` — vegeu [altres paquets](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ al menú, que edita fitxers de configuració de text pla — vegeu [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, a `Super + Shift + F` — vegeu [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome a `Super + Shift + Return`; tria'n un altre a _Setup > Defaults > Browser_ — vegeu [navegadors](23-browsers.md) |
| Preview / Photos | Omaview per a imatges, vídeo i música, Document Viewer per als PDF — vegeu [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, a `Super + Shift + N`; tria'n un altre a _Setup > Defaults > Editor_ |

### Algunes coses sí que són diferents de veritat

Molts ajustos viuen en fitxers de text que edites, no en panells pels quals navegues a clics. Això sembla primitiu fins que t'adones que significa que cada retoc es pot veure, copiar a la teva màquina següent i posar sota control de versions. El menú _Setup_ et deixa directament al fitxer correcte i reinicia el que calgui reiniciar quan has acabat.

Les actualitzacions arriben amb una sola comanda — _Update > Omarchy_ — que actualitza el mateix Omarchy i tots els paquets del sistema, fent primer una instantània. Sense actualitzadors per aplicació que et molestin en moments aleatoris. Vegeu [actualitzacions](30-updates.md).

El programari ve d'un gestor de paquets, no d'instal·ladors descarregats.

I quan tanques una finestra, l'aplicació es tanca de veritat. No hi ha el llimb de macOS on el programa continua en marxa sense finestres. `Super + W` — o `Super + Q`, si és amb aquesta memòria dels dits que vas arribar — vol dir que s'ha acabat.

### En maquinari Mac

Omarchy funciona bé en Macs amb Intel — vegeu [compatibilitat amb Mac](44-mac-support.md). I el teclat et tracta bé: Omarchy no reassigna res, i Linux tracta la tecla Command com a Super, de manera que Super queda exactament on sempre hi havia hagut Cmd. El teu polze ni notarà el canvi.

### Dona-li dues setmanes

Els instints es transfereixen més de pressa del que pensaries. Fes una ullada un cop al capítol de [dreceres de teclat](07-hotkeys.md), i sempre que et quedis en blanc amb una assignació, prem `Super + K` — te les mostra totes. Aquesta és l'única drecera de teclat que realment has de memoritzar.
