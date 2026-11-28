# La barra superior

La franja de la part superior de la pantalla és la barra d'Omarchy. No és una barra d'estat acoblada, sinó part de la shell d'Omarchy, l'únic procés Quickshell de llarga durada que també dibuixa el menú, les notificacions, les finestres emergents OSD i la pantalla de bloqueig. Per això el tema s'adapta perfectament a tota la resta i per això un panell s'obre a l'instant en lloc d'iniciar una aplicació nova.

També és l'única peça de l'escriptori que sempre és a la pantalla, així que val la pena saber què fan tots aquells glifs petits.

## Què hi ha per defecte

La barra té tres seccions. A l'esquerra hi ha el logotip d'Omarchy (el llançador del menú) i els indicadors d'espais de treball. Al centre hi ha els indicadors d'estat, el rellotge, Elsewhen (un rellotge mundial), el temps i una insígnia d'actualització d'Omarchy. A la dreta: la safata del sistema, la disposició del teclat (quan hi ha configurada més d'una disposició o mètode d'entrada), agents, bluetooth, xarxa, àudio, pantalla i energia.

Alguns d'aquests només apareixen quan tenen alguna cosa a dir. La disposició del teclat només apareix si has configurat més d'una disposició o mètode d'entrada. La insígnia d'actualització només apareix quan hi ha una actualització d'Omarchy esperant.

## Fer clic

Gairebé tots els widgets fan alguna cosa amb el clic esquerre, dret i central, i diversos responen al desplaçament. Aquesta és la part que la gent es perd: els botons dret i central són on s'amaga gran part del millor.

| Widget | Esquerre | Dret | Central / desplaçament |
| --- | --- | --- | --- |
| Menú | Menú d'Omarchy | Terminal nou | — |
| Espais de treball | Centra aquell espai de treball en aquest monitor | — | Desplaçament: espai de treball següent/anterior |
| Rellotge | Finestra emergent del calendari | Canvia cíclicament el format de l'etiqueta | Central: selector de fus horari |
| Rellotge mundial | Panell del rellotge mundial | Actualitza | Central: actualitza |
| Temps | Finestra emergent de la previsió | El temps complet com a notificació | Central: actualitza |
| Àudio | Panell d'àudio | Silencia | Central: panell · desplaçament: volum |
| Micròfon | Silencia el micròfon | — | Central: panell d'àudio · desplaçament: volum d'entrada |
| Xarxa | Panell de xarxa | — | — |
| Bluetooth | Panell de Bluetooth | Activa/desactiva la ràdio | — |
| Pantalla | Panell de pantalla | — | Desplaçament: brillantor |
| Energia | Panell d'energia | Activa/desactiva el percentatge de bateria | — |
| Multimèdia | Reprodueix/pausa | Finestra emergent de la portada | Central: següent · desplaçament: anterior/següent |
| Agents | Panell d'agents | Inicia el teu agent | Central: actualitza l'ús |
| Safata | Passa el cursor per damunt per revelar el calaix | Clic dret sobre el galó per gestionar-ho | — |
| Actualització d'Omarchy | Executa l'actualització | — | — |

No tot el que hi ha en aquesta taula és a la teva barra de sèrie. El widget multimèdia (MPRIS de reproducció actual, amb una pista i un artista que es desplacen) i el widget del micròfon estan integrats però desactivats per defecte: afegeix-los si els vols, tal com es descriu més avall.

## Els panells

En fer clic en una icona de la barra s'obre un panell, que és una finestra emergent com cal, amb controls lliscants, llistes i navegació amb teclat, en lloc d'un consell. Cada un també té una drecera de teclat, perquè mai no hagis d'apuntar a un glif de 16 píxels:

| Drecera | Panell |
| --- | --- |
| `Super + Ctrl + A` | Àudio |
| `Super + Ctrl + N` | Xarxa |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Pantalla |
| `Super + Ctrl + P` | Energia |
| `Super + Ctrl + Alt + D` | Calendari |
| `Super + Ctrl + Alt + E` | Rellotge mundial |
| `Super + Ctrl + X` | Agents |
| `Super + Ctrl + 1-9` | Activa/desactiva l'enèsim panell de la secció dreta |

