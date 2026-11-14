# GUI-k

## Fájlok

A Files (Nautilus) a grafikus fájlkezelő. A `Super + Shift + F` nyitja meg, a `Super + Shift + Alt + F` pedig abban a könyvtárban, amelyben éppen a terminálod áll, ami rengeteg kattintást megspórol. A `Ctrl + L` segítségével beírhatsz egy elérési utat, a `Space` megnyomása bármelyik fájlon pedig gyors előnézetet ad anélkül, hogy bármit is megnyitnál.

Csatlakoztass egy USB-meghajtót vagy egy SD-kártyát, és automatikusan csatolódik, így egyszerűen megjelenik az oldalsávban. Minden komolyabb feladathoz — meghajtó formázásához, a SMART-állapot ellenőrzéséhez, partíciók létrehozásához — indítsd el a _Disks_ alkalmazást az alkalmazásindítóból (`Super + Space`).

A dupla kattintás ésszerű alapértelmezéseket követ: a képek imv-ben, a videók mpv-ben, a PDF-ek a Document Viewer alkalmazásban, az egyszerű szövegfájlok pedig Neovimban nyílnak meg.

## Disktree

Amikor megtelik a meghajtó, és fogalmad sincs, mi zabálja fel, indítsd el a [Disktree](https://github.com/tobi/disktree) alkalmazást az alkalmazásindítóból (`Super + Space`). Grafikus treemap formájában mutatja a saját könyvtáradat. A nagyobb blokkok több helyet foglalnak; billentyűzettel vagy egérrel lépkedhetsz be a könyvtárakba, megjelölheted, minek kell mennie, és bármit is távolítanál el, előbb átnézheted a kiválasztásaidat. Az egész lemez vizsgálatához futtasd a `disktree --disk` parancsot.

## Obsidian

Az [Obsidian](https://obsidian.md/) egy ingyenes és rendkívül bővíthető jegyzetelő alkalmazás, amely egyszerű Markdown-fájlokat használ tárolásra.

Az Obsidian minden célra ingyenes, beleértve a személyes, a kereskedelmi és a nonprofit felhasználást is.

Az Obsidian [kereskedelmi kiegészítőt is kínál szinkronizáláshoz](https://obsidian.md/sync) iOS-es és androidos mobilalkalmazásokkal. (https://obsidian.md/pricing).

Az Obsidiant a `Super + Shift + O` billentyűkombinációval indítod. A téma szinkronizálásához a beállítások alatt ki kell választanod az `Omarchy` témát.

## Omawrite

Az [Omawrite](https://github.com/omacom-io/omawrite) az Omarchy saját, pofonegyszerű Markdown-íróalkalmazása. Nincsenek vaultok, nincsenek bővítmények, csak te és a szavak.

Az Omawrite-ot a `Super + Shift + W` billentyűkombinációval indítod.

## Pinta

A [Pinta](https://www.pinta-project.com/) egy egyszerű képszerkesztő eszköz, amely remekül használható vágáshoz, átméretezéshez és más alapvető műveletekhez. Csak Photoshop-alternatívát ne várj tőle. De még így is van benne Magic Wand és rétegek!

A Pintát az alkalmazásindítón keresztül indítod (`Super + Space`).

## Aether

Az [Aether](https://github.com/bjarneo/aether) egy témázó alkalmazás, amely színeket tud kinyerni egy háttérképből, és azokat teljes, egységes témává tudja alakítani. Ez a legegyszerűbb módja annak, hogy [elkészítsd a saját témádat](43-making-your-own-theme.md).

Az Aethert az alkalmazásindítón keresztül indítod (`Super + Space`).

## LocalSend

A [LocalSend](https://localsend.org/) segítségével fájlokat küldhetsz ugyanazon a hálózaton lévő, az alkalmazást futtató más eszközökre, akárcsak az Apple AirDropjával. Viszont platformfüggetlen, így Windows, macOS, Android, iOS és persze Linux között is küldhetsz fájlokat oda-vissza.

A Megosztás menüt a `Super + Ctrl + S` billentyűkombinációval vagy az Omarchy menüben a _Trigger > Share_ alatt nyithatod meg. Négy lehetőséget kínál:

- A **Clipboard** szövegfájlként küldi el, bármit is másoltál. Remek arra, hogy egy hivatkozást vagy egy részletet a telefonodra juttass anélkül, hogy e-mailt küldenél magadnak.
- A **File** egy fájlválasztót nyit meg, ahol egyszerre többet is kiválaszthatsz.
- A **Folder** egy teljes könyvtárat küld el.
- A **Receive** magát a LocalSendet nyitja meg, hogy egy másik eszköz küldhessen neked valamit.

Ugyanez a terminálból is működik az `omarchy share clipboard`, az `omarchy share file [path]` és az `omarchy share folder [path]` parancsokkal. Hagyd le az elérési utat, és megkapod a választót.

Közvetlenül a fájlkezelőből is küldhetsz: kattints jobb gombbal bármilyen kijelölésre a Nautilusban, és válaszd a _Send via LocalSend_ lehetőséget.

Az Omarchy tűzfala alapértelmezés szerint zárva van, kivéve a LocalSend portját, így ez egy friss telepítésen azonnal működik. Lásd: [biztonság](48-security.md).

## LibreOffice

A [LibreOffice](https://www.libreoffice.org/) egy teljes irodai csomag szövegszerkesztővel, táblázatkezelővel, bemutatókészítővel, rajzolóalkalmazással és még sok mással. Kompatibilis a Microsoft Office fájljaival, így remek módja annak, hogy meg tudd nyitni azokat a Word-dokumentumokat.

A LibreOffice-t az alkalmazásindítón keresztül indítod (`Super + Space`).

## Hype

A [Hype](https://github.com/omacom/hype) az Omarchy saját, pofonegyszerű prezentációs alkalmazása. A prezentációd egyetlen Markdown-fájl, mellette a képeivel és videóival: minden diát élő előnézet alatt írsz meg, a diákat sorrendbe húzod, majd teljes képernyőn prezentálsz, vagy PDF-be és PowerPointba exportálsz. Még az Omarchy-témádat is átveszi.

A Hype-ot az alkalmazásindítón keresztül indítod (`Super + Space`). Nyomd meg benne a `?` billentyűt az összes gyorsbillentyű megtekintéséhez.

## Signed

A [Signed](https://github.com/omacom/signed) az Omarchy saját, pofonegyszerű módja PDF-ek aláírására és kitöltésére. Helyezd el a mentett aláírásodat, szöveget és a mai dátumot bárhová egy oldalon, majd ments egy aláírt példányt az eredeti mellé. A módját lásd itt: [PDF-ek kitöltése](27-filling-out-pdfs.md).

A Signedet az alkalmazásindítón keresztül indítod (`Super + Space`), vagy megnyithatsz vele egy PDF-et a fájlkezelőből.

## Omacalc

Az [Omacalc](https://github.com/omacom-io/omacalc) az Omarchy saját, pofonegyszerű számológépe, amely lebegő ablakban nyílik meg.

Az Omacalcot a `Super + Shift + Q` billentyűkombinációval indítod (vagy a számológép billentyűvel, ha a billentyűzeteden van ilyen).

## Signal

A [Signal](https://signal.org/) az E2E-titkosított üzenetküldés úttörője, és remek kommunikációs lehetőség mindenkinek, aki inkább nem valamelyik nagy technológiai konglomerátumon keresztül intézné ezt.

A Signalt a `Super + Shift + G` billentyűkombinációval indítod. Nem része az alaptelepítésnek, így amikor először megnyomod ezt, az Omarchy felajánlja, hogy telepíti neked (az Omarchy menüben az _Install > Service_ alatt is megtalálod).

## mpv

Az [mpv](https://mpv.io/) egy egyszerű, gyors médialejátszó, amely szinte bármit lejátszik bármilyen forrásból. Remek videók nézéséhez.

Az mpv-t az alkalmazásindítón keresztül indítod (`Super + Space`), vagy egyszerűen dupla kattintással egy videóra a fájlkezelőben.

## Omacut

Az [Omacut](https://github.com/omacom-io/omacut) az Omarchy saját, pofonegyszerű videóvágója. Amikor csak egy klip elejét és végét kell levágnod, sokkal jobb, mint elindítani egy teljes értékű videószerkesztőt.

Az Omacutot az alkalmazásindítón keresztül indítod (`Super + Space`).

## Monologue

A [Monologue](https://github.com/omacom/monologue) az Omarchy saját, pofonegyszerű webkamerás rögzítője. Válaszd ki egyszer a kamerádat és a mikrofonodat, majd nyomd meg a `Space` billentyűt a rögzítéshez, és újra ugyanannak a felvételnek a szüneteltetéséhez és folytatásához. Mindig a kamerád legmagasabb felbontásában rögzít, élő mikrofonszint-jelzővel, így még kezdés előtt ellenőrizheted a szinteket.

Állítsd le a felvételt, és azonnal megnyílik egy beépített szerkesztőben. Kattints duplán egy klipre a felosztásához, húzd a fogantyúkat az egyes darabok vágásához, és távolítsd el azokat a részeket, amelyekre nincs szükséged. Ezután mentsd el MP4-ként. Az eredeti felvételed megmarad, amíg el nem veted, így bármikor visszatérhetsz hozzá, és másképp vághatod meg.

A Monologue-ot az alkalmazásindítón keresztül indítod (`Super + Space`).
