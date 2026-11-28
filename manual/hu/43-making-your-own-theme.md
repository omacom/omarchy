# Saját téma készítése

Saját témáidat a `~/.config/omarchy/themes` mappába teheted. Egyszerűen másolj le egyet a meglévők közül alapnak (nézz körül a `/usr/share/omarchy/themes` mappában), aztán alakítsd kedved szerint. Amíg a témád abban a mappában van, megjelenik a témaválasztó menüben.

A fő fájl, amit módosítanod kell, a `colors.toml`. Ez határozza meg azt a színkészletet, amelyből aztán konfigok generálódnak a terminálhoz (Foot/Alacritty/Ghostty/Kitty), a btophoz, a Chromiumhoz, a Hyprlandhez, a Neovimhoz, a Helixhez, a VSCode-hoz, az Obsidianhez, a Qt alkalmazásokhoz, a billentyűzet háttérvilágításához, a beviteli módszerhez, a képernyőmegosztás-választóhoz, az alkalmazásikonokhoz, több AI eszközhöz (Claude, Pi, Hermes, T3 Code, Herdr), valamint a teljes Omarchy felülethez (felső sáv, menü, értesítések, OSD és zárolási képernyő).

Használhatod a mellékelt Aether alkalmazást is, hogy új témát hozz létre egy kellemes GUI felületen, ahol játszhatsz a színekkel és háttereket kereshetsz. Csak indítsd el az alkalmazásrácsból a `Super + Alt + Space` billentyűkombinációval.

### Mit tartalmazhat egy telepített téma

Egy téma, amelyet magad írsz a `~/.config/omarchy/themes` mappában, bármit tartalmazhat — a te géped és a te fájlod, az Omarchy pedig mindent alkalmaz belőle.

Egy téma, amelyet valaki más repójából telepítesz az `omarchy theme install` paranccsal, minden színnel kapcsolatos dolgot megtart, és elveszíti azt a néhány fájlt, amely kódot futtatna a gépeden: minden `.lua` fájlt, a terminálkonfigokat (`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`) és a `vscode.json` fájlt. Egy téma `hyprland.lua` fájlja olyan Lua kód, amelyet a kompozitorod futtat bejelentkezéskor, egy terminálkonfig azt a programot nevezi meg, amelyet a terminálod elindít, a `vscode.json` pedig egy telepítendő VSCode bővítményt nevez meg. Valaki témájának telepítése azt változtassa meg, hogyan néz ki az asztalod, soha ne azt, hogy mit futtat.

Minden más pontosan úgy működik tovább, ahogyan a téma szerzője megírta — a `btop.theme`, a `chromium.theme`, a `helix.toml`, a `shell.toml`, a hátterek és az előnézetek mind megmaradnak. Csak az kerül újragenerálásra a `colors.toml` alapján a gépeden, amit eldobott a rendszer.

Az Omarchy aszerint különbözteti meg a kettőt, hogy a témának van-e saját git repója magán belül, amit az `omarchy theme install` hagy maga után klónozáskor. Így egy általad írt téma a tiéd marad, egy internetről letöltött pedig megmarad pusztán színeknek.

### Világos mód

Ha világos módú témát készítesz, állítsd be a `mode = "light"` értéket a `colors.toml` fájlod tetején. Ezután automatikusan világos móddal lesz párosítva minden alkalmazásnál. (A régi módszer is működik még, amikor egy üres, `light.mode` nevű fájlt dobsz a témád gyökerébe.)

### Indítási és bejelentkezési képernyők

Az a képernyő, amely indításkor a meghajtó jelszavát kéri, és a bejelentkezési képernyő az Omarchy logót a témád `accent` színével rajzolja ki annak `background` hátterén, a jelszómezőt pedig a `foreground` színnel, hibás jelszó esetén pedig a `red` színnel. Semmi extrát nem kell mellékelni hozzájuk: az Omarchy már nem használja egy téma `unlock.png` vagy `preview-unlock.png` fájlját. Apple Silicon Mac gépeken a meghajtó jelszavát kérő képernyő a témától függetlenül megtartja az Omarchy alapértelmezett megjelenését.

### Olyan alkalmazások témázása, amelyeket az Omarchy nem fed le

Ha olyan alkalmazást használsz, amely nem szerepel abban a listában, megtaníthatod az Omarchyt, hogy maga témázza azt egy sablonnal. Dobj egy fájlt a `~/.config/omarchy/themed/` mappába, amelyet az általa generált konfigról nevezz el, kiegészítve egy `.tpl` kiterjesztéssel, és írd meg a konfigot a `{{ background }}`, a `{{ foreground }}`, a `{{ accent }}`, a `{{ red }}`, a `{{ color0 }}` és a `{{ color15 }}` közötti helyőrzőkkel, valamint a paletta többi részével helyőrzőkként. Valahányszor témát váltasz, a fájl újragenerálódik az adott téma színeivel.

Abban a mappában van egy részletesen kommentált `alacritty.toml.tpl.sample`, amelyről másolhatsz — felsorol minden használható változót, plusz a `_strip` és a `_rgb` módosítókat azokhoz az alkalmazásokhoz, amelyek a színeiket a `#` nélkül vagy decimális RGB formában kérik. A sablonjaid elsőbbséget élveznek az Omarchy sajátjaival szemben, így ezzel azt is felülírhatod, hogyan kap témát egy beépített alkalmazás.

### A témád terjesztése

Ha terjeszteni szeretnéd a témádat, hogy mások is használhassák, fel kell tenned egy nyilvános git szerverre, például a GitHubra. Ezután az emberek telepíthetik az Omarchy menüben az _Install > Style > Theme_ menüponton keresztül, azt az URL-t használva. Ajánlott az `omarchy-[themename]-theme` elnevezési konvenciót követned, mert így a téma a telepítés után helyesen, pusztán `[themename]` formában jelenik meg a témaválasztó menüben.

Az a megmaradó `[themename]` lesz a téma könyvtárneve, ezért olyannak kell lennie, amelyet az Omarchy biztonságosan tud kezelni: betűvel, számjeggyel vagy aláhúzással kell kezdődnie, a többi része pedig betűket, számjegyeket, `.`, `_`, `+` és `-` karaktereket tartalmazhat. A nagybetűket a rendszer kisbetűssé alakítja helyetted, de bármi mást — szóközt, idézőjelet, nem angol karaktert — a telepítéskor elutasít, ahelyett hogy könyvtárnévvé alakítaná. Így az `omarchy-tokyo-night-theme`, az `omarchy-flexoki_light-theme` és az `omarchy-c++-theme` mind gond nélkül települ.

Ne feledd, hogy amint egy repóból telepítik, minden mellékelt `.lua` fájl, terminálkonfig vagy `vscode.json` kimarad, ezért ne ezek köré építsd a témát.

A témád felkerülhet [az extra témák oldalára](https://omarchy.org/themes/), ha pull requestet küldesz [az omarchy-site repóba](https://github.com/omacom-io/omarchy-site).
