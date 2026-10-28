# Monitorok

Az Omarchy alapértelmezés szerint azt feltételezi, hogy 2x-es méretezésre képes, retina osztályú kijelzőt használsz. Erre van szükséged azokhoz a szép, éles programozó betűtípusokhoz. Erre van optimalizálva szinte minden új, nagy felbontású képernyővel szerelt prémium laptop. Ezt akarnád használni egy 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) vagy egy 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) kijelzőn.

De ha nem 218-as vagy annál nagyobb PPI-vel rendelkező kijelzőt használsz, érdemes megváltoztatnod a monitorbeállításokat. Ha például 27" vagy 32" 4K kijelződ van, használhatsz tört méretezést, ha megnyitod a `~/.config/hypr/monitors.lua` fájlt (az Omarchy menüben a _Beállítás > Monitorok_ útvonalon), és átváltasz az ahhoz a kombinációhoz ajánlott értékekre:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Ha 1080p vagy 1440p kijelzőt használsz, valószínűleg egyszerűen 1x-es méretezést akarsz majd használni, így ezeket használhatod:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

A `GDK_SCALE` módosításai a módosítás után indított alkalmazásokra vonatkoznak (és a GTK csak egész számokat vesz figyelembe, ezért tartsd a monitor méretezéséhez legközelebbi egész értéken). Ezért a módosítás után mindenképpen lépj ki azokból az ablakokból, amelyek túl nagyok (vagy zárd be az összes ablakot a `Ctrl + Alt + Del` billentyűkombinációval!).

Gyorsan végig is lépkedhetsz a fő monitor-méretezési arányokon (1x, 1.25x, 1.6x, 2x, 3x, 4x) a `Super + /` billentyűkombinációval felfelé és a `Super + Alt + /` billentyűkombinációval lefelé, vagy kiválaszthatsz egyet a felső sáv monitorpaneljéről. Ezek csak azt a monitort módosítják, amelyiken a fókusz van, így a laptop képernyőjének és egy külső kijelzőnek is lehet saját méretezése. A választás `hl.monitor` szabályként mentődik az adott monitorhoz a `~/.config/hypr/monitors.lua` fájlba, így újraindítás után is megmarad, és elsőbbséget élvez az `omarchy_monitor_scale` értékkel szemben, amely továbbra is minden olyan monitor méretezése marad, amelynek nincs saját szabálya.

### Szöveg nagyítása vagy kicsinyítése

A monitor méretezése mindennek a méretét megváltoztatja. Ha csak nagyobb vagy kisebb _szöveget_ szeretnél, arra egyetlen beállítás szolgál:

```
omarchy display text size 14
```

Ez 9 és 20 közötti pixelméretet fogad el, és együtt állítja az Omarchy felületét, a GTK alkalmazásokat és a terminálodat, így az egész asztal arányos marad. Futtasd argumentum nélkül, hogy lásd, hol tartasz, a `omarchy display text size reset` paranccsal pedig visszatérhetsz az alapértelmezetthez. A Foot az egyetlen lemaradó: nem tudja újratölteni a konfigurációját, így a futó terminálok megtartják a régi méretüket, amíg nem nyitsz egy újat.

### Laptopkijelzők kiterjesztése és tükrözése

Amikor külső képernyőt csatlakoztatsz a laptopodhoz, a kijelző automatikusan kiterjesztődik. Ezt azonban tükrözésre is átállíthatod az Omarchy menü _Indító > Hardver_ pontjában vagy a `Super + Ctrl + Alt + Delete` billentyűkombinációval. Ez különösen hasznos, ha az a külső képernyő egy projektor, és munka közben szeretnél valamit megmutatni.

Kiterjesztéskor a laptop fedelének lecsukása automatikusan kikapcsolja a belső képernyőt. A fedél felnyitása visszakapcsolja. Ezt kézzel is vezérelheted az Omarchy menü _Indító > Hardver_ pontjában vagy a `Super + Ctrl + Delete` billentyűkombinációval.

### Több képernyő elrendezése

