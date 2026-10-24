# Monitors

Omarchy assumeix per defecte que funciones amb una pantalla de classe retina capaç de 2x. Això és el que necessites per obtenir aquells tipus de lletra de programador bonics i nítids. És per al que estan optimitzats gairebé tots els portàtils premium nous amb pantalles d'alta resolució. És el que voldries fer servir en un [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) de 27" 5K o un [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) de 32" 6K.

Però si no funciones amb una pantalla amb un PPI de 218 o superior, voldràs canviar la configuració del monitor. Per exemple, si tens un 4K de 27" o 32", pots fer servir escala fraccionària obrint `~/.config/hypr/monitors.lua` (mitjançant _Configuració > Monitors_ al menú d'Omarchy) i canviant a la recomanació per a aquella combinació:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Si fas servir una pantalla de 1080p o 1440p, probablement voldràs simplement fer servir escala 1x, de manera que pots fer servir:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Els canvis a `GDK_SCALE` s'apliquen a les aplicacions iniciades després del canvi (i GTK només accepta nombres enters, de manera que mantén-lo a l'enter més proper de l'escala del teu monitor). Així que assegura't de tancar les finestres que tinguis sobredimensionades després del canvi (o tanca totes les finestres amb `Ctrl + Alt + Del`!).

També pots recórrer ràpidament les proporcions d'escala de monitor principals (1x, 1.25x, 1.6x, 2x, 3x, 4x) amb `Super + /` per pujar i `Super + Alt + /` per baixar. Si tens la configuració per defecte, aquests canvis també persistiran després de reiniciar.

### Fer el text més gran o més petit

L'escala del monitor canvia la mida de tot. Si tot el que vols és _text_ més gran o més petit, hi ha un sol comandament per a això:

```
omarchy display text size 14
```

Això pren una mida en píxels entre 9 i 20, i mou conjuntament l'intèrpret d'escriptori d'Omarchy, les aplicacions GTK i el teu terminal, de manera que tot l'escriptori es manté en proporció. Executa'l sense cap argument per veure on ets, i `omarchy display text size reset` per tornar al valor per defecte. Foot és l'únic endarrerit: no té cap manera de tornar a carregar la seva configuració, de manera que els terminals en funcionament conserven la mida antiga fins que n'obris un de nou.

### Estendre i duplicar pantalles de portàtil

Quan connectes una pantalla externa al portàtil, la pantalla s'estén automàticament. Però pots canviar-ho a duplicació en el seu lloc amb _Activa > Maquinari_ al menú d'Omarchy o `Super + Ctrl + Alt + Delete`. Això és especialment útil si aquella pantalla externa és un projector i vols mostrar alguna cosa mentre treballes.

Quan estàs estenent, tancar la tapa del portàtil apagarà automàticament la pantalla interna. Obrir la tapa la tornarà a engegar. També pots controlar-ho manualment amb _Activa > Maquinari_ al menú d'Omarchy o `Super + Ctrl + Delete`.

### Disposar diverses pantalles

Hyprland funciona de meravella amb diverses pantalles. Llegeix més coses sobre com disposar-les a [la documentació de monitors de Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). També pots [lligar espais de treball específics a monitors específics](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/). A Omarchy, aquestes regles van a `~/.config/hypr/monitors.lua` com a entrades `hl.monitor` — el fitxer ve amb exemples comentats per fixar un monitor específic a una resolució, una posició i una rotació.

També pots passar per [Hyprmon](https://github.com/erans/hyprmon/), si vols una TUI que t'ajudi amb el posicionament de diverses pantalles.

### Controlar la brillantor

La brillantor del monitor es controla amb les tecles de funció dedicades per pujar i baixar la brillantor. Si mantens premut majúscules mentre les prems, aniràs a la brillantor màxima o mínima. Les tecles controlen la pantalla en què estàs centrat, de manera que els monitors externs que parlen DDC/CI s'ajusten de la mateixa manera que la pantalla del portàtil.

### Pantalles d'Apple

Si fas servir una pantalla d'Apple, les tecles normals de brillantor del teclat també funcionaran automàticament, si estàs centrat en la pantalla d'Apple. Això es fa mitjançant l'ordre `asdcontrol`.

Tingues en compte que si fas servir una pantalla XDR de 6K d'Apple, potser veuràs una pantalla fantasma al llistat de `hyprctl monitors`. Pots apagar-ho amb alguna cosa com `hl.monitor({ output = "DP-2", disabled = true })` mitjançant _Configuració > Monitors_.

En màquines Intel, hauries de connectar-te a pantalles d'Apple fent servir un cable Thunderbolt normal. En altres màquines sense Thunderbolt, normalment hauràs de fer servir un [cable DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) perquè funcioni.
