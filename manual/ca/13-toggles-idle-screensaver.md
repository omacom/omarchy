# Commutadors, inactivitat i l'estalvi de pantalla

Gran part del que canvies en el dia a dia no és realment un ajust. És un mode que actives durant una hora i després tornes a desactivar: la llum nocturna mentre treballes fins tard, el no molesteu mentre fas una presentació, el mantenir-te despert mentre mires alguna cosa. Omarchy els anomena commutadors, i tots funcionen de la mateixa manera: una tecla d'accés ràpid, una entrada de menú i una ordre, tots accionant el mateix interruptor.

### El menú de commutadors

`Super + Ctrl + O` obre _Activador > Commutador_ directament, o hi pots arribar des del menú d'Omarchy (`Super + Space`). Tot el que hi ha en aquesta llista és un interruptor que pots accionar sense pensar on viu l'estat. Els interruptors de l'aspecte de l'escriptori són al costat, a _Aparença_.

Des del terminal, els mateixos interruptors són `omarchy toggle <thing>`. Executa `omarchy toggle` tot sol per veure tot el grup.

| Commutador | Tecla d'accés ràpid | Ordre |
| ------ | ------ | ------- |
| Llum nocturna | — | `omarchy toggle nightlight` |
| Silencia les notificacions | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Mantén-te despert (sense bloqueig per inactivitat) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Captura de fallades | — | `omarchy toggle crash-capture` |
| Estalvi de pantalla | — | `omarchy toggle screensaver` |
| Sincronització de tema de [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Barra de menús | `Super + Shift + Space` | `omarchy toggle bar` |
| Panell tàctil | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Pantalla tàctil | — | `omarchy toggle touchscreen` |
| Suspensió | — | `omarchy toggle suspend` |
| GPU híbrida | — | `omarchy toggle hybrid gpu` |

Els interruptors del panell tàctil, la pantalla tàctil i la GPU híbrida són a _Activador > Maquinari_ (`Super + Ctrl + H`) en lloc de ser a Commutador, perquè només apareixen quan realment tens aquest maquinari. Els del panell tàctil i la pantalla tàctil sobreviuen a una recàrrega de Hyprland: el nom del dispositiu desactivat es desa en un petit fitxer d'estat que Hyprland llegeix en iniciar-se per tornar-lo a desactivar.

_Aparença_ conté la barra de menús i les animacions, a més d'algunes coses que no són ordres `omarchy toggle` però que es comporten igual: el percentatge de bateria a la barra, la disposició predeterminada de l'espai de treball i, a _Finestres_, els espais entre finestres (`Super + Shift + Backspace`) i l'aspecte quadrat d'1 finestra (`Super + Ctrl + Backspace`).

Quan Hyprland no té cap GPU amb què dibuixar i renderitza amb la CPU (llvmpipe), com passa als Mac la GPU dels quals encara no és compatible, a la majoria de màquines virtuals o quan un controlador gràfic no es carrega, Omarchy desactiva les animacions, el difuminat i les ombres durant aquella sessió i t'ho comunica una sola vegada amb una notificació. _Aparença > Animacions activades_ els torna a activar, i Omarchy també ho recorda per a sessions posteriors.

La majoria són simplement un fitxer de marca a `~/.local/state/omarchy/toggles/`. Si en vols comprovar un en un script, `omarchy-toggle-enabled` et dona un codi de sortida en lloc d'obligar-te a anar a buscar-lo:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Les marques porten el nom de l'estat desactivat — `screensaver-off`, `suspend-off`, `bar-off` —, de manera que la seva presència significa que la funció està desactivada.

### Indicadors a la barra

Quan un mode està activat, obtens un petit glif al centre de la barra superior, al costat del rellotge. És el giny d'indicadors, i inclou dictat, gravació de pantalla, recordatoris pendents, llum nocturna, no molesteu i mantenir-te despert.

Els indicadors inactius s'amaguen. Passa el cursor per sobre de qualsevol punt de la barra i apareixen atenuats, perquè en puguis fer clic en un per activar-lo sense conèixer-ne la tecla d'accés ràpid. Si fas clic en un d'actiu, es torna a desactivar. Si prefereixes veure'ls tots sempre, defineix `alwaysShow` com a `true` a l'entrada `omarchy.indicators` de `~/.config/omarchy/shell.json`: consulta [la barra superior](05-the-top-bar.md) per saber com es configuren els ginys de la barra.

### Llum nocturna

La llum nocturna escalfa la pantalla fins a 4000K, i si la tornes a commutar, la retorna a 6500K. Acciona-la des del menú de commutadors (`Super + Ctrl + O`) o amb `omarchy toggle nightlight`. La controla hyprsunset, que el commutador inicia per tu si encara no s'està executant.

Per defecte, hyprsunset no fa absolutament res a la pantalla. `~/.config/hypr/hyprsunset.conf` inclou un perfil d'identitat precisament perquè la pantalla es mantingui intacta fins que demanis escalfor. Si prefereixes que canviï segons el rellotge, substitueix-lo per un perfil horari:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Després inicia hyprsunset en iniciar la sessió afegint `o.launch_on_start("hyprsunset")` a `~/.config/hypr/autostart.lua`. La parella 4000K/6500K que utilitza el commutador és fixa, de manera que el fitxer de configuració és on has d'anar si vols una temperatura diferent.

### No molesteu

`Super + Ctrl + Alt + ,` silencia les notificacions. Mentre està activat no apareix cap notificació emergent, i l'indicador de la campana ratllada roman a la barra per recordar-te per què l'escriptori s'ha quedat en silenci.

Però no es perd res. Les notificacions silenciades es retenen: torna a posar les últimes a la pantalla amb `Super + Shift + Alt + ,`. Consulta [avisos](10-notices.md) per a la resta.

Dos tipus de missatges encara hi passen: les notificacions emergents de confirmació d'Omarchy per alguna cosa que acabes de fer ("Theme changed", "Screenshot saved") i les alertes crítiques enviades des de la línia d'ordres. Les aplicacions de xat que marquen tot com a crític per obrir-se pas davant teu no hi tenen dret.

### Inactivitat

El shell d'Omarchy és el propietari del comportament d'inactivitat, i els temps són un bloc `idle` de nivell superior a `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Ambdós números són segons comptats des del moment en què has passat a estar inactiu, no l'un des de l'altre. Així, amb els valors predeterminats, l'estalvi de pantalla apareix al cap de dos minuts i mig i la pantalla de bloqueig pren el relleu als cinc minuts, tant si l'estalvi de pantalla s'ha executat com si no. Desa el fitxer i el shell recull els nous temps immediatament.

Si descartes l'estalvi de pantalla abans del termini de bloqueig, això compta com a activitat i el bloqueig pendent es cancel·la. No et quedes bloquejat per haver fet una ullada a la màquina.

Per deixar de bloquejar per inactivitat del tot, `Super + Ctrl + I` —o `omarchy toggle idle`— activa el mantenir-te despert, i l'indicador de la tassa de cafè apareix a la barra. És el que has d'accionar abans d'una presentació llarga o d'una compilació que vulguis mirar. Torna'l a accionar per tornar a la normalitat. `omarchy toggle idle status` imprimeix l'estat actual com a JSON si el necessites des d'un script.

Això va del bloqueig i l'estalvi de pantalla, no de l'energia. La suspensió i la hibernació tenen la seva pròpia configuració a [suspensió del sistema](36-system-sleep.md).

### L'estalvi de pantalla

L'estalvi de pantalla d'Omarchy és art ASCII que passa per efectes de text aleatoris, una instància per monitor. Qualsevol tecla o moviment del ratolí en surt.

El pots iniciar a demanda des de _Sistema > Estalvi de pantalla_ (`Super + Esc`), cosa que el força a aparèixer encara que hagis desactivat l'estalvi de pantalla per inactivitat. Per defecte no hi ha cap tecla d'accés ràpid assignada.

`omarchy toggle screensaver` és el que desactiva el d'inactivitat, si prefereixes passar directament de treballar a bloquejat. Qualsevol tecla, clic, desplaçament o moviment del ratolí el tanca.

El logotip que dibuixa el pots canviar tu, a _Aparença > Imatge de marca > Estalvi de pantalla_. Puja un png o un svg i Omarchy el converteix en ASCII. Consulta [imatge de marca](41-branding.md).

### La pantalla de bloqueig

`Super + Ctrl + L` bloqueja la màquina. Això executa la pantalla de bloqueig del shell d'Omarchy, apaga la pantalla, restableix la disposició del teclat a la primera perquè no escriguis la contrasenya en l'alfabet equivocat i, si el tens en execució, bloqueja 1Password en sortir.

La pantalla de bloqueig accepta una contrasenya, i també acceptarà una empremta digital un cop n'hagis configurat una. Això, i les altres maneres d'autenticar-te, es tracten a [autenticació de maquinari](37-hardware-authentication.md).
