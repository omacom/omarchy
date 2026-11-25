# Monitorji

Omarchy privzeto predpostavlja, da uporabljaš zaslon razreda retina, ki zmore 2x. To potrebuješ, da dobiš tiste lepe, ostre programerske pisave. Za to so optimizirani skoraj vsi novi vrhunski prenosniki z zasloni visoke ločljivosti. S tem boš želel delati na 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) ali 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Če pa ne uporabljaš zaslona s PPI 218 ali več, boš želel spremeniti nastavitve monitorja. Če imaš na primer 27" ali 32" 4K, lahko zanj izbereš delno merilo na plošči za monitorje v zgornji vrstici ali nastaviš privzeto za vsak monitor tako, da odpreš `~/.config/hypr/monitors.lua` in preklopiš na priporočilo za to kombinacijo:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Če uporabljaš zaslon 1080p ali 1440p, boš verjetno želel uporabiti kar merilo 1x, enako pa tudi za aplikacije GTK in X11, tako da lahko uporabiš:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Spremembe `GDK_SCALE` veljajo za aplikacije, zagnane po spremembi (GTK pa upošteva le cela števila, zato naj ostane pri celem številu, najbližjem merilu tvojega monitorja). Zato po spremembi zapri okna, ki so prevelika (ali zapri vsa okna s `Ctrl + Alt + Del`!).

Po glavnih razmerjih merila monitorja (1x, 1.25x, 1.6x, 2x, 3x, 4x) se lahko tudi hitro pomikaš s `Super + /` za večje in `Super + Alt + /` za manjše ali eno izbereš na plošči za monitorje v zgornji vrstici. Te spremembe veljajo le za monitor, na katerem si trenutno, tako da imata lahko zaslon prenosnika in zunanji zaslon vsak svoje merilo. Plošča nastavi tudi ločljivost, hitrost osveževanja in vrtenje vsakega monitorja. Tvoje izbire se za ta fizični monitor shranijo v `~/.local/state/omarchy/monitors/settings`, zato ostanejo tudi po ponovnem zagonu in sledijo monitorju na katera koli vrata ali priklopno postajo, na katero ga priključiš naslednjič. Imajo prednost pred vsakim pravilom za isti monitor v `~/.config/hypr/monitors.lua`, ki ga Omarchy nikoli ne ureja. Če bi svoje monitorje raje v celoti nastavil v tej datoteki, ji dodaj `omarchy_monitor_panel_settings = false`, in spremembe s plošče bodo trajale le, dokler se Hyprland ne naloži znova. Ker je `GDK_SCALE` ena vrednost za vse zaslone, jo izbrano merilo nastavi po monitorju z najnižjim merilom, tako da so aplikacije X11 na gostejšem zaslonu nekoliko premajhne, namesto da bi bile na drugem prevelike.

### Povečanje ali pomanjšanje besedila

Merilo monitorja spremeni velikost vsega. Če želiš le večje ali manjše _besedilo_, obstaja za to en sam gumb:

```
omarchy display text size 14
```

Ta sprejme velikost v slikovnih pikah med 9 in 20 in skupaj premakne lupino Omarchy, aplikacije GTK in tvoj terminal, tako da celotno namizje ostane v razmerju. Zaženi ga brez argumenta, da vidiš, na čem si, in `omarchy display text size reset`, da se vrneš na privzeto. Foot je edini zaostajalec: nima načina za ponovno nalaganje svoje konfiguracije, zato terminali, ki že tečejo, obdržijo staro velikost, dokler ne odpreš novega.

### Razširjanje in zrcaljenje zaslonov prenosnika

Ko na prenosnik priključiš zunanji zaslon, se zaslon samodejno razširi. Lahko pa to namesto tega spremeniš v zrcaljenje z _Razširi_ | _Zrcali_ na plošči za monitorje v zgornji vrstici, _Sprožilec > Strojna oprema_ v meniju Omarchy ali `Super + Ctrl + Alt + Delete`. To je še posebej koristno, če je ta zunanji zaslon projektor in želiš med delom nekaj pokazati.

