# GUI-k

## Fájlok

A Files (Nautilus) a grafikus fájlkezelő. A `Super + Shift + F` nyitja meg, a `Super + Shift + Alt + F` pedig abban a könyvtárban nyitja meg, amelyben a terminálod éppen áll, ami rengeteg kattintást megspórol. A `Ctrl + L` segítségével beírhatsz egy elérési utat, és ha bármelyik fájlon lenyomod a `Space` billentyűt, gyors előnézetet kapsz anélkül, hogy bármit megnyitnál.

Csatlakoztass egy USB-meghajtót vagy egy SD-kártyát, és automatikusan csatolódik, így egyszerűen megjelenik az oldalsávban. Bármi komolyabbhoz — meghajtó formázása, SMART-állapot ellenőrzése, partíciók létrehozása — indítsd el a _Disks_ alkalmazást az alkalmazásindítóból (`Super + Space`).

A dupla kattintás ésszerű alapértelmezéseket követ: a képek, videók és zenék az Omaview-ban nyílnak meg, a PDF-ek a Document Viewerben, a Markdown az Omawrite-ban, az egyszerű szöveg pedig a _Setup > Default > Editor_ alatt kiválasztott szerkesztőben.

## Disktree

Amikor megtelik a meghajtó, és fogalmad sincs, mi zabálja fel, indítsd el a [Disktree](https://github.com/tobi/disktree) alkalmazást az alkalmazásindítóból (`Super + Space`). Grafikus treemap formájában mutatja meg a saját könyvtáradat. A nagyobb blokkok több helyet foglalnak; billentyűzettel vagy egérrel lépkedhetsz be a könyvtárakba, megjelölheted, minek kell mennie, és átnézheted a kiválasztásaidat, mielőtt bármit eltávolítanál. Futtasd a `disktree --disk` parancsot az egész lemez átvizsgálásához.

## Obsidian

Az [Obsidian](https://obsidian.md/) egy ingyenes és rendkívül bővíthető jegyzetelő alkalmazás, amely egyszerű Markdown-fájlokat használ tárolásra.

Az Obsidian minden célra ingyenes, beleértve a személyes, kereskedelmi és nonprofit használatot is.

Az Obsidian [kereskedelmi kiegészítőt is kínál szinkronizáláshoz](https://obsidian.md/sync) iOS-es és Androidos mobilalkalmazásokkal. (https://obsidian.md/pricing).

Az Obsidiant a `Super + Shift + O` billentyűkombinációval indítod. A téma-szinkronizálás használatához a beállításokban ki kell választanod az `Omarchy` témát.

## Omawrite

Az [Omawrite](https://github.com/omacom-io/omawrite) az Omarchy saját, pofonegyszerű Markdown-író alkalmazása. Nincsenek trezorok, nincsenek bővítmények, csak te és a szavak.

Az Omawrite-ot a `Super + Shift + W` billentyűkombinációval indítod.

## Pinta

A [Pinta](https://www.pinta-project.com/) egy egyszerű képszerkesztő eszköz, amely kiváló vágáshoz, átméretezéshez és más alapvető műveletekhez. Csak ne várj tőle Photoshop-alternatívát. De még így is van benne Magic Wand és rétegek!

A Pintát az alkalmazásindítón keresztül indítod (`Super + Space`).

## Aether

Az [Aether](https://github.com/bjarneo/aether) egy témázó alkalmazás, amely ki tudja nyerni a színeket egy háttérképből, és teljes, összefüggő témává tudja alakítani őket. Ez a legegyszerűbb módja annak, hogy [elkészítsd a saját témádat](43-making-your-own-theme.md).

Az Aethert az alkalmazásindítón keresztül indítod (`Super + Space`).

## LocalSend

A [LocalSend](https://localsend.org/) lehetővé teszi, hogy fájlokat küldj ugyanazon a hálózaton lévő, az alkalmazást futtató más eszközökre, mint az Apple AirDropja. Viszont platformfüggetlen, így Windowsra, macOS-re, Androidra, iOS-re és persze Linuxra is küldhetsz fájlokat, és onnan is fogadhatsz.

A Share menüt a `Super + Ctrl + S` billentyűkombinációval vagy az Omarchy menüben a _Trigger > Share_ alatt nyithatod meg. Négy lehetőséget kínál:

- A **Clipboard** szövegfájlként küldi el, bármit is másoltál. Nagyszerű arra, hogy egy linket vagy kódrészletet a telefonodra juttass anélkül, hogy e-mailt küldenél magadnak.
- A **File** egy fájlválasztót nyit meg, ahol egyszerre többet is kiválaszthatsz.
- A **Folder** egy teljes könyvtárat küld el.
- A **Receive** magát a LocalSendet nyitja meg, hogy egy másik eszköz küldhessen neked valamit.

Ugyanez működik terminálból is a `omarchy share clipboard`, a `omarchy share file [path]` és az `omarchy share folder [path]` parancsokkal. Hagyd le az elérési utat, és megkapod a választót.

Közvetlenül a fájlkezelőből is küldhetsz: kattints jobb gombbal bármilyen kiválasztásra a Nautilusban, és válaszd a _Send via LocalSend_ lehetőséget.

Az Omarchy tűzfala alapértelmezetten zárva van a LocalSend portjának kivételével, így ez egy friss telepítésen azonnal működik. Lásd: [biztonság](48-security.md).

## LibreOffice

A [LibreOffice](https://www.libreoffice.org/) egy teljes irodai csomag szövegszerkesztővel, táblázatkezelővel, prezentációkkal, rajzolóalkalmazással és még sok mással. Kompatibilis a Microsoft Office fájljaival, így ez egy nagyszerű módja annak, hogy meg tudd nyitni azokat a Word-dokumentumokat.

A LibreOffice-t az alkalmazásindítón keresztül indítod (`Super + Space`).

## Hype

A [Hype](https://github.com/omacom/hype) az Omarchy saját, pofonegyszerű prezentációs alkalmazása. A diasorod egyetlen Markdown-fájl, mellette a képeivel és videóival: minden diát élő előnézet alatt írsz, húzással rendezed sorba a diákat, majd teljes képernyőn prezentálsz, vagy PDF-be és PowerPointba exportálsz. Még az Omarchy-témádat is átveszi.

A Hype-ot az alkalmazásindítón keresztül indítod (`Super + Space`). Nyomd meg a `?` billentyűt benne az összes gyorsbillentyű megtekintéséhez.

## Signed

A [Signed](https://github.com/omacom/signed) az Omarchy saját, pofonegyszerű módja PDF-ek aláírására és kitöltésére. Helyezd el a mentett aláírásodat, szöveget és a mai dátumot bárhová egy oldalon, majd ments egy aláírt másolatot az eredeti mellé. Lásd: [PDF-ek kitöltése](27-filling-out-pdfs.md) a módjáról.

A Signedet az alkalmazásindítón keresztül indítod (`Super + Space`), vagy nyiss meg vele egy PDF-et a fájlkezelőből.

## Checkmate

A [Checkmate](https://github.com/omacom/checkmate) az Omarchy saját 3D-s sakkjátéka. Játssz egy barátoddal ugyanazon a számítógépen vagy a beépített ellenfél ellen három szinten, négy faragott készlettel, amelyek mindegyike a maga módján mozog: űreszközök, faragott fa és elefántcsont, erdei lények és édesség. A játékokban nincs óra, és minden lépés után mentenek.

A Checkmate-et az alkalmazásindítón keresztül indítod (`Super + Space`), ahol Chess néven szerepel. Nyomd meg a `?` billentyűt benne az összes gyorsbillentyű megtekintéséhez.

## Cards

A [Cards](https://github.com/omacom/cards) az Omarchy saját Klondike pasziánsza. Hármasával húzol, korlátlan számú végigjátszással, négy kártyasorozatban: az egyik a témád színeivel készült, három pedig saját megjelenéssel rendelkezik. Kattints egy kártyára, majd oda, ahová megy, húzd át, vagy kattints rá duplán, hogy a legjobb helyre kerüljön. A játékok minden lépés után mentenek.

A Cardsot az alkalmazásindítón keresztül indítod (`Super + Space`). Kattints a nevére, vagy nyomd meg a `?` billentyűt az összes gyorsbillentyű megtekintéséhez.

## Omacalc

Az [Omacalc](https://github.com/omacom-io/omacalc) az Omarchy saját, pofonegyszerű számológépe, amely lebegő ablakban nyílik meg.

Az Omacalcot a `Super + Shift + Q` billentyűkombinációval indítod (vagy a számológép billentyűvel, ha a billentyűzeteden van ilyen).

## Signal

A [Signal](https://signal.org/) az E2E titkosítású üzenetküldés úttörője, és nagyszerű kommunikációs lehetőség mindenkinek, aki inkább nem valamelyik nagy technológiai konglomerátumon keresztül intézné.

A Signalt a `Super + Shift + G` billentyűkombinációval indítod. Nem része az alaptelepítésnek, így amikor először megnyomod ezt, az Omarchy felajánlja, hogy telepíti neked (az Omarchy menüben az _Install > Service_ alatt is megtalálod).

## Omaview

Az [Omaview](https://github.com/omacom/omaview) az Omarchy saját, pofonegyszerű képmegjelenítője és médialejátszója: egy ablak a fényképeidhez, videóidhoz és zenéidhez. Nyiss meg egy fényképet, és a nyílbillentyűk végigléptetnek a mappája többi részén, az `N` és a `P` ugyanezt teszi bármivel, a `Ctrl + M` pedig az egész mappát rácsként mutatja. HEIC, AVIF és JPEG XL fényképeket is megjelenít, és folytatja ott, ahol abbahagytad bármi hosszabb dologban.

Nyomd meg az `F` billentyűt a teljes képernyőhöz, az `E` billentyűt egy kép szerkesztéséhez az Omasnapban vagy egy videó vágásához az Omacutban, a `Ctrl + P` billentyűkombinációt egy kép nyomtatásához, és a `Delete` billentyűt egy fájl Kukába mozgatásához (a `Ctrl + Z` visszahozza). Nyomd meg a `?` billentyűt benne az összes gyorsbillentyű megtekintéséhez.

Az Omaview-t _Media Viewer_ néven indítod az alkalmazásindítón keresztül (`Super + Space`), vagy egyszerűen kattints duplán egy képre, videóra vagy dalra a fájlkezelőben.

## Omacut

Az [Omacut](https://github.com/omacom-io/omacut) az Omarchy saját, pofonegyszerű videóvágója. Amikor csak egy klip elejét és végét kell levágnod, ez veri egy teljes videószerkesztő elindítását.

Az Omacutot az alkalmazásindítón keresztül indítod (`Super + Space`).

## Monologue

A [Monologue](https://github.com/omacom/monologue) az Omarchy saját, pofonegyszerű webkamerás felvevője. Válaszd ki egyszer a kamerádat és a mikrofonodat, majd nyomd meg a `Space` billentyűt a felvételhez, és ismét a szüneteltetéshez és ugyanazon felvétel folytatásához. Mindig a kamerád legnagyobb felbontásában rögzít, élő mikrofonmérővel, így kezdés előtt ellenőrizheted a szinteket.

Állítsd le a felvételt, és azonnal megnyílik egy beépített szerkesztőben. Kattints duplán egy klipre a felosztásához, húzd a fogantyúkat az egyes darabok vágásához, és távolítsd el azokat a részeket, amelyeket nem akarsz. Ezután mentsd el MP4-ként. Az eredeti felvételed megmarad, amíg el nem veted, így bármikor visszatérhetsz, és másképp vághatod meg.

A Monologue-ot az alkalmazásindítón keresztül indítod (`Super + Space`).
