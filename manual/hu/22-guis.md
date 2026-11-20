# Grafikus felületek

## Files

A Files (Folio) a grafikus fájlkezelő. A `Super + Shift + F` megnyitja, a `Super + Shift + Alt + F` pedig abban a mappában nyitja meg, amelyben éppen a terminálod áll, így sok kattintást megspórolsz. A `Ctrl + L` segítségével beírhatsz egy elérési utat, a `Space` megnyomása bármely fájlon pedig teljes méretben, megnyitás nélkül mutatja meg az előnézetét.

Csatlakoztass egy USB-meghajtót vagy egy SD-kártyát, és automatikusan felcsatolódik, így egyszerűen megjelenik az oldalsávban. Bonyolultabb műveletekhez — meghajtó formázásához, SMART-állapot ellenőrzéséhez, partíciók létrehozásához — indítsd el a _Disks_ alkalmazást az alkalmazásindítóból (`Super + Space`).

A dupla kattintás ésszerű alapértelmezéseket követ: a képek, videók és zenék az Omaview alkalmazásban nyílnak meg, a PDF-ek a Document Viewer alkalmazásban, a Markdown az Omawrite alkalmazásban, az egyszerű szöveg pedig a _Setup > Default > Editor_ alatt kiválasztott szerkesztőben.

## Disktree

