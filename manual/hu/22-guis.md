# GUI-k

## Files

A Files (Nautilus) a grafikus fájlkezelő. A `Super + Shift + F` megnyitja, a `Super + Shift + Alt + F` pedig abban a könyvtárban nyitja meg, amelyben a terminálod tartózkodik, ami sok kattintást takarít meg. A `Ctrl + L` lehetővé teszi egy útvonal begépelését, bármelyik fájlon megnyomva a `Space` billentyűt pedig gyors előnézetet kapsz anélkül, hogy bármit megnyitnál.

Dugj be egy USB-meghajtót vagy egy SD-kártyát, és automatikusan csatolódik, így egyszerűen megjelenik az oldalsávban. Minden összetettebb feladathoz — meghajtó formázásához, SMART-állapot ellenőrzéséhez, partíciók létrehozásához — indítsd el a _Disks_ alkalmazást az alkalmazásindítóból (`Super + Space`).

A dupla kattintás értelmes alapértelmezéseket követ: a képek az imv-ben nyílnak, a videó az mpv-ben, a PDF-ek a Document Viewerben, a sima szöveg pedig a Neovimban.

## Disktree

Amikor a meghajtó megtelik, és fogalmad sincs, mi eszi fel, indítsd el a [Disktree](https://github.com/tobi/disktree) programot az alkalmazásindítóból (`Super + Space`). A saját mappád grafikus fatérképét mutatja. A nagyobb blokkok több helyet foglalnak; járj be könyvtárakat billentyűzettel vagy egérrel, jelöld meg, minek kell mennie, és ellenőrizd a választásaidat, mielőtt bármit eltávolítanál. Futtasd a `disktree --disk` parancsot az egész lemez beolvasásához.

## Obsidian

Az [Obsidian](https://obsidian.md/) egy ingyenes és rendkívül bővíthető jegyzetelő alkalmazás, amely egyszerű Markdown-fájlokat használ tárolásra.

Az Obsidian minden célra ingyenes, beleértve a személyes, kereskedelmi és nonprofit használatot is.

Az Obsidian [kereskedelmi szinkronizálási kiegészítőt](https://obsidian.md/sync) is kínál iOS- és Android-mobilalkalmazásokkal. (https://obsidian.md/pricing).

Az Obsidiant a `Super + Shift + O` kombinációval indítod. A témaszinkronizáláshoz a beállításokban ki kell választanod az `Omarchy` témát.

## Omawrite

Az [Omawrite](https://github.com/omacom-io/omawrite) az Omarchy saját, végtelenül egyszerű Markdown-íróalkalmazása. Nincsenek adattárak, nincsenek bővítmények, csak te és a szavaid.

Az Omawrite-ot a `Super + Shift + W` kombinációval indítod.

## Pinta

A [Pinta](https://www.pinta-project.com/) egy alapvető képszerkesztő eszköz, amely nagyszerű vágáshoz, átméretezéshez és más alapvető műveletekhez. Csak ne vársz Photoshop-alternatívát. De mégis megvan benne a varázspálca és a rétegek!

A Pintát az alkalmazásindítón keresztül indíthatod (`Super + Space`).

## Aether

Az [Aether](https://github.com/bjarneo/aether) egy témázó alkalmazás, amely színeket nyer ki egy háttérképről, és azokat teljes, egységes témává alakítja. Ez a legegyszerűbb módja annak, hogy [elkészítsd saját témádat](43-making-your-own-theme.md).

Az Aethert az alkalmazásindítón keresztül indíthatod (`Super + Space`).

## LocalSend

A [LocalSend](https://localsend.org/) segítségével fájlokat küldhetsz ugyanazon a hálózaton lévő, az alkalmazást futtató más eszközökre, mint az Apple AirDropja. Azonban többplatformos, így Windowsra, macOS-re, Androidra, iOS-re és természetesen Linuxra is küldhetsz és fogadhatsz fájlokat.

A Megosztás menüt a `Super + Ctrl + S` billentyűvel vagy az Omarchy menü _Trigger > Share_ pontjában nyithatod meg. Négy lehetőséget ad:

- A **Clipboard** szövegfájlként küldi el, bármit is másoltál. Nagyszerű ahhoz, hogy egy hivatkozást vagy egy kódrészletet a telefonodra juttass anélkül, hogy magadnak e-maileznél.
- A **File** megnyit egy fájlválasztót, ahol egyszerre többet választhatsz ki.
- A **Folder** egy teljes könyvtárat küld.
- A **Receive** megnyitja magát a LocalSend-et, hogy egy másik eszköz küldhessen neked valamit.

Ugyanez működik terminálból is az `omarchy share clipboard`, az `omarchy share file [path]` és az `omarchy share folder [path]` paranccsal. Hagyd le az elérési utat, és megkapod a fájlválasztót.

Küldhetsz közvetlenül a fájlkezelőből is: kattints jobb gombbal bármely kiválasztásra a Nautilusban, és válaszd az _Send via LocalSend_ lehetőséget.

Az Omarchy tűzfala alapértelmezetten zárva van, kivéve a LocalSend portját, így ez frissen telepített rendszeren is azonnal működik. Lásd a [security](48-security.md) részt.

## LibreOffice

A [LibreOffice](https://www.libreoffice.org/) egy teljes irodai csomag szövegszerkesztővel, táblázatkezelővel, prezentációval, rajzalkalmazással és egyebekkel. Kompatibilis a Microsoft Office fájljaival, így ez nagyszerű módja annak, hogy megnyisd azokat a Word-dokumentumokat.

A LibreOffice-t az alkalmazásindítón keresztül indíthatod (`Super + Space`).

## Hype

A [Hype](https://github.com/omacom/hype) az Omarchy saját, végtelenül egyszerű prezentációs alkalmazása. A diavetítésed egy egyetlen Markdown-fájl a képeivel és videóival mellette: minden diát egy élő előnézet alá írj, húzd rendezett sorba a diákat, majd mutasd be teljes képernyőn vagy exportáld PDF-be és PowerPointba. Még az Omarchy-témádat is átveszi.

A Hype-ot az alkalmazásindítón keresztül indíthatod (`Super + Space`). Nyomd meg a `?` billentyűt belül az összes gyorsbillentyű megtekintéséhez.

## Signed

A [Signed](https://github.com/omacom/signed) az Omarchy saját, végtelenül egyszerű módja PDF-ek aláírására és kitöltésére. Tedd a tárolt aláírásodat, szövegedet és a mai dátumot az oldal bármely részére, majd ments el egy aláírt példányt az eredeti mellé. A hogyanról lásd a [Filling out PDFs](27-filling-out-pdfs.md) részt.

A Signedet az alkalmazásindítón keresztül indíthatod (`Super + Space`), vagy nyiss meg vele egy PDF-et a fájlkezelőből.

## Omacalc

Az [Omacalc](https://github.com/omacom-io/omacalc) az Omarchy saját, végtelenül egyszerű számológépe, amely lebegő ablakban nyílik.

Az Omacalcot a `Super + Ctrl + Q` kombinációval indíthatod (vagy a számológép-billentyűvel, ha a billentyűzete rendelkezik ilyennel).

## Signal

A [Signal](https://signal.org/) az E2E-titkosítás úttörője, és nagyszerű kommunikációs lehetőség bárki számára, aki szeretné elkerülni a nagy technológiai konglomerátumokat.

A Signalt a `Super + Shift + G` kombinációval indíthatod. Nem része az alaptelepítésnek, így az első alkalommal, amikor ezt megnyomod, az Omarchy felajánlja, hogy telepíti neked (az Omarchy menü _Install > Service_ pontja alatt is megtalálható).

## mpv

Az [mpv](https://mpv.io/) egy egyszerű, gyors médialejátszó, amely szinte bármit lejátszik bármilyen forrásból. Nagyszerű videónezegetéshez.

Az mpv-t az alkalmazásindítón keresztül (`Super + Space`) indíthatod, vagy egyszerűen duplán kattints egy videóra a fájlkezelőben.

## Omacut

Az [Omacut](https://github.com/omacom-io/omacut) az Omarchy saját, végtelenül egyszerű videóvágója. Amikor csak egy klip elejét és végét kell levágni, ez veri egy komplett videószerkesztő elindítását.

Az Omacutot az alkalmazásindítón keresztül indíthatod (`Super + Space`).

## Monologue

A [Monologue](https://github.com/omacom/monologue) az Omarchy saját, végtelenül egyszerű webkamera-felvevője. Vállj kamerát és mikrofont egyszer, majd nyomd meg a `Space` billentyűt a felvételhez, és újra a szünethez és folytatáshoz ugyanannál a felvételnél. Mindig a kamerád legnagyobb felbontásában rögzít, élő mikrofon-méterrel, hogy a kezdés előtt ellenőrizd a szinteket.

Állítsd le a felvételt, és máris megnyílik egy beépített szerkesztőben. Kattints duplán egy klipre, hogy felvágd, húzd a fogantyúkat minden rész vágásához, és töröld a nem kívánt részeket. Majd mentse el MP4-ként. Az eredeti felvétel addig megmarad, amíg el nem dobja, így mindig visszatérhetsz, és másképp vághatod.

A Monologue-ot az alkalmazásindítón keresztül indíthatod (`Super + Space`).
