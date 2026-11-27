# Monitorji

Omarchy privzeto predvideva, da uporabljaš zaslon razreda retina, ki podpira 2x. To potrebuješ za tiste lepe, ostre programerske pisave. Za to so optimizirani skoraj vsi novi vrhunski prenosniki z zasloni visoke ločljivosti. Takšen zaslon bi želel uporabljati na 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) ali 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Če pa ne uporabljaš zaslona s PPI 218 ali več, boš želel spremeniti nastavitve monitorja. Če imaš na primer 27" ali 32" 4K, lahko zanj izbereš delno povečavo na plošči za monitor v zgornji vrstici ali nastaviš privzeto vrednost za vsak monitor tako, da odpreš `~/.config/hypr/monitors.lua` in preklopiš na priporočilo za to kombinacijo:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Če uporabljaš zaslon 1080p ali 1440p, boš verjetno želel uporabiti kar povečavo 1x, enako pa tudi za aplikacije GTK in X11, zato lahko uporabiš:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Spremembe `GDK_SCALE` veljajo za aplikacije, zagnane po spremembi (GTK pa upošteva le cela števila, zato naj ostane na najbližjem celem številu povečave tvojega monitorja). Zato po spremembi zapri okna, ki so prevelika (ali zapri vsa okna s `Ctrl + Alt + Del`!).

Med glavnimi razmerji povečave monitorja (1x, 1.25x, 1.6x, 2x, 3x, 4x) lahko hitro preklapljaš tudi s `Super + /` za večjo in `Super + Alt + /` za manjšo ali pa eno izbereš na plošči za monitor v zgornji vrstici. Te spremembe veljajo le za monitor, na katerem si trenutno, zato imata lahko zaslon prenosnika in zunanji zaslon vsak svojo povečavo. Plošča nastavi tudi ločljivost, hitrost osveževanja in vrtenje vsakega monitorja. Tvoje izbire se za ta fizični monitor shranijo v `~/.local/state/omarchy/monitors/settings`, zato ostanejo tudi po ponovnem zagonu in sledijo monitorju na katera koli vrata ali priklopno postajo, na katero ga priključiš naslednjič. Imajo prednost pred vsakim pravilom za isti monitor v `~/.config/hypr/monitors.lua`, ki ga Omarchy nikoli ne ureja. Če raje monitorje v celoti nastaviš v tej datoteki, vanjo dodaj `omarchy_monitor_panel_settings = false` in spremembe s plošče bodo veljale le, dokler se Hyprland znova ne naloži. Ker je `GDK_SCALE` ena vrednost za vse zaslone, jo izbrana povečava nastavi glede na monitor z najmanjšo povečavo, zato so aplikacije X11 na gostejšem zaslonu nekoliko premajhne, namesto da bi bile na drugem prevelike.

### Povečanje ali pomanjšanje besedila

Povečava monitorja spremeni velikost vsega. Če želiš večje ali manjše samo _besedilo_, je za to en sam gumb:

```
omarchy display text size 14
```

Ta sprejme velikost v slikovnih pikah med 9 in 20 ter skupaj premakne lupino Omarchy, aplikacije GTK in tvoj terminal, tako da celotno namizje ostane v sorazmerju. Zaženi ga brez argumenta, da vidiš, kje si trenutno, in `omarchy display text size reset`, da se vrneš na privzeto vrednost. Foot je edini zaostali primer: svoje konfiguracije ne more znova naložiti, zato terminali, ki že tečejo, obdržijo staro velikost, dokler ne odpreš novega.

### Razširitev in zrcaljenje zaslonov prenosnika

Ko na prenosnik priključiš zunanji zaslon, se zaslon samodejno razširi. To pa lahko spremeniš v zrcaljenje z _Extend_ | _Mirror_ na plošči za monitor v zgornji vrstici, _Trigger > Hardware_ v meniju Omarchy ali `Super + Ctrl + Alt + Delete`. To je še posebej koristno, če je ta zunanji zaslon projektor in želiš med delom nekaj pokazati.

Ko uporabljaš razširitev, bo zapiranje pokrova prenosnika samodejno izklopilo notranji zaslon. Odpiranje pokrova ga bo znova vklopilo. To lahko nadzoruješ tudi ročno z _Trigger > Hardware_ v meniju Omarchy ali `Super + Ctrl + Delete`.

