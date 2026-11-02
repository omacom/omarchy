# Monitory

Omarchy ve výchozím nastavení předpokládá, že používáte displej třídy retina schopný 2x škálování. Právě to potřebujete, abyste měli ta pěkná, ostrá programátorská písma. Právě na to jsou optimalizovány téměř všechny nové prémiové notebooky s obrazovkami s vysokým rozlišením. Právě to byste chtěli používat na 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) nebo 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Pokud ale nepoužíváte displej s PPI 218 nebo vyšším, budete chtít změnit nastavení monitoru. Pokud máte například 27" nebo 32" 4K, můžete zlomkové škálování zvolit na panelu monitoru v horní liště, nebo nastavit výchozí hodnotu pro všechny monitory otevřením `~/.config/hypr/monitors.lua` a přepnutím na doporučení pro danou kombinaci:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Pokud používáte displej s rozlišením 1080p nebo 1440p, pravděpodobně budete chtít prostě používat 1x škálování, a to i pro aplikace GTK a X11, takže můžete použít:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Změny `GDK_SCALE` se projeví u aplikací spuštěných po změně (a GTK respektuje pouze celá čísla, takže ho ponechte na nejbližším celém čísle vašeho škálování monitoru). Po změně tedy nezapomeňte ukončit okna, která máte nadměrně velká (nebo zavřete všechna okna pomocí `Ctrl + Alt + Del`!).

Pomocí `Super + /` můžete také rychle procházet hlavní poměry škálování monitoru (1x, 1.25x, 1.6x, 2x, 3x, 4x) směrem nahoru a pomocí `Super + Alt + /` směrem dolů, nebo si jeden vybrat na panelu monitoru v horní liště. Změna se týká jen aktivního monitoru, takže obrazovka notebooku a externí displej mohou mít každý své vlastní škálování. Panel nastavuje také rozlišení, obnovovací frekvenci a otočení každého monitoru. Vaše volby se ukládají pro daný fyzický monitor do `~/.local/state/omarchy/monitors/settings`, takže přežijí restart a následují monitor do jakéhokoli portu nebo dokovací stanice, ke které ho příště připojíte. Mají přednost před jakýmkoli pravidlem pro stejný monitor v souboru `~/.config/hypr/monitors.lua`, který Omarchy nikdy neupravuje. Pokud raději nastavujete monitory výhradně v tomto souboru, přidejte do něj `omarchy_monitor_panel_settings = false` a změny z panelu vydrží jen do opětovného načtení Hyprlandu. Protože `GDK_SCALE` má jednu hodnotu pro všechny obrazovky, nastaví ho zvolené škálování podle monitoru s nejnižším škálováním. Aplikace X11 tak budou na obrazovce s vyšší hustotou pixelů trochu menší, místo aby byly na té druhé příliš velké.

### Zvětšení nebo zmenšení textu

Škálování monitoru mění velikost všeho. Pokud chcete jen větší nebo menší _text_, stačí jeden příkaz:

```
omarchy display text size 14
```

Ten přijímá velikost v pixelech mezi 9 a 20 a mění velikost textu současně v shellu Omarchy, aplikacích GTK a terminálu, aby celé pracovní prostředí zůstalo sladěné. Spusťte ho bez argumentu, abyste viděli aktuální velikost, a příkazem `omarchy display text size reset` se vraťte k výchozímu nastavení. Foot je jediný opozdilec: nemá způsob, jak svou konfiguraci načíst znovu, takže běžící terminály si uchovají svou starou velikost, dokud neotevřete nový.

### Rozšíření a zrcadlení displejů notebooku

Když k notebooku připojíte externí obrazovku, displej se automaticky rozšíří. Místo toho to ale můžete změnit na zrcadlení pomocí _Akce > Hardware_ v nabídce Omarchy nebo `Super + Ctrl + Alt + Delete`. To je obzvlášť užitečné, pokud je tou externí obrazovkou projektor a chcete během práce něco ukazovat.

Když máte plochu rozšířenou, zavřením víka notebooku se vnitřní obrazovka automaticky vypne. Otevřením víka se zase zapne. Můžete to také ovládat ručně pomocí _Akce > Hardware_ v nabídce Omarchy nebo `Super + Ctrl + Delete`.

