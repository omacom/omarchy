# Commutadors, la inactivitat i l'estalvi de pantalla

Molt del que canvies dia a dia no és ben bé un ajust. És un mode que actives durant una hora i després tornes a desactivar: la llum nocturna mentre treballes fins tard, el no molesteu mentre fas una presentació, mantenir-te despert mentre mires alguna cosa. Omarchy els anomena commutadors, i tots funcionen de la mateixa manera: una drecera, una entrada de menú i una ordre, tots accionant el mateix interruptor.

### El menú de commutadors

`Super + Ctrl + O` obre _Disparador > Commutador_ directament, o hi pots arribar des del menú d'Omarchy (`Super + Space`). Tot el que hi ha en aquesta llista és un interruptor que pots accionar sense pensar on viu l'estat. Els interruptors de l'aspecte de l'escriptori són al costat, a _Aparença_.

Des del terminal, els mateixos interruptors són `omarchy toggle <thing>`. Executa `omarchy toggle` tot sol per veure tot el grup.

| Commutador | Drecera | Ordre |
| ------ | ------ | ------- |
| Llum nocturna | — | `omarchy toggle nightlight` |
| Silencia les notificacions | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Mantén-te despert (sense bloqueig per inactivitat) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Captura de fallades | — | `omarchy toggle crash-capture` |
| Estalvi de pantalla | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) sincronització del tema | — | `omarchy toggle theme sync` |
| Barra de menú | `Super + Shift + Space` | `omarchy toggle bar` |
| Escriptori a pantalla completa (sense barra, sense buits) | `Super + Ctrl + Alt + F` | `omarchy toggle fullscreen desktop` |
| Animacions, desenfocament i ombres | — | `omarchy toggle animations` |
| Panell tàctil | `XF86TouchpadToggle` | `omarchy device touchpad` |
| Pantalla tàctil | — | `omarchy device touchscreen` |
| Suspensió | — | `omarchy toggle suspend` |
| GPU híbrida | — | `omarchy device gpu hybrid` |

Els commutadors del panell tàctil, la pantalla tàctil i la GPU híbrida viuen a _Disparador > Maquinari_ (`Super + Ctrl + H`) en lloc de ser a Commutador, perquè només apareixen quan realment tens aquest maquinari. Els del panell tàctil i la pantalla tàctil sobreviuen a una recàrrega de Hyprland: el nom del dispositiu desactivat es desa en un petit fitxer d'estat que Hyprland llegeix en arrencar per tornar-lo a desactivar.

_Aparença_ conté la barra de menú i les animacions, a més d'algunes coses que no són ordres `omarchy toggle` però es comporten igual: el percentatge de bateria a la barra, la disposició predeterminada de l'espai de treball i, a _Finestres_, els buits entre finestres (`Super + Shift + Backspace`) i l'aspecte quadrat d'1 finestra (`Super + Ctrl + Backspace`).

Quan Hyprland no té cap GPU amb què dibuixar i renderitza amb la CPU (llvmpipe), com en els Mac la GPU dels quals encara no és compatible, en la majoria de màquines virtuals o quan un controlador gràfic no es carrega, Omarchy desactiva les animacions, el desenfocament i les ombres per a aquesta sessió i t'ho comunica una vegada amb una notificació. _Aparença > Animacions activades_ els torna a activar, i Omarchy també ho recorda per a sessions posteriors.

La majoria són simplement un fitxer de marca a `~/.local/state/omarchy/toggles/`. Si en vols comprovar un en un script, `omarchy-toggle-enabled` et dona un codi de sortida en lloc de fer-te anar a buscar:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Les marques s'anomenen per l'estat desactivat — `screensaver-off`, `suspend-off`, `bar-off` — de manera que la seva presència significa que la funció està desactivada.

### Indicadors a la barra

Quan un mode està activat, obtens un petit glif al mig de la barra superior, al costat del rellotge. Això és el giny d'indicadors, i inclou la gravació de pantalla, els recordatoris pendents, la llum nocturna, el no molesteu i mantenir-te despert, a més d'avisos mentre sudo sense contrasenya està activat o algú està connectat a una sessió remota.

Els indicadors inactius estan ocults. Passa el cursor per sobre de qualsevol punt de la barra i apareixen atenuats, de manera que pots fer clic en un per activar-lo sense conèixer-ne la drecera. Fer clic en un d'actiu el torna a desactivar. Si prefereixes veure'ls tots sempre, estableix `alwaysShow` a `true` a l'entrada `omarchy.indicators` de `~/.config/omarchy/shell.json` — vegeu [la barra superior](05-the-top-bar.md) per saber com es configuren els ginys de la barra.

