# Monitory

Omarchy ve výchozím nastavení předpokládá, že používáte displej třídy retina s podporou škálování 2x. To je to, co potřebujete pro ty hezké, ostré programátorské fonty. Je to to, na co je optimalizována skoro každá nová prémiová řada notebooků s obrazovkami s vysokým rozlišením. Je to to, co byste chtěli používat na 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) nebo 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Ale pokud nepoužíváte displej s PPI 218 nebo vyšším, budete chtít nastavení monitoru změnit. Pokud například máte 27" nebo 32" 4K, můžete pro něj vybrat zlomkové škálování z panelu monitorů v horní liště, nebo nastavit výchozí hodnotu pro každý monitor otevřením `~/.config/hypr/monitors.lua` a přepnutím na doporučení pro danou kombinaci:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Pokud používáte displej 1080p nebo 1440p, pravděpodobně budete chtít prostě používat škálování 1x a totéž pro aplikace GTK a X11, takže můžete použít:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Změny `GDK_SCALE` se projeví u aplikací spuštěných po změně (a GTK bere v úvahu pouze celá čísla, takže ho držte na nejbližším celém čísle škálování vašeho monitoru). Takže po změně určitě zavřete okna, která máte nadměrně velká (nebo zavřete všechna okna pomocí `Ctrl + Alt + Del`!).

Pomocí `Super + /` pro vyšší a `Super + Alt + /` pro nižší můžete také rychle procházet hlavní poměry škálování monitoru (1x, 1.25x, 1.6x, 2x, 3x, 4x), nebo si jeden vybrat z panelu monitorů v horní liště. Ty mění pouze monitor, na který jste zaměřeni, takže obrazovka notebooku a externí displej mohou mít každý své vlastní škálování. Panel také nastavuje rozlišení, obnovovací frekvenci a otočení každého monitoru. Vaše volby se pro daný fyzický monitor ukládají do `~/.local/state/omarchy/monitors/settings`, takže přetrvají i po restartu a následují monitor do kteréhokoli portu nebo doku, do kterého ho příště zapojíte. Mají přednost před jakýmkoli pravidlem pro stejný monitor v `~/.config/hypr/monitors.lua`, které Omarchy nikdy neupravuje. Pokud byste raději nastavovali své monitory výhradně v tomto souboru, přidejte do něj `omarchy_monitor_panel_settings = false` a změny z panelu vydrží pouze do opětovného načtení Hyprlandu. Protože `GDK_SCALE` je jedna hodnota pro všechny obrazovky, nastaví ho zvolené škálování podle monitoru s nejnižším škálováním, takže aplikace X11 vyjdou na hustší obrazovce trochu malé místo nadměrně velké na té druhé.

### Zvětšení nebo zmenšení textu

Škálování monitoru mění velikost všeho. Pokud chcete jen větší nebo menší _text_, existuje na to jediné ovládací kolečko:

```
omarchy display text size 14
```

To bere velikost v pixelech mezi 9 a 20 a hýbe shellem Omarchy, aplikacemi GTK a vaším terminálem společně, takže celá plocha zůstává v proporcích. Spusťte to bez argumentu, abyste viděli, kde právě jste, a `omarchy display text size reset` pro návrat k výchozí hodnotě. Foot je jediný opozdilec: nemá žádný způsob, jak znovu načíst svou konfiguraci, takže běžící terminály si ponechají svou starou velikost, dokud neotevřete nový.

### Rozšíření a zrcadlení displejů notebooku

Když k notebooku připojíte externí obrazovku, displej se automaticky rozšíří. Ale můžete to místo toho změnit na zrcadlení pomocí _Trigger > Hardware_ v nabídce Omarchy nebo `Super + Ctrl + Alt + Delete`. To je obzvlášť užitečné, pokud je tou externí obrazovkou projektor a chcete při práci něco ukázat.

Když rozšiřujete, zavření víka notebooku automaticky vypne interní obrazovku. Otevření víka ji zase zapne. Můžete to ovládat i ručně pomocí _Trigger > Hardware_ v nabídce Omarchy nebo `Super + Ctrl + Delete`.

