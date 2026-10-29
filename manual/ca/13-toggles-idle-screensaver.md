# Commutadors, inactivitat i l'estalvi de pantalla

Molta part del que canvies en el dia a dia no és ben bé una configuració. És un mode que actives durant una hora i després tornes a desactivar: llum nocturna mentre treballes fins tard, no molesteu mentre fas una presentació, mantén-te despert mentre mires alguna cosa. Omarchy els anomena commutadors, i tots funcionen de la mateixa manera: una drecera de teclat, una entrada de menú i una ordre, tots accionant el mateix interruptor.

### El menú de commutadors

`Super + Ctrl + O` obre _Activador > Commutador_ directament, o hi pots arribar des del menú d'Omarchy (`Super + Space`). Tot el que hi ha en aquesta llista és un interruptor que pots accionar sense pensar on viu l'estat. Els interruptors de l'aspecte de l'escriptori són just al costat, a _Aparença_.

Des del terminal, els mateixos interruptors són `omarchy toggle <thing>`. Executa `omarchy toggle` tot sol per veure tot el grup.

| Commutador | Drecera de teclat | Ordre |
| ------ | ------ | ------- |
| Llum nocturna | — | `omarchy toggle nightlight` |
| Silencia les notificacions | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Mantén-te despert (sense bloqueig per inactivitat) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Captura de fallades | — | `omarchy toggle crash-capture` |
| Estalvi de pantalla | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev): sincronització del tema | — | `omarchy toggle theme sync` |
| Barra de menús | `Super + Shift + Space` | `omarchy toggle bar` |
| Tauler tàctil | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Pantalla tàctil | — | `omarchy toggle touchscreen` |
| Suspensió | — | `omarchy toggle suspend` |
| GPU híbrida | — | `omarchy toggle hybrid gpu` |

El tauler tàctil, la pantalla tàctil i els interruptors de la GPU híbrida viuen a _Activador > Maquinari_ (`Super + Ctrl + H`) en lloc de a Commutador, ja que només apareixen quan realment tens aquest maquinari. Els del tauler tàctil i la pantalla tàctil sobreviuen a una recàrrega de Hyprland: el nom del dispositiu desactivat es desa en un petit fitxer d'estat que Hyprland llegeix en l'arrencada per tornar-lo a desactivar.

_Aparença_ conté la barra de menús i les animacions, més unes quantes coses que no són ordres `omarchy toggle` però es comporten igual: el percentatge de bateria a la barra, la disposició predeterminada de l'espai de treball i, a _Finestres_, els espais entre finestres (`Super + Shift + Backspace`) i la relació d'aspecte quadrada d'1 finestra (`Super + Ctrl + Backspace`).

La majoria d'aquests són només un fitxer de marca a `~/.local/state/omarchy/toggles/`. Si en un script vols condicionar segons un d'ells, `omarchy-toggle-enabled` et dona un codi de sortida en lloc d'obligar-te a anar a buscar:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Els fitxers de marca s'anomenen per l'estat desactivat — `screensaver-off`, `suspend-off`, `bar-off` — de manera que la seva presència significa que la funció està desactivada.

### Indicadors a la barra

Quan un mode està activat, reps un glif petit al mig de la barra superior, al costat del rellotge. Això és el widget d'indicadors, i inclou dictat, enregistrament de pantalla, recordatoris pendents, llum nocturna, no molesteu i mantén-te despert.

Els indicadors inactius estan ocults. Passa el cursor per sobre de qualsevol punt de la barra i apareixen atenuats, perquè puguis fer clic en un per activar-lo sense conèixer-ne la drecera de teclat. Fer clic en un d'actiu el torna a desactivar. Si prefereixes veure'ls tots sempre, defineix `alwaysShow` a `true` a l'entrada `omarchy.indicators` de `~/.config/omarchy/shell.json` — consulta [la barra superior](05-the-top-bar.md) per saber com es configuren els widgets de la barra.

### Llum nocturna

La llum nocturna escalfa la pantalla a 4000K, i tornar-la a commutar la retorna a 6500K. Acciona-la des del menú de commutadors (`Super + Ctrl + O`) o amb `omarchy toggle nightlight`. L'acciona hyprsunset, que el commutador inicia per tu si encara no s'està executant.

