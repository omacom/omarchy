# Monitorok

Az Omarchy alapértelmezés szerint abból indul ki, hogy 2x-es méretezésre képes, retina-kategóriás kijelzőt használsz. Erre van szükséged ahhoz, hogy megkapd azokat a szép, éles programozóbetűtípusokat. Szinte az összes új, nagy felbontású képernyővel szerelt prémium laptop erre van optimalizálva. Ezt akarnád futtatni egy 27"-os 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) vagy egy 32"-os 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) kijelzőn.

De ha nem 218-as vagy annál nagyobb PPI-vel rendelkező kijelzőt használsz, érdemes módosítanod a monitorbeállításokat. Ha például 27"-os vagy 32"-os 4K kijelződ van, a felső sávban található monitorpanelen kiválaszthatsz hozzá egy tört méretezést, vagy beállíthatod az alapértelmezést minden monitorra a `~/.config/hypr/monitors.lua` fájl megnyitásával, és átválthatsz az adott kombinációhoz ajánlott értékre:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Ha 1080p-s vagy 1440p-s kijelzőt használsz, valószínűleg egyszerűen 1x-es méretezést akarsz használni, és ugyanezt a GTK- és X11-alkalmazásokhoz is, így ezt használhatod:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

A `GDK_SCALE` módosításai a módosítás után indított alkalmazásokra vonatkoznak (és a GTK csak egész számokat fogad el, ezért tartsd a monitor méretezéséhez legközelebbi egész számnál). Ezért a módosítás után mindenképp lépj ki azokból az ablakokból, amelyek túl nagyok (vagy zárd be az összes ablakot a `Ctrl + Alt + Del` billentyűkombinációval!).

A fő monitor-méretezési arányok (1x, 1.25x, 1.6x, 2x, 3x, 4x) között gyorsan is lépegethetsz a `Super + /` billentyűkombinációval felfelé és a `Super + Alt + /` billentyűkombinációval lefelé, vagy kiválaszthatsz egyet a felső sávban lévő monitorpanelen. Ezek csak azt a monitort módosítják, amelyiken a fókusz van, így a laptop képernyője és egy külső kijelző külön-külön méretezést kaphat. A panel az egyes monitorok felbontását, frissítési gyakoriságát és elforgatását is beállítja. A választásaidat a rendszer az adott fizikai monitorhoz a `~/.local/state/omarchy/monitors/settings` fájlban menti, így azok újraindítás után is megmaradnak, és követik a monitort, bármelyik portra vagy dokkra csatlakoztatod is legközelebb. Ezek elsőbbséget élveznek az ugyanarra a monitorra vonatkozó minden szabállyal szemben a `~/.config/hypr/monitors.lua` fájlban, amelyet az Omarchy soha nem szerkeszt. Ha inkább teljes egészében abban a fájlban állítanád be a monitoraidat, add hozzá az `omarchy_monitor_panel_settings = false` sort, és a panel módosításai csak addig maradnak érvényben, amíg a Hyprland újra nem töltődik. Mivel a `GDK_SCALE` egyetlen érték az összes képernyőre, a választott méretezés a legalacsonyabb méretezésű monitor alapján állítja be, így az X11-alkalmazások inkább egy kicsit kicsik lesznek a sűrűbb képernyőn, semmint túl nagyok a másikon.

### A szöveg nagyobbá vagy kisebbé tétele

A monitor méretezése mindennek a méretét megváltoztatja. Ha csak nagyobb vagy kisebb _szöveget_ szeretnél, arra egyetlen beállítás szolgál:

```
omarchy display text size 14
```

Ez 9 és 20 közötti pixelméretet fogad el, és együtt mozgatja az Omarchy felületét, a GTK-alkalmazásokat és a terminálodat, így az egész asztal arányos marad. Argumentum nélkül futtatva megnézheted, hol tartasz éppen, az `omarchy display text size reset` paranccsal pedig visszaállhatsz az alapértelmezésre. A Foot az egyetlen lemaradó: nincs módja a konfigurációja újratöltésére, így a futó terminálok megtartják a régi méretüket, amíg újat nem nyitsz.

### Laptopkijelzők kiterjesztése és tükrözése

Amikor külső képernyőt csatlakoztatsz a laptopodhoz, a kijelző automatikusan kiterjesztésre kerül. Ezt azonban tükrözésre is átállíthatod az Omarchy menüben a _Trigger > Hardware_ alatt vagy a `Super + Ctrl + Alt + Delete` billentyűkombinációval. Ez különösen akkor hasznos, ha az a külső képernyő egy projektor, és munka közben szeretnél valamit megmutatni.

