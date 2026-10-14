# Monitory

Omarchy ve výchozím nastavení předpokládá, že běžíte na displeji třídy retina s možností 2× škálování. To je to, co potřebujete, abyste získali ta pěkná, ostrá programátorská písma. Pro toto jsou optimalizovány téměř všechny nové prémiové notebooky s obrazovkami s vysokým rozlišením. Je to to, co byste chtěli provozovat na 27palcovém 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) nebo 32palcovém 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Ale pokud neběžíte na displeji s PPI 218 nebo vyšším, budete chtít nastavení monitoru změnit. Například, pokud máte 27palcový nebo 32palcový monitor 4K, můžete použít zlomkové škálování otevřením souboru `~/.config/hypr/monitors.lua` (v části _Nastavení > Monitory_ v nabídce Omarchy) a přepnutím na doporučení pro tuto kombinaci:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Pokud používáte displej 1080p nebo 1440p, pravděpodobně budete chtít použít jen 1× škálování, takže můžete použít:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Změny proměnné `GDK_SCALE` se použijí na aplikace spuštěné po změně (a GTK respektuje pouze celá čísla, takže ji udržujte na nejbližším celém čísle vašeho měřítka pro monitor). Takže po změně nezapomeňte zavřít okna, která máte nadměrné velikosti (nebo zavřete všechna okna pomocí klávesové zkratky `Ctrl + Alt + Del`!).

Hlavními poměry škálování monitoru (1×, 1,25×, 1,6×, 2×, 3×, 4×) můžete také rychle procházet pomocí klávesové zkratky `Super + /` pro zvýšení a `Super + Alt + /` pro snížení. Pokud máte výchozí konfiguraci, tyto změny přetrvají i po restartu.

### Zvětšení nebo zmenšení textu

Škálování monitoru mění velikost všeho. Pokud chcete jen větší nebo menší _text_, existuje pro to jediný ovladač:

```
omarchy display text size 14
```

Ten přijímá velikost v pixelech mezi 9 a 20 a přesouvá společně shell Omarchy, aplikace GTK a váš terminál, takže celé pracovní prostředí zůstává v proporcích. Spusťte ho bez argumentu, abyste viděli, kde se nacházíte, a příkazem `omarchy display text size reset` se vraťte k výchozímu nastavení. Foot je jediný opozdilec: nemá způsob, jak svou konfiguraci načíst znovu, takže běžící terminály si uchovají svou starou velikost, dokud neotevřete nový.

### Rozšíření a zrcadlení displejů notebooků

Když k notebooku připojíte externí obrazovku, displej se automaticky rozšíří. Ale pomocí části _Akce > Hardware_ v nabídce Omarchy nebo klávesové zkratky `Super + Ctrl + Alt + Delete` to můžete změnit na zrcadlení. To je obzvlášť užitečné, pokud je tato externí obrazovka projektor a vy chcete něco ukázat během práce.

Když displej rozšiřujete, zavření víka notebooku automaticky vypne interní obrazovku. Otevření víka ji znovu zapne. Můžete to ovládat také ručně pomocí části _Akce > Hardware_ v nabídce Omarchy nebo klávesové zkratky `Super + Ctrl + Delete`.

### Uspořádání více obrazovek

Hyprland skvěle funguje s více obrazovkami. Další informace o tom, jak je rozvrhnout, najdete v [dokumentaci k monitorům Hyprlandu](https://wiki.hypr.land/Configuring/Basics/Monitors/). Můžete také [vázat konkrétní pracovní plochy na konkrétní monitory](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/). V Omarchy tato pravidla patří do souboru `~/.config/hypr/monitors.lua` jako položky `hl.monitor` — soubor je dodáván s okomentovanými příklady pro připnutí konkrétního monitoru na rozlišení, polohu a otáčení.

Můžete se také podívat na program [Hyprmon](https://github.com/erans/hyprmon/), pokud byste chtěli TUI, které vám pomůže s umístěním více obrazovek.

### Ovládání jasu

Jas monitoru se ovládá vyhrazenými funkčními klávesami pro zvýšení/snížení jasu. Pokud při jejich stisknutí podržíte klávesu Shift, přejdete na maximální nebo minimální jas. Klávesy ovládají displej, na který jste zaměřeni, takže externí monitory, které komunikují prostřednictvím DDC/CI, se upravují stejným způsobem jako obrazovka notebooku.

### Displeje Apple

Pokud používáte displej Apple, budou běžné klávesové zkratky pro ovládání jasu z klávesnice také automaticky fungovat, pokud jste zaměřeni na displej Apple. Provádí se to příkazem `asdcontrol`.

Pamatujte, že pokud používáte displej Apple 6K XDR, můžete ve výpisu příkazu `hyprctl monitors` vidět přízračnou obrazovku. V části _Nastavení > Monitory_ ji můžete vypnout například příkazem `hl.monitor({ output = "DP-2", disabled = true })`.

Na počítačích s procesory Intel byste se měli k displejům Apple připojovat běžným kabelem Thunderbolt. Na jiných počítačích bez rozhraní Thunderbolt budete obvykle muset k fungování použít [kabel DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N).
