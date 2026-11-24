# GYIK

### Hogyan válthatok a billentyűzetkiosztások között?

Szerkeszd a `~/.config/hypr/input.lua` fájlt, és add hozzá az alábbiakat, hogy a `Left Alt + Right Alt` billentyűkombinációval válthass a kiosztások között:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

A sáv automatikusan mutatni fogja az aktuális billentyűzetkiosztást, amint több kiosztást is beállítottál (és kattintással is válthatsz közöttük).

### Hogyan állíthatom az óra formátumát 12 órásra?

Kattints jobb gombbal az órára a sávban, hogy végiglépegethess a gyakori formátumokon, köztük a 12 órásakon is. A formátumot közvetlenül is beállíthatod:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Ez a következőt jeleníti meg: Vasárnap 10:55 AM.

### Hogyan módosíthatom az időzónámat?

Indítsd el a _Setup > Region > Timezone_ menüpontot az Omarchy menüben, és válassz a listából. Ha az időzóna helyes, de maga az óra eltért, az _Update > Time_ újraindítja neked az időszinkronizálást.

### Hogyan módosíthatom a DNS-emet, oszthatom meg a Wi-Fi-met, vagy ellenőrizhetem a kapcsolatom sebességét?

Mindez a [hálózatkezelés](35-networking.md) részben található.

### Hogyan ellenőrizhetem, milyen gyors a lemezem?

A _Trigger > Speed Test > Disk Speed Test_ valós időben méri a meghajtód olvasási és írási sebességét, vagy használd az `omarchy disk speedtest` parancsot a terminálból.

### Hogyan adhatok hozzá nyomtatót?

A nyomtatás gyárilag be van állítva és működik, és minden nyomtatót magad adhatsz hozzá az alkalmazásindító _Print Settings_ menüpontjából (`Super + Alt + Space`).

Válaszd az _Add_ lehetőséget, és adj neki egy pillanatot a keresésre: az USB-n keresztül csatlakoztatott nyomtatót és a legtöbb hálózati nyomtatót automatikusan megtalálja neked. Ha a tiéd nincs a listán, válaszd a _Network Printer > Internet Printing Protocol (ipp)_ lehetőséget, és add meg a címét — a nyomtató saját kijelzője vagy weboldala megmondja, mi az, általában valami olyasmi, mint `192.168.1.50`, `ipp/print` várólistával. A _Forward_ ezután felajánl egy illesztőprogramot, ahol egy modern nyomtató a legjobban az illesztőprogram nélküli _IPP Everywhere_ profillal működik, egy régebbihez pedig a modell saját illesztőprogramja kell.

Kattints jobb gombbal egy nyomtatóra, és válaszd a _Set as Default_ lehetőséget annak kiválasztásához, melyiket használják először az alkalmazásaid, a _Properties_ lehetőséget pedig a papírméret, a duplex és a minőség beállításához.

Az automatikus felderítés, amelynek során a hálózaton lévő nyomtatók hozzáadás nélkül jelennek meg, átmenetileg ki van kapcsolva, amíg átdolgozzuk, ezért a fenti első lépés a tiéd, nem automatikus. A PDF-fájlba nyomtatás nyomtató nélkül is működik.

### Hogyan módosíthatom, hova mentődjenek a képernyőképek vagy a képernyőfelvételek?

A mentett képernyőképek alapértelmezés szerint a `~/Pictures/Screenshots` mappába kerülnek. Másik könyvtár használatához add hozzá az alábbiakat a `~/.config/uwsm/env.d/` alatti egyik fájlhoz (például a `~/.config/uwsm/env.d/capture` fájlhoz):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Ugyanezt megteheted a képernyőfelvételeknél is az `OMARCHY_SCREENRECORD_DIR` használatával.

Az Omasnap automatikusan létrehozza a képernyőképek könyvtárát. A képernyőfelvételek könyvtárát magad hozd létre, majd indítsd újra az Omarchy rendszert, hogy bármelyik környezeti változtatás érvénybe lépjen.

### Hogyan hozhatom működésre a hangszórókat + webkamerát az Apple Studio Display monitoromon?

Azt hinné az ember, hogy minden működik, ha egyszerűen bedugja az USB C-t, de sajnos nem ez a helyzet. A megoldás, amely nálam megbízhatóan működik, [a WJESOG DisplayPort + USB-A => USB-C kábel](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/) használata. Onnantól a hangszórók és a webkamera remekül működnek.

Ne feledd, hogy az Omarchy beépített fényerő-szabályozással rendelkezik az Apple Displays monitorokhoz (Studio és XDR esetén egyaránt) a szokásos billentyűzeti fényerőgombokkal.

### Hogyan szabadulhatok meg az összes felesleges szoftvertől?

Ha nem kérsz olyan programokból, mint az Obsidian vagy a LibreOffice, vagy bármelyik másik előre telepített cuccból, nagyon könnyen eltávolíthatod őket.

Indítsd el a _Remove > Package_ menüpontot, hogy lásd az összes telepített csomagot. Ezután a tab billentyűvel kiválaszthatod bármelyik eltávolítani kívánt csomagot, és a return billentyűvel elkezdheted az összes kiválasztott elem eltávolítását.

Az Omarchy menü _Remove > Web App_ menüpontjával pedig eltávolíthatod bármelyik előre telepített webalkalmazást, amelyre nincs szükséged.

Vagy indítsd el a _Remove > Preinstalls_ menüpontot, hogy egy menetben kisöpörhesd az összes előre telepített extrát — webalkalmazásokat, TUI-kat és opcionális alkalmazásokat. Az őket indító gyorsbillentyűk velük együtt eltűnnek, így tiszta lappal indulhatsz a billentyűkiosztások terén, amelyeket a sajátjaiddal tölthetsz meg a `~/.config/hypr/bindings.lua` fájlban.

---

Hibák és elromlott dolgok esetén lásd [a Hibaelhárítás szakaszt](45-troubleshooting.md).
