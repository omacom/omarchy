# GUIs

## Fájlok

A Files (Nautilus) a grafikus fájlkezelő. A `Super + Shift + F` nyitja meg, a `Super + Shift + Alt + F` pedig abban a mappában nyitja meg, ahol a terminálod éppen áll, ami rengeteg kattintást megspórol. A `Ctrl + L` lehetővé teszi, hogy beírj egy útvonalat, és ha bármelyik fájlon lenyomod a `Space` billentyűt, gyors előnézetet kapsz anélkül, hogy bármit megnyitnál.

Csatlakoztass egy USB-meghajtót vagy egy SD-kártyát, és automatikusan felcsatolódik, így egyszerűen megjelenik az oldalsávban. Bármi komolyabbhoz — meghajtó formázásához, SMART-állapot ellenőrzéséhez, partíciók létrehozásához — indítsd el a _Disks_ alkalmazást az alkalmazásindítóból (`Super + Space`).

A dupla kattintás ésszerű alapértelmezéseket követ: a képek, videók és zenék az Omaview alkalmazásban nyílnak meg, a PDF-ek a Document Viewer alkalmazásban, a Markdown az Omawrite alkalmazásban, az egyszerű szöveg pedig a _Setup > Default > Editor_ alatt kiválasztott szerkesztőben.

## Disktree

