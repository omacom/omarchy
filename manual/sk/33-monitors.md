# Monitory

Omarchy predvolene predpokladá, že používate displej triedy retina schopný 2x škálovania. Práve to potrebujete na tie pekné, ostré programátorské fonty. Práve na to sú optimalizované takmer všetky nové prémiové laptopy s obrazovkami s vysokým rozlíšením. Práve to by ste chceli používať na 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) alebo 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Ak však nepoužívate displej s PPI 218 alebo vyšším, budete chcieť zmeniť nastavenia monitora. Ak máte napríklad 27" alebo 32" 4K, môžete použiť zlomkové škálovanie otvorením `~/.config/hypr/monitors.lua` (cez _Nastavenie > Monitory_ v menu Omarchy) a prepnutím na odporúčanie pre danú kombináciu:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Ak používate displej s rozlíšením 1080p alebo 1440p, pravdepodobne budete chcieť jednoducho používať 1x škálovanie, takže môžete použiť:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Zmeny `GDK_SCALE` sa vzťahujú na aplikácie spustené po zmene (a GTK akceptuje len celé čísla, takže ho ponechajte na najbližšom celom čísle vášho škálovania monitora). Takže po zmene určite ukončite okná, ktoré máte nadmerne veľké (alebo zatvorte všetky okná pomocou `Ctrl + Alt + Del`!).

Môžete tiež rýchlo prechádzať medzi hlavnými pomermi škálovania monitora (1x, 1.25x, 1.6x, 2x, 3x, 4x) pomocou `Super + /`, ak chcete ísť vyššie, a `Super + Alt + /`, ak chcete ísť nižšie, alebo si jeden vybrať z panela monitora v hornom paneli. Tieto zmeny sa týkajú len monitora, na ktorý ste práve zameraní, takže obrazovka laptopu a externý displej môžu mať každý svoje vlastné škálovanie. Voľba sa uloží do `~/.config/hypr/monitors.lua` ako pravidlo `hl.monitor` pre daný monitor, takže pretrvá aj po reštarte a má prednosť pred `omarchy_monitor_scale`, ktoré zostáva škálovaním pre každý monitor bez vlastného pravidla. Keďže `GDK_SCALE` je jedna hodnota pre všetky obrazovky, tieto zmeny ju nastavia podľa monitora s najnižším škálovaním, takže aplikácie X11 budú na hustejšej obrazovke o niečo menšie, namiesto toho, aby boli na tej druhej nadmerne veľké.

### Zväčšenie alebo zmenšenie textu

Škálovanie monitora mení veľkosť všetkého. Ak chcete len väčší alebo menší _text_, je na to jediný ovládací prvok:

```
omarchy display text size 14
```

Ten berie veľkosť v pixeloch medzi 9 a 20 a spoločne posúva shell Omarchy, aplikácie GTK a váš terminál, takže celý desktop zostáva v proporciách. Spustite ho bez argumentu, aby ste videli, kde ste, a `omarchy display text size reset`, ak sa chcete vrátiť k predvolenej hodnote. Foot je jediný oneskorenec: nemá spôsob, ako znova načítať svoju konfiguráciu, takže spustené terminály si ponechajú starú veľkosť, kým neotvoríte nový.

### Rozšírenie a zrkadlenie displejov laptopu

Keď k laptopu pripojíte externú obrazovku, displej sa automaticky rozšíri. Môžete to však zmeniť na zrkadlenie pomocou _Spúšťač > Hardvér_ v menu Omarchy alebo `Super + Ctrl + Alt + Delete`. Je to obzvlášť užitočné, ak je tou externou obrazovkou projektor a chcete niečo ukázať, zatiaľ čo pracujete.

Keď používate rozšírenie, zatvorenie veka laptopu automaticky vypne internú obrazovku. Otvorenie veka ju znova zapne. Môžete to ovládať aj manuálne pomocou _Spúšťač > Hardvér_ v menu Omarchy alebo `Super + Ctrl + Delete`.

