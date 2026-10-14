# Monitory

Omarchy predvolene predpokladá, že bežíš na displeji triedy retina s možnosťou 2x. To je to, čo potrebuješ, aby si získal tie pekné, ostré programátorské písma. Na to sú optimalizované takmer všetky nové prémiové notebooky s obrazovkami s vysokým rozlíšením. To by si chcel prevádzkovať na 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) alebo 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Ak však nepoužívaš displej s PPI 218 alebo vyšším, budeš chcieť zmeniť nastavenia monitora. Napríklad, ak máš 27" alebo 32" 4K, môžeš použiť zlomkové škálovanie otvorením súboru `~/.config/hypr/monitors.lua` (prostredníctvom _Nastavenie > Monitory_ v menu Omarchy) a prepnutím na odporúčanie pre túto kombináciu:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Ak používaš displej 1080p alebo 1440p, pravdepodobne budeš chcieť jednoducho použiť škálovanie 1x, takže môžeš použiť:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Zmeny `GDK_SCALE` sa vzťahujú na aplikácie spustené po zmene (a GTK rešpektuje len celé čísla, takže ho udržiavaj na najbližšom celom čísle tvojho škálovania monitora). Takže sa uisti, že po zmene ukončíš okná, ktoré máš a ktoré sú príliš veľké (alebo zatvor všetky okná pomocou `Ctrl + Alt + Del`!).

Môžeš tiež rýchlo prechádzať hlavnými pomermi škálovania monitora (1x, 1.25x, 1.6x, 2x, 3x, 4x) pomocou `Super + /` na zvýšenie a `Super + Alt + /` na zníženie. Ak máš predvolenú konfiguráciu, tieto zmeny pretrvajú aj po reštarte.

### Zväčšovanie alebo zmenšovanie textu

Škálovanie monitora mení veľkosť všetkého. Ak chceš len väčší alebo menší _text_, existuje na to jediný gombík:

```
omarchy display text size 14
```

Ten preberá veľkosť v pixeloch od 9 do 20 a posúva shell Omarchy, aplikácie GTK a tvoj terminál spoločne, takže celá pracovná plocha zostáva v proporciách. Spusti to bez argumentu, aby si videl, na čom si, a `omarchy display text size reset`, aby si sa vrátil k predvoleným nastaveniam. Foot je jediný oneskorenec: nemá spôsob, ako znova načítať svoju konfiguráciu, takže spustené terminály si zachovávajú svoju starú veľkosť, kým neotvoríš nový.

### Rozširovanie a zrkadlenie displejov notebookov

Keď k notebooku pripojíš externú obrazovku, displej sa automaticky rozšíri. Môžeš to však zmeniť na zrkadlenie pomocou _Akcie > Hardvér_ v menu Omarchy alebo `Super + Ctrl + Alt + Delete`. Toto je obzvlášť užitočné, ak je tou externou obrazovkou projektor a chceš počas práce niečo ukázať.

Keď rozširuješ, zatvorenie veka notebooku automaticky vypne internú obrazovku. Otvorenie veka ju znova zapne. Môžeš to ovládať aj ručne pomocou _Akcie > Hardvér_ v menu Omarchy alebo `Super + Ctrl + Delete`.

### Usporiadanie viacerých obrazoviek

Hyprland skvele funguje s viacerými obrazovkami. Ďalšie informácie o tom, ako ich rozložiť, nájdeš v [dokumentácii monitorov Hyprlandu](https://wiki.hypr.land/Configuring/Basics/Monitors/). Môžeš tiež [viazať konkrétne pracovné plochy na konkrétne monitory](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/). V Omarchy tieto pravidlá idú do súboru `~/.config/hypr/monitors.lua` ako položky `hl.monitor` — súbor sa dodáva s komentovanými príkladmi na pripnutie konkrétneho monitora k rozlíšeniu, polohe a rotácii.

Môžeš si pozrieť aj [Hyprmon](https://github.com/erans/hyprmon/), ak by si chcel TUI, ktoré ti pomôže s umiestnením viacerých obrazoviek.

### Ovládanie jasu

Jas monitora sa ovláda dedikovanými funkčnými klávesmi na zvýšenie/zníženie jasu. Ak pri ich stláčaní podržíš shift, prejdeš na maximálny alebo minimálny jas. Klávesy ovládajú displej, na ktorý máš fokus, takže externé monitory, ktoré hovoria protokolom DDC/CI, sa nastavujú rovnakým spôsobom ako obrazovka notebooku.

### Displeje Apple

Ak používaš displej Apple, bežné klávesy jasu na klávesnici budú tiež automaticky fungovať, ak máš fokus na displeji Apple. Toto sa robí prostredníctvom príkazu `asdcontrol`.

Maj na pamäti, že ak používaš displej Apple 6K XDR, môžeš vo svojom výpise `hyprctl monitors` vidieť fantómovú obrazovku. Môžeš ju vypnúť napríklad pomocou `hl.monitor({ output = "DP-2", disabled = true })` prostredníctvom _Nastavenie > Monitory_.

Na počítačoch Intel by si sa mal k displejom Apple pripájať pomocou bežného kábla Thunderbolt. Na iných počítačoch bez Thunderboltu budeš na jeho fungovanie zvyčajne musieť použiť [kábel DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N).
