# GYIK

### Hogyan válthatok a billentyűzetkiosztások között?

Szerkeszd a `~/.config/hypr/input.lua` fájlt, és add hozzá az alábbiakat, hogy a `Left Alt + Right Alt` kombinációval válthass a kiosztások között:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

A sáv automatikusan megjeleníti az aktuális billentyűzetkiosztásodat, amint több kiosztást is beállítottál (és rákattintva is válthatsz).

### Hogyan állíthatom át az óra formátumát 12 órásra?

Kattints jobb gombbal a sávban lévő órára, hogy végiglépkedj a gyakori formátumokon, köztük a 12 órásakon is. A formátumot közvetlenül is beállíthatod:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Ez Vasárnap 10:55 AM formában jelenik meg.

### Hogyan változtathatom meg az időzónámat?

Futtasd a _Setup > Region > Timezone_ menüpontot az Omarchy menüben, és válassz a listából. Ha az időzóna helyes, de maga az óra csúszott el, az _Update > Time_ újraindítja neked az időszinkronizálást.

### Hogyan változtathatom meg a DNS-t, oszthatom meg a Wi-Fi-t, vagy ellenőrizhetem a kapcsolatom sebességét?

Mindezek a [hálózatkezelés](35-networking.md) részben találhatók.

### Hogyan ellenőrizhetem, milyen gyors a lemezem?

A _Trigger > Speed Test > Disk Speed Test_ valós időben méri a meghajtód olvasási és írási sebességét, vagy használd a terminálból az `omarchy disk speedtest` parancsot.

### Hogyan adhatok hozzá nyomtatót?

A nyomtatás alapból be van állítva és működik, minden nyomtatót magad adsz hozzá a _Print Settings_ felületről, amelyet az alkalmazásindítóból érsz el (`Super + Space`).

Válaszd az _Add_ lehetőséget, és adj neki egy pillanatot a keresésre: az USB-n csatlakoztatott nyomtatókat és a legtöbb hálózati nyomtatót megtalálja neked. Ha a tiéd nincs a listán, válaszd a _Network Printer > Internet Printing Protocol (ipp)_ lehetőséget, és add meg a címét — a nyomtató saját kijelzője vagy a weboldala megmondja, mi az, általában valami olyasmi, mint a `192.168.1.50` `ipp/print` sorral. A _Forward_ ezután felajánl egy illesztőprogramot, ahol egy modern nyomtató az illesztőprogram nélküli _IPP Everywhere_ profillal működik a legjobban, egy régebbihez pedig a modell saját illesztőprogramja kell.

Kattints jobb gombbal egy nyomtatóra, és válaszd a _Set as Default_ lehetőséget annak beállításához, melyiket használják először az alkalmazásaid, a _Properties_ menüpontban pedig beállíthatod a papírméretet, a kétoldalas nyomtatást és a minőséget.

Az automatikus felderítés, amelynek során a hálózaton lévő nyomtatók hozzáadás nélkül megjelennek, ideiglenesen ki van kapcsolva, amíg átdolgozzák, ezért a fenti első lépés a tiéd, nem automatikus. A PDF-fájlba nyomtatás nyomtató nélkül is működik.

### Hogyan változtathatom meg, hová mentődjenek a képernyőképek vagy a képernyőfelvételek?

A mentett képernyőképek alapértelmezés szerint a `~/Pictures/Screenshots` mappába kerülnek. Más könyvtár használatához add hozzá az alábbi sort egy fájlhoz a `~/.config/uwsm/env.d/` alatt (például a `~/.config/uwsm/env.d/capture` fájlhoz):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Ugyanezt megteheted a képernyőfelvételek esetén is az `OMARCHY_SCREENRECORD_DIR` használatával.

Az Omasnap automatikusan létrehozza a képernyőképek könyvtárát. A képernyőfelvételek könyvtárát magad hozd létre, majd indítsd újra az Omarchy rendszert, hogy bármelyik környezeti változtatás életbe lépjen.

### Hogyan tudom működésre bírni a hangszórókat és a webkamerát az Apple Studio Displayemen?

Azt hinné az ember, hogy az USB C bedugásával mindennek működnie kell, de sajnos nem ez a helyzet. A megoldás, amelyet megbízhatóan működőnek találtam, [a WJESOG DisplayPort + USB-A => USB-C kábel](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/) használata. Onnantól a hangszórók és a webkamera tökéletesen működnek.

Ne feledd, hogy az Omarchy beépített fényerő-szabályozást kínál az Apple Displays kijelzőkhöz (a Studio és az XDR modellekhez is) a szokásos billentyűzetes fényerőgombokkal.

### Hogyan szabadulhatok meg az összes extra szoftvertől?

Ha nem akarsz olyan programokat, mint az Obsidian vagy a LibreOffice, vagy bármelyik másik előre telepített cuccot, nagyon könnyen eltávolíthatod őket.

Futtasd a _Remove > Package_ menüpontot, hogy lásd az összes telepített csomagot. Ezután a tab billentyűvel kiválaszthatod az eltávolítani kívánt csomagokat, és a return billentyűvel elkezdheted az összes kiválasztott elem eltávolítását.

Az előre telepített webalkalmazások eltávolítására az Omarchy menü _Remove > Web App_ menüpontját használhatod.

Vagy futtasd a _Remove > Preinstalls_ menüpontot, hogy egyetlen mozdulattal kisöpörd az összes előre telepített extrát — a webalkalmazásokat, a TUI-kat és az opcionális alkalmazásokat. Az őket indító gyorsbillentyűk velük együtt eltűnnek, így tiszta lappal maradsz, amelyet a `~/.config/hypr/bindings.lua` fájlban tölthetsz meg a saját billentyűparancsaiddal.

---

Hibák és elromlott dolgok esetén lásd a [Hibaelhárítás szakaszt](45-troubleshooting.md).