Kiterjesztés közben a laptop fedelének lecsukása automatikusan kikapcsolja a belső képernyőt. A fedél felnyitása visszakapcsolja azt. Ezt kézzel is vezérelheted az Omarchy menüben a _Trigger > Hardware_ alatt vagy a `Super + Ctrl + Delete` billentyűkombinációval.

### Több képernyő elrendezése

A Hyprland remekül működik több képernyővel. A felső sávban lévő monitorpanel ott rajzolja ki őket, ahol vannak: húzz egyet egy másik oldalához, hogy oda mozgasd, és az elrendezés minden monitor többi beállításával együtt mentésre kerül. Minden olyan dologhoz, amit a panel nem fed le, olvass tovább arról, hogyan rendezheted el őket a [Hyprland monitor dokumentációjában](https://wiki.hypr.land/Configuring/Basics/Monitors/). Az Omarchyban ezek a `~/.config/hypr/monitors.lua` fájlba kerülnek `hl.monitor` bejegyzésekként — a fájl kommentelt példákkal érkezik monitor kikapcsolva tartásához, a panel által nem kínált módokhoz, 10 bites színhez és változó frissítési gyakorisághoz.

Minden monitornak megvan a saját 1-től 10-ig terjedő munkaterület-sorozata, így a `Super + 1` mindig annak a monitornak az első munkaterületét jelenti, amelyiken éppen vagy. A háttérben a Hyprland továbbra is az összes monitoron átívelően számozza a munkaterületeket: a laptopod képernyője (vagy az első monitor) kapja az 1–10-et, a következő monitor a 11–20-at, és így tovább, és minden monitor minden csatlakoztatáskor megtartja a saját blokkját. Ezeket a számokat használd, ha [munkaterület-szabályokat](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) vagy ablaksabályokat írsz egy adott monitorhoz, így a 12-es munkaterület a második monitorod második munkaterülete. A `~/.local/state/omarchy/monitors/workspaces` fájl felsorolja, melyik monitor melyik blokkot kapta.

A nyílbillentyűk az elrendezésedben közös éllel érintkező monitorok között működnek. Azok a képernyők, amelyek csak egy sarokban érintkeznek, vagy amelyek között rés van, nem szomszédok, ezért a `Ctrl + Alt + Tab` billentyűkombinációval juthatsz át közöttük.

| Gyorsbillentyű | Monitorok között |
| --- | --- |
| `Super + Arrow` | Átviszi a fókuszt az azon az oldalon lévő monitorra, amint már nincs ablak abban az irányban |
| `Super + Shift + Arrow` | Ablakot cserél az azon az oldalon lévő monitoron lévő ablakkal |
| `Super + Alt + Arrow` | Átmozgatja az ablakot egy csoportba az azon az oldalon lévő monitoron |
| `Super + Shift + Ctrl + Arrow` | Átmozgatja az ablakot az azon az oldalon lévő monitorra, az általa éppen mutatott munkaterületre |
| `Super + Shift + Alt + Arrow` | Átmozgatja a munkaterületet az azon az oldalon lévő monitorra, megtartva a számát, ha az szabad |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Átviszi a fókuszt a következő vagy előző monitorra, az elrendezéstől függetlenül |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Azon a monitoron marad, amelyiken vagy |

Nézd meg a [Hyprmon](https://github.com/erans/hyprmon/) projektet is, ha egy TUI-t szeretnél, amely segít a több képernyő pozicionálásában.

### A fényerő szabályozása

A monitor fényerejét a fényerő növelésére/csökkentésére szolgáló dedikált funkcióbillentyűk szabályozzák. Ha lenyomva tartod a shift billentyűt, miközben megnyomod ezeket, a maximális vagy minimális fényerőre ugrasz. A billentyűk azt a kijelzőt szabályozzák, amelyiken a fókusz van, így a DDC/CI-t beszélő külső monitorok ugyanúgy állíthatók, mint a laptop képernyője.

### Apple kijelzők

Ha Apple kijelzőt használsz, a szokásos billentyűzetes fényerőbillentyűk automatikusan működni fognak akkor is, ha az Apple kijelzőn van a fókusz. Ez az `asdcontrol` paranccsal történik.

Megjegyzés: ha Apple 6K XDR kijelzőt használsz, fantomképernyőt láthatsz a `hyprctl monitors` listázásában. Ezt kikapcsolhatod valami ilyesmivel: `hl.monitor({ output = "DP-2", disabled = true })` a `~/.config/hypr/monitors.lua` fájlban.

Intel gépeken szokásos Thunderbolt-kábellel érdemes Apple kijelzőkhöz csatlakoznod. Thunderbolt nélküli más gépeken általában egy [DP + USB-A -> USB-C kábelt](https://www.amazon.com/dp/B0BNX7MS6N) kell használnod, hogy működjön.
