# Monitorok

Az Omarchy alapértelmezetten abból indul ki, hogy 2x-es léptékezésre képes, retina osztályú kijelzőt használsz. Erre van szükséged ahhoz, hogy megkapd azokat a szép, éles programozóbetűtípusokat. Szinte minden új, nagy felbontású képernyővel szerelt prémium laptop erre van optimalizálva. Ilyet akarnál használni egy 27"-os 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) vagy egy 32"-os 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) kijelzőn.

De ha nem 218 vagy annál nagyobb PPI értékű kijelzőt használsz, meg akarod majd változtatni a monitorbeállításokat. Ha például 27"-os vagy 32"-os 4K kijelződ van, a felső sávban lévő monitorpanelen választhatsz hozzá tört léptékezést, vagy minden monitorra beállíthatod az alapértelmezést a `~/.config/hypr/monitors.lua` megnyitásával, és átállhatsz az adott kombinációhoz ajánlott értékre:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Ha 1080p vagy 1440p kijelzőt használsz, valószínűleg egyszerűen 1x-es léptékezést akarsz használni, GTK és X11 alkalmazásoknál is ugyanazt, így ezt használhatod:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

A `GDK_SCALE` módosításai a módosítás után indított alkalmazásokra vonatkoznak (és a GTK csak egész számokat fogad el, ezért tartsd a monitor léptékezéséhez legközelebbi egész számnál). Ezért a módosítás után mindenképpen lépj ki azokból az ablakokból, amelyek túl nagyok lettek (vagy zárd be az összes ablakot a `Ctrl + Alt + Del` billentyűkombinációval!).

A fő monitorléptékezési arányok (1x, 1.25x, 1.6x, 2x, 3x, 4x) között gyorsan is lépkedhetsz: a `Super + /` felfelé visz, a `Super + Alt + /` pedig lefelé, vagy kiválaszthatsz egyet a felső sávban lévő monitorpanelről. Ezek csak azt a monitort módosítják, amelyikre éppen fókuszálsz, így a laptop képernyője és egy külső kijelző is saját léptékezést kaphat. A panel az egyes monitorok felbontását, frissítési gyakoriságát és elforgatását is beállítja. A választásaidat a rendszer az adott fizikai monitorhoz a `~/.local/state/omarchy/monitors/settings` fájlban menti, így újraindítás után is megmaradnak, és követik a monitort, bármelyik portra vagy dokkra csatlakoztatod is legközelebb. Ezek elsőbbséget élveznek ugyanannak a monitornak a `~/.config/hypr/monitors.lua` fájlban lévő bármely szabályával szemben, amelyet az Omarchy soha nem szerkeszt. Ha inkább teljes egészében abban a fájlban állítanád be a monitoraidat, add hozzá az `omarchy_monitor_panel_settings = false` sort, és a panel módosításai csak addig maradnak érvényben, amíg a Hyprland újra nem töltődik. Mivel a `GDK_SCALE` egyetlen érték az összes képernyőre, a választott léptékezés a legalacsonyabb léptékezésű monitor alapján állítja be, így az X11 alkalmazások inkább egy kicsit kicsik lesznek a sűrűbb képernyőn, mintsem túl nagyok a másikon.

### A szöveg nagyobbá vagy kisebbé tétele

A monitor léptékezése mindennek a méretét megváltoztatja. Ha csak nagyobb vagy kisebb _szöveget_ szeretnél, arra egyetlen kapcsoló szolgál:

```
omarchy display text size 14
```

Ez 9 és 20 közötti pixelméretet fogad el, és együtt mozgatja az Omarchy felületét, a GTK alkalmazásokat és a terminálodat, így az egész asztal arányos marad. Argumentum nélkül futtatva megnézheted, hol tartasz éppen, az `omarchy display text size reset` paranccsal pedig visszaállhatsz az alapértelmezésre. A Foot az egyetlen lemaradó: nincs módja a konfigurációja újratöltésére, így a futó terminálok megtartják a régi méretüket, amíg újat nem nyitsz.

### Laptopkijelzők kiterjesztése és tükrözése

Amikor külső képernyőt csatlakoztatsz a laptopodhoz, a kijelző automatikusan kiterjesztődik. Ezt azonban tükrözésre is átállíthatod a felső sávban lévő monitorpanel _Extend_ | _Mirror_ beállításával, az Omarchy menü _Trigger > Hardware_ pontjában, vagy a `Super + Ctrl + Alt + Delete` billentyűkombinációval. Ez különösen akkor hasznos, ha az a külső képernyő egy projektor, és munka közben szeretnél valamit megmutatni.

