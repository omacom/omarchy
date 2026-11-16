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

A sáv automatikusan mutatja az aktuális billentyűzetkiosztást, amint több kiosztást is beállítottál (és rákattintva is válthatsz).

### Hogyan állíthatom az óra formátumát 12 órásra?

Kattints jobb gombbal a sávban lévő órára az elterjedt formátumok közötti léptetéshez, a 12 órásakat is beleértve. A formátumot közvetlenül is beállíthatod:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Ez így fog megjelenni: vasárnap 10:55 AM.

### Hogyan változtathatom meg az időzónámat?

Futtasd a _Frissítés > Időzóna_ lehetőséget az Omarchy menüben, és válassz a listából. Ha az időzóna helyes, de maga az óra eltért, a _Frissítés > Idő_ újraindítja neked az időszinkronizálást.

### Hogyan változtathatom meg a DNS-emet, oszthatom meg a Wi-Fi-met, vagy ellenőrizhetem a kapcsolatom sebességét?

Ezek mind a [hálózatkezelés](35-networking.md) alatt találhatók.

### Hogyan ellenőrizhetem, milyen gyors a lemezem?

A _Trigger > Speed Test > Disk Speed Test_ valós olvasási és írási sebességet mér a meghajtódon, vagy terminálból az `omarchy disk speedtest` parancs.

### Hogyan adhatok hozzá nyomtatót?

A nyomtatás azonnal működőképesen, beállítva és futva érkezik, az egyes nyomtatókat pedig te adod hozzá az alkalmazásindítóban (`Super + Space`) található _Nyomtatási beállítások_ menüpontból.

Válaszd a _Hozzáadás_ lehetőséget, és adj neki egy pillanatot a keresésre: az USB-n keresztül csatlakoztatott nyomtatót és a legtöbb hálózati nyomtatót megtalálja neked. Ha a tiéd nincs a listában, válaszd a _Hálózati nyomtató > Internet Printing Protocol (ipp)_ lehetőséget, és add meg a címét — a nyomtató saját kijelzője vagy a weboldala megmondja, mi az, általában valami olyasmi, mint a `192.168.1.50` egy `ipp/print` sorral. A _Tovább_ ezután illesztőprogramot kínál, ahol egy modern nyomtató a meghajtó nélküli _IPP Everywhere_ profillal működik a legjobban, egy régebbihez pedig a modell saját illesztőprogramja kell.

Kattints jobb gombbal egy nyomtatóra, és válaszd a _Beállítás alapértelmezettként_ lehetőséget annak kiválasztásához, melyiket érjék el először az alkalmazásaid, a _Tulajdonságok_ lehetőséget pedig a papírméret, a kétoldalas nyomtatás és a minőség beállításához.

Az automatikus felderítés, ahol a hálózati nyomtatók hozzáadás nélkül jelennek meg, ideiglenesen ki van kapcsolva, amíg átdolgozzák, ezért a fenti első lépés a tiéd, nem automatikus. PDF fájlba nyomtatni bármilyen nyomtató nélkül is lehet.

### Hogyan változtathatom meg, hová mentődnek a képernyőképek vagy a képernyőfelvételek?

A mentett képernyőképek alapértelmezés szerint a `~/Pictures/Screenshots` mappába kerülnek. Másik könyvtár használatához add hozzá az alábbiakat egy `~/.config/uwsm/env.d/` alatti fájlhoz (például a `~/.config/uwsm/env.d/capture` fájlhoz):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Ugyanezt megteheted a képernyőfelvételekhez is az `OMARCHY_SCREENRECORD_DIR` használatával.

Az Omasnap automatikusan létrehozza a képernyőképek könyvtárát. A képernyőfelvételek könyvtárát magad hozd létre, majd indítsd újra az Omarchy-t, hogy bármelyik környezeti változtatás érvénybe lépjen.

### Hogyan kelthetem életre a hangszórókat + webkamerát az Apple Studio Display kijelzőmön?

Az ember azt hinné, hogy az egésznek működnie kellene pusztán az USB C bedugásával, de sajnos nem ez a helyzet. Az általam talált megoldás, amely megbízhatóan működik, [a WJESOG DisplayPort + USB-A => USB-C kábel](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/) használata. Onnantól a hangszórók és a webkamera úgy működnek, mint a karikacsapás.

Ne feledd, hogy az Omarchy beépített fényerő-szabályozással rendelkezik az Apple kijelzőkhöz (a Studio és az XDR modellekhez is) a szokásos billentyűzeti fényerőgombokkal.

### Hogyan szabadulhatok meg az összes extra szoftvertől?

Ha nem akarsz olyan programokat, mint az Obsidian vagy a LibreOffice, vagy bármely más előre telepített cuccot, nagyon könnyen eltávolíthatod őket.

Futtasd az _Eltávolítás > Csomag_ lehetőséget az összes telepített csomag megtekintéséhez. Ezután a tab billentyűvel bármelyik eltávolítani kívánt csomagot kiválaszthatod, a return billentyűvel pedig megkezdheted az összes kiválasztott eltávolítását.

Az Omarchy menü _Eltávolítás > Web App_ pontjával pedig eltávolíthatod az előre telepített webalkalmazások bármelyikét, amelyet nem akarsz.

Vagy futtasd az _Eltávolítás > Előre telepítettek_ lehetőséget, hogy egy menetben kisöpörd az összes előre telepített extrát — webalkalmazásokat, TUI-kat és opcionális alkalmazásokat. Az őket indító gyorsbillentyűk velük együtt eltűnnek, így tiszta lappal maradsz a billentyűkiosztásokhoz, amelyeket a sajátjaiddal tölthetsz meg a `~/.config/hypr/bindings.lua` fájlban.

---

Hibákkal és meghibásodott részekkel kapcsolatban lásd [a Hibaelhárítás szakaszt](45-troubleshooting.md).
