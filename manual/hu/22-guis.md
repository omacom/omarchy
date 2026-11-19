# GUI-k

## Fájlok

A Files (Nautilus) a grafikus fájlkezelő. A `Super + Shift + F` nyitja meg, a `Super + Shift + Alt + F` pedig abban a mappában nyitja meg, amelyikben a terminálod éppen áll, ami rengeteg kattintást megspórol. A `Ctrl + L` segítségével beírhatsz egy elérési utat, és bármelyik fájlon a `Space` megnyomásával gyors előnézetet kapsz anélkül, hogy bármit is megnyitnál.

Csatlakoztass egy USB-meghajtót vagy egy SD-kártyát, és automatikusan felcsatolódik, így egyszerűen megjelenik az oldalsávban. Bármi komolyabbhoz — egy meghajtó formázásához, a SMART-állapot ellenőrzéséhez, partíciók létrehozásához — indítsd el a _Disks_ alkalmazást az alkalmazásindítóból (`Super + Space`).

A dupla kattintás értelmes alapértelmezéseket követ: a képek, videók és zenék az Omaview-ban nyílnak meg, a PDF-ek a Document Viewerben, a Markdown az Omawrite-ban, az egyszerű szöveg pedig a _Setup > Default > Editor_ alatt kiválasztott szerkesztőben.

## Disktree