A Hyprland remekül működik több képernyővel. További információt az elrendezésükről [a Hyprland monitorokról szóló dokumentációjában](https://wiki.hypr.land/Configuring/Basics/Monitors/) találsz. Az Omarchyban ezek `hl.monitor` bejegyzésekként kerülnek a `~/.config/hypr/monitors.lua` fájlba — a fájl kommentelt példákkal érkezik egy adott monitor felbontásának, pozíciójának és elforgatásának rögzítéséhez.

Minden monitornak saját 1-től 10-ig terjedő munkaterületei vannak, így a `Super + 1` mindig annak a monitornak az első munkaterületét jelenti, amelyiken éppen vagy. A háttérben a Hyprland továbbra is az összes monitoron átívelően számozza a munkaterületeket: a laptopod képernyője (vagy az első monitor) kapja az 1–10-et, a következő monitor a 11–20-at, és így tovább, és minden monitor megtartja a saját blokkját minden alkalommal, amikor csatlakoztatod. Ezeket a számokat használd, ha [munkaterület-szabályokat](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) vagy ablakszabályokat írsz egy adott monitorhoz, így a 12-es munkaterület a második monitorod második munkaterülete. A `~/.local/state/omarchy/monitor-workspaces` felsorolja, melyik blokk melyik monitorhoz tartozik.

A nyílbillentyűk az elrendezésedben közös éllel érintkező monitorok között működnek. Azok a képernyők, amelyek csak egy sarokban érintkeznek, vagy amelyek között rés van, nem szomszédok, ezért a `Ctrl + Alt + Tab` billentyűkombinációval válts közöttük.

| Gyorsbillentyű | Monitorok között |
| --- | --- |
| `Super + Arrow` | A fókuszt az azon az oldalon lévő monitorra helyezi, amint abban az irányban már nincs több ablak |
| `Super + Shift + Arrow` | Felcseréli az azon az oldalon lévő monitoron lévő ablakkal |
| `Super + Alt + Arrow` | Az ablakot egy csoportba helyezi az azon az oldalon lévő monitoron |
| `Super + Shift + Ctrl + Arrow` | Az ablakot az azon az oldalon lévő monitorra helyezi, az általa éppen mutatott munkaterületre |
| `Super + Shift + Alt + Arrow` | A munkaterületet az azon az oldalon lévő monitorra helyezi, megtartva a számát, ha az szabad |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | A fókuszt a következő vagy előző monitorra helyezi, az elrendezéstől függetlenül |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Az aktuális monitoron maradnak |

Megnézheted a [Hyprmon](https://github.com/erans/hyprmon/) alkalmazást is, ha szeretnél egy TUI-t, amely segít több képernyő elhelyezésében.

### Fényerő szabályozása

A monitor fényerejét a fényerő növelésére és csökkentésére szolgáló, külön erre szolgáló funkcióbillentyűkkel lehet szabályozni. Ha ezek megnyomása közben lenyomva tartod a shift billentyűt, a maximális vagy minimális fényerőre ugrasz. A billentyűk azt a kijelzőt vezérlik, amelyiken a fókusz van, így a DDC/CI protokollt támogató külső monitorok ugyanúgy állíthatók, mint a laptop képernyője.

### Apple kijelzők

Ha Apple kijelzőt használsz, a szokásos billentyűzeti fényerőbillentyűk is automatikusan működni fognak, ha az Apple kijelzőn van a fókusz. Ez az `asdcontrol` paranccsal történik.

Megjegyzés: ha Apple 6K XDR kijelzőt használsz, egy fantomképernyőt láthatsz a `hyprctl monitors` listájában. Ezt kikapcsolhatod például ezzel: `hl.monitor({ output = "DP-2", disabled = true })` a _Beállítás > Monitorok_ útvonalon.

Intel gépeken egy szokásos Thunderbolt kábellel érdemes az Apple kijelzőkhöz csatlakoznod. Más, Thunderbolt nélküli gépeken általában egy [DP + USB-A -> USB-C kábelt](https://www.amazon.com/dp/B0BNX7MS6N) kell használnod, hogy működjön.
