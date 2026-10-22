# Monitori

Omarchy pretpostavlja da prema zadanim postavkama koristiš zaslon retina klase s mogućnošću 2x. To je ono što ti treba za one lijepe, oštre programerske fontove. To je ono za što su optimizirani gotovo svi novi premium prijenosnici s zaslonima visoke razlučivosti. To je ono što bi želio koristiti na 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) ili 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Ali ako ne koristiš zaslon s PPI od 218 ili više, htjet ćeš promijeniti postavke monitora. Na primjer, ako imaš 27" ili 32" 4K, možeš koristiti frakcijsko skaliranje otvaranjem `~/.config/hypr/monitors.lua` (putem _Postavke > Monitori_ u izborniku Omarchy) i prebacivanjem na preporuku za tu kombinaciju:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Ako koristiš zaslon 1080p ili 1440p, vjerojatno ćeš htjeti koristiti 1x skaliranje, pa možeš koristiti:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Promjene `GDK_SCALE` primjenjuju se na aplikacije pokrenute nakon promjene (a GTK poštuje samo cijele brojeve, pa ga drži na najbližem cijelom broju skale tvog monitora). Zato obavezno zatvori prozore koje imaš koji su preveliki nakon promjene (ili zatvori sve prozore s `Ctrl + Alt + Del`!).

Također možeš brzo koračati kroz glavne omjere skaliranja monitora (1x, 1.25x, 1.6x, 2x, 3x, 4x) koristeći `Super + /` za više i `Super + Alt + /` za niže. Ako imaš zadanu konfiguraciju, ove promjene također će se zadržati nakon ponovnog pokretanja.

### Povećavanje ili smanjivanje teksta

Skaliranje monitora mijenja veličinu svega. Ako sve što želiš je veći ili manji _tekst_, za to postoji jedan gumb:

```
omarchy display text size 14
```

To uzima veličinu u pikselima između 9 i 20 i pomiče Omarchy ljusku, GTK aplikacije i tvoj terminal zajedno, pa cijela radna površina ostaje u proporciji. Pokreni ga bez argumenta da vidiš gdje si, a `omarchy display text size reset` za povratak na zadano. Foot je jedini zaostali: nema načina za ponovno učitavanje konfiguracije, pa aktivni terminali zadržavaju staru veličinu dok ne otvoriš novi.

### Proširivanje i zrcaljenje zaslona prijenosnika

Kad spojiš vanjski zaslon na prijenosnik, prikaz se automatski proširuje. Ali to možeš promijeniti u zrcaljenje koristeći _Pokreni > Hardver_ u izborniku Omarchy ili `Super + Ctrl + Alt + Delete`. To je posebno korisno ako je taj vanjski zaslon projektor i želiš nešto pokazati dok radiš.

Kad proširuješ, zatvaranje poklopca prijenosnika automatski će isključiti unutarnji zaslon. Otvaranje poklopca vratit će ga. To također možeš kontrolirati ručno koristeći _Pokreni > Hardver_ u izborniku Omarchy ili `Super + Ctrl + Delete`.

### Raspoređivanje više zaslona

Hyprland odlično radi s više zaslona. Pročitaj više o tome kako ih rasporediti u [dokumentaciji Hyprland monitora](https://wiki.hypr.land/Configuring/Basics/Monitors/). Možeš [vezati određene radne prostore za određene monitore](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) također. U Omarchyju ova pravila idu u `~/.config/hypr/monitors.lua` kao unosi `hl.monitor` — datoteka dolazi s komentiranim primjerima za pričvršćivanje određenog monitora na razlučivost, položaj i rotaciju.

Također možeš pogledati [Hyprmon](https://github.com/erans/hyprmon/), ako želiš TUI koji će ti pomoći s pozicioniranjem više zaslona.

### Kontroliranje svjetline

Svjetlina monitora kontrolira se namjenskim funkcijskim tipkama za povećavanje/smanjivanje svjetline. Ako tijekom pritiskanja držiš shift, ići ćeš na maksimalnu ili minimalnu svjetlinu. Tipke kontroliraju zaslon na koji si fokusiran, pa se vanjski monitori koji govore DDC/CI prilagođavaju na isti način kao zaslon prijenosnika.

### Apple zasloni

Ako koristiš Apple zaslon, redovne tipke za svjetlinu tipkovnice također će automatski raditi, ako si fokusiran na Apple zaslon. To se radi kroz naredbu `asdcontrol`.

Imaj na umu da ako koristiš Apple 6K XDR zaslon, možeš vidjeti fantomski zaslon u popisu `hyprctl monitors`. To možeš isključiti s nečim poput `hl.monitor({ output = "DP-2", disabled = true })` putem _Postavke > Monitori_.

Na Intel računalima trebao bi se spajati na Apple zaslone koristeći običan Thunderbolt kabel. Na drugim računalima bez Thunderbolta obično ćeš morati koristiti [kabel DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N) da to proradi.
