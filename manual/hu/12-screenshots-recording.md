# Képernyőképek és felvétel

Minden, amit a képernyőről lekapni tudsz, a Print Screen billentyűn lóg. Ez az egy billentyű önmagában képet készít, a módosítók pedig felvételt, színt vagy egy területen belüli szöveget. Ha a billentyűzetednek egyáltalán nincs Print Screen billentyűje, a `Super + Ctrl + C` ugyanazt a készletet nyitja meg menüként.

| Billentyűparancs | Funkció |
| ------ | -------- |
| `Print Screen` | Képernyőkép |
| `Alt + Print Screen` | Képernyőfelvétel (vagy a futó leállítása) |
| `Super + Print Screen` | Színválasztó |
| `Super + Ctrl + Print Screen` | Szövegkinyerés egy területről |
| `Super + Ctrl + C` | Rögzítés menü |
| `Super + Ctrl + .` | Egy kép vagy videó átkódolása |

## Képernyőképek

Nyomd meg a `Print Screen` billentyűt, és az Omasnap még a fedvényének megjelenése előtt rögzíti a fókuszált monitort, így semmi sem mozdul el alattad, miközben célzol. Húzz egy szabad formájú területet, kattints egy ablakra annak rögzítéséhez, vagy kattints üres térre az egész monitor rögzítéséhez. Nyomd meg az `S` billentyűt rajzolás előtt görgetődő terület rögzítéséhez. Meggondoltad magad? Nyomd meg újra a `Print Screen` billentyűt az Omasnap elvetéséhez.

Miután kiválasztottál egy területet, az Omasnap menti a rögzítést, a vágólapra másolja, és 10 másodpercig előnézetet mutat. Az előnézet rögzítés gombjával vagy a `Ctrl + P` kombinációval a képernyőn tarthatod, vagy válaszd az Edit lehetőséget a jegyzeteléshez.

A jegyzetelő szerkesztő tud nyilakat, vonalakat, alakzatokat, kiemeléseket, számozott jelölőket, szöveget és biztonságos kitakarásokat rajzolni; körbevágni vagy kivágni a kép egy részét; OCR-ezni a szövegét; és hátteret hozzáadni. A szerkesztőben nyomd meg az `Enter` billentyűt a kész PNG másolásához és mentéséhez, a `Ctrl + C` kombinációt mentés nélküli másolásához, vagy a `Ctrl + S` kombinációt másolás nélküli mentéséhez.

A mentett képernyőképek alapértelmezetten a `~/Pictures/Screenshots` mappában landolnak, például `screenshot-2026-08-13_14-22-05-firefox.png` néven. Állítsd be az `OMASNAP_SCREENSHOT_DIR` változót egy másik mappához — hogy hova tegyél munkamenet-környezetváltozókat, azt lásd [a FAQ-ban](46-faq.md). Az Omasnap az első felvétel mentésekor létrehozza a mappát. Állítsd a `~/.config/omasnap/omasnap.conf` fájlban az `[output] autosave = false` opciót az automatikus mentés letiltásához.

Terminálból az `omarchy screenshot` ugyanazt a fedvényt nyitja meg, és kiválaszthatod az indulási módját: `omarchy capture screenshot region`, `windows`, `fullscreen` vagy `scroll`. A `copy` vagy `save` második argumentum kihagyja az előnézetet, és egyenesen abba a célba küldi a felvételt. Kimenet előtti szerkesztéshez használd az `omarchy screenshot --editor=overlay` opciót teljes képernyős szerkesztőhöz, vagy az `omarchy screenshot --editor=window` opciót külön ablakhoz.

### A választó vezérlése billentyűzetről

Amíg a kijelölés fenn van, egyáltalán nem kell egeret használnod:

| Billentyű | Funkció |
| --- | -------- |
| `S` | Görgetődő terület módjának kapcsolása |
| `Super + Arrow keys` | Mozgás az ablakok között Window módban |
| `Return` | A kijelölt ablak rögzítése |
| `Ctrl + A` | A teljes fókuszált monitor rögzítése |
| `R` | Ebben a munkamenetben utoljára rajzolt terület visszaállítása |
| `Esc` | Az Omasnap elvetése |

Ezek a hozzárendelések csak addig léteznek, amíg az Omasnap nyitva van, így nem ütközhetnek semmivel a saját konfigurációdban.

## Képernyőfelvétel

Az `Alt + Print Screen` megnyitja a _Trigger > Capture > Screenrecord_ pontot, amely megkérdezi, mit kérsz a hanganyagba: hang nélkül, asztali hang, asztali plusz mikrofonhang, vagy asztali plusz mikrofonhang plusz webkamera. Ez utóbbi csak akkor jelenik meg, ha tényleg be van dugva egy kamerád. Válassz ki egyet, és az Omarchy felvételi választója lehetővé teszi, hogy területet húzz vagy ablakra vagy monitorra kattints.

