# GUIs

## Files

A Files (Folio) a grafikus fájlkezelő. A `Super + Shift + F` nyitja meg, a `Super + Shift + Alt + F` pedig abban a mappában nyitja meg, amelyben a terminálod éppen áll, ami rengeteg kattintást megspórol. A `Ctrl + L` segítségével beírhatsz egy elérési utat, a `Space` megnyomása bármely fájlon pedig teljes méretben mutatja az előnézetét anélkül, hogy megnyitná.

Csatlakoztass egy USB-meghajtót vagy egy SD-kártyát, és automatikusan csatolódik, így egyszerűen megjelenik az oldalsávban. Bonyolultabb dolgokhoz — meghajtó formázásához, SMART-állapot ellenőrzéséhez, partíciók létrehozásához — indítsd el a _Disks_ alkalmazást az alkalmazásindítóból (`Super + Space`).

A titkosított meghajtó csatlakoztatáskor kéri a jelszavát. Ha azt szeretnéd, hogy magától feloldódjon, adj hozzá egy kulcsfájlt a `sudo cryptsetup luksAddKey /dev/sdX1 <keyfile>` paranccsal, és tedd azt a kulcsfájlt a `~/.config/omarchy/drive-keys/<UUID>` helyre, a titkosított partícióhoz tartozó, a `lsblk -dno UUID /dev/sdX1` által kiírt UUID szerint elnevezve, és csak általad olvashatóan (`chmod 600`). Ha ez a kulcsfájl hiányzik vagy elutasítják, a rendszer a szokásos módon kéri a jelszót.

A dupla kattintás értelmes alapértelmezéseket követ: a képek, videók és zenék az Omaview-ban, a PDF-ek a Document Viewerben, a Markdown az Omawrite-ban, az egyszerű szöveg pedig a szövegszerkesztődben nyílik meg — ez a Plain, hacsak nem választasz másikat a _Setup > Defaults > Editor_ alatt.

## Disktree

