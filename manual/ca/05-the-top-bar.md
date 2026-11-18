# La barra superior

La franja que recorre la part superior de la pantalla és la barra d'Omarchy. No és una barra d'estat afegida com un pegat, sinó part de la shell d'Omarchy, l'únic procés de Quickshell de llarga durada que també dibuixa el menú, les notificacions, les finestres emergents OSD i la pantalla de bloqueig. Per això el seu tema combina perfectament amb tota la resta i per això un panell s'obre a l'instant en lloc d'iniciar una aplicació nova.

És també l'única peça de l'escriptori que sempre és a la pantalla, així que val la pena saber què fan tots aquells petits glifs.

## Què hi ha per defecte

La barra té tres seccions. A l'esquerra hi ha el logotip d'Omarchy (el llançador del menú) i els indicadors d'espais de treball. Al centre hi tens els indicadors d'estat, el rellotge, Elsewhen (un rellotge mundial), el temps i una insígnia d'actualització d'Omarchy. A la dreta: la safata del sistema, la disposició del teclat (quan n'hi ha més d'una de configurada), els agents, el bluetooth, la xarxa, l'àudio, la pantalla i l'energia.

Alguns d'aquests només apareixen quan tenen alguna cosa a dir. La disposició del teclat només apareix si n'has configurat més d'una. La insígnia d'actualització només apareix quan hi ha una actualització d'Omarchy esperant. I la icona dels agents apareix la primera vegada que Omarchy troba ús de codificació amb IA a la màquina (vegeu [IA](17-ai.md)).

## Fer clic arreu

Gairebé tots els widgets fan alguna cosa amb el clic esquerre, dret i central, i diversos responen al desplaçament. Aquesta és la part que la gent es perd — els botons dret i central són on s'amaga gran part del millor.

| Widget | Esquerre | Dret | Central / desplaçament |
| --- | --- | --- | --- |
| Menú | Menú d'Omarchy | Terminal nou | — |
| Espais de treball | Centra aquell espai de treball en aquest monitor | — | Desplaçament: espai de treball següent/anterior |
| Rellotge | Finestra emergent del calendari | Canvia el format de l'etiqueta | Central: selector de fus horari |
| Temps | Finestra emergent de la previsió | Temps complet com a notificació | Central: actualitza |
| Àudio | Panell d'àudio | Silencia | Central: panell · desplaçament: volum |
| Micròfon | Silencia el micròfon | — | Central: panell d'àudio · desplaçament: volum d'entrada |
| Xarxa | Panell de xarxa | — | — |
| Bluetooth | Panell de Bluetooth | Activa/desactiva la ràdio | — |
| Pantalla | Panell de pantalla | — | Desplaçament: brillantor |
| Energia | Panell d'energia | Mostra/amaga el percentatge de bateria | — |
| Multimèdia | Reprodueix/posa en pausa | Finestra emergent de la portada | Central: següent · desplaçament: anterior/següent |
| Agents | Panell d'agents | Inicia el teu agent | Central: subscripció següent |
| Safata | Passa el cursor per sobre per mostrar el calaix | Clic dret al xebró per gestionar-lo | — |
| Actualització d'Omarchy | Executa l'actualització | — | — |

No tot el que hi ha en aquella taula és a la teva barra d'entrada. El widget multimèdia (MPRIS en reproducció ara, amb una pista i un artista que es desplacen) i el widget del micròfon estan integrats, però desactivats per defecte — afegeix-los si els vols, tal com es descriu més avall.

## Els panells

En fer clic a una icona de la barra s'obre un panell, que és una finestra emergent com cal, amb controls lliscants, llistes i navegació amb teclat, en lloc d'un consell emergent. Cadascun també té una drecera de teclat, de manera que mai no has d'apuntar a un glif de 16 píxels:

| Drecera | Panell |
| --- | --- |
| `Super + Ctrl + A` | Àudio |
| `Super + Ctrl + N` | Xarxa |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Pantalla |
| `Super + Ctrl + P` | Energia |
| `Super + Ctrl + Alt + D` | Calendari |
| `Super + Ctrl + Alt + E` | Rellotge mundial |
| `Super + Ctrl + 1-9` | Activa/desactiva l'enèsim panell de la secció de la dreta |

