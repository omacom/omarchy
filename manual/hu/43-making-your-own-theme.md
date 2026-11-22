# Saját téma készítése

Hozzáadhatod a saját témáidat a `~/.config/omarchy/themes` mappához. Csak másolj le egyet a meglévők közül alapnak (nézz körül a `/usr/share/omarchy/themes` mappában), aztán alakítsd kedved szerint. Amíg a témád abban a mappában van, szerepelni fog a témaválasztó menüben.

A fő fájl, amelyet módosítanod kell, a `colors.toml`. Ez határozza meg azt a színkészletet, amelyből aztán konfigurációk generálódnak a terminálhoz (Foot/Alacritty/Ghostty/Kitty), a btop, a Chromium, a Hyprland, a Neovim, a Helix, a VSCode, az Obsidian, a Qt appok, a billentyűzet háttérvilágítása, a beviteli mód, a képernyőmegosztás-választó, az appikonok, több AI-eszköz (Claude, Pi, Hermes, T3 Code, Herdr), valamint a teljes Omarchy shell (felső sáv, menü, értesítések, OSD és zárolási képernyő) számára.

Használhatod a mellékelt Aether alkalmazást is új téma létrehozásához egy kellemes GUI felülettel, ahol játszhatsz a színekkel, és hátterek után kereshetsz. Csak indítsd el az apprácsból a `Super + Alt + Space` billentyűkombinációval.

### Mit tartalmazhat egy telepített téma

Egy téma, amelyet magad írsz a `~/.config/omarchy/themes` mappában, bármit tartalmazhat, amit csak szeretnél — ez a te géped és a te fájlod, és az Omarchy mindent alkalmaz belőle.

Egy téma, amelyet valaki más repójából telepítesz az `omarchy theme install` paranccsal, megtart mindent, ami szín, és elveszíti azt a maroknyi fájlt, amely kódot futtatna a gépeden: minden `.lua` fájlt, a terminálkonfigurációkat (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) és a `vscode.json` fájlt. Egy téma `hyprland.lua` fájlja olyan Lua, amelyet a compositorod futtat bejelentkezéskor, egy terminálkonfiguráció megnevezi a programot, amelyet a terminálod elindít, a `vscode.json` pedig megnevez egy telepítendő VSCode-bővítményt. Valaki témájának telepítése azt változtassa meg, hogyan néz ki az asztalod, soha ne azt, hogy mit futtat.

Minden más továbbra is pontosan úgy működik, ahogyan a téma szerzője megírta — a `btop.theme`, a `chromium.theme`, a `helix.toml`, a `shell.toml`, a hátterek és az előnézetek mind megmaradnak. Csak az generálódik újra a gépeden a `colors.toml` alapján, ami el lett dobva.

Az Omarchy aszerint különbözteti meg a kettőt, hogy a témának van-e saját git repója önmagában, amit az `omarchy theme install` hagy maga után klónozáskor. Így egy téma, amelyet te írtál, a tiéd marad, egy pedig, amelyet az internetről húztál le, megmarad színeknek.

### Világos mód

Ha világos módú témát készítesz, állítsd be a `mode = "light"` értéket a `colors.toml` fájlod tetején. Akkor automatikusan világos móddal lesz párosítva minden appnál. (A régi módszer is működik még, amikor egy üres, `light.mode` nevű fájlt dobsz a témád gyökerébe.)

### Feloldási kép

Az `unlock.png` és `preview-unlock.png` képekkel érkező témák a _Megjelenés > Feloldás_ alatt lesznek felsorolva. Az `unlock.png` fájlod lehetőleg átlátszó png legyen. Az előnézeti képet pedig az `omarchy plymouth preview` paranccsal hozhatod létre.

### Az Omarchy által le nem fedett appok témázása

Ha olyan appot használsz, amely nincs azon a listán, egy sablonnal magad is megtaníthatod az Omarchy-t, hogyan témázza azt. Dobj egy fájlt a `~/.config/omarchy/themed/` mappába, amelyet az általa generált konfigurációról nevezz el, plusz egy `.tpl` kiterjesztéssel, és írd meg a konfigurációt a `{{ background }}`, a `{{ foreground }}`, a `{{ accent }}`, a `{{ red }}`, a `{{ color0 }}` és a `{{ color15 }}` közötti elemek, valamint a paletta többi része helyőrzőivel. Minden alkalommal, amikor témát váltasz, a fájl újra generálódik az adott téma színeivel.

Abban a mappában van egy teljesen kommentezett `alacritty.toml.tpl.sample`, amelyet lemásolhatsz — felsorol minden változót, amelyet használhatsz, plusz a `_strip` és `_rgb` módosítókat azokhoz az appokhoz, amelyek a színeiket a `#` nélkül vagy decimális RGB formában kérik. A sablonjaid elsőbbséget élveznek az Omarchy sajátjaival szemben, így ezzel azt is felülírhatod, hogyan kap témát egy beépített app.

### A témád terjesztése

Ha terjeszteni szeretnéd a témádat, hogy mások is használhassák, nyilvános git szerverre kell tenned, például a GitHubra. Akkor az emberek telepíthetik az Omarchy menüben a _Telepítés > Stílus > Téma_ útvonalon, azzal az URL-lel. Ajánlott az `omarchy-[themename]-theme` elnevezési konvenciót követned, mert így a téma telepítés után helyesen, csak `[themename]` formában jelenik meg a témaválasztó menüben.

Ez a megmaradó `[themename]` lesz a téma könyvtárneve, így olyannak kell lennie, amelyet az Omarchy biztonságosan tud ide-oda adni: betűvel, számjeggyel vagy aláhúzással kell kezdődnie, a többi része pedig betűket, számjegyeket, `.`, `_`, `+` és `-` karaktereket tartalmazhat. A nagybetűket kisbetűsre alakítja neked, de minden mást — egy szóközt, egy idézőjelet, egy nem angol karaktert — telepítéskor elutasít, ahelyett hogy könyvtárnévvé alakítaná. Így az `omarchy-tokyo-night-theme`, az `omarchy-flexoki_light-theme` és az `omarchy-c++-theme` mind gond nélkül települ.

Ne feledd, hogy amint repóból telepítik, minden `.lua` fájl, terminálkonfiguráció vagy `vscode.json`, amelyet a téma magával hoz, el lesz dobva, ezért ne ezek köré építsd a témát.

Felveheted a témádat [az extra témák oldalára](https://omarchy.org/themes/), ha pull requestet küldesz [az omarchy-site repóba](https://github.com/omacom-io/omarchy-site).
