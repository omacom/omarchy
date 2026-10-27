# Képernyőképek és rögzítés

Minden, amit le tudsz kapni a képernyőről, a Print Screen billentyűn lóg. Egyetlen billentyű önmagában képet készít, a módosítók pedig felvételt, színt vagy egy tartományon belüli szöveget adnak. Ha a billentyűzeteden egyáltalán nincs Print Screen billentyű, a `Super + Ctrl + Alt + C` ugyanazt a képernyőképet készíti el, a `Super + Ctrl + C` pedig az egész készletet menüként nyitja meg.

| Billentyűparancs | Funkció |
| ------ | -------- |
| `Print Screen` | Képernyőkép |
| `Super + Ctrl + Alt + C` | Képernyőkép |
| `Alt + Print Screen` | Képernyőfelvétel (vagy a futó felvétel leállítása) |
| `Super + Print Screen` | Színválasztó |
| `Super + Ctrl + Print Screen` | Szöveg kinyerése egy tartományból |
| `Super + Ctrl + C` | Rögzítés menü |
| `Super + Ctrl + .` | Kép vagy videó átkódolása |

## Képernyőképek

Nyomd meg a `Print Screen` billentyűt (vagy a `Super + Ctrl + Alt + C` kombinációt), és az Omasnap még az átfedő felülete megjelenése előtt rögzíti a fókuszált monitort, így semmi nem mozdul el alattad, miközben célzol. Húzz egy szabad formájú tartományt, kattints egy ablakra a rögzítéséhez, vagy kattints üres területre az egész monitor rögzítéséhez. Nyomd meg az `S` billentyűt a rajzolás előtt görgethető tartomány rögzítéséhez. Meggondoltad magad? Nyomd meg újra ugyanazt a billentyűt az Omasnap bezárásához.

Miután kiválasztottál egy területet, az Omasnap menti a felvételt, a vágólapra másolja, és értesítést mutat az indexképével, ahogyan egy mentett képernyőfelvétel is teszi. Válaszd a Megnyitás lehetőséget a mentett felvétel megtekintéséhez a képnézegetődben, vagy a Szerkesztés lehetőséget a feljegyzésekkel való ellátásához.

A feljegyzésszerkesztő tud nyilakat, vonalakat, alakzatokat, kiemeléseket, számozott jelölőket, szöveget és biztonságos kitakarásokat rajzolni; kivágni vagy kimetszeni a kép egy részét; OCR-ezni a szövegét; és hátteret adni hozzá. A szerkesztőben nyomd meg az `Enter` billentyűt a kész PNG másolásához és mentéséhez, a `Ctrl + C` kombinációt a mentés nélküli másolásához, vagy a `Ctrl + S` kombinációt a másolás nélküli mentéséhez.

A mentett képernyőképek alapértelmezés szerint a `~/Pictures/Screenshots` mappába kerülnek, olyan névvel, mint a `screenshot-2026-08-13_14-22-05-firefox.png`. Állítsd be az `OMASNAP_SCREENSHOT_DIR` változót másik könyvtár használatához — lásd [a GYIK-et](46-faq.md) arról, hová kell tenni a munkamenet környezeti változóit. Az Omasnap létrehozza a könyvtárat, amikor menti az első felvételt. Állítsd be a `[output] autosave = false` értéket a `~/.config/omasnap/omasnap.conf` fájlban az automatikus mentés letiltásához; a felvételek ilyenkor csak másolódnak, és 10 másodpercig megjelennek egy előnézetben, amelyet a rögzítés gombjával vagy a `Ctrl + P` kombinációval a képernyőn tarthatsz.

Terminálból az `omarchy screenshot` ugyanazt az átfedő felületet nyitja meg, és kiválaszthatod a kezdő módját: `omarchy capture screenshot region`, `windows`, `fullscreen` vagy `scroll`. A `copy` vagy `save` második argumentum egyenesen az adott célhelyre küldi a felvételt. Ha a kimenet előtt szerkeszteni szeretnél, használd az `omarchy screenshot --editor=overlay` parancsot teljes képernyős szerkesztőhöz, vagy az `omarchy screenshot --editor=window` parancsot külön ablakhoz.

### A választó vezérlése billentyűzetről

Amíg a kijelölés látható, egyáltalán nem kell egeret használnod:

| Billentyű | Funkció |
| --- | -------- |
| `S` | Görgethető tartomány mód be- és kikapcsolása |
| `Super + Arrow keys` | Mozgás az ablakok között Ablak módban |
| `Return` | A kiemelt ablak rögzítése |
| `Ctrl + A` | A teljes fókuszált monitor rögzítése |
| `R` | Az ebben a munkamenetben utoljára rajzolt tartomány visszaállítása |
| `Esc` | Az Omasnap bezárása |

Ezek a billentyűhozzárendelések csak addig léteznek, amíg az Omasnap nyitva van, így nem ütközhetnek semmivel a saját konfigurációdban.

## Képernyőfelvétel

Az `Alt + Print Screen` megnyitja a _Trigger > Capture > Screenrecord_ menüt, amely megkérdezi, mit szeretnél a hangsávra: semmilyen hangot, asztali hangot, asztali hangot plusz mikrofont, vagy asztali hangot plusz mikrofont plusz webkamerát. Ez utóbbi csak akkor jelenik meg, ha ténylegesen van bedugott kamerád. Válassz egyet, és az Omarchy felvételválasztója lehetővé teszi, hogy tartományt húzz, vagy ablakra vagy monitorra kattints.

