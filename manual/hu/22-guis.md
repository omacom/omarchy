# GUI-k

## Files

A Files (Folio) a grafikus fájlkezelő. A `Super + Shift + F` nyitja meg, a `Super + Shift + Alt + F` pedig abban a mappában nyitja meg, amelyben a terminálod éppen áll, ami rengeteg kattintást megspórol. A `Ctrl + L` billentyűkombinációval beírhatsz egy útvonalat, a `Space` megnyomása bármelyik fájlon pedig teljes méretben megmutatja az előnézetét anélkül, hogy megnyitnád.

Dugj be egy USB-meghajtót vagy egy SD-kártyát, és automatikusan csatolódik, így egyszerűen megjelenik az oldalsávban. Bonyolultabb dolgokhoz — meghajtó formázásához, SMART-állapot ellenőrzéséhez, partíciók létrehozásához — indítsd el a _Disks_ alkalmazást az alkalmazásindítóból (`Super + Space`).

A dupla kattintás értelmes alapértelmezéseket követ: a képek, videók és zenék az Omaview alkalmazásban nyílnak meg, a PDF-ek a Document Viewerben, a Markdown az Omawrite-ban, az egyszerű szöveg pedig a szerkesztődben, a Plainben, hacsak nem választasz másikat a _Setup > Defaults > Editor_ alatt.

## Disktree

