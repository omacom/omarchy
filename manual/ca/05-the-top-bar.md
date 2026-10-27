# La barra superior

La franja de la part superior de la pantalla és la barra d'Omarchy. No és una barra d'estat acoblada, sinó part de l'intèrpret d'Omarchy, l'únic procés Quickshell de llarga durada que també dibuixa el menú, les notificacions, les finestres emergents OSD i la pantalla de bloqueig. Per això el tema combina perfectament amb tota la resta i per això un panell s'obre a l'instant en lloc d'iniciar una aplicació nova.

També és l'única peça de l'escriptori que sempre és a la pantalla, així que val la pena saber què fan tots aquells glifs petits.

## Què hi ha per defecte

La barra té tres seccions. A l'esquerra hi ha el logotip d'Omarchy (el llançador del menú) i els indicadors dels espais de treball. Al centre hi tens els indicadors d'estat, el rellotge, Elsewhen (un rellotge mundial), el temps i una insígnia d'actualització d'Omarchy. A la dreta: la safata del sistema, la distribució del teclat (quan n'hi ha més d'una configurada), els agents, el bluetooth, la xarxa, l'àudio, la pantalla i l'energia.

Alguns d'aquests només apareixen quan tenen alguna cosa a dir. La distribució del teclat només apareix si n'has configurat més d'una. La insígnia d'actualització només apareix quan hi ha una actualització d'Omarchy esperant. I la icona dels agents apareix la primera vegada que Omarchy troba ús de codificació amb AI a la màquina (vegeu [AI](17-ai.md)).

## Fer clic

Gairebé tots els elements fan alguna cosa amb el clic esquerre, dret i mitjà, i diversos responen al desplaçament. Aquesta és la part que la gent es perd: els botons dret i mitjà són on s'amaga bona part de les coses bones.

| Element | Esquerre | Dret | Mitjà / desplaçament |
| --- | --- | --- | --- |
| Menú | Menú d'Omarchy | Terminal nou | — |
| Espais de treball | Enfoca aquell espai de treball en aquest monitor | — | Desplaçament: espai de treball següent/anterior |
| Rellotge | Finestra emergent del calendari | Recorre els formats de l'etiqueta | Mitjà: selector de zona horària |
| Temps | Finestra emergent de la previsió | Temps complet com a notificació | Mitjà: actualitza |
| Àudio | Panell d'àudio | Silencia | Mitjà: panell · desplaçament: volum |
| Micròfon | Silencia el micròfon | — | Mitjà: panell d'àudio · desplaçament: volum d'entrada |
| Xarxa | Panell de xarxa | — | — |
| Bluetooth | Panell de Bluetooth | Activa o desactiva la ràdio | — |
| Pantalla | Panell de pantalla | — | Desplaçament: brillantor |
| Energia | Panell d'energia | Activa o desactiva el percentatge de bateria | — |
| Multimèdia | Reprodueix/pausa | Finestra emergent de la caràtula | Mitjà: següent · desplaçament: anterior/següent |
| Agents | Panell d'agents | Inicia el teu agent | Mitjà: subscripció següent |
| Safata | Passa el cursor per sobre per revelar el calaix | Clic dret al galó per gestionar-lo | — |
| Actualització d'Omarchy | Executa l'actualització | — | — |

