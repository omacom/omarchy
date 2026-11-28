# Si véns de Mac o Windows

Si has passat anys a macOS o Windows, els teus dits saben un centenar de coses que el teu cervell ha oblidat que mai havia après. Aquest capítol és la capa de traducció: on van aquests instints a Omarchy. Les funcions en si es tracten en profunditat en altres llocs — això és només el mapa.

### Super és el centre de tot

Tota la memòria muscular que has construït al voltant de Cmd o de la tecla Windows es transfereix a una sola tecla: Super. És la tecla Windows en un teclat de PC, i és l'ancoratge de gairebé totes les dreceres de teclat d'Omarchy.

El teu reflex de Spotlight o Raycast o del menú d'inici es converteix en `Super + Space`. Això obre el menú d'Omarchy, que obre aplicacions, canvia paràmetres, instal·la programari, captura la pantalla — pràcticament tot. Comença a escriure per filtrar. `Super + Alt + Space` mostra totes les aplicacions en una sola quadrícula, com fa Launchpad. Vegeu [navegació](04-navigation.md).

### Sense icones a l'escriptori, i el dock només apareix quan flotes

Sense icones per organitzar a l'escriptori, i sense dock en un espai de treball en mosaic — el dock només apareix en un espai de treball flotant (vegeu [navegació](04-navigation.md)). Les aplicacions s'obren amb una drecera (`Super + Return` per al terminal, `Super + Shift + Return` per al navegador, i `Super + K` per a una llista de tot el que està assignat) o des del menú. L'única peça persistent de la interfície és [la barra superior](05-the-top-bar.md), que cobreix el que abans feien per tu la barra de menú, la safata del sistema i el Notification Center — i gairebé tots els widgets que hi ha fan alguna cosa amb el clic esquerre, el dret i el central.

### Les finestres es col·loquen soles

El canvi de mentalitat més gran: no arrossegues finestres d'una banda a l'altra ni les enganxes a meitats de pantalla. Obres una finestra i ocupa tota la pantalla. N'obres una segona i se la reparteixen. Mai has de pescar una finestra de sota d'una altra, perquè les finestres no se superposen.

Quan realment necessites una finestra flotant, `Super + T` fa sortir la finestra activa del mosaic (i la hi torna). Però primer dona una oportunitat real al mosaic — és el cor de tot plegat. [La navegació](04-navigation.md) t'hi acompanya pas a pas.

Els espais de treball et resultaran familiars: són els Spaces de macOS o els escriptoris virtuals de Windows, només que aquests sí que els faràs servir, perquè `Super + 1/2/3/4` salta directament a un i `Super + Shift + 1/2/3/4` hi envia la finestra activa. Sense retard d'animació, només salts instantanis. Això vol dir que potser ni tan sols necessitaràs diversos monitors, si és que hi estaves acostumat abans.

### Copiar i enganxar funciona i prou

Al Mac tenies Cmd + C a tot arreu. A Windows tenies Ctrl + C a tot arreu — excepte al terminal, on mata el programa. Omarchy et dona `Super + C`, `Super + X` i `Super + V`, i funcionen a tot arreu, terminal inclòs. Cap reflex separat per aprendre per al shell.

Gent de Windows: el vostre historial del porta-retalls de Win + V viu a `Super + Ctrl + V`, i guarda imatges a més de text. Vegeu [porta-retalls unificat i historial](08-unified-clipboard-history.md).

### La taula de traducció

| El que intentes obrir | A Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — el menú d'Omarchy |
| AirDrop | LocalSend, amb `Super + Ctrl + S` — vegeu [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` o `Print Screen` — vegeu [captures de pantalla i enregistrament](12-screenshots-recording.md) |
| Notification Center | Historial de notificacions a `Super + Shift + Alt + ,` |
| Time Machine (per al sistema) | [Instantànies del sistema](47-system-snapshots.md) automàtiques a cada actualització |
| App Store / descarregar un instal·lador | _Install_ al menú, o `omarchy pkg add` — vegeu [altres paquets](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ al menú, que edita fitxers de configuració normals — vegeu [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, a `Super + Shift + F` — vegeu [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome a `Super + Shift + Return`; tria'n un altre a _Setup > Defaults > Browser_ — vegeu [navegadors](23-browsers.md) |
| Preview / Photos | Omaview per a imatges, vídeo i música, Document Viewer per als PDF — vegeu [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, a `Super + Shift + N`; tria'n un altre a _Setup > Defaults > Editor_ |

### Algunes coses són realment diferents

Molts paràmetres viuen en fitxers de text que edites, no en panells on vas fent clic. Sembla primitiu fins que t'adones que això vol dir que cada ajustament es pot veure, copiar a la teva propera màquina i posar sota control de versions. El menú _Setup_ et porta directe al fitxer correcte i reinicia tot el que calgui reiniciar quan has acabat.

Les actualitzacions arriben amb una sola ordre — _Update > Omarchy_ — que actualitza el mateix Omarchy i tots els paquets del sistema, fent primer una instantània. Sense actualitzadors per a cada aplicació que et vagin molestant en qualsevol moment. Vegeu [actualitzacions](30-updates.md).

El programari ve d'un gestor de paquets, no d'instal·ladors descarregats.

I quan tanques una finestra, l'aplicació es tanca de veritat. No hi ha cap llimb de macOS on el programa continua funcionant sense cap finestra. `Super + W` — o `Super + Q`, si és aquesta la memòria dels dits amb què has arribat — vol dir que ha desaparegut.

### Amb maquinari Mac

Omarchy funciona bé als Mac amb Intel, i als Mac amb M1, M2 i M3 amb Omarchy for Apple Silicon. Vegeu [compatibilitat amb Mac](44-mac-support.md). I el teclat et tracta bé: Omarchy no reassigna res, i Linux tracta la tecla Command com a Super, de manera que Super és just on sempre hi havia Cmd. El teu polze no notarà el canvi.

### Dona-li dues setmanes

Els instints es transfereixen més de pressa del que et penses. Fes una ullada al capítol de [tecles d'accés ràpid](07-hotkeys.md) un cop, i sempre que et quedis en blanc amb una assignació, prem `Super + K` — te les mostra totes. És l'única drecera que realment t'has de memoritzar.
