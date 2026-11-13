# Első lépések

Az Omarchy egy ISO segítségével telepíthető. Választhatsz a teljes lemezes telepítés, amely átveszi az egész meghajtót, vagy a szabad helyre történő telepítés között, amely az Omarchy-t a meghajtón lévő lefoglalatlan helyre teszi — így tudsz dual bootolni Windows vagy egy másik OS mellett (lásd [dual-boot telepítés](50-dual-boot-install.md) — vedd figyelembe, hogy először ki kell kapcsolnod a BitLockert a Windowsban). Akárhogy is, a telepítés alapértelmezetten teljes titkosítást használ, és a teljes lemezes opció törölni fogja a kiválasztott meghajtót, úgyhogy mindenképpen készíts biztonsági másolatot, mielőtt egy meglévőt használnál!

Először [töltsd le az Omarchy ISO-t](https://omarchy.org/), tedd rá egy USB-meghajtóra (használd a [Rufus](https://rufus.ie/) programot Windowson, a [balenaEtcher](https://etcher.balena.io/) programot Macen, vagy a [caligula](https://github.com/ifd3f/caligula) programot Linuxon), és bootolj a meghajtóról.

_Ki kell kapcsolnod a Secure Bootot és/vagy a TPM-et a BIOS-ban. Ki kell kapcsolnod ezeket ahhoz, hogy telepíteni tudd az Omarchy-t. Ezek Microsoft biztonsági sémák, amelyek a Windowshoz és a Microsofthoz kapcsolódó Linux disztribúciókhoz készültek._

Ezután válaszolj a konfigurációs kérdésekre, és erősítsd meg őket így:

 ![install-config](images/install-config.webp)

Ezután válassz ki egy meghajtót a telepítéshez, és dőlj hátra, és nézd a telepítési show-t. A leggyorsabb modern gépeken egy perc alatt kész lehet, de még egy régebbi számítógépen sem tarthat tovább 5 percnél.

 ![install-done](images/install-done.webp)

Most már készen állsz az Omarchy-ra!

### Használj vezetékes vagy 2.4ghz-es billentyűzetet!

A teljes lemezes titkosítás nem engedi, hogy Bluetooth billentyűzetről add meg a jelszót indításkor. Ahogy a BIOS-ba sem tudsz belépni Bluetooth billentyűzettel egy PC-n. Olyan billentyűzetre lesz szükséged, amely vagy 2.4ghz-es dongle-t használ, vagy kábeles (ami amúgy is sokkal jobb a késleltetés szempontjából!). Én személy szerint imádom a [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard) billentyűzetet!

### Telepítés másik tulajdonos számára

Ha valaki másnak állítasz be egy gépet — egy családtagnak, egy új alkalmazottnak, egy vevőnek — nem neked kellene megválaszolnod helyettük a személyes kérdéseket. Nyomd meg a `Ctrl + C` billentyűkombinációt a telepítő legelső képernyőjén (a billentyűzet kiválasztásánál), és az Omarchy felajánlja, hogy inkább egy másik tulajdonos számára készíti elő a gépet. A rendszer azonnal települ, de minden személyes beállítás — billentyűzetkiosztás, felhasználónév, jelszó — addig halasztódik, amíg a gép először el nem indul. A meghajtó továbbra is alapértelmezetten titkosított, és az a jelszó, amelyet az új tulajdonos azon az első indításkor választ, lesz a titkosítási jelszó is. (Egy már használt gépet újratelepítés nélkül is át lehet adni — lásd [a számítógép visszaállítása](48-security.md).)

### Felügyelet nélküli telepítések

Az ISO teljesen önállóan is tud telepíteni — billentyűzet nélkül, varázsló nélkül — ha egy második meghajtón megkapja a konfigurációját. Így érdemes az Omarchy-t alap image-ként kezelni VM-ekhez és flottagépekhez. Lásd [felügyelet nélküli telepítések](51-unattended-installs.md).

### Titkosítás nélküli telepítések

Az Omarchy alapértelmezetten titkosítással települ. Ez a biztonságos, felelős választás minden olyan számítógéphez, amely esetleg elveszhet vagy ellophatják. Nem akarod, hogy bárki, aki hozzáfér a hardveredhez, hozzá tudjon férni az adataidhoz!

De különleges körülmények között, például védett számítógépekre történő távoli Omarchy telepítéseknél vagy érzékeny adatok nélküli eldobható telepítéseknél, előfordulhat, hogy titkosítás nélkül szeretnél telepíteni. A lemezformázás megerősítésénél megnyomhatod a `Ctrl + C` billentyűkombinációt, hogy titkosítás nélküli telepítésre válts.

### Nyelv

Az Omarchy 50 nyelven beszél — ugyanazon a készleten, mint az omarchy.org — és az alapértelmezett az angol. A váltáshoz nyisd meg az Omarchy menüt, és menj a _Setup > Language_ menüpontra, vagy futtasd az `omarchy language <code>` parancsot egy terminálban (az `omarchy language list` mutatja a kódokat). A menü, az asztal és az Omarchy saját értesítései azonnal nyelvet váltanak, és minden utána megnyitott alkalmazás is követi őket. A már megnyitott alkalmazások akkor váltanak, amikor újraindítod őket.

### Segítség, ha elakadtál

Ha elakadsz, általában találsz valakit, aki szívesen segít a _#omarchy-help_ csatornán [a közösségi Discordon](https://omarchy.org/discord).
