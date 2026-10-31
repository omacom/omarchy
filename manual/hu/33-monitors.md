# Monitorok

Az Omarchy alapból azt feltételezi, hogy 2x-es méretezésre képes, retina-osztályú kijelzőt használsz. Erre van szükséged a szép, éles programozóbetűtípusokhoz. Erre optimalizáltak szinte minden új prémium laptopot nagy felbontású képernyővel. Ezt akarnád használni egy 27"-os 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) vagy egy 32"-os 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) kijelzőn is.

De ha nem 218-as vagy magasabb PPI-s kijelzőt használsz, érdemes módosítanod a monitor beállításait. Ha például 27"-os vagy 32"-os 4K kijelződ van, választhatsz hozzá tört méretezést a felső sáv monitorpaneljén, vagy beállíthatod az alapértelmezést minden monitorra a `~/.config/hypr/monitors.lua` fájl megnyitásával, és átállhatsz az adott kombinációhoz ajánlott értékre:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Ha 1080p vagy 1440p kijelzőt használsz, valószínűleg csak 1x-es méretezést akarsz, GTK és X11 alkalmazásoknál is ugyanúgy, így ezt használhatod:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

A `GDK_SCALE` módosításai a módosítás után indított alkalmazásokra érvényesek (és a GTK csak egész számokat kezel, ezért tartsd a monitor méretezéséhez legközelebbi egész számnál). Ezért a módosítás után mindenképp lépj ki azokból az ablakokból, amelyek túl nagyok maradtak (vagy zárj be minden ablakot a `Ctrl + Alt + Del` paranccsal!).

A `Super + /` billentyűvel gyorsan végigléphetsz a fő monitor-méretezési arányok között felfelé (1x, 1,25x, 1,6x, 2x, 3x, 4x), a `Super + Alt + /` billentyűvel lefelé, vagy választhatsz egyet a felső sáv monitorpaneljén is. Ezek csak arra a monitorra vonatkoznak, amelyiken éppen a fókusz van, így a laptop képernyője és egy külső kijelző külön-külön méretezést kaphat. A panel az egyes monitorok felbontását is beállítja. A választásaidat az adott fizikai monitorhoz a rendszer a `~/.local/state/omarchy/monitors/settings` fájlban menti, így azok újraindítás után is megmaradnak, és követik a monitort, bármelyik porthoz vagy dokkhoz csatlakoztasd is legközelebb. Ezek elsőbbséget élveznek az ugyanarra a monitorra vonatkozó szabályokkal szemben a `~/.config/hypr/monitors.lua` fájlban, amelyet az Omarchy soha nem szerkeszt. Mivel a `GDK_SCALE` egyetlen érték minden képernyőre, egy kiválasztott méretezés a legalacsonyabb méretezésű monitor alapján állítja be, így az X11 alkalmazások a sűrűbb képernyőn kicsit kisebbek lesznek, nem pedig túl nagyok a másikon.

### Szöveg nagyobbítása vagy kisebbítése

A monitor méretezése mindennek a méretét megváltoztatja. Ha csak nagyobb vagy kisebb _szöveget_ szeretnél, arra egyetlen kapcsoló szolgál:

```
omarchy display text size 14
```

Ez 9 és 20 közötti pixelméretet fogad el, és együtt mozgatja az Omarchy felületet, a GTK alkalmazásokat és a terminált, így az egész asztal arányos marad. Argumentum nélkül futtatva megnézheted, hol tartasz éppen, az `omarchy display text size reset` pedig visszaállítja az alapértelmezett értéket. A Foot az egyetlen lemaradó: nincs módja a konfigurációja újratöltésére, ezért a már futó terminálok megtartják a régi méretüket, amíg újat nem nyitsz.

### Laptopkijelzők kiterjesztése és tükrözése

Amikor külső képernyőt csatlakoztatsz a laptopodhoz, a kijelző automatikusan kiterjesztett lesz. Ezt azonban tükrözésre is átállíthatod az Omarchy menü _Trigger > Hardware_ pontján keresztül, vagy a `Super + Ctrl + Alt + Delete` billentyűvel. Ez különösen hasznos, ha az a külső képernyő egy projektor, és szeretnél valamit megmutatni munka közben.

Kiterjesztés használata esetén a laptop fedelének lehajtása automatikusan kikapcsolja a belső képernyőt. A fedél felnyitása visszakapcsolja azt. Ezt kézzel is vezérelheted az Omarchy menü _Trigger > Hardware_ pontján keresztül, vagy a `Super + Ctrl + Delete` billentyűvel.