No tot el que hi ha en aquesta taula és a la teva barra d'entrada. L'element multimèdia (MPRIS del que s'està reproduint, amb una pista i un artista que es desplacen) i l'element del micròfon estan integrats però desactivats per defecte: afegeix-los si els vols, tal com s'explica més avall.

## Els panells

Fer clic a una icona de la barra obre un panell, que és una finestra emergent com cal, amb controls lliscants, llistes i navegació amb el teclat, en lloc d'un consell. Cadascun també té una drecera, així que mai no has d'encertar un glif de 16 píxels:

| Drecera | Panell |
| --- | --- |
| `Super + Ctrl + A` | Àudio |
| `Super + Ctrl + N` | Xarxa |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Pantalla |
| `Super + Ctrl + P` | Energia |
| `Super + Ctrl + Alt + D` | Calendari |
| `Super + Ctrl + Alt + E` | Rellotge mundial |
| `Super + Ctrl + 1-9` | Activa o desactiva l'enèsim panell de la secció dreta |

Els panells no són simples indicadors. Són on fas la cosa de debò:

- **Àudio** té un control lliscant de volum principal, un selector de dispositiu de sortida i un mesclador per aplicació, així pots abaixar aquella pestanya del navegador sense tocar tota la resta.
- **Xarxa** cerca xarxes Wi-Fi, mostra la intensitat del senyal, s'hi connecta i et deixa triar un proveïdor DNS.
- **Bluetooth** llista els teus dispositius amb connexió/desconnexió i nivells de bateria.
- **Energia** mostra estadístiques de la bateria, canvia els perfils d'energia (recorda una elecció separada per a bateria i AC) i imprimeix una mica d'informació del sistema.
- **Pantalla** porta un control lliscant de brillantor, la mida del text, valors predefinits d'escala del monitor i, quan tens més d'una pantalla, controls per monitor. Vegeu [monitors](33-monitors.md) per a la història més profunda.
- **Rellotge** obre una quadrícula mensual amb números de setmana ISO i canvi de mes.
- **Rellotge mundial** manté una fila per ciutat, amb el seu temps i com li va el dia. La cerca troba pobles a més de zones horàries, així que Fort Lauderdale és Fort Lauderdale i no New York. Si la línia de dalt anomena la ciutat equivocada, fes-hi clic i digues on ets; tria un lloc d'una altra zona horària i el rellotge del sistema també s'hi trasllada, cosa que és pràctica quan viatges. Passa el cursor per sobre d'una ciutat i fes clic al botó de la persona per dir qui hi viu: noms simples, o identificadors `@` de GitHub per portar les seves cares amb ells.

Tots els panells accepten el teclat a més del ratolí: les fletxes mouen, Return activa, Tab passa al panell veí i Escape tanca.

`Super + Ctrl + 1-9` compta els panells d'esquerra a dreta a la secció dreta, saltant-se la safata perquè no té panell propi. Així el número coincideix amb la icona que assenyalaria.

### Tailscale i Dropbox

Dos elements més apareixen a la barra només un cop instal·les el servei corresponent des d'**Install → Service**, i tots dos valen la pena perquè fan més que informar de l'estat.

El panell de **Tailscale** connecta i desconnecta la tailnet, canvia entre comptes i tria un node de sortida (tant les teves màquines com les regions de Mullvad apareixen en aquella llista). També explora les teves màquines, i amb una seleccionada, `s` li envia fitxers mitjançant Taildrop, que és la manera més ràpida de moure un fitxer al teu telèfon o a un altre portàtil. `c` copia la IP de la màquina, `n` el seu nom i `d` el seu nom DNS complet. També hi ha un botó d'enviament a cada fila de màquina, si prefereixes fer clic. El mateix des del terminal és `omarchy tailscale send <machine> [file...]`.

El panell de **Dropbox** gestiona l'inici de sessió, mostra quant emmagatzematge has fet servir i llista els fitxers sincronitzats recentment.

Eliminar qualsevol dels dos serveis treu el seu element de la barra.

## Indicadors

El petit grup del centre és l'element d'indicadors. Aquests són glifs d'estat per als modes que has activat: no molestis, llum nocturna, un [reminder](09-reminders.md) en cua, una gravació de pantalla activa, mantenir-se despert i [dictation](11-text-extraction-dictation.md). S'il·luminen quan el mode és actiu i, si no, es mantenen fora del camí: passa el cursor per sobre de qualsevol lloc de la barra per fer una ullada als inactius. Fer clic a un indicador activa o desactiva aquell mode. Un més és només d'estat: una sessió remota s'il·lumina en vermell mentre algú està connectat a aquesta màquina mitjançant gliff.

Si prefereixes que sempre siguin visibles, estableix `alwaysShow` a `true` a l'element. I si només t'interessen alguns d'ells, llista els que vulguis a `items`: `["Dnd", "Reminder", "NightLight"]`. Pots tenir més d'un element d'indicadors, així diferents seccions poden mostrar diferents subconjunts.

## Reordenar la barra

La barra es configura sola. No has d'obrir un fitxer de configuració per moure coses.

Agafa un tros buit de la barra al voltant del centre i arrossega'l cap a una altra vora de la pantalla, i la barra s'hi trasllada: esquerra, dreta, dalt o baix funcionen, i tots els elements s'adapten (les barres verticals recorren a formes compactes només d'icones). Un clic mantingut inicia el mateix arrossegament. Fes doble clic esquerre en aquell mateix espai buit per recórrer el fons de la barra de transparent a vidriós a opac. I arrossega qualsevol element per reordenar-lo o llançar-lo a una altra secció; els altres elements s'obren per fer espai on aterrarà.

