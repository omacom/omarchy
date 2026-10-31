# Monitorok

Az Omarchy alapértelmezés szerint abból indul ki, hogy 2x-es méretezésre képes, retina-szintű kijelzőt használsz. Erre van szükséged ahhoz, hogy megkapd azokat a szép, éles programozóbetűtípusokat. Szinte minden új, nagy felbontású képernyővel rendelkező prémium laptop erre van optimalizálva. Ezt akarod majd használni egy 27"-os 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) vagy egy 32"-os 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) kijelzőn.

Ha viszont nem 218-as vagy annál nagyobb PPI-vel rendelkező kijelzőt használsz, módosítanod kell a monitorbeállításokat. Ha például 27"-os vagy 32"-os 4K kijelződ van, választhatsz hozzá tört méretezést a felső sávban található monitorpanelről, vagy beállíthatod az alapértelmezést minden monitorra a `~/.config/hypr/monitors.lua` megnyitásával, és átállhatsz az ahhoz a kombinációhoz ajánlott értékre:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Ha 1080p vagy 1440p kijelzőt használsz, valószínűleg egyszerűen 1x-es méretezést akarsz használni, és ugyanezt a GTK- és X11-alkalmazásokhoz is, így ezt használhatod:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

A `GDK_SCALE` módosításai a módosítás után indított alkalmazásokra vonatkoznak (és a GTK csak egész számokat fogad el, ezért tartsd a monitor méretezéséhez legközelebbi egész számnál). Ezért a módosítás után mindenképpen lépj ki azokból az ablakokból, amelyek túl naggyá váltak (vagy zárd be az összes ablakot a `Ctrl + Alt + Del` billentyűkombinációval!).

Gyorsan végig is lépkedhetsz a fő monitor-méretezési arányokon (1x, 1.25x, 1.6x, 2x, 3x, 4x) a `Super + /` billentyűkombinációval felfelé és a `Super + Alt + /` billentyűkombinációval lefelé, vagy kiválaszthatsz egyet a felső sávban található monitorpanelről. Ezek csak azt a monitort módosítják, amelyiken a fókusz van, így a laptop képernyője és egy külső kijelző is rendelkezhet saját méretezéssel. A panel az egyes monitorok felbontását is beállítja. A választásaid az adott fizikai monitorhoz a `~/.local/state/omarchy/monitors/settings` fájlba kerülnek mentésre, így újraindítás után is megmaradnak, és követik a monitort bármelyik porthoz vagy dokkhoz csatlakoztatod is legközelebb. Ezek elsőbbséget élveznek ugyanannak a monitornak a `~/.config/hypr/monitors.lua` fájlban szereplő bármely szabályával szemben, amelyet az Omarchy soha nem szerkeszt. Ha inkább teljes egészében abban a fájlban állítanád be a monitorjaidat, add hozzá az `omarchy_monitor_panel_settings = false` beállítást, és a panel módosításai csak addig maradnak érvényben, amíg a Hyprland újra nem töltődik. Mivel a `GDK_SCALE` egyetlen érték az összes képernyőre, a kiválasztott méretezés a legalacsonyabb méretezésű monitor alapján állítja be, így az X11-alkalmazások a sűrűbb képernyőn egy kicsit kicsinek jelennek meg, ahelyett hogy a másikon túl nagyok lennének.

### A szöveg nagyobbá vagy kisebbé tétele

A monitor méretezése mindennek a méretét megváltoztatja. Ha csak nagyobb vagy kisebb _szöveget_ szeretnél, arra egyetlen kapcsoló szolgál:

```
omarchy display text size 14
```

Ez 9 és 20 közötti képpontméretet fogad el, és együtt mozgatja az Omarchy felületét, a GTK-alkalmazásokat és a terminálodat, így az egész asztal arányos marad. Futtasd argumentum nélkül, hogy lásd, hol tartasz éppen, a `omarchy display text size reset` paranccsal pedig visszatérhetsz az alapértelmezéshez. A Foot az egyetlen lemaradó: nincs módja a konfigurációja újratöltésére, így a futó terminálok megtartják a régi méretüket, amíg nem nyitsz újat.

### Laptopkijelzők kiterjesztése és tükrözése

Ha külső képernyőt csatlakoztatsz a laptopodhoz, a kijelző automatikusan kiterjesztésre kerül. Ezt azonban tükrözésre is átállíthatod az Omarchy menüben a _Trigger > Hardware_ segítségével vagy a `Super + Ctrl + Alt + Delete` billentyűkombinációval. Ez különösen hasznos, ha az a külső képernyő egy kivetítő, és szeretnél valamit megmutatni munka közben.