Els panells no són panells de lectura. Són on realment fas la cosa:

- **Àudio** té un control lliscant de volum principal, un selector de dispositiu de sortida i un mesclador per aplicació, perquè puguis abaixar aquella pestanya del navegador sense tocar tota la resta.
- **Xarxa** cerca xarxes Wi-Fi, mostra la intensitat del senyal, s'hi connecta i et permet triar un proveïdor de DNS.
- **Bluetooth** llista els teus dispositius amb connexió/desconnexió i nivells de bateria.
- **Energia** mostra estadístiques de la bateria, canvia els perfils d'energia (recorda una tria separada per a bateria i per a CA) i imprimeix una mica d'informació del sistema.
- **Pantalla** inclou un control lliscant de brillantor, la mida del text, valors predefinits d'escala del monitor i — quan tens més d'una pantalla — controls per monitor. Consulta [monitors](33-monitors.md) per a la història completa.
- **Rellotge** obre una graella mensual amb números de setmana ISO i canvi de mes.
- **Rellotge mundial** manté una fila per ciutat, amb el seu temps i com li va el dia. La cerca troba pobles a més de fusos horaris, de manera que Fort Lauderdale és Fort Lauderdale i no Nova York. Si la línia de dalt indica la ciutat equivocada, fes-hi clic i digues on ets; tria un lloc d'un altre fus horari i el rellotge del sistema també s'hi traslladarà, cosa molt pràctica quan viatges. Passa el cursor per damunt d'una ciutat i fes clic al botó de la persona per dir qui hi viu: noms senzills, o identificadors de GitHub amb `@` per portar-ne també les cares.

Cada panell accepta el teclat a més del ratolí: les fletxes mouen, Return activa, Tab passa al panell veí i Escape tanca.

`Super + Ctrl + 1-9` compta els panells d'esquerra a dreta a la secció dreta, saltant-se la safata, perquè no té cap panell propi. Així el número coincideix amb la icona que assenyalaries.

### Tailscale i Dropbox

Dos widgets més apareixen a la barra només quan instal·les el servei corresponent des d'**Instal·la → Servei**, i val la pena conèixer tots dos perquè fan més que informar de l'estat.

El panell de **Tailscale** connecta i desconnecta de la tailnet, canvia entre comptes i tria un node de sortida (tant les teves màquines com les regions de Mullvad apareixen en aquella llista). També explora les teves màquines — i, amb una de seleccionada, `s` li envia fitxers mitjançant Taildrop, que és la manera més ràpida de traslladar un fitxer al teu telèfon o a un altre portàtil. `c` copia la IP de la màquina, `n` el seu nom i `d` el seu nom DNS complet. També hi ha un botó d'enviament a cada fila de màquina, si prefereixes fer clic. La mateixa cosa des del terminal és `omarchy tailscale send <machine> [file...]`.

El panell de **Dropbox** s'encarrega de l'inici de sessió, mostra quant d'emmagatzematge has fet servir i llista els fitxers sincronitzats recentment.

En suprimir qualsevol dels dos serveis, el seu widget desapareix de la barra.

## Indicadors

El petit grup del centre és el widget d'indicadors. Són glifs d'estat per als modes que has activat: no molestis, llum nocturna, un [recordatori](09-reminders.md) en cua, una gravació de pantalla activa i mantenir despert, a més d'avisos mentre el sudo sense contrasenya està activat o algú està connectat a una sessió remota. S'il·luminen quan el mode està actiu i, si no, es mantenen fora del camí: passa el cursor just al costat, on serien els inactius, per fer-hi una ullada. En fer clic en un indicador s'activa o desactiva aquell mode. N'hi ha un més que és només d'estat: una sessió remota s'il·lumina en vermell mentre algú està connectat a aquesta màquina mitjançant gliff.

Si prefereixes que sempre siguin visibles, estableix `alwaysShow` a `true` en el widget. I si només t'interessen alguns, llista els que vulguis a `items`: `["Dnd", "Reminder", "NightLight"]`. Pots tenir més d'un widget d'indicadors, de manera que seccions diferents poden mostrar subconjunts diferents.

