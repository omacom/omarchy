# Kezdő lépések

Az Omarchy telepítése ISO segítségével történik. Választhatsz a teljes lemezes telepítés között, amely átveszi az egész meghajtót, vagy a szabad helyre történő telepítés között, amely egy meghajtó fel nem osztott területére teszi az Omarchyt — így tudsz kettős rendszerindítást használni Windows vagy egy másik operációs rendszer mellett (lásd: [kettős rendszerindításos telepítés](50-dual-boot-install.md) — vedd figyelembe, hogy Windowsban előbb ki kell kapcsolnod a BitLockert). Akárhogy is, a telepítés alapértelmezés szerint teljes titkosítást használ, a teljes lemezes opció pedig törli a kiválasztott meghajtót, ezért feltétlenül készíts biztonsági mentést, mielőtt egy meglévőt használnál!

Először [Töltsd le az Omarchy ISO-t](https://omarchy.org/), tedd rá egy USB-kulcsra (Macen/Windowson használd a [balenaEtcher](https://etcher.balena.io/) alkalmazást, Linuxon pedig a [caligula](https://github.com/ifd3f/caligula) alkalmazást), és indítsd el a gépet a kulcsról.

_Ki kell kapcsolnod a Secure Bootot és/vagy a TPM-et a BIOS-ban. Ezeket ki kell kapcsolnod ahhoz, hogy telepíteni tudd az Omarchyt. Ezek Microsoft-biztonsági megoldások, amelyeket Windowshoz és a Microsofthoz kötődő Linux-disztribúciókhoz szántak._

Ezután válaszolj a konfigurációs kérdésekre, és erősítsd meg őket így:

 ![install-config](images/install-config.webp)

Ezután válassz egy meghajtót a telepítéshez, dőlj hátra, és nézd végig a telepítési műsort. A leggyorsabb modern gépeken egy perc alatt kész lehet, de még egy régebbi számítógépen sem tarthat 5 percnél tovább.

 ![install-done](images/install-done.webp)

Most már készen állsz omarchyzni!

### Használj vezetékes vagy 2.4ghz-es billentyűzetet!

A teljes lemezes titkosítás nem engedi, hogy induláskor Bluetooth-billentyűzetről írd be a jelszót. Ahogy egy PC-n sem tudsz Bluetooth-billentyűzetet használni a BIOS-ba való belépéshez. Olyan billentyűzetre lesz szükséged, amely vagy 2.4ghz-es dongle-t használ, vagy kábeles (ami a késleltetés szempontjából amúgy is sokkal jobb!). Én személy szerint imádom a [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard) billentyűzetet!

### Telepítés másik tulajdonosnak

Ha másnak állítasz be egy gépet — egy családtagnak, egy új munkatársnak, egy vevőnek —, nem neked kell megválaszolnod a személyes kérdéseket a nevükben. Nyomd meg a `Ctrl + C` billentyűkombinációt a telepítő legelső képernyőjén (a billentyűzetválasztón), és az Omarchy felajánlja, hogy ehelyett másik tulajdonosnak készíti elő a gépet. A rendszer azonnal települ, de minden személyes beállítás — a billentyűzetkiosztás, a felhasználónév, a jelszó — elhalasztódik a gép első indulásáig. A meghajtó alapértelmezés szerint továbbra is titkosított, és az a jelszó, amelyet az új tulajdonos az első induláskor kiválaszt, egyben a titkosítási jelszó is lesz. (Egy már használt gép újratelepítés nélkül is átadható — lásd: [a számítógép visszaállítása](48-security.md).)

### Felügyelet nélküli telepítések

Az ISO teljesen önállóan is tud telepíteni — billentyűzet és varázsló nélkül —, ha egy második meghajtón megkapja a konfigurációját. Így lehet az Omarchyt alapképként kezelni VM-ekhez és gépflották gépeihez. Lásd: [felügyelet nélküli telepítések](51-unattended-installs.md).

### Telepítés titkosítás nélkül

Az Omarchy alapértelmezés szerint titkosítással települ. Ez a biztonságos, felelősségteljes választás minden olyan számítógép esetében, amely esetleg elveszhet vagy ellophatják. Nem szeretnéd, hogy bárki, aki hozzáfér a hardveredhez, hozzá tudjon férni az adataidhoz!

De különleges körülmények között, például védett számítógépeken végzett távoli Omarchy-telepítéseknél vagy érzékeny adatokat nem tartalmazó, eldobható telepítéseknél előfordulhat, hogy titkosítás nélkül szeretnél telepíteni. A lemezformázás megerősítésénél megnyomhatod a `Ctrl + C` billentyűkombinációt, hogy titkosítás nélküli telepítésre válts.

### Nyelv

Az Omarchy 50 nyelven beszél — ugyanabban a készletben, mint az omarchy.org —, és az angol az alapértelmezett. A váltáshoz nyisd meg az Omarchy menüt, és lépj a _Beállítás > Nyelv_ pontra, vagy futtasd terminálban az `omarchy language <code>` parancsot (az `omarchy language list` megmutatja a kódokat). A menü, az asztal és az Omarchy saját értesítései azonnal nyelvet váltanak, és minden ezután megnyitott alkalmazás is követi őket. A már nyitva lévő alkalmazások az újraindításuk után váltanak.

### Segítség, ha elakadtál

Ha elakadsz, általában találsz valakit, aki szívesen segít a [közösségi Discord](https://omarchy.org/discord) _#omarchy-help_ csatornáján.
