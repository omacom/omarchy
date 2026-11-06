# GYIK

### Hogyan válthatok a billentyűzetkiosztások között?

Szerkeszd a `~/.config/hypr/input.lua` fájlod, és add hozzá ezt a `Left Alt + Right Alt` kombinációval való váltáshoz:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

A sáv automatikusan megmutatja az aktuális billentyűzetkiosztásod, amint több kiosztást konfiguráltál (és rá is kattinthatsz a váltáshoz).

### Hogyan változtathatom 12 órásra az óraformátumot?

Kattints jobb gombbal a sávban lévő órára, hogy végiglapozd a gyakori formátumokat, köztük a 12 órásakat is. A formátumot közvetlenül is beállíthatod:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Ez Sunday 10:55 AM formátumot mutat.

### Hogyan változtathatom meg az időzónám?

Futtasd az Omarchy menü _Frissítés > Időzóna_ pontját, és válassz a listából. Ha az időzóna jó, de maga az óra elcsúszott, a _Frissítés > Idő_ újraindítja számodra az időszinkronizálást.

### Hogyan változtathatom meg a DNS-em, oszthatom meg a Wi-Fi-met, vagy ellenőrizhetem a kapcsolatsebességem?

Ezek mind a [hálózatkezelésben](35-networking.md) vannak.

### Hogyan ellenőrizhetem, milyen gyors a lemezem?

Az _Indító > Sebességteszt > Lemez sebességteszt_ élő olvasási és írási sebességet mér a meghajtódon, vagy az `omarchy disk speedtest` a terminálból.

### Miért nem tudok bejelentkezni a Google-fiókomba Chromiumban?

A sima nyílt forráskódú Chromium build nem szállítja azokat az OAuth-hitelesítőadatokat, amelyeket a Google a fiókba való bejelentkezéshez megkövetel. Futtasd az Omarchy menü _Telepítés > Szolgáltatás > Chromium-fiók_ pontját ezek hozzáadásához, indítsd újra a böngészőt, és a bejelentkezés végigmegy.

### Hogyan adhatok hozzá nyomtatót?

A nyomtatás alapból be van állítva és fut, és minden nyomtatót magad adsz hozzá az alkalmazásindító (`Super + Space`) _Print Settings_ pontjából.

Válaszd az _Add_ lehetőséget, és adj neki egy pillanatot a keresésre: egy USB-n bedugott nyomtatót és a legtöbb hálózati nyomtatót megtalál helyetted. Ha a tied nincs a listában, válaszd a _Network Printer > Internet Printing Protocol (ipp)_ pontot, és add meg a címét — a nyomtató saját kijelzője vagy a weboldala megmondja, mi az, általában valami olyasmi, mint `192.168.1.50` `ipp/print` várólistával. A _Forward_ ezután illesztőprogramot kínál, ahol egy modern nyomtató a legjobban illesztőprogram nélküli _IPP Everywhere_ profilon működik, egy régebbi pedig a modell saját illesztőprogramját akarja.

Kattints jobb gombbal egy nyomtatóra, és válaszd a _Set as Default_ lehetőséget annak kiválasztásához, hogy melyiket érik el először az alkalmazásaid, és a _Properties_ lehetőséget a papírméret, a duplex és a minőség beállításához.

Az automatikus felderítés, ahol a hálózaton lévő nyomtatók hozzáadás nélkül jelennek meg, ideiglenesen ki van kapcsolva, amíg átdolgozzák, ezért a fenti első lépés a tied, nem automatikus. A PDF-fájlba nyomtatás bármilyen nyomtató nélkül is működik.

### Hogyan változtathatom meg, hová mentődjenek a képernyőképek vagy a képernyőfelvételek?

A mentett képernyőképek alapértelmezetten a `~/Pictures/Screenshots` mappába mennek. Más könyvtár használatához add hozzá ezt egy fájlhoz a `~/.config/uwsm/env.d/` alatt (például `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Ugyanezt megteheted a képernyőfelvételekhez az `OMARCHY_SCREENRECORD_DIR` használatával.

Az Omasnap automatikusan létrehozza a képernyőkép-könyvtárát. Hozd létre a képernyőfelvételi könyvtárat saját kézzel, majd indítsd újra az Omarchyt, hogy bármelyik környezeti változás életbe lépjen.

### Hogyan működtethetem a hangszórókat + webkamerát az Apple Studio Displayemen?

Azt hinné az ember, hogy mindennek működnie kell az USB C bedugásával, de sajnos ez nem így van. Az a megoldás, amelyet találtam, és megbízhatóan működik, [a WJESOG DisplayPort + USB-A => USB-C kábel](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/) használata. Akkor a hangszórók és a webkamera úgy működnek, mint a karikacsapás.

Ne feledd, hogy az Omarchyban beépített fényerőszabályozás van az Apple kijelzőkhöz (mind a Studio, mind az XDR) a szokásos billentyűzetes fényerőgombokkal.

### Hogyan szabadulhatok meg az összes extra szoftvertől?

Ha nem akarsz olyan programokat, mint az Obsidian vagy a LibreOffice, vagy bármelyik más előre telepített dolgot, nagyon könnyen eltávolíthatod.

Futtasd az _Eltávolítás > Csomag_ pontot, hogy megnézd minden telepített csomagot. Ezután a tabulátorral kiválaszthatsz minden eltávolítandó csomagot, és a return billentyűvel elindíthatod minden kiválasztott dolog eltávolítását.

És az Omarchy menü _Eltávolítás > Webalkalmazás_ pontját is használhatod bármely előre telepített webalkalmazás eltávolítására, amelyet nem akarsz.

Vagy futtasd az _Eltávolítás > Előtelepített elemek_ pontot, hogy minden előre telepített extrát — webalkalmazásokat, TUI-kat és opcionális alkalmazásokat — egy menetben kitakaríts. Az őket indító gyorsbillentyűk velük együtt eltűnnek, így tiszta billentyűkiosztási lappal maradsz, amelyet a sajátjaiddal tölthetsz fel a `~/.config/hypr/bindings.lua` fájlban.

---

A hibákról és a tört részekről lásd [a Hibaelhárítás szakaszt](45-troubleshooting.md).
