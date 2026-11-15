# GUI-k

## Files

Files (Nautilus) a grafikus fájlkezelő. A `Super + Shift + F` nyitja meg, a `Super + Shift + Alt + F` pedig abban a könyvtárban nyitja meg, amelyben a terminálod éppen áll, ami rengeteg kattintást megspórol. A `Ctrl + L` segítségével beírhatsz egy útvonalat, és ha bármelyik fájlon lenyomod a `Space` billentyűt, gyors előnézetet kapsz anélkül, hogy bármit megnyitnál.

Csatlakoztass egy USB-meghajtót vagy egy SD-kártyát, és automatikusan csatolódik, így egyszerűen megjelenik az oldalsávban. Bonyolultabb dolgokhoz — meghajtó formázása, SMART-állapot ellenőrzése, partíciók létrehozása — indítsd el a _Disks_ alkalmazást az alkalmazásindítóból (`Super + Space`).

A dupla kattintás ésszerű alapértelmezéseket követ: a képek, videók és zenék az Omaview alkalmazásban nyílnak meg, a PDF-ek a Document Viewer alkalmazásban, az egyszerű szövegfájlok pedig a Neovim alkalmazásban.

## Disktree

Amikor a meghajtó megtelik, és fogalmad sincs, mi zabálja a helyet, indítsd el a [Disktree](https://github.com/tobi/disktree) alkalmazást az alkalmazásindítóból (`Super + Space`). Grafikus treemap formájában mutatja a saját könyvtáradat. A nagyobb blokkok több helyet foglalnak; billentyűzettel vagy egérrel lépj be a könyvtárakba, jelöld meg, minek kell mennie, és bármit törölnél, előbb nézd át a kijelöléseidet. A teljes lemez átvizsgálásához futtasd a `disktree --disk` parancsot.

## Obsidian

Az [Obsidian](https://obsidian.md/) ingyenes és rendkívül bővíthető jegyzetelő alkalmazás, amely egyszerű Markdown-fájlokat használ tárolásra.

Az Obsidian minden célra ingyenes, beleértve a személyes, kereskedelmi és nonprofit felhasználást is.

Az Obsidian [kereskedelmi szinkronizálási kiegészítőt](https://obsidian.md/sync) is kínál iOS és Android mobilalkalmazásokhoz. (https://obsidian.md/pricing).

Az Obsidian a `Super + Shift + O` kombinációval indul. A témaszinkronizálás használatához a beállításokban ki kell választanod az `Omarchy` témát.

## Omawrite

Az [Omawrite](https://github.com/omacom-io/omawrite) az Omarchy saját, pofonegyszerű Markdown-író alkalmazása. Nincsenek vaultok, nincsenek bővítmények, csak te és a szavak.

Az Omawrite a `Super + Shift + W` kombinációval indul.

## Pinta

A [Pinta](https://www.pinta-project.com/) egy egyszerű képszerkesztő eszköz, amely kiváló vágáshoz, átméretezéshez és más alapvető műveletekhez. Csak ne várj tőle Photoshop-alternatívát. De azért van benne Magic Wand és rétegek is!

A Pintát az alkalmazásindítón keresztül indítod (`Super + Space`).

## Aether

Az [Aether](https://github.com/bjarneo/aether) egy témakészítő alkalmazás, amely színeket tud kinyerni egy háttérképből, és azokat teljes, egységes témává tudja alakítani. Ez a legegyszerűbb módja annak, hogy [saját témát készíts](43-making-your-own-theme.md).

Az Aethert az alkalmazásindítón keresztül indítod (`Super + Space`).

## LocalSend

A [LocalSend](https://localsend.org/) segítségével fájlokat küldhetsz ugyanazon a hálózaton lévő, az alkalmazást futtató más eszközökre, mint az Apple AirDropja. Csakhogy ez platformfüggetlen, így fájlokat küldhetsz Windows, macOS, Android, iOS és persze Linux rendszerekre és rendszerekről is.

A Share menüt a `Super + Ctrl + S` kombinációval, vagy az Omarchy menüben a _Trigger > Share_ alatt nyithatod meg. Négy lehetőséget kínál:

- **Clipboard** szövegfájlként küldi el, bármit is másoltál. Kiváló arra, hogy egy linket vagy egy részletet a telefonodra juttass anélkül, hogy e-mailt küldenél magadnak.
- **File** megnyit egy fájlválasztót, ahol egyszerre többet is kiválaszthatsz.
- **Folder** egy teljes könyvtárat küld el.
- **Receive** megnyitja magát a LocalSend alkalmazást, hogy egy másik eszköz küldhessen neked valamit.

Ugyanez működik terminálból is a `omarchy share clipboard`, az `omarchy share file [path]` és az `omarchy share folder [path]` paranccsal. Hagyd el az útvonalat, és megkapod a választót.

Közvetlenül a fájlkezelőből is küldhetsz: kattints jobb gombbal bármilyen kijelölésre a Nautilusban, és válaszd a _Send via LocalSend_ lehetőséget.

Az Omarchy tűzfala alapértelmezetten zárva van, a LocalSend portját kivéve, így ez egy friss telepítésen azonnal működik. Lásd a [biztonság](48-security.md) részt.

## LibreOffice

A [LibreOffice](https://www.libreoffice.org/) teljes irodai csomag szövegszerkesztővel, táblázatkezelővel, prezentációkészítővel, rajzalkalmazással és még sok mással. Kompatibilis a Microsoft Office fájljaival, így ez kiváló módja annak, hogy meg tudd nyitni azokat a Word-dokumentumokat.

A LibreOffice-t az alkalmazásindítón keresztül indítod (`Super + Space`).

## Hype

A [Hype](https://github.com/omacom/hype) az Omarchy saját, pofonegyszerű prezentációs alkalmazása. A prezentációd egyetlen Markdown-fájl, mellette a képeivel és videóival: minden diát egy élő előnézet alatt írj meg, húzd a diákat a helyükre, majd mutasd be teljes képernyőn, vagy exportáld PDF és PowerPoint formátumba. Még az Omarchy-témádat is átveszi.

A Hype-ot az alkalmazásindítón keresztül indítod (`Super + Space`). Nyomd meg benne a `?` billentyűt az összes billentyűparancs megtekintéséhez.

## Signed

A [Signed](https://github.com/omacom/signed) az Omarchy saját, pofonegyszerű megoldása PDF-ek aláírására és kitöltésére. Helyezd el a mentett aláírásodat, szöveget és a mai dátumot bárhová egy oldalon, majd ments egy aláírt másolatot az eredeti mellé. A módját lásd a [PDF-ek kitöltése](27-filling-out-pdfs.md) részben.

A Signed alkalmazást az alkalmazásindítón keresztül indítod (`Super + Space`), vagy nyiss meg vele egy PDF-et a fájlkezelőből.

## Omacalc

Az [Omacalc](https://github.com/omacom-io/omacalc) az Omarchy saját, pofonegyszerű számológépe, amely lebegő ablakban nyílik meg.

Az Omacalc a `Super + Shift + Q` kombinációval indul (vagy a számológép billentyűvel, ha a billentyűzeteden van ilyen).

## Signal

A [Signal](https://signal.org/) az E2E titkosított üzenetküldés úttörője, és kiváló kommunikációs lehetőség mindenkinek, aki inkább nem valamelyik nagy technológiai konglomerátumon keresztül szeretne kommunikálni.

A Signal a `Super + Shift + G` kombinációval indul. Nem része az alaptelepítésnek, így amikor először lenyomod ezt, az Omarchy felajánlja, hogy telepíti neked (az Omarchy menüben az _Install > Service_ alatt is megtalálod).

## Omaview

Az [Omaview](https://github.com/omacom/omaview) az Omarchy saját, pofonegyszerű képmegjelenítője és médialejátszója: egy ablak a fotóidhoz, videóidhoz és zenéidhez. Nyiss meg egy fotót, és a nyílbillentyűk végiglépkednek a mappája többi elemén, az `N` és a `P` ugyanezt teszi bármivel, a `Ctrl + M` pedig az egész mappát rácsként mutatja. HEIC, AVIF és JPEG XL fotókat is megjelenít, és minden hosszabb tartalomban ott folytatja, ahol abbahagytad.

Nyomd meg az `F` billentyűt a teljes képernyőhöz, az `E` billentyűt egy kép szerkesztéséhez az Omasnap alkalmazásban vagy egy videó vágásához az Omacut alkalmazásban, a `Ctrl + P` kombinációt egy kép nyomtatásához, a `Delete` billentyűt pedig egy fájl Kukába helyezéséhez (a `Ctrl + Z` visszahozza). Nyomd meg benne a `?` billentyűt az összes billentyűparancs megtekintéséhez.

Az Omaview alkalmazást _Media Viewer_ néven indítod az alkalmazásindítón keresztül (`Super + Space`), vagy egyszerűen kattints duplán egy képre, videóra vagy dalra a fájlkezelőben.

## Omacut

Az [Omacut](https://github.com/omacom-io/omacut) az Omarchy saját, pofonegyszerű videóvágója. Amikor csak egy klip elejét és végét kell levágnod, sokkal jobb, mint elindítani egy teljes videószerkesztőt.

Az Omacutot az alkalmazásindítón keresztül indítod (`Super + Space`).

## Monologue

A [Monologue](https://github.com/omacom/monologue) az Omarchy saját, pofonegyszerű webkamerás felvevője. Válaszd ki egyszer a kamerádat és a mikrofonodat, majd nyomd meg a `Space` billentyűt a felvételhez, és újra ugyanannak a felvételnek a szüneteltetéséhez és folytatásához. Mindig a kamerád legmagasabb felbontásában rögzít, élő mikrofonszint-jelzővel, hogy indulás előtt ellenőrizhesd a szinteket.

Állítsd le a felvételt, és azonnal megnyílik egy beépített szerkesztőben. Kattints duplán egy klipre a felosztásához, húzd a fogantyúkat az egyes darabok vágásához, és távolítsd el azokat a részeket, amelyeket nem akarsz. Ezután mentsd el MP4 formátumban. Az eredeti felvételed megmarad, amíg el nem veted, így bármikor visszatérhetsz, és másképp vághatod meg.

A Monologue-ot az alkalmazásindítón keresztül indítod (`Super + Space`).
