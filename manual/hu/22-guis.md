# GUI-k

## Files

A Files (Nautilus) a grafikus fájlkezelő. A `Super + Shift + F` nyitja meg, a `Super + Shift + Alt + F` pedig abban a mappában nyitja meg, ahol a terminálod éppen áll, ami rengeteg kattintgatást megspórol. A `Ctrl + L` lenyomásával beírhatsz egy elérési utat, ha pedig bármelyik fájlon lenyomod a `Space` billentyűt, gyors előnézetet kapsz anélkül, hogy bármit is megnyitnál.

Csatlakoztass egy USB-meghajtót vagy egy SD-kártyát, és az automatikusan csatolódik, így egyszerűen megjelenik az oldalsávban. Minden komolyabb feladathoz — meghajtó formázása, SMART állapot ellenőrzése, partíciók létrehozása — indítsd el a _Disks_ alkalmazást az alkalmazásindítóból (`Super + Space`).

A dupla kattintás ésszerű alapértelmezéseket követ: a képek, videók és zenék az Omaview alkalmazásban nyílnak meg, a PDF-ek a Document Viewer alkalmazásban, a Markdown az Omawrite alkalmazásban, az egyszerű szöveg pedig a _Setup > Default > Editor_ alatt kiválasztott szerkesztőben.

## Disktree