Amikor megtelik a meghajtó, és fogalmad sincs, mi falja fel, indítsd el a [Disktree](https://github.com/tobi/disktree) alkalmazást az alkalmazásindítóból (`Super + Space`). A saját mappád grafikus treemapjét mutatja. A nagyobb blokkok több helyet foglalnak; billentyűzettel vagy egérrel lépkedhetsz be a mappákba, megjelölheted, minek kell mennie, és mindent áttekinthetsz a kijelölések közül, mielőtt bármit is eltávolítanál. A `disktree --disk` futtatásával az egész lemezt átvizsgálhatod.

## Obsidian

Az [Obsidian](https://obsidian.md/) egy ingyenes és nagymértékben bővíthető jegyzetelő alkalmazás, amely egyszerű Markdown-fájlokat használ tárolásra.

Az Obsidian minden célra ingyenes, beleértve a személyes, kereskedelmi és nonprofit felhasználást is.

Az Obsidian egy [kereskedelmi kiegészítőt is kínál a szinkronizáláshoz](https://obsidian.md/sync) az iOS-es és androidos mobilalkalmazásokkal. (https://obsidian.md/pricing).

Az Obsidiant a `Super + Shift + O` kombinációval indíthatod. A témaszinkronizálás használatához ki kell választanod az `Omarchy` témát a beállítások alatt.

## Omawrite

Az [Omawrite](https://github.com/omacom-io/omawrite) az Omarchy saját, pofonegyszerű Markdown-íróalkalmazása. Sem vaultok, sem pluginek, csak te meg a szavak.

Az Omawrite-ot a `Super + Shift + W` kombinációval indíthatod.

## Pinta

A [Pinta](https://www.pinta-project.com/) egy egyszerű képszerkesztő eszköz, amely kiváló vágáshoz, átméretezéshez és más alapvető műveletekhez. Csak ne várj tőle Photoshop-alternatívát. De még így is van benne Magic Wand és rétegek!

A Pintát az alkalmazásindítón keresztül indíthatod (`Super + Space`).

## Aether

Az [Aether](https://github.com/bjarneo/aether) egy témakészítő alkalmazás, amely képes színeket kinyerni egy háttérképből, és azokat teljes, egységes témává alakítani. Ez a legegyszerűbb módja annak, hogy [elkészítsd a saját témádat](43-making-your-own-theme.md).

Az Aethert az alkalmazásindítón keresztül indíthatod (`Super + Space`).

## LocalSend

A [LocalSend](https://localsend.org/) segítségével fájlokat küldhetsz ugyanazon a hálózaton lévő, az alkalmazást futtató más eszközökre, mint az Apple AirDropja. Viszont platformfüggetlen, így fájlokat küldhetsz és fogadhatsz Windows, macOS, Android, iOS és persze Linux között.

A Share menüt a `Super + Ctrl + S` kombinációval, vagy az Omarchy menüben a _Trigger > Share_ alatt nyithatod meg. Négy lehetőséget kínál:

- **Clipboard** szöveges fájlként küldi el, bármit is másoltál. Kiváló arra, hogy egy linket vagy egy kódrészletet a telefonodra juttass anélkül, hogy e-mailt küldenél magadnak.
- **File** megnyit egy fájlválasztót, ahol egyszerre többet is kiválaszthatsz.
- **Folder** egy teljes mappát küld el.
- **Receive** megnyitja magát a LocalSendet, hogy egy másik eszköz küldhessen neked valamit.

Ugyanez működik a terminálból is a `omarchy share clipboard`, a `omarchy share file [path]` és a `omarchy share folder [path]` paranccsal. Hagyd el az elérési utat, és megkapod a választót.

Közvetlenül a fájlkezelőből is küldhetsz: kattints jobb gombbal bármely kijelölésre a Files alkalmazásban, és oszd meg a LocalSenddel.

Az Omarchy tűzfala alapértelmezés szerint zárva van, a LocalSend portját kivéve, így ez egy friss telepítésen azonnal működik. Lásd: [biztonság](48-security.md).

## LibreOffice

A [LibreOffice](https://www.libreoffice.org/) egy teljes irodai csomag szövegszerkesztővel, táblázatkezelővel, bemutatókészítővel, rajzalkalmazással és még sok mással. Kompatibilis a Microsoft Office fájljaival, így kiváló módja annak, hogy megnyithasd azokat a Word-dokumentumokat.

A LibreOffice-t az alkalmazásindítón keresztül indíthatod (`Super + Space`).

## Hype

A [Hype](https://github.com/omacom/hype) az Omarchy saját, pofonegyszerű bemutatókészítő alkalmazása. A bemutatód egyetlen Markdown-fájl, mellette a képeivel és videóival: minden diát egy élő előnézet alatt írhatsz meg, húzással sorrendbe rendezheted a diákat, majd teljes képernyőn bemutathatod őket, vagy exportálhatod PDF-be és PowerPointba. Még az Omarchy-témádat is átveszi.

A Hype-ot az alkalmazásindítón keresztül indíthatod (`Super + Space`). Nyomd meg a `?` billentyűt benne, hogy lásd az összes gyorsbillentyűt.

## Signed

A [Signed](https://github.com/omacom/signed) az Omarchy saját, pofonegyszerű módja a PDF-ek aláírásának és kitöltésének. Helyezd el a mentett aláírásodat, szöveget és a mai dátumot bárhová egy oldalon, majd ments egy aláírt másolatot az eredeti mellé. A [PDF-ek kitöltése](27-filling-out-pdfs.md) részben megnézheted, hogyan.

A Signedet az alkalmazásindítón keresztül indíthatod (`Super + Space`), vagy megnyithatsz vele egy PDF-et a fájlkezelőből.

## Game Vibes

A Game Vibes, az alkalmazásindítóban (`Super + Space`), az a hely, ahol az Omarchy apró játékai élnek: a Checkmate, egy 3D-s sakkjáték egy barát vagy a beépített ellenfél ellen; a Cards, Klondike pasziánsz; és a Neon Swarm, egy árkád lövöldözős játék. Mindegyik egyetlen weboldal, amely követi a témádat. Válassz ki egyet a nyilakkal és az `Enter` billentyűvel, és térj vissza a listához az `Esc` billentyűvel egy játék címképernyőjéről, vagy a `Q` billentyűvel, miközben szünetel. Teljes képernyőn nyílik meg: a `Super + F` ablakká alakítja, a `Super + W` pedig bezárja.

Azok a játékok is itt jelennek meg, amelyeket egy ügynökkel készítesz: válaszd a _Make something cool → Game_ lehetőséget az ügynökök paneljén, és írj le egyet, vagy nevezz meg egy már a Game Vibesban lévő játékot, hogy tovább dolgozz rajta. Az ügynök átmásolja azt a `~/Games/vibes` mappába, ahol kedvedre módosíthatod, és megnyitja, amikor elkészült. Ezt a másolatot magad is elkészítheted a `omarchy games vibes copy <game>` paranccsal. Egy más által megosztott játék ugyanúgy telepíthető, mint egy téma: válaszd az _Install > Gaming > Game Vibes_ lehetőséget, és illeszd be a git-címét, vagy futtasd az `omarchy games vibes install <git-repo-url>` parancsot. A _Remove > Gaming_ ismét eltávolítja, az _Update > Game Vibes Games_ pedig lekéri az új verziókat. A játékok a three.js-t a webről töltik be, így az induláshoz kapcsolatra van szükségük.

## Omacalc

Az [Omacalc](https://github.com/omacom-io/omacalc) az Omarchy saját, pofonegyszerű számológépe, amely lebegő ablakban nyílik meg.

Az Omacalcot a `Super + Shift + Q` kombinációval indíthatod (vagy a számológép-billentyűvel, ha a billentyűzeteden van ilyen).

## Signal

A [Signal](https://signal.org/) az E2E-titkosított üzenetküldés úttörője, és kiváló kommunikációs lehetőség mindenkinek, aki inkább nem valamelyik nagy techkonglomerátumon keresztül szeretne kommunikálni.

A Signalt a `Super + Shift + G` kombinációval indíthatod. Nem része az alaptelepítésnek, így amikor először megnyomod ezt, az Omarchy felajánlja, hogy telepíti neked (az Omarchy menüben az _Install > Service_ alatt is megtalálod).

## Omaview

Az [Omaview](https://github.com/omacom/omaview) az Omarchy saját, pofonegyszerű képnézegetője és médialejátszója: egyetlen ablak a fényképeidnek, videóidnak és zenéidnek. Nyiss meg egy fényképet, és a nyílbillentyűk végiglépkednek a mappa többi részén, az `N` és a `P` ugyanezt teszi bármivel, a `Ctrl + M` pedig az egész mappát rácsként mutatja. HEIC, AVIF és JPEG XL fényképeket is megjelenít, és ott folytatja, ahol abbahagytad bármi hosszút.

Nyomd meg az `F` billentyűt a teljes képernyőhöz, az `E` billentyűt egy kép szerkesztéséhez az Omasnapban vagy egy videó vágásához az Omacutban, a `Ctrl + P` kombinációt egy kép nyomtatásához, a `Delete` billentyűt pedig egy fájl Kukába mozgatásához (a `Ctrl + Z` visszahozza). Nyomd meg a `?` billentyűt benne, hogy lásd az összes gyorsbillentyűt.

Az Omaview-t _Media Viewer_ néven az alkalmazásindítón keresztül indíthatod (`Super + Space`), vagy egyszerűen kattints duplán egy képre, videóra vagy dalra a fájlkezelőben.

## Omacut

Az [Omacut](https://github.com/omacom-io/omacut) az Omarchy saját, pofonegyszerű videóvágója. Amikor csak egy klip elejét és végét kell levágnod, sokkal jobb, mint elindítani egy teljes videószerkesztőt.

Az Omacutot az alkalmazásindítón keresztül indíthatod (`Super + Space`).

## Monologue

A [Monologue](https://github.com/omacom/monologue) az Omarchy saját, pofonegyszerű webkamerás felvevője. Válaszd ki egyszer a kamerádat és a mikrofonodat, majd nyomd meg a `Space` billentyűt a felvételhez, és újra ugyanannak a felvételnek a szüneteltetéséhez és folytatásához. Mindig a kamerád legmagasabb felbontásán rögzít, élő mikrofonjelszint-mérővel, hogy indulás előtt ellenőrizhesd a szinteket.

Állítsd le a felvételt, és azonnal megnyílik egy beépített szerkesztőben. Kattints duplán egy klipre a kettévágásához, húzd a fogantyúkat az egyes darabok vágásához, és távolítsd el azokat a részeket, amelyeket nem akarsz. Ezután mentsd el MP4-ként. Az eredeti felvételed megmarad, amíg el nem veted, így mindig visszatérhetsz, és másképp vághatod meg.

A Monologue-ot az alkalmazásindítón keresztül indíthatod (`Super + Space`).
