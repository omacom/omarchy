# Képernyőképek és rögzítés

Minden, amit le tudsz szedni a képernyőről, a Print Screen billentyűn lóg. Egy billentyű önmagában képet készít, a módosítók pedig felvételt, színt vagy egy területen belüli szöveget adnak. Ha a billentyűzeteden egyáltalán nincs Print Screen billentyű, a `Super + Ctrl + Alt + C` ugyanazt a képernyőképet készíti el, a `Super + Ctrl + C` pedig az egész készletet menüként nyitja meg.

| Billentyűkombináció | Funkció |
| ------ | -------- |
| `Print Screen` | Képernyőkép |
| `Super + Ctrl + Alt + C` | Képernyőkép |
| `Alt + Print Screen` | Képernyőfelvétel (vagy a futó felvétel leállítása) |
| `Super + Print Screen` | Színválasztó |
| `Super + Ctrl + Print Screen` | Szöveg kinyerése egy területről |
| `Super + Ctrl + C` | Rögzítés menü |
| `Super + Ctrl + .` | Kép vagy videó átkódolása |

## Képernyőképek

Nyomd meg a `Print Screen` billentyűt (vagy a `Super + Ctrl + Alt + C` kombinációt), és az Omasnap még a saját felületének megjelenése előtt rögzíti a fókuszban lévő monitort, így célzás közben semmi sem csúszik el alattad. Húzz ki egy szabad formájú területet, kattints egy ablakra a rögzítéséhez, vagy kattints üres területre a teljes monitor rögzítéséhez. Görgethető terület rögzítéséhez a rajzolás előtt nyomd meg az `S` billentyűt. Meggondoltad magad? Nyomd meg újra ugyanazt a billentyűt az Omasnap bezárásához.

Miután kiválasztottál egy területet, az Omasnap elmenti a felvételt, a vágólapra másolja, és értesítést mutat a bélyegképével, ahogyan egy elmentett képernyőfelvétel is teszi. Válaszd az Open lehetőséget a mentett felvétel megtekintéséhez a képnézegetődben, vagy az Edit lehetőséget a feliratozásához.

A feliratozó szerkesztővel nyilakat, vonalakat, alakzatokat, kiemeléseket, számozott jelölőket, szöveget és biztonságos kitakarásokat rajzolhatsz; kivághatod vagy kimetszheted a kép egy részét; OCR-ezheted a szövegét; és hátteret adhatsz hozzá. A szerkesztőben nyomd meg az `Enter` billentyűt a kész PNG másolásához és mentéséhez, a `Ctrl + C` kombinációt a mentés nélküli másoláshoz, vagy a `Ctrl + S` kombinációt a másolás nélküli mentéshez.

A mentett képernyőképek alapértelmezés szerint a `~/Pictures/Screenshots` mappába kerülnek, olyan névvel, mint például a `screenshot-2026-08-13_14-22-05-firefox.png`. Másik könyvtár használatához állítsd be az `OMASNAP_SCREENSHOT_DIR` változót — lásd [a GYIK-et](46-faq.md) arról, hová kell tenni a munkamenet környezeti változóit. Az Omasnap létrehozza a könyvtárat, amikor elmenti az első felvételt. Az automatikus mentés kikapcsolásához állítsd be a `[output] autosave = false` értéket a `~/.config/omasnap/omasnap.conf` fájlban; a felvételek ezután csak a vágólapra kerülnek, és 7 másodpercig megjelennek egy előnézetben, amelyet a rögzítés gombjával vagy a `Ctrl + P` kombinációval tarthatsz a képernyőn.

Terminálból az `omarchy screenshot` ugyanazt a felületet nyitja meg, és kiválaszthatod a kezdő módját: `omarchy capture screenshot region`, `windows`, `fullscreen` vagy `scroll`. A `copy` vagy `save` második argumentum egyenesen az adott célra küldi a képet. Ha a kiadás előtt szerkeszteni szeretnéd, használd az `omarchy screenshot --editor=overlay` parancsot teljes képernyős szerkesztőhöz, vagy az `omarchy screenshot --editor=window` parancsot külön ablakhoz.

### A választó kezelése billentyűzetről

Amíg a kijelölés fent van, egyáltalán nem kell egeret használnod:

| Billentyű | Funkció |
| --- | -------- |
| `S` | Görgethető terület mód be- és kikapcsolása |
| `Super + Arrow keys` | Mozgás az ablakok között Ablak módban |
| `Return` | A kiemelt ablak rögzítése |
| `Ctrl + A` | A teljes, fókuszban lévő monitor rögzítése |
| `R` | Az ebben a munkamenetben utoljára rajzolt terület visszaállítása |
| `Esc` | Az Omasnap bezárása |

Ezek a billentyű-hozzárendelések csak addig léteznek, amíg az Omasnap nyitva van, így nem ütközhetnek semmivel a saját konfigurációdban.

## Képernyőfelvétel

Az `Alt + Print Screen` megnyitja a _Trigger > Capture > Screenrecord_ menüt, amely megkérdezi, mit szeretnél a hangsávra: semmilyen hangot, asztali hangot, asztali hangot és mikrofont, vagy asztali hangot, mikrofont és webkamerát. Ez az utolsó csak akkor jelenik meg, ha ténylegesen van csatlakoztatott kamerád. Válassz ki egyet, és az Omarchy felvételválasztója lehetővé teszi, hogy elhúzz egy területet, vagy rákattints egy ablakra vagy monitorra.

