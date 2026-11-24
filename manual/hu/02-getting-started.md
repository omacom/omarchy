# Első lépések

Az Omarchy ISO-val telepíthető. Választhatsz a teljes lemezes telepítés között, amely átveszi az egész meghajtót, vagy a szabad helyre történő telepítés között, amely az Omarchy-t a meghajtó fel nem osztott területére teszi — így tudsz dual bootot beállítani Windows vagy egy másik OS mellé (lásd a [dual-boot telepítés](50-dual-boot-install.md) részt — vedd figyelembe, hogy előbb ki kell kapcsolnod a BitLockert a Windowsban). Akárhogy is, a telepítés alapértelmezés szerint teljes titkosítást használ, és a teljes lemezes opció törölni fogja a kiválasztott meghajtót, úgyhogy mindenképp készíts biztonsági mentést, mielőtt egy meglévőt használsz!

Apple Silicon Macen az ISO vagy USB-stick helyett macOS-ből telepítesz. Lásd az [Omarchy Apple Siliconra](44-mac-support.md#omarchy-for-apple-silicon) részt.

[Töltsd le először az Omarchy ISO-t](https://omarchy.org/), tedd USB-stickre (Windowson használd a [Rufus](https://rufus.ie/) alkalmazást, Macen a [balenaEtcher](https://etcher.balena.io/) alkalmazást, Linuxon pedig a [caligula](https://github.com/ifd3f/caligula) alkalmazást), és bootolj a stickről.

_Ki kell kapcsolnod a Secure Bootot és/vagy a TPM-et a BIOS-ban. Ki kell kapcsolnod ezeket, hogy telepíteni tudd az Omarchy-t. Ezek Microsoft biztonsági sémák, amelyek a Windowshoz és a Microsofthoz kötődő Linux disztribúciókhoz készültek._

Ezután válaszolj a konfigurációs kérdésekre, és erősítsd meg őket így:

 ![install-config](images/install-config.webp)

Ezután válassz ki egy meghajtót a telepítéshez, dőlj hátra, és nézd a telepítés műsorát. A leggyorsabb modern gépeken egy perc alatt megvan, de még egy régebbi számítógépen sem tarthat tovább 5 percnél.

 ![install-done](images/install-done.webp)

Most már készen állsz az Omarchy-ra!

### Használj vezetékes vagy 2.4ghz-es billentyűzetet!

A teljes lemezes titkosítás miatt induláskor nem tudod Bluetooth billentyűzetről beírni a jelszót. Ahogy PC-n sem tudsz Bluetooth billentyűzetet használni a BIOS-ba való belépéshez. Olyan billentyűzetre lesz szükséged, amely vagy 2.4ghz-es dongle-t vagy kábelt használ (ami amúgy is sokkal jobb a késleltetés szempontjából!). Én személy szerint imádom a [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard) billentyűzetet!

### Telepítés egy másik tulajdonosnak

Ha valaki másnak állítasz be egy gépet — egy családtagnak, egy új munkatársnak, egy vevőnek — nem neked kellene helyettük válaszolnod a személyes kérdésekre. Nyomj `Ctrl + C` billentyűkombinációt a telepítő legelső képernyőjén (a billentyűzet kiválasztásánál), és az Omarchy felajánlja, hogy inkább egy másik tulajdonosnak készíti elő a gépet. A rendszer azonnal települ, de minden személyes beállítás — billentyűzetkiosztás, felhasználónév, jelszó — arra az időpontra halasztódik, amikor a gép először elindul. A meghajtó alapértelmezés szerint továbbra is titkosított, és az új tulajdonos által az első induláskor választott jelszó lesz a titkosítási jelszó is. (Egy olyan gép is átadható újratelepítés nélkül, amelyet már használtál — lásd a [számítógép visszaállítása](48-security.md) részt.)

### Felügyelet nélküli telepítések

Az ISO teljesen önállóan is telepíteni tud — billentyűzet és varázsló nélkül —, amikor egy második meghajtón megkapja a konfigurációját. Így kell az Omarchy-t alap image-ként kezelni VM-ekhez és flottagépekhez. Lásd a [felügyelet nélküli telepítések](51-unattended-installs.md) részt.

### Titkosítás nélküli telepítések

Az Omarchy alapértelmezés szerint titkosítással települ. Ez a biztonságos, felelős választás minden olyan számítógépnél, amely esetleg elveszhet vagy ellophatják. Nem akarod, hogy bárki, aki hozzáfér a hardveredhez, hozzáférhessen az adataidhoz!

De különleges körülmények között, például védett számítógépeken végzett távoli Omarchy telepítéseknél vagy érzékeny adatok nélküli, eldobható telepítéseknél érdemes lehet titkosítás nélkül telepíteni. A lemezformázás megerősítésénél a `Ctrl + C` megnyomásával válthatsz titkosítás nélküli telepítésre.

### Nyelv

Az Omarchy 50 nyelven beszél — ugyanazon a készleten, mint az omarchy.org —, és az alapértelmezett az angol. A váltáshoz nyisd meg az Omarchy menüt, és lépj a _Setup > Region > Language_ menüpontra, vagy futtasd az `omarchy language <code>` parancsot egy terminálban (az `omarchy language list` megmutatja a kódokat). A menü, az asztal és az Omarchy saját értesítései azonnal nyelvet váltanak, és minden utána megnyitott alkalmazás is követi ezt. A már nyitva lévő alkalmazások akkor váltanak, amikor újraindítod őket.

Ha meg akarod tartani a nyelvet, de a dátumokat, időket, számokat, pénzt, mértékegységeket és papírméreteket egy másik régió szokásai szerint akarod írni (például angolt európai dátumokkal és 24 órás órával), válassz egy régiót a _Setup > Region > Formats_ alatt, ahol minden választásnál minta is látható, vagy futtasd az `omarchy region formats <code>` parancsot (az `omarchy region formats list` megmutatja a kódokat). A _Same as language_ visszavisz a nyelv saját formátumaihoz. A nyelvváltáshoz hasonlóan ez is az utána megnyitott alkalmazásokat éri el.

### Segítség, ha elakadtál

Ha elakadsz, általában találsz valakit, aki szívesen segít a _#omarchy-help_ csatornán a [közösségi Discordon](https://omarchy.org/discord).
