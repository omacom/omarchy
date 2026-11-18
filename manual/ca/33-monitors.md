# Monitors

Omarchy assumeix per defecte que fas servir una pantalla de classe retina amb capacitat 2x. Això és el que necessites per aconseguir aquelles fonts de programació boniques i nítides. És per a això que estan optimitzats gairebé tots els portàtils premium nous amb pantalles d'alta resolució. És el que voldries fer servir en un [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) de 27" 5K o un [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) de 32" 6K.

Però si no fas servir una pantalla amb un PPI de 218 o superior, voldràs canviar la configuració del monitor. Per exemple, si tens un 4K de 27" o 32", pots triar-ne una escala fraccionària des del panell del monitor a la barra superior, o establir el valor per defecte per a cada monitor obrint `~/.config/hypr/monitors.lua` i canviant a la recomanació per a aquesta combinació:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Si fas servir una pantalla de 1080p o 1440p, probablement voldràs fer servir simplement l'escala 1x, i el mateix per a les aplicacions GTK i X11, així que pots fer servir:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Els canvis a `GDK_SCALE` s'apliquen a les aplicacions iniciades després del canvi (i GTK només accepta nombres enters, així que mantín-lo en l'enter més proper a l'escala del teu monitor). Així que assegura't de tancar les finestres sobredimensionades que tinguis després del canvi (o tanca totes les finestres amb `Ctrl + Alt + Del`!).

També pots recórrer ràpidament les principals proporcions d'escala del monitor (1x, 1.25x, 1.6x, 2x, 3x, 4x) fent servir `Super + /` per pujar i `Super + Alt + /` per baixar, o triar-ne una des del panell del monitor a la barra superior. Aquestes només canvien el monitor en el qual estàs centrat, de manera que la pantalla d'un portàtil i una pantalla externa poden tenir cadascuna la seva pròpia escala. El panell també estableix la resolució, la freqüència d'actualització i la rotació de cada monitor. Les teves eleccions es desen per a aquell monitor físic a `~/.local/state/omarchy/monitors/settings`, de manera que persisteixen després de reiniciar i segueixen el monitor a qualsevol port o base on el connectis després. Tenen precedència sobre qualsevol regla per al mateix monitor a `~/.config/hypr/monitors.lua`, que Omarchy mai no edita. Si prefereixes configurar els teus monitors completament en aquell fitxer, afegeix-hi `omarchy_monitor_panel_settings = false`, i els canvis del panell només duraran fins que Hyprland es recarregui. Com que `GDK_SCALE` és un únic valor per a totes les pantalles, una escala triada l'estableix a partir del monitor amb l'escala més baixa, de manera que les aplicacions X11 surten una mica petites a la pantalla més densa en lloc de sobredimensionades a l'altra.

### Fer el text més gran o més petit

L'escala del monitor canvia la mida de tot. Si tot el que vols és un _text_ més gran o més petit, hi ha un únic control per a això:

```
omarchy display text size 14
```

Això accepta una mida en píxels entre 9 i 20, i mou la shell d'Omarchy, les aplicacions GTK i el teu terminal conjuntament, de manera que tot l'escriptori es manté en proporció. Executa-ho sense cap argument per veure on ets, i `omarchy display text size reset` per tornar al valor per defecte. Foot és l'únic que queda enrere: no té cap manera de recarregar la seva configuració, així que els terminals en execució mantenen la seva mida antiga fins que n'obres un de nou.

### Ampliar i duplicar pantalles de portàtil

Quan connectes una pantalla externa al teu portàtil, la pantalla s'amplia automàticament. Però pots canviar-ho a duplicació fent servir _Trigger > Hardware_ al menú d'Omarchy o `Super + Ctrl + Alt + Delete`. Això és especialment útil si aquella pantalla externa és un projector, i vols mostrar alguna cosa mentre treballes.

Quan estàs ampliant, tancar la tapa del portàtil apagarà automàticament la pantalla interna. Obrir la tapa la tornarà a engegar. També pots controlar això manualment fent servir _Trigger > Hardware_ al menú d'Omarchy o `Super + Ctrl + Delete`.

