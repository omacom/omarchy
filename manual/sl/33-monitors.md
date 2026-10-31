# Monitorji

Omarchy privzeto predpostavlja, da uporabljate zaslon razreda retina z zmogljivostjo 2x. To potrebujete za lepe, ostre programerske pisave. Za to so optimizirani skoraj vsi novi vrhunski prenosniki z zasloni visoke ločljivosti. To bi želeli uporabljati na 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) ali 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Če pa ne uporabljate zaslona s PPI 218 ali več, boste želeli spremeniti nastavitve monitorja. Če imate na primer 27" ali 32" 4K, lahko zanj izberete delno povečavo na plošči za monitor v zgornji vrstici ali nastavite privzeto vrednost za vsak monitor tako, da odprete `~/.config/hypr/monitors.lua` in preklopite na priporočilo za to kombinacijo:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Če uporabljate zaslon 1080p ali 1440p, boste verjetno želeli uporabiti kar povečavo 1x, enako pa tudi za aplikacije GTK in X11, zato lahko uporabite:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Spremembe `GDK_SCALE` veljajo za aplikacije, zagnane po spremembi (GTK pa upošteva le cela števila, zato naj ostane na najbližjem celem številu vaše povečave monitorja). Zato po spremembi zaprite okna, ki so prevelika (ali zaprite vsa okna s `Ctrl + Alt + Del`!).

Skozi glavna razmerja povečave monitorja (1x, 1.25x, 1.6x, 2x, 3x, 4x) se lahko hitro pomikate tudi s `Super + /` za večjo in `Super + Alt + /` za manjšo povečavo ali pa eno izberete na plošči za monitor v zgornji vrstici. Te spremembe veljajo le za monitor, na katerem ste osredotočeni, zato imata zaslon prenosnika in zunanji zaslon lahko vsak svojo povečavo. Na plošči nastavite tudi ločljivost vsakega monitorja. Vaše izbire se za ta fizični monitor shranijo v `~/.local/state/omarchy/monitors/settings`, zato ostanejo po ponovnem zagonu in sledijo monitorju na katera koli vrata ali priklopno postajo, na katero ga priključite naslednjič. Imajo prednost pred vsakim pravilom za isti monitor v `~/.config/hypr/monitors.lua`, ki ga Omarchy nikoli ne ureja. Če bi raje monitorje v celoti nastavili v tej datoteki, vanjo dodajte `omarchy_monitor_panel_settings = false` in spremembe s plošče bodo veljale le, dokler se Hyprland znova ne naloži. Ker je `GDK_SCALE` ena vrednost za vse zaslone, izbrana povečava to vrednost nastavi glede na monitor z najmanjšo povečavo, tako da so aplikacije X11 na gostejšem zaslonu nekoliko premajhne, namesto da bi bile prevelike na drugem.

### Povečanje ali pomanjšanje besedila

Povečava monitorja spremeni velikost vsega. Če želite večje ali manjše samo _besedilo_, je za to en sam gumb:

```
omarchy display text size 14
```

Ta sprejme velikost v pikslih med 9 in 20 ter skupaj premakne lupino Omarchy, aplikacije GTK in vaš terminal, tako da celotno namizje ostane v sorazmerju. Zaženite ga brez argumenta, da vidite, kje ste, in `omarchy display text size reset`, da se vrnete na privzeto vrednost. Foot je edini zaostali: svoje konfiguracije ne more znova naložiti, zato terminali, ki že tečejo, ohranijo staro velikost, dokler ne odprete novega.

### Razširitev in zrcaljenje zaslonov prenosnika

Ko na prenosnik priključite zunanji zaslon, se zaslon samodejno razširi. To pa lahko spremenite v zrcaljenje prek _Trigger > Hardware_ v meniju Omarchy ali s `Super + Ctrl + Alt + Delete`. To je še posebej koristno, če je ta zunanji zaslon projektor in želite med delom nekaj pokazati.