Amikor megtelik a meghajtó, és fogalmad sincs, mi zabálja fel, indítsd el a [Disktree](https://github.com/tobi/disktree) alkalmazást az alkalmazásindítóból (`Super + Space`). Grafikus treemapként mutatja a saját mappádat. A nagyobb blokkok több helyet foglalnak; billentyűzettel vagy egérrel bejárhatod a mappákat, megjelölheted, minek kell mennie, és átnézheted a kijelöléseidet, mielőtt bármit törölnél. Az egész lemez átvizsgálásához futtasd a `disktree --disk` parancsot.

## Obsidian

Az [Obsidian](https://obsidian.md/) egy ingyenes és rendkívül bővíthető jegyzetelő alkalmazás, amely egyszerű Markdown-fájlokat használ tárolásra.

Az Obsidian minden célra ingyenes, beleértve a személyes, kereskedelmi és nonprofit használatot is.

Az Obsidian [kereskedelmi kiegészítőt is kínál szinkronizáláshoz](https://obsidian.md/sync) iOS-es és androidos mobilalkalmazásokkal. (https://obsidian.md/pricing).

Az Obsidiant a `Super + Shift + O` billentyűkombinációval indítod. A téma szinkronizálásához a beállításokban ki kell választanod az `Omarchy` témát.

## Omawrite

Az [Omawrite](https://github.com/omacom-io/omawrite) az Omarchy saját, pofonegyszerű Markdown-író alkalmazása. Nincsenek vaultok, nincsenek bővítmények, csak te és a szavak.

Az Omawrite-ot a `Super + Shift + W` billentyűkombinációval indítod.

## Pinta

A [Pinta](https://www.pinta-project.com/) egy egyszerű képszerkesztő eszköz, amely remek vágáshoz, átméretezéshez és más alapvető műveletekhez. Csak ne várj tőle Photoshop-alternatívát. De Magic Wand és rétegek azért vannak benne!

A Pintát az alkalmazásindítón keresztül indítod (`Super + Space`).

## Aether

Az [Aether](https://github.com/bjarneo/aether) egy témázó alkalmazás, amely képes színeket kinyerni egy háttérképből, és azokból teljes, egységes témát készíteni. Ez a legegyszerűbb módja annak, hogy [elkészítsd a saját témádat](43-making-your-own-theme.md).

Az Aethert az alkalmazásindítón keresztül indítod (`Super + Space`).

## LocalSend

A [LocalSend](https://localsend.org/) segítségével fájlokat küldhetsz más, ugyanazon a hálózaton lévő, az alkalmazást futtató eszközökre, hasonlóan az Apple AirDropjához. Viszont platformfüggetlen, így Windowsra, macOS-re, Androidra, iOS-re és persze Linuxra is küldhetsz fájlokat, és fogadhatsz is róluk.

A Megosztás menüt a `Super + Ctrl + S` billentyűkombinációval vagy az Omarchy menü _Trigger > Share_ pontjában nyithatod meg. Négy lehetőséget kínál:

- **Clipboard** azt küldi el szövegfájlként, amit kimásoltál. Remek arra, hogy egy linket vagy kódrészletet átjuttass a telefonodra anélkül, hogy e-mailt írnál magadnak.
- **File** megnyit egy fájlválasztót, ahol egyszerre többet is kiválaszthatsz.
- **Folder** egy teljes mappát küld el.
- **Receive** megnyitja magát a LocalSendet, hogy egy másik eszköz küldhessen neked valamit.

Ugyanez terminálból is működik a `omarchy share clipboard`, a `omarchy share file [path]` és a `omarchy share folder [path]` parancsokkal. Hagyd el az útvonalat, és megkapod a fájlválasztót.

Közvetlenül a fájlkezelőből is küldhetsz: kattints jobb gombbal bármilyen kijelölésre a Filesban, és oszd meg LocalSenddel.

Az Omarchy tűzfala alapból zárva van, kivéve a LocalSend portját, így ez egy friss telepítésen azonnal működik. Lásd: [biztonság](48-security.md).

## LibreOffice

A [LibreOffice](https://www.libreoffice.org/) egy teljes irodai csomag szövegszerkesztővel, táblázatkezelővel, prezentációkkal, rajzalkalmazással és még sok mással. Kompatibilis a Microsoft Office fájljaival, így remek módja annak, hogy meg tudd nyitni azokat a Word-dokumentumokat.

A LibreOffice-t az alkalmazásindítón keresztül indítod (`Super + Space`).

## Hype

A [Hype](https://github.com/omacom/hype) az Omarchy saját, pofonegyszerű prezentációs alkalmazása. A prezentációd egyetlen Markdown-fájl, mellette a képeivel és videóival: minden diát élő előnézet alatt írsz meg, a diákat sorrendbe húzod, majd teljes képernyőn prezentálsz, vagy PDF-be és PowerPointba exportálsz. Még az Omarchy-témádat is átveszi.

A Hype-ot az alkalmazásindítón keresztül indítod (`Super + Space`). Nyomd meg a `?` billentyűt benne az összes billentyűparancs megtekintéséhez.

## Signed

A [Signed](https://github.com/omacom/signed) az Omarchy saját, pofonegyszerű módja PDF-ek aláírására és kitöltésére. Helyezd el a mentett aláírásodat, szöveget és a mai dátumot bárhová egy oldalon, majd ments egy aláírt példányt az eredeti mellé. A módját lásd itt: [PDF-ek kitöltése](27-filling-out-pdfs.md).

A Signedet az alkalmazásindítón keresztül indítod (`Super + Space`), vagy megnyithatsz vele egy PDF-et a fájlkezelőből.

## Game Vibes

A Game Vibes az alkalmazásindítóban (`Super + Space`) az a hely, ahol az Omarchy apró játékai élnek: a Checkmate, egy 3D sakkjáték egy barát vagy a beépített ellenfél ellen; a Cards, a Klondike pasziánsz; a Death Wish, egy pixelpontos platformjáték tíz, tüskékkel és fűrészekkel teli szobával; és a Neon Swarm, egy árkád lövöldözős játék. Mindegyik egyetlen weboldal, amely követi a témádat. Válassz ki egyet a nyilakkal és az `Enter` billentyűvel, és térj vissza a listához egy játék címképernyőjéről az `Esc`, szüneteltetés közben pedig a `Q` billentyűvel. Teljes képernyőn nyílik meg: a `Super + F` ablakká alakítja, a `Super + W` pedig bezárja.

Az ágenssel készített játékaid is itt jelennek meg: válaszd az _Make something cool → Game_ lehetőséget az ágensek paneljén, és írj le egyet, vagy nevezz meg egy már a Game Vibesban lévő játékot, hogy tovább dolgozz rajta. Az ágens átmásolja a `~/Games/vibes` mappába, ahol a tiéd, módosíthatod, és megnyitja, amikor elkészült. Ezt a másolatot magad is elkészítheted az `omarchy games vibes copy <game>` paranccsal. Egy más által megosztott játék témaként települ: válaszd az _Install > Gaming > Game Vibes_ lehetőséget, és illeszd be a git címét, vagy futtasd az `omarchy games vibes install <git-repo-url>` parancsot. A _Remove > Gaming_ ismét kivesz egyet, az _Update > Game Vibes Games_ pedig lekéri az új verziókat. A játékok a three.js-t a webről töltik be, így az induláshoz kapcsolatra van szükségük.

## Omacalc

Az [Omacalc](https://github.com/omacom-io/omacalc) az Omarchy saját, pofonegyszerű számológépe, amely lebegő ablakban nyílik meg.

Az Omacalcot a `Super + Shift + Q` billentyűkombinációval indítod (vagy a számológép billentyűvel, ha a billentyűzeteden van ilyen).

## Signal

A [Signal](https://signal.org/) az E2E titkosított üzenetküldés úttörője, és remek kommunikációs lehetőség mindenkinek, aki inkább nem valamelyik nagy techóriáson keresztül intézné.

A Signalt a `Super + Shift + G` billentyűkombinációval indítod. Nem része az alaptelepítésnek, így amikor először megnyomod ezt, az Omarchy felajánlja, hogy telepíti neked (az Omarchy menü _Install > Service_ pontja alatt is megtalálod).

## Omaview

Az [Omaview](https://github.com/omacom/omaview) az Omarchy saját, pofonegyszerű képmegjelenítője és médialejátszója: egyetlen ablak a fotóidhoz, videóidhoz és zenéidhez. Nyiss meg egy fotót, és a nyílbillentyűk léptetnek a mappája többi eleme között, az `N` és a `P` ugyanezt teszi bármivel, a `Ctrl + M` pedig az egész mappát rácsként mutatja. HEIC, AVIF és JPEG XL fotókat is megjelenít, és folytatja, ahol abbahagytad bármi hosszút.

Nyomd meg az `F` billentyűt a teljes képernyőhöz, az `E` billentyűt egy kép szerkesztéséhez az Omasnapben vagy egy videó vágásához az Omacutban, a `Ctrl + P` billentyűkombinációt egy kép nyomtatásához, a `Delete` billentyűt pedig egy fájl Kukába mozgatásához (a `Ctrl + Z` visszahozza). Nyomd meg a `?` billentyűt benne az összes billentyűparancs megtekintéséhez.

Az Omaview-t _Media Viewer_ néven indítod az alkalmazásindítón keresztül (`Super + Space`), vagy egyszerűen duplán kattintasz egy képre, videóra vagy dalra a fájlkezelőben.

## Omacut

Az [Omacut](https://github.com/omacom-io/omacut) az Omarchy saját, pofonegyszerű videóvágója. Amikor csak egy klip elejét és végét kell levágnod, jobb, mint elindítani egy teljes videószerkesztőt.

Az Omacutot az alkalmazásindítón keresztül indítod (`Super + Space`).

## Monologue

A [Monologue](https://github.com/omacom/monologue) az Omarchy saját, pofonegyszerű webkamerás felvevője. Válaszd ki egyszer a kamerádat és a mikrofonodat, majd nyomd meg a `Space` billentyűt a felvételhez, és újra a szüneteltetéshez és ugyanazon felvétel folytatásához. Mindig a kamerád legmagasabb felbontásában rögzít, élő mikrofonszintmérővel, hogy indulás előtt ellenőrizhesd a szinteket.

Állítsd le a felvételt, és azonnal megnyílik egy beépített szerkesztőben. Kattints duplán egy klipre a felosztásához, húzd a fogantyúkat az egyes darabok vágásához, és távolítsd el azokat a részeket, amelyeket nem akarsz. Ezután mentsd el MP4-ként. Az eredeti felvételed megmarad, amíg el nem veted, így mindig visszatérhetsz és máshogy vághatod meg.

A Monologue-ot az alkalmazásindítón keresztül indítod (`Super + Space`).
