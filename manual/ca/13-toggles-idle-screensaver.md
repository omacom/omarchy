# Commutadors, inactivitat i el salvapantalles

Una bona part del que canvies en el dia a dia no és pròpiament una configuració. És un mode que actives durant una hora i després tornes a desactivar: la llum nocturna mentre treballes fins tard, el mode no molestar mentre fas una presentació, mantenir l'equip despert mentre mires alguna cosa. Omarchy els anomena commutadors, i tots funcionen de la mateixa manera: una drecera de teclat, una entrada de menú i una ordre, que actuen sobre el mateix interruptor.

### El menú de commutadors

`Super + Ctrl + O` obre directament _Activació > Commutador_, o hi pots arribar des del menú d'Omarchy (`Super + Space`). Tot el que hi ha en aquella llista és un interruptor que pots activar o desactivar sense pensar on es desa l'estat. Els interruptors sobre l'aspecte de l'escriptori són al costat, a _Aparença_.

Des del terminal, els mateixos interruptors són `omarchy toggle <thing>`. Executa `omarchy toggle` sol per veure tot el grup.

| Commutador | Drecera de teclat | Ordre |
| ------ | ------ | ------- |
| Llum nocturna | — | `omarchy toggle nightlight` |
| Silencia les notificacions | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Mantenir despert (sense bloqueig per inactivitat) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Captura de fallades | — | `omarchy toggle crash-capture` |
| Salvapantalles | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) sincronització de tema | — | `omarchy toggle theme sync` |
| Barra de menús | `Super + Shift + Space` | `omarchy toggle bar` |
| Panell tàctil | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Pantalla tàctil | — | `omarchy device touchscreen` |
| Suspensió | — | `omarchy toggle suspend` |
| GPU híbrida | — | `omarchy toggle hybrid gpu` |

Els commutadors del panell tàctil, la pantalla tàctil i la GPU híbrida són a _Activació > Maquinari_ (`Super + Ctrl + H`) en comptes de a Commutador, perquè només apareixen quan realment tens aquell maquinari. El del panell tàctil i el de la pantalla tàctil sobreviuen a una recàrrega de Hyprland: el nom del dispositiu desactivat es desa en un petit fitxer d'estat que Hyprland llegeix en arrencar per tornar-lo a desactivar.

_Aparença_ conté la barra de menús i les animacions, a més d'unes quantes coses que no són ordres `omarchy toggle` però que es comporten igual: el percentatge de bateria a la barra, la disposició predeterminada de l'espai de treball i, a _Finestres_, els espais entre finestres (`Super + Shift + Backspace`) i l'aspecte quadrat d'1 finestra (`Super + Ctrl + Backspace`).

Quan Hyprland no té cap GPU amb què dibuixar i renderitza amb la CPU (llvmpipe), com passa en els Mac la GPU dels quals encara no és compatible, en la majoria de màquines virtuals o quan un controlador gràfic no es carrega, Omarchy desactiva les animacions, el desenfocament i les ombres durant aquella sessió i t'ho comunica una sola vegada amb una notificació. _Aparença > Animacions activades_ els torna a activar, i Omarchy també ho recorda per a sessions posteriors.

La majoria són només un fitxer de marca a `~/.local/state/omarchy/toggles/`. Si en vols fer servir un per bifurcar en un script, `omarchy-toggle-enabled` et dona un codi de sortida en comptes de fer-te anar a buscar-lo:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Les marques reben el nom de l'estat desactivat — `screensaver-off`, `suspend-off`, `bar-off` —, de manera que la seva presència significa que la funció està desactivada.

### Indicadors a la barra

Quan un mode està activat, veus un petit glif al mig de la barra superior, al costat del rellotge. És el giny d'indicadors, i inclou el dictat, la gravació de pantalla, els recordatoris pendents, la llum nocturna, el mode no molestar i mantenir despert.

Els indicadors inactius estan ocults. Passa el cursor per damunt de qualsevol punt de la barra i apareixen atenuats, de manera que pots fer clic en un per activar-lo sense saber-ne la drecera de teclat. Fer clic en un d'actiu el torna a desactivar. Si prefereixes veure'ls tots sempre, defineix `alwaysShow` com a `true` a l'entrada `omarchy.indicators` de `~/.config/omarchy/shell.json`: consulta [la barra superior](05-the-top-bar.md) per saber com es configuren els ginys de la barra.

### Llum nocturna

