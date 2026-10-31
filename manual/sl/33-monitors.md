# Monitorji

Omarchy privzema, da privzeto uporabljaš zaslon razreda retina z 2-kratno zmogljivostjo. To potrebuješ, da dobiš tiste lepe, ostre programerske pisave. Za to so optimizirani skoraj vsi novi vrhunski prenosniki z zasloni visoke ločljivosti. To bi želel uporabljati na 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) ali 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Če pa ne uporabljaš zaslona s PPI 218 ali več, boš želel spremeniti nastavitve monitorja. Če imaš na primer 27" ali 32" 4K, lahko zanj izbereš delno merilo na plošči za monitorje v zgornji vrstici ali nastaviš privzeto za vsak monitor tako, da odpreš `~/.config/hypr/monitors.lua` in preklopiš na priporočilo za to kombinacijo:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Če uporabljaš zaslon 1080p ali 1440p, boš verjetno želel uporabiti kar merilo 1x, enako za aplikacije GTK in X11, zato lahko uporabiš:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Spremembe `GDK_SCALE` veljajo za aplikacije, zagnane po spremembi (GTK pa upošteva samo cela števila, zato ga ohrani na celem številu, najbližjem merilu tvojega monitorja). Zato poskrbi, da zapreš okna, ki jih imaš in so po spremembi prevelika (ali zapri vsa okna s `Ctrl + Alt + Del`!).

Hitro lahko tudi preklapljaš med glavnimi razmerji merila monitorja (1x, 1.25x, 1.6x, 2x, 3x, 4x) s `Super + /` za višje in `Super + Alt + /` za nižje ali enega izbereš na plošči za monitorje v zgornji vrstici. Te spremenijo samo monitor, na katerega si osredotočen, zato imata zaslon prenosnika in zunanji zaslon lahko vsak svoje merilo. Plošča nastavi tudi ločljivost vsakega monitorja. Tvoje izbire so za ta fizični monitor shranjene v `~/.local/state/omarchy/monitors/settings`, zato se ohranijo po ponovnem zagonu in spremljajo monitor do vrat ali postaje, na katero ga priključiš naslednjič. Imajo prednost pred vsakim pravilom za isti monitor v `~/.config/hypr/monitors.lua`, ki ga Omarchy nikoli ne ureja. Ker je `GDK_SCALE` ena vrednost za vse zaslone, ga izbrano merilo nastavi glede na monitor z najnižjim merilom, zato so aplikacije X11 na gostejšem zaslonu videti malo premajhne in ne prevelike na drugem.

### Povečanje ali pomanjšanje besedila

Merilo monitorja spremeni velikost vsega. Če želiš le večje ali manjše _besedilo_, obstaja za to en sam gumb:

```
omarchy display text size 14
```

Ta sprejme velikost v pikslih med 9 in 20 ter hkrati premakne lupino Omarchy, aplikacije GTK in tvoj terminal, tako da celotno namizje ostane v sorazmerju. Zaženi ga brez argumenta, da vidiš, kje si, in `omarchy display text size reset`, da se vrneš na privzeto. Foot je edini zaostanek: nima načina za ponovno nalaganje svoje konfiguracije, zato terminali, ki že tečejo, ohranijo staro velikost, dokler ne odpreš novega.

### Razširitev in zrcaljenje zaslonov prenosnika

Ko na prenosnik priključiš zunanji zaslon, se zaslon samodejno razširi. Lahko pa to spremeniš v zrcaljenje s pomočjo _Trigger > Hardware_ v meniju Omarchy ali `Super + Ctrl + Alt + Delete`. To je še posebej koristno, če je ta zunanji zaslon projektor in želiš med delom nekaj pokazati.

Ko razširjaš, bo zapiranje pokrova na prenosniku samodejno izklopilo notranji zaslon. Odprtje pokrova ga bo spet vklopilo. To lahko upravljaš tudi ročno s pomočjo _Trigger > Hardware_ v meniju Omarchy ali `Super + Ctrl + Delete`.

