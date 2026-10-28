# Monitory

Omarchy ve výchozím nastavení předpokládá, že používáte displej třídy retina s podporou 2x škálování. Právě to potřebujete, abyste získali ta hezká, ostrá programátorská písma. Právě na to je optimalizována téměř většina nových prémiových notebooků s obrazovkami ve vysokém rozlišení. Právě to byste chtěli používat na 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) nebo 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Pokud ale nemáte displej s PPI 218 nebo vyšším, budete chtít nastavení monitoru změnit. Pokud máte například 27" nebo 32" 4K, můžete použít frakční škálování tak, že otevřete `~/.config/hypr/monitors.lua` (přes _Nastavení > Monitory_ v nabídce Omarchy) a přepnete na doporučení pro danou kombinaci:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Pokud používáte displej s rozlišením 1080p nebo 1440p, pravděpodobně budete chtít prostě používat škálování 1x, takže můžete použít:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Změny `GDK_SCALE` se projeví u aplikací spuštěných po změně (a GTK respektuje jen celá čísla, takže ho nechte na nejbližším celém čísle vašeho škálování monitoru). Takže po změně určitě ukončete okna, která máte nadměrně velká (nebo zavřete všechna okna pomocí `Ctrl + Alt + Del`!).

Pomocí `Super + /` můžete také rychle procházet hlavní poměry škálování monitoru (1x, 1.25x, 1.6x, 2x, 3x, 4x) směrem nahoru a pomocí `Super + Alt + /` směrem dolů, nebo si jeden vybrat na panelu monitoru v horní liště. Ty mění jen monitor, na který jste zaměřeni, takže obrazovka notebooku a externí displej mohou mít každý své vlastní škálování. Volba se pro daný monitor uloží do `~/.config/hypr/monitors.lua` jako pravidlo `hl.monitor`, takže přežije restart a má přednost před `omarchy_monitor_scale`, které zůstává škálováním pro každý monitor bez vlastního pravidla.

### Zvětšení nebo zmenšení textu

Škálování monitoru mění velikost všeho. Pokud chcete jen větší nebo menší _text_, je na to jediný ovládací prvek:

```
omarchy display text size 14
```

Přijímá velikost v pixelech od 9 do 20 a společně posouvá shell Omarchy, GTK aplikace i váš terminál, takže celý desktop zůstane v proporcích. Spusťte ho bez argumentu, abyste viděli, jak na tom jste, a pomocí `omarchy display text size reset` se vrátíte k výchozímu nastavení. Foot je jediný opozdilec: nemá žádný způsob, jak znovu načíst svou konfiguraci, takže běžící terminály si zachovají starou velikost, dokud neotevřete nový.

### Rozšíření a zrcadlení displejů notebooku

Když k notebooku připojíte externí obrazovku, displej se automaticky rozšíří. Místo toho to ale můžete změnit na zrcadlení pomocí _Spouštěč > Hardware_ v nabídce Omarchy nebo `Super + Ctrl + Alt + Delete`. To je obzvlášť užitečné, pokud je tou externí obrazovkou projector a chcete během práce něco ukazovat.

Když máte plochu rozšířenou, zavřením víka notebooku se vnitřní obrazovka automaticky vypne. Otevřením víka se zase zapne. Můžete to také ovládat ručně pomocí _Spouštěč > Hardware_ v nabídce Omarchy nebo `Super + Ctrl + Delete`.

### Uspořádání více obrazovek

Hyprland skvěle funguje s více obrazovkami. Více o tom, jak je rozmístit, se dočtete v [dokumentaci Hyprlandu k monitorům](https://wiki.hypr.land/Configuring/Basics/Monitors/). V Omarchy patří do `~/.config/hypr/monitors.lua` jako položky `hl.monitor` — soubor obsahuje zakomentované příklady, jak konkrétní monitor připnout k rozlišení, pozici a otočení.

Každý monitor má svých vlastních pracovních ploch 1 až 10, takže `Super + 1` vždy znamená první pracovní plochu monitoru, na kterém jste. V pozadí Hyprland stále čísluje pracovní plochy napříč všemi monitory: displej vašeho notebooku (nebo první monitor) dostane 1–10, další monitor 11–20 a tak dále a každý monitor si svůj blok zachová pokaždé, když ho připojíte. Tato čísla použijte, pokud píšete [pravidla pro pracovní plochy](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) nebo pravidla oken pro konkrétní monitor, takže pracovní plocha 12 je druhá pracovní plocha vašeho druhého monitoru. `~/.local/state/omarchy/monitor-workspaces` uvádí, který blok každý monitor má.

Klávesy se šipkami fungují mezi monitory, které ve vašem rozložení sdílejí hranu. Obrazovky, které se dotýkají jen v rohu nebo mezi kterými je mezera, nejsou sousedé, takže mezi nimi přecházejte pomocí `Ctrl + Alt + Tab`.

| Klávesová zkratka | Napříč monitory |
| --- | --- |
| `Super + Arrow` | Přesune fokus na monitor na dané straně, jakmile v daném směru už nezbývá žádné okno |
| `Super + Shift + Arrow` | Prohodí se s oknem na monitoru na dané straně |
| `Super + Alt + Arrow` | Přesune okno do skupiny na monitoru na dané straně |
| `Super + Shift + Ctrl + Arrow` | Přesune okno na monitor na dané straně, na pracovní plochu, kterou zobrazuje |
| `Super + Shift + Alt + Arrow` | Přesune pracovní plochu na monitor na dané straně a zachová její číslo, pokud je volné |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Přesune fokus na další nebo předchozí monitor bez ohledu na rozložení |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Zůstanou na monitoru, na kterém jste |

Můžete se také podívat na [Hyprmon](https://github.com/erans/hyprmon/), pokud byste chtěli TUI, které vám pomůže s rozmístěním více obrazovek.

### Ovládání jasu

Jas monitoru se ovládá vyhrazenými funkčními klávesami pro zvýšení/snížení jasu. Pokud při stisknutí těchto kláves podržíte Shift, přejdete na maximální nebo minimální jas. Klávesy ovládají displej, na který jste zaměřeni, takže externí monitory, které mluví DDC/CI, se upravují stejně jako obrazovka notebooku.

### Displeje Apple

Pokud používáte displej Apple, běžné klávesy pro jas na klávesnici budou také automaticky fungovat, pokud jste zaměřeni na displej Apple. Děje se to prostřednictvím příkazu `asdcontrol`.

Upozorňujeme, že pokud používáte displej Apple 6K XDR, může se ve výpisu `hyprctl monitors` objevit fantomová obrazovka. Tu můžete vypnout něčím jako `hl.monitor({ output = "DP-2", disabled = true })` přes _Nastavení > Monitory_.

Na počítačích Intel byste se k displejům Apple měli připojovat běžným kabelem Thunderbolt. Na ostatních počítačích bez Thunderboltu budete obvykle muset použít [kabel DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N), aby to fungovalo.
