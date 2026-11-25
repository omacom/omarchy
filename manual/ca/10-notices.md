# Avisos

Les notificacions apareixen a la cantonada superior dreta de la pantalla focalitzada. També pots accedir ràpidament a la data i l'hora, l'estat de la bateria i el temps actual amb els avisos per tecles d'accés ràpid.

## Notificacions

Les notificacions de la mateixa aplicació o lloc s'apilen en una baralla, de manera que un canal xerraire de Slack no fa fora de la pantalla l'error de compilació. Passa el cursor per sobre d'una baralla per desplegar-la en ventall; res de nou no s'hi fica sota el punter mentre llegeixes. Fes clic en una targeta per saltar d'on prové, fes-hi clic amb el botó dret, clic amb el botó central o prem el ✕ per descartar-la.

Les targetes ofereixen el que porten: _Copia el codi_ per als codis de verificació (que es mantenen fora de l'[historial del porta-retalls](08-unified-clipboard-history.md) i s'esborren al cap d'un minut), a més de qualsevol botó que proporcioni l'aplicació. Els enllaços del text d'una notificació s'obren en fer-hi clic.

`Super + ,` descarta la notificació més recent, o obre allò a què apunta quan ho ofereix, `Super + Alt + ,` descarta només l'última, `Super + Shift + ,` les descarta totes, i `Super + Shift + Alt + ,` obre l'historial. Per utilitzar-les sense el ratolí, prem `Super + Ctrl + ,`. La notificació més recent queda seleccionada i els seus botons es numeren: prem un número per utilitzar-ne un, `Enter` per fer clic a la notificació, `↑` i `↓` per moure't entre notificacions, `Delete` per descartar-ne una i `Esc` per tornar el teclat. També es deixa anar per si sol al cap d'uns segons d'inactivitat.

Silenciar les notificacions les reté, excepte les confirmacions del mateix Omarchy, les alertes d'emergència i els codis de verificació, que has demanat fa un moment. Torna a posar les últimes en pantalla, retingudes o no, amb `Super + Shift + Alt + ,`. L'historial es conserva durant un dia.

## Avisos per tecles d'accés ràpid

### Data i hora

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Temps

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

La ubicació es detecta a partir de la teva adreça IP, que normalment és prou aproximada, però no sempre. Pots fixar-la amb `omarchy weather location --set Malibu`, o ser exacte afegint-hi coordenades: `omarchy weather location --set Malibu 34.0259,-118.7798`. Executa `omarchy weather location` tot sol per veure on creu que ets, i `--clear` per tornar a la detecció automàtica.

### Bateria

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
