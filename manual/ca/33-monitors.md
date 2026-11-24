# Monitors

Omarchy assumeix per defecte que utilitzes una pantalla de classe retina amb capacitat 2x. Això és el que necessites per obtenir aquelles fonts de programador agradables i nítides. És per a allò que gairebé tots els portàtils premium nous amb pantalles d'alta resolució estan optimitzats. És el que voldries utilitzar en un [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) de 27" 5K o un [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) de 32" 6K.

Però si no utilitzes una pantalla amb un PPI de 218 o superior, voldràs canviar la configuració del monitor. Per exemple, si tens un 4K de 27" o 32", pots triar una escala fraccionària per a ell des del panell del monitor a la barra superior, o establir el valor per defecte per a cada monitor obrint `~/.config/hypr/monitors.lua` i canviant a la recomanació per a aquesta combinació:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Si utilitzes una pantalla de 1080p o 1440p, probablement voldràs utilitzar simplement una escala 1x, i el mateix per a les aplicacions GTK i X11, així que pots utilitzar:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Els canvis a `GDK_SCALE` s'apliquen a les aplicacions iniciades després del canvi (i GTK només accepta números sencers, així que mantén-lo en l'enter més proper a l'escala del teu monitor). Així que assegura't de tancar les finestres que tens que estan sobredimensionades després del canvi (o tanca totes les finestres amb `Ctrl + Alt + Del`!).

També pots recórrer ràpidament les principals proporcions d'escala del monitor (1x, 1.25x, 1.6x, 2x, 3x, 4x) utilitzant `Super + /` per pujar i `Super + Alt + /` per baixar, o triar-ne una des del panell del monitor a la barra superior. Aquestes només canvien el monitor en què estàs centrat, així que una pantalla de portàtil i una pantalla externa poden tenir cadascuna la seva pròpia escala. El panell també estableix la resolució, la freqüència d'actualització i la rotació de cada monitor. Les teves eleccions es desen per a aquest monitor físic a `~/.local/state/omarchy/monitors/settings`, així que persisteixen després de reiniciar i segueixen el monitor a qualsevol port o base d'acoblament on el connectis després. Tenen precedència sobre qualsevol regla per al mateix monitor a `~/.config/hypr/monitors.lua`, que Omarchy mai no edita. Si prefereixes configurar els teus monitors completament en aquest fitxer, afegeix-hi `omarchy_monitor_panel_settings = false`, i els canvis del panell només duraran fins que Hyprland es recarregui. Com que `GDK_SCALE` és un sol valor per a totes les pantalles, una escala triada l'estableix a partir del monitor amb l'escala més baixa, així que les aplicacions X11 surten una mica petites a la pantalla més densa en lloc de sobredimensionades a l'altra.

### Fer el text més gran o més petit

L'escala del monitor canvia la mida de tot. Si tot el que vols és un _text_ més gran o més petit, hi ha un sol control per a això:

```
omarchy display text size 14
```

Això accepta una mida en píxels entre 9 i 20, i mou la shell d'Omarchy, les aplicacions GTK i el teu terminal junts, així que tot l'escriptori es manté en proporció. Executa'l sense cap argument per veure on ets, i `omarchy display text size reset` per tornar al valor per defecte. Foot és l'únic endarrerit: no té cap manera de recarregar la seva configuració, així que els terminals en execució mantenen la seva mida antiga fins que n'obris un de nou.

### Ampliar i duplicar les pantalles del portàtil

Quan connectes una pantalla externa al teu portàtil, la pantalla s'amplia automàticament. Però pots canviar-ho a duplicació en lloc d'això amb _Extend_ | _Mirror_ al panell del monitor a la barra superior, _Trigger > Hardware_ al menú d'Omarchy, o `Super + Ctrl + Alt + Delete`. Això és especialment útil si aquesta pantalla externa és un projector, i vols mostrar alguna cosa mentre treballes.

