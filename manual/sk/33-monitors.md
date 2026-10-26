# Monitory

Omarchy predvolene predpokladá, že používate displej triedy retina s podporou 2x škálovania. To potrebujete na tie pekné, ostré programátorské fonty. Na to sú optimalizované takmer všetky nové prémiové notebooky s obrazovkami s vysokým rozlíšením. To by ste chceli používať na 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) alebo 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Ak však nepoužívate displej s PPI 218 alebo vyšším, budete chcieť zmeniť nastavenia monitora. Ak máte napríklad 27" alebo 32" 4K, môžete použiť zlomkové škálovanie tak, že otvoríte `~/.config/hypr/monitors.lua` (cez _Setup > Monitors_ v menu Omarchy) a prepnete na odporúčanie pre túto kombináciu:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Ak používate displej s rozlíšením 1080p alebo 1440p, pravdepodobne budete chcieť jednoducho použiť 1x škálovanie, takže môžete použiť:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Zmeny `GDK_SCALE` sa vzťahujú na aplikácie spustené po zmene (a GTK rešpektuje iba celé čísla, takže ho ponechajte na najbližšom celom čísle vášho škálovania monitora). Preto po zmene ukončite okná, ktoré máte príliš veľké (alebo zatvorte všetky okná pomocou `Ctrl + Alt + Del`!).

Pomocou `Super + /` na prechod vyššie a `Super + Alt + /` na prechod nižšie môžete tiež rýchlo prechádzať hlavnými pomermi škálovania monitora (1x, 1.25x, 1.6x, 2x, 3x, 4x). Ak máte predvolenú konfiguráciu, tieto zmeny pretrvajú aj po reštarte.

### Zväčšenie alebo zmenšenie textu

Škálovanie monitora mení veľkosť všetkého. Ak chcete len väčší alebo menší _text_, existuje na to jediný ovládací prvok:

```
omarchy display text size 14
```

Ten prijíma veľkosť v pixeloch od 9 do 20 a posúva spolu shell Omarchy, aplikácie GTK a váš terminál, takže celý desktop zostáva v proporciách. Spustite ho bez argumentu, aby ste videli, kde sa nachádzate, a pomocou `omarchy display text size reset` sa vrátite na predvolenú hodnotu. Foot je jediný oneskorenec: nemá spôsob, ako znova načítať svoju konfiguráciu, takže bežiace terminály si zachovajú starú veľkosť, kým neotvoríte nový.

### Rozšírenie a zrkadlenie displejov notebooku

Keď k notebooku pripojíte externú obrazovku, displej sa automaticky rozšíri. Pomocou _Trigger > Hardware_ v menu Omarchy alebo `Super + Ctrl + Alt + Delete` to však môžete namiesto toho zmeniť na zrkadlenie. To je obzvlášť užitočné, ak je tou externou obrazovkou projektor a chcete počas práce niečo ukazovať.

Keď používate rozšírenie, zatvorením veka notebooku sa interná obrazovka automaticky vypne. Otvorením veka sa znova zapne. Môžete to ovládať aj manuálne pomocou _Trigger > Hardware_ v menu Omarchy alebo `Super + Ctrl + Delete`.

### Usporiadanie viacerých obrazoviek

Hyprland funguje skvele s viacerými obrazovkami. Viac o tom, ako ich rozložiť, si prečítajte v [dokumentácii Hyprlandu k monitorom](https://wiki.hypr.land/Configuring/Basics/Monitors/). V Omarchy patria do `~/.config/hypr/monitors.lua` ako položky `hl.monitor` — súbor sa dodáva s komentovanými príkladmi na pripnutie konkrétneho monitora na rozlíšenie, pozíciu a otočenie.

Každý monitor má vlastné pracovné plochy 1 až 10, takže `Super + 1` vždy znamená prvú pracovnú plochu monitora, na ktorom sa nachádzate. V pozadí Hyprland stále čísluje pracovné plochy naprieč všetkými monitormi: obrazovka vášho notebooku (alebo prvý monitor) dostane 1–10, ďalší monitor 11–20 a tak ďalej a každý monitor si svoj blok zachová pri každom pripojení. Tieto čísla použite, ak píšete [pravidlá pracovných plôch](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) alebo pravidlá okien pre konkrétny monitor, takže pracovná plocha 12 je druhou pracovnou plochou vášho druhého monitora. `~/.local/state/omarchy/monitor-workspaces` uvádza, ktorý blok má každý monitor.

Klávesy so šípkami fungujú naprieč monitormi, ktoré vo vašom rozložení zdieľajú hranu. Obrazovky, ktoré sa dotýkajú len v rohu alebo medzi ktorými je medzera, nie sú susedmi, takže na prechod medzi nimi použite `Ctrl + Alt + Tab`.

| Klávesová skratka | Naprieč monitormi |
| --- | --- |
| `Super + Arrow` | Presunie zameranie na monitor na tej strane, keď už tým smerom nezostáva žiadne okno |
| `Super + Shift + Arrow` | Vymení s oknom na monitore na tej strane |
| `Super + Alt + Arrow` | Presunie okno do skupiny na monitore na tej strane |
| `Super + Shift + Ctrl + Arrow` | Presunie okno na monitor na tej strane, na pracovnú plochu, ktorú zobrazuje |
| `Super + Shift + Alt + Arrow` | Presunie pracovnú plochu na monitor na tej strane, pričom si zachová svoje číslo, ak je voľné |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Presunie zameranie na ďalší alebo predchádzajúci monitor bez ohľadu na rozloženie |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Zostanú na monitore, na ktorom sa nachádzate |

Pozrieť si môžete aj [Hyprmon](https://github.com/erans/hyprmon/), ak by ste chceli TUI, ktoré vám pomôže s umiestnením viacerých obrazoviek.

### Ovládanie jasu

Jas monitora sa ovláda vyhradenými funkčnými klávesmi na zvýšenie a zníženie jasu. Ak pri stláčaní týchto klávesov podržíte Shift, prejdete na maximálny alebo minimálny jas. Klávesy ovládajú displej, na ktorý ste zameraní, takže externé monitory, ktoré komunikujú cez DDC/CI, sa nastavujú rovnakým spôsobom ako obrazovka notebooku.

### Displeje Apple

Ak používate displej Apple, bežné klávesy klávesnice na ovládanie jasu budú tiež automaticky fungovať, ak ste zameraní na displej Apple. Robí sa to prostredníctvom príkazu `asdcontrol`.

Upozorňujeme, že ak používate displej Apple 6K XDR, môžete vo výpise `hyprctl monitors` vidieť fantómovú obrazovku. Môžete ju vypnúť niečím ako `hl.monitor({ output = "DP-2", disabled = true })` cez _Setup > Monitors_.

Na počítačoch Intel by ste sa k displejom Apple mali pripájať bežným káblom Thunderbolt. Na iných počítačoch bez Thunderboltu budete zvyčajne musieť použiť [kábel DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N), aby to fungovalo.
