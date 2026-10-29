# Monitorji

Omarchy privzeto predpostavlja, da uporabljaš zaslon razreda retina, ki podpira skaliranje 2x. To potrebuješ, če želiš tiste lepe, ostre programerske pisave. Za to so optimizirani skoraj vsi novi vrhunski prenosniki z zasloni visoke ločljivosti. To bi želel uporabljati na 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) ali 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Toda če ne uporabljaš zaslona s PPI 218 ali več, boš želel spremeniti nastavitve monitorja. Če imaš na primer 27" ali 32" 4K, lahko uporabiš delno skaliranje tako, da odpreš `~/.config/hypr/monitors.lua` (prek _Nastavitve > Monitorji_ v meniju Omarchy) in preklopiš na priporočilo za to kombinacijo:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Če uporabljaš zaslon 1080p ali 1440p, boš verjetno želel uporabiti skaliranje 1x, zato lahko uporabiš:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Spremembe `GDK_SCALE` veljajo za aplikacije, zagnane po spremembi (GTK pa upošteva samo cela števila, zato naj ostane pri celem številu, najbližjem skaliranju tvojega monitorja). Zato obvezno zapri okna, ki so po spremembi prevelika (ali zapri vsa okna s `Ctrl + Alt + Del`!).

Med glavnimi razmerji skaliranja monitorja (1x, 1.25x, 1.6x, 2x, 3x, 4x) lahko hitro prehajaš tudi z `Super + /` za višje in `Super + Alt + /` za nižje, ali pa eno izbereš na plošči monitorja v zgornji vrstici. Te spremembe vplivajo samo na monitor, na katerega si osredotočen, zato imata lahko zaslon prenosnika in zunanji zaslon vsak svoje skaliranje. Izbira se shrani v `~/.config/hypr/monitors.lua` kot pravilo `hl.monitor` za ta monitor, zato ostane tudi po ponovnem zagonu in ima prednost pred `omarchy_monitor_scale`, ki ostane skaliranje za vsak monitor brez lastnega pravila. Ker je `GDK_SCALE` ena vrednost za vse zaslone, ga te spremembe nastavijo glede na monitor z najnižjim skaliranjem, zato aplikacije X11 na gostejšem zaslonu izpadejo nekoliko majhne, namesto da bi bile na drugem prevelike.

### Povečevanje ali pomanjševanje besedila

Skaliranje monitorja spremeni velikost vsega. Če želiš večje ali manjše samo _besedilo_, je za to ena sama nastavitev:

```
omarchy display text size 14
```

Ta sprejme velikost v slikovnih pikah med 9 in 20 ter skupaj premakne lupino Omarchy, aplikacije GTK in tvoj terminal, tako da celotno namizje ostane v sorazmerju. Zaženi jo brez argumenta, da vidiš, na čem si, z `omarchy display text size reset` pa se vrneš na privzeto vrednost. Foot je edini zaostajalec: svoje konfiguracije ne more znova naložiti, zato terminali, ki že tečejo, obdržijo staro velikost, dokler ne odpreš novega.

### Razširitev in zrcaljenje zaslonov prenosnika

Ko na prenosnik priključiš zunanji zaslon, se prikaz samodejno razširi. To pa lahko spremeniš v zrcaljenje prek _Sprožilec > Strojna oprema_ v meniju Omarchy ali s `Super + Ctrl + Alt + Delete`. To je še posebej priročno, če je ta zunanji zaslon projektor in želiš med delom nekaj pokazati.

Ko uporabljaš razširitev, se ob zaprtju pokrova prenosnika notranji zaslon samodejno izklopi. Ob odprtju pokrova se znova vklopi. To lahko nadziraš tudi ročno prek _Sprožilec > Strojna oprema_ v meniju Omarchy ali s `Super + Ctrl + Delete`.

### Razporeditev več zaslonov

Hyprland odlično deluje z več zasloni. Več o tem, kako jih razporediti, preberi v [dokumentaciji Hyprland o monitorjih](https://wiki.hypr.land/Configuring/Basics/Monitors/). V Omarchyju gredo te nastavitve v `~/.config/hypr/monitors.lua` kot vnosi `hl.monitor` — datoteka vsebuje zakomentirane primere za pripenjanje določenega monitorja na ločljivost, položaj in zasuk.

Vsak monitor ima svojih delovnih prostorov od 1 do 10, zato `Super + 1` vedno pomeni prvi delovni prostor monitorja, na katerem si. V ozadju Hyprland delovne prostore vseeno številči čez vse monitorje: zaslon tvojega prenosnika (ali prvi monitor) dobi 1–10, naslednji monitor 11–20 in tako naprej, vsak monitor pa obdrži svoj blok ob vsakem priklopu. Ta števila uporabi, če pišeš [pravila za delovne prostore](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) ali pravila za okna za določen monitor, tako da je delovni prostor 12 drugi delovni prostor tvojega drugega monitorja. `~/.local/state/omarchy/monitor-workspaces` navaja, kateri blok ima vsak monitor.

Smerne tipke delujejo čez monitorje, ki si v tvoji postavitvi delijo rob. Zasloni, ki se dotikajo samo v kotu ali imajo med seboj vrzel, niso sosedje, zato za premik med njimi uporabi `Ctrl + Alt + Tab`.

| Bližnjica | Čez monitorje |
| --- | --- |
| `Super + Arrow` | Premakne fokus na monitor na tisti strani, ko v tisti smeri ni več nobenega okna |
| `Super + Shift + Arrow` | Zamenja z oknom na monitorju na tisti strani |
| `Super + Alt + Arrow` | Premakne okno v skupino na monitorju na tisti strani |
| `Super + Shift + Ctrl + Arrow` | Premakne okno na monitor na tisti strani, na delovni prostor, ki ga ta prikazuje |
| `Super + Shift + Alt + Arrow` | Premakne delovni prostor na monitor na tisti strani in obdrži njegovo številko, če je prosta |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Premakne fokus na naslednji ali prejšnji monitor, ne glede na postavitev |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Ostanejo na monitorju, na katerem si |

Oglej si tudi [Hyprmon](https://github.com/erans/hyprmon/), če želiš TUI, ki ti pomaga pri postavljanju več zaslonov.

### Nadzor svetlosti

Svetlost monitorja nadziraš z namenskima funkcijskima tipkama za povečanje/zmanjšanje svetlosti. Če med pritiskanjem teh tipk držiš Shift, greš na največjo ali najmanjšo svetlost. Tipke nadzirajo zaslon, na katerega si osredotočen, zato se zunanji monitorji, ki govorijo DDC/CI, prilagajajo enako kot zaslon prenosnika.

### Zasloni Apple

Če uporabljaš zaslon Apple, bodo običajne tipke za svetlost na tipkovnici samodejno delovale tudi zanj, če si osredotočen na zaslon Apple. To poteka prek ukaza `asdcontrol`.

Upoštevaj, da boš pri uporabi zaslona Apple 6K XDR v izpisu `hyprctl monitors` morda videl fantomski zaslon. Izklopiš ga lahko z nečim podobnim kot `hl.monitor({ output = "DP-2", disabled = true })` prek _Nastavitve > Monitorji_.

Na napravah Intel se na zaslone Apple poveži z običajnim kablom Thunderbolt. Na drugih napravah brez Thunderbolta boš običajno moral uporabiti [kabel DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N), da bo delovalo.