Amikor megtelik a meghajtó, és fogalmad sincs, mi zabálja fel, indítsd el a [Disktree](https://github.com/tobi/disktree) alkalmazást az alkalmazásindítóból (`Super + Space`). Grafikus treemap formájában mutatja a saját mappádat. A nagyobb blokkok több helyet foglalnak; billentyűzettel vagy egérrel lépkedhetsz be a mappákba, kijelölheted, minek kell mennie, és átnézheted a kijelöléseidet, mielőtt bármit eltávolítanál. Futtasd a `disktree --disk` parancsot az egész lemez átvizsgálásához.

## Obsidian

Az [Obsidian](https://obsidian.md/) egy ingyenes és rendkívül bővíthető jegyzetelő alkalmazás, amely egyszerű Markdown-fájlokat használ tárolásra.

Az Obsidian minden célra ingyenes, beleértve a személyes, kereskedelmi és nonprofit használatot is.

Az Obsidian [kereskedelmi kiegészítőt is kínál a szinkronizáláshoz](https://obsidian.md/sync) iOS és Android mobilalkalmazásokkal. (https://obsidian.md/pricing).

Az Obsidiant a `Super + Shift + O` billentyűkombinációval indítod. A téma-szinkronizálás használatához a beállításokban ki kell választanod az `Omarchy` témát.

## Omawrite

Az [Omawrite](https://github.com/omacom-io/omawrite) az Omarchy saját, pofonegyszerű Markdown-író alkalmazása. Nincsenek vaultok, nincsenek bővítmények, csak te és a szavak.

Az Omawrite-ot a `Super + Shift + W` billentyűkombinációval indítod.

## Pinta

A [Pinta](https://www.pinta-project.com/) egy alapvető képszerkesztő eszköz, amely kiváló vágáshoz, átméretezéshez és más alapvető műveletekhez. Csak ne várj tőle Photoshop-alternatívát. De még Magic Wand és rétegek is vannak benne!

A Pintát az alkalmazásindítón keresztül indítod (`Super + Space`).

## Aether

Az [Aether](https://github.com/bjarneo/aether) egy témázó alkalmazás, amely képes színeket kinyerni egy háttérképből, és teljes, egységes témává alakítani őket. Ez a legegyszerűbb módja annak, hogy [elkészítsd a saját témádat](43-making-your-own-theme.md).

Az Aethert az alkalmazásindítón keresztül indítod (`Super + Space`).

## LocalSend

A [LocalSend](https://localsend.org/) segítségével fájlokat küldhetsz ugyanazon a hálózaton lévő, az alkalmazást futtató más eszközökre, akárcsak az Apple AirDropjával. Viszont platformfüggetlen, így Windows, macOS, Android, iOS és persze Linux között is küldhetsz fájlokat oda-vissza.

A Megosztás menüt a `Super + Ctrl + S` billentyűkombinációval vagy az Omarchy menüben a _Trigger > Share_ alatt nyithatod meg. Négy lehetőséget kínál:

- **Clipboard** szöveges fájlként elküldi, bármit is másoltál. Kiváló arra, hogy egy linket vagy egy kódrészletet átjuttass a telefonodra anélkül, hogy e-mailt küldenél magadnak.
- **File** megnyit egy fájlválasztót, ahol egyszerre többet is kiválaszthatsz.
- **Folder** egy teljes mappát küld el.
- **Receive** megnyitja magát a LocalSendet, hogy egy másik eszköz küldhessen neked valamit.

Ugyanez működik a terminálból is a `omarchy share clipboard`, a `omarchy share file [path]` és a `omarchy share folder [path]` parancsokkal. Hagyd le az útvonalat, és megkapod a választót.

Közvetlenül a fájlkezelőből is küldhetsz: kattints jobb gombbal bármelyik kijelölésre a Nautilusban, és válaszd a _Send via LocalSend_ lehetőséget.

Az Omarchy tűzfala alapértelmezés szerint zárva van, kivéve a LocalSend portját, így ez egy friss telepítésen azonnal működik. Lásd: [biztonság](48-security.md).

## LibreOffice

A [LibreOffice](https://www.libreoffice.org/) egy teljes irodai csomag szövegszerkesztővel, táblázatkezelővel, prezentációkkal, rajzolóalkalmazással és még sok mással. Kompatibilis a Microsoft Office fájljaival, így ez egy nagyszerű módja annak, hogy megnyithasd azokat a Word-dokumentumokat.

A LibreOffice-t az alkalmazásindítón keresztül indítod (`Super + Space`).

## Hype

A [Hype](https://github.com/omacom/hype) az Omarchy saját, pofonegyszerű prezentációs alkalmazása. A prezentációd egyetlen Markdown-fájl, mellette a képeivel és videóival: minden diát élő előnézet alatt írhatsz meg, húzással sorrendbe rendezheted a diákat, majd teljes képernyőn prezentálhatsz, vagy exportálhatsz PDF-be és PowerPointba. Még az Omarchy témádat is átveszi.

A Hype-ot az alkalmazásindítón keresztül indítod (`Super + Space`). Nyomd meg benne a `?` billentyűt az összes gyorsbillentyű megtekintéséhez.

## Signed

A [Signed](https://github.com/omacom/signed) az Omarchy saját, pofonegyszerű módja PDF-ek aláírására és kitöltésére. Helyezd el a mentett aláírásodat, szöveget és a mai dátumot bárhová egy oldalon, majd ments egy aláírt példányt az eredeti mellé. Lásd: [PDF-ek kitöltése](27-filling-out-pdfs.md) a tudnivalókért.

A Signedet az alkalmazásindítón keresztül indítod (`Super + Space`), vagy megnyithatsz vele egy PDF-et a fájlkezelőből.

## Omacalc

Az [Omacalc](https://github.com/omacom-io/omacalc) az Omarchy saját, pofonegyszerű számológépe, amely lebegő ablakban nyílik meg.

Az Omacalcot a `Super + Shift + Q` billentyűkombinációval indítod (vagy a számológép billentyűvel, ha a billentyűzeteden van ilyen).

## Signal

A [Signal](https://signal.org/) az E2E titkosított üzenetküldés úttörője, és nagyszerű kommunikációs lehetőség mindenkinek, aki inkább nem valamelyik nagy technológiai konglomerátumon keresztül szeretne kommunikálni.

A Signalt a `Super + Shift + G` billentyűkombinációval indítod. Nem része az alaptelepítésnek, így amikor először megnyomod ezt, az Omarchy felajánlja, hogy telepíti neked (megtalálod az Omarchy menüben az _Install > Service_ alatt is).

## Omaview

Az [Omaview](https://github.com/omacom/omaview) az Omarchy saját, pofonegyszerű képnézegetője és médialejátszója: egyetlen ablak a fényképeidnek, videóidnak és zenéidnek. Nyiss meg egy fényképet, és a nyílbillentyűk végiglépkednek a mappa többi részén, az `N` és a `P` ugyanezt teszi bármivel, a `Ctrl + M` pedig az egész mappát rácsként mutatja. HEIC, AVIF és JPEG XL fényképeket is megjelenít, és folytatja ott, ahol abbahagytad bármi hosszabb dologban.

Nyomd meg az `F` billentyűt a teljes képernyőhöz, az `E` billentyűt egy kép szerkesztéséhez az Omasnapban vagy egy videó vágásához az Omacutban, a `Ctrl + P` billentyűkombinációt egy kép nyomtatásához, a `Delete` billentyűt pedig egy fájl Kukába helyezéséhez (a `Ctrl + Z` visszahozza). Nyomd meg benne a `?` billentyűt az összes gyorsbillentyű megtekintéséhez.

Az Omaview-t _Media Viewer_ néven indítod az alkalmazásindítón keresztül (`Super + Space`), vagy egyszerűen duplán kattints egy képre, videóra vagy dalra a fájlkezelőben.

## Omacut

Az [Omacut](https://github.com/omacom-io/omacut) az Omarchy saját, pofonegyszerű videóvágója. Amikor csak annyira van szükséged, hogy levágd egy klip elejét és végét, jobb, mint beindítani egy teljes videószerkesztőt.

Az Omacutot az alkalmazásindítón keresztül indítod (`Super + Space`).

## Monologue

A [Monologue](https://github.com/omacom/monologue) az Omarchy saját, pofonegyszerű webkamerás felvevője. Válaszd ki egyszer a kamerádat és a mikrofonodat, majd nyomd meg a `Space` billentyűt a felvételhez, és újra a szüneteltetéshez és ugyanazon felvétel folytatásához. Mindig a kamerád legmagasabb felbontásában rögzít, élő mikrofonszint-jelzővel, hogy indulás előtt ellenőrizhesd a szinteket.

Állítsd le a felvételt, és azonnal megnyílik egy beépített szerkesztőben. Kattints duplán egy klipre a felosztásához, húzd a fogantyúkat az egyes részek vágásához, és távolítsd el azokat a részeket, amelyeket nem akarsz. Ezután mentsd el MP4-ként. Az eredeti felvételed megmarad, amíg el nem veted, így bármikor visszatérhetsz, és másképp vághatod meg.

A Monologue-ot az alkalmazásindítón keresztül indítod (`Super + Space`).