A felvétel a gpu-screen-recorder programon fut, amely a GPU-n kódol 60fps sebességgel, és ha kell, visszaesik a CPU-ra. Az eredmény egy MP4 a `~/Videos` mappában, `screenrecording-2026-08-13_14-22-05.mp4` néven. Állítsd be az `OMARCHY_SCREENRECORD_DIR` változót ennek módosításához — de vedd figyelembe, hogy a képernyőkép-könyvtárral ellentétben ennek már léteznie kell, különben a felvétel nem hajlandó elindulni.

Amíg rögzítesz, egy kis jelző jelenik meg a sávban. Kattints rá a leállításhoz. Leállíthatod az `Alt + Print Screen` ismételt megnyomásával is, vagy a _Trigger > Capture > Screenrecord_ alatt található _Stop Screenrecording_ bejegyzéssel, amely csak akkor jelenik meg, amíg ténylegesen rögzít valami.

A leállítás egy kis rendrakást végez, mielőtt átadná a fájlt: az első képkocka levágásra kerül, és ha van hang, az -14 LUFS értékre normalizálódik, miközben a PipeWire rögzítési pattanása a legelején elnémul. Ezután megjelenik egy értesítés a felvételből származó indexképpel. Kattints rá a fájl mpv-ben való lejátszásához.

### A webkamera-átfedés

Amikor webkamerával rögzítesz, a kamera rögzített, körbevágott portréablakként jelenik meg annak a jobb alsó sarkában, amit rögzítesz. Ha olyasmi felett ül, amire szükséged van, menet közben méretezd át:

| Billentyűparancs | Funkció |
| ------ | -------- |
| `Super + Alt + [` | A webkamera-átfedés kisebbé tétele |
| `Super + Alt + ]` | A webkamera-átfedés nagyobbá tétele |

Három méret van — kicsi, közepes és nagy —, és a billentyűparancsok ezek között léptetnek. A közepes az alapértelmezett. Arányosak a felvételhez, így a kamera ugyanakkora részét foglalja el a képnek, akár 1080p monitort, akár 6K monitort rögzítesz. És ha tartományt rögzítettél az egész kijelző helyett, az átfedés annak a tartománynak a sarkához rögzül a monitoré helyett, így a felvételen belül marad.

Közvetlenül is meghívhatod az `omarchy-capture-webcam-resize small` paranccsal, vagy a `reset` argumentummal visszatérhetsz a közepeshez.

## Szöveg, QR-kódok és színek

A `Super + Ctrl + Print Screen` kiválaszt egy tartományt, és OCR-ezi a vágólapra. Ezt megfelelően tárgyalja a [Szövegkinyerés és diktálás](11-text-extraction-dictation.md).

A _Trigger > Capture > QR Code_ ugyanezt a trükköt csinálja QR-kódokkal. Válaszd ki a tartományt, amelyben a kód van, és a dekódolt érték a vágólapra kerül. Csak QR-kódokat keres — a sűrű képernyőtartalom egyébként hajlamos arra, hogy tévesen vonalkódként ismerje fel a rendszer. Érdemes tudni: a dekódolt érték a vágólapra kerül, és sehová máshová. Nem kerül kiírásra, nincs benne az értesítésben, és érzékenyként van megjelölve, így nem marad meg a [vágólap-előzményekben](08-unified-clipboard-history.md). A QR-kódok rendszeresen hordoznak titkokat — például egy 2FA beállítási kód mögötti `otpauth://` URI-t —, és ezt nem akarod egy naplóban látni. A beillesztés továbbra is jól működik.

A `Super + Print Screen` (vagy a _Trigger > Capture > Color_) pipettává változtatja a kurzort. Kattints bármire a képernyőn, és a szín a vágólapra kerül. Nyomd meg újra a billentyűparancsot a kilépéshez választás nélkül.

## Átkódolás megosztás előtt

Egy 4K képernyőfelvétel vagy egy nyers HEIC a telefonodról gyakran túl nagy ahhoz, hogy csak úgy elküldd. A `Super + Ctrl + .` (vagy a _Trigger > Transcode_) ezt javítja. Fuzzy fájlválasztót kínál a `~/Pictures` és a `~/Videos` felett, majd formátumot és méretet kér.

A képek jpg vagy png formátumba kerülnek magas, közepes vagy alacsony szinten, amelyek a szélességet 3160, 2160 és 1080 pixelben maximalizálják. A videók mp4 vagy animált gif formátumba kerülnek 4k, 1080p vagy 720p felbontásban. A konvertált fájl az eredeti mellé íródik, a felbontással a nevében — `demo-1080p.mp4` —, és az elérési út fájl-URI-ként a vágólapra másolódik, így közvetlenül beillesztheted egy olyan alkalmazásba, amely elfogad fájldobásokat.

Terminálból is működik, ha már tudod, mit szeretnél: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Van egy `omarchy transcode ascii` is, amely egy képet ASCII-művészetté alakít — az leginkább [arculathoz](41-branding.md) való.

## Elküldés valahová

Miután megvan a fájl, a `Super + Ctrl + S` megnyitja a Megosztás menüt, és elküldi egy másik eszközre a hálózatodon LocalSend segítségével. Lásd erről a [GUI-kat](22-guis.md).
