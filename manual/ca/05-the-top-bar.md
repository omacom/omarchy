# La barra superior

La franja de la part superior de la pantalla és la barra d'Omarchy. No és una barra d'estat afegida, sinó part del shell d'Omarchy, l'únic procés de Quickshell de llarga durada que també dibuixa el menú, les notificacions, les finestres emergents OSD i la pantalla de bloqueig. Per això combina perfectament amb tot la resta i per això un panell s'obre instantàniament en lloc d'iniciar una aplicació nova.

També és l'única peça de l'escriptori que sempre és a la pantalla, així que val la pena saber què fan tots aquests petits glifs.

## Què hi ha per defecte

La barra té tres seccions. A l'esquerra hi ha el logotip d'Omarchy (el llançador del menú) i els indicadors d'espais de treball. Al centre teniu els indicadors d'estat, el rellotge, Elsewhen (un rellotge mundial), el temps i un distintiu d'actualització d'Omarchy. A la dreta: la disposició del teclat (quan n'hi ha més d'una configurada), la safata del sistema, els agents, bluetooth, xarxa, àudio, pantalla i energia.

Alguns només apareixen quan tenen alguna cosa a dir. La disposició del teclat només apareix si n'heu configurat més d'una. El distintiu d'actualització només apareix quan hi ha una actualització d'Omarchy esperant. I la icona dels agents apareix la primera vegada que Omarchy troba ús de codificació amb IA a la màquina (vegeu [IA](17-ai.md)).

## Fer clics per aquí i per allà

Gairebé tots els ginys fan alguna cosa amb el clic esquerre, el dret i el del mig, i diversos responen al desplaçament. Aquesta és la part que la gent es perd — els botons dret i del mig són on s'amaga gran part del que és bo.

| Giny | Esquerra | Dreta | Mig / desplaçament |
| --- | --- | --- | --- |
| Menú | Menú d'Omarchy | Terminal nou | — |
| Espais de treball | Enfoca aquest espai de treball | — | Desplaçament: espai de treball següent/anterior |
| Rellotge | Finestra emergent del calendari | Fa rotar el format de l'etiqueta | Mig: selector de zona horària |
| Temps | Finestra emergent de la previsió | Temps complet com a notificació | Mig: actualitza |
| Àudio | Panell d'àudio | Silencia | Mig: panell · desplaçament: volum |
| Micròfon | Silencia el micròfon | — | Mig: panell d'àudio · desplaçament: volum d'entrada |
| Xarxa | Panell de xarxa | — | — |
| Bluetooth | Panell de Bluetooth | Commuta la ràdio | — |
| Pantalla | Panell de pantalla | — | Desplaçament: brillantor |
| Energia | Panell d'energia | Commuta el percentatge de bateria | — |
| Mitjans | Reprodueix/pausa | Finestra emergent de la caràtula | Mig: següent · desplaçament: anterior/següent |
| Agents | Panell d'agents | Llança el vostre agent | Mig: subscripció següent |
| Safata | Passar el cursor revela el calaix | Clic dret al xevró per gestionar | — |
| Actualització d'Omarchy | Executa l'actualització | — | — |