### Több képernyő elrendezése

A Hyprland remekül működik több képernyővel. A felső sáv monitorpanelje ott rajzolja ki őket, ahol vannak: húzz egyet egy másik oldalához, hogy oda mozgasd, és az elrendezés minden monitor további beállításaival együtt mentésre kerül. Minden olyan dologért, amit a panel nem fed le, olvass tovább arról, hogyan rendezheted el őket [a Hyprland monitordokumentációjában](https://wiki.hypr.land/Configuring/Basics/Monitors/). Az Omarchyban ezek a `~/.config/hypr/monitors.lua` fájlba kerülnek `hl.monitor` bejegyzésekként — a fájl kommentelt példákkal érkezik egy adott monitor felbontásának, pozíciójának és forgatásának rögzítésére.

Minden monitornak megvan a saját 1-től 10-ig tartó munkaterület-készlete, így a `Super + 1` mindig annak a monitornak az első munkaterületét jelenti, amelyiken éppen vagy. A színfalak mögött a Hyprland továbbra is minden monitoron átívelően számozza a munkaterületeket: a laptop képernyője (vagy első monitor) kapja az 1–10-et, a következő monitor a 11–20-at, és így tovább, és minden monitor megtartja a saját blokkját minden alkalommal, amikor csatlakoztatod. Használd ezeket a számokat, ha [munkaterület-szabályokat](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) vagy ablaksabályokat írsz egy adott monitorhoz, így a 12-es munkaterület a második monitorod második munkaterülete. A `~/.local/state/omarchy/monitors/workspaces` felsorolja, melyik blokk melyik monitorhoz tartozik.

A nyílbillentyűk azokon a monitorokon át működnek, amelyek közös él mentén érintkeznek az elrendezésedben. Azok a képernyők, amelyek csak egy sarokban érintkeznek, vagy amelyek között rés van, nem szomszédok, ezért használj `Ctrl + Alt + Tab` billentyűt a közöttük való átjutáshoz.

| Gyorsbillentyű | Monitorok között |
| --- | --- |
| `Super + Arrow` | A fókuszt arra a monitorra helyezi azon az oldalon, amint abban az irányban már nem maradt ablak |
| `Super + Shift + Arrow` | Felcserélődik egy ablakkal azon az oldali monitoron |
| `Super + Alt + Arrow` | Az ablakot egy csoportba helyezi azon az oldali monitoron |
| `Super + Shift + Ctrl + Arrow` | Az ablakot azon az oldali monitorra helyezi, az éppen mutatott munkaterületre |
| `Super + Shift + Alt + Arrow` | A munkaterületet azon az oldali monitorra helyezi, megtartva a számát, ha szabad |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | A fókuszt a következő vagy előző monitorra helyezi, az elrendezéstől függetlenül |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Azon a monitoron marad, amelyiken vagy |

Megnézheted a [Hyprmon](https://github.com/erans/hyprmon/) alkalmazást is, ha TUI-t szeretnél, amely segít több képernyő pozicionálásában.

### Fényerő szabályozása

A monitor fényerejét a külön erre szolgáló funkcióbillentyűk szabályozzák a fényerő növelésére/csökkentésére. Ha lenyomva tartod a shift billentyűt ezek megnyomása közben, maximális vagy minimális fényerőre ugrasz. A billentyűk azt a kijelzőt szabályozzák, amelyiken a fókusz van, így a DDC/CI-t beszélő külső monitorok ugyanúgy állíthatók, mint a laptop képernyője.

### Apple kijelzők

Ha Apple kijelzőt használsz, a szokásos billentyűzetes fényerőbillentyűk is automatikusan működni fognak, ha a fókusz az Apple kijelzőn van. Ez az `asdcontrol` paranccsal történik.

Vedd figyelembe, hogy ha Apple 6K XDR kijelzőt használsz, fantomképernyőt láthatsz a `hyprctl monitors` listában. Ezt kikapcsolhatod például egy `hl.monitor({ output = "DP-2", disabled = true })` bejegyzéssel a `~/.config/hypr/monitors.lua` fájlban.

Intel gépeken szokásos Thunderbolt-kábellel kell csatlakoznod az Apple kijelzőkhöz. Thunderbolt nélküli gépeken általában [DP + USB-A -> USB-C kábelt](https://www.amazon.com/dp/B0BNX7MS6N) kell használnod, hogy működjön.