### Llum nocturna

La llum nocturna escalfa la pantalla a 4000K, i tornar-la a commutar la retorna a 6500K. Acciona-la des del menú de commutadors (`Super + Ctrl + O`) o amb `omarchy toggle nightlight`. L'acciona hyprsunset, que el commutador inicia per tu si encara no s'està executant.

Per defecte, hyprsunset no fa absolutament res a la teva pantalla. `~/.config/hypr/hyprsunset.conf` inclou un perfil d'identitat precisament perquè la pantalla es mantingui intacta fins que demanis calidesa. Si prefereixes que canviï segons el rellotge, substitueix-lo per un perfil horari:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Després inicia hyprsunset en iniciar la sessió afegint `o.launch_on_start("hyprsunset")` a `~/.config/hypr/autostart.lua`. La parella 4000K/6500K que utilitza el commutador és fixa, de manera que el fitxer de configuració és on has d'anar si vols una temperatura diferent.

### No molesteu

`Super + Ctrl + Alt + ,` silencia les notificacions. No apareix cap notificació emergent mentre està activat, i l'indicador de la campana ratllada roman a la barra per recordar-te per què l'escriptori s'ha quedat en silenci.

Però no es perd res. Les notificacions silenciades es retenen: torna a posar les últimes a la pantalla amb `Super + Shift + Alt + ,`. Vegeu [avisos](10-notices.md) per a la resta.

Tres tipus de missatge encara passen: les notificacions de confirmació pròpies d'Omarchy per a alguna cosa que acabes de fer ("Theme changed", "Screenshot saved"), les alertes crítiques enviades des de la línia d'ordres i els codis de verificació. Les aplicacions de xat que ho marquen tot com a crític per forçar-se a posar-se davant teu no hi tenen dret.

### Inactivitat

El shell d'Omarchy s'encarrega del comportament d'inactivitat, i els temps són un bloc `idle` de nivell superior a `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Tots dos números són segons comptats des del moment en què has passat a estar inactiu, no l'un des de l'altre. Així, amb els valors predeterminats, l'estalvi de pantalla apareix després de dos minuts i mig i la pantalla de bloqueig pren el relleu als cinc minuts, tant si l'estalvi de pantalla s'ha executat com si no. Desa el fitxer i el shell recull els nous temps immediatament.

Si descartes l'estalvi de pantalla abans del termini de bloqueig, això compta com a activitat i el bloqueig pendent es cancel·la. No et quedes bloquejat per fer una ullada a la teva màquina.

Per aturar completament el bloqueig per inactivitat, `Super + Ctrl + I` — o `omarchy toggle idle` — activa mantenir-te despert, i l'indicador de la tassa de cafè apareix a la barra. És el que cal prémer abans d'una presentació llarga o d'una compilació que vols vigilar. Prem-lo de nou per tornar a la normalitat. `omarchy toggle idle status` imprimeix l'estat actual com a JSON si el necessites des d'un script.

Això va de bloqueig i estalvi de pantalla, no d'energia. La suspensió i la hibernació tenen la seva pròpia configuració a [repòs del sistema](36-system-sleep.md).

### L'estalvi de pantalla

L'estalvi de pantalla d'Omarchy és art ASCII que passa per efectes de text aleatoris, una instància per monitor. Qualsevol tecla o moviment del ratolí en surt.

Pots iniciar-lo a demanda des de _Sistema > Estalvi de pantalla_ (`Super + Esc`), que el força encara que hagis desactivat l'estalvi de pantalla per inactivitat. Per defecte no hi ha cap drecera vinculada a ell.

`omarchy toggle screensaver` és el que desactiva el d'inactivitat, si prefereixes anar directament de treballar a bloquejat. Qualsevol tecla, clic, desplaçament o moviment del ratolí el tanca.

El logotip que dibuixa és teu per canviar-lo, a _Aparença > Marca > Estalvi de pantalla_. Puja un png o svg i Omarchy el converteix a ASCII. Vegeu [marca](41-branding.md).

### La pantalla de bloqueig

`Super + Ctrl + L` bloqueja la màquina. Això executa la pantalla de bloqueig del shell d'Omarchy, apaga la pantalla, restableix la disposició del teclat a la primera perquè no escriguis la contrasenya en l'alfabet equivocat i — si el tens en execució — bloqueja 1Password en sortir.

La pantalla de bloqueig accepta una contrasenya, i també acceptarà una empremta digital un cop n'hagis configurada una. Això, i les altres maneres d'autenticar-te, es tracten a [autenticació de maquinari](37-hardware-authentication.md).