Kiterjesztéskor a laptop fedelének lecsukása automatikusan kikapcsolja a belső képernyőt. A fedél felnyitása visszakapcsolja azt. Ezt manuálisan is vezérelheted az Omarchy menüben a _Trigger > Hardware_ segítségével vagy a `Super + Ctrl + Delete` billentyűkombinációval.

### Több képernyő elrendezése

A Hyprland nagyszerűen működik több képernyővel. A felső sávban található monitorpanel ott rajzolja ki őket, ahol vannak: húzz egyet egy másik oldalához, hogy oda mozgasd, és az elrendezés az egyes monitorok egyéb beállításaival együtt mentésre kerül. Minden olyan dologért, amit a panel nem fed le, olvass tovább arról, hogyan rendezheted el őket a [Hyprland monitor dokumentációjában](https://wiki.hypr.land/Configuring/Basics/Monitors/). Az Omarchyban ezek a `~/.config/hypr/monitors.lua` fájlba kerülnek `hl.monitor` bejegyzésekként — a fájl kommentelt példákkal érkezik egy adott monitor felbontáshoz, pozícióhoz és forgatáshoz rögzítéséhez.

Minden monitornak saját 1-től 10-ig terjedő munkaterületei vannak, így a `Super + 1` mindig az éppen használt monitor első munkaterületét jelenti. A háttérben a Hyprland továbbra is az összes monitoron átívelően számozza a munkaterületeket: a laptop képernyője (vagy az első monitor) kapja az 1–10-et, a következő monitor a 11–20-at, és így tovább, és minden monitor megtartja a blokkját minden alkalommal, amikor csatlakoztatod. Használd ezeket a számokat, ha [munkaterület-szabályokat](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) vagy ablaksabályokat írsz egy adott monitorhoz, így a 12-es munkaterület a második monitor második munkaterülete. A `~/.local/state/omarchy/monitors/workspaces` felsorolja, hogy melyik monitor melyik blokkot kapta.

A nyílbillentyűk az elrendezésedben közös éllel érintkező monitorok között működnek. Azok a képernyők, amelyek csak egy saroknál érintkeznek, vagy amelyek között rés van, nem szomszédok, ezért a `Ctrl + Alt + Tab` billentyűkombinációval juthatsz át közöttük.

| Gyorsbillentyű | Monitorok között |
| --- | --- |
| `Super + Arrow` | Átviszi a fókuszt az azon az oldalon lévő monitorra, amint már nincs ablak abban az irányban |
| `Super + Shift + Arrow` | Felcseréli az azon az oldalon lévő monitoron lévő ablakkal |
| `Super + Alt + Arrow` | Átviszi az ablakot az azon az oldalon lévő monitoron lévő csoportba |
| `Super + Shift + Ctrl + Arrow` | Átviszi az ablakot az azon az oldalon lévő monitorra, az általa mutatott munkaterületre |
| `Super + Shift + Alt + Arrow` | Átviszi a munkaterületet az azon az oldalon lévő monitorra, megtartva a számát, ha szabad |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Átviszi a fókuszt a következő vagy az előző monitorra, az elrendezéstől függetlenül |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Az éppen használt monitoron marad |

Megnézheted a [Hyprmon](https://github.com/erans/hyprmon/) alkalmazást is, ha egy TUI-t szeretnél, amely segít több képernyő elhelyezésében.

### A fényerő szabályozása

A monitor fényerejét a fényerő növelésére és csökkentésére szolgáló dedikált funkcióbillentyűk szabályozzák. Ha ezek megnyomása közben lenyomva tartod a Shift billentyűt, a maximális vagy a minimális fényerőre ugrasz. A billentyűk azt a kijelzőt szabályozzák, amelyiken a fókusz van, így a DDC/CI protokollt használó külső monitorok ugyanúgy állíthatók, mint a laptop képernyője.

### Apple kijelzők

Ha Apple kijelzőt használsz, a szokásos billentyűzetes fényerőbillentyűk is automatikusan működni fognak, ha a fókusz az Apple kijelzőn van. Ez az `asdcontrol` paranccsal történik.

Vedd figyelembe, hogy ha Apple 6K XDR kijelzőt használsz, fantomképernyőt láthatsz a `hyprctl monitors` listádban. Ezt kikapcsolhatod például a `hl.monitor({ output = "DP-2", disabled = true })` bejegyzéssel a `~/.config/hypr/monitors.lua` fájlban.

Intel gépeken szokásos Thunderbolt-kábellel érdemes az Apple kijelzőkhöz csatlakoznod. Más, Thunderbolt nélküli gépeken általában [DP + USB-A -> USB-C kábelt](https://www.amazon.com/dp/B0BNX7MS6N) kell használnod, hogy működjön.