### Uspořádání více obrazovek

Hyprland skvěle funguje s více obrazovkami. Panel monitoru v horní liště je zakreslí tak, jak stojí: přetáhněte jeden k okraji druhého a přesunete ho tam a uspořádání se uloží spolu s dalšími nastaveními každého monitoru. Pro vše, co panel nepokrývá, si přečtěte více o jejich rozložení v [dokumentaci Hyprlandu k monitorům](https://wiki.hypr.land/Configuring/Basics/Monitors/). V Omarchy se tyto údaje zapisují do `~/.config/hypr/monitors.lua` jako položky `hl.monitor` — soubor se dodává s okomentovanými příklady pro ponechání monitoru vypnutého, režimy, které panel nenabízí, 10bitovou barvu a proměnnou obnovovací frekvenci.

Každý monitor má vlastní pracovní plochy 1 až 10, takže `Super + 1` vždy znamená první pracovní plochu monitoru, na kterém se nacházíte. V pozadí Hyprland stále čísluje pracovní plochy napříč všemi monitory: obrazovka vašeho notebooku (nebo první monitor) dostane 1–10, další monitor 11–20 a tak dále, a každý monitor si svůj blok ponechá pokaždé, když ho připojíte. Tato čísla použijte, pokud píšete [pravidla pracovních ploch](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) nebo pravidla oken pro konkrétní monitor, takže pracovní plocha 12 je druhou pracovní plochou vašeho druhého monitoru. `~/.local/state/omarchy/monitors/workspaces` uvádí, který blok má každý monitor.

Klávesy se šipkami fungují napříč monitory, které ve vašem rozložení sdílejí hranu. Obrazovky, které se dotýkají pouze v rohu nebo mezi nimiž je mezera, nejsou sousedé, takže pro přechod mezi nimi použijte `Ctrl + Alt + Tab`.

| Klávesová zkratka | Napříč monitory |
| --- | --- |
| `Super + Arrow` | Přesune zaměření na monitor na dané straně, jakmile v daném směru už nezbývá žádné okno |
| `Super + Shift + Arrow` | Prohodí okno s oknem na monitoru na dané straně |
| `Super + Alt + Arrow` | Přesune okno do skupiny na monitoru na dané straně |
| `Super + Shift + Ctrl + Arrow` | Přesune okno na monitor na dané straně, na pracovní plochu, kterou zobrazuje |
| `Super + Shift + Alt + Arrow` | Přesune pracovní plochu na monitor na dané straně a ponechá její číslo, pokud je volné |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Přesune zaměření na další nebo předchozí monitor, bez ohledu na rozložení |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Zůstávají na monitoru, na kterém se nacházíte |

Můžete se také podívat na [Hyprmon](https://github.com/erans/hyprmon/), pokud byste chtěli TUI, které vám pomůže s umístěním více obrazovek.

### Ovládání jasu

Jas monitoru se ovládá vyhrazenými funkčními klávesami pro zvýšení/snížení jasu. Pokud při stisknutí těchto kláves podržíte Shift, přejdete na maximální nebo minimální jas. Klávesy ovládají aktivní displej, takže externí monitory, které komunikují přes DDC/CI, se nastavují stejně jako obrazovka notebooku.

### Displeje Apple

Pokud používáte displej Apple, běžné klávesy pro jas na klávesnici budou také automaticky fungovat, pokud je aktivní displej Apple. To se děje prostřednictvím příkazu `asdcontrol`.

Pokud používáte displej Apple 6K XDR, můžete ve výpisu `hyprctl monitors` vidět fantomovou obrazovku. Vypnout ji můžete například pomocí `hl.monitor({ output = "DP-2", disabled = true })` v `~/.config/hypr/monitors.lua`.

Na počítačích Intel byste se k displejům Apple měli připojovat pomocí běžného kabelu Thunderbolt. Na jiných počítačích bez Thunderboltu budete obvykle muset použít [kabel DP + USB-A -> USB-C](https://www.amazon.com/dp/B0BNX7MS6N), aby to fungovalo.
