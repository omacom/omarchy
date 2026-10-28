# Monitorji

Omarchy privzema, da privzeto uporabljaš zaslon razreda retina, ki zmore 2x. To potrebuješ za tiste lepe, ostre programerske pisave. Za to so optimizirani skoraj vsi novi vrhunski prenosniki z zasloni visoke ločljivosti. To želiš uporabljati na 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) ali 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Če pa ne uporabljaš zaslona s PPI 218 ali več, boš hotel spremeniti nastavitve monitorja. Če imaš na primer 27" ali 32" 4K, lahko uporabiš delno skaliranje tako, da odpreš `~/.config/hypr/monitors.lua` (prek _Setup > Monitors_ v meniju Omarchy) in preklopiš na priporočilo za to kombinacijo:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Če uporabljaš zaslon 1080p ali 1440p, boš verjetno hotel samo skaliranje 1x, zato lahko uporabiš:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Spremembe `GDK_SCALE` veljajo za aplikacije, zagnane po spremembi (GTK pa upošteva samo cela števila, zato ga obdrži pri celem številu, najbližjem skaliranju tvojega monitorja). Zato obvezno zapri okna, ki so po spremembi prevelika (ali zapri vsa okna s `Ctrl + Alt + Del`!).

Hitro lahko tudi preklapljaš med glavnimi razmerji skaliranja monitorja (1x, 1.25x, 1.6x, 2x, 3x, 4x) z `Super + /` za višje in `Super + Alt + /` za nižje ali izbereš enega na plošči monitorja v zgornji vrstici. Ta spremenijo samo monitor, na katerega si osredotočen, zato imata zaslon prenosnika in zunanji zaslon lahko vsak svoje skaliranje. Izbira se shrani v `~/.config/hypr/monitors.lua` kot pravilo `hl.monitor` za ta monitor, zato se ohrani po ponovnem zagonu in ima prednost pred `omarchy_monitor_scale`, ki ostane skaliranje za vsak monitor brez lastnega pravila.

### Povečevanje ali pomanjševanje besedila

Skaliranje monitorja spremeni velikost vsega. Če hočeš večje ali manjše samo _besedilo_, je za to en sam gumb:

```
omarchy display text size 14
```

Ta sprejme velikost v pikslih med 9 in 20 ter skupaj premakne lupino Omarchy, aplikacije GTK in tvoj terminal, zato celotno namizje ostane v sorazmerju. Zaženi ga brez argumenta, da vidiš, kje si, in `omarchy display text size reset`, da se vrneš na privzeto. Foot je edini zaostajalec: nima načina, da bi znova naložil svojo konfiguracijo, zato zagnani terminali obdržijo staro velikost, dokler ne odpreš novega.

### Razširjanje in zrcaljenje zaslonov prenosnika

Ko na prenosnik priključiš zunanji zaslon, se zaslon samodejno razširi. Namesto tega pa lahko to spremeniš v zrcaljenje prek _Trigger > Hardware_ v meniju Omarchy ali s `Super + Ctrl + Alt + Delete`. To je še posebej koristno, če je ta zunanji zaslon projektor in želiš med delom nekaj prikazati.

Ko razširjaš, zaprtje pokrova prenosnika samodejno izklopi notranji zaslon. Odprtje pokrova ga znova vklopi. To lahko nadzoruješ tudi ročno prek _Trigger > Hardware_ v meniju Omarchy ali s `Super + Ctrl + Delete`.

### Razporejanje več zaslonov

Hyprland odlično deluje z več zasloni. Več o tem, kako jih razporediti, preberi v [dokumentaciji o monitorjih Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). V Omarchyju gredo ti v `~/.config/hypr/monitors.lua` kot vnosi `hl.monitor` — datoteka vsebuje zakomentirane primere za pripenjanje določenega monitorja na ločljivost, položaj in vrtenje.

Vsak monitor ima svojih delovnih prostorov od 1 do 10, zato `Super + 1` vedno pomeni prvi delovni prostor monitorja, na katerem si. V ozadju Hyprland še vedno številči delovne prostore čez vse monitorje: zaslon tvojega prenosnika (ali prvi monitor) dobi 1–10, naslednji monitor 11–20 in tako naprej, vsak monitor pa obdrži svoj blok vsakič, ko ga priključiš. Te številke uporabi, če pišeš [pravila za delovne prostore](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) ali pravila za okna za določen monitor, tako da je delovni prostor 12 drugi delovni prostor tvojega drugega monitorja. `~/.local/state/omarchy/monitor-workspaces` navaja, kateri blok ima vsak monitor.

Smerne tipke delujejo čez monitorje, ki si v tvoji postavitvi delijo rob. Zasloni, ki se dotikajo samo v kotu ali imajo med sabo vrzel, niso sosedje, zato za premik med njimi uporabi `Ctrl + Alt + Tab`.

| Bližnjica | Čez monitorje |
| --- | --- |
| `Super + Arrow` | Premakne fokus na monitor na tisti strani, ko v tisti smeri ni več nobenega okna |
| `Super + Shift + Arrow` | Zamenja z oknom na monitorju na tisti strani |
| `Super + Alt + Arrow` | Premakne okno v skupino na monitorju na tisti strani |
| `Super + Shift + Ctrl + Arrow` | Premakne okno na monitor na tisti strani, na delovni prostor, ki ga ta prikazuje |
| `Super + Shift + Alt + Arrow` | Premakne delovni prostor na monitor na tisti strani in obdrži njegovo številko, če je prosta |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Premakne fokus na naslednji ali prejšnji monitor, ne glede na postavitev |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Ostanejo na monitorju, na katerem si |

Ogledaš si lahko tudi [Hyprmon](https://github.com/erans/hyprmon/), če želiš TUI, ki ti pomaga pri postavljanju več zaslonov.

### Nadzor svetlosti

Svetlost monitorja nadzoruješ z namenskima funkcijskima tipkama za povečanje/zmanjšanje svetlosti. Če med pritiskom nanju držiš shift, boš šel na največjo ali najmanjšo svetlost. Tipke nadzorujejo zaslon, na katerega si osredotočen, zato se zunanji monitorji, ki govorijo DDC/CI, prilagodijo na enak način kot zaslon prenosnika.

### Zasloni Apple

Če uporabljaš zaslon Apple, bodo običajne tipke za svetlost na tipkovnici samodejno delovale tudi, če si osredotočen na zaslon Apple. To se naredi prek ukaza `asdcontrol`.

Upoštevaj, da boš pri uporabi zaslona Apple 6K XDR morda videl fantomski zaslon na svojem seznamu `hyprctl monitors`. To lahko izklopiš z nečim, kot je `hl.monitor({ output = "DP-2", disabled = true })` prek _Setup > Monitors_.

Na računalnikih Intel moraš zaslone Apple priključiti z običajnim kablom Thunderbolt. Na drugih računalnikih brez Thunderbolta boš običajno moral uporabiti [kabel DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N), da bo delovalo.