Amikor a meghajtó megtelik, és fogalmad sincs, mi zabálja fel, indítsd el a [Disktree](https://github.com/tobi/disktree) alkalmazást az alkalmazásindítóból (`Super + Space`). Grafikus treemapet mutat a saját mappádról. A nagyobb blokkok több helyet foglalnak; billentyűzettel vagy egérrel bejárhatod a mappákat, kijelölheted, minek kell mennie, és átnézheted a kijelöléseidet, mielőtt bármit is eltávolítanál. A teljes lemez vizsgálatához futtasd a `disktree --disk` parancsot.

## Obsidian

Az [Obsidian](https://obsidian.md/) egy ingyenes és rendkívül bővíthető jegyzetelő alkalmazás, amely egyszerű Markdown-fájlokat használ tárolásra.

Az Obsidian minden célra ingyenes, beleértve a személyes, kereskedelmi és nonprofit felhasználást is.

Az Obsidian [kereskedelmi kiegészítőt is kínál a szinkronizáláshoz](https://obsidian.md/sync) iOS-es és Androidos mobilalkalmazásokkal. (https://obsidian.md/pricing).

Az Obsidiant a `Super + Shift + O` billentyűkombinációval indítod. A téma szinkronizálásának használatához a beállításokban ki kell választanod az `Omarchy` témát.

## Omawrite

Az [Omawrite](https://github.com/omacom-io/omawrite) az Omarchy saját, pofonegyszerű Markdown-író alkalmazása. Nincsenek vaultok, nincsenek pluginek, csak te és a szavak.

Az Omawrite-ot a `Super + Shift + W` billentyűkombinációval indítod.

## Pinta

A [Pinta](https://www.pinta-project.com/) egy egyszerű képszerkesztő eszköz, amely remek vágáshoz, átméretezéshez és más alapvető műveletekhez. Csak ne várj tőle Photoshop-alternatívát. De még így is van benne Magic Wand és rétegek!

A Pintát az alkalmazásindítóból indítod (`Super + Space`).

## Aether

Az [Aether](https://github.com/bjarneo/aether) egy témázó alkalmazás, amely képes színeket kinyerni egy háttérképből, és azokat egy teljes, összefüggő témává alakítani. Ez a legegyszerűbb módja annak, hogy [elkészítsd a saját témádat](43-making-your-own-theme.md).

Az Aethert az alkalmazásindítóból indítod (`Super + Space`).

## LocalSend

A [LocalSend](https://localsend.org/) segítségével fájlokat küldhetsz más, ugyanazon a hálózaton lévő, az alkalmazást futtató eszközökre, mint az Apple AirDropja. Viszont platformfüggetlen, így Windowsra, macOSre, Androidra, iOSre és természetesen Linuxra is küldhetsz fájlokat, és fogadhatsz is róluk.

Megnyithatod a Share menüt a `Super + Ctrl + S` billentyűkombinációval, vagy az Omarchy menü _Trigger > Share_ pontjában. Négy lehetőséget kínál:

- **Clipboard** szöveges fájlként küldi el, bármit is másoltál. Remek arra, hogy egy linket vagy egy részletet a telefonodra juttass anélkül, hogy e-mailt küldenél magadnak.
- **File** megnyit egy fájlválasztót, ahol egyszerre többet is kiválaszthatsz.
- **Folder** egy teljes mappát küld el.
- **Receive** megnyitja magát a LocalSendet, hogy egy másik eszköz küldhessen neked valamit.

Ugyanez működik a terminálból is az `omarchy share clipboard`, az `omarchy share file [path]` és az `omarchy share folder [path]` parancsokkal. Hagyd el az elérési utat, és megkapod a választót.

Közvetlenül a fájlkezelőből is küldhetsz: kattints jobb gombbal bármelyik kijelölésre a Nautilusban, és válaszd a _Send via LocalSend_ lehetőséget.

Az Omarchy tűzfala alapértelmezetten zárva van, a LocalSend portja kivételével, így ez egy friss telepítésen azonnal működik. Lásd a [biztonság](48-security.md) részt.

## LibreOffice

A [LibreOffice](https://www.libreoffice.org/) egy teljes irodai csomag szövegszerkesztővel, táblázatkezelővel, prezentációkkal, rajzalkalmazással és még sok mással. Kompatibilis a Microsoft Office fájljaival, így ez egy remek módja annak, hogy meg tudd nyitni azokat a Word-dokumentumokat.

A LibreOffice-t az alkalmazásindítóból indítod (`Super + Space`).

## Hype

A [Hype](https://github.com/omacom/hype) az Omarchy saját, pofonegyszerű prezentációs alkalmazása. A paklid egyetlen Markdown-fájl, mellette a képeivel és videóival: minden diát élő előnézet alatt írsz, a diákat sorrendbe húzod, majd teljes képernyőn prezentálsz, vagy PDF-be és PowerPointba exportálsz. Még az Omarchy-témádat is átveszi.

A Hype-ot az alkalmazásindítóból indítod (`Super + Space`). Nyomd meg a `?` billentyűt benne, hogy lásd az összes gyorsbillentyűt.

## Signed

A [Signed](https://github.com/omacom/signed) az Omarchy saját, pofonegyszerű módja PDF-ek aláírására és kitöltésére. Helyezd el a mentett aláírásodat, szöveget és a mai dátumot bárhová egy oldalon, majd ments egy aláírt példányt az eredeti mellé. A módját lásd a [PDF-ek kitöltése](27-filling-out-pdfs.md) részben.

A Signedet az alkalmazásindítóból indítod (`Super + Space`), vagy megnyithatsz vele egy PDF-et a fájlkezelőből.

## Game Vibes

A Game Vibes az alkalmazásindítóban (`Super + Space`) az a hely, ahol az Omarchy kis játékai élnek: a Checkmate, egy 3D sakkjáték egy barát ellen vagy a beépített ellenfél ellen; a Cards, Klondike pasziánsz; és a Neon Swarm, egy arcade lövöldözős játék. Mindegyik egyetlen weboldal, amely követi a témádat. Válassz ki egyet a nyilakkal és az `Enter` billentyűvel, és térj vissza a listához egy játék címképernyőjéről az `Esc` billentyűvel, vagy szüneteltetés közben a `Q` billentyűvel. Teljes képernyőn nyílik meg: a `Super + F` ablakká teszi, a `Super + W` pedig bezárja.

Az ügynökkel készített játékaid is megjelennek itt: válaszd az ügynökök panelen a _Make something cool → Game_ lehetőséget, és írj le egyet, vagy nevezz meg egy már a Game Vibesban lévő játékot, hogy tovább dolgozz rajta. Az ügynök átmásolja a `~/Games/vibes` mappába, ahol a tiéd, módosíthatod, és megnyitja, amikor elkészült. Ezt a másolatot magad is elkészítheted az `omarchy games vibes copy <game>` paranccsal. Egy más által megosztott játék témaként telepíthető: válaszd az _Install > Gaming > Game Vibes_ lehetőséget, és illeszd be a git-címét, vagy futtasd az `omarchy games vibes install <git-repo-url>` parancsot. A _Remove > Gaming_ újra eltávolít egyet, az _Update > Game Vibes Games_ pedig lekéri az új verziókat. A játékok a three.js-t a webről töltik be, így az induláshoz kapcsolatra van szükségük.

## Omacalc

Az [Omacalc](https://github.com/omacom-io/omacalc) az Omarchy saját, pofonegyszerű számológépe, amely lebegő ablakban nyílik meg.

Az Omacalcot a `Super + Shift + Q` billentyűkombinációval indítod (vagy a számológép billentyűvel, ha a billentyűzeteden van ilyen).

## Signal

A [Signal](https://signal.org/) az E2E titkosított üzenetküldés úttörője, és remek kommunikációs lehetőség mindenkinek, aki inkább nem valamelyik nagy tech-konglomerátumon keresztül intézné.

A Signalt a `Super + Shift + G` billentyűkombinációval indítod. Nem része az alaptelepítésnek, így amikor először megnyomod ezt, az Omarchy felajánlja, hogy telepíti neked (az Omarchy menü _Install > Service_ pontjában is megtalálható).

## Omaview

Az [Omaview](https://github.com/omacom/omaview) az Omarchy saját, pofonegyszerű képnézegetője és médialejátszója: egy ablak a fényképeidnek, videóidnak és zenéidnek. Nyiss meg egy fényképet, és a nyílbillentyűk végiglépkednek a mappája többi részén, az `N` és a `P` ugyanezt teszi bármivel, a `Ctrl + M` pedig az egész mappát rácsként mutatja. HEIC, AVIF és JPEG XL fényképeket is megjelenít, és bármilyen hosszú anyagban ott folytatja, ahol abbahagytad.

Nyomd meg az `F` billentyűt a teljes képernyőhöz, az `E` billentyűt egy kép szerkesztéséhez az Omasnapben vagy egy videó vágásához az Omacutban, a `Ctrl + P` billentyűkombinációt egy kép nyomtatásához, és a `Delete` billentyűt egy fájl Kukába mozgatásához (a `Ctrl + Z` visszahozza). Nyomd meg a `?` billentyűt benne, hogy lásd az összes gyorsbillentyűt.

Az Omaview-t _Media Viewer_ néven indítod az alkalmazásindítóból (`Super + Space`), vagy egyszerűen kattints duplán egy képre, videóra vagy dalra a fájlkezelőben.

## Omacut

Az [Omacut](https://github.com/omacom-io/omacut) az Omarchy saját, pofonegyszerű videóvágója. Amikor csak arra van szükséged, hogy levágd egy klip elejét és végét, jobb, mint elindítani egy teljes videószerkesztőt.

Az Omacutot az alkalmazásindítóból indítod (`Super + Space`).

## Monologue

A [Monologue](https://github.com/omacom/monologue) az Omarchy saját, pofonegyszerű webkamerás rögzítője. Válaszd ki egyszer a kamerádat és a mikrofonodat, majd nyomd meg a `Space` billentyűt a rögzítéshez, és újra a szüneteltetéshez és ugyanazon felvétel folytatásához. Mindig a kamerád legmagasabb felbontásán rögzít, élő mikrofonszint-jelzővel, hogy indulás előtt ellenőrizhesd a szintjeidet.

Állítsd le a felvételt, és azonnal megnyílik egy beépített szerkesztőben. Kattints duplán egy klipre a felosztásához, húzd a fogantyúkat az egyes darabok vágásához, és távolítsd el azokat a részeket, amelyeket nem akarsz. Ezután mentsd el MP4-ként. Az eredeti felvételed megmarad, amíg el nem veted, így mindig visszatérhetsz, és másképp vághatod meg.

A Monologue-ot az alkalmazásindítóból indítod (`Super + Space`).