Dokler je prenosnik priključen na napajanje, ga zapiranje pokrova nikoli ne uspava, zato prenosnik na priklopni postaji ostane buden, tudi če se zunanji zaslon za kratek čas odklopi. Če zunanji zaslon ni priključen, zapiranje pokrova na napajanju prenosnik samo zaklene. Na bateriji zapiranje pokrova kot običajno preklopi v stanje mirovanja.

### Urejanje več zaslonov

Hyprland odlično deluje z več zasloni. Plošča za monitor v zgornji vrstici jih nariše tam, kjer so: enega povleci ob stran drugega, da ga premakneš tja, razporeditev pa se shrani skupaj z drugimi nastavitvami vsakega monitorja. Za vse, česar plošča ne pokriva, si več o tem, kako jih razporediti, preberi v [dokumentaciji o monitorjih za Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). V Omarchyju gre to v `~/.config/hypr/monitors.lua` kot vnosi `hl.monitor` — datoteka je priložena s komentiranimi primeri za izklop monitorja, načine, ki jih plošča ne ponuja, 10-bitno barvo in spremenljivo hitrost osveževanja.

Vsak monitor ima svojih delovnih prostorov od 1 do 10, zato `Super + 1` vedno pomeni prvi delovni prostor monitorja, na katerem si. Hyprland v ozadju še vedno oštevilčuje delovne prostore čez vse monitorje: zaslon prenosnika (ali prvi monitor) dobi 1–10, naslednji monitor 11–20 in tako naprej, vsak monitor pa obdrži svoj blok vsakič, ko ga priključiš. Te številke uporabi, če pišeš [pravila za delovne prostore](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) ali pravila za okna za določen monitor, tako da je delovni prostor 12 drugi delovni prostor tvojega drugega monitorja. `~/.local/state/omarchy/monitors/workspaces` navaja, kateri blok ima vsak monitor.

Smerne tipke delujejo med monitorji, ki si v tvoji postavitvi delijo rob. Zasloni, ki se dotikajo le v kotu ali imajo med seboj vrzel, niso sosedje, zato za premik med njimi uporabi `Ctrl + Alt + Tab`.

| Hotkey | Across monitors |
| --- | --- |
| `Super + Arrow` | Premakne fokus na monitor na tisti strani, ko v tisti smeri ni več nobenega okna |
| `Super + Shift + Arrow` | Zamenja z oknom na monitorju na tisti strani |
| `Super + Alt + Arrow` | Premakne okno v skupino na monitorju na tisti strani |
| `Super + Shift + Ctrl + Arrow` | Premakne okno na monitor na tisti strani, na delovni prostor, ki ga ta prikazuje |
| `Super + Shift + Alt + Arrow` | Premakne delovni prostor na monitor na tisti strani in ohrani njegovo številko, če je prosta |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Premakne fokus na naslednji ali prejšnji monitor, ne glede na postavitev |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Ostanejo na monitorju, na katerem si |

Oglej si lahko tudi [Hyprmon](https://github.com/erans/hyprmon/), če želiš TUI za pomoč pri postavljanju več zaslonov.

### Nadzor svetlosti

Svetlost monitorja nadzoruješ z namenskima funkcijskima tipkama za povečanje/zmanjšanje svetlosti. Če med pritiskom teh tipk držiš Shift, boš šel na največjo ali najmanjšo svetlost. Tipke nadzorujejo zaslon, na katerem si trenutno, zato se zunanji monitorji, ki govorijo DDC/CI, prilagajajo enako kot zaslon prenosnika.

### Zasloni Apple

Če uporabljaš zaslon Apple, bodo običajne tipke za svetlost na tipkovnici samodejno delovale tudi, če si na zaslonu Apple. To se naredi z ukazom `asdcontrol`.

Upoštevaj, da lahko pri uporabi zaslona Apple 6K XDR na seznamu `hyprctl monitors` vidiš navidezni zaslon. To lahko izklopiš z nečim, kot je `hl.monitor({ output = "DP-2", disabled = true })` v `~/.config/hypr/monitors.lua`.

Na računalnikih Intel se moraš na zaslone Apple povezovati z običajnim kablom Thunderbolt. Na drugih računalnikih brez Thunderbolta boš za delovanje običajno moral uporabiti [kabel DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N).