Per defecte, hyprsunset no fa absolutament res a la teva pantalla. `~/.config/hypr/hyprsunset.conf` ve amb un perfil d'identitat precisament perquè la pantalla es quedi intacta fins que demanis escalfor. Si prefereixes que canviï segons l'hora, substitueix-ho per un perfil horari:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Després, inicia hyprsunset en iniciar sessió afegint `o.launch_on_start("hyprsunset")` a `~/.config/hypr/autostart.lua`. La parella 4000K/6500K que utilitza el commutador és fixa, així que el fitxer de configuració és on has d'anar si vols una temperatura diferent.

### No molesteu

`Super + Ctrl + Alt + ,` silencia les notificacions. Mentre està activat, no apareix cap notificació emergent, i l'indicador de la campana ratllada es queda a la barra per recordar-te per què l'escriptori s'ha quedat en silenci.

Però no es perd res. Les notificacions silenciades es retenen: torna a posar les últimes a la pantalla amb `Super + Shift + Alt + ,`. Consulta [avisos](10-notices.md) per a la resta.

Dos tipus de missatge encara passen: les notificacions emergents de confirmació del mateix Omarchy per alguna cosa que acabes de fer ("Tema canviat", "Captura de pantalla desada") i les alertes crítiques enviades des de la línia d'ordres. Les aplicacions de xat que marquen tot com a crític per posar-se davant teu per la força no compten.

### Inactivitat

La shell d'Omarchy és responsable del comportament d'inactivitat, i els temps són un bloc `idle` de nivell superior a `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Tots dos números són segons comptats des del moment en què has quedat inactiu, no l'un des de l'altre. Així, amb els valors predeterminats, l'estalvi de pantalla apareix al cap de dos minuts i mig i la pantalla de bloqueig pren el relleu als cinc minuts, tant si l'estalvi de pantalla s'ha executat com si no. Desa el fitxer i la shell recull els nous temps immediatament.

Si descartes l'estalvi de pantalla abans del termini de bloqueig, això compta com a activitat i el bloqueig pendent es cancel·la. No et quedes bloquejat per haver fet una ullada a la màquina.

Per deixar de bloquejar per inactivitat del tot, `Super + Ctrl + I` — o `omarchy toggle idle` — activa el mode mantén-te despert, i l'indicador de la tassa de cafè apareix a la barra. És el que has de prémer abans d'una presentació llarga o d'una compilació que vulguis vigilar. Prem-lo de nou per tornar a la normalitat. `omarchy toggle idle status` imprimeix l'estat actual com a JSON si el necessites des d'un script.

Això va de bloqueig i estalvi de pantalla, no d'energia. La suspensió i la hibernació tenen la seva pròpia configuració a [la suspensió del sistema](36-system-sleep.md).

### L'estalvi de pantalla

L'estalvi de pantalla d'Omarchy és art ASCII que passa per efectes de text aleatoris, una instància per monitor. Qualsevol tecla o moviment del ratolí en surt.

El pots iniciar a demanda des de _Sistema > Estalvi de pantalla_ (`Super + Esc`), que el força a aparèixer encara que hagis desactivat l'estalvi de pantalla per inactivitat. Per defecte no hi ha cap drecera de teclat vinculada.

`omarchy toggle screensaver` és el que desactiva el d'inactivitat, si prefereixes passar directament de treballar a bloquejat. Qualsevol tecla, clic, desplaçament o moviment del ratolí el tanca.

El logotip que dibuixa el pots canviar tu, a _Aparença > Imatge de marca > Estalvi de pantalla_. Puja un png o svg i Omarchy el converteix a ASCII. Consulta [imatge de marca](41-branding.md).

### La pantalla de bloqueig

`Super + Ctrl + L` bloqueja la màquina. Això executa la pantalla de bloqueig des de la shell d'Omarchy, deixa la pantalla en negre, restableix la disposició del teclat a la primera perquè no escriguis la contrasenya en l'alfabet equivocat i — si el tens en execució — bloqueja 1Password en sortir.

La pantalla de bloqueig accepta una contrasenya, i també acceptarà una empremta dactilar un cop n'hagis configurat una. Això, i les altres maneres d'autenticar-te, es tracten a [autenticació de maquinari](37-hardware-authentication.md).