Pri razširitvi bo zaprtje pokrova prenosnika samodejno izklopilo notranji zaslon. Ko pokrov odprete, se bo znova vklopil. To lahko nadzirate tudi ročno prek _Trigger > Hardware_ v meniju Omarchy ali s `Super + Ctrl + Delete`.

### Razporejanje več zaslonov

Hyprland odlično deluje z več zasloni. Plošča za monitor v zgornji vrstici jih nariše tam, kjer so: enega povlecite ob stran drugega, da ga premaknete tja, razporeditev pa se shrani skupaj z drugimi nastavitvami vsakega monitorja. Za vse, česar plošča ne pokriva, si več o razporejanju preberite v [dokumentaciji Hyprland o monitorjih](https://wiki.hypr.land/Configuring/Basics/Monitors/). V Omarchyju gredo te v `~/.config/hypr/monitors.lua` kot vnosi `hl.monitor` — datoteka je dobavljena s komentiranimi primeri za pripenjanje določenega monitorja na ločljivost, položaj in vrtenje.

Vsak monitor ima svoje delovne prostore od 1 do 10, zato `Super + 1` vedno pomeni prvi delovni prostor monitorja, na katerem ste. V ozadju Hyprland delovne prostore še vedno številči prek vseh monitorjev: zaslon vašega prenosnika (ali prvi monitor) dobi 1–10, naslednji monitor 11–20 in tako naprej, vsak monitor pa obdrži svoj blok vsakič, ko ga priključite. Te številke uporabite, če pišete [pravila za delovne prostore](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) ali pravila za okna za določen monitor, tako da je delovni prostor 12 drugi delovni prostor vašega drugega monitorja. `~/.local/state/omarchy/monitors/workspaces` navaja, kateri blok ima vsak monitor.

Puščične tipke delujejo med monitorji, ki si v vaši postavitvi delijo rob. Zasloni, ki se dotikajo le v kotu ali imajo med seboj vrzel, niso sosedje, zato za premik med njimi uporabite `Ctrl + Alt + Tab`.

| Bližnjica | Med monitorji |
| --- | --- |
| `Super + Arrow` | Premakne fokus na monitor na tisti strani, ko v tisti smeri ni več nobenega okna |
| `Super + Shift + Arrow` | Zamenja z oknom na monitorju na tisti strani |
| `Super + Alt + Arrow` | Premakne okno v skupino na monitorju na tisti strani |
| `Super + Shift + Ctrl + Arrow` | Premakne okno na monitor na tisti strani, na delovni prostor, ki ga prikazuje |
| `Super + Shift + Alt + Arrow` | Premakne delovni prostor na monitor na tisti strani in ohrani njegovo številko, če je prosta |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Premakne fokus na naslednji ali prejšnji monitor, ne glede na postavitev |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Ostane na monitorju, na katerem ste |

Oglejte si tudi [Hyprmon](https://github.com/erans/hyprmon/), če želite TUI, ki vam pomaga pri postavljanju več zaslonov.

### Nadzor svetlosti

Svetlost monitorja nadzirate z namenskim funkcijskima tipkama za povečanje/zmanjšanje svetlosti. Če med pritiskom teh tipk držite Shift, boste šli na največjo ali najmanjšo svetlost. Tipke nadzirajo zaslon, na katerem ste osredotočeni, zato se zunanji monitorji, ki govorijo DDC/CI, prilagodijo enako kot zaslon prenosnika.

### Zasloni Apple

Če uporabljate zaslon Apple, bodo običajne tipke za svetlost na tipkovnici samodejno delovale tudi, če ste osredotočeni na zaslon Apple. To se izvede prek ukaza `asdcontrol`.

Upoštevajte, da če uporabljate zaslon Apple 6K XDR, boste v izpisu `hyprctl monitors` morda videli fantomski zaslon. To lahko izklopite z nečim podobnim `hl.monitor({ output = "DP-2", disabled = true })` v `~/.config/hypr/monitors.lua`.

Na računalnikih Intel se morate na zaslone Apple povezovati z običajnim kablom Thunderbolt. Na drugih računalnikih brez vrat Thunderbolt boste običajno morali uporabiti [kabel DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N), da bo delovalo.
