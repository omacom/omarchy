# Képernyőképek és felvétel

Minden, amit le tudsz szedni a képernyőről, a Print Screen billentyűn lóg. Egyetlen billentyű önmagában képet készít, a módosítók pedig felvételt, színt, vagy egy terület belsejében lévő szöveget adnak. Ha a billentyűzeteden egyáltalán nincs Print Screen billentyű, a `Super + Ctrl + Alt + C` ugyanazt a képernyőképet készíti, a `Super + Ctrl + C` pedig az egész készletet menüként nyitja meg.

| Gyorsbillentyű | Funkció |
| ------ | -------- |
| `Print Screen` | Képernyőkép |
| `Super + Ctrl + Alt + C` | Képernyőkép |
| `Alt + Print Screen` | Képernyőfelvétel (vagy a futó felvétel leállítása) |
| `Super + Print Screen` | Színválasztó |
| `Super + Ctrl + Print Screen` | Szöveg kinyerése egy területről |
| `Super + Ctrl + C` | Rögzítés menü |
| `Super + Ctrl + .` | Kép vagy videó átkódolása |

## Képernyőképek

Nyomd meg a `Print Screen` (vagy a `Super + Ctrl + Alt + C`) billentyűt, és az Omasnap még azelőtt rögzíti a fókuszban lévő monitort, hogy megjelenne a felülete, így semmi sem mozdul el alattad, miközben célzol. Húzz egy szabad alakú területet, kattints egy ablakra a rögzítéséhez, vagy kattints üres területre a teljes monitor rögzítéséhez. Görgethető terület rögzítéséhez rajzolás előtt nyomd meg az `S` billentyűt. Meggondoltad magad? Nyomd meg ugyanazt a billentyűt újra az Omasnap bezárásához.

Miután kiválasztottál egy területet, az Omasnap menti a rögzítést, a vágólapra másolja, és értesítést mutat a bélyegképével, ugyanúgy, mint egy mentett képernyőfelvétel. Válaszd az Open lehetőséget a mentett kép megtekintéséhez a képnézegetődben, vagy az Edit lehetőséget a megjegyzésekkel való ellátásához.

A megjegyzésszerkesztővel nyilakat, vonalakat, alakzatokat, kiemeléseket, számozott jelölőket, szöveget és biztonságos kitakarásokat rajzolhatsz; levághatod vagy kivághatod a kép egy részét; OCR-rel kinyerheted a szövegét; és hátteret adhatsz hozzá. A szerkesztőben nyomd meg az `Enter` billentyűt a kész PNG másolásához és mentéséhez, a `Ctrl + C` billentyűkombinációt a mentés nélküli másoláshoz, vagy a `Ctrl + S` billentyűkombinációt a másolás nélküli mentéshez.

A mentett képernyőképek alapértelmezés szerint a `~/Pictures/Screenshots` mappába kerülnek, például `screenshot-2026-08-13_14-22-05-firefox.png` néven. Másik könyvtár használatához állítsd be az `OMASNAP_SCREENSHOT_DIR` változót — lásd [a GYIK-et](46-faq.md) arról, hová kell tenni a munkamenet környezeti változóit. Az Omasnap az első kép mentésekor létrehozza a könyvtárat. Az automatikus mentés kikapcsolásához állítsd be az `[output] autosave = false` értéket a `~/.config/omasnap/omasnap.conf` fájlban; a rögzítések ekkor csak másolódnak, és 10 másodpercig egy előnézetben jelennek meg, amelyet a rögzítés gombjával vagy a `Ctrl + P` billentyűkombinációval a képernyőn tarthatsz.

Terminálból az `omarchy screenshot` ugyanazt a felületet nyitja meg, és kiválaszthatod a kezdő módját: `omarchy capture screenshot region`, `windows`, `fullscreen` vagy `scroll`. Egy második, `copy` vagy `save` argumentum egyenesen az adott célra küldi a képet. Ha kimenet előtt szerkesztenéd, használd az `omarchy screenshot --editor=overlay` parancsot teljes képernyős szerkesztőhöz, vagy az `omarchy screenshot --editor=window` parancsot külön ablakhoz.

### A választó kezelése billentyűzetről

Amíg a kijelölés látható, egyáltalán nem kell egeret használnod:

| Billentyű | Funkció |
| --- | -------- |
| `S` | Görgethető terület mód be-/kikapcsolása |
| `Super + Arrow keys` | Mozgás az ablakok között Ablak módban |
| `Return` | A kiemelt ablak rögzítése |
| `Ctrl + A` | A teljes fókuszban lévő monitor rögzítése |
| `R` | Az ebben a munkamenetben utoljára rajzolt terület visszaállítása |
| `Esc` | Az Omasnap bezárása |

Ezek a billentyű-hozzárendelések csak addig léteznek, amíg az Omasnap nyitva van, így nem ütközhetnek semmivel a saját konfigurációdban.

## Képernyőfelvétel

Az `Alt + Print Screen` megnyitja a _Trigger > Capture > Screenrecord_ menüt, amely megkérdezi, mit szeretnél a hangsávon: semmilyen hangot, asztali hangot, asztali hangot és mikrofont, vagy asztali hangot, mikrofont és webkamerát. Az utolsó csak akkor jelenik meg, ha tényleg van csatlakoztatott kamerád. Válassz egyet, és az Omarchy felvételválasztója lehetővé teszi, hogy területet húzz, vagy egy ablakra vagy monitorra kattints.