### Organitzar diverses pantalles

Hyprland funciona molt bé amb diverses pantalles. El panell del monitor a la barra superior les dibuixa on estan situades: arrossega'n una contra el costat d'una altra per moure-la allà, i la disposició es desa amb la resta de configuracions de cada monitor. Per a qualsevol cosa que el panell no cobreixi, llegeix més sobre com disposar-les a [la documentació de monitors de Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). A Omarchy, aquestes van a `~/.config/hypr/monitors.lua` com a entrades `hl.monitor` — el fitxer inclou exemples comentats per mantenir un monitor apagat, modes que el panell no ofereix, color de 10 bits i freqüència d'actualització variable.

Cada monitor té els seus propis espais de treball de l'1 al 10, de manera que `Super + 1` sempre significa el primer espai de treball del monitor en el qual et trobes. Entre bastidors, Hyprland continua numerant els espais de treball entre tots els monitors: la pantalla del teu portàtil (o el primer monitor) rep l'1–10, el monitor següent l'11–20, i així successivament, i cada monitor manté el seu bloc cada vegada que el connectes. Fes servir aquests números si escrius [regles d'espais de treball](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) o regles de finestra per a un monitor específic, de manera que l'espai de treball 12 és el segon espai de treball del teu segon monitor. `~/.local/state/omarchy/monitors/workspaces` enumera quin bloc té cada monitor.

Les tecles de fletxa funcionen entre monitors que comparteixen una vora en la teva disposició. Les pantalles que només es toquen en una cantonada, o que tenen un buit entre elles, no són veïnes, així que fes servir `Ctrl + Alt + Tab` per anar d'una a l'altra.

| Tecla ràpida | Entre monitors |
| --- | --- |
| `Super + Arrow` | Mou el focus al monitor d'aquell costat un cop ja no queda cap finestra en aquella direcció |
| `Super + Shift + Arrow` | Intercanvia amb una finestra del monitor d'aquell costat |
| `Super + Alt + Arrow` | Mou la finestra a un grup del monitor d'aquell costat |
| `Super + Shift + Ctrl + Arrow` | Mou la finestra al monitor d'aquell costat, a l'espai de treball que està mostrant |
| `Super + Shift + Alt + Arrow` | Mou l'espai de treball al monitor d'aquell costat, mantenint el seu número si està lliure |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Mou el focus al monitor següent o anterior, sigui quina sigui la disposició |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Es queden al monitor en el qual et trobes |

També pots fer una ullada a [Hyprmon](https://github.com/erans/hyprmon/), si vols un TUI que t'ajudi amb la posició de diverses pantalles.

### Controlar la brillantor

La brillantor del monitor es controla amb les tecles de funció dedicades per pujar/baixar la brillantor. Si mantens premut Shift mentre prems aquestes tecles, aniràs a la brillantor màxima o mínima. Les tecles controlen la pantalla en la qual estàs centrat, de manera que els monitors externs que parlen DDC/CI s'ajusten de la mateixa manera que la pantalla del portàtil.

### Pantalles d'Apple

Si fas servir una pantalla d'Apple, les tecles de brillantor normals del teclat també funcionaran automàticament, si estàs centrat en la pantalla d'Apple. Això es fa mitjançant l'ordre `asdcontrol`.

Tingues en compte que si fas servir una pantalla Apple 6K XDR, és possible que vegis una pantalla fantasma al teu llistat de `hyprctl monitors`. Pots desactivar això amb alguna cosa com `hl.monitor({ output = "DP-2", disabled = true })` a `~/.config/hypr/monitors.lua`.

En màquines Intel, hauries de connectar-te a les pantalles d'Apple fent servir un cable Thunderbolt normal. En altres màquines sense Thunderbolt, normalment hauràs de fer servir un [DP + USB-A -> USB-C cable](https://www.amazon.com/dp/B0BNX7MS6N) per fer que funcioni.
