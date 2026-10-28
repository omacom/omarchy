# Monitory

Omarchy ve výchozím nastavení předpokládá, že používáte displej třídy retina, který zvládne škálování 2x. Právě to potřebujete k těm hezkým, ostrým programátorským fontům. Právě pro to je optimalizovaná téměř všechna nová prémiová notebooková zařízení s displeji s vysokým rozlišením. Právě to byste chtěli provozovat na 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) nebo 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Pokud ale nepoužíváte displej s PPI 218 nebo vyšším, budete chtít nastavení monitoru změnit. Pokud máte například 27" nebo 32" 4K, můžete použít frakční škálování tak, že otevřete `~/.config/hypr/monitors.lua` (přes _Setup > Monitors_ v nabídce Omarchy) a přepnete na doporučení pro danou kombinaci:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Pokud používáte displej 1080p nebo 1440p, pravděpodobně budete chtít prostě použít škálování 1x, takže můžete použít:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Změny `GDK_SCALE` se projeví u aplikací spuštěných po změně (a GTK respektuje pouze celá čísla, takže ho nechte na nejbližším celém čísle vašeho škálování monitoru). Po změně tedy určitě ukončete okna, která máte příliš velká (nebo zavřete všechna okna pomocí `Ctrl + Alt + Del`!).

Hlavními poměry škálování monitoru (1x, 1.25x, 1.6x, 2x, 3x, 4x) můžete také rychle procházet pomocí `Super + /` směrem nahoru a `Super + Alt + /` směrem dolů. Pokud máte výchozí konfiguraci, tyto změny přetrvají i po restartu.

### Zvětšení nebo zmenšení textu

Škálování monitoru mění velikost všeho. Pokud chcete jen větší nebo menší _text_, je na to jediný ovládací prvek:

```
omarchy display text size 14
```

Bere velikost v pixelech mezi 9 a 20 a posouvá shell Omarchy, aplikace GTK a váš terminál společně, takže celý desktop zůstane v proporcích. Spusťte ho bez argumentu, abyste viděli, kde právě jste, a `omarchy display text size reset` pro návrat k výchozímu nastavení. Foot je jediný opozdilec: nemá jak znovu načíst svou konfiguraci, takže spuštěné terminály si zachovají starou velikost, dokud neotevřete nový.

### Rozšíření a zrcadlení displejů notebooku

Když k notebooku připojíte externí obrazovku, displej se automaticky rozšíří. Místo toho to ale můžete změnit na zrcadlení pomocí _Trigger > Hardware_ v nabídce Omarchy nebo `Super + Ctrl + Alt + Delete`. To se hodí zejména tehdy, když je tou externí obrazovkou projektor a chcete něco ukázat, zatímco pracujete.

Když používáte rozšíření, zavřením víka notebooku se interní obrazovka automaticky vypne. Otevřením víka se zase zapne. Můžete to také ovládat ručně pomocí _Trigger > Hardware_ v nabídce Omarchy nebo `Super + Ctrl + Delete`.

### Uspořádání více obrazovek

Hyprland skvěle funguje s více obrazovkami. Více o tom, jak je rozložit, si přečtěte v [dokumentaci k monitorům Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). V Omarchy se tyto věci zapisují do `~/.config/hypr/monitors.lua` jako položky `hl.monitor` — soubor se dodává se zakomentovanými příklady, jak konkrétní monitor připnout na rozlišení, pozici a otočení.

Každý monitor má vlastních 1 až 10 pracovních ploch, takže `Super + 1` vždy znamená první pracovní plochu monitoru, na kterém právě jste. V zákulisí Hyprland stále čísluje pracovní plochy napříč všemi monitory: displej vašeho notebooku (nebo první monitor) dostane 1–10, další monitor 11–20 a tak dále a každý monitor si svůj blok zachová pokaždé, když ho připojíte. Tato čísla použijte, pokud píšete [pravidla pracovních ploch](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) nebo pravidla oken pro konkrétní monitor, takže pracovní plocha 12 je druhá pracovní plocha vašeho druhého monitoru. `~/.local/state/omarchy/monitor-workspaces` uvádí, který blok který monitor má.

Klávesy se šipkami fungují napříč monitory, které ve vašem rozložení sdílejí hranu. Obrazovky, které se dotýkají jen v rohu nebo mezi kterými je mezera, nejsou sousedé, takže mezi nimi přecházejte pomocí `Ctrl + Alt + Tab`.

| Klávesová zkratka | Napříč monitory |
| --- | --- |
| `Super + Arrow` | Přesune fokus na monitor na dané straně, jakmile v daném směru už nezbývá žádné okno |
| `Super + Shift + Arrow` | Prohodí se s oknem na monitoru na dané straně |
| `Super + Alt + Arrow` | Přesune okno do skupiny na monitoru na dané straně |
| `Super + Shift + Ctrl + Arrow` | Přesune okno na monitor na dané straně, na pracovní plochu, kterou zobrazuje |
| `Super + Shift + Alt + Arrow` | Přesune pracovní plochu na monitor na dané straně a zachová její číslo, pokud je volné |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Přesune fokus na další nebo předchozí monitor, bez ohledu na rozložení |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Zůstávají na monitoru, na kterém právě jste |

Můžete se také podívat na [Hyprmon](https://github.com/erans/hyprmon/), pokud byste chtěli TUI, které vám pomůže s umístěním více obrazovek.

### Ovládání jasu

Jas monitoru se ovládá vyhrazenými funkčními klávesami pro zvýšení/snížení jasu. Pokud při jejich stisknutí podržíte shift, přejdete na maximální nebo minimální jas. Klávesy ovládají displej, na který máte zaměřenou pozornost, takže externí monitory, které mluví DDC/CI, se nastavují stejně jako obrazovka notebooku.

### Displeje Apple

Pokud používáte displej Apple, běžné klávesy pro jas na klávesnici budou také automaticky fungovat, pokud máte zaměřený displej Apple. Děje se to prostřednictvím příkazu `asdcontrol`.

Všimněte si, že pokud používáte displej Apple 6K XDR, můžete ve výpisu `hyprctl monitors` vidět fantomovou obrazovku. Můžete ji vypnout něčím jako `hl.monitor({ output = "DP-2", disabled = true })` přes _Setup > Monitors_.

Na počítačích Intel byste se k displejům Apple měli připojovat běžným kabelem Thunderbolt. Na ostatních počítačích bez Thunderboltu budete obvykle muset použít [kabel DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N), aby to fungovalo.
