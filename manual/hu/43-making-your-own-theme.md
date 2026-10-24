# Saját téma készítése

Saját témákat adhatsz hozzá a `~/.config/omarchy/themes` mappához. Csak másolj le egyet a meglévők közül alapnak (nézz körül a `/usr/share/omarchy/themes` mappában), majd hangold kedvedre. Amíg a témád abban a mappában van, benne lesz a témaválasztó menüben.

A fő fájl, amelyet hangolnod kell, a `colors.toml`. Ez határozza meg azt a színkészletet, amelyet azután a terminál (Foot/Alacritty/Ghostty/Kitty), a btop, a Chromium, a Hyprland, a Neovim, a Helix, a VSCode, az Obsidian és a teljes Omarchy shell (felső sáv, menü, értesítések, OSD és zárolási képernyő) konfigurációinak előállításához használnak.

A mellékelt Aether alkalmazást is használhatod új téma létrehozásához egy kedves GUI-felülettel, amellyel játszhatsz a színekkel és háttereket kereshetsz. Csak indítsd el az alkalmazásrácsból a `Super + Alt + Space` kombinációval.

### Mit tartalmazhat egy telepített téma

Egy téma, amelyet magad írsz a `~/.config/omarchy/themes` mappában, bármit tartalmazhat, amit akarsz — a te géped és a te fájlod, és az Omarchy mindet alkalmazza.

Egy téma, amelyet valaki más repójából telepítesz az `omarchy theme install` paranccsal, megtart mindent, ami szín, és elveszíti azt a néhány fájlt, amely kódot futtatna a gépeden: minden `.lua` fájlt, a terminálkonfigurációkat (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) és a `vscode.json` fájlt. Egy téma `hyprland.lua` fájlja olyan Lua, amelyet a komponálód bejelentkezéskor futtat, egy terminálkonfiguráció megnevezi azt a programot, amelyet a terminálod indít, és a `vscode.json` egy telepítendő VSCode-kiterjesztést nevez meg. Valaki témájának telepítése azt változtatja meg, hogyan néz ki az asztalod, soha nem azt, hogy mit futtat.

Minden más továbbra is pontosan úgy működik, ahogyan a téma szerzője írta — a `btop.theme`, a `chromium.theme`, a `helix.toml`, az `icons.theme`, a `shell.toml`, a hátterek és az előnézetek mind megmaradnak. Csak az, amit eldobtak, termelődik újra a `colors.toml` fájlból a gépeden.

Az Omarchy az alapján különbözteti meg a kettőt, hogy a témának van-e saját git-repója önmagán belül, ami az, amit az `omarchy theme install` klónozáskor maga után hagy. Így egy téma, amelyet írtál, a tiéd marad, és egy, amelyet az internetről szereztél, színek maradnak.

### Világos mód

Ha világos módú témát készítesz, állítsd be a `mode = "light"` értéket a `colors.toml` fájlod tetején. Ezután automatikusan világos móddal párosul minden alkalmazásban. (A téma gyökerébe dobott üres `light.mode` fájl régi módszere is továbbra is működik.)

### Ikonszínek

Ha szeretnéd a fájlkezelő ikonjait a témád színeihez igazítani, adj hozzá egy `icons.theme` nevű fájlt a használni kívánt ikonkészlet nevével. Alapértelmezetten ezek a lehetőségek: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Feloldási kép

Azok a témák, amelyek `unlock.png` és `preview-unlock.png` képekkel érkeznek, a _Stílus > Feloldás_ alatt szerepelnek. Az `unlock.png` fájlod lehetőleg egy átlátszó png legyen. Az előnézeti képet pedig az `omarchy plymouth preview` paranccsal hozhatod létre.

### Olyan alkalmazások témázása, amelyeket az Omarchy nem fed le

Ha olyan alkalmazást használsz, amely nincs azon a listán, magad is megtaníthatod az Omarchynak, hogy egy sablonnal témázza. Dobj egy fájlt a `~/.config/omarchy/themed/` mappába arról a konfigurációról elnevezve, amelyet létrehoz, plusz egy `.tpl` kiterjesztéssel, és írd meg a konfigurációt a `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}`-től `{{ color15 }}`-ig, valamint a paletta többi részével helyőrzőkként. Minden alkalommal, amikor témát váltasz, a fájl újra létrejön az adott téma színeivel.

Van egy teljesen kommentált `alacritty.toml.tpl.sample` abban a mappában, amelyről másolhatsz — felsorol minden változót, amelyet használhatsz, plusz a `_strip` és `_rgb` módosítókat azokhoz az alkalmazásokhoz, amelyek színeiket a `#` nélkül vagy decimális RGB-ként akarják. A sablonjaid előnyt élveznek az Omarchyéval szemben, így ezt arra is használhatod, hogy felülírd, hogyan kap témát egy beépített alkalmazás.

### A témád terjesztése

Ha terjeszteni akarod a témád, hogy mások is használhassák, egy nyilvános git-szerverre kell tenned, mint a GitHub. Ezután az emberek az Omarchy menü _Telepítés > Stílus > Téma_ pontjából telepíthetik azt az URL-t használva. Ajánlott, hogy az `omarchy-[themename]-theme` elnevezési konvenciót kövesd, mivel a téma a témaválasztó menüben a telepítés után helyesen csak `[themename]` néven jelenik meg.

Ez a megmaradó `[themename]` válik a téma könyvtárnevévé, így olyannak kell lennie, amelyet az Omarchy biztonságosan körbeadhat: betűvel, számjeggyel vagy aláhúzással kell kezdődnie, és a többi része betűket, számjegyeket, `.`, `_`, `+` és `-` jeleket tartalmazhat. A nagybetűk kisbetűssé válnak számodra, de minden más — szóköz, idézőjel, nem angol karakter — visszautasításra kerül telepítéskor, ahelyett, hogy könyvtárnévvé válna. Így az `omarchy-tokyo-night-theme`, az `omarchy-flexoki_light-theme` és az `omarchy-c++-theme` mind jól települ.

Emlékezz, hogy amint egy repóból települ, minden olyan `.lua`, terminálkonfiguráció vagy `vscode.json`, amelyet szállít, eldobódik, úgyhogy ne ezek köré építsd a témát.

A témádat hozzáadhatod [az extra témák oldalához](https://omarchy.org/themes/), ha pull requestet küldesz [az omarchy-site repónak](https://github.com/omacom-io/omarchy-site).