### Usporiadanie viacerých obrazoviek

Hyprland funguje skvele s viacerými obrazovkami. Prečítajte si viac o tom, ako ich rozložiť, v [dokumentácii Hyprlandu k monitorom](https://wiki.hypr.land/Configuring/Basics/Monitors/). V Omarchy sa tieto veci zapisujú do `~/.config/hypr/monitors.lua` ako položky `hl.monitor` — súbor sa dodáva s komentovanými príkladmi na pripnutie konkrétneho monitora k rozlíšeniu, pozícii a otočeniu.

Každý monitor má vlastné pracovné plochy 1 až 10, takže `Super + 1` vždy znamená prvú pracovnú plochu monitora, na ktorom ste. V pozadí Hyprland stále čísluje pracovné plochy naprieč všetkými monitormi: obrazovka vášho laptopu (alebo prvý monitor) dostane 1–10, ďalší monitor 11–20 a tak ďalej, a každý monitor si svoj blok ponechá pri každom pripojení. Používajte tieto čísla, ak píšete [pravidlá pracovných plôch](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) alebo pravidlá okien pre konkrétny monitor, takže pracovná plocha 12 je druhou pracovnou plochou vášho druhého monitora. `~/.local/state/omarchy/monitor-workspaces` uvádza, ktorý blok má každý monitor.

Klávesy so šípkami fungujú naprieč monitormi, ktoré vo vašom rozložení zdieľajú hranu. Obrazovky, ktoré sa dotýkajú len v rohu, alebo ktoré majú medzi sebou medzeru, nie sú susedmi, takže na prechod medzi nimi použite `Ctrl + Alt + Tab`.

| Klávesová skratka | Naprieč monitormi |
| --- | --- |
| `Super + Arrow` | Presunie zameranie na monitor na tej strane, keď v tom smere už nezostáva žiadne okno |
| `Super + Shift + Arrow` | Vymení sa s oknom na monitore na tej strane |
| `Super + Alt + Arrow` | Presunie okno do skupiny na monitore na tej strane |
| `Super + Shift + Ctrl + Arrow` | Presunie okno na monitor na tej strane, na pracovnú plochu, ktorú zobrazuje |
| `Super + Shift + Alt + Arrow` | Presunie pracovnú plochu na monitor na tej strane, pričom si ponechá svoje číslo, ak je voľné |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Presunie zameranie na ďalší alebo predchádzajúci monitor, bez ohľadu na rozloženie |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Zostane na monitore, na ktorom ste |

Môžete si tiež pozrieť [Hyprmon](https://github.com/erans/hyprmon/), ak by ste chceli TUI, ktoré vám pomôže s umiestnením viacerých obrazoviek.

### Ovládanie jasu

Jas monitora sa ovláda vyhradenými funkčnými klávesmi na zvýšenie/zníženie jasu. Ak pri stláčaní týchto klávesov podržíte shift, prejdete na maximálny alebo minimálny jas. Klávesy ovládajú displej, na ktorý ste zameraní, takže externé monitory, ktoré rozumejú DDC/CI, sa nastavujú rovnako ako obrazovka laptopu.

### Displeje Apple

Ak používate displej Apple, bežné klávesy na ovládanie jasu na klávesnici budú tiež automaticky fungovať, ak ste zameraní na displej Apple. Robí sa to prostredníctvom príkazu `asdcontrol`.

Upozorňujeme, že ak používate displej Apple 6K XDR, môžete vo výpise `hyprctl monitors` vidieť fantómovú obrazovku. Môžete ju vypnúť niečím ako `hl.monitor({ output = "DP-2", disabled = true })` cez _Nastavenie > Monitory_.

Na počítačoch Intel by ste sa k displejom Apple mali pripájať pomocou bežného kábla Thunderbolt. Na iných počítačoch bez Thunderboltu budete zvyčajne musieť použiť [kábel DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N), aby to fungovalo.
