# GUI-k

## Files

A Files (Nautilus) a grafikus fájlkezelő. A `Super + Shift + F` nyitja meg, a `Super + Shift + Alt + F` pedig abban a könyvtárban, amelyben a terminálod éppen áll, ami rengeteg kattintást megspórol. A `Ctrl + L` segítségével beírhatsz egy elérési utat, bármelyik fájlon a `Space` lenyomásával pedig gyors előnézetet kapsz anélkül, hogy bármit megnyitnál.

Dugj be egy USB-meghajtót vagy egy SD-kártyát, és automatikusan csatolódik, így egyszerűen megjelenik az oldalsávban. Bármi komolyabbhoz — meghajtó formázásához, a SMART-állapot ellenőrzéséhez, partíciók létrehozásához — indítsd el a _Disks_ alkalmazást az alkalmazásindítóból (`Super + Space`).

A dupla kattintás ésszerű alapértelmezéseket követ: a képek, videók és zenék az Omaview-ban, a PDF-ek a Document Viewerben, a Markdown az Omawrite-ban, az egyszerű szöveg pedig a _Setup > Default > Editor_ alatt kiválasztott szerkesztőben nyílik meg.

## Disktree

Amikor megtelik a meghajtó, és fogalmad sincs, mi zabálja fel, indítsd el a [Disktree](https://github.com/tobi/disktree) alkalmazást az alkalmazásindítóból (`Super + Space`). Grafikus treemapként mutatja a saját könyvtáradat. A nagyobb blokkok több helyet foglalnak; a billentyűzettel vagy az egérrel járhatod be a könyvtárakat, kijelölheted, minek kell mennie, és még az eltávolítás előtt átnézheted a kijelöléseidet. A `disktree --disk` futtatásával az egész lemezt átvizsgálhatod.

## Obsidian

Az [Obsidian](https://obsidian.md/) egy ingyenes, rendkívül bővíthető jegyzetelő alkalmazás, amely egyszerű Markdown-fájlokat használ tárolásra.

Az Obsidian minden célra ingyenes, beleértve a személyes, kereskedelmi és nonprofit felhasználást is.

Az Obsidian kínál egy [kereskedelmi kiegészítőt a szinkronizáláshoz](https://obsidian.md/sync) is, amellyel iOS-en és Androidon futó mobilalkalmazásokkal szinkronizálhatsz. (https://obsidian.md/pricing).

Az Obsidiant a `Super + Shift + O` billentyűkombinációval indítod. A téma szinkronizálásához a beállításokban ki kell választanod az `Omarchy` témát.

## Omawrite

Az [Omawrite](https://github.com/omacom-io/omawrite) az Omarchy saját, pofonegyszerű Markdown-író alkalmazása. Nincsenek vaultok, nincsenek pluginek, csak te és a szavak.

Az Omawrite-ot a `Super + Shift + W` billentyűkombinációval indítod.

## Pinta

A [Pinta](https://www.pinta-project.com/) egy egyszerű képszerkesztő eszköz, amely remekül használható körülvágásra, átméretezésre és más alapvető műveletekre. Csak ne várj tőle Photoshop-alternatívát. De azért van benne Magic Wand és rétegek is!

A Pintát az alkalmazásindítón keresztül indítod (`Super + Space`).

## Aether

Az [Aether](https://github.com/bjarneo/aether) egy témázó alkalmazás, amely ki tudja nyerni a színeket egy háttérképből, és teljes, egységes témát tud belőlük készíteni. Ez a legegyszerűbb módja annak, hogy [elkészítsd a saját témádat](43-making-your-own-theme.md).

Az Aethert az alkalmazásindítón keresztül indítod (`Super + Space`).

## LocalSend

A [LocalSend](https://localsend.org/) segítségével fájlokat küldhetsz más, ugyanazon a hálózaton lévő, az alkalmazást futtató eszközökre, akárcsak az Apple AirDropjával. Viszont platformfüggetlen, így Windowsra, macOS-re, Androidra, iOS-re és persze Linuxra is küldhetsz fájlokat, és onnan is fogadhatsz.

A Share menüt a `Super + Ctrl + S` billentyűkombinációval vagy az Omarchy menüben a _Trigger > Share_ alatt nyithatod meg. Négy lehetőséget kínál:

- **Clipboard** szöveges fájlként küldi el, bármit is másoltál. Remek arra, hogy egy linket vagy egy részletet átjuttass a telefonodra anélkül, hogy e-mailt küldenél magadnak.
- **File** egy fájlválasztót nyit meg, amelyben egyszerre többet is kiválaszthatsz.
- **Folder** egy teljes könyvtárat küld el.
- **Receive** magát a LocalSendet nyitja meg, hogy egy másik eszköz küldhessen neked valamit.

Ugyanez működik a terminálból is az `omarchy share clipboard`, az `omarchy share file [path]` és az `omarchy share folder [path]` parancsokkal. Hagyd le az elérési utat, és megkapod a választót.

Közvetlenül a fájlkezelőből is küldhetsz: kattints jobb gombbal bármilyen kijelölésre a Nautilusban, és válaszd a _Send via LocalSend_ lehetőséget.

Az Omarchy tűzfala alapértelmezés szerint zárva van, a LocalSend portját kivéve, így ez egy friss telepítésen azonnal működik. Lásd: [biztonság](48-security.md).

## LibreOffice

A [LibreOffice](https://www.libreoffice.org/) egy teljes irodai csomag szövegszerkesztővel, táblázatkezelővel, prezentációkkal, rajzolóalkalmazással és még sok mással. Kompatibilis a Microsoft Office fájljaival, így remekül használható azoknak a Word-dokumentumoknak a megnyitására.

A LibreOffice-t az alkalmazásindítón keresztül indítod (`Super + Space`).

## Hype

A [Hype](https://github.com/omacom/hype) az Omarchy saját, pofonegyszerű prezentációs alkalmazása. A prezentációd egyetlen Markdown-fájl, mellette a képeivel és videóival: minden diát egy élő előnézet alatt írhatsz meg, húzással sorrendbe rendezheted a diákat, majd teljes képernyőn vetíthetsz, vagy PDF-be és PowerPointba exportálhatsz. Még az Omarchy-témádat is átveszi.

A Hype-ot az alkalmazásindítón keresztül indítod (`Super + Space`). Nyomd meg benne a `?` billentyűt az összes gyorsbillentyű megtekintéséhez.

## Signed

A [Signed](https://github.com/omacom/signed) az Omarchy saját, pofonegyszerű megoldása PDF-ek aláírására és kitöltésére. Helyezd el a mentett aláírásodat, szöveget és a mai dátumot bárhová egy oldalon, majd ments egy aláírt másolatot az eredeti mellé. A hogyanról lásd: [PDF-ek kitöltése](27-filling-out-pdfs.md).

A Signedet az alkalmazásindítón keresztül indítod (`Super + Space`), vagy megnyithatsz vele egy PDF-et a fájlkezelőből.

## Checkmate

A [Checkmate](https://github.com/omacom/checkmate) az Omarchy saját 3D-s sakkjátéka. Játssz egy barátoddal ugyanazon a számítógépen, vagy a beépített ellenfél ellen három szinten, négy faragott készleten, amelyek mindegyike a maga módján mozog: keringő űreszközök, faragott fa és elefántcsont, erdei lények és cukorkák. A játszmáknak nincs órájuk, és minden lépés után mentődnek.

A Checkmate-et az alkalmazásindítón keresztül indítod (`Super + Space`). Nyomd meg benne a `?` billentyűt az összes gyorsbillentyű megtekintéséhez.

## Omacalc

Az [Omacalc](https://github.com/omacom-io/omacalc) az Omarchy saját, pofonegyszerű számológépe, amely lebegő ablakban nyílik meg.

Az Omacalcot a `Super + Shift + Q` billentyűkombinációval indítod (vagy a számológép billentyűvel, ha van olyan a billentyűzeteden).

## Signal

A [Signal](https://signal.org/) az E2E titkosított üzenetküldés úttörője, és remek kommunikációs lehetőség mindenkinek, aki inkább nem valamelyik nagy technológiai konglomerátumon keresztül szeretne kommunikálni.

A Signalt a `Super + Shift + G` billentyűkombinációval indítod. Nem része az alaptelepítésnek, ezért amikor először megnyomod ezt, az Omarchy felajánlja, hogy telepíti neked (az Omarchy menüben az _Install > Service_ alatt is megtalálható).

## Omaview

Az [Omaview](https://github.com/omacom/omaview) az Omarchy saját, pofonegyszerű képnézegetője és médialejátszója: egyetlen ablak a fotóidhoz, videóidhoz és zenéidhez. Nyiss meg egy fotót, és a nyílbillentyűk végigléptetnek a mappája többi elemén, az `N` és a `P` ugyanezt teszi bármivel, a `Ctrl + M` pedig az egész mappát rácsként mutatja. HEIC, AVIF és JPEG XL fotókat is megjelenít, és minden hosszabb tartalmat onnan folytat, ahol abbahagytad.

Nyomd meg az `F` billentyűt a teljes képernyőhöz, az `E` billentyűt egy kép szerkesztéséhez az Omasnapban vagy egy videó megvágásához az Omacutban, a `Ctrl + P` billentyűkombinációt egy kép nyomtatásához, a `Delete` billentyűt pedig egy fájl Kukába helyezéséhez (a `Ctrl + Z` visszahozza). Nyomd meg benne a `?` billentyűt az összes gyorsbillentyű megtekintéséhez.

Az Omaview-t _Media Viewer_ néven indítod az alkalmazásindítón keresztül (`Super + Space`), vagy egyszerűen kattints duplán egy képre, videóra vagy dalra a fájlkezelőben.

## Omacut

Az [Omacut](https://github.com/omacom-io/omacut) az Omarchy saját, pofonegyszerű videóvágója. Amikor csak egy klip elejét és végét kell levágnod, sokkal jobb, mint elindítani egy teljes videószerkesztőt.

Az Omacutot az alkalmazásindítón keresztül indítod (`Super + Space`).

## Monologue

A [Monologue](https://github.com/omacom/monologue) az Omarchy saját, pofonegyszerű webkamerás felvevője. Válaszd ki egyszer a kamerádat és a mikrofonodat, majd nyomd meg a `Space` billentyűt a felvételhez, és újra ugyanannak a felvételnek a szüneteltetéséhez és folytatásához. Mindig a kamerád legmagasabb felbontásában rögzít, élő mikrofonjelszint-mérővel, hogy indulás előtt ellenőrizhesd a szinteket.

Állítsd le a felvételt, és azonnal megnyílik egy beépített szerkesztőben. Kattints duplán egy klipre a kettévágásához, húzd a fogantyúkat az egyes darabok megvágásához, és távolítsd el azokat a részeket, amelyeket nem akarsz. Ezután mentsd el MP4-ként. Az eredeti felvételed megmarad, amíg el nem veted, így mindig visszatérhetsz, és másképp vághatod meg.

A Monologue-ot az alkalmazásindítón keresztül indítod (`Super + Space`).
