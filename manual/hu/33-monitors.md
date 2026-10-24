# Monitorok

Az Omarchy alapértelmezetten abból indul ki, hogy 2x-képes, retina-osztályú kijelzőn futsz. Ez az, amihez szükséged van a szép, éles programozó-betűtípusokhoz. Erre van optimalizálva szinte minden új, nagy felbontású kijelzővel szerelt prémium laptop. Ezt szeretnéd futtatni egy 27"-os 5K [Apple Studio Displayen](https://www.apple.com/studio-display/)/[ProArt PA27JCV-n](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9-en](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P-n](https://kuycon.us/monitors/G27P/) vagy egy 32"-os 6K [Apple XDR-en](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV-n](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P-n](https://kuycon.us/monitors/G32P/).

De ha nem 218-as vagy annál nagyobb PPI-vel futtatsz kijelzőt, módosítani szeretnéd a monitorbeállításokat. Például ha 27"-os vagy 32"-os 4K-d van, használhatsz tört skálázást, ha megnyitod a `~/.config/hypr/monitors.lua` fájlt (az Omarchy menü _Setup > Monitors_ pontján keresztül), és átváltasz az adott kombinációhoz ajánlott beállításra:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Ha 1080p vagy 1440p kijelzőt használsz, valószínűleg egyszerűen 1x skálázást szeretnél, így használhatod ezt:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

A `GDK_SCALE` módosításai a módosítás után indított alkalmazásokra vonatkoznak (és a GTK csak egész számokat vesz figyelembe, így tartsd a monitor skálád legközelebbi egészénél). Ezért ügyelj arra, hogy kilépj azokból az ablakokból, amelyek a módosítás után túl nagyok (vagy zárj be minden ablakot a `Ctrl + Alt + Del` kombinációval!).

A főbb monitor-skálázási arányokon (1x, 1.25x, 1.6x, 2x, 3x, 4x) gyorsan végigléptethetsz a `Super + /` kombinációval felfelé és a `Super + Alt + /` kombinációval lefelé. Ha megvan az alapértelmezett konfigurációd, ezek a módosítások újraindítás után is megmaradnak.

### Szöveg nagyítása vagy kicsinyítése

A monitor skálázása mindennek a méretét módosítja. Ha csak nagyobb vagy kisebb _szöveget_ szeretnél, van hozzá egy egyszerű beállítás:

```
omarchy display text size 14
```

Ez egy 9 és 20 közötti pixelméretet vesz fel, és az Omarchy shellt, a GTK-alkalmazásokat és a terminált együtt mozdítja, így az egész asztal arányban marad. Futtasd argumentum nélkül az aktuális értéked megtekintéséhez, és az `omarchy display text size reset` paranccsal az alapértelmezettre való visszaállításhoz. A Foot az egyetlen lemaradó: nincs módja a konfiguráció újratöltésére, így a futó terminálok a régi méretet tartják, amíg újat nem nyitsz.

### Laptopkijelzők kiterjesztése és tükrözése

Amikor egy külső kijelzőt csatlakoztatsz a laptopodhoz, a kijelző automatikusan kiterjesztődik. Ezt azonban tükrözésre módosíthatod az Omarchy menü _Trigger > Hardware_ pontjával vagy a `Super + Ctrl + Alt + Delete` kombinációval. Ez különösen hasznos, ha az a külső kijelző egy projektor, és munka közben szeretnél valamit megmutatni.

Amikor kiterjesztéssel használod, a laptop fedelének bezárása automatikusan kikapcsolja a belső képernyőt. A fedél felnyitása visszakapcsolja. Ezt kézzel is vezérelheted az Omarchy menü _Trigger > Hardware_ pontjával vagy a `Super + Ctrl + Delete` kombinációval.

### Több képernyő elrendezése

A Hyprland kiválóan működik több képernyővel. Olvass arról, hogyan rendezheted el őket [a Hyprland monitor-dokumentációban](https://wiki.hypr.land/Configuring/Basics/Monitors/). [Külön munkaterületeket is köthetsz külön monitorokhoz](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/). Az Omarchyban ezek a szabályok a `~/.config/hypr/monitors.lua` fájlba kerülnek `hl.monitor` bejegyzésekként — a fájl olyan kommentált példákkal érkezik, amelyekkel egy adott monitort felbontáshoz, pozícióhoz és forgatáshoz rögzíthetsz.

Nézd meg a [Hyprmont](https://github.com/erans/hyprmon/) is, ha szeretnél egy TUI-t, amely segít több képernyő elhelyezésében.

### Fényerő szabályozása

A monitor fényerejét a fényerő növelésére/csökkentésére szolgáló dedikált funkcióbillentyűk vezérlik. Ha a Shiftet lenyomva tartod ezek megnyomása közben, a maximális vagy minimális fényerőre ugrasz. A billentyűk azt a kijelzőt vezérlik, amelyen a fókusz van, így a DDC/CI-t beszélő külső monitorokat ugyanúgy állítod, mint a laptop képernyőjét.

### Apple kijelzők

Ha Apple kijelzőt használsz, a szokásos billentyűzeti fényerő-billentyűk akkor is automatikusan működnek, ha a fókusz az Apple kijelzőn van. Ezt az `asdcontrol` parancs végzi.

Megjegyzés: ha Apple 6K XDR kijelzőt használsz, egy fantom képernyőt láthatsz a `hyprctl monitors` listádban. Kikapcsolhatod valami ilyesmivel: `hl.monitor({ output = "DP-2", disabled = true })` a _Setup > Monitors_ pontban.

Intel-gépeken szokásos Thunderbolt-kábellel kell csatlakoznod az Apple kijelzőkhöz. Más gépeken Thunderbolt nélkül általában egy [DP + USB-A -> USB-C kábelt](https://www.amazon.com/dp/B0BNX7MS6N) kell használnod a működéshez.