No tot el que hi ha en aquesta taula és a la vostra barra de sèrie. El giny de mitjans (reproducció actual MPRIS, amb la cançó i l'artista desplaçant-se) i el giny del micròfon són tots dos integrats però desactivats per defecte — afegiu-los si els voleu, com es descriu més avall.

## Els panells

Fer clic en una icona de la barra obre un panell, que és una finestra emergent com cal amb controls lliscants, llistes i navegació amb teclat en lloc d'un consell d'eina. Cadascun també té una drecera, de manera que mai no heu d'apuntar a un glif de 16 píxels:

| Drecera | Panell |
| --- | --- |
| `Super + Ctrl + A` | Àudio |
| `Super + Ctrl + W` | Xarxa |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Pantalla |
| `Super + Ctrl + P` | Energia |
| `Super + Ctrl + Alt + D` | Calendari |
| `Super + Ctrl + Alt + E` | Rellotge mundial |
| `Super + Ctrl + 1-9` | Commuta l'enèsim panell de la secció dreta |

Els panells no són lectures. Són on realment feu la cosa:

- **Àudio** té un control lliscant de volum principal, un selector de dispositiu de sortida i una mescladora per aplicació, de manera que podeu abaixar aquella pestanya del navegador sense tocar la resta.
- **Xarxa** busca Wi-Fi, mostra la intensitat del senyal, connecta i us permet triar un proveïdor de DNS.
- **Bluetooth** enumera els vostres dispositius amb connecta/desconnecta i nivells de bateria.
- **Energia** mostra estadístiques de la bateria, canvia els perfils d'energia (recorda una elecció separada per a bateria i per a corrent altern) i imprimeix informació del sistema.
- **Pantalla** té un control lliscant de brillantor, mida del text, valors predefinits d'escala del monitor i — quan teniu més d'una pantalla — controls per monitor. Vegeu [monitors](33-monitors.md) per a la història en profunditat.
- **Rellotge** obre una graella mensual amb números de setmana ISO i navegació per mesos.

Cada panell accepta tant el teclat com el ratolí: les fletxes mouen, Return activa, Tab passa al panell veí i Escape tanca.

`Super + Ctrl + 1-9` compta els panells d'esquerra a dreta a la secció dreta, saltant-se la safata perquè no té panell propi. Així el número coincideix amb la icona a què apuntaríeu.

### Tailscale i Dropbox

Dos ginys més apareixen a la barra només un cop instal·leu el servei corresponent des de **Instal·la → Servei**, i tots dos val la pena conèixer perquè fan més que informar de l'estat.

El panell de **Tailscale** connecta i desconnecta la tailnet, canvia entre comptes i tria un node de sortida (tant les vostres màquines com les regions de Mullvad apareixen en aquesta llista). També navega per les vostres màquines — i amb una de seleccionada, `s` hi envia fitxers mitjançant Taildrop, que és la manera més ràpida de moure un fitxer al vostre telèfon o a un altre portàtil. `c` copia l'IP de la màquina, `n` el seu nom i `d` el seu nom DNS complet. També hi ha un botó d'enviament a cada fila de màquina, si preferiu fer clic. El mateix des del terminal és `omarchy tailscale send <machine> [file...]`.

El panell de **Dropbox** gestiona l'inici de sessió, mostra quant d'emmagatzematge heu fet servir i enumera els fitxers sincronitzats recentment.

Eliminar qualsevol dels dos serveis retira el seu giny de la barra.

## Indicadors

El petit grup del centre és el giny d'indicadors. Són glifs d'estat per als modes que heu activat: no molesteu, llum nocturna, un [recordatori](09-reminders.md) en cua, una gravació de pantalla activa, mantenir despert i [dictat](11-text-extraction-dictation.md). S'il·luminen quan el mode és actiu i, si no, no molesten — passeu el cursor a l'esquerra del rellotge (a sobre en una barra vertical) per fer un cop d'ull als inactius. Fer clic en un indicador commuta aquest mode. Un més és només d'estat: una sessió remota s'il·lumina en vermell mentre algú està connectat a aquesta màquina mitjançant gliff.

Si preferiu que sempre fossin visibles, definiu `alwaysShow` a `true` al giny. I si només us importen alguns, enumereu els que voleu a `items`: `["Dnd", "Reminder", "NightLight"]`. Podeu tenir més d'un giny d'indicadors, de manera que seccions diferents poden mostrar subconjunts diferents.

## Reordenar la barra

La barra es configura sola. No heu d'obrir un fitxer de configuració per moure coses.

Agafeu un tros buit de la barra al voltant del centre i arrossegueu-lo cap a una altra vora de la pantalla, i la barra s'hi mourà — esquerra, dreta, dalt o baix, tot funciona, i cada giny s'hi adapta (les barres verticals passen a formes compactes només amb icones). Un clic mantingut inicia el mateix arrossegament. Feu doble clic esquerre en aquest mateix espai buit per fer rotar el fons de la barra de transparent a de vidre a opac. I arrossegueu qualsevol giny per reordenar-lo o llançar-lo a una altra secció.

Un giny que voleu tenir a mà però no sempre a la vista pot anar al calaix de la safata: arrossegueu-lo damunt la safata i el calaix s'obrirà per acollir-lo. S'hi queda darrere les icones de les aplicacions, apareix sempre que el calaix ho fa i manté el calaix obert mentre el seu panell és obert. Arrossegueu-lo de nou cap a la barra per tornar-lo al seu lloc.

Si preferiu triar des d'un menú, **Activa → Aparença → Barra de menú** té la posició, i **Fons de la barra** tria com es dibuixa la barra: **Barra opaca**, **Barra de vidre** (transparència, amb el que hi ha darrere difuminat) o **Barra transparent**.

Les mateixes coses tenen ordres, que és el que voleu per a una configuració de [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.clock --section center --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Per afegir o eliminar un giny del tot, feu servir les ordres de complement. `omarchy plugin list` imprimeix tots els ginys que el shell coneix amb el seu id, i llavors:

```bash
omarchy plugin enable omarchy.media --section center
omarchy plugin disable omarchy.weather
```

## Amagar la barra

`Super + Shift + Space` amaga la barra i la torna a mostrar sense matar el shell — els panells i les dreceres continuen funcionant, simplement recupereu els píxels. També és al menú a **Activa → Aparença → Barra de menú → Amaga la barra**.

## El fitxer de configuració

Tot plegat es desa a `~/.config/omarchy/shell.json`, a la clau `bar`. Aquí en teniu una versió retallada:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "centerAnchor": "omarchy.clock",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Cada giny és una entrada en una de les tres matrius de disposició, i la seva configuració és dins d'aquesta entrada — no hi ha cap fitxer de configuració separat ni cap subobjecte `config`. El `format` del rellotge, el `formatAlt` (allò a què el clic dret fa rotar) i el `verticalFormat` viuen tots just aquí a `{ "id": "omarchy.clock" }`.

`centerAnchor` anomena l'únic giny del centre que es fixa al centre exacte de la pantalla, amb els altres flanquejant-lo. Així és com el rellotge es manté ben centrat fins i tot mentre el temps i el distintiu d'actualització van i venen. Definiu-lo a una cadena buida i la llista del centre simplement se centrarà com a grup.

Una regla que val la pena interioritzar: **un cop teniu el vostre propi `shell.json`, és canònic**. Fins que no personalitzeu res, el shell llegeix el fitxer per defecte d'Omarchy. En el moment que arrossegueu un giny, executeu `omarchy bar` o editeu el fitxer vosaltres mateixos, passa a ser vostre — no hi ha fusió en profunditat, de manera que els ginys nous per defecte en futures versions d'Omarchy no apareixeran automàticament a la vostra barra. `omarchy bar defaults` restableix la disposició subministrada sempre que vulgueu començar de zero.

El mateix fitxer també conté els vostres temps d'inactivitat al nivell superior, fora de la clau `bar`: `idle.screensaver` i `idle.lock`, tots dos en segons des que vau quedar inactius. Així, el salvapantalles per defecte s'activa als 150 segons i el bloqueig als 300.
