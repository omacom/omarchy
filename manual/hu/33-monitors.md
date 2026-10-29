# Monitorok

Az Omarchy alapértelmezés szerint azt feltételezi, hogy 2x-es méretezésre képes, retina osztályú kijelzőt használsz. Erre van szükséged azokhoz a szép, éles programozóbetűtípusokhoz. Szinte minden új, nagy felbontású képernyővel szerelt prémium laptop erre van optimalizálva. Ilyet akarsz használni egy 27"-os 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) vagy egy 32"-os 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) kijelzőn is.

De ha nem 218-as vagy nagyobb PPI-vel rendelkező kijelzőt használsz, érdemes módosítanod a monitorbeállításokat. Ha például 27"-os vagy 32"-os 4K kijelződ van, használhatsz tört méretezést: nyisd meg a `~/.config/hypr/monitors.lua` fájlt (az Omarchy menü _Setup > Monitors_ pontján keresztül), és válts az ahhoz a kombinációhoz ajánlott értékekre:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Ha 1080p-s vagy 1440p-s kijelzőt használsz, valószínűleg egyszerűen 1x-es méretezést akarsz használni, tehát ezeket állíthatod be:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

A `GDK_SCALE` módosításai a módosítás után indított alkalmazásokra vonatkoznak (és a GTK csak egész számokat vesz figyelembe, tehát tartsd a monitor méretezéséhez legközelebbi egész értéken). Ezért a módosítás után mindenképpen lépj ki azokból az ablakokból, amelyek túl nagyok lettek (vagy zárd be az összes ablakot a `Ctrl + Alt + Del` billentyűkombinációval!).

Gyorsan végig is lépkedhetsz a fő monitor-méretezési arányokon (1x, 1.25x, 1.6x, 2x, 3x, 4x) a `Super + /` billentyűkombinációval felfelé és a `Super + Alt + /` billentyűkombinációval lefelé, vagy kiválaszthatsz egyet a felső sáv monitorpaneljén. Ezek csak azt a monitort módosítják, amelyiken a fókusz van, így a laptop képernyőjének és egy külső kijelzőnek is lehet saját méretezése. A választás `hl.monitor` szabályként mentődik az adott monitorhoz a `~/.config/hypr/monitors.lua` fájlba, így újraindítás után is megmarad, és elsőbbséget élvez az `omarchy_monitor_scale` értékkel szemben, amely továbbra is minden olyan monitor méretezése marad, amelynek nincs saját szabálya. Mivel a `GDK_SCALE` egyetlen érték az összes képernyőre, ezek a módosítások a legalacsonyabb méretezésű monitor alapján állítják be, így az X11-alkalmazások inkább kicsit kicsik lesznek a sűrűbb képernyőn, mintsem túl nagyok a másikon.

### Szöveg nagyítása vagy kicsinyítése

A monitor méretezése mindent átméretez. Ha csak nagyobb vagy kisebb _szöveget_ szeretnél, arra egyetlen kapcsoló szolgál:

```
omarchy display text size 14
```

Ez 9 és 20 közötti képpontméretet fogad el, és együtt mozgatja az Omarchy felületét, a GTK-alkalmazásokat és a terminálodat, így az egész asztal arányos marad. Futtasd argumentum nélkül, hogy lásd, éppen hol tartasz, a `omarchy display text size reset` paranccsal pedig visszaállhatsz az alapértelmezettre. A Foot az egyetlen lemaradó: nincs módja a konfigurációja újratöltésére, így a futó terminálok megtartják a régi méretüket, amíg újat nem nyitsz.

### Laptopkijelzők kiterjesztése és tükrözése

Amikor külső képernyőt csatlakoztatsz a laptopodhoz, a kijelző automatikusan kiterjesztésre kerül. Ezt azonban tükrözésre is átállíthatod az Omarchy menü _Trigger > Hardware_ pontjában vagy a `Super + Ctrl + Alt + Delete` billentyűkombinációval. Ez különösen akkor hasznos, ha az a külső képernyő egy projektor, és munka közben szeretnél valamit megmutatni.

Kiterjesztés közben a laptop fedelének lecsukása automatikusan kikapcsolja a belső képernyőt. A fedél felnyitása visszakapcsolja. Ezt kézzel is vezérelheted az Omarchy menü _Trigger > Hardware_ pontjában vagy a `Super + Ctrl + Delete` billentyűkombinációval.