La llum nocturna escalfa la pantalla fins a 4000K, i tornar-la a commutar la retorna a 6500K. Activa-la des del menú de commutadors (`Super + Ctrl + O`) o amb `omarchy toggle nightlight`. L'impulsa hyprsunset, que el commutador inicia per tu si encara no està en execució.

Per defecte, hyprsunset no fa absolutament res a la pantalla. `~/.config/hypr/hyprsunset.conf` inclou un perfil d'identitat precisament perquè la pantalla no es toqui fins que demanis calidesa. Si prefereixes que canviï segons l'hora, substitueix-lo per un perfil horari:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Després, fes que hyprsunset s'iniciï en iniciar la sessió afegint `o.launch_on_start("hyprsunset")` a `~/.config/hypr/autostart.lua`. La parella 4000K/6500K que fa servir el commutador és fixa, així que el fitxer de configuració és on has d'anar si vols una temperatura diferent.

### No molestar

`Super + Ctrl + Alt + ,` silencia les notificacions. Mentre està activat no apareix cap notificació emergent, i l'indicador de la campana ratllada es queda a la barra per recordar-te per què l'escriptori s'ha quedat en silenci.

Però no es perd res. Les notificacions silenciades es retenen: torna a mostrar les últimes a la pantalla amb `Super + Shift + Alt + ,`. Consulta [avisos](10-notices.md) per a la resta.

Dos tipus de missatges sí que passen: les notificacions emergents de confirmació del mateix Omarchy per alguna cosa que acabes de fer ("Tema canviat", "Captura de pantalla desada"), i les alertes crítiques enviades des de la línia d'ordres. Les aplicacions de xat que ho marquen tot com a crític per posar-se davant teu a la força no compten.

### Inactivitat

La shell d'Omarchy s'encarrega del comportament en inactivitat, i els temps són un bloc `idle` de primer nivell a `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Tots dos nombres són segons comptats des del moment en què has quedat inactiu, no des de l'un a l'altre. Així, amb els valors predeterminats, el salvapantalles apareix al cap de dos minuts i mig i la pantalla de bloqueig se'n fa càrrec als cinc minuts, tant si el salvapantalles s'ha executat com si no. Desa el fitxer i la shell adopta els nous temps immediatament.

Si descartes el salvapantalles abans del termini de bloqueig, això compta com a activitat i el bloqueig pendent es cancel·la. No et quedes bloquejat per haver fet una ullada a la màquina.

Per deixar de bloquejar per inactivitat del tot, `Super + Ctrl + I` —o `omarchy toggle idle`— activa el mode mantenir despert, i l'indicador de la tassa de cafè apareix a la barra. És el que has de prémer abans d'una presentació llarga o d'una compilació que vols vigilar. Prem-lo un altre cop per tornar a la normalitat. `omarchy toggle idle status` mostra l'estat actual com a JSON si el necessites des d'un script.

Això va del bloqueig i el salvapantalles, no de l'energia. La suspensió i la hibernació tenen la seva pròpia configuració a [repòs del sistema](36-system-sleep.md).

### El salvapantalles

El salvapantalles d'Omarchy és art ASCII que passa per efectes de text aleatoris, una instància per monitor. Qualsevol tecla o moviment del ratolí en surt.

El pots iniciar a demanda des de _Sistema > Salvapantalles_ (`Super + Esc`), que el força a aparèixer encara que hagis desactivat el salvapantalles per inactivitat. Per defecte no hi té cap drecera de teclat assignada.

`omarchy toggle screensaver` és el que desactiva el d'inactivitat, si prefereixes passar directament de treballar a l'estat bloquejat. Qualsevol tecla, clic, desplaçament o moviment del ratolí el tanca.

El logotip que dibuixa el pots canviar tu, a _Aparença > Imatge de marca > Salvapantalles_. Penja un png o un svg i Omarchy el converteix en ASCII. Consulta [imatge de marca](41-branding.md).

### La pantalla de bloqueig

`Super + Ctrl + L` bloqueja la màquina. Això executa la pantalla de bloqueig de la shell d'Omarchy, deixa la pantalla en blanc, restableix la disposició del teclat a la primera perquè no escriguis la contrasenya en l'alfabet equivocat i —si el tens en execució— bloqueja 1Password en sortir.

La pantalla de bloqueig accepta una contrasenya, i també acceptarà una empremta dactilar un cop n'hagis configurat una. Això, i les altres maneres d'autenticar-se, es tracten a [autenticació de maquinari](37-hardware-authentication.md).
