# Monitory

Omarchy predvolene predpokladá, že používate displej triedy retina s podporou škálovania 2x. To potrebujete na tie pekné, ostré programátorské fonty. Práve na to je optimalizovaná takmer každá nová prémiová zostava laptopov s obrazovkami s vysokým rozlíšením. Práve to by ste chceli používať na 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) alebo 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Ak však nepoužívate displej s PPI 218 alebo vyšším, budete chcieť zmeniť nastavenia monitora. Ak máte napríklad 27" alebo 32" 4K, môžete použiť zlomkové škálovanie tak, že otvoríte `~/.config/hypr/monitors.lua` (cez _Nastavenie > Monitory_ v menu Omarchy) a prepnete na odporúčanie pre danú kombináciu:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Ak používate displej s rozlíšením 1080p alebo 1440p, pravdepodobne budete chcieť použiť jednoducho škálovanie 1x, takže môžete použiť:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Zmeny `GDK_SCALE` sa vzťahujú na aplikácie spustené po zmene (a GTK rešpektuje iba celé čísla, takže ho ponechajte na najbližšom celom čísle vášho škálovania monitora). Takže po zmene nezabudnite ukončiť okná, ktoré máte nadmerne veľké (alebo zatvorte všetky okná pomocou `Ctrl + Alt + Del`!).

Hlavné pomery škálovania monitora (1x, 1.25x, 1.6x, 2x, 3x, 4x) môžete tiež rýchlo prechádzať pomocou `Super + /`, ak chcete ísť vyššie, a `Super + Alt + /`, ak chcete ísť nižšie, alebo si jeden vyberte z panela monitora v hornej lište. Tieto menia iba monitor, na ktorý ste zameraní, takže obrazovka laptopu a externý displej môžu mať každý svoje vlastné škálovanie. Voľba sa uloží do `~/.config/hypr/monitors.lua` ako pravidlo `hl.monitor` pre daný monitor, takže pretrvá aj po reštarte a má prednosť pred `omarchy_monitor_scale`, ktoré zostáva škálovaním pre každý monitor bez vlastného pravidla.

### Zväčšenie alebo zmenšenie textu

Škálovanie monitora mení veľkosť všetkého. Ak chcete len väčší alebo menší _text_, je na to jediný ovládací prvok:

```
omarchy display text size 14
```

Ten berie veľkosť v pixeloch od 9 do 20 a hýbe shellom Omarchy, aplikáciami GTK a vaším terminálom spoločne, takže celá pracovná plocha zostáva v správnych proporciách. Spustite ho bez argumentu, ak chcete vidieť, na čom ste, a `omarchy display text size reset`, ak sa chcete vrátiť k predvolenému nastaveniu. Foot je jediný oneskorenec: nemá spôsob, ako znova načítať svoju konfiguráciu, takže spustené terminály si ponechajú starú veľkosť, kým neotvoríte nový.

### Rozšírenie a zrkadlenie displejov laptopu

Keď k laptopu pripojíte externú obrazovku, displej sa automaticky rozšíri. To však môžete namiesto toho zmeniť na zrkadlenie pomocou _Spúšťač > Hardvér_ v menu Omarchy alebo `Super + Ctrl + Alt + Delete`. To je obzvlášť užitočné, ak je tou externou obrazovkou projektor a chcete niečo ukázať počas práce.

Keď používate rozšírenie, zatvorenie veka laptopu automaticky vypne internú obrazovku. Otvorenie veka ju znova zapne. Môžete to ovládať aj ručne pomocou _Spúšťač > Hardvér_ v menu Omarchy alebo `Super + Ctrl + Delete`.

### Usporiadanie viacerých obrazoviek

Hyprland funguje skvele s viacerými obrazovkami. Viac o tom, ako ich rozložiť, si prečítajte v [dokumentácii Hyprland k monitorom](https://wiki.hypr.land/Configuring/Basics/Monitors/). V Omarchy patria do `~/.config/hypr/monitors.lua` ako položky `hl.monitor` — súbor sa dodáva s komentovanými príkladmi na pripnutie konkrétneho monitora na rozlíšenie, pozíciu a otočenie.

Každý monitor má svoje vlastné pracovné plochy 1 až 10, takže `Super + 1` vždy znamená prvú pracovnú plochu monitora, na ktorom ste. V pozadí Hyprland stále čísluje pracovné plochy naprieč všetkými monitormi: obrazovka vášho laptopu (alebo prvý monitor) dostane 1–10, ďalší monitor 11–20 atď. a každý monitor si svoj blok zachová pri každom pripojení. Tieto čísla použite, ak píšete [pravidlá pracovných plôch](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) alebo pravidlá okien pre konkrétny monitor, takže pracovná plocha 12 je druhou pracovnou plochou vášho druhého monitora. `~/.local/state/omarchy/monitor-workspaces` uvádza, ktorý blok má každý monitor.

Klávesy so šípkami fungujú naprieč monitormi, ktoré vo vašom rozložení zdieľajú hranu. Obrazovky, ktoré sa dotýkajú len v rohu alebo medzi ktorými je medzera, nie sú susedmi, takže na prechod medzi nimi použite `Ctrl + Alt + Tab`.

| Klávesová skratka | Naprieč monitormi |
| --- | --- |
| `Super + Arrow` | Presunie zameranie na monitor na danej strane, keď už v danom smere nezostáva žiadne okno |
| `Super + Shift + Arrow` | Vymení sa s oknom na monitore na danej strane |
| `Super + Alt + Arrow` | Presunie okno do skupiny na monitore na danej strane |
| `Super + Shift + Ctrl + Arrow` | Presunie okno na monitor na danej strane, na pracovnú plochu, ktorú zobrazuje |
| `Super + Shift + Alt + Arrow` | Presunie pracovnú plochu na monitor na danej strane, pričom si ponechá svoje číslo, ak je voľné |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Presunie zameranie na ďalší alebo predchádzajúci monitor, bez ohľadu na rozloženie |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Zostanú na monitore, na ktorom ste |

Môžete si tiež pozrieť [Hyprmon](https://github.com/erans/hyprmon/), ak by ste chceli TUI, ktoré vám pomôže s umiestnením viacerých obrazoviek.

### Ovládanie jasu

Jas monitora sa ovláda vyhradenými funkčnými klávesmi na zvýšenie/zníženie jasu. Ak pri stláčaní týchto klávesov podržíte Shift, prejdete na maximálny alebo minimálny jas. Klávesy ovládajú displej, na ktorý ste zameraní, takže externé monitory, ktoré rozumejú DDC/CI, sa nastavujú rovnako ako obrazovka laptopu.

### Displeje Apple

Ak používate displej Apple, bežné klávesy na ovládanie jasu na klávesnici budú automaticky fungovať aj vtedy, ak ste zameraní na displej Apple. Deje sa to prostredníctvom príkazu `asdcontrol`.

Upozorňujeme, že ak používate displej Apple 6K XDR, môžete vo výpise `hyprctl monitors` vidieť fantómovú obrazovku. Môžete ju vypnúť niečím ako `hl.monitor({ output = "DP-2", disabled = true })` cez _Nastavenie > Monitory_.

Na počítačoch Intel by ste sa k displejom Apple mali pripájať pomocou bežného kábla Thunderbolt. Na iných počítačoch bez Thunderboltu budete zvyčajne musieť použiť [kábel DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N), aby to fungovalo.