### Uspořádání více obrazovek

Hyprland skvěle funguje s více obrazovkami. Panel monitorů v horní liště je kreslí tam, kde sedí: přetáhněte jednu ke straně druhé, abyste ji tam přesunuli, a uspořádání se uloží spolu s ostatními nastaveními každého monitoru. Pro cokoli, co panel nepokrývá, si přečtěte více o tom, jak je rozložit, v [dokumentaci k monitorům v Hyprlandu](https://wiki.hypr.land/Configuring/Basics/Monitors/). V Omarchy se tyto věci dávají do `~/.config/hypr/monitors.lua` jako položky `hl.monitor` — soubor se dodává s komentovanými příklady pro ponechání monitoru vypnutého, režimy, které panel nenabízí, 10bitové barvy a variabilní obnovovací frekvenci.

Každý monitor má svých vlastních pracovních ploch 1 až 10, takže `Super + 1` vždy znamená první pracovní plochu monitoru, na kterém jste. V zákulisí Hyprland stále čísluje pracovní plochy napříč všemi monitory: vaše obrazovka notebooku (nebo první monitor) dostane 1–10, další monitor 11–20 a tak dále a každý monitor si svůj blok zachová pokaždé, když ho zapojíte. Tato čísla použijte, pokud píšete [pravidla pracovních ploch](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) nebo pravidla oken pro konkrétní monitor, takže pracovní plocha 12 je druhá pracovní plocha vašeho druhého monitoru. `~/.local/state/omarchy/monitors/workspaces` uvádí, který blok každý monitor má.

Klávesy se šipkami fungují napříč monitory, které ve vašem rozložení sdílejí hranu. Obrazovky, které se dotýkají pouze v rohu nebo mezi kterými je mezera, nejsou sousedé, takže pro přechod mezi nimi použijte `Ctrl + Alt + Tab`.

| Klávesová zkratka | Mezi monitory |
| --- | --- |
| `Super + Arrow` | Přesune zaměření na monitor na té straně, jakmile tím směrem už nezbývá žádné okno |
| `Super + Shift + Arrow` | Prohodí se s oknem na monitoru na té straně |
| `Super + Alt + Arrow` | Přesune okno do skupiny na monitoru na té straně |
| `Super + Shift + Ctrl + Arrow` | Přesune okno na monitor na té straně, na pracovní plochu, kterou zobrazuje |
| `Super + Shift + Alt + Arrow` | Přesune pracovní plochu na monitor na té straně a ponechá její číslo, pokud je volné |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Přesune zaměření na další nebo předchozí monitor, bez ohledu na rozložení |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Zůstanou na monitoru, na kterém jste |

Můžete se také podívat na [Hyprmon](https://github.com/erans/hyprmon/), pokud byste chtěli TUI, které vám pomůže s umístěním více obrazovek.

### Ovládání jasu

Jas monitoru se ovládá vyhrazenými funkčními klávesami pro zvýšení/snížení jasu. Pokud při stisknutí těchto kláves podržíte shift, přejdete na maximální nebo minimální jas. Klávesy ovládají displej, na který jste zaměřeni, takže externí monitory, které mluví DDC/CI, se nastavují stejným způsobem jako obrazovka notebooku.

### Displeje Apple

Pokud používáte displej Apple, běžné klávesy pro jas na klávesnici budou také automaticky fungovat, pokud jste zaměřeni na displej Apple. Děje se to prostřednictvím příkazu `asdcontrol`.

Všimněte si, že pokud používáte displej Apple 6K XDR, můžete ve svém výpisu `hyprctl monitors` vidět fantomovou obrazovku. Tu můžete vypnout něčím jako `hl.monitor({ output = "DP-2", disabled = true })` v `~/.config/hypr/monitors.lua`.

Na počítačích Intel byste se k displejům Apple měli připojovat pomocí běžného kabelu Thunderbolt. Na ostatních počítačích bez Thunderboltu budete obvykle muset použít [kabel DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N), aby to fungovalo.
