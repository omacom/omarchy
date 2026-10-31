# Monitory

Omarchy ve výchozím nastavení předpokládá, že používáte displej třídy retina schopný 2x škálování. Právě to potřebujete, abyste měli ta pěkná, ostrá programátorská písma. Právě na to je optimalizována téměř většina nových prémiových notebooků s obrazovkami s vysokým rozlišením. Právě to byste chtěli používat na 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) nebo 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Pokud ale nepoužíváte displej s PPI 218 nebo vyšším, budete chtít změnit nastavení monitoru. Pokud máte například 27" nebo 32" 4K, můžete použít zlomkové škálování tak, že otevřete `~/.config/hypr/monitors.lua` (přes _Nastavení > Monitory_ v nabídce Omarchy) a přepnete na doporučení pro danou kombinaci:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Pokud používáte displej s rozlišením 1080p nebo 1440p, pravděpodobně budete chtít prostě používat 1x škálování, takže můžete použít:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Změny `GDK_SCALE` se projeví u aplikací spuštěných po změně (a GTK respektuje pouze celá čísla, takže ho ponechte na nejbližším celém čísle vašeho škálování monitoru). Po změně tedy nezapomeňte ukončit okna, která máte nadměrně velká (nebo zavřete všechna okna pomocí `Ctrl + Alt + Del`!).

Pomocí `Super + /` můžete také rychle procházet hlavní poměry škálování monitoru (1x, 1.25x, 1.6x, 2x, 3x, 4x) směrem nahoru a pomocí `Super + Alt + /` směrem dolů, nebo si jeden vybrat z panelu monitoru v horní liště. Ty mění pouze monitor, na který jste zaměřeni, takže obrazovka notebooku a externí displej mohou mít každý své vlastní škálování. Volba se uloží do `~/.config/hypr/monitors.lua` jako pravidlo `hl.monitor` pro daný monitor, takže přetrvá i po restartu a má přednost před `omarchy_monitor_scale`, které zůstává škálováním pro každý monitor bez vlastního pravidla. Protože `GDK_SCALE` je jedna hodnota pro všechny obrazovky, tyto změny ji nastavují podle monitoru s nejnižším škálováním, takže aplikace X11 vyjdou na hustší obrazovce trochu malé, místo aby byly na té druhé nadměrně velké.

### Zvětšení nebo zmenšení textu

Škálování monitoru mění velikost všeho. Pokud chcete jen větší nebo menší _text_, je na to jediný ovladač:

```
omarchy display text size 14
```

Ten přijímá velikost v pixelech od 9 do 20 a mění společně shell Omarchy, aplikace GTK i váš terminál, takže celá pracovní plocha zůstane v poměru. Spusťte ho bez argumentu, abyste viděli, kde se nacházíte, a `omarchy display text size reset` pro návrat k výchozímu nastavení. Foot je jediný opozdilec: nemá způsob, jak znovu načíst svou konfiguraci, takže spuštěné terminály si ponechají svou starou velikost, dokud neotevřete nový.

### Rozšíření a zrcadlení displejů notebooku

Když připojíte k notebooku externí obrazovku, displej se automaticky rozšíří. Můžete to ale změnit na zrcadlení pomocí _Spouštěče > Hardware_ v nabídce Omarchy nebo `Super + Ctrl + Alt + Delete`. To je obzvlášť užitečné, pokud je tou externí obrazovkou projektor a chcete něco ukazovat při práci.

Když používáte rozšíření, zavření víka notebooku automaticky vypne interní obrazovku. Otevření víka ji znovu zapne. Můžete to také ovládat ručně pomocí _Spouštěče > Hardware_ v nabídce Omarchy nebo `Super + Ctrl + Delete`.

### Uspořádání více obrazovek

Hyprland skvěle funguje s více obrazovkami. Více o tom, jak je rozložit, si přečtěte v [dokumentaci Hyprlandu k monitorům](https://wiki.hypr.land/Configuring/Basics/Monitors/). V Omarchy se tyto údaje zapisují do `~/.config/hypr/monitors.lua` jako položky `hl.monitor` — soubor se dodává s okomentovanými příklady pro přiřazení konkrétního monitoru k rozlišení, poloze a otočení.

Každý monitor má svých vlastních 1 až 10 pracovních ploch, takže `Super + 1` vždy znamená první pracovní plochu monitoru, na kterém se nacházíte. V pozadí Hyprland stále čísluje pracovní plochy napříč všemi monitory: obrazovka vašeho notebooku (nebo první monitor) dostane 1–10, další monitor 11–20 a tak dále, a každý monitor si svůj blok ponechá pokaždé, když ho připojíte. Tato čísla použijte, pokud píšete [pravidla pracovních ploch](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) nebo pravidla oken pro konkrétní monitor, takže pracovní plocha 12 je druhou pracovní plochou vašeho druhého monitoru. `~/.local/state/omarchy/monitor-workspaces` uvádí, který blok má každý monitor.

Klávesy se šipkami fungují napříč monitory, které ve vašem rozložení sdílejí hranu. Obrazovky, které se dotýkají pouze v rohu nebo mezi nimiž je mezera, nejsou sousedé, takže pro přechod mezi nimi použijte `Ctrl + Alt + Tab`.

| Klávesová zkratka | Napříč monitory |
| --- | --- |
| `Super + Arrow` | Přesune zaměření na monitor na dané straně, jakmile v daném směru už nezbývá žádné okno |
| `Super + Shift + Arrow` | Prohodí s oknem na monitoru na dané straně |
| `Super + Alt + Arrow` | Přesune okno do skupiny na monitoru na dané straně |
| `Super + Shift + Ctrl + Arrow` | Přesune okno na monitor na dané straně, na pracovní plochu, kterou zobrazuje |
| `Super + Shift + Alt + Arrow` | Přesune pracovní plochu na monitor na dané straně a ponechá její číslo, pokud je volné |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Přesune zaměření na další nebo předchozí monitor, bez ohledu na rozložení |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Zůstávají na monitoru, na kterém se nacházíte |

Můžete se také podívat na [Hyprmon](https://github.com/erans/hyprmon/), pokud byste chtěli TUI, které vám pomůže s umístěním více obrazovek.

### Ovládání jasu

Jas monitoru se ovládá vyhrazenými funkčními klávesami pro zvýšení/snížení jasu. Pokud při stisknutí těchto kláves podržíte Shift, přejdete na maximální nebo minimální jas. Klávesy ovládají displej, na který jste zaměřeni, takže externí monitory, které komunikují přes DDC/CI, se nastavují stejně jako obrazovka notebooku.

### Displeje Apple

Pokud používáte displej Apple, běžné klávesy pro jas na klávesnici budou také automaticky fungovat, pokud jste zaměřeni na displej Apple. To se děje prostřednictvím příkazu `asdcontrol`.

Všimněte si, že pokud používáte displej Apple 6K XDR, můžete ve výpisu `hyprctl monitors` vidět fantomovou obrazovku. Můžete ji vypnout něčím jako `hl.monitor({ output = "DP-2", disabled = true })` přes _Nastavení > Monitory_.

Na počítačích Intel byste se k displejům Apple měli připojovat pomocí běžného kabelu Thunderbolt. Na jiných počítačích bez Thunderboltu budete obvykle muset použít [kabel DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N), aby to fungovalo.