A felvétel a gpu-screen-recorder-en fut, amely a GPU-n kódol 60fps-sel, és ha kell, visszaesik a CPU-ra. Az eredmény egy MP4 a `~/Videos` mappában, `screenrecording-2026-08-13_14-22-05.mp4` néven. Állítsd be az `OMARCHY_SCREENRECORD_DIR` változót ennek megváltoztatásához — de jegyezd meg, hogy a képernyőképmappától eltérően ennek már léteznie kell, különben a felvétel nem hajlandó elindulni.

Amíg felvételt készítesz, egy kis jelző jelenik meg a sávon. Kattints rá a leállításhoz. A leállításhoz használhatod ismét az `Alt + Print Screen` kombinációt, vagy a _Trigger > Capture > Screenrecord_ alatti _Stop Screenrecording_ bejegyzést, amely csak akkor jelenik meg, amikor tényleg történik felvétel.

A leállítás némi rendet tesz, mielőtt átadja a fájlt: levágja az első képkockát, és ha van hang, azt -14 LUFS-ra normalizálja, a PipeWire-rögzítés elején lévő pukkanást elnémítva. Ezután értesítés jelenik meg a felvétel egyik bélyegképével. Kattints rá, hogy mpv-ben játszd le a fájlt.

### A webkamera-fedvény

Ha webkamerával veszel fel, a kamera rögzített, vágott álló ablakként jelenik meg a felvétel jobb alsó sarkában. Ha valami előtt ül, amire szükséged van, menet közben is átméretezheted:

| Billentyűparancs | Funkció |
| ------ | -------- |
| `Super + Alt + [` | A webkamera-fedvény kisebbítése |
| `Super + Alt + ]` | A webkamera-fedvény nagyobbítása |

Három méret van — kicsi, közepes és nagy —, és a billentyűparancsok léptetnek köztük. A közepes az alapértelmezett. Arányosak a felvételhez képest, így a kamera ugyanakkora hányadot foglal el a képen, akár egy 1080p monitort, akár egy 6K-st veszel fel. És ha kijelző helyett egy területet vettél fel, a fedvény annak a területnek a sarkához horgonyoz, a monitoré helyett, így a felvételen belül marad.

Közvetlenül is hívhatod az `omarchy-capture-webcam-resize small` paranccsal, vagy a `reset` argumentummal a közepes állapothoz való visszatéréshez.

## Szöveg, QR-kódok és színek

A `Super + Ctrl + Print Screen` kiválaszt egy területet, és OCR-ezi a vágólapra. Ez rendesen le van fedve a [Text Extraction & Dictation](11-text-extraction-dictation.md) fejezetben.

A _Trigger > Capture > QR Code_ ugyanazt a trükköt játssza QR-kódokkal. Jelöld ki a területet a benne lévő kóddal, és a dekódolt érték a vágólapra kerül. Csak QR-kódokat keres — sűrű képernyőtartalomnak máskülönben van szokása, hogy vonalkódként fals-pozitívan jelenjen meg. Érdemes tudni: a dekódolt érték a vágólapra kerül, és máshová nem. Nem kerül kinyomtatásra, nincs benne az értesítésben, és érzékenyként van megjelölve, így nem ragad ott [a vágólap-előzményekben](08-unified-clipboard-history.md). A QR-kódok rendszeresen titkokat hordoznak — például egy 2FA-beállítási kód mögötti `otpauth://` URI-t —, és ezt nem akarod naplóban látni. A beillesztés továbbra is rendben működik.

A `Super + Print Screen` (vagy _Trigger > Capture > Color_) szemcseppentővé változtatja a kurzort. Kattints bármire a képernyőn, és a szín a vágólapon landol. Nyomd meg újra a billentyűparancsot, hogy választás nélkül visszalépj.

## Átkódolás megosztás előtt

Egy 4K képernyőfelvétel vagy egy telefonról érkező nyers HEIC gyakran túl nagy ahhoz, hogy csak úgy elküldhesd. A `Super + Ctrl + .` (vagy _Trigger > Transcode_) ezt javítja. Homályos fájlválasztót kínál a `~/Pictures` és `~/Videos` mappákon, majd formátumot és méretet kér.

A képek jpg-be vagy png-be mennek, high, medium vagy low méretben, amelyek a szélességet 3160, 2160 és 1080 pixelre korlátozzák. A videók mp4-be vagy animált gif-be mennek 4k, 1080p vagy 720p méretben. A konvertált fájl az eredeti mellé kerül a nevében szereplő felbontással — `demo-1080p.mp4` —, és az útvonala fájl-URI-ként a vágólapra másolódik, így egyenesen egy fájlbedobást fogadó appba illesztheted be.

Terminálból is működik, ha már tudod, mit szeretnél: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. Van `omarchy transcode ascii` is, amely egy képet ASCII-rajzzá alakít — ez leginkább a [brandinghez](41-branding.md) való.

## Valahova küldés

Amint megvan a fájl, a `Super + Ctrl + S` megnyitja a Share menüt és elküldi azt a hálózatodon lévő másik eszközre LocalSenden keresztül. Erről lásd a [GUI-kat](22-guis.md).
