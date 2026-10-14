# Zasloni

Omarchy privzeto predpostavlja, da uporabljate zaslon razreda retina, zmožen 2x. To je potrebno, da dobite lepe, ostre programerske pisave. Za to so optimizirani skoraj vsi novi premium prenosniki z visokoločljivostnimi zasloni. To je tisto, kar bi radi izvajali na 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) ali 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Če pa ne uporabljate zaslona s PPI 218 ali več, boste želeli spremeniti nastavitve zaslona. Če imate na primer 27" ali 32" 4K, lahko uporabite delno povečevanje, tako da odprete `~/.config/hypr/monitors.lua` (prek _Nastavitve > Zasloni_ v meniju Omarchy) in preklopite na priporočilo za to kombinacijo:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Če uporabljate zaslon 1080p ali 1440p, boste verjetno želeli povečevanje 1x, tako da lahko uporabite:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Spremembe `GDK_SCALE` veljajo za aplikacije, zagnane po spremembi (GTK pa sprejema le cela števila, zato ga hranite pri najbližji celi vrednosti povečevanja vašega zaslona). Zato po spremembi poskrbite, da zaprete okna, ki so prevelika (ali zaprite vsa okna s `Ctrl + Alt + Del`!).

Prav tako lahko hitro prehajate skozi glavne razmere povečevanja zaslona (1x, 1.25x, 1.6x, 2x, 3x, 4x) z `Super + /` navzgor in `Super + Alt + /` navzdol. Če imate privzeto konfiguracijo, bodo te spremembe preživele tudi ponovni zagon.

### Povečevanje ali pomanjševanje besedila

Povečevanje zaslona spremeni velikost vsega. Če želite samo večje ali manjše _besedilo_, obstaja en sam gumb za to:

```
omarchy display text size 14
```

To prevzame velikost v slikovnih pikah med 9 in 20 in premakne lupino Omarchy, aplikacije GTK in vaš terminal skupaj, tako da celotno namizje ostane v razmerju. Zaženite brez argumenta, da vidite, kje ste, in `omarchy display text size reset`, da se vrnete na privzeto. Foot je edini zaostajalec: nima načina, da ponovno naloži svojo konfiguracijo, zato tekoči terminali obdržijo staro velikost, dokler ne odprete novega.

### Razširjanje in zrcaljenje zaslonov prenosnika

Ko na prenosnik priklopite zunanji zaslon, se zaslon samodejno razširi. Lahko pa to spremenite v zrcaljenje prek _Sproži > Strojna oprema_ v meniju Omarchy ali `Super + Ctrl + Alt + Delete`. To je še posebej koristno, če je ta zunanji zaslon projektor in želite kaj prikazati med delom.

Ko razširjate, zaprtje pokrova prenosnika samodejno izklopi notranji zaslon. Odprtje pokrova ga znova vklopi. To lahko nadzirate tudi ročno prek _Sproži > Strojna oprema_ v meniju Omarchy ali `Super + Ctrl + Delete`.

### Urejanje več zaslonov

Hyprland odlično deluje z več zasloni. Več o postavitvi preberite v [dokumentaciji zaslonov Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). Lahko tudi [vežete specifične delovne prostore na specifične zaslone](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/). V Omarchy ta pravila gredo v `~/.config/hypr/monitors.lua` kot vnosi `hl.monitor` — datoteka vsebuje komentirane primere za pripenjanje specifičnega zaslona na ločljivost, položaj in vrtenje.

Lahko preverite tudi [Hyprmon](https://github.com/erans/hyprmon/), če želite TUI, ki pomaga pri pozicioniranju več zaslonov.

### Uravnavanje svetlosti

Svetlost zaslona nadzirajo namenske funkcijske tipke za svetlost gor/dol. Če med pritiskom držite shift, boste šli na največjo ali najmanjšo svetlost. Tipke nadzirajo zaslon, na katerega ste usmerjeni, tako da se zunanji zasloni, ki govorijo DDC/CI, prilagodijo enako kot zaslon prenosnika.

### Zasloni Apple

Če uporabljate zaslon Apple, bodo običajne tipke za svetlost na tipkovnici prav tako samodejno delovale, če ste usmerjeni na zaslon Apple. To se naredi prek ukaza `asdcontrol`.

Upoštevajte, da lahko, če uporabljate zaslon Apple 6K XDR, v seznamu `hyprctl monitors` vidite fantomski zaslon. To lahko izklopite z nečim podobnim `hl.monitor({ output = "DP-2", disabled = true })` prek _Nastavitve > Zasloni_.

Na računalnikih Intel bi se morali z zasloni Apple povezovati z običajnim kablom Thunderbolt. Na drugih računalnikih brez Thunderbolta boste običajno morali uporabiti [kabel DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N), da boste dosegli delovanje.
