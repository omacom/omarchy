# Commutadors, inactivitat i l'estalvi de pantalla

Molt del que canvies en el dia a dia no és ben bé un ajustament. És un mode que actives durant una hora i el tornes a desactivar: la llum nocturna mentre treballes fins tard, el no molestis mentre fas una presentació, mantenir-te despert mentre mires alguna cosa. Omarchy els anomena commutadors, i tots funcionen de la mateixa manera: una tecla d'accés ràpid, una entrada de menú i una ordre, que toquen tots el mateix interruptor.

### El menú de commutadors

`Super + Ctrl + O` obre directament _Activador > Commutador_, o hi pots arribar des del menú d'Omarchy (`Super + Space`). Tot el que hi ha en aquesta llista és un interruptor que pots commutar sense pensar on viu l'estat. Els interruptors de l'aspecte de l'escriptori són al costat, a _Aparença_.

Des del terminal, els mateixos interruptors són `omarchy toggle <thing>`. Executa `omarchy toggle` tot sol per veure tot el grup.

| Commutador | Tecla d'accés ràpid | Ordre |
| ------ | ------ | ------- |
| Llum nocturna | — | `omarchy toggle nightlight` |
| Silencia les notificacions | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| Mantén despert (sense bloqueig per inactivitat) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Captura d'errors | — | `omarchy toggle crash-capture` |
| Estalvi de pantalla | — | `omarchy toggle screensaver` |
| Sincronització de tema de [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Barra de menú | `Super + Shift + Space` | `omarchy toggle bar` |
| Panell tàctil | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Pantalla tàctil | — | `omarchy toggle touchscreen` |
| Suspensió | — | `omarchy toggle suspend` |
| GPU híbrida | — | `omarchy toggle hybrid gpu` |

Els commutadors del panell tàctil, la pantalla tàctil i la GPU híbrida viuen a _Activador > Maquinari_ (`Super + Ctrl + H`) en lloc de ser a Commutador, ja que només apareixen quan realment tens aquest maquinari. Els del panell tàctil i la pantalla tàctil sobreviuen a una recàrrega de Hyprland: el nom del dispositiu desactivat es desa en un petit fitxer d'estat que Hyprland llegeix en arrencar per tornar-lo a desactivar.

_Aparença_ conté la barra de menú i les animacions, a més d'algunes coses que no són ordres `omarchy toggle` però que es comporten igual: el percentatge de bateria a la barra, la disposició predeterminada de l'espai de treball i, a _Finestres_, els espais entre finestres (`Super + Shift + Backspace`) i la proporció quadrada d'1 finestra (`Super + Ctrl + Backspace`).

La majoria d'aquests són només un fitxer de marca a `~/.local/state/omarchy/toggles/`. Si en vols condicionar un en un script, `omarchy-toggle-enabled` et dona un codi de sortida en lloc de fer-te anar a buscar:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Les marques s'anomenen segons l'estat desactivat — `screensaver-off`, `suspend-off`, `bar-off` —, de manera que la seva presència significa que la funció està desactivada.

### Indicadors a la barra

Quan un mode està activat, reps un petit glif al mig de la barra superior, al costat del rellotge. Això és el giny d'indicadors, i conté el dictat, la gravació de pantalla, els recordatoris pendents, la llum nocturna, el no molestis i el mantenir despert.

Els indicadors inactius s'amaguen. Passa el cursor per sobre de qualsevol punt de la barra i apareixen atenuats, de manera que pots fer clic en un per activar-lo sense saber-ne la tecla d'accés ràpid. Fer clic en un d'actiu el torna a desactivar. Si prefereixes veure'ls tots sempre, posa `alwaysShow` a `true` a l'entrada `omarchy.indicators` de `~/.config/omarchy/shell.json`: consulta [la barra superior](05-the-top-bar.md) per saber com es configuren els ginys de la barra.

### Llum nocturna

La llum nocturna escalfa la pantalla a 4000K, i tornar-la a commutar la retorna a 6500K. Activa-la des del menú de commutadors (`Super + Ctrl + O`) o amb `omarchy toggle nightlight`. L'acciona hyprsunset, que el commutador inicia per tu si encara no està en execució.

Per defecte, hyprsunset no fa absolutament res a la pantalla. `~/.config/hypr/hyprsunset.conf` inclou un perfil d'identitat precisament perquè la pantalla es quedi intacta fins que demanes calidesa. Si prefereixes que canviï segons l'hora, substitueix-ho per un perfil horari:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Després inicia hyprsunset en iniciar la sessió afegint `o.launch_on_start("hyprsunset")` a `~/.config/hypr/autostart.lua`. La parella 4000K/6500K que fa servir el commutador és fixa, de manera que el fitxer de configuració és on has d'anar si vols una temperatura diferent.

### No molestis

`Super + Ctrl + Alt + ,` silencia les notificacions. Mentre està activat no apareix cap notificació emergent, i l'indicador de la campana ratllada es queda a la barra per recordar-te per què l'escriptori s'ha quedat en silenci.

Però no es perd res. Les notificacions silenciades es retenen: torna a posar les últimes a la pantalla amb `Super + Shift + Alt + ,`. Consulta [avisos](10-notices.md) per a la resta.

Dos tipus de missatge encara passen: les notificacions emergents de confirmació del mateix Omarchy per alguna cosa que acabes de fer ("Tema canviat", "Captura de pantalla desada") i les alertes crítiques enviades des de la línia d'ordres. Les aplicacions de xat que ho marquen tot com a crític per posar-se davant teu per la força no compten.

### Inactivitat

L'intèrpret d'Omarchy és el propietari del comportament d'inactivitat, i els temps són un bloc `idle` de nivell superior a `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Tots dos nombres són segons comptats des del moment en què has entrat en inactivitat, no l'un des de l'altre. Així, amb els valors predeterminats, l'estalvi de pantalla apareix al cap de dos minuts i mig i la pantalla de bloqueig se'n fa càrrec als cinc minuts, tant si l'estalvi de pantalla s'ha executat com si no. Desa el fitxer i l'intèrpret recollirà els nous temps de seguida.

Si tanques l'estalvi de pantalla abans del termini de bloqueig, això compta com a activitat i el bloqueig pendent es cancel·la. No et quedes bloquejat per fer una ullada a la màquina.

Per deixar de bloquejar per inactivitat del tot, `Super + Ctrl + I` — o `omarchy toggle idle` — activa el mantenir despert, i l'indicador de la tassa de cafè apareix a la barra. Aquest és el que has de tocar abans d'una presentació llarga o d'una compilació que vols vigilar. Torna'l a tocar per tornar a la normalitat. `omarchy toggle idle status` imprimeix l'estat actual com a JSON si el necessites des d'un script.

Això va del bloqueig i l'estalvi de pantalla, no de l'energia. La suspensió i la hibernació tenen la seva pròpia configuració a [repòs del sistema](36-system-sleep.md).

### L'estalvi de pantalla

L'estalvi de pantalla d'Omarchy és art ASCII que passa per efectes de text aleatoris, una instància per monitor. Qualsevol tecla o moviment del ratolí en surt.

El pots iniciar a demanda des de _Sistema > Estalvi de pantalla_ (`Super + Esc`), que el força a aparèixer encara que hagis desactivat l'estalvi de pantalla per inactivitat. Per defecte no hi ha cap tecla d'accés ràpid vinculada.

`omarchy toggle screensaver` és el que desactiva el d'inactivitat, si prefereixes anar directament de treballar a bloquejat. Necessita un terminal que sàpiga configurar — Alacritty, Foot, Ghostty o Kitty — i t'ho dirà si el teu terminal predeterminat és una altra cosa.

El logotip que dibuixa el pots canviar tu, a _Aparença > Imatge de marca > Estalvi de pantalla_. Puja un png o svg i Omarchy el converteix a ASCII. Consulta [imatge de marca](41-branding.md).

### La pantalla de bloqueig

`Super + Ctrl + L` bloqueja la màquina. Això executa la pantalla de bloqueig de l'intèrpret d'Omarchy, apaga la pantalla, restableix la disposició del teclat a la primera perquè no escriguis la contrasenya en l'alfabet equivocat i, si el tens en execució, bloqueja 1Password en sortir.

La pantalla de bloqueig accepta una contrasenya, i també acceptarà una empremta digital un cop n'hagis configurat una. Això, i les altres maneres d'autenticar-se, es tracten a [autenticació de maquinari](37-hardware-authentication.md).
