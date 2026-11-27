# Monitorok

Az Omarchy alapértelmezetten feltételezi, hogy 2x-es skálázásra alkalmas, retina-szintű kijelzőt használsz. Erre van szükséged, hogy megkapd azokat a szép, éles programozó betűtípusokat. Szinte minden új, nagy felbontású képernyővel ellátott prémium laptopot erre optimalizáltak. Ilyen kijelzőn akarod futtatni egy 27"-os 5K-s [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) vagy egy 32"-os 6K-s [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) esetében.

De ha nem 218 vagy annál nagyobb PPI-jű kijelzőt használsz, érdemes megváltoztatnod a monitorbeállításokat. Ha például 27"-os vagy 32"-os 4K kijelződ van, választhatsz hozzá törtszámú skálázást a felső sáv monitorpaneljéről, vagy beállíthatod az alapértelmezést minden monitorra a `~/.config/hypr/monitors.lua` megnyitásával, és átállhatsz az adott kombinációhoz javasolt beállításra:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Ha 1080p-s vagy 1440p-s kijelzőt használsz, valószínűleg egyszerűen csak 1x-es skálázást akarsz, és ugyanezt a GTK és X11 alkalmazásoknál is, így ezt használhatod:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

A `GDK_SCALE` módosításai a módosítás után indított alkalmazásokra érvényesek (és a GTK csak egész számokat fogad el, ezért tartsd a monitor skálázásához legközelebbi egész számnál). Ezért mindenképp lépj ki azokból az ablakokból, amelyek a módosítás után túl nagyok maradtak (vagy zárd be az összes ablakot a `Ctrl + Alt + Del` billentyűkombinációval!).

Gyorsan végig is lépkedhetsz a fő monitor-skálázási arányokon (1x, 1.25x, 1.6x, 2x, 3x, 4x) a `Super + /` segítségével felfelé, a `Super + Alt + /` segítségével pedig lefelé, vagy kiválaszthatsz egyet a felső sáv monitorpaneljéről. Ezek csak azt a monitort módosítják, amelyiken a fókusz van, így a laptop képernyője és egy külső kijelző is külön skálázást kaphat. A panel beállítja minden monitor felbontását, frissítési frekvenciáját és elforgatását is. A választásaid az adott fizikai monitorhoz a `~/.local/state/omarchy/monitors/settings` fájlba mentődnek, így újraindítás után is megmaradnak, és követik a monitort, bármelyik porthoz vagy dokkhoz csatlakoztatod is legközelebb. Ezek elsőbbséget élveznek ugyanannak a monitornak a `~/.config/hypr/monitors.lua` fájlban szereplő bármely szabályával szemben, amelyet az Omarchy soha nem szerkeszt. Ha inkább teljes egészében abban a fájlban állítanád be a monitorjaidat, add hozzá az `omarchy_monitor_panel_settings = false` beállítást, és a panel módosításai csak addig maradnak meg, amíg a Hyprland újra nem töltődik. Mivel a `GDK_SCALE` egyetlen érték az összes képernyőhöz, a választott skálázás a legalacsonyabb skálázású monitor alapján állítja be, így az X11 alkalmazások inkább egy kicsit kicsik lesznek a sűrűbb képernyőn, mintsem túl nagyok a másikon.

### A szöveg nagyítása vagy kicsinyítése

A monitor skálázása mindennek a méretét megváltoztatja. Ha csak nagyobb vagy kisebb _szöveget_ szeretnél, arra egyetlen beállítás szolgál:

```
omarchy display text size 14
```

Ez 9 és 20 közötti pixelméretet fogad el, és együtt állítja az Omarchy felületét, a GTK alkalmazásokat és a terminálodat, így az egész asztal arányos marad. Argumentum nélkül futtatva megnézheted, hol tartasz éppen, a `omarchy display text size reset` pedig visszaállítja az alapértelmezést. A Foot az egyetlen lemaradó: nem tudja újratölteni a konfigurációját, így a futó terminálok megtartják a régi méretet, amíg nem nyitsz egy újat.

### A laptop kijelzőjének kiterjesztése és tükrözése

Amikor külső képernyőt csatlakoztatsz a laptophoz, a kijelző automatikusan kiterjesztetté válik. Ezt azonban tükrözésre is átállíthatod a felső sáv monitorpaneljén található _Extend_ | _Mirror_ opcióval, az Omarchy menüben a _Trigger > Hardware_ alatt, vagy a `Super + Ctrl + Alt + Delete` billentyűkombinációval. Ez különösen hasznos, ha az a külső képernyő egy projektor, és szeretnél valamit megmutatni munka közben.

Kiterjesztéskor a laptop fedelének lecsukása automatikusan kikapcsolja a belső képernyőt. A fedél felnyitása visszakapcsolja azt. Ezt kézzel is vezérelheted az Omarchy menü _Trigger > Hardware_ pontján keresztül, vagy a `Super + Ctrl + Delete` billentyűkombinációval.

