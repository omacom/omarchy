# Monitory

Omarchy ve výchozím nastavení předpokládá, že používáte displej třídy retina s podporou 2x škálování. Přesně to potřebujete, abyste získali ta pěkná, ostrá programátorská písma. Právě na to je optimalizovaná téměř všechna nová prémiová notebooková zařízení s obrazovkami s vysokým rozlišením. Právě to byste chtěli používat na 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) nebo 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Pokud ale nemáte displej s PPI 218 nebo vyšším, budete chtít nastavení monitoru změnit. Pokud máte například 27" nebo 32" 4K, můžete pro něj vybrat zlomkové měřítko z panelu monitorů v horní liště, nebo nastavit výchozí hodnotu pro každý monitor otevřením `~/.config/hypr/monitors.lua` a přepnutím na doporučení pro danou kombinaci:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Pokud používáte displej 1080p nebo 1440p, pravděpodobně budete chtít prostě používat škálování 1x, a totéž pro aplikace GTK a X11, takže můžete použít:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Změny `GDK_SCALE` se projeví u aplikací spuštěných po změně (a GTK respektuje pouze celá čísla, takže ho ponechte na nejbližším celém čísle k měřítku vašeho monitoru). Po změně tedy nezapomeňte zavřít okna, která máte příliš velká (nebo zavřete všechna okna pomocí `Ctrl + Alt + Del`!).

Hlavními poměry škálování monitoru (1x, 1.25x, 1.6x, 2x, 3x, 4x) můžete také rychle procházet pomocí `Super + /` směrem nahoru a `Super + Alt + /` směrem dolů, nebo si jeden vybrat z panelu monitorů v horní liště. Tyto volby mění pouze monitor, na který jste právě zaměření, takže obrazovka notebooku a externí displej mohou mít každý své vlastní měřítko. Panel také nastavuje rozlišení každého monitoru. Vaše volby se pro daný fyzický monitor ukládají do `~/.local/state/omarchy/monitors/settings`, takže přetrvají i po restartu a následují monitor do kteréhokoli portu nebo doku, do kterého ho příště zapojíte. Mají přednost před jakýmkoli pravidlem pro stejný monitor v `~/.config/hypr/monitors.lua`, které Omarchy nikdy neupravuje. Pokud byste raději nastavovali monitory výhradně v tomto souboru, přidejte do něj `omarchy_monitor_panel_settings = false` a změny z panelu vydrží pouze do opětovného načtení Hyprland. Protože `GDK_SCALE` je jedna hodnota pro všechny obrazovky, nastaví ho zvolené měřítko podle monitoru s nejnižším měřítkem, takže aplikace X11 vyjdou na hustší obrazovce trochu malé, místo aby byly na té druhé příliš velké.

### Zvětšení nebo zmenšení textu

Škálování monitoru mění velikost všeho. Pokud chcete pouze větší nebo menší _text_, je na to jediný ovladač:

```
omarchy display text size 14
```

Ten přijímá velikost v pixelech mezi 9 a 20 a posouvá shell Omarchy, aplikace GTK a váš terminál společně, takže celá plocha zůstává v proporcích. Spusťte ho bez argumentu, abyste viděli, kde právě jste, a `omarchy display text size reset` pro návrat k výchozí hodnotě. Foot je jediný opozdilec: nemá žádný způsob, jak znovu načíst svou konfiguraci, takže spuštěné terminály si ponechají starou velikost, dokud neotevřete nový.

### Rozšíření a zrcadlení displejů notebooku

Když k notebooku připojíte externí obrazovku, displej se automaticky rozšíří. To ale můžete místo toho změnit na zrcadlení pomocí _Trigger > Hardware_ v nabídce Omarchy nebo `Super + Ctrl + Alt + Delete`. To je obzvlášť užitečné, pokud je tou externí obrazovkou projektor a chcete něco ukazovat při práci.

Když používáte rozšíření, zavřením víka notebooku se interní obrazovka automaticky vypne. Otevřením víka se zase zapne. Můžete to také ovládat ručně pomocí _Trigger > Hardware_ v nabídce Omarchy nebo `Super + Ctrl + Delete`.

