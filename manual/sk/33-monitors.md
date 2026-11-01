# Monitory

Omarchy predvolene predpokladá, že používate displej triedy retina s podporou 2x škálovania. Práve to potrebujete, aby ste získali pekné, ostré programátorské fonty. Práve na to je optimalizovaná takmer každá nová prémiová notebooková obrazovka s vysokým rozlíšením. Práve to by ste chceli používať na 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) alebo 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Ak však nepoužívate displej s PPI 218 alebo vyšším, budete chcieť nastavenia monitora zmeniť. Ak máte napríklad 27" alebo 32" 4K, môžete preň vybrať zlomkové škálovanie z panela monitora v hornej lište, alebo nastaviť predvolené pre každý monitor otvorením `~/.config/hypr/monitors.lua` a prepnutím na odporúčanie pre danú kombináciu:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Ak používate displej s rozlíšením 1080p alebo 1440p, pravdepodobne budete chcieť použiť škálovanie 1x, a to isté aj pre aplikácie GTK a X11, takže môžete použiť:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Zmeny `GDK_SCALE` sa vzťahujú na aplikácie spustené po zmene (a GTK rešpektuje iba celé čísla, takže ho ponechajte na celom čísle najbližšom k škálovaniu vášho monitora). Preto po zmene určite ukončite okná, ktoré máte príliš veľké (alebo zatvorte všetky okná pomocou `Ctrl + Alt + Del`!).

Môžete tiež rýchlo prechádzať medzi hlavnými pomermi škálovania monitora (1x, 1.25x, 1.6x, 2x, 3x, 4x) pomocou `Super + /` na zvýšenie a `Super + Alt + /` na zníženie, alebo si vybrať jeden z panela monitora v hornej lište. Tieto zmeny sa vzťahujú iba na monitor, na ktorý ste zameraní, takže obrazovka notebooku a externý displej môžu mať každé svoje vlastné škálovanie. Panel tiež nastavuje rozlíšenie, obnovovaciu frekvenciu a otočenie každého monitora. Vaše voľby sa pre daný fyzický monitor ukladajú do `~/.local/state/omarchy/monitors/settings`, takže pretrvajú aj po reštarte a sledujú monitor do portu alebo doku, do ktorého ho nabudúce zapojíte. Majú prednosť pred akýmkoľvek pravidlom pre ten istý monitor v `~/.config/hypr/monitors.lua`, ktoré Omarchy nikdy neupravuje. Ak by ste radšej nastavovali svoje monitory výlučne v tomto súbore, pridajte doň `omarchy_monitor_panel_settings = false` a zmeny z panela vydržia iba do opätovného načítania Hyprlandu. Keďže `GDK_SCALE` je jedna hodnota pre všetky obrazovky, zvolené škálovanie ho nastaví podľa monitora s najnižším škálovaním, takže aplikácie X11 vyjdú na hustejšej obrazovke trochu malé namiesto príliš veľkých na tej druhej.

### Zväčšenie alebo zmenšenie textu

Škálovanie monitora mení veľkosť všetkého. Ak chcete iba väčší alebo menší _text_, existuje na to jediný ovládací prvok:

```
omarchy display text size 14
```

Ten prijíma veľkosť v pixeloch medzi 9 a 20 a posúva shell Omarchy, aplikácie GTK a váš terminál spoločne, takže celý desktop zostáva v proporcii. Spustite ho bez argumentu, aby ste videli, kde sa nachádzate, a `omarchy display text size reset` na návrat k predvolenej hodnote. Foot je jediný oneskorenec: nemá spôsob, ako znova načítať svoju konfiguráciu, takže spustené terminály si ponechajú starú veľkosť, kým neotvoríte nový.

### Rozšírenie a zrkadlenie displejov notebooku

Keď k notebooku pripojíte externú obrazovku, displej sa automaticky rozšíri. Môžete to však zmeniť na zrkadlenie pomocou _Trigger > Hardware_ v ponuke Omarchy alebo `Super + Ctrl + Alt + Delete`. To je obzvlášť užitočné, ak je tou externou obrazovkou projektor a chcete niečo ukázať počas práce.

Keď používate rozšírenie, zatvorenie veka notebooku automaticky vypne internú obrazovku. Otvorenie veka ju znova zapne. Môžete to tiež ovládať manuálne pomocou _Trigger > Hardware_ v ponuke Omarchy alebo `Super + Ctrl + Delete`.

