# Saját téma készítése

Saját témáidat a `~/.config/omarchy/themes` mappába adhatod hozzá. Egyszerűen másolj le egyet a meglévők közül alapnak (ezeket a `/usr/share/omarchy/themes` mappában találod), majd alakítsd kedved szerint. Amíg a témád abban a mappában van, megjelenik a témaválasztó menüben.

A fő fájl, amelyet módosítanod kell, a `colors.toml`. Ez határozza meg azt a színkészletet, amelyből aztán konfigok generálódnak a terminálhoz (Foot/Alacritty/Ghostty/Kitty), a btop, a Chromium, a Hyprland, a Neovim, a Helix, a VSCode, az Obsidian számára, valamint a teljes Omarchy shellhez (felső sáv, menü, értesítések, OSD és zárolási képernyő).

A mellékelt Aether alkalmazást is használhatod új téma létrehozására, egy kellemes GUI felülettel, ahol játszhatsz a színekkel és háttereket kereshetsz. Csak indítsd el az alkalmazásrácsból a `Super + Alt + Space` billentyűkombinációval.

### Mit tartalmazhat egy telepített téma

Egy téma, amelyet magad írsz a `~/.config/omarchy/themes` mappába, bármit tartalmazhat, amit csak szeretnél — ez a te géped és a te fájlod, és az Omarchy mindent alkalmaz belőle.

Egy téma, amelyet valaki más repójából telepítesz az `omarchy theme install` paranccsal, megtart mindent, ami szín, és elveszíti azt a maroknyi fájlt, amely kódot futtatna a gépeden: minden `.lua` fájlt, a terminálkonfigokat (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) és a `vscode.json` fájlt. Egy téma `hyprland.lua` fájlja olyan Lua, amelyet a compositorod futtat bejelentkezéskor, egy terminálkonfig megnevezi azt a programot, amelyet a terminálod elindít, a `vscode.json` pedig megnevez egy telepítendő VSCode bővítményt. Valaki más témájának telepítése azt változtassa meg, hogyan néz ki az asztalod, soha ne azt, hogy mit futtat.

Minden más továbbra is pontosan úgy működik, ahogy a téma szerzője megírta — a `btop.theme`, a `chromium.theme`, a `helix.toml`, a `shell.toml`, a hátterek és az előnézetek mind megmaradnak. Csak az, amit eldobott, generálódik újra a `colors.toml` fájlból a te gépeden.

Az Omarchy aszerint különbözteti meg a kettőt, hogy a témának van-e saját git repója benne, ez az, amit az `omarchy theme install` hátrahagy, amikor klónoz. Így a téma, amelyet te írtál, a tiéd marad, amelyet pedig az internetről húztál le, az színek marad.

### Világos mód

Ha világos módú témát készítesz, állítsd be a `mode = "light"` értéket a `colors.toml` fájlod tetején. Akkor automatikusan világos móddal lesz párosítva minden alkalmazásnál. (A régi módszer is működik még: egy üres, `light.mode` nevű fájlt dobsz a témád gyökerébe.)

### Feloldókép

Az `unlock.png` és `preview-unlock.png` képekkel ellátott témák a _Megjelenés > Feloldás_ alatt lesznek felsorolva. Az `unlock.png` fájlod lehetőleg átlátszó png legyen. Az előnézeti képet pedig az `omarchy plymouth preview` paranccsal hozhatod létre.

### Olyan alkalmazások témázása, amelyeket az Omarchy nem fed le

Ha olyan alkalmazást használsz, amely nincs azon a listán, sablonnal magad is megtaníthatod az Omarchy-t a témázására. Dobj egy fájlt a `~/.config/omarchy/themed/` mappába, amelyet arról a konfigról nevezz el, amelyet generál, plusz egy `.tpl` kiterjesztéssel, és írd meg a konfigot a `{{ background }}`, a `{{ foreground }}`, a `{{ accent }}`, a `{{ red }}`, a `{{ color0 }}` és a `{{ color15 }}` közötti helyőrzőkkel, valamint a paletta többi részével helyőrzőkként. Ahányszor témát váltasz, a fájl újra generálódik az adott téma színeivel.

Van abban a mappában egy teljesen kommentezett `alacritty.toml.tpl.sample`, amelyről másolhatsz — felsorol minden használható változót, plusz a `_strip` és `_rgb` módosítókat azokhoz az alkalmazásokhoz, amelyek `#` nélkül vagy decimális RGB formában kérik a színeiket. A sablonjaid elsőbbséget élveznek az Omarchy sajátjaival szemben, így ezzel azt is felülírhatod, hogyan kap témát egy beépített alkalmazás.

### A témád terjesztése

Ha terjeszteni szeretnéd a témádat, hogy mások is használhassák, nyilvános git szerverre kell tenned, például a GitHubra. Ezután az emberek telepíthetik az Omarchy menü _Telepítés > Stílus > Téma_ pontjában, azt az URL-t használva. Ajánlott az `omarchy-[themename]-theme` elnevezési konvenciót követned, mert így a téma a telepítés után helyesen, egyszerűen `[themename]` néven jelenik meg a témaválasztó menüben.

Az a megmaradó `[themename]` lesz a téma könyvtárneve, ezért olyannak kell lennie, amelyet az Omarchy biztonságosan tud kezelni: betűvel, számjeggyel vagy aláhúzással kell kezdődnie, a többi része pedig betűket, számjegyeket, `.`, `_`, `+` és `-` karaktereket tartalmazhat. A nagybetűket kisbetűssé alakítja neked, de minden mást — szóközt, idézőjelet, nem angol karaktert — a telepítéskor elutasít, ahelyett hogy könyvtárnévvé alakítaná. Így az `omarchy-tokyo-night-theme`, az `omarchy-flexoki_light-theme` és az `omarchy-c++-theme` mind gond nélkül települ.

Ne feledd, hogy amint repóból telepítik, minden `.lua`, terminálkonfig vagy `vscode.json`, amelyet tartalmaz, el lesz dobva, ezért ne ezek köré építsd a témát.

Felvetetheted a témádat [az extra témák oldalára](https://omarchy.org/themes/), ha pull requestet küldesz [az omarchy-site repóba](https://github.com/omacom-io/omarchy-site).