### Több képernyő elrendezése

A Hyprland remekül működik több képernyővel. Az elrendezésükről bővebben [a Hyprland monitorokról szóló dokumentációjában](https://wiki.hypr.land/Configuring/Basics/Monitors/) olvashatsz. Az Omarchyban ezek a `~/.config/hypr/monitors.lua` fájlba kerülnek `hl.monitor` bejegyzésekként — a fájl kommentelt példákat tartalmaz egy adott monitor felbontásának, pozíciójának és elforgatásának rögzítésére.

Minden monitornak saját 1-től 10-ig terjedő munkaterületei vannak, így a `Super + 1` mindig annak a monitornak az első munkaterületét jelenti, amelyiken éppen vagy. A háttérben a Hyprland továbbra is az összes monitoron átívelően számozza a munkaterületeket: a laptop képernyője (vagy az első monitor) kapja az 1–10 tartományt, a következő monitor a 11–20 tartományt, és így tovább, és minden monitor megtartja a saját blokkját minden alkalommal, amikor csatlakoztatod. Ezeket a számokat használd, ha egy adott monitorhoz írsz [munkaterület-szabályokat](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) vagy ablakszabályokat, így a 12-es munkaterület a második monitorod második munkaterülete. A `~/.local/state/omarchy/monitor-workspaces` fájl sorolja fel, hogy melyik monitor melyik blokkot kapta.

A nyílbillentyűk azokon a monitorokon át működnek, amelyek az elrendezésedben közös éllel érintkeznek. Azok a képernyők, amelyek csak egy sarokban érintkeznek, vagy amelyek között rés van, nem szomszédok, ezért a `Ctrl + Alt + Tab` billentyűkombinációval juthatsz át közöttük.

| Gyorsbillentyű | Monitorok között |
| --- | --- |
| `Super + Arrow` | Átviszi a fókuszt az azon az oldalon lévő monitorra, amint abban az irányban már nincs több ablak |
| `Super + Shift + Arrow` | Helyet cserél az azon az oldalon lévő monitoron lévő ablakkal |
| `Super + Alt + Arrow` | Áthelyezi az ablakot egy csoportba az azon az oldalon lévő monitoron |
| `Super + Shift + Ctrl + Arrow` | Áthelyezi az ablakot az azon az oldalon lévő monitorra, az ott éppen megjelenített munkaterületre |
| `Super + Shift + Alt + Arrow` | Áthelyezi a munkaterületet az azon az oldalon lévő monitorra, megtartva a számát, ha az szabad |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Átviszi a fókuszt a következő vagy az előző monitorra, az elrendezéstől függetlenül |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Azon a monitoron maradnak, amelyiken éppen vagy |

Érdemes megnézned a [Hyprmon](https://github.com/erans/hyprmon/) eszközt is, ha szeretnél egy TUI-t, amely segít több képernyő pozicionálásában.

### Fényerő szabályozása

A monitor fényerejét a fényerő növelésére és csökkentésére szolgáló dedikált funkcióbillentyűk szabályozzák. Ha ezek megnyomása közben lenyomva tartod a shift billentyűt, maximális vagy minimális fényerőre ugrasz. A billentyűk azt a kijelzőt szabályozzák, amelyiken a fókusz van, így a DDC/CI protokollt támogató külső monitorok ugyanúgy állíthatók, mint a laptop képernyője.

### Apple kijelzők

Ha Apple kijelzőt használsz, a szokásos billentyűzetes fényerőbillentyűk automatikusan működni fognak akkor is, ha a fókusz az Apple kijelzőn van. Ez az `asdcontrol` paranccsal történik.

Ne feledd, hogy ha Apple 6K XDR kijelzőt használsz, fantomképernyőt láthatsz a `hyprctl monitors` listájában. Ezt kikapcsolhatod például egy `hl.monitor({ output = "DP-2", disabled = true })` bejegyzéssel a _Setup > Monitors_ pontban.

Intel gépeken szokásos Thunderbolt-kábellel érdemes Apple kijelzőkhöz csatlakoznod. Thunderbolt nélküli más gépeken általában [DP + USB-A -> USB-C kábelt](https://www.amazon.com/dp/B0BNX7MS6N) kell használnod, hogy működjön.