### Razporejanje več zaslonov

Hyprland odlično deluje z več zasloni. Plošča za monitorje v zgornji vrstici jih nariše tam, kjer sedijo: povleci enega ob stran drugega, da ga premakneš tja, razporeditev pa se shrani skupaj z drugimi nastavitvami vsakega monitorja. Za vse, česar plošča ne pokriva, preberi več o tem, kako jih postaviti, v [dokumentaciji Hyprland o monitorjih](https://wiki.hypr.land/Configuring/Basics/Monitors/). V Omarchyju te vneseš v `~/.config/hypr/monitors.lua` kot vnose `hl.monitor` — datoteka je opremljena s komentiranimi primeri za pripenjanje določenega monitorja na ločljivost, položaj in vrtenje.

Vsak monitor ima svojih delovnih prostorov 1 do 10, zato `Super + 1` vedno pomeni prvi delovni prostor monitorja, na katerem si. Za kulisami Hyprland še vedno številči delovne prostore čez vse monitorje: zaslon tvojega prenosnika (ali prvi monitor) dobi 1–10, naslednji monitor 11–20 in tako naprej, vsak monitor pa obdrži svoj blok vsakič, ko ga priključiš. Te številke uporabi, če pišeš [pravila za delovne prostore](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) ali pravila za okna za določen monitor, tako da je delovni prostor 12 drugi delovni prostor tvojega drugega monitorja. `~/.local/state/omarchy/monitors/workspaces` navaja, kateri blok ima vsak monitor.

Smerne tipke delujejo čez monitorje, ki si delijo rob v tvoji postavitvi. Zasloni, ki se dotikajo samo v kotu ali med katerimi je vrzel, nista soseda, zato za premik med njimi uporabi `Ctrl + Alt + Tab`.

| Bližnjica | Čez monitorje |
| --- | --- |
| `Super + Arrow` | Premakne fokus na monitor na tisti strani, ko v tisti smeri ni več nobenega okna |
| `Super + Shift + Arrow` | Zamenja z oknom na monitorju na tisti strani |
| `Super + Alt + Arrow` | Premakne okno v skupino na monitorju na tisti strani |
| `Super + Shift + Ctrl + Arrow` | Premakne okno na monitor na tisti strani, na delovni prostor, ki ga prikazuje |
| `Super + Shift + Alt + Arrow` | Premakne delovni prostor na monitor na tisti strani in obdrži njegovo številko, če je prosta |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Premakne fokus na naslednji ali prejšnji monitor, ne glede na postavitev |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Ostanejo na monitorju, na katerem si |

Ogledaš si lahko tudi [Hyprmon](https://github.com/erans/hyprmon/), če želiš TUI, ki ti bo pomagal pri postavljanju več zaslonov.

### Upravljanje svetlosti

Svetlost monitorja se upravlja z namenskima funkcijskima tipkama za povečanje/zmanjšanje svetlosti. Če med pritiskanjem teh tipk držiš shift, boš šel na največjo ali najmanjšo svetlost. Tipke upravljajo zaslon, na katerega si osredotočen, zato se zunanji monitorji, ki govorijo DDC/CI, prilagajajo enako kot zaslon prenosnika.

### Zasloni Apple

Če uporabljaš zaslon Apple, bodo običajne tipke za svetlost na tipkovnici samodejno delovale tudi, če si osredotočen na zaslon Apple. To se naredi z ukazom `asdcontrol`.

Upoštevaj, da boš, če uporabljaš zaslon Apple 6K XDR, na seznamu `hyprctl monitors` morda videl fantomski zaslon. To lahko izklopiš z nečim, kot je `hl.monitor({ output = "DP-2", disabled = true })` v `~/.config/hypr/monitors.lua`.

Na računalnikih Intel moraš zaslone Apple povezovati z običajnim kablom Thunderbolt. Na drugih računalnikih brez Thunderbolta boš, da bo delovalo, običajno moral uporabiti [kabel DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N).