### Uspořádání více obrazovek

Hyprland funguje skvěle s více obrazovkami. Panel monitorů v horní liště je kreslí tam, kde sedí: přetáhněte jednu ke straně jiné, abyste ji tam přesunuli, a uspořádání se uloží spolu s ostatními nastaveními každého monitoru. Pro cokoli, co panel nepokrývá, si přečtěte více o tom, jak je rozložit, v [dokumentaci Hyprland k monitorům](https://wiki.hypr.land/Configuring/Basics/Monitors/). V Omarchy patří tyto položky do `~/.config/hypr/monitors.lua` jako položky `hl.monitor` — soubor se dodává se zakomentovanými příklady pro přiřazení konkrétního monitoru k rozlišení, pozici a otočení.

Každý monitor má svých vlastních 1 až 10 pracovních ploch, takže `Super + 1` vždy znamená první pracovní plochu monitoru, na kterém jste. V pozadí Hyprland stále čísluje pracovní plochy napříč všemi monitory: obrazovka vašeho notebooku (nebo první monitor) dostane 1–10, další monitor 11–20 a tak dále, a každý monitor si svůj blok ponechá pokaždé, když ho zapojíte. Tato čísla použijte, pokud píšete [pravidla pracovních ploch](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) nebo pravidla oken pro konkrétní monitor, takže pracovní plocha 12 je druhá pracovní plocha vašeho druhého monitoru. `~/.local/state/omarchy/monitors/workspaces` uvádí, který blok má každý monitor.

Šipky fungují napříč monitory, které ve vašem rozložení sdílejí hranu. Obrazovky, které se dotýkají pouze rohem, nebo mezi kterými je mezera, nejsou sousedé, takže pro přechod mezi nimi použijte `Ctrl + Alt + Tab`.

| Klávesová zkratka | Napříč monitory |
| --- | --- |
| `Super + Arrow` | Přesune zaměření na monitor na dané straně, jakmile tím směrem už nezbývá žádné okno |
| `Super + Shift + Arrow` | Prohodí se s oknem na monitoru na dané straně |
| `Super + Alt + Arrow` | Přesune okno do skupiny na monitoru na dané straně |
| `Super + Shift + Ctrl + Arrow` | Přesune okno na monitor na dané straně, na pracovní plochu, kterou zobrazuje |
| `Super + Shift + Alt + Arrow` | Přesune pracovní plochu na monitor na dané straně a ponechá si její číslo, pokud je volné |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Přesune zaměření na další nebo předchozí monitor, ať je rozložení jakékoli |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Zůstanou na monitoru, na kterém jste |

Můžete se také podívat na [Hyprmon](https://github.com/erans/hyprmon/), pokud byste chtěli TUI, které vám pomůže s umístěním více obrazovek.

### Ovládání jasu

Jas monitoru se ovládá vyhrazenými funkčními klávesami pro zvýšení/snížení jasu. Pokud při stisknutí těchto kláves podržíte shift, přejdete na maximální nebo minimální jas. Klávesy ovládají displej, na který jste zaměření, takže externí monitory, které hovoří DDC/CI, se nastavují stejným způsobem jako obrazovka notebooku.

### Displeje Apple

Pokud používáte displej Apple, budou běžné klávesy pro jas na klávesnici také automaticky fungovat, pokud jste zaměření na displej Apple. To se provádí prostřednictvím příkazu `asdcontrol`.

Všimněte si, že pokud používáte displej Apple 6K XDR, můžete ve výpisu `hyprctl monitors` vidět fantomovou obrazovku. Tu můžete vypnout něčím jako `hl.monitor({ output = "DP-2", disabled = true })` v `~/.config/hypr/monitors.lua`.

Na strojích Intel byste se k displejům Apple měli připojovat pomocí běžného kabelu Thunderbolt. Na ostatních strojích bez Thunderbolt budete typicky muset použít [kabel DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N), aby to fungovalo.