El mig de la barra és una caixa: el que hi ha dins es manté centrat com un sol grup, i els elements de cada costat pengen de les seves vores. Mentre arrossegues un element, la caixa es mostra com un contorn, o una línia a través de la barra quan és buida, i hi pots deixar anar dins o al costat. Quan una deixada aniria a parar a la caixa, la caixa creix per acollir l'element.

Un element que vols tenir a prop però no sempre a la vista pot anar al calaix de la safata: arrossega'l a la safata i el calaix s'obre per acollir-lo. Es queda allà després de les icones de les aplicacions, apareix sempre que ho fa el calaix i manté el seu calaix obert mentre el seu panell és obert. Arrossega'l de nou a la barra per tornar-lo a posar.

Si prefereixes triar des d'un menú, **Appearance → Menu Bar** té la posició, i **Bar Background** tria com es dibuixa la barra: **Opaque Bar**, **Glassy Bar** (transparent, amb el que hi ha darrere difuminat) o **Clear Bar**.

Les mateixes coses tenen ordres, que és el que vols per a una configuració de [dotfiles](31-dotfiles.md):

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Per afegir o eliminar un element completament, fes servir les ordres de connectors. `omarchy plugin list` imprimeix tots els elements que l'intèrpret coneix amb el seu id, i després:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Amagar la barra

`Super + Shift + Space` amaga la barra i la torna a mostrar sense matar l'intèrpret: els panells i les dreceres continuen funcionant, simplement recuperes els píxels. També és al menú a **Appearance → Menu Bar → Hide Bar**.

## El fitxer de configuració

Tot s'emmagatzema a `~/.config/omarchy/shell.json`, sota la clau `bar`. Aquí en tens una versió retallada:

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

Cada element és una entrada en una de les cinc matrius de disposició, i els seus ajustos són inline en aquella entrada: no hi ha cap fitxer d'ajustos separat ni cap subobjecte `config`. El `format`, el `formatAlt` (allò a què el clic dret passa per torns) i el `verticalFormat` del rellotge viuen tots allà mateix a `{ "id": "omarchy.clock" }`.

`center` és la caixa del mig de la barra: tot el que hi ha es centra a la pantalla com un sol grup. `centerBegin` i `centerEnd` pengen de cada costat de la caixa, que és com el rellotge es manté ben bé al centre encara que el temps i la insígnia d'actualització vinguin i vagin. Posa més d'un element a `center` i es centraran junts; deixa'l buit i `centerBegin` i `centerEnd` es trobaran al mig de la barra.

Una regla que val la pena interioritzar: **un cop tens el teu propi `shell.json`, és canònic**. Fins que no personalitzes res, l'intèrpret llegeix el fitxer per defecte d'Omarchy. En el moment que arrossegues un element, executes `omarchy bar` o edites el fitxer tu mateix, és teu: no hi ha cap fusió profunda, així que els nous elements per defecte de futures versions d'Omarchy no apareixeran automàticament a la teva barra. `omarchy bar defaults` torna a posar la disposició subministrada sempre que vulguis partir de zero.

El mateix fitxer també conté els teus temps d'inactivitat al nivell superior, fora de la clau `bar`: `idle.screensaver` i `idle.lock`, tots dos en segons des que vas quedar inactiu. Així, l'estalvi de pantalla per defecte entra als 150 segons i el bloqueig als 300.