Ko razširjaš, zaprtje pokrova prenosnika samodejno izklopi notranji zaslon. Odprtje pokrova ga znova vklopi. To lahko upravljaš tudi ročno z _Sprožilec > Strojna oprema_ v meniju Omarchy ali `Super + Ctrl + Delete`.

### Razporejanje več zaslonov

Hyprland odlično deluje z več zasloni. Plošča za monitorje v zgornji vrstici jih nariše tam, kjer sedijo: enega povleci ob stran drugega, da ga premakneš tja, in razporeditev se shrani skupaj z drugimi nastavitvami vsakega monitorja. Za vse, česar plošča ne pokriva, si več o tem, kako jih razporediti, preberi v [dokumentaciji Hyprland o monitorjih](https://wiki.hypr.land/Configuring/Basics/Monitors/). V Omarchy gredo te v `~/.config/hypr/monitors.lua` kot vnosi `hl.monitor` — datoteka je opremljena s komentiranimi primeri za to, da monitor ostane izklopljen, za načine, ki jih plošča ne ponuja, za 10-bitno barvo in za spremenljivo hitrost osveževanja.

Vsak monitor ima svojih delovnih prostorov 1 do 10, tako da `Super + 1` vedno pomeni prvi delovni prostor monitorja, na katerem si. Hyprland v ozadju delovne prostore še vedno številči prek vseh monitorjev: zaslon prenosnika (ali prvi monitor) dobi 1–10, naslednji monitor 11–20 in tako naprej, vsak monitor pa obdrži svoj blok vsakič, ko ga priključiš. Te številke uporabi, če pišeš [pravila delovnih prostorov](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) ali pravila oken za določen monitor, tako da je delovni prostor 12 drugi delovni prostor tvojega drugega monitorja. `~/.local/state/omarchy/monitors/workspaces` navaja, kateri blok ima vsak monitor.

Puščične tipke delujejo med monitorji, ki si v tvoji postavitvi delijo rob. Zasloni, ki se dotikajo le v kotu ali imajo med seboj vrzel, niso sosedje, zato za premik med njimi uporabi `Ctrl + Alt + Tab`.

| Bližnjica | Med monitorji |
| --- | --- |
| `Super + Arrow` | Premakne fokus na monitor na tisti strani, ko v tisti smeri ni več nobenega okna |
| `Super + Shift + Arrow` | Zamenja z oknom na monitorju na tisti strani |
| `Super + Alt + Arrow` | Premakne okno v skupino na monitorju na tisti strani |
| `Super + Shift + Ctrl + Arrow` | Premakne okno na monitor na tisti strani, na delovni prostor, ki ga prikazuje |
| `Super + Shift + Alt + Arrow` | Premakne delovni prostor na monitor na tisti strani in ohrani njegovo številko, če je prosta |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Premakne fokus na naslednji ali prejšnji monitor, ne glede na postavitev |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Ostane na monitorju, na katerem si |

Oglej si tudi [Hyprmon](https://github.com/erans/hyprmon/), če želiš TUI, ki ti pomaga pri postavitvi več zaslonov.

### Nadzor svetlosti

Svetlost monitorja se upravlja z namenskima funkcijskima tipkama za povečanje/zmanjšanje svetlosti. Če med pritiskanjem teh tipk držiš Shift, greš na najvišjo ali najnižjo svetlost. Tipke upravljajo zaslon, na katerem si, tako da se zunanji monitorji, ki govorijo DDC/CI, prilagajajo enako kot zaslon prenosnika.

### Zasloni Apple

Če uporabljaš zaslon Apple, običajne tipke za svetlost na tipkovnici samodejno delujejo tudi zanj, če si na zaslonu Apple. To se izvede z ukazom `asdcontrol`.

Upoštevaj, da lahko ob uporabi zaslona Apple 6K XDR na seznamu `hyprctl monitors` vidiš navidezni zaslon. To lahko izklopiš z nečim, kot je `hl.monitor({ output = "DP-2", disabled = true })` v `~/.config/hypr/monitors.lua`.

Na računalnikih Intel se moraš na zaslone Apple povezati z običajnim kablom Thunderbolt. Na drugih računalnikih brez Thunderbolt boš za delovanje običajno moral uporabiti [kabel DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N).