Amikor megtelik a meghajtó, és fogalmad sincs, mi zabálja fel a helyet, indítsd el a [Disktree](https://github.com/tobi/disktree) alkalmazást az alkalmazásindítóból (`Super + Space`). Grafikus fátérképen jeleníti meg a saját mappádat. A nagyobb blokkok több helyet foglalnak; billentyűzettel vagy egérrel lépkedhetsz be a mappákba, megjelölheted, minek kell mennie, és áttekintheted a kijelöléseidet, mielőtt bármit is eltávolítanál. A `disktree --disk` parancs futtatásával az egész lemezt átvizsgálhatod.

## Obsidian

Az [Obsidian](https://obsidian.md/) egy ingyenes és rendkívül bővíthető jegyzetelő alkalmazás, amely egyszerű Markdown-fájlokat használ tárolásra.

Az Obsidian minden célra ingyenes, beleértve a személyes, a kereskedelmi és a nonprofit felhasználást is.

Az Obsidian egy [kereskedelmi kiegészítőt is kínál a szinkronizáláshoz](https://obsidian.md/sync) az iOS-es és androidos mobilalkalmazásokkal. (https://obsidian.md/pricing).

Az Obsidiant a `Super + Shift + O` billentyűkombinációval indíthatod el. A témaszinkronizálás használatához a beállításokban ki kell választanod az `Omarchy` témát.

## Omawrite

Az [Omawrite](https://github.com/omacom-io/omawrite) az Omarchy saját, pofonegyszerű Markdown-íróalkalmazása. Nincsenek trezorok, nincsenek bővítmények, csak te és a szavak.

Az Omawrite-ot a `Super + Shift + W` billentyűkombinációval indíthatod el.

## Pinta

A [Pinta](https://www.pinta-project.com/) egy egyszerű képszerkesztő eszköz, amely remekül alkalmas vágásra, átméretezésre és egyéb alapvető műveletekre. Csak ne várj tőle Photoshop-alternatívát. De még így is van benne Magic Wand és rétegek!

A Pintát az alkalmazásindítóval (`Super + Space`) indíthatod el.

## Aether

Az [Aether](https://github.com/bjarneo/aether) egy témakészítő alkalmazás, amely képes színeket kinyerni egy háttérképből, és azokból teljes, egységes témát készíteni. Ez a legegyszerűbb módja annak, hogy [elkészítsd a saját témádat](43-making-your-own-theme.md).

Az Aethert az alkalmazásindítóval (`Super + Space`) indíthatod el.

## LocalSend

A [LocalSend](https://localsend.org/) lehetővé teszi, hogy fájlokat küldj az ugyanazon a hálózaton lévő, az alkalmazást futtató más eszközökre, hasonlóan az Apple AirDropjához. Ráadásul többplatformos, így küldhetsz és fogadhatsz fájlokat Windows, macOS, Android, iOS és természetesen Linux között is.

A Share menüt a `Super + Ctrl + S` billentyűkombinációval vagy az Omarchy menüben a _Trigger > Share_ alatt nyithatod meg. Négy lehetőséget kínál:

- **Clipboard** szövegfájlként küldi el azt, amit kimásoltál. Remek arra, hogy egy hivatkozást vagy egy részletet átjuttass a telefonodra anélkül, hogy e-mailt küldenél magadnak.
- **File** egy fájlválasztót nyit meg, ahol egyszerre többet is kiválaszthatsz.
- **Folder** egy teljes mappát küld el.
- **Receive** magát a LocalSendet nyitja meg, hogy egy másik eszköz küldhessen neked valamit.

Ugyanez működik a terminálból is az `omarchy share clipboard`, az `omarchy share file [path]` és az `omarchy share folder [path]` paranccsal. Hagyd le az elérési utat, és megkapod a választót.

Közvetlenül a fájlkezelőből is küldhetsz: kattints jobb gombbal bármilyen kijelölésre a Nautilusban, és válaszd a _Send via LocalSend_ lehetőséget.

Az Omarchy tűzfala alapból zárva van, a LocalSend portját kivéve, így ez egy friss telepítésen azonnal működik. Lásd: [biztonság](48-security.md).

## LibreOffice

A [LibreOffice](https://www.libreoffice.org/) egy teljes irodai csomag szövegszerkesztővel, táblázatkezelővel, prezentációkészítővel, rajzolóalkalmazással és még sok mással. Kompatibilis a Microsoft Office fájljaival, így remek módja annak, hogy meg tudd nyitni azokat a Word-dokumentumokat.

A LibreOffice-t az alkalmazásindítóval (`Super + Space`) indíthatod el.

## Hype

A [Hype](https://github.com/omacom/hype) az Omarchy saját, pofonegyszerű prezentációs alkalmazása. A prezentációd egyetlen Markdown-fájl, mellette a képeivel és videóival: minden diát élő előnézet alatt írhatsz meg, húzással sorrendbe rendezheted a diákat, majd teljes képernyőn vetíthetsz, vagy exportálhatsz PDF-be és PowerPointba. Még az Omarchy-témádat is átveszi.

A Hype-ot az alkalmazásindítóval (`Super + Space`) indíthatod el. Nyomd meg benne a `?` billentyűt az összes billentyűparancs megtekintéséhez.

## Signed

A [Signed](https://github.com/omacom/signed) az Omarchy saját, pofonegyszerű módja a PDF-ek aláírására és kitöltésére. Helyezd el a mentett aláírásodat, szöveget és a mai dátumot bárhová egy oldalon, majd ments egy aláírt másolatot az eredeti mellé. A módját lásd itt: [PDF-ek kitöltése](27-filling-out-pdfs.md).

A Signedet az alkalmazásindítóval (`Super + Space`) indíthatod el, vagy megnyithatsz vele egy PDF-et a fájlkezelőből.

## Checkmate

A [Checkmate](https://github.com/omacom/checkmate) az Omarchy saját 3D-s sakkjátéka. Játssz egy barátoddal ugyanazon a számítógépen, vagy a beépített ellenfél ellen három nehézségi szinten, négy megfaragott készlettel, amelyek mindegyike a maga módján mozog: orbitális járművek, faragott fa és elefántcsont, erdei lények és cukorkák. A játszmáknak nincs órájuk, és minden lépés után mentődnek.

A Checkmate-et az alkalmazásindítóval (`Super + Space`) indíthatod el, ahol Chess néven szerepel. Nyomd meg benne a `?` billentyűt az összes billentyűparancs megtekintéséhez.

## Omacalc

Az [Omacalc](https://github.com/omacom-io/omacalc) az Omarchy saját, pofonegyszerű számológépe, amely lebegő ablakban nyílik meg.

Az Omacalcot a `Super + Shift + Q` billentyűkombinációval indíthatod el (vagy a számológép billentyűvel, ha a billentyűzeteden van ilyen).

## Signal

A [Signal](https://signal.org/) az E2E-titkosított üzenetküldés úttörője, és remek kommunikációs lehetőség mindenkinek, aki inkább nem valamelyik nagy technológiai konglomerátumon keresztül szeretne kommunikálni.

A Signalt a `Super + Shift + G` billentyűkombinációval indíthatod el. Nem része az alaptelepítésnek, így amikor először nyomod meg ezt, az Omarchy felajánlja, hogy telepíti neked (megtalálható az Omarchy menüben az _Install > Service_ alatt is).

## Omaview

Az [Omaview](https://github.com/omacom/omaview) az Omarchy saját, pofonegyszerű képnézegetője és médialejátszója: egyetlen ablak a fotóidhoz, videóidhoz és zenéidhez. Nyiss meg egy fotót, és a nyílbillentyűk végiglépkednek a mappája többi elemén, az `N` és a `P` ugyanezt teszi bármivel, a `Ctrl + M` pedig az egész mappát rácsként jeleníti meg. Megjeleníti a HEIC, AVIF és JPEG XL fotókat is, és minden hosszabb tartalomban ott folytatja, ahol abbahagytad.

Nyomd meg az `F` billentyűt a teljes képernyőhöz, az `E` billentyűt egy kép szerkesztéséhez az Omasnapban vagy egy videó vágásához az Omacutban, a `Ctrl + P` billentyűkombinációt egy kép nyomtatásához, a `Delete` billentyűt pedig egy fájl Kukába helyezéséhez (a `Ctrl + Z` visszahozza). Nyomd meg benne a `?` billentyűt az összes billentyűparancs megtekintéséhez.

Az Omaview-t _Media Viewer_ néven indíthatod el az alkalmazásindítóval (`Super + Space`), vagy egyszerűen kattints duplán egy képre, videóra vagy dalra a fájlkezelőben.

## Omacut

Az [Omacut](https://github.com/omacom-io/omacut) az Omarchy saját, pofonegyszerű videóvágója. Amikor csak egy klip elejét és végét kell levágnod, sokkal jobb, mint elindítani egy teljes videószerkesztőt.

Az Omacutot az alkalmazásindítóval (`Super + Space`) indíthatod el.

## Monologue

A [Monologue](https://github.com/omacom/monologue) az Omarchy saját, pofonegyszerű webkamerás felvevője. Válaszd ki egyszer a kamerádat és a mikrofonodat, majd nyomd meg a `Space` billentyűt a felvételhez, és újra ugyanannak a felvételnek a szüneteltetéséhez és folytatásához. Mindig a kamerád legmagasabb felbontásán rögzít, élő mikrofonszintjelzővel, hogy kezdés előtt ellenőrizhesd a szinteket.

Állítsd le a felvételt, és azonnal megnyílik egy beépített szerkesztőben. Kattints duplán egy klipre a kettévágásához, húzd a fogantyúkat az egyes darabok vágásához, és távolítsd el azokat a részeket, amelyeket nem akarsz megtartani. Ezután mentsd el MP4-ként. Az eredeti felvételed megmarad, amíg el nem veted, így bármikor visszatérhetsz, és másképp vághatod meg.

A Monologue-ot az alkalmazásindítóval (`Super + Space`) indíthatod el.
