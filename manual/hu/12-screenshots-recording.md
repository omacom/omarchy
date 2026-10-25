# Képernyőképek és felvétel

Minden, amit le tudsz kapni a képernyőről, a Print Screen billentyűn lóg. Egy billentyű önmagában képet készít, a módosítókkal pedig felvételt, színt vagy egy terület belsejében lévő szöveget kapsz. Ha a billentyűzeteden egyáltalán nincs Print Screen billentyű, a `Super + Ctrl + Alt + C` ugyanazt a képernyőképet készíti, a `Super + Ctrl + C` pedig az egész készletet menüként nyitja meg.

| Billentyűkombináció | Funkció |
| ------ | -------- |
| `Print Screen` | Képernyőkép |
| `Super + Ctrl + Alt + C` | Képernyőkép |
| `Alt + Print Screen` | Képernyőfelvétel (vagy a futó felvétel leállítása) |
| `Super + Print Screen` | Színválasztó |
| `Super + Ctrl + Print Screen` | Szöveg kinyerése egy területről |
| `Super + Ctrl + C` | Rögzítési menü |
| `Super + Ctrl + .` | Kép vagy videó átkódolása |

## Képernyőképek

Nyomd meg a `Print Screen` billentyűt (vagy a `Super + Ctrl + Alt + C` kombinációt), és az Omasnap még az átfedő felület megjelenése előtt rögzíti a fókuszban lévő monitort, így semmi sem mozdul el alattad, miközben célzol. Húzz szabad alakú területet, kattints egy ablakra a rögzítéséhez, vagy kattints üres helyre az egész monitor rögzítéséhez. Nyomd meg az `S` billentyűt a rajzolás előtt görgethető terület rögzítéséhez. Meggondoltad magad? Nyomd meg újra ugyanazt a billentyűt az Omasnap bezárásához.

Miután kiválasztottál egy területet, az Omasnap menti a felvételt, a vágólapra másolja, és 10 másodpercig előnézetet mutat. Az előnézet rögzítőgombjával vagy a `Ctrl + P` kombinációval a képernyőn tarthatod, vagy az Edit lehetőséget választva elláthatod megjegyzésekkel.

A megjegyzésszerkesztő tud nyilakat, vonalakat, alakzatokat, kiemeléseket, számozott jelölőket, szöveget és biztonságos kitakarásokat rajzolni; kivágni vagy kijelölni a kép egy részét; OCR-rel feldolgozni a szövegét; és hátteret adni hozzá. A szerkesztőben nyomj `Enter` billentyűt a kész PNG másolásához és mentéséhez, `Ctrl + C` billentyűt a másolásához mentés nélkül, vagy `Ctrl + S` billentyűt a mentéséhez másolás nélkül.

A mentett képernyőképek alapértelmezetten a `~/Pictures/Screenshots` mappába kerülnek, például `screenshot-2026-08-13_14-22-05-firefox.png` néven. Állítsd be az `OMASNAP_SCREENSHOT_DIR` változót másik könyvtár használatához — lásd [a GYIK-et](46-faq.md) arról, hova kerülnek a munkamenet környezeti változói. Az Omasnap az első felvétel mentésekor létrehozza a könyvtárat. Állítsd be az `[output] autosave = false` értéket a `~/.config/omasnap/omasnap.conf` fájlban az automatikus mentés kikapcsolásához.

Terminálból az `omarchy screenshot` ugyanazt az átfedő felületet nyitja meg, és kiválaszthatod a kezdő módját: `omarchy capture screenshot region`, `windows`, `fullscreen` vagy `scroll`. A `copy` vagy `save` második argumentum kihagyja az előnézetet, és egyenesen az adott célra küldi a felvételt. Ha szerkeszteni akarsz a kimenet előtt, használd az `omarchy screenshot --editor=overlay` parancsot teljes képernyős szerkesztőhöz, vagy az `omarchy screenshot --editor=window` parancsot külön ablakhoz.

### A választó vezérlése billentyűzetről

Amíg a kijelölés látható, egyáltalán nem kell egeret használnod:

| Billentyű | Funkció |
| --- | -------- |
| `S` | Görgethető terület mód be- és kikapcsolása |
| `Super + Arrow keys` | Mozgás az ablakok között Window módban |
| `Return` | A kiemelt ablak rögzítése |
| `Ctrl + A` | A teljes fókuszban lévő monitor rögzítése |
| `R` | Az ebben a munkamenetben utoljára rajzolt terület visszaállítása |
| `Esc` | Az Omasnap bezárása |

Ezek a hozzárendelések csak addig léteznek, amíg az Omasnap nyitva van, így semmivel sem ütközhetnek a saját konfigurációdban.

## Képernyőfelvétel

Az `Alt + Print Screen` megnyitja a _Trigger > Capture > Screenrecord_ menüt, amely megkérdezi, mit szeretnél a hangsávra: nincs hang, asztali hang, asztali hang plusz mikrofon, vagy asztali hang plusz mikrofon plusz webkamera. Ez az utolsó csak akkor jelenik meg, ha tényleg van csatlakoztatott kamerád. Válassz egyet, és az Omarchy felvételválasztója lehetővé teszi, hogy területet húzz, vagy ablakra vagy monitorra kattints.