Els panells no són simples lectures. Són on realment fas la feina:

- **Àudio** té un control lliscant de volum principal, un selector de dispositiu de sortida i un mesclador per aplicació, de manera que pots abaixar aquella pestanya del navegador sense tocar tota la resta.
- **Xarxa** cerca xarxes Wi-Fi, mostra la intensitat del senyal, s'hi connecta i et permet triar un proveïdor de DNS.
- **Bluetooth** enumera els teus dispositius amb connexió/desconnexió i nivells de bateria.
- **Energia** mostra estadístiques de la bateria, canvia els perfils d'energia (recorda una tria diferent per a la bateria i per a l'AC) i imprimeix una mica d'informació del sistema.
- **Pantalla** inclou un control lliscant de brillantor, la mida del text, valors predefinits d'escalat del monitor i — quan tens més d'una pantalla — controls per a cada monitor. Vegeu [monitors](33-monitors.md) per a la història més detallada.
- **Rellotge** obre una graella mensual amb números de setmana ISO i canvi de mes.
- **Rellotge mundial** manté una fila per ciutat, amb el seu temps i com li va el dia. La cerca troba pobles a més de fusos horaris, de manera que Fort Lauderdale és Fort Lauderdale i no Nova York. Si la línia de la part superior anomena la ciutat equivocada, fes-hi clic i digues on ets; tria algun lloc en un altre fus horari i el rellotge del sistema també s'hi traslladarà, cosa que va molt bé quan viatges. Passa el cursor per sobre d'una ciutat i fes clic al botó de la persona per dir qui hi viu — noms senzills, o identificadors de GitHub amb `@` per portar-ne també les cares.

Tots els panells accepten tant el teclat com el ratolí: les fletxes mouen, Return activa, Tab passa al panell veí i Escape tanca.

`Super + Ctrl + 1-9` compta els panells d'esquerra a dreta a la secció de la dreta, saltant-se la safata perquè no té panell propi. Així el número coincideix amb la icona que apuntaries.

### Tailscale i Dropbox

Dos widgets més apareixen a la barra només quan instal·les el servei corresponent des d'**Instal·la → Servei**, i val la pena conèixer tots dos perquè fan més que informar de l'estat.

El panell de **Tailscale** connecta i desconnecta la tailnet, canvia entre comptes i tria un node de sortida (tant les teves pròpies màquines com les regions de Mullvad apareixen en aquella llista). També explora les teves màquines — i, amb una de seleccionada, `s` hi envia fitxers mitjançant Taildrop, que és la manera més ràpida de moure un fitxer al teu telèfon o a un altre portàtil. `c` copia la IP de la màquina, `n` el seu nom i `d` el seu nom DNS complet. També hi ha un botó d'enviament a cada fila de màquina, per si prefereixes fer clic. El mateix des del terminal és `omarchy tailscale send <machine> [file...]`.

El panell de **Dropbox** gestiona l'inici de sessió, mostra quant d'emmagatzematge has utilitzat i enumera els fitxers sincronitzats recentment.

Si elimines qualsevol dels dos serveis, el seu widget desapareixerà de la barra.

## Indicadors

El petit grup del centre és el widget d'indicadors. Són glifs d'estat per als modes que has activat: no molestar, llum nocturna, un [recordatori](09-reminders.md) a la cua, una gravació de pantalla activa, mantenir despert i [dictat](11-text-extraction-dictation.md). S'il·luminen quan el mode és actiu i, si no, no fan nosa — passa el cursor just al seu costat, on serien els inactius, per fer una ullada a aquells. En fer clic a un indicador s'activa o es desactiva aquell mode. N'hi ha un altre que és només d'estat: una sessió remota s'il·lumina en vermell mentre algú està connectat a aquesta màquina mitjançant gliff.

Si prefereixes que sempre siguin visibles, estableix `alwaysShow` a `true` al widget. I si només te n'importen alguns, enumera els que vols a `items`: `["Dnd", "Reminder", "NightLight"]`. Pots tenir més d'un widget d'indicadors, de manera que seccions diferents poden mostrar subconjunts diferents.

