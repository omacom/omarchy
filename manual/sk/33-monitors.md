# Monitory

Omarchy predvolene predpokladá, že používate displej triedy retina s podporou 2x škálovania. Práve to potrebujete na tie pekné, ostré programátorské fonty. Práve na to je optimalizovaná takmer každá nová prémiová notebooková obrazovka s vysokým rozlíšením. Práve to by ste chceli používať na 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) alebo 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Ak však nepoužívate displej s PPI 218 alebo vyšším, budete chcieť zmeniť nastavenia monitora. Ak máte napríklad 27" alebo 32" 4K, môžete preň vybrať zlomkové škálovanie z panela monitora na hornom paneli, alebo nastaviť predvolené pre každý monitor otvorením `~/.config/hypr/monitors.lua` a prepnutím na odporúčanie pre danú kombináciu:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Ak používate displej s rozlíšením 1080p alebo 1440p, pravdepodobne budete chcieť jednoducho používať 1x škálovanie, a rovnako aj pre aplikácie GTK a X11, takže môžete použiť:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Zmeny `GDK_SCALE` sa vzťahujú na aplikácie spustené po zmene (a GTK rešpektuje len celé čísla, takže ho ponechajte na najbližšom celom čísle vášho škálovania monitora). Takže po zmene nezabudnite ukončiť okná, ktoré máte príliš veľké (alebo zatvorte všetky okná pomocou `Ctrl + Alt + Del`!).

Môžete tiež rýchlo prechádzať medzi hlavnými pomermi škálovania monitora (1x, 1.25x, 1.6x, 2x, 3x, 4x) pomocou `Super + /` na zvýšenie a `Super + Alt + /` na zníženie, alebo si jeden vybrať z panela monitora na hornom paneli. Tieto menia len monitor, na ktorý ste zameraní, takže obrazovka notebooku a externý displej môžu mať každý svoje vlastné škálovanie. Panel tiež nastavuje rozlíšenie každého monitora. Vaše voľby sa pre daný fyzický monitor ukladajú do `~/.local/state/omarchy/monitors/settings`, takže pretrvajú aj po reštarte a nasledujú monitor do ktoréhokoľvek portu alebo doku, do ktorého ho nabudúce zapojíte. Majú prednosť pred akýmkoľvek pravidlom pre ten istý monitor v `~/.config/hypr/monitors.lua`, ktoré Omarchy nikdy neupravuje. Keďže `GDK_SCALE` je jedna hodnota pre všetky obrazovky, zvolené škálovanie ho nastavuje z monitora s najnižším škálovaním, takže aplikácie X11 vychádzajú na hustejšej obrazovke trochu malé, namiesto toho, aby boli na tej druhej príliš veľké.

### Zväčšenie alebo zmenšenie textu

Škálovanie monitora mení veľkosť všetkého. Ak chcete len väčší alebo menší _text_, existuje na to jediný ovládací prvok:

```
omarchy display text size 14
```

Ten prijíma veľkosť v pixeloch medzi 9 a 20 a posúva prostredie Omarchy, aplikácie GTK a váš terminál spoločne, takže celá pracovná plocha zostáva v pomere. Spustite ho bez argumentu, aby ste videli, kde sa nachádzate, a `omarchy display text size reset` na návrat k predvolenej hodnote. Foot je jediný oneskorenec: nemá spôsob, ako znova načítať svoju konfiguráciu, takže spustené terminály si ponechajú svoju starú veľkosť, kým neotvoríte nový.

### Rozšírenie a zrkadlenie displejov notebooku

Keď k notebooku pripojíte externú obrazovku, displej sa automaticky rozšíri. Môžete to však zmeniť na zrkadlenie pomocou _Trigger > Hardware_ v menu Omarchy alebo `Super + Ctrl + Alt + Delete`. To je obzvlášť užitočné, ak je tá externá obrazovka projektor a chcete niečo ukázať počas práce.

Keď rozširujete, zatvorenie veka notebooku automaticky vypne internú obrazovku. Otvorenie veka ju znova zapne. Môžete to ovládať aj manuálne pomocou _Trigger > Hardware_ v menu Omarchy alebo `Super + Ctrl + Delete`.

### Usporiadanie viacerých obrazoviek