Quan estàs ampliant, tancar la tapa del portàtil apagarà automàticament la pantalla interna. Obrir la tapa la tornarà a engegar. També pots controlar això manualment utilitzant _Trigger > Hardware_ al menú d'Omarchy o `Super + Ctrl + Delete`.

### Organitzar múltiples pantalles

Hyprland funciona molt bé amb múltiples pantalles. El panell del monitor a la barra superior les dibuixa on estan situades: arrossega'n una contra el costat d'una altra per moure-la allà, i la disposició es desa amb la resta de configuracions de cada monitor. Per a qualsevol cosa que el panell no cobreixi, llegeix més sobre com disposar-les a [la documentació de monitors de Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). A Omarchy, aquestes van a `~/.config/hypr/monitors.lua` com a entrades `hl.monitor` — el fitxer inclou exemples comentats per mantenir un monitor apagat, modes que el panell no ofereix, color de 10 bits i freqüència d'actualització variable.

Cada monitor té els seus propis espais de treball de l'1 al 10, així que `Super + 1` sempre significa el primer espai de treball del monitor en què ets. Entre bastidors, Hyprland encara numera els espais de treball a través de tots els monitors: la pantalla del portàtil (o el primer monitor) obté l'1–10, el següent monitor l'11–20, i així successivament, i cada monitor manté el seu bloc cada vegada que el connectes. Utilitza aquests números si escrius [regles d'espais de treball](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) o regles de finestres per a un monitor específic, així que l'espai de treball 12 és el segon espai de treball del teu segon monitor. `~/.local/state/omarchy/monitors/workspaces` llista quin bloc té cada monitor.

Les tecles de fletxa funcionen a través de monitors que comparteixen una vora en la teva disposició. Les pantalles que només es toquen en una cantonada, o que tenen un buit entre elles, no són veïnes, així que utilitza `Ctrl + Alt + Tab` per anar entre elles.

| Drecera de teclat | Entre monitors |
| --- | --- |
| `Super + Arrow` | Mou el focus al monitor d'aquell costat un cop no queda cap finestra en aquella direcció |
| `Super + Shift + Arrow` | Intercanvia amb una finestra del monitor d'aquell costat |
| `Super + Alt + Arrow` | Mou la finestra a un grup del monitor d'aquell costat |
| `Super + Shift + Ctrl + Arrow` | Mou la finestra al monitor d'aquell costat, a l'espai de treball que està mostrant |
| `Super + Shift + Alt + Arrow` | Mou l'espai de treball al monitor d'aquell costat, mantenint el seu número si està lliure |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Mou el focus al monitor següent o anterior, sigui quina sigui la disposició |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Es queden al monitor en què ets |

També pots fer una ullada a [Hyprmon](https://github.com/erans/hyprmon/), si vols una TUI que t'ajudi amb el posicionament de múltiples pantalles.

### Controlar la brillantor

La brillantor del monitor es controla amb les tecles de funció dedicades per pujar i baixar la brillantor. Si mantens premuda shift mentre prems aquestes, aniràs a la brillantor màxima o mínima. Les tecles controlen la pantalla en què estàs centrat, així que els monitors externs que parlen DDC/CI s'ajusten de la mateixa manera que la pantalla del portàtil.

### Pantalles Apple

Si utilitzes una pantalla Apple, les tecles normals de brillantor del teclat també funcionaran automàticament, si estàs centrat en la pantalla Apple. Això es fa mitjançant l'ordre `asdcontrol`.

Tingues en compte que si utilitzes una pantalla Apple 6K XDR, pots veure una pantalla fantasma a la teva llista de `hyprctl monitors`. Pots desactivar això amb alguna cosa com `hl.monitor({ output = "DP-2", disabled = true })` a `~/.config/hypr/monitors.lua`.

En màquines Intel, hauries de connectar-te a les pantalles Apple utilitzant un cable Thunderbolt normal. En altres màquines sense Thunderbolt, normalment hauràs d'utilitzar un [cable DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) perquè funcioni.
