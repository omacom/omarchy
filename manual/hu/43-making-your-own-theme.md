# Saját téma készítése

Hozzáadhatod saját témáidat a `~/.config/omarchy/themes` mappához. Egyszerűen másolj le egyet a meglévők közül alapnak (nézd meg a `/usr/share/omarchy/themes` mappát), aztán alakítsd kedved szerint. Amíg a témád abban a mappában van, szerepelni fog a témaválasztó menüben.

A fő fájl, amelyet módosítanod kell, a `colors.toml`. Ez határozza meg azt a színkészletet, amelyből aztán konfigurációk generálódnak a terminálhoz (Foot/Alacritty/Ghostty/Kitty), a btop, a Chromium, a Hyprland, a Neovim, a Helix, a VSCode, az Obsidian és az egész Omarchy shell (felső sáv, menü, értesítések, OSD és zárolási képernyő) számára.

A mellékelt Aether alkalmazást is használhatod új téma létrehozásához, egy kellemes GUI felülettel, ahol játszhatsz a színekkel és kereshetsz háttereket. Egyszerűen indítsd el az alkalmazásrácsból a `Super + Alt + Space` billentyűkombinációval.

### Mit tartalmazhat egy telepített téma

Egy téma, amelyet magad írsz a `~/.config/omarchy/themes` mappában, bármit tartalmazhat — ez a te géped és a te fájlod, az Omarchy pedig mindent alkalmaz belőle.

Egy téma, amelyet valaki más repójából telepítesz az `omarchy theme install` paranccsal, mindent megtart, ami szín, és elveszíti azt a néhány fájlt, amely kódot futtatna a gépeden: minden `.lua` fájlt, a terminálkonfigurációkat (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) és a `vscode.json` fájlt. Egy téma `hyprland.lua` fájlja Lua, amelyet a kompozitorod futtat bejelentkezéskor, egy terminálkonfiguráció megnevezi a programot, amelyet a terminálod elindít, a `vscode.json` pedig egy telepítendő VSCode-bővítményt nevez meg. Valaki témájának telepítése azt változtassa meg, hogyan néz ki az asztalod, soha ne azt, hogy mit futtat.

Minden más továbbra is pontosan úgy működik, ahogyan a téma szerzője megírta — a `btop.theme`, a `chromium.theme`, a `helix.toml`, az `icons.theme`, a `shell.toml`, a hátterek és az előnézetek mind megmaradnak. Csak az generálódik újra a gépeden a `colors.toml` alapján, amit eldobott.

Az Omarchy aszerint különbözteti meg a kettőt, hogy van-e a témának saját git repója magában, amit az `omarchy theme install` hagy hátra klónozáskor. Így egy általad írt téma a tiéd marad, egy internetről letöltött pedig színek marad.

### Világos mód

Ha világos módú témát készítesz, állítsd be a `mode = "light"` értéket a `colors.toml` tetején. Akkor automatikusan világos móddal lesz párosítva minden alkalmazáshoz. (A régi módszer is működik még: egy üres, `light.mode` nevű fájlt dobsz a témád gyökerébe.)

### Ikonok színei

Ha szeretnéd a fájlkezelő ikonjainak színét a témádhoz igazítani, adj hozzá egy `icons.theme` nevű fájlt a használni kívánt ikonkészlet nevével. Alapértelmezés szerint a lehetőségek: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### Feloldókép

Az `unlock.png` és `preview-unlock.png` képekkel ellátott témák a _Megjelenés > Feloldás_ alatt lesznek felsorolva. Az `unlock.png` lehetőleg átlátszó png legyen. Az előnézeti képet pedig az `omarchy plymouth preview` paranccsal hozhatod létre.

### Olyan alkalmazások témázása, amelyekre az Omarchy nem terjed ki

Ha olyan alkalmazást használsz, amely nincs azon a listán, egy sablonnal magad is megtaníthatod az Omarchynak, hogyan témázza. Dobj egy fájlt a `~/.config/omarchy/themed/` mappába, amelyet az általa generált konfigurációról nevezz el, plusz egy `.tpl` kiterjesztéssel, és írd meg a konfigurációt a `{{ background }}`, a `{{ foreground }}`, a `{{ accent }}`, a `{{ red }}`, a `{{ color0 }}` és a `{{ color15 }}` közötti értékek, valamint a paletta többi része helyőrzőivel. Minden témaváltáskor a fájl újragenerálódik az adott téma színeivel.

Abban a mappában van egy részletesen kommentált `alacritty.toml.tpl.sample`, amelyről másolhatsz — felsorol minden használható változót, plusz a `_strip` és `_rgb` módosítókat azoknak az alkalmazásoknak, amelyek `#` nélkül vagy decimális RGB formában kérik a színeiket. A sablonjaid elsőbbséget élveznek az Omarchy sajátjaival szemben, így ezzel azt is felülírhatod, hogyan kap témát egy beépített alkalmazás.

### A témád terjesztése

Ha terjeszteni szeretnéd a témádat, hogy mások is használhassák, nyilvános git szerverre kell tenned, például GitHubra. Akkor az emberek telepíthetik az Omarchy menü _Telepítés > Stílus > Téma_ pontjában, azzal az URL-lel. Ajánlott az `omarchy-[themename]-theme` elnevezési konvenciót követni, mert így a téma telepítés után helyesen, egyszerűen `[themename]` néven jelenik meg a témaválasztó menüben.

Az a megmaradó `[themename]` lesz a téma könyvtárneve, ezért olyannak kell lennie, amelyet az Omarchy biztonságosan tud kezelni: betűvel, számjeggyel vagy aláhúzásjellel kell kezdődnie, a többi része pedig betűket, számjegyeket, `.`, `_`, `+` és `-` karaktereket tartalmazhat. A nagybetűket kisbetűssé alakítja helyetted, de minden mást — egy szóközt, egy idézőjelet, egy nem angol karaktert — telepítéskor elutasít, ahelyett hogy könyvtárnévvé alakítaná. Így az `omarchy-tokyo-night-theme`, az `omarchy-flexoki_light-theme` és az `omarchy-c++-theme` mind gond nélkül települ.

Ne feledd: amint repóból telepítik, minden vele együtt szállított `.lua`, terminálkonfiguráció vagy `vscode.json` eldobásra kerül, ezért ne ezek köré építsd a témát.

Felvetetheted a témádat az [extra témák oldalára](https://omarchy.org/themes/), ha pull requestet küldesz az [omarchy-site repóba](https://github.com/omacom-io/omarchy-site).