A felvétel a gpu-screen-recorder programon fut, amely a GPU-n kódol 60fps sebességgel, és ha kell, visszaesik a CPU-ra. Az eredmény egy MP4 a `~/Videos` mappában, `screenrecording-2026-08-13_14-22-05.mp4` néven. Állítsd be az `OMARCHY_SCREENRECORD_DIR` változót ennek megváltoztatásához — de vedd figyelembe, hogy a képernyőkép-könyvtártól eltérően ennek már léteznie kell, különben a felvétel nem hajlandó elindulni.

Amíg felveszel, egy kis jelző jelenik meg a sávban. Kattints rá a leállításhoz. Leállíthatod újra az `Alt + Print Screen` megnyomásával is, vagy a _Trigger > Capture > Screenrecord_ alatt található _Stop Screenrecording_ bejegyzéssel, amely csak akkor jelenik meg, amíg tényleg folyik felvétel.

A leállítás egy kis rendrakást végez, mielőtt átadná a fájlt: levágja az első képkockát, és ha van hang, -14 LUFS értékre normalizálja, a PipeWire rögzítési pattogást pedig a legelején elnémítja. Ezután megjelenik egy értesítés a felvételből származó bélyegképpel. Kattints rá a fájl mpv-ben való lejátszásához.

### A webkamera-átfedés

Amikor webkamerával veszel fel, a kamera rögzített, körbevágott portréablakként jelenik meg annak jobb alsó sarkában, amit felveszel. Ha épp olyasmi fölött van, amire szükséged van, menet közben átméretezheted:

| Billentyűkombináció | Funkció |
| ------ | -------- |
| `Super + Alt + [` | A webkamera-átfedés kisebbé tétele |
| `Super + Alt + ]` | A webkamera-átfedés nagyobbá tétele |

Három méret van — kicsi, közepes és nagy —, és a billentyűkombinációk ezek között léptetnek. A közepes az alapértelmezett. Arányosak a felvételhez, így a kamera a képkocka ugyanakkora hányadát foglalja el, akár 1080p monitort, akár 6K monitort veszel fel. És ha területet vettél fel egész kijelző helyett, az átfedés annak a területnek a sarkához igazodik a monitoré helyett, így a felvételen belül marad.

Közvetlenül is meghívhatod az `omarchy-capture-webcam-resize small` paranccsal, vagy a `reset` paraméterrel visszatérhetsz a közepes mérethez.

## Szöveg, QR-kódok és színek

A `Super + Ctrl + Print Screen` kijelöl egy területet, és OCR-rel a vágólapra teszi. Ezt rendesen tárgyalja a [Szövegkinyerés és diktálás](11-text-extraction-dictation.md).

A _Trigger > Capture > QR Code_ ugyanezt a trükköt csinálja QR-kódokkal. Jelöld ki a kódot tartalmazó területet, és a dekódolt érték a vágólapra kerül. Csak QR-kódokat keres — a sűrű képernyőtartalom egyébként hajlamos tévesen vonalkódként jelentkezni. Érdemes tudni: a dekódolt érték a vágólapra kerül, és sehova máshova. Nincs kinyomtatva, nincs benne az értesítésben, és érzékenyként van megjelölve, így nem ragad bent a [vágólap-előzményekben](08-unified-clipboard-history.md). A QR-kódok rendszeresen hordoznak titkokat — például a 2FA beállítási kód mögötti `otpauth://` URI-t —, és ezt nem akarod egy naplóban látni. A beillesztés továbbra is rendben működik.

A `Super + Print Screen` (vagy a _Trigger > Capture > Color_) pipettává változtatja a kurzort. Kattints bármire a képernyőn, és a szín a vágólapra kerül. Nyomd meg újra a billentyűkombinációt a kilépéshez választás nélkül.

## Átkódolás megosztás előtt

Egy 4K képernyőfelvétel vagy egy nyers HEIC a telefonodról gyakran túl nagy ahhoz, hogy csak úgy elküldd. A `Super + Ctrl + .` (vagy a _Trigger > Transcode_) ezt megoldja. Fuzzy fájlválasztót kínál a `~/Pictures` és a `~/Videos` fölött, majd formátumot és méretet kér.

A képek jpg vagy png formátumba mennek magas, közepes vagy alacsony minőségben, amelyek 3160, 2160, illetve 1080 képpontban korlátozzák a szélességet. A videók mp4 vagy animált gif formátumba mennek 4k, 1080p vagy 720p felbontásban. A konvertált fájl az eredeti mellé kerül a felbontással a nevében — `demo-1080p.mp4` —, és az elérési út fájl-URI-ként a vágólapra másolódik, így közvetlenül beillesztheted egy fájldobást fogadó alkalmazásba.

Terminálból is működik, ha már tudod, mit akarsz: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Van továbbá az `omarchy transcode ascii` is, amely képet alakít ASCII-művészetté — az leginkább az [arculathoz](41-branding.md) való.

## Elküldés valahová

Miután megvan a fájl, a `Super + Ctrl + S` megnyitja a Share menüt, és LocalSend segítségével elküldi a hálózatodon lévő másik eszközre. Lásd ehhez a [GUIs](22-guis.md) részt.
