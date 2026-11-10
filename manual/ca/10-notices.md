# Avisos

Les notificacions arriben a la cantonada superior dreta de la pantalla enfocada. També pots accedir ràpidament a la data i l'hora, a l'estat de la bateria i al temps actual amb els avisos per drecera de teclat.

## Notificacions

Les notificacions de la mateixa aplicació o lloc s'apilen en una baralla, de manera que un canal de Slack xerraire no et tregui de la pantalla l'error de compilació. Passa el cursor per sobre d'una baralla per ventar-la; no s'hi colarà res de nou sota el punter mentre llegeixes. Fes clic en una targeta per saltar d'on ve, fes-hi clic amb el botó dret, amb el botó central o prem el ✕ per descartar-la.

Les targetes ofereixen el que porten: _Copia el codi_ per als codis de verificació (que es mantenen fora de l'[historial del porta-retalls](08-unified-clipboard-history.md) i s'esborren al cap d'un minut), a més de qualsevol botó que proporcioni l'aplicació. Els enllaços del text d'una notificació s'obren quan hi fas clic.

Per fer-les servir sense el ratolí, prem `Super + Ctrl + ,`. La notificació més recent queda seleccionada i els seus botons numerats: prem un número per fer-ne servir un, `Enter` per fer clic a la notificació, `↑` i `↓` per moure't entre notificacions, `Delete` per descartar-ne una i `Esc` per tornar el teclat. També es deixa anar per si sola al cap d'uns segons sense activitat.

Silenciar les notificacions les reté, excepte les confirmacions del mateix Omarchy, les alertes d'emergència i els codis de verificació, que acabes de demanar fa un moment. Torna a posar les últimes a la pantalla, retingudes o no, amb `Super + Shift + Alt + ,`. L'historial es conserva durant un dia.

## Avisos per drecera de teclat

### Data i hora

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Temps

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

La ubicació es detecta a partir de la teva adreça IP, que normalment s'hi acosta prou, però no sempre. La pots fixar amb `omarchy weather location --set Malibu`, o ser exacte afegint-hi coordenades: `omarchy weather location --set Malibu 34.0259,-118.7798`. Executa `omarchy weather location` tot sol per veure on creu que ets, i `--clear` per tornar a la detecció automàtica.

### Bateria

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
