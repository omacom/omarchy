# Monitorji

Omarchy privzeto predvideva, da uporabljate zaslon razreda retina z zmogljivostjo 2x. To potrebujete za lepe, ostre programerske pisave. Za to so optimizirani skoraj vsi novi vrhunski prenosniki z zasloni visoke ločljivosti. To bi želeli uporabljati na 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) ali 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Če pa ne uporabljate zaslona s PPI 218 ali več, boste želeli spremeniti nastavitve monitorja. Če imate na primer 27" ali 32" 4K, lahko uporabite delno skaliranje tako, da odprete `~/.config/hypr/monitors.lua` (prek _Setup > Monitors_ v meniju Omarchy) in preklopite na priporočilo za to kombinacijo:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Če uporabljate zaslon 1080p ali 1440p, boste verjetno želeli uporabiti kar skaliranje 1x, torej lahko uporabite:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Spremembe `GDK_SCALE` veljajo za aplikacije, zagnane po spremembi (GTK pa upošteva le cela števila, zato naj ostane pri najbližjem celem številu vašega skaliranja monitorja). Zato obvezno zaprite okna, ki so po spremembi prevelika (ali zaprite vsa okna s `Ctrl + Alt + Del`!).

Skozi glavna razmerja skaliranja monitorja (1x, 1.25x, 1.6x, 2x, 3x, 4x) lahko hitro prehajate tudi z uporabo `Super + /` za višje in `Super + Alt + /` za nižje. Če imate privzeto konfiguracijo, se te spremembe ohranijo tudi po ponovnem zagonu.

### Povečanje ali pomanjšanje besedila

Skaliranje monitorja spremeni velikost vsega. Če želite le večje ali manjše _besedilo_, je za to en sam gumb:

```
omarchy display text size 14
```

Ta sprejme velikost v pikslih med 9 in 20 ter skupaj premakne lupino Omarchy, aplikacije GTK in vaš terminal, tako da celotno namizje ostane v sorazmerju. Zaženite ga brez argumenta, da vidite, pri čem ste, in `omarchy display text size reset`, da se vrnete na privzeto vrednost. Foot je edini zaostajalec: nima načina za ponovno nalaganje svoje konfiguracije, zato zagnani terminali ohranijo staro velikost, dokler ne odprete novega.

### Razširjanje in zrcaljenje zaslonov prenosnika

Ko na prenosnik priključite zunanji zaslon, se zaslon samodejno razširi. To pa lahko namesto tega spremenite v zrcaljenje z uporabo _Trigger > Hardware_ v meniju Omarchy ali `Super + Ctrl + Alt + Delete`. To je še posebej koristno, če je ta zunanji zaslon projektor in želite nekaj pokazati, medtem ko delate.

Ko razširjate, zapiranje pokrova prenosnika samodejno izklopi notranji zaslon. Odpiranje pokrova ga znova vklopi. To lahko nadzirate tudi ročno z uporabo _Trigger > Hardware_ v meniju Omarchy ali `Super + Ctrl + Delete`.

### Urejanje več zaslonov

Hyprland odlično deluje z več zasloni. Več o tem, kako jih razporediti, preberite v [dokumentaciji Hyprland o monitorjih](https://wiki.hypr.land/Configuring/Basics/Monitors/). V Omarchyju gredo te v `~/.config/hypr/monitors.lua` kot vnosi `hl.monitor` — datoteka je dobavljena s komentiranimi primeri za pripenjanje določenega monitorja na ločljivost, položaj in vrtenje.

Vsak monitor ima svojih delovnih prostorov od 1 do 10, zato `Super + 1` vedno pomeni prvi delovni prostor monitorja, na katerem ste. V ozadju Hyprland še vedno številči delovne prostore čez vse monitorje: zaslon vašega prenosnika (ali prvi monitor) dobi 1–10, naslednji monitor 11–20 in tako naprej, vsak monitor pa obdrži svoj blok vsakič, ko ga priključite. Te številke uporabite, če pišete [pravila delovnih prostorov](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) ali pravila oken za določen monitor, tako da je delovni prostor 12 drugi delovni prostor vašega drugega monitorja. `~/.local/state/omarchy/monitor-workspaces` navaja, kateri blok ima vsak monitor.

Smerne tipke delujejo čez monitorje, ki si v vaši postavitvi delijo rob. Zasloni, ki se dotikajo le v kotu ali imajo med seboj vrzel, niso sosedje, zato za premik med njimi uporabite `Ctrl + Alt + Tab`.

| Bližnjica | Med monitorji |
| --- | --- |
| `Super + Arrow` | Premakne fokus na monitor na tisti strani, ko v tisti smeri ni več nobenega okna |
| `Super + Shift + Arrow` | Zamenja z oknom na monitorju na tisti strani |
| `Super + Alt + Arrow` | Premakne okno v skupino na monitorju na tisti strani |
| `Super + Shift + Ctrl + Arrow` | Premakne okno na monitor na tisti strani, na delovni prostor, ki ga ta prikazuje |
| `Super + Shift + Alt + Arrow` | Premakne delovni prostor na monitor na tisti strani in ohrani njegovo številko, če je prosta |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Premakne fokus na naslednji ali prejšnji monitor, ne glede na postavitev |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Ostanejo na monitorju, na katerem ste |

Ogledate si lahko tudi [Hyprmon](https://github.com/erans/hyprmon/), če želite TUI, ki vam pomaga pri postavljanju več zaslonov.

### Nadzor svetlosti

Svetlost monitorja nadzirate z namenskima funkcijskima tipkama za povečanje/zmanjšanje svetlosti. Če med pritiskanjem teh tipk držite Shift, boste šli na največjo ali najmanjšo svetlost. Tipke nadzirajo zaslon, na katerem ste osredotočeni, zato se zunanji monitorji, ki govorijo DDC/CI, prilagodijo na enak način kot zaslon prenosnika.

### Zasloni Apple

Če uporabljate zaslon Apple, bodo običajne tipke za svetlost na tipkovnici prav tako samodejno delovale, če ste osredotočeni na zaslon Apple. To se izvede z ukazom `asdcontrol`.

Upoštevajte, da boste, če uporabljate zaslon Apple 6K XDR, v svojem izpisu `hyprctl monitors` morda videli fantomski zaslon. To lahko izklopite z nečim podobnim `hl.monitor({ output = "DP-2", disabled = true })` prek _Setup > Monitors_.

Na računalnikih Intel bi se morali na zaslone Apple povezovati z običajnim kablom Thunderbolt. Na drugih računalnikih brez Thunderbolta boste običajno morali uporabiti [kabel DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N), da bo delovalo.
