# Monitorok

Az Omarchy alapértelmezés szerint abból indul ki, hogy 2x-es skálázásra képes, retina osztályú kijelzőt használsz. Erre van szükséged a szép, éles programozóbetűtípusokhoz. Erre optimalizáltak szinte minden új prémium laptopot nagy felbontású képernyővel. Ezt akarnád használni egy 27"-os 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) vagy 32"-os 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) kijelzőn.

De ha nem 218-as vagy nagyobb PPI-jű kijelzőt használsz, meg kell változtatnod a monitorbeállításokat. Ha például 27"-os vagy 32"-os 4K kijelződ van, tört skálázást használhatsz: nyisd meg a `~/.config/hypr/monitors.lua` fájlt (az Omarchy menüben a _Setup > Monitors_ menüpont alatt), és válts az ahhoz a kombinációhoz ajánlott értékekre:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Ha 1080p-s vagy 1440p-s kijelzőt használsz, valószínűleg egyszerűen 1x-es skálázást akarsz, tehát ezt használhatod:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

A `GDK_SCALE` módosításai a változtatás után indított alkalmazásokra vonatkoznak (és a GTK csak egész számokat fogad el, ezért tartsd a monitorskáládhoz legközelebbi egész értéken). Ezért a változtatás után mindenképp lépj ki azokból az ablakaidból, amelyek túlméretezettnek bizonyulnak (vagy zárd be az összes ablakot a `Ctrl + Alt + Del` billentyűkombinációval!).

A fő monitorskálázási arányok (1x, 1.25x, 1.6x, 2x, 3x, 4x) között gyorsan is lépegethetsz: a `Super + /` billentyűkombinációval feljebb, a `Super + Alt + /` billentyűkombinációval lejjebb. Ha az alapértelmezett konfigurációt használod, ezek a változtatások újraindítás után is megmaradnak.

### Szöveg nagyítása vagy kicsinyítése

A monitorskálázás mindennek megváltoztatja a méretét. Ha csak nagyobb vagy kisebb _szöveget_ szeretnél, arra egyetlen kapcsoló szolgál:

```
omarchy display text size 14
```

Ez 9 és 20 közötti képpontméretet fogad el, és együtt mozgatja az Omarchy felületét, a GTK-alkalmazásokat és a terminálodat, így az egész asztali környezet arányos marad. Argumentum nélkül futtatva megnézheted, éppen hol tartasz, az `omarchy display text size reset` paranccsal pedig visszaállhatsz az alapértelmezésre. A Foot az egyetlen lemaradó: nincs módja újratölteni a konfigurációját, ezért a futó terminálok a régi méretet tartják meg, amíg újat nem nyitsz.

### Laptopkijelzők kiterjesztése és tükrözése

Amikor külső képernyőt csatlakoztatsz a laptopodhoz, a kijelző automatikusan kiterjesztetté válik. Ezt azonban tükrözésre változtathatod az Omarchy menü _Trigger > Hardware_ menüpontjával vagy a `Super + Ctrl + Alt + Delete` billentyűkombinációval. Ez különösen hasznos, ha az a külső képernyő egy projektor, és miközben dolgozol, mutatni szeretnél valamit.

Kiterjesztéskor a laptop fedelének lehajtása automatikusan kikapcsolja a belső képernyőt. A fedél felnyitása visszakapcsolja. Ezt kézzel is vezérelheted az Omarchy menü _Trigger > Hardware_ menüpontjával vagy a `Super + Ctrl + Delete` billentyűkombinációval.

### Több képernyő elrendezése

A Hyprland remekül működik több képernyővel. Az elrendezésükről bővebben [a Hyprland monitorokról szóló dokumentációjában](https://wiki.hypr.land/Configuring/Basics/Monitors/) olvashatsz. Az Omarchyban ezek a `~/.config/hypr/monitors.lua` fájlba kerülnek `hl.monitor` bejegyzésekként — a fájl kommentelt példákkal érkezik arra, hogyan rögzíthetsz egy adott monitort egy felbontáshoz, pozícióhoz és elforgatáshoz.

Minden monitornak saját 1-től 10-ig terjedő munkaterületei vannak, így a `Super + 1` mindig annak a monitornak az első munkaterületét jelenti, amelyiken éppen vagy. A háttérben a Hyprland továbbra is az összes monitoron átívelően számozza a munkaterületeket: a laptop képernyője (vagy az első monitor) kapja az 1–10-es tartományt, a következő monitor a 11–20-as tartományt, és így tovább, és minden monitor minden csatlakoztatáskor megtartja a saját blokkját. Ezeket a számokat használd, ha [munkaterület-szabályokat](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) vagy ablakszabályokat írsz egy adott monitorhoz, tehát a 12-es munkaterület a második monitorod második munkaterülete. A `~/.local/state/omarchy/monitor-workspaces` fájl sorolja fel, melyik monitorhoz melyik blokk tartozik.

A nyílbillentyűk az elrendezésedben közös éllel érintkező monitorok között működnek. Azok a képernyők, amelyek csak egy sarokban érintkeznek, vagy amelyek között rés van, nem szomszédok, ezért a `Ctrl + Alt + Tab` billentyűkombinációval juthatsz át közöttük.

| Gyorsbillentyű | Monitorok között |
| --- | --- |
| `Super + Arrow` | A fókuszt az azon az oldalon lévő monitorra viszi, amint abban az irányban már nincs több ablak |
| `Super + Shift + Arrow` | Helyet cserél az azon az oldalon lévő monitoron lévő ablakkal |
| `Super + Alt + Arrow` | Az ablakot az azon az oldalon lévő monitoron lévő csoportba mozgatja |
| `Super + Shift + Ctrl + Arrow` | Az ablakot az azon az oldalon lévő monitorra mozgatja, az általa mutatott munkaterületre |
| `Super + Shift + Alt + Arrow` | A munkaterületet az azon az oldalon lévő monitorra mozgatja, lehetőség szerint megtartva a számát |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | A fókuszt a következő vagy az előző monitorra viszi, az elrendezéstől függetlenül |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Azon a monitoron marad, amelyiken éppen vagy |

Megnézheted a [Hyprmon](https://github.com/erans/hyprmon/) eszközt is, ha TUI-t szeretnél a több képernyő pozicionálásához.

### Fényerő szabályozása

A monitor fényerejét a külön fényerő-növelő és fényerő-csökkentő funkcióbillentyűk szabályozzák. Ha ezek megnyomása közben lenyomva tartod a Shift billentyűt, maximális vagy minimális fényerőre ugrasz. A billentyűk arra a kijelzőre vonatkoznak, amelyiken a fókusz van, így a DDC/CI protokollt használó külső monitorok ugyanúgy állíthatók, mint a laptop képernyője.

### Apple kijelzők

Ha Apple kijelzőt használsz, a szokásos billentyűzetes fényerőbillentyűk is automatikusan működni fognak, ha a fókusz az Apple kijelzőn van. Ezt az `asdcontrol` parancs biztosítja.

Vedd figyelembe, hogy Apple 6K XDR kijelző használata esetén fantomképernyőt láthatsz a `hyprctl monitors` listájában. Ezt kikapcsolhatod például egy `hl.monitor({ output = "DP-2", disabled = true })` bejegyzéssel a _Setup > Monitors_ menüpont alatt.

Intel gépeken szokásos Thunderbolt-kábellel érdemes Apple kijelzőkhöz csatlakoznod. Thunderbolt nélküli más gépeken általában [DP + USB-A -> USB-C kábelt](https://www.amazon.com/dp/B0BNX7MS6N) kell használnod, hogy működjön.