### Usporiadanie viacerých obrazoviek

Hyprland skvele funguje s viacerými obrazovkami. Panel monitora v hornej lište ich kreslí tam, kde sedia: potiahnite jeden k boku druhého, aby ste ho tam presunuli, a usporiadanie sa uloží spolu s ostatnými nastaveniami každého monitora. Všetko, čo panel nepokrýva, si prečítajte v [dokumentácii Hyprlandu o monitoroch](https://wiki.hypr.land/Configuring/Basics/Monitors/). V Omarchy patria do `~/.config/hypr/monitors.lua` ako položky `hl.monitor` — súbor sa dodáva so zakomentovanými príkladmi pre ponechanie monitora vypnutého, režimy, ktoré panel neponúka, 10-bitovú farbu a variabilnú obnovovaciu frekvenciu.

Každý monitor má svoje vlastné pracovné plochy 1 až 10, takže `Super + 1` vždy znamená prvú pracovnú plochu monitora, na ktorom ste. V zákulisí Hyprland stále čísluje pracovné plochy naprieč všetkými monitormi: vaša obrazovka notebooku (alebo prvý monitor) dostane 1–10, ďalší monitor 11–20 a tak ďalej, a každý monitor si zachová svoj blok pri každom zapojení. Tieto čísla používajte, ak píšete [pravidlá pracovných plôch](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) alebo pravidlá okien pre konkrétny monitor, takže pracovná plocha 12 je druhá pracovná plocha vášho druhého monitora. `~/.local/state/omarchy/monitors/workspaces` uvádza, ktorý blok má každý monitor.

Klávesy so šípkami fungujú naprieč monitormi, ktoré v rozložení zdieľajú hranu. Obrazovky, ktoré sa dotýkajú iba v rohu alebo medzi ktorými je medzera, nie sú susedmi, takže na prechod medzi nimi použite `Ctrl + Alt + Tab`.

| Klávesová skratka | Naprieč monitormi |
| --- | --- |
| `Super + Arrow` | Presunie zameranie na monitor na tej strane, keď v danom smere už nezostane žiadne okno |
| `Super + Shift + Arrow` | Vymení sa s oknom na monitore na tej strane |
| `Super + Alt + Arrow` | Presunie okno do skupiny na monitore na tej strane |
| `Super + Shift + Ctrl + Arrow` | Presunie okno na monitor na tej strane, na pracovnú plochu, ktorú zobrazuje |
| `Super + Shift + Alt + Arrow` | Presunie pracovnú plochu na monitor na tej strane, pričom si zachová svoje číslo, ak je voľné |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Presunie zameranie na ďalší alebo predchádzajúci monitor, bez ohľadu na rozloženie |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Zostanú na monitore, na ktorom ste |

Môžete si tiež pozrieť [Hyprmon](https://github.com/erans/hyprmon/), ak by ste chceli TUI, ktoré vám pomôže s umiestnením viacerých obrazoviek.

### Ovládanie jasu

Jas monitora sa ovláda vyhradenými funkčnými klávesmi na zvýšenie/zníženie jasu. Ak pri stláčaní týchto klávesov podržíte shift, prejdete na maximálny alebo minimálny jas. Klávesy ovládajú displej, na ktorý ste zameraní, takže externé monitory, ktoré rozumejú DDC/CI, sa nastavujú rovnakým spôsobom ako obrazovka notebooku.

### Displeje Apple

Ak používate displej Apple, bežné klávesy klávesnice na ovládanie jasu budú tiež automaticky fungovať, ak ste zameraní na displej Apple. Robí sa to prostredníctvom príkazu `asdcontrol`.

Všimnite si, že ak používate displej Apple 6K XDR, môžete vo výpise `hyprctl monitors` vidieť fantómovú obrazovku. Môžete ju vypnúť niečím ako `hl.monitor({ output = "DP-2", disabled = true })` v `~/.config/hypr/monitors.lua`.

Na počítačoch Intel by ste sa k displejom Apple mali pripájať pomocou bežného kábla Thunderbolt. Na iných počítačoch bez Thunderboltu budete zvyčajne musieť použiť [kábel DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N), aby to fungovalo.