Amikor a meghajtó megtelik, és fogalmad sincs, mi zabálja fel, indítsd el a [Disktree](https://github.com/tobi/disktree) alkalmazást az alkalmazásindítóból (`Super + Space`). Grafikus treemap formájában mutatja a saját mappádat. A nagyobb blokkok több helyet foglalnak; billentyűzettel vagy egérrel lépj be a mappákba, jelöld ki, minek kell mennie, és ellenőrizd a kijelöléseidet, mielőtt bármit eltávolítanál. A `disktree --disk` paranccsal az egész lemezt átvizsgálhatod.

## Obsidian

Az [Obsidian](https://obsidian.md/) egy ingyenes és rendkívül bővíthető jegyzetelő alkalmazás, amely egyszerű Markdown-fájlokat használ tárolásra.

Az Obsidian minden célra ingyenes, beleértve a személyes, kereskedelmi és nonprofit használatot is.

Az Obsidian [kereskedelmi kiegészítőt is kínál a szinkronizáláshoz](https://obsidian.md/sync) az iOS-es és androidos mobilalkalmazásokkal. (https://obsidian.md/pricing).

Az Obsidiant a `Super + Shift + O` kombinációval indítod. A téma szinkronizálásának használatához a beállítások alatt ki kell választanod az `Omarchy` témát.

## Omawrite

Az [Omawrite](https://github.com/omacom-io/omawrite) az Omarchy saját, pofonegyszerű Markdown-író alkalmazása. Nincs vault, nincsenek bővítmények, csak te meg a szavak.

Az Omawrite-ot a `Super + Shift + W` kombinációval indítod.

## Pinta

A [Pinta](https://www.pinta-project.com/) egy egyszerű képszerkesztő eszköz, amely remekül használható vágáshoz, átméretezéshez és egyéb alapvető műveletekhez. Csak ne várj tőle Photoshop-alternatívát. De azért van benne Magic Wand és rétegek is!

A Pintát az alkalmazásindítón keresztül indítod (`Super + Space`).

## Aether

Az [Aether](https://github.com/bjarneo/aether) egy témázó alkalmazás, amely képes színeket kinyerni egy háttérképből, és azokat teljes, összefüggő témává alakítani. Ez a legegyszerűbb módja annak, hogy [elkészítsd a saját témádat](43-making-your-own-theme.md).

Az Aethert az alkalmazásindítón keresztül indítod (`Super + Space`).

## LocalSend

A [LocalSend](https://localsend.org/) segítségével fájlokat küldhetsz ugyanazon a hálózaton lévő, az alkalmazást futtató más eszközökre, mint az Apple AirDropja. Viszont platformfüggetlen, így küldhetsz fájlokat Windowsra, macOS-re, Androidra, iOS-re és természetesen Linuxra, illetve fogadhatsz is azokról.

A Share menüt a `Super + Ctrl + S` kombinációval, vagy az Omarchy menü _Trigger > Share_ pontja alatt nyithatod meg. Négy lehetőséget kínál:

- **Clipboard** azt küldi el szöveges fájlként, amit másoltál. Remek arra, hogy egy linket vagy egy kódrészletet a telefonodra juttass anélkül, hogy e-mailt küldenél magadnak.
- **File** megnyit egy fájlválasztót, ahol egyszerre többet is kiválaszthatsz.
- **Folder** egy teljes mappát küld el.
- **Receive** magát a LocalSendet nyitja meg, hogy egy másik eszköz küldhessen neked valamit.

Ugyanez működik a terminálból is a `omarchy share clipboard`, `omarchy share file [path]` és `omarchy share folder [path]` parancsokkal. Hagyd el az elérési utat, és megkapod a választót.

Közvetlenül a fájlkezelőből is küldhetsz: kattints jobb gombbal bármely kijelölésre a Filesban, és oszd meg a LocalSenddel.

Az Omarchy tűzfala alapértelmezetten zárva van a LocalSend portjának kivételével, így ez egy friss telepítésen azonnal működik. Lásd: [biztonság](48-security.md).

## LibreOffice

A [LibreOffice](https://www.libreoffice.org/) egy teljes irodai csomag szövegszerkesztővel, táblázatkezelővel, prezentációkkal, rajzalkalmazással és még sok mással. Kompatibilis a Microsoft Office fájljaival, így ez remek módja annak, hogy meg tudd nyitni azokat a Word-dokumentumokat.

A LibreOffice-t az alkalmazásindítón keresztül indítod (`Super + Space`).

## Hype

A [Hype](https://github.com/omacom/hype) az Omarchy saját, pofonegyszerű prezentációs alkalmazása. A prezentációd egyetlen Markdown-fájl, a képeivel és videóival mellette: minden diát élő előnézet alatt írj meg, húzd a diákat sorrendbe, majd mutasd be teljes képernyőn, vagy exportáld PDF-be és PowerPointba. Még az Omarchy-témádat is átveszi.

A Hype-ot az alkalmazásindítón keresztül indítod (`Super + Space`). Nyomd meg a `?` billentyűt benne, hogy lásd az összes gyorsbillentyűt.

## Signed

A [Signed](https://github.com/omacom/signed) az Omarchy saját, pofonegyszerű módja a PDF-ek aláírására és kitöltésére. Helyezd el a mentett aláírásodat, szöveget és a mai dátumot bárhová egy oldalon, majd ments egy aláírt példányt az eredeti mellé. A hogyanról lásd: [PDF-ek kitöltése](27-filling-out-pdfs.md).

A Signedet az alkalmazásindítón keresztül indítod (`Super + Space`), vagy megnyithatsz vele egy PDF-et a fájlkezelőből.

## Game Vibes

A Game Vibes az alkalmazásindítóban (`Super + Space`) az a hely, ahol az Omarchy kis játékai élnek: a Checkmate, egy 3D sakkjáték egy barát vagy a beépített ellenfél ellen; a Cards, Klondike pasziánsz; a Death Wish, egy pixelpontos platformjáték tíz, tüskékkel és fűrészekkel teli szobával; és a Neon Swarm, egy arcade lövöldözős játék. Mindegyik egyetlen weboldal, amely követi a témádat. Válassz ki egyet a nyilakkal és az `Enter` billentyűvel, és térj vissza a listához egy játék címképernyőjéről az `Esc`, szüneteltetés közben pedig a `Q` billentyűvel. Teljes képernyőn nyílik meg: a `Super + F` ablakká alakítja, a `Super + W` pedig bezárja.

Azok a játékok is itt jelennek meg, amelyeket egy ügynökkel készítesz: válaszd az _Make something cool → Game_ lehetőséget az ügynökök paneljén, és írj le egyet, vagy nevezz meg egy már a Game Vibesban lévő játékot, hogy tovább dolgozz rajta. Az ügynök bemásolja a `~/Games/vibes` mappába, ahol a tiéd, módosíthatod, és megnyitja, amikor elkészült. Ezt a másolatot magad is elkészítheted a `omarchy games vibes copy <game>` paranccsal. Egy más által megosztott játék témaként települ: válaszd az _Install > Gaming > Game Vibes_ lehetőséget, és illeszd be a git-címét, vagy futtasd a `omarchy games vibes install <git-repo-url>` parancsot. A _Remove > Gaming_ ismét eltávolít egyet, a _Update > Game Vibes Games_ pedig lekéri az új verziókat. A játékok a three.js-t a webről töltik be, így az induláshoz kapcsolatra van szükségük.

## Omacalc

Az [Omacalc](https://github.com/omacom-io/omacalc) az Omarchy saját, pofonegyszerű számológépe, amely lebegő ablakban nyílik meg.

Az Omacalcot a `Super + Shift + Q` kombinációval indítod (vagy a számológép billentyűvel, ha a billentyűzeteden van ilyen).

## Signal

A [Signal](https://signal.org/) az E2E titkosított üzenetküldés úttörője, és remek kommunikációs lehetőség mindenkinek, aki inkább nem valamelyik nagy technológiai konglomerátumon keresztül szeretne kommunikálni.

A Signalt a `Super + Shift + G` kombinációval indítod. Nem része az alaptelepítésnek, így amikor először nyomod meg ezt, az Omarchy felajánlja, hogy telepíti neked (az Omarchy menü _Install > Service_ pontja alatt is megtalálható).

## Omaview

Az [Omaview](https://github.com/omacom/omaview) az Omarchy saját, pofonegyszerű képnézegetője és médialejátszója: egy ablak a fényképeidnek, videóidnak és zenéidnek. Nyiss meg egy fényképet, és a nyílbillentyűk végiglépkednek a mappája többi részén, az `N` és a `P` bármi esetén ugyanezt teszi, a `Ctrl + M` pedig az egész mappát rácsként mutatja. HEIC, AVIF és JPEG XL fényképeket is megjelenít, és ott folytatja, ahol abbahagytad bármi hosszabbat.

Nyomd meg az `F` billentyűt a teljes képernyőhöz, az `E` billentyűt egy kép szerkesztéséhez az Omasnapban vagy egy videó vágásához az Omacutban, a `Ctrl + P` kombinációt egy kép nyomtatásához, a `Delete` billentyűt pedig egy fájl Kukába mozgatásához (a `Ctrl + Z` visszahozza). Nyomd meg a `?` billentyűt benne, hogy lásd az összes gyorsbillentyűt.

Az Omaview-t _Media Viewer_ néven indítod az alkalmazásindítón keresztül (`Super + Space`), vagy egyszerűen kattints duplán egy képre, videóra vagy dalra a fájlkezelőben.

## Omacut

Az [Omacut](https://github.com/omacom-io/omacut) az Omarchy saját, pofonegyszerű videóvágója. Amikor csak arra van szükséged, hogy levágd egy klip elejét és végét, veri azt, hogy beindíts egy teljes videószerkesztőt.

Az Omacutot az alkalmazásindítón keresztül indítod (`Super + Space`).

## Monologue

A [Monologue](https://github.com/omacom/monologue) az Omarchy saját, pofonegyszerű webkamerás felvevője. Válaszd ki egyszer a kamerádat és a mikrofonodat, majd nyomd meg a `Space` billentyűt a felvételhez, és ismét a szüneteltetéshez és ugyanazon felvétel folytatásához. Mindig a kamerád legmagasabb felbontásában rögzít, élő mikrofonszintmérővel, hogy indulás előtt ellenőrizhesd a szinteket.

Állítsd le a felvételt, és azonnal megnyílik egy beépített szerkesztőben. Kattints duplán egy klipre a felosztásához, húzd a fogantyúkat az egyes darabok vágásához, és távolítsd el azokat a részeket, amelyeket nem akarsz. Ezután mentsd el MP4-ként. Az eredeti felvételed megmarad, amíg el nem veted, így mindig visszatérhetsz, és másképp vághatod meg.

A Monologue-ot az alkalmazásindítón keresztül indítod (`Super + Space`).
