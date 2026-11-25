# Monitory

Omarchy predvolene predpokladá, že používate displej triedy retina s podporou 2x škálovania. Práve to potrebujete na pekné, ostré programátorské fonty. Práve na to sú optimalizované takmer všetky nové prémiové laptopy s obrazovkami s vysokým rozlíšením. Práve to by ste chceli používať na 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) alebo 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Ak však nepoužívate displej s PPI 218 alebo vyšším, budete chcieť zmeniť nastavenia monitora. Ak máte napríklad 27" alebo 32" 4K displej, môžete si preň vybrať zlomkové škálovanie z panela monitora v hornom paneli alebo nastaviť predvolenú hodnotu pre každý monitor otvorením `~/.config/hypr/monitors.lua` a prepnutím na odporúčanie pre danú kombináciu:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Ak používate displej s rozlíšením 1080p alebo 1440p, pravdepodobne budete chcieť jednoducho používať škálovanie 1x a to isté pre aplikácie GTK a X11, takže môžete použiť:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Zmeny `GDK_SCALE` sa vzťahujú na aplikácie spustené po zmene (a GTK rešpektuje iba celé čísla, takže ho ponechajte na najbližšom celom čísle škálovania vášho monitora). Nezabudnite preto po zmene ukončiť okná, ktoré máte príliš veľké (alebo zatvorte všetky okná pomocou `Ctrl + Alt + Del`!).

Hlavnými pomermi škálovania monitora (1x, 1.25x, 1.6x, 2x, 3x, 4x) môžete tiež rýchlo prechádzať pomocou `Super + /` na zvýšenie a `Super + Alt + /` na zníženie alebo si jeden vybrať z panela monitora v hornom paneli. Tieto zmeny sa vzťahujú iba na monitor, na ktorý ste zameraní, takže obrazovka laptopu a externý displej môžu mať každý vlastné škálovanie. Panel tiež nastavuje rozlíšenie, obnovovaciu frekvenciu a otočenie každého monitora. Vaše voľby sa pre daný fyzický monitor ukladajú do `~/.local/state/omarchy/monitors/settings`, takže pretrvajú aj po reštarte a nasledujú monitor do ktoréhokoľvek portu alebo doku, do ktorého ho nabudúce zapojíte. Majú prednosť pred akýmkoľvek pravidlom pre ten istý monitor v `~/.config/hypr/monitors.lua`, ktoré Omarchy nikdy neupravuje. Ak by ste radšej nastavovali svoje monitory výlučne v tomto súbore, pridajte doň `omarchy_monitor_panel_settings = false` a zmeny z panela vydržia iba do opätovného načítania Hyprlandu. Keďže `GDK_SCALE` je jedna hodnota pre všetky obrazovky, zvolené škálovanie ju nastaví podľa monitora s najnižším škálovaním, takže aplikácie X11 budú na hustejšej obrazovke trochu malé namiesto toho, aby boli na tej druhej príliš veľké.

### Zväčšenie alebo zmenšenie textu

Škálovanie monitora mení veľkosť všetkého. Ak chcete iba väčší alebo menší _text_, existuje na to jediný ovládací prvok:

```
omarchy display text size 14
```

Prijíma veľkosť v pixeloch od 9 do 20 a spoločne mení prostredie Omarchy, aplikácie GTK aj váš terminál, takže celá pracovná plocha zostáva v správnych proporciách. Spustite ho bez argumentu, aby ste zistili, kde sa nachádzate, a `omarchy display text size reset`, aby ste sa vrátili k predvolenej hodnote. Foot je jediný oneskorenec: nemá spôsob, ako znovu načítať svoju konfiguráciu, takže spustené terminály si zachovajú svoju starú veľkosť, kým neotvoríte nový.

### Rozšírenie a zrkadlenie displejov laptopu

Keď k laptopu pripojíte externú obrazovku, displej sa automaticky rozšíri. Môžete to však zmeniť na zrkadlenie pomocou _Extend_ | _Mirror_ v paneli monitora v hornom paneli, _Trigger > Hardware_ v ponuke Omarchy alebo `Super + Ctrl + Alt + Delete`. Je to obzvlášť užitočné, ak je tou externou obrazovkou projektor a chcete niečo ukazovať, zatiaľ čo pracujete.