Kiterjesztéskor a laptop fedelének lecsukása automatikusan kikapcsolja a belső képernyőt. A fedél felnyitása visszakapcsolja. Ezt kézzel is vezérelheted az Omarchy menü _Trigger > Hardware_ pontjában, vagy a `Super + Ctrl + Delete` billentyűkombinációval.

### Több képernyő elrendezése

A Hyprland remekül működik több képernyővel. A felső sávban lévő monitorpanel ott rajzolja ki őket, ahol éppen vannak: húzz egyet egy másik oldalához, hogy oda mozgasd, és az elrendezést a rendszer az egyes monitorok többi beállításával együtt menti. Minden másról, amire a panel nem terjed ki, bővebben [a Hyprland monitordokumentációjában](https://wiki.hypr.land/Configuring/Basics/Monitors/) olvashatsz. Az Omarchyban ezek a `~/.config/hypr/monitors.lua` fájlba kerülnek `hl.monitor` bejegyzésekként — a fájl kommentelt példákat tartalmaz monitor kikapcsolva tartásához, a panel által nem kínált módokhoz, 10 bites színhez és változó frissítési gyakorisághoz.

Minden monitornak saját 1-től 10-ig terjedő munkaterületei vannak, így a `Super + 1` mindig annak a monitornak az első munkaterületét jelenti, amelyiken éppen vagy. A háttérben a Hyprland továbbra is az összes monitoron átívelően számozza a munkaterületeket: a laptop képernyője (vagy az első monitor) kapja az 1–10 tartományt, a következő monitor a 11–20 tartományt, és így tovább, és minden monitor minden csatlakoztatáskor megtartja a saját blokkját. Ezeket a számokat használd, ha [munkaterület-szabályokat](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) vagy ablakszabályokat írsz egy adott monitorhoz, így a 12-es munkaterület a második monitorod második munkaterülete. A `~/.local/state/omarchy/monitors/workspaces` felsorolja, melyik monitor melyik blokkot kapta.

A nyílbillentyűk az elrendezésedben közös éllel érintkező monitorok között működnek. Azok a képernyők, amelyek csak egy sarokban érintkeznek, vagy amelyek között rés van, nem szomszédok, ezért a `Ctrl + Alt + Tab` billentyűkombinációval juthatsz át közöttük.

| Gyorsbillentyű | Monitorok között |
| --- | --- |
| `Super + Arrow` | A fókuszt az azon az oldalon lévő monitorra viszi, ha abban az irányban már nincs több ablak |
| `Super + Shift + Arrow` | Ablakot cserél az azon az oldalon lévő monitoron lévő ablakkal |
| `Super + Alt + Arrow` | Az ablakot az azon az oldalon lévő monitoron lévő csoportba mozgatja |
| `Super + Shift + Ctrl + Arrow` | Az ablakot az azon az oldalon lévő monitorra mozgatja, az általa éppen mutatott munkaterületre |
| `Super + Shift + Alt + Arrow` | A munkaterületet az azon az oldalon lévő monitorra mozgatja, megtartva a számát, ha az szabad |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | A fókuszt a következő vagy az előző monitorra viszi, bármilyen is az elrendezés |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Azon a monitoron maradnak, amelyiken éppen vagy |

Nézd meg a [Hyprmon](https://github.com/erans/hyprmon/) alkalmazást is, ha szeretnél egy TUI-t, amely segít több képernyő elhelyezésében.

### A fényerő szabályozása

A monitor fényerejét a fényerő növelésére és csökkentésére szolgáló dedikált funkcióbillentyűk szabályozzák. Ha ezek megnyomása közben lenyomva tartod a Shift billentyűt, maximális vagy minimális fényerőre ugrasz. A billentyűk azt a kijelzőt szabályozzák, amelyikre éppen fókuszálsz, így a DDC/CI protokollt beszélő külső monitorok ugyanúgy állíthatók, mint a laptop képernyője.

### Apple kijelzők

Ha Apple kijelzőt használsz, a szokásos billentyűzetes fényerőbillentyűk automatikusan működni fognak akkor is, ha az Apple kijelzőre fókuszálsz. Ez az `asdcontrol` paranccsal történik.

Ne feledd, hogy Apple 6K XDR kijelző használata esetén fantomképernyőt láthatsz a `hyprctl monitors` listájában. Ezt a `~/.config/hypr/monitors.lua` fájlban valami ilyesmivel kapcsolhatod ki: `hl.monitor({ output = "DP-2", disabled = true })`.

Intel gépeken rendes Thunderbolt kábellel érdemes Apple kijelzőkhöz csatlakoznod. Más, Thunderbolt nélküli gépeken általában [DP + USB-A -> USB-C kábelt](https://www.amazon.com/dp/B0BNX7MS6N) kell használnod, hogy működjön.