Amíg a laptop áramforráshoz van csatlakoztatva, a fedél lecsukása soha nem altatja el, így a dokkolt laptop ébren marad akkor is, ha a külső képernyő rövid időre lecsatlakozik. Ha nincs külső képernyő csatlakoztatva, a fedél lecsukása hálózati táplálás mellett csak zárolja azt. Akkumulátoron a fedél lecsukása a megszokott módon felfüggeszti a működést.

### Több képernyő elrendezése

A Hyprland nagyszerűen működik több képernyővel. A felső sáv monitorpanelje ott rajzolja őket, ahol éppen vannak: húzz egyet egy másik oldalához, hogy oda kerüljön, és az elrendezés minden monitor többi beállításával együtt mentésre kerül. Minden olyan esethez, amelyet a panel nem fed le, olvass bővebben az elrendezésükről [a Hyprland monitordokumentációjában](https://wiki.hypr.land/Configuring/Basics/Monitors/). Az Omarchyban ezek a `~/.config/hypr/monitors.lua` fájlba kerülnek `hl.monitor` bejegyzésekként — a fájl kommentelt példákkal érkezik a monitor kikapcsolva tartásához, a panel által nem kínált módokhoz, a 10 bites színhez és a változó frissítési frekvenciához.

Minden monitornak saját, 1-től 10-ig terjedő munkaterületei vannak, így a `Super + 1` mindig annak a monitornak az első munkaterületét jelenti, amelyiken éppen vagy. A háttérben a Hyprland továbbra is az összes monitoron átívelően számozza a munkaterületeket: a laptop képernyője (vagy az első monitor) kapja az 1–10-et, a következő monitor a 11–20-at, és így tovább, és minden monitor megtartja a saját blokkját minden alkalommal, amikor csatlakoztatod. Ezeket a számokat használd, ha [munkaterület-szabályokat](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) vagy ablaksabályokat írsz egy adott monitorhoz, így a 12-es munkaterület a második monitorod második munkaterülete. A `~/.local/state/omarchy/monitors/workspaces` felsorolja, melyik blokk melyik monitorhoz tartozik.

A nyílbillentyűk az elrendezésedben közös éllel érintkező monitorok között működnek. Azok a képernyők, amelyek csak egy sarokban érnek össze, vagy amelyek között rés van, nem szomszédosak, ezért a `Ctrl + Alt + Tab` segítségével juthatsz át közöttük.

| Gyorsbillentyű | Monitorok között |
| --- | --- |
| `Super + Arrow` | Áthelyezi a fókuszt az azon az oldalon lévő monitorra, amint már nincs ablak abban az irányban |
| `Super + Shift + Arrow` | Felcseréli az azon az oldalon lévő monitoron található ablakkal |
| `Super + Alt + Arrow` | Áthelyezi az ablakot egy csoportba az azon az oldalon lévő monitoron |
| `Super + Shift + Ctrl + Arrow` | Áthelyezi az ablakot az azon az oldalon lévő monitorra, az általa éppen mutatott munkaterületre |
| `Super + Shift + Alt + Arrow` | Áthelyezi a munkaterületet az azon az oldalon lévő monitorra, megtartva a számát, ha az szabad |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Áthelyezi a fókuszt a következő vagy előző monitorra, az elrendezéstől függetlenül |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Azon a monitoron marad, amelyiken éppen vagy |

Érdemes megnézned a [Hyprmon](https://github.com/erans/hyprmon/) eszközt is, ha szeretnél egy TUI-t, amely segít a több képernyő elhelyezésében.

### A fényerő szabályozása

A monitor fényerejét a fényerő növelésére és csökkentésére szolgáló dedikált funkcióbillentyűk szabályozzák. Ha ezek megnyomása közben lenyomva tartod a shift billentyűt, maximális vagy minimális fényerőre ugrasz. A billentyűk azt a kijelzőt szabályozzák, amelyiken a fókusz van, így a DDC/CI-t ismerő külső monitorok ugyanúgy állíthatók, mint a laptop képernyője.

### Apple kijelzők

Ha Apple kijelzőt használsz, a szokásos billentyűzeti fényerőbillentyűk automatikusan működni fognak akkor is, ha az Apple kijelzőn van a fókusz. Ez az `asdcontrol` paranccsal történik.

Vedd figyelembe, hogy ha Apple 6K XDR kijelzőt használsz, egy fantomképernyőt láthatsz a `hyprctl monitors` listájában. Ezt valami ilyesmivel kapcsolhatod ki: `hl.monitor({ output = "DP-2", disabled = true })` a `~/.config/hypr/monitors.lua` fájlban.

Intel gépeken szokásos Thunderbolt kábellel érdemes Apple kijelzőkhöz csatlakoznod. Thunderbolt nélküli más gépeken általában egy [DP + USB-A -> USB-C kábelt](https://www.amazon.com/dp/B0BNX7MS6N) kell használnod, hogy működjön.