Hyprland skvele funguje s viacerými obrazovkami. Panel monitora na hornom paneli ich kreslí tam, kde sedia: potiahnite jednu k strane druhej, aby ste ju tam presunuli, a usporiadanie sa uloží spolu s ostatnými nastaveniami každého monitora. Pre všetko, čo panel nepokrýva, si prečítajte viac o tom, ako ich rozložiť, v [dokumentácii k monitorom Hyprlandu](https://wiki.hypr.land/Configuring/Basics/Monitors/). V Omarchy sa tieto zadávajú do `~/.config/hypr/monitors.lua` ako položky `hl.monitor` — súbor sa dodáva s komentovanými príkladmi na pripnutie konkrétneho monitora na rozlíšenie, pozíciu a otočenie.

Každý monitor má svoje vlastné pracovné plochy 1 až 10, takže `Super + 1` vždy znamená prvú pracovnú plochu monitora, na ktorom sa nachádzate. V zákulisí Hyprland stále čísluje pracovné plochy naprieč všetkými monitormi: obrazovka vášho notebooku (alebo prvý monitor) dostane 1–10, ďalší monitor 11–20 a tak ďalej, a každý monitor si svoj blok ponechá zakaždým, keď ho zapojíte. Použite tieto čísla, ak píšete [pravidlá pracovných plôch](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) alebo pravidlá okien pre konkrétny monitor, takže pracovná plocha 12 je druhá pracovná plocha vášho druhého monitora. `~/.local/state/omarchy/monitors/workspaces` uvádza, ktorý blok má každý monitor.

Klávesy so šípkami fungujú naprieč monitormi, ktoré zdieľajú hranu vo vašom rozložení. Obrazovky, ktoré sa dotýkajú len v rohu, alebo ktoré majú medzi sebou medzeru, nie sú susedmi, takže na prechod medzi nimi použite `Ctrl + Alt + Tab`.

| Klávesová skratka | Naprieč monitormi |
| --- | --- |
| `Super + Arrow` | Presunie zameranie na monitor na danej strane, keď už v danom smere nezostáva žiadne okno |
| `Super + Shift + Arrow` | Vymení s oknom na monitore na danej strane |
| `Super + Alt + Arrow` | Presunie okno do skupiny na monitore na danej strane |
| `Super + Shift + Ctrl + Arrow` | Presunie okno na monitor na danej strane, na pracovnú plochu, ktorú zobrazuje |
| `Super + Shift + Alt + Arrow` | Presunie pracovnú plochu na monitor na danej strane, pričom si ponechá svoje číslo, ak je voľné |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Presunie zameranie na ďalší alebo predchádzajúci monitor, bez ohľadu na rozloženie |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Zostanú na monitore, na ktorom sa nachádzate |

Môžete si tiež pozrieť [Hyprmon](https://github.com/erans/hyprmon/), ak by ste chceli TUI, ktoré vám pomôže s polohovaním viacerých obrazoviek.

### Ovládanie jasu

Jas monitora sa ovláda vyhradenými funkčnými klávesmi na zvýšenie/zníženie jasu. Ak pri stlačení týchto klávesov podržíte shift, prejdete na maximálny alebo minimálny jas. Klávesy ovládajú displej, na ktorý ste zameraní, takže externé monitory, ktoré komunikujú cez DDC/CI, sa nastavujú rovnakým spôsobom ako obrazovka notebooku.

### Displeje Apple

Ak používate displej Apple, bežné klávesy na ovládanie jasu na klávesnici budú tiež automaticky fungovať, ak ste zameraní na displej Apple. Robí sa to prostredníctvom príkazu `asdcontrol`.

Upozorňujeme, že ak používate displej Apple 6K XDR, môžete vo výpise `hyprctl monitors` vidieť fantómovú obrazovku. Môžete ju vypnúť pomocou niečoho ako `hl.monitor({ output = "DP-2", disabled = true })` v `~/.config/hypr/monitors.lua`.

Na počítačoch Intel by ste sa k displejom Apple mali pripájať pomocou bežného kábla Thunderbolt. Na iných počítačoch bez Thunderboltu budete zvyčajne musieť použiť [kábel DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N), aby to fungovalo.