## Reorganitzar la barra

La barra es configura sola. No has d'obrir cap fitxer de configuració per moure coses.

Agafa un tros buit de la barra al voltant del centre i arrossega'l cap a un altre extrem de la pantalla, i la barra s'hi traslladarà — esquerra, dreta, a dalt o a baix, tot funciona, i cada widget s'hi adapta (les barres verticals recorren a formes compactes només amb icones). Un clic mantingut inicia el mateix arrossegament. Fes doble clic esquerre en aquell mateix espai buit per canviar el fons de la barra de transparent a vidriós a opac. I arrossega qualsevol widget per reordenar-lo o llançar-lo a una altra secció; els altres widgets se separaran per fer lloc on anirà a parar.

El mig de la barra és una caixa: tot el que hi ha es manté centrat com un sol grup, i els widgets de cada costat pengen dels seus extrems. Mentre arrossegues un widget, la caixa es mostra com un contorn, o com una línia que travessa la barra quan és buida, i hi pots deixar anar dins o al costat. Quan una deixada aniria a parar a la caixa, la caixa creix per acollir el widget.

Un widget que vols tenir a prop però no sempre a la vista pot anar al calaix de la safata: arrossega'l a sobre de la safata i el calaix s'obrirà per acollir-lo. Hi queda després de les icones de les aplicacions, apareix sempre que ho fa el calaix i manté el seu calaix obert mentre el seu panell és obert. Arrossega'l de nou cap a fora, a la barra, per tornar-lo a posar.

Si prefereixes triar des d'un menú, **Aparença → Barra de menú** té la posició, i **Fons de la barra** tria com es dibuixa la barra: **Barra opaca**, **Barra vidriosa** (transparent, amb el que hi ha darrere difuminat) o **Barra transparent**.

El mateix es pot fer amb ordres, que és el que vols per a una configuració amb [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Per afegir o eliminar un widget del tot, utilitza les ordres de connectors. `omarchy plugin list` imprimeix tots els widgets que la shell coneix amb el seu id, i després:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Amagar la barra

`Super + Shift + Space` amaga i torna a mostrar la barra sense matar la shell — els panells i les dreceres continuen funcionant, simplement recuperes els píxels. També és al menú, a **Aparença → Barra de menú → Amaga la barra**.

## El fitxer de configuració

Tot es desa a `~/.config/omarchy/shell.json`, sota la clau `bar`. Aquí en tens una versió retallada:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "centerBegin": [{ "id": "omarchy.indicators" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "centerEnd": [{ "id": "omarchy.weather" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Cada widget és una entrada en una de les cinc matrius de disposició, i la seva configuració és en línia en aquella entrada — no hi ha cap fitxer de configuració separat ni cap subobjecte `config`. El `format`, el `formatAlt` (allò a què canvia el clic dret) i el `verticalFormat` del rellotge viuen tots allà mateix, a `{ "id": "omarchy.clock" }`.

`center` és la caixa del mig de la barra: tot el que conté se centra a la pantalla com un sol grup. `centerBegin` i `centerEnd` pengen de cada costat de la caixa, i així és com el rellotge es manté ben bé al centre encara que el temps i la insígnia d'actualització vinguin i vagin. Posa més d'un widget a `center` i se centraran junts; deixa'l buit i `centerBegin` i `centerEnd` es trobaran al mig de la barra.

Una regla que val la pena interioritzar: **un cop tens el teu propi `shell.json`, és canònic**. Fins que no personalitzis res, la shell llegeix el fitxer per defecte d'Omarchy. En el moment en què arrossegues un widget, executes `omarchy bar` o edites el fitxer tu mateix, és teu — no hi ha cap fusió profunda, de manera que els widgets nous per defecte de les futures versions d'Omarchy no apareixeran automàticament a la teva barra. `omarchy bar defaults` torna a posar la disposició subministrada sempre que vulguis començar de zero.

El mateix fitxer també conté els teus temps d'inactivitat al nivell superior, fora de la clau `bar`: `idle.screensaver` i `idle.lock`, tots dos en segons des que vas passar a estar inactiu. Així, l'estalvi de pantalla per defecte s'activa als 150 segons i el bloqueig als 300.
