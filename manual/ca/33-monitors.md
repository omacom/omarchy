# Monitors

Omarchy assumeix per defecte que fas servir una pantalla de classe retina amb capacitat 2x. Això és el que necessites per obtenir aquelles fonts de programació boniques i nítides. És allò per a què estan optimitzades gairebé totes les pantalles d'alta resolució dels portàtils premium nous. És el que voldries fer servir en una pantalla de 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) o de 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Però si no fas servir una pantalla amb un PPI de 218 o superior, voldràs canviar la configuració del monitor. Per exemple, si tens una 4K de 27" o 32", pots fer servir l'escalat fraccionari obrint `~/.config/hypr/monitors.lua` (mitjançant _Configuració > Monitors_ al menú d'Omarchy) i canviant a la recomanació per a aquesta combinació:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Si fas servir una pantalla de 1080p o 1440p, probablement voldràs fer servir simplement l'escalat 1x, així que pots fer servir:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Els canvis a `GDK_SCALE` s'apliquen a les aplicacions iniciades després del canvi (i GTK només accepta nombres enters, així que mantén-lo en l'enter més proper a l'escala del teu monitor). Així que assegura't de tancar les finestres que tinguis sobredimensionades després del canvi (o tanca totes les finestres amb `Ctrl + Alt + Del`!).

També pots recórrer ràpidament les principals proporcions d'escalat del monitor (1x, 1.25x, 1.6x, 2x, 3x, 4x) fent servir `Super + /` per pujar i `Super + Alt + /` per baixar. Si tens la configuració per defecte, aquests canvis també es mantindran després de reiniciar.

### Fer el text més gran o més petit

L'escalat del monitor canvia la mida de tot. Si tot el que vols és un _text_ més gran o més petit, hi ha un sol control per a això:

```
omarchy display text size 14
```

Això accepta una mida en píxels entre 9 i 20, i mou la shell d'Omarchy, les aplicacions GTK i el teu terminal alhora, de manera que tot l'escriptori es manté en proporció. Executa-ho sense cap argument per veure on ets, i `omarchy display text size reset` per tornar al valor per defecte. Foot és l'únic que es queda enrere: no té cap manera de recarregar la seva configuració, així que els terminals en execució mantenen la mida antiga fins que n'obris un de nou.

### Ampliar i duplicar les pantalles del portàtil

Quan connectes una pantalla externa al teu portàtil, la pantalla s'amplia automàticament. Però pots canviar-ho a duplicació fent servir _Activador > Maquinari_ al menú d'Omarchy o `Super + Ctrl + Alt + Delete`. Això és especialment útil si aquesta pantalla externa és un projector, i vols mostrar alguna cosa mentre treballes.

Quan estàs ampliant, tancar la tapa del portàtil apagarà automàticament la pantalla interna. Obrir la tapa la tornarà a engegar. També pots controlar-ho manualment fent servir _Activador > Maquinari_ al menú d'Omarchy o `Super + Ctrl + Delete`.

### Organitzar diverses pantalles

Hyprland funciona molt bé amb diverses pantalles. Llegeix més sobre com disposar-les a [la documentació de monitors de Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). A Omarchy, aquestes van a `~/.config/hypr/monitors.lua` com a entrades `hl.monitor` — el fitxer inclou exemples comentats per fixar un monitor concret a una resolució, posició i rotació.

Cada monitor té els seus propis espais de treball de l'1 al 10, així que `Super + 1` sempre significa el primer espai de treball del monitor on ets. Entre bastidors, Hyprland encara numera els espais de treball entre tots els monitors: la pantalla del teu portàtil (o el primer monitor) rep l'1–10, el monitor següent l'11–20, i així successivament, i cada monitor conserva el seu bloc cada vegada que el connectes. Fes servir aquests nombres si escrius [regles d'espais de treball](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) o regles de finestres per a un monitor concret, de manera que l'espai de treball 12 és el segon espai de treball del teu segon monitor. `~/.local/state/omarchy/monitor-workspaces` enumera quin bloc té cada monitor.

Les tecles de fletxa funcionen entre monitors que comparteixen una vora en la teva disposició. Les pantalles que només es toquen en una cantonada, o que tenen un espai entre elles, no són veïnes, així que fes servir `Ctrl + Alt + Tab` per moure't entre elles.

| Tecla d'accés ràpid | Entre monitors |
| --- | --- |
| `Super + Arrow` | Mou el focus al monitor d'aquell costat un cop ja no queda cap finestra en aquella direcció |
| `Super + Shift + Arrow` | Intercanvia amb una finestra del monitor d'aquell costat |
| `Super + Alt + Arrow` | Mou la finestra a un grup del monitor d'aquell costat |
| `Super + Shift + Ctrl + Arrow` | Mou la finestra al monitor d'aquell costat, a l'espai de treball que està mostrant |
| `Super + Shift + Alt + Arrow` | Mou l'espai de treball al monitor d'aquell costat, conservant el seu nombre si és lliure |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Mou el focus al monitor següent o anterior, sigui quina sigui la disposició |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Es queden al monitor on ets |

També pots fer una ullada a [Hyprmon](https://github.com/erans/hyprmon/), si vols una TUI que t'ajudi amb la posició de diverses pantalles.

### Controlar la brillantor

La brillantor del monitor es controla amb les tecles de funció dedicades per pujar/baixar la brillantor. Si mantens premuda shift mentre prems aquestes tecles, aniràs a la brillantor màxima o mínima. Les tecles controlen la pantalla on tens el focus, així que els monitors externs que parlen DDC/CI s'ajusten de la mateixa manera que la pantalla del portàtil.

### Pantalles d'Apple

Si fas servir una pantalla d'Apple, les tecles normals de brillantor del teclat també funcionaran automàticament, si tens el focus a la pantalla d'Apple. Això es fa mitjançant l'ordre `asdcontrol`.

Tingues en compte que si fas servir una pantalla Apple 6K XDR, potser veuràs una pantalla fantasma a la llista de `hyprctl monitors`. Pots desactivar-ho amb alguna cosa com `hl.monitor({ output = "DP-2", disabled = true })` mitjançant _Configuració > Monitors_.

En màquines Intel, hauries de connectar-te a les pantalles d'Apple fent servir un cable Thunderbolt normal. En altres màquines sense Thunderbolt, normalment hauràs de fer servir un [cable DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) per fer-ho funcionar.