A felvétel a gpu-screen-recorder programon fut, amely a GPU-n kódol 60fps sebességgel, és ha kell, visszavált a CPU-ra. Az eredmény egy MP4 a `~/Videos` mappában, `screenrecording-2026-08-13_14-22-05.mp4` néven. Ennek megváltoztatásához állítsd be az `OMARCHY_SCREENRECORD_DIR` változót — de vedd figyelembe, hogy a képernyőkép-könyvtárral ellentétben ennek már léteznie kell, különben a felvétel nem hajlandó elindulni.

Felvétel közben egy kis jelző jelenik meg a sávban. Kattints rá a leállításhoz. Leállíthatod az `Alt + Print Screen` ismételt megnyomásával is, vagy a _Trigger > Capture > Screenrecord_ alatt található _Stop Screenrecording_ bejegyzéssel, amely csak akkor jelenik meg, amíg ténylegesen fut egy felvétel.

A leállítás egy kis rendrakást végez, mielőtt átadná a fájlt: az első képkockát levágja, és ha van hang, azt -14 LUFS szintre normalizálja, miközben a PipeWire rögzítés legelején lévő pattanást elnémítja. Ezután megjelenik egy értesítés a felvétel egyik bélyegképével. Kattints rá a fájl lejátszásához az Omaview alkalmazásban.

### A webkamera-fedvény

Amikor webkamerával rögzítesz, a kamera rögzített, levágott álló ablakként jelenik meg annak jobb alsó sarkában, amit rögzítesz. Ha épp valami olyasmi fölött ül, amire szükséged van, menet közben átméretezheted:

| Gyorsbillentyű | Funkció |
| ------ | -------- |
| `Super + Alt + [` | A webkamera-fedvény kisebbé tétele |
| `Super + Alt + ]` | A webkamera-fedvény nagyobbá tétele |

Három méret van — kicsi, közepes és nagy —, és a gyorsbillentyűk ezek között léptetnek. Az alapértelmezett a közepes. A méretek arányosak a felvétellel, így a kamera ugyanakkora részét foglalja el a képnek, akár 1080p monitort, akár 6K monitort rögzítesz. És ha területet rögzítettél egy teljes kijelző helyett, a fedvény annak a területnek a sarkához rögzül a monitoré helyett, így a felvételen belül marad.

Közvetlenül is meghívhatod az `omarchy-capture-webcam-resize small` paranccsal, vagy a `reset` argumentummal visszatérhetsz a közepes mérethez.

## Szöveg, QR-kódok és színek

A `Super + Ctrl + Print Screen` kiválaszt egy területet, és OCR-rel a vágólapra teszi a szövegét. Ezt rendesen a [Szövegkinyerés és diktálás](11-text-extraction-dictation.md) fejezet tárgyalja.

A _Trigger > Capture > QR Code_ ugyanezt a trükköt csinálja QR-kódokkal. Válaszd ki a kódot tartalmazó területet, és a dekódolt érték a vágólapra kerül. Csak QR-kódokat keres — a sűrű képernyőtartalom egyébként hajlamos tévesen vonalkódként felismerődni. Érdemes tudni: a dekódolt érték csak a vágólapra kerül, sehová máshová. Nem kerül kiírásra, nem szerepel az értesítésben, és érzékenyként van megjelölve, így nem marad meg a [vágólap-előzményekben](08-unified-clipboard-history.md). A QR-kódok rutinszerűen titkokat hordoznak — például egy 2FA beállítókód mögötti `otpauth://` URI-t —, és nem akarod, hogy ez egy naplóba kerüljön. A beillesztés továbbra is rendben működik.

A `Super + Print Screen` (vagy a _Trigger > Capture > Color_) pipettává változtatja a kurzort. Kattints bármire a képernyőn, és a szín a vágólapra kerül. Nyomd meg újra a gyorsbillentyűt, ha választás nélkül ki akarsz lépni.

## Átkódolás megosztás előtt

Egy 4K képernyőfelvétel vagy egy nyers HEIC a telefonodról gyakran túl nagy ahhoz, hogy csak úgy elküldd. A `Super + Ctrl + .` (vagy a _Trigger > Transcode_) ezt megoldja. Egy fuzzy fájlválasztót kínál a `~/Pictures` és a `~/Videos` fölött, majd megkérdezi a formátumot és a méretet.

A képek jpg vagy png formátumba mennek magas, közepes vagy alacsony minőségben, amelyek 3160, 2160 és 1080 képpontban korlátozzák a szélességet. A videók mp4 vagy animált gif formátumba mennek 4k, 1080p vagy 720p felbontásban. Az átalakított fájl az eredeti mellé kerül, a felbontással a nevében — `demo-1080p.mp4` —, és az elérési út fájl-URI-ként a vágólapra másolódik, így közvetlenül beillesztheted egy olyan alkalmazásba, amely elfogad fájlhúzást.

Terminálból is működik, ha már tudod, mit akarsz: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Van továbbá az `omarchy transcode ascii` is, amely egy képet ASCII-művészetté alakít — az leginkább [arculathoz](41-branding.md) való.

## Elküldés valahová

Ha megvan a fájl, a `Super + Ctrl + S` megnyitja a Share menüt, és a LocalSend segítségével elküldi a hálózatodon lévő másik eszközre. Erről lásd a [GUI-k](22-guis.md) fejezetet.