## Reorganitzar la barra

La barra es configura sola. No has d'obrir cap fitxer de configuració per moure coses.

Agafa un tros buit de la barra al voltant del centre i arrossega'l cap a una altra vora de la pantalla, i la barra s'hi traslladarà: esquerra, dreta, dalt o baix funcionen, i tots els widgets s'hi adapten (les barres verticals recorren a formes compactes només amb icones). Un clic mantingut inicia el mateix arrossegament. Fes doble clic esquerre en aquell mateix espai buit per canviar cíclicament el fons de la barra de transparent a vidriós a opac. I arrossega qualsevol widget per reordenar-lo o llançar-lo a una altra secció; els altres widgets se separen lliscant per fer lloc on anirà a parar.

El mig de la barra és una caixa: tot el que hi ha a dins es manté centrat com un sol grup, i els widgets de cada costat pengen de les seves vores. Mentre arrossegues un widget, la caixa es mostra com un contorn, o com una línia que travessa la barra quan és buida, i hi pots deixar elements a dins o al costat. Quan una deixada aniria a parar a la caixa, la caixa creix per acollir el widget.

Un widget que vols tenir a prop però no sempre a la vista pot anar al calaix de la safata: arrossega'l a la safata i el calaix s'obrirà per acollir-lo. S'hi queda després de les icones de les aplicacions, apareix sempre que ho fa el calaix i manté el seu calaix obert mentre el seu panell està obert. Arrossega'l de nou a la barra per tornar-lo a posar.

Si prefereixes triar-ho des d'un menú, **Aparença → Barra de menú** té la posició, i **Fons de la barra** tria com es dibuixa la barra: **Barra opaca**, **Barra vidriosa** (transparent, amb el que hi ha darrere difuminat) o **Barra transparent**.

Les mateixes coses tenen ordres, que és el que vols per a una configuració de [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Per afegir o eliminar un widget completament, fes servir les ordres de complements. `omarchy plugin list` imprimeix tots els widgets que la shell coneix amb el seu id, i després:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Amagar la barra

`Super + Shift + Space` amaga la barra i la torna a mostrar sense matar la shell: els panells i les dreceres continuen funcionant, simplement recuperes els píxels. També és al menú a **Aparença → Barra de menú → Amaga la barra**.

## El fitxer de configuració

Tot això s'emmagatzema a `~/.config/omarchy/shell.json`, sota la clau `bar`. Aquí en tens una versió retallada:

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

Tots els widgets són una entrada d'una de les cinc matrius de disposició, i la seva configuració és en línia en aquella entrada: no hi ha cap fitxer de configuració separat ni cap subobjecte `config`. El `format`, el `formatAlt` (al que passa el clic dret en cicle) i el `verticalFormat` del rellotge viuen just allà a `{ "id": "omarchy.clock" }`.

`center` és la caixa del mig de la barra: tot el que hi ha a dins es centra a la pantalla com un sol grup. `centerBegin` i `centerEnd` pengen de cada costat de la caixa, i així és com el rellotge es manté ben bé al centre encara que el temps i la insígnia d'actualització vagin i vinguin. Posa més d'un widget a `center` i es centraran junts; deixa'l buit i `centerBegin` i `centerEnd` es trobaran al mig de la barra.

Una regla que val la pena interioritzar: **un cop tens el teu propi `shell.json`, és canònic**. Fins que no personalitzis res, la shell llegeix el fitxer per defecte d'Omarchy. En el moment en què arrossegues un widget, executes `omarchy bar` o edites el fitxer tu mateix, és teu: no hi ha cap fusió profunda, de manera que els nous widgets per defecte de les futures versions d'Omarchy no apareixeran automàticament a la teva barra. `omarchy bar defaults` restableix la disposició subministrada sempre que vulguis començar de zero.

El mateix fitxer també conté els teus temps d'inactivitat al nivell superior, fora de la clau `bar`: `idle.screensaver` i `idle.lock`, tots dos en segons des que vas passar a estar inactiu. Així, l'estalvi de pantalla per defecte entra en funcionament als 150 segons i el bloqueig als 300.