A felvétel a gpu-screen-recorder programon fut, amely a GPU-n kódol 60fps sebességgel, és ha muszáj, visszaesik a CPU-ra; azokon a GPU-kon, amelyeket nem támogat, például az Apple Silicon esetében, az Omarchy helyette a wf-recorder programmal rögzít. Az eredmény egy MP4 a `~/Videos` mappában, `screenrecording-2026-08-13_14-22-05.mp4` névvel. Ennek megváltoztatásához állítsd be az `OMARCHY_SCREENRECORD_DIR` változót — de vedd figyelembe, hogy a képernyőkép-könyvtárral ellentétben ennek már léteznie kell, különben a felvétel nem hajlandó elindulni.

Amíg rögzítesz, egy kis jelző jelenik meg a sávban. Kattints rá a leállításhoz. Leállíthatod az `Alt + Print Screen` ismételt megnyomásával is, vagy a _Trigger > Capture > Screenrecord_ alatt található _Stop Screenrecording_ bejegyzéssel, amely csak akkor jelenik meg, amikor ténylegesen zajlik felvétel.

A leállítás egy kis rendrakást is elvégez, mielőtt átadná neked a fájlt: levágja az első képkockát, és ha van hang, -14 LUFS szintre normalizálja, miközben a PipeWire-rögzítés legelején hallható pattanást elnémítja. Ezután megjelenik egy értesítés a felvételből származó bélyegképpel. Válaszd az _Open_ lehetőséget a fájl lejátszásához az Omaview programban, vagy a _Cut_ lehetőséget a megvágásához az Omacut programban.

### A webkamera-átfedés

Amikor webkamerával rögzítesz, a kamera rögzített, körbevágott, álló ablakként jelenik meg annak a jobb alsó sarkában, amit rögzítesz. Ha éppen eltakar valamit, amire szükséged van, menet közben átméretezheted:

| Billentyűkombináció | Funkció |
| ------ | -------- |
| `Super + Alt + [` | A webkamera-átfedés kisebbé tétele |
| `Super + Alt + ]` | A webkamera-átfedés nagyobbá tétele |

Három méret létezik — kicsi, közepes és nagy —, és a gyorsbillentyűk lépegetnek közöttük. A közepes az alapértelmezett. A méretek arányosak a felvétellel, így a kamera a képkockának ugyanakkora hányadát foglalja el, akár 1080p monitort, akár 6K monitort rögzítesz. Ha pedig teljes képernyő helyett területet rögzítettél, az átfedés annak a területnek a sarkához igazodik a monitor sarka helyett, így a felvételen belül marad.

Közvetlenül is meghívhatod az `omarchy-capture-webcam-resize small` paranccsal, vagy a `reset` argumentummal visszatérhetsz a közepes mérethez.

## Szöveg, QR-kódok és színek

A `Super + Ctrl + Print Screen` kijelöl egy területet, és OCR-rel a vágólapra teszi a szövegét. Ezt rendesen a [Szövegkinyerés és diktálás](11-text-extraction-dictation.md) fejezet tárgyalja.

A _Trigger > Capture > QR Code_ ugyanezt a trükköt csinálja QR-kódokkal. Jelöld ki a kódot tartalmazó területet, és a dekódolt érték a vágólapra kerül. Csak QR-kódokat keres — a sűrű képernyőtartalom egyébként hajlamos tévesen vonalkódként felismerődni. Érdemes tudni: a dekódolt érték a vágólapra kerül, és sehová máshová. Nem kerül kiírásra, nincs benne az értesítésben, és érzékenyként van megjelölve, így nem ragad bent a [vágólapelőzményekben](08-unified-clipboard-history.md). A QR-kódok rendszeresen hordoznak titkokat — például a 2FA beállítási kód mögötti `otpauth://` URI-t —, és nem akarod, hogy ezek naplóba kerüljenek. A beillesztés ettől még tökéletesen működik.

A `Super + Print Screen` (vagy a _Trigger > Capture > Color_) színpipettává alakítja a kurzort. Kattints bármire a képernyőn, és a szín a vágólapra kerül. Nyomd meg újra a gyorsbillentyűt, ha választás nélkül ki akarsz lépni.

## Átkódolás megosztás előtt

Egy 4K képernyőfelvétel vagy a telefonodról származó nyers HEIC gyakran túl nagy ahhoz, hogy csak úgy elküldd. A `Super + Ctrl + .` (vagy a _Trigger > Transcode_) megoldja ezt. Homályos keresésű fájlválasztót kínál a `~/Pictures` és a `~/Videos` felett, majd formátumot és méretet kér.

A képek jpg vagy png formátumba kerülnek magas, közepes vagy alacsony beállítással, amelyek a szélességet 3160, 2160, illetve 1080 pixelben maximalizálják. A videók mp4 vagy animált gif formátumba kerülnek 4k, 1080p vagy 720p felbontásban. Az átalakított fájl az eredeti mellé íródik, a felbontással a nevében — `demo-1080p.mp4` —, és az elérési útja fájl-URI-ként a vágólapra másolódik, így közvetlenül beillesztheted egy olyan alkalmazásba, amely elfogadja a fájlok behúzását.

Terminálból is működik, ha már tudod, mit akarsz: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Létezik az `omarchy transcode ascii` is, amely képet alakít ASCII-művészetté — az főleg [márkaépítéshez](41-branding.md) való.

## Elküldés valahová

Ha megvan a fájl, a `Super + Ctrl + S` megnyitja a Share menüt, és a LocalSend segítségével elküldi a hálózatodon lévő másik eszközre. Erről lásd a [Grafikus felületek](22-guis.md) fejezetet.