Keď používate rozšírenie, zatvorením veka laptopu sa interná obrazovka automaticky vypne. Otvorením veka sa znova zapne. Môžete to ovládať aj ručne pomocou _Trigger > Hardware_ v ponuke Omarchy alebo `Super + Ctrl + Delete`.

### Usporiadanie viacerých obrazoviek

Hyprland skvele funguje s viacerými obrazovkami. Panel monitora v hornom paneli ich kreslí tam, kde sa nachádzajú: potiahnite jeden k strane druhého, aby ste ho tam presunuli, a usporiadanie sa uloží spolu s ostatnými nastaveniami každého monitora. Všetko, čo panel nepokrýva, nájdete v [dokumentácii o monitoroch Hyprlandu](https://wiki.hypr.land/Configuring/Basics/Monitors/). V Omarchy patria do `~/.config/hypr/monitors.lua` ako položky `hl.monitor` — súbor sa dodáva so zakomentovanými príkladmi na ponechanie monitora vypnutého, režimy, ktoré panel neponúka, 10-bitové farby a variabilnú obnovovaciu frekvenciu.

Každý monitor má vlastných pracovných plôch 1 až 10, takže `Super + 1` vždy znamená prvú pracovnú plochu monitora, na ktorom sa nachádzate. Hyprland v pozadí stále čísluje pracovné plochy naprieč všetkými monitormi: obrazovka vášho laptopu (alebo prvý monitor) dostane 1–10, ďalší monitor 11–20 a tak ďalej a každý monitor si svoj blok zachová pri každom zapojení. Tieto čísla použite, ak píšete [pravidlá pracovných plôch](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) alebo pravidlá okien pre konkrétny monitor, takže pracovná plocha 12 je druhou pracovnou plochou vášho druhého monitora. `~/.local/state/omarchy/monitors/workspaces` uvádza, ktorý blok má každý monitor.

Klávesy so šípkami fungujú naprieč monitormi, ktoré vo vašom rozložení zdieľajú hranu. Obrazovky, ktoré sa dotýkajú iba v rohu alebo medzi ktorými je medzera, nie sú susedmi, takže na prechod medzi nimi použite `Ctrl + Alt + Tab`.

| Klávesová skratka | Medzi monitormi |
| --- | --- |
| `Super + Arrow` | Presunie zameranie na monitor na danej strane, keď v danom smere už nezostáva žiadne okno |
| `Super + Shift + Arrow` | Vymení sa s oknom na monitore na danej strane |
| `Super + Alt + Arrow` | Presunie okno do skupiny na monitore na danej strane |
| `Super + Shift + Ctrl + Arrow` | Presunie okno na monitor na danej strane, na pracovnú plochu, ktorú zobrazuje |
| `Super + Shift + Alt + Arrow` | Presunie pracovnú plochu na monitor na danej strane, pričom zachová jej číslo, ak je voľné |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Presunie zameranie na ďalší alebo predchádzajúci monitor, bez ohľadu na rozloženie |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Zostanú na monitore, na ktorom sa nachádzate |

Môžete si tiež pozrieť [Hyprmon](https://github.com/erans/hyprmon/), ak by ste chceli TUI, ktoré vám pomôže s umiestnením viacerých obrazoviek.

### Ovládanie jasu

Jas monitora sa ovláda vyhradenými funkčnými klávesmi na zvýšenie/zníženie jasu. Ak pri stláčaní týchto klávesov podržíte shift, prejdete na maximálny alebo minimálny jas. Klávesy ovládajú displej, na ktorý ste zameraní, takže externé monitory, ktoré komunikujú cez DDC/CI, sa nastavujú rovnako ako obrazovka laptopu.

### Displeje Apple

Ak používate displej Apple, bežné klávesy jasu na klávesnici budú tiež automaticky fungovať, ak ste zameraní na displej Apple. Robí sa to prostredníctvom príkazu `asdcontrol`.

Upozorňujeme, že ak používate displej Apple 6K XDR, môžete vo výpise `hyprctl monitors` vidieť fantómovú obrazovku. Môžete ju vypnúť niečím ako `hl.monitor({ output = "DP-2", disabled = true })` v `~/.config/hypr/monitors.lua`.

Na počítačoch Intel by ste sa k displejom Apple mali pripájať pomocou bežného kábla Thunderbolt. Na iných počítačoch bez Thunderboltu budete zvyčajne musieť použiť [kábel DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N), aby to fungovalo.
